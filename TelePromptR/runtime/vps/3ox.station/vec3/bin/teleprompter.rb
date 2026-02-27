#!/usr/bin/env ruby
# frozen_string_literal: true

# ▛//▞▞ TELEPROMPTER v2.0 ▞▞
# MetaTron Forge Telegram Bot (VPS Deployment)
# Thread-aware, Sirius-timed, Accountability-enabled

require 'net/http'
require 'json'
require 'uri'
require 'time'
require 'fileutils'
require 'securerandom'

# VPS Deployment paths - 3ox.service structure
# bin/ is at vec3/bin/, var/ is at vec3/var/
BIN_DIR = File.dirname(File.expand_path(__FILE__))
VEC3_DIR = File.dirname(BIN_DIR)
VAR_DIR = File.join(VEC3_DIR, 'var')
LOG_DIR = File.join(VAR_DIR, 'logs')
LOG_FILE = File.join(LOG_DIR, 'teleprompter.log')
STATE_FILE = File.join(VAR_DIR, 'state.json')
TOPICS_FILE = File.join(VAR_DIR, 'topics.json')
AGENTS_FILE = File.join(VAR_DIR, 'agents.json')
MONITOR_API = ENV['MONITOR_API'] || 'http://127.0.0.1:4567'

# For backward compatibility
DAEMON_VAR_DIR = VAR_DIR

FileUtils.mkdir_p(LOG_DIR)
FileUtils.mkdir_p(VAR_DIR)

#═══════════════════════════════════════════════════════════════════════════════
# LOGGING
#═══════════════════════════════════════════════════════════════════════════════

def log(message, level = 'info')
  timestamp = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
  log_entry = "[#{timestamp}] [#{level.upcase}] Teleprompter: #{message}"
  File.open(LOG_FILE, 'a') { |f| f.puts(log_entry) }
  puts log_entry if level == 'info' || level == 'error' || level == 'warn'
end

#═══════════════════════════════════════════════════════════════════════════════
# TOKEN LOADING
#═══════════════════════════════════════════════════════════════════════════════

BOT_TOKEN = begin
  token = ENV['TELEGRAM_BOT_TOKEN'] || ''
  if token.empty?
    token_file = File.join(DAEMON_VAR_DIR, 'telegram_token.json')
    if File.exist?(token_file)
      data = JSON.parse(File.read(token_file)) rescue {}
      token = data['token'] || data['bot_token'] || ''
    end
  end
  token
end

if BOT_TOKEN.empty?
  log("ERROR: Telegram bot token not found", 'error')
  exit 1
end

TELEGRAM_API = "https://api.telegram.org/bot#{BOT_TOKEN}"

#═══════════════════════════════════════════════════════════════════════════════
# CONFIG HELPERS
#═══════════════════════════════════════════════════════════════════════════════

def truthy?(value)
  %w[1 true yes y on].include?(value.to_s.strip.downcase)
end

def int_env(key, default)
  raw = ENV[key].to_s.strip
  return default if raw.empty?

  Integer(raw)
rescue StandardError
  default
end

# Autopilot: background summaries / fun-facts, strict <10% autopost ratio.
AUTOPILOT_ENABLED = truthy?(ENV['TPR_AUTOPILOT_ENABLED'])
AUTOPILOT_AGENT = begin
  v = ENV['TPR_AUTOPILOT_AGENT'].to_s.strip
  v.empty? ? 'Lobby' : v
end
AUTOPILOT_TOPIC_KEY = ENV['TPR_AUTOPILOT_TOPIC_KEY'].to_s.strip # optional scope
AUTOPILOT_MIN_HUMAN = int_env('TPR_AUTOPILOT_MIN_HUMAN', 12) # 1 post per 12+ human msgs (~8.3%)
AUTOPILOT_IDLE_S = int_env('TPR_AUTOPILOT_IDLE_S', 120)
AUTOPILOT_COOLDOWN_S = int_env('TPR_AUTOPILOT_COOLDOWN_S', 900)

#═══════════════════════════════════════════════════════════════════════════════
# STATE MANAGEMENT
#═══════════════════════════════════════════════════════════════════════════════

def default_state
  {
    'last_update_id' => 0,
    'chats' => [],
    'topic_stats' => {}
  }
end

def load_state
  payload =
    if File.exist?(STATE_FILE)
      JSON.parse(File.read(STATE_FILE)) rescue {}
    else
      {}
    end

  payload = {} unless payload.is_a?(Hash)
  state = default_state.merge(payload)
  state['chats'] ||= []
  state['topic_stats'] ||= {}
  state
end

def save_state(state)
  File.write(STATE_FILE, JSON.pretty_generate(state))
end

def load_topics
  return {} unless File.exist?(TOPICS_FILE)
  JSON.parse(File.read(TOPICS_FILE)) rescue {}
end

def save_topics(topics)
  File.write(TOPICS_FILE, JSON.pretty_generate(topics))
end

def load_agents
  return {} unless File.exist?(AGENTS_FILE)
  JSON.parse(File.read(AGENTS_FILE)) rescue {}
end

def save_agents(agents)
  File.write(AGENTS_FILE, JSON.pretty_generate(agents))
end

#═══════════════════════════════════════════════════════════════════════════════
# SIRIUS TIME
#═══════════════════════════════════════════════════════════════════════════════

def sirius_time
  days_since_reset = (Time.now.utc - Time.utc(2025, 8, 8)).to_i / 86400
  year = 25 + (days_since_reset / 365)
  day = days_since_reset % 365
  "⧗-#{year}.#{day.to_s.rjust(3, '0')}"
rescue
  "⧗-??.???"
end

#═══════════════════════════════════════════════════════════════════════════════
# TELEGRAM API (Hardened)
#═══════════════════════════════════════════════════════════════════════════════

HTTP_TIMEOUT = 30
MAX_RETRIES = 3
RETRY_DELAY = 2

# Rate limiting
$last_api_call = Time.now
$api_calls_this_minute = 0
DEFAULT_MAX_CALLS_PER_MINUTE = 30
MAX_CALLS_PER_MINUTE = int_env('TPR_TELEGRAM_MAX_CALLS_PER_MINUTE', DEFAULT_MAX_CALLS_PER_MINUTE)

def rate_limit_check
  now = Time.now
  if now - $last_api_call > 60
    $api_calls_this_minute = 0
    $last_api_call = now
  end
  
  if $api_calls_this_minute >= MAX_CALLS_PER_MINUTE
    sleep_time = 60 - (now - $last_api_call)
    log("Rate limit reached, sleeping #{sleep_time.round}s", 'warn')
    sleep(sleep_time) if sleep_time > 0
    $api_calls_this_minute = 0
    $last_api_call = Time.now
  end
  
  $api_calls_this_minute += 1
end

def telegram_get(method, params = {}, retries = 0)
  rate_limit_check
  
  uri = URI("#{TELEGRAM_API}/#{method}")
  uri.query = URI.encode_www_form(params) unless params.empty?
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = HTTP_TIMEOUT
  http.read_timeout = HTTP_TIMEOUT
  
  response = http.get(uri.request_uri)
  
  if response.code == '200'
    JSON.parse(response.body)
  elsif response.code == '429' # Rate limited
    retry_after = JSON.parse(response.body).dig('parameters', 'retry_after') || 30
    log("Telegram rate limited, waiting #{retry_after}s", 'warn')
    sleep(retry_after)
    telegram_get(method, params, retries + 1) if retries < MAX_RETRIES
  else
    log("Telegram API returned #{response.code}: #{response.body[0..100]}", 'warn')
    nil
  end
rescue Net::OpenTimeout, Net::ReadTimeout => e
  log("Telegram timeout: #{e.message}", 'warn')
  if retries < MAX_RETRIES
    sleep(RETRY_DELAY * (retries + 1))
    telegram_get(method, params, retries + 1)
  end
rescue => e
  log("Telegram API error: #{e.class} - #{e.message}", 'error')
  if retries < MAX_RETRIES
    sleep(RETRY_DELAY * (retries + 1))
    telegram_get(method, params, retries + 1)
  end
end

def telegram_post(method, params, retries = 0)
  rate_limit_check
  
  uri = URI("#{TELEGRAM_API}/#{method}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = HTTP_TIMEOUT
  http.read_timeout = HTTP_TIMEOUT
  
  request = Net::HTTP::Post.new(uri.path)
  request.set_form_data(params)
  response = http.request(request)
  
  if response.code == '200'
    JSON.parse(response.body)
  elsif response.code == '429' # Rate limited
    retry_after = JSON.parse(response.body).dig('parameters', 'retry_after') || 30
    log("Telegram rate limited, waiting #{retry_after}s", 'warn')
    sleep(retry_after)
    telegram_post(method, params, retries + 1) if retries < MAX_RETRIES
  else
    log("Telegram POST returned #{response.code}: #{response.body[0..100]}", 'warn')
    nil
  end
rescue Net::OpenTimeout, Net::ReadTimeout => e
  log("Telegram timeout: #{e.message}", 'warn')
  if retries < MAX_RETRIES
    sleep(RETRY_DELAY * (retries + 1))
    telegram_post(method, params, retries + 1)
  end
rescue => e
  log("Telegram API error: #{e.class} - #{e.message}", 'error')
  if retries < MAX_RETRIES
    sleep(RETRY_DELAY * (retries + 1))
    telegram_post(method, params, retries + 1)
  end
end

def send_message(chat_id, text, parse_mode = nil, thread_id = nil)
  params = { chat_id: chat_id, text: text }
  params[:parse_mode] = parse_mode if parse_mode
  params[:message_thread_id] = thread_id if thread_id
  telegram_post('sendMessage', params)
end

#═══════════════════════════════════════════════════════════════════════════════
# STATUS LOG NOTIFICATIONS
#═══════════════════════════════════════════════════════════════════════════════

def notify_status_log(message, emoji = "📢")
  topics = load_topics
  status_topic = topics.values.find { |t| 
    name = t['name']&.downcase || ''
    name.include?('status') || name.include?('log')
  }
  return unless status_topic
  
  timestamp = Time.now.utc.strftime('%H:%M:%S')
  params = { 
    chat_id: status_topic['chat_id'], 
    text: "[#{timestamp}] #{emoji} #{message}"
  }
  params[:message_thread_id] = status_topic['thread_id'] if status_topic['thread_id']
  telegram_post('sendMessage', params)
end

#═══════════════════════════════════════════════════════════════════════════════
# MONITOR API
#═══════════════════════════════════════════════════════════════════════════════

def get_monitor_api(endpoint)
  return nil if MONITOR_API.nil? || MONITOR_API.empty?
  uri = URI("#{MONITOR_API}/api/#{endpoint}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 5
  http.open_timeout = 5
  response = http.get(uri.path)
  JSON.parse(response.body) if response.code == '200'
rescue
  nil
end

def format_daemon_status(daemons)
  return "❌ Monitor API unavailable" unless daemons
  running = daemons.select { |d| d['status'] == 'running' }
  text = "🤖 *Daemon Status* (#{running.length}/#{daemons.length})\n\n"
  daemons.each do |daemon|
    emoji = daemon['status'] == 'running' ? '🟢' : '⚪'
    text += "#{emoji} #{daemon['name']}: #{daemon['status']}\n"
  end
  text
end

#═══════════════════════════════════════════════════════════════════════════════
# COMMAND HANDLER
#═══════════════════════════════════════════════════════════════════════════════

def handle_command(command, chat_id, full_text, thread_id = nil)
  topics = load_topics
  agents = load_agents
  state = load_state
  
  case command
  when 'ping'
    send_message(chat_id, "🏓 PONG - Teleprompter ONLINE\n#{sirius_time}", nil, thread_id)
    
  when 'health'
    h = health_status
    uptime_hours = h[:uptime_seconds] / 3600.0
    msg = "🩺 *TELEPROMPTER HEALTH*\n\n"
    msg += "Version: `#{h[:version]}`\n"
    msg += "Status: #{h[:status] == 'ok' ? '🟢' : '🔴'} #{h[:status]}\n"
    msg += "Uptime: #{uptime_hours.round(1)}h\n"
    msg += "#{h[:sirius_time]}\n\n"
    msg += "*Stats:*\n"
    msg += "Updates: #{h[:stats][:updates_processed]}\n"
    msg += "Commands: #{h[:stats][:commands_handled]}\n"
    msg += "Mentions: #{h[:stats][:mentions_routed]}\n"
    msg += "Outbox: #{h[:stats][:outbox_sent]}\n"
    msg += "Errors: #{h[:stats][:errors]}\n"
    msg += "Last: #{h[:stats][:last_update] || 'none'}"
    send_message(chat_id, msg, 'Markdown', thread_id)
    
  when 'start', 'help'
    text = "🤖 *TELEPROMPTER v2.0*\n"
    text += "#{sirius_time}\n\n"
    text += "*Core Commands:*\n"
    text += "/ping - Check connectivity\n"
    text += "/status - Full system status\n"
    text += "/health - Health stats\n"
    text += "/sirius - Sirius time\n\n"
    text += "*Topic Management:*\n"
    text += "/topic add [name] - Register topic\n"
    text += "/topics - List all topics\n\n"
    text += "*Forge Integration:*\n"
    text += "/daemons - Daemon status\n"
    text += "/scans - Recent activity\n"
    text += "/goals - Forge goals\n\n"
    text += "*Agent Commands:*\n"
    text += "/teleprompter subkey signon [name]"
    send_message(chat_id, text, 'Markdown', thread_id)
    
  when 'sirius'
    send_message(chat_id, "⏱️ *Sirius Time:* #{sirius_time}", 'Markdown', thread_id)
    
  when 'status'
    message = "🖥️ *TELEPROMPTER STATUS*\n"
    message += "#{sirius_time}\n\n"
    
    # Bus Agents
    message += "📡 *Bus Agents:* #{agents.keys.length} registered\n"
    agents.each do |name, info|
      glyph = info['glyph'] || info['pico_glyph'] || '🤖'
      message += "🟢 #{glyph} #{name}\n"
    end
    message += "\n"
    
    # Groups & Topics
    message += "📋 *Groups & Topics*\n\n"
    
    # Group topics by chat_id
    chats_with_topics = {}
    state['chats']&.each do |chat|
      chats_with_topics[chat['chat_id']] = {
        'title' => chat['title'],
        'type' => chat['type'],
        'topics' => []
      }
    end
    
    topics.each do |topic_key, topic_info|
      cid = topic_info['chat_id']
      if chats_with_topics[cid]
        chats_with_topics[cid]['topics'] << {
          'name' => topic_info['name'],
          'thread_id' => topic_info['thread_id']
        }
      end
    end
    
    message += "💬 *Groups:* #{chats_with_topics.length}\n"
    chats_with_topics.each do |cid, info|
      message += "🟢 #{info['title']}\n"
      message += "  ID: #{cid} | Type: #{info['type']}\n"
      info['topics'].each do |t|
        tid = t['thread_id'] ? " (ID: #{t['thread_id']})" : ""
        message += "  └─ #{t['name']}#{tid}\n"
      end
    end
    
    send_message(chat_id, message, 'Markdown', thread_id)
    
  when 'topics'
    if topics.empty?
      send_message(chat_id, "📋 No topics registered.\n\nUse /topic add [name] to register.", nil, thread_id)
    else
      message = "📋 *Registered Topics:*\n\n"
      topics.each do |key, info|
        tid = info['thread_id'] ? " (thread: #{info['thread_id']})" : ""
        message += "• #{info['name'] || key}#{tid}\n"
        message += "  Key: `#{key}`\n\n"
      end
      send_message(chat_id, message, 'Markdown', thread_id)
    end
    
  when 'topic'
    parts = full_text.split
    if parts[1]&.downcase == 'add'
      # Get custom name from command
      custom_name = parts[2..-1]&.join(' ')
      
      # Get chat info
      chat_info = telegram_get('getChat', { chat_id: chat_id })
      if chat_info && chat_info['ok']
        chat_data = chat_info['result']
        chat_title = chat_data['title'] || chat_data['username'] || "Chat"
        
        # Create topic key with thread_id for forum topics
        if thread_id
          topic_key = "#{chat_id}:#{thread_id}"
          topic_name = custom_name && !custom_name.empty? ? custom_name : "Thread #{thread_id}"
        else
          topic_key = chat_id.to_s
          topic_name = custom_name && !custom_name.empty? ? custom_name : chat_title
        end
        
        topics[topic_key] = {
          'name' => topic_name,
          'chat_id' => chat_id,
          'thread_id' => thread_id,
          'chat_title' => chat_title,
          'type' => chat_data['type'] || 'unknown',
          'registered_at' => Time.now.utc.iso8601
        }
        save_topics(topics)
        
        # Send init message
        init_msg = "▛//▞▞ ⟦⚡⟧ :: TOPIC INITIALIZED ▞▞\n\n"
        init_msg += "📋 *Topic:* #{topic_name}\n"
        init_msg += "🆔 *Key:* `#{topic_key}`\n"
        init_msg += "💬 *Chat:* #{chat_title}\n"
        init_msg += thread_id ? "🧵 *Thread:* #{thread_id}\n" : ""
        init_msg += "⏰ *Time:* #{sirius_time}\n\n"
        init_msg += "✅ Agents can now post to this topic."
        
        send_message(chat_id, init_msg, 'Markdown', thread_id)
        log("Topic registered: #{topic_name} (#{topic_key})", 'info')
        
        # Notify Status Log
        notify_status_log("📥 New Topic: #{topic_name}", "📥")
      else
        send_message(chat_id, "❌ Could not retrieve chat information.", nil, thread_id)
      end
    else
      send_message(chat_id, "Usage: /topic add [name]\n\nExamples:\n/topic add 👑 MetaTron\n/topic add 🖨 Status Log", nil, thread_id)
    end
    
  when 'daemons'
    daemons = get_monitor_api('daemons')
    text = format_daemon_status(daemons)
    send_message(chat_id, text, 'Markdown', thread_id)
    
  when 'scans'
    scans = get_monitor_api('scans')
    if scans
      text = "📝 *Recent Activity*\n\n"
      scans.first(5).each do |s|
        text += "• #{s['file']} → #{s['base']}\n"
      end
      send_message(chat_id, text, 'Markdown', thread_id)
    else
      send_message(chat_id, "❌ Monitor API unavailable", nil, thread_id)
    end
    
  when 'goals'
    goals = get_monitor_api('forge-goals')
    if goals && goals.is_a?(Array)
      text = "🎯 *Forge Goals*\n\n"
      goals.each { |g| text += "#{g['number']}. #{g['title']}\n" }
      send_message(chat_id, text, 'Markdown', thread_id)
    else
      send_message(chat_id, "❌ Monitor API unavailable", nil, thread_id)
    end
    
  when 'teleprompter'
    parts = full_text.split
    subcommand = parts[1]&.downcase
    
    if subcommand == 'subkey' && parts[2]&.downcase == 'signon'
      # /teleprompter subkey signon [name] [glyph]
      agent_name = parts[3] || "Agent_#{SecureRandom.hex(4)}"
      agent_glyph = parts[4] || '🤖'
      subkey = SecureRandom.hex(32)
      
      # Find Initializing topic for init post
      init_topic = topics.values.find { |t| 
        name = t['name']&.downcase || ''
        name.include?('init') || name.include?('initializing')
      }
      
      agents[agent_name] = {
        'agent_id' => agent_name,
        'subkey' => subkey,
        'glyph' => agent_glyph,
        'capabilities' => [],
        'subscriptions' => [],
        'status' => 'online',
        'signon_time' => Time.now.utc.iso8601,
        'last_seen' => Time.now.utc.iso8601,
        'chat_id' => chat_id
      }
      save_agents(agents)
      
      # Response to user - show FULL subkey
      msg = "🔑 *Agent Signon Complete*\n\n"
      msg += "#{agent_glyph} Agent: *#{agent_name}*\n\n"
      msg += "*Subkey (copy to agent):*\n"
      msg += "`#{subkey}`\n\n"
      msg += "*Save to:* `.3ox/keys/#{agent_name}.subkey`\n\n"
      msg += "*Next Steps:*\n"
      msg += "1. Copy subkey to agent's `.3ox/keys/`\n"
      msg += "2. Subscribe: `/teleprompter subscribe <TID>`"
      send_message(chat_id, msg, 'Markdown', thread_id)
      log("Agent signed on: #{agent_name} (#{agent_glyph})", 'info')
      
      # Post init message to Initializing topic
      if init_topic
        init_msg = "▛▞// #{agent_glyph} *#{agent_name}* :: ONLINE ▞▞\n"
        init_msg += "#{sirius_time}"
        params = { chat_id: init_topic['chat_id'], text: init_msg, parse_mode: 'Markdown' }
        params[:message_thread_id] = init_topic['thread_id'] if init_topic['thread_id']
        telegram_post('sendMessage', params)
        log("Init posted for #{agent_name} to Initializing topic", 'info')
      end
      
      # Notify Status Log
      notify_status_log("#{agent_glyph} #{agent_name} signed on", "🤖")
      
    elsif subcommand == 'subscribe'
      # /teleprompter subscribe <TID> [agent_name]
      tid_input = parts[2]
      agent_name = parts[3]
      
      if tid_input.nil?
        # List available topics with short TIDs
        msg = "📋 *Available Topics:*\n\n"
        msg += "*Groups:*\n"
        topics.each do |key, info|
          next if info['thread_id']  # Skip topics, show groups first
          msg += "• #{info['name']}\n"
        end
        msg += "\n*Topics (use TID to subscribe):*\n"
        topics.each do |key, info|
          next unless info['thread_id']  # Only topics with thread_id
          tid = info['thread_id']
          msg += "• #{info['name']} → TID:`#{tid}`\n"
        end
        msg += "\nUsage: `/teleprompter subscribe <TID>`\n"
        msg += "Example: `/teleprompter subscribe 295`"
        send_message(chat_id, msg, 'Markdown', thread_id)
        
      else
        # Find topic by TID (short form) or full key
        topic_key = nil
        if tid_input.include?(':')
          # Full key provided
          topic_key = tid_input if topics[tid_input]
        else
          # TID only - find matching topic
          topics.each do |key, info|
            if info['thread_id'].to_s == tid_input.to_s
              topic_key = key
              break
            end
          end
        end
        
        if topic_key && topics[topic_key]
        # Find agent (by name or by chat_id)
        if agent_name && agents[agent_name]
          target_agent = agent_name
        else
          # Find agent registered from this chat
          target_agent = agents.keys.find { |k| agents[k]['chat_id'] == chat_id }
        end
        
        if target_agent && agents[target_agent]
          agents[target_agent]['subscriptions'] ||= []
          unless agents[target_agent]['subscriptions'].include?(topic_key)
            agents[target_agent]['subscriptions'] << topic_key
          end
          agents[target_agent]['last_seen'] = Time.now.utc.iso8601
          save_agents(agents)
          
          glyph = agents[target_agent]['glyph'] || '🤖'
          topic_name = topics[topic_key]['name']
          
          msg = "✅ #{glyph} *#{target_agent}* subscribed to *#{topic_name}*\n\n"
          msg += "Topic Key: `#{topic_key}`"
          send_message(chat_id, msg, 'Markdown', thread_id)
          log("#{target_agent} subscribed to #{topic_name}", 'info')
          notify_status_log("#{glyph} #{target_agent} → #{topic_name}", "📨")
        else
          send_message(chat_id, "❌ No agent found. Sign on first:\n`/teleprompter subkey signon [name]`", 'Markdown', thread_id)
        end
        else
          send_message(chat_id, "❌ Topic not found: TID `#{tid_input}`\n\nUse `/teleprompter subscribe` to list topics.", 'Markdown', thread_id)
        end
      end
      
    elsif subcommand == 'agents'
      # /teleprompter agents - List all agents
      if agents.empty?
        send_message(chat_id, "📋 No agents registered.", nil, thread_id)
      else
        msg = "📋 *Registered Agents:*\n\n"
        agents.each do |name, info|
          glyph = info['glyph'] || '🤖'
          status = info['status'] || 'unknown'
          subs = info['subscriptions']&.length || 0
          msg += "#{glyph} *#{name}* (#{status})\n"
          msg += "  Subscriptions: #{subs}\n"
        end
        send_message(chat_id, msg, 'Markdown', thread_id)
      end
      
    else
      help_msg = "*Teleprompter Commands:*\n\n"
      help_msg += "`/teleprompter subkey signon [name] [glyph]`\n"
      help_msg += "  Sign on a new agent\n\n"
      help_msg += "`/teleprompter subscribe [topic_key]`\n"
      help_msg += "  Subscribe agent to a topic\n\n"
      help_msg += "`/teleprompter agents`\n"
      help_msg += "  List all agents"
      send_message(chat_id, help_msg, 'Markdown', thread_id)
    end
    
  else
    send_message(chat_id, "❓ Unknown: /#{command}\n\nSend /help for commands.", nil, thread_id)
  end
rescue => e
  log("Command error: #{e.message}", 'error')
  send_message(chat_id, "❌ Error: #{e.message}", nil, thread_id)
end

#═══════════════════════════════════════════════════════════════════════════════
# MESSAGE NORMALIZATION
#═══════════════════════════════════════════════════════════════════════════════

def normalize_message(text, agent_name = nil)
  """
  Normalize all messages before routing to agents.
  Ensures consistent formatting, loading bars (MetaTron style), and proper structure.
  """
  return nil if text.nil? || text.empty?
  
  # Clean up text
  normalized = text.strip
  
  # Extract agent mentions for routing
  agent_mentions = []
  agents = load_agents
  agents.each do |name, info|
    patterns = [
      /@#{Regexp.escape(name)}/i,
      /^#{Regexp.escape(name)}[:\s]/i,
      /\b#{Regexp.escape(name)}:/i
    ]
    
    patterns.each do |pattern|
      if normalized.match?(pattern)
        agent_mentions << name
        # Remove mention from text for processing
        normalized = normalized.gsub(pattern, '').strip
      end
    end
  end
  
  # Add loading bar indicator if processing (MetaTron style)
  if normalized.length > 20 && !normalized.match?(/loading|processing|compiling|seeding|indexing/i)
    # Don't add loading bar for short messages or if already present
  end
  
  {
    'original' => text,
    'normalized' => normalized,
    'agent_mentions' => agent_mentions,
    'timestamp' => Time.now.utc.iso8601,
    'sirius_time' => sirius_time
  }
end

#═══════════════════════════════════════════════════════════════════════════════
# @MENTION ROUTING
#═══════════════════════════════════════════════════════════════════════════════

INBOX_DIR = File.join(DAEMON_VAR_DIR, 'inbox')
OUTBOX_DIR = File.join(DAEMON_VAR_DIR, 'outbox')
PROCESSED_DIR = File.join(DAEMON_VAR_DIR, 'processed')
FileUtils.mkdir_p(INBOX_DIR)
FileUtils.mkdir_p(OUTBOX_DIR)
FileUtils.mkdir_p(PROCESSED_DIR)

def handle_mentions(message, chat_id, text, thread_id)
  return [] if text.nil? || text.empty?
  
  agents = load_agents
  return [] if agents.empty?
  
  # Extract @mentions from message entities
  entities = message['entities'] || []
  mentions = entities.select { |e| e['type'] == 'mention' }
  
  # Also check for text_mention (for users without username)
  text_mentions = entities.select { |e| e['type'] == 'text_mention' }
  
  # Extract mentioned usernames from text
  mentioned_usernames = mentions.map do |m|
    offset = m['offset']
    length = m['length']
    text[offset, length]&.delete_prefix('@')&.downcase
  end.compact
  
  # Also check for direct agent name mentions (e.g., "@MetaTron" or "MetaTron:")
  agent_names = agents.keys.map(&:downcase)
  
  # Find agents mentioned by @username or by name pattern
  matched_agents = []
  
  # Check @mentions
  mentioned_usernames.each do |username|
    agents.each do |name, info|
      # Match if agent name contains the mention or vice versa
      if name.downcase.include?(username) || username.include?(name.downcase)
        matched_agents << { name: name, info: info, mention: "@#{username}" }
      end
    end
  end
  
  # Check for agent name patterns like "MetaTron:" or "@MetaTron"
  agents.each do |name, info|
    pattern_mentions = [
      /@#{Regexp.escape(name)}/i,           # @AgentName
      /^#{Regexp.escape(name)}[:\s]/i,      # AgentName: at start
      /\b#{Regexp.escape(name)}:/i          # AgentName: anywhere
    ]
    
    pattern_mentions.each do |pattern|
      if text.match?(pattern) && !matched_agents.any? { |m| m[:name] == name }
        matched_agents << { name: name, info: info, mention: name }
      end
    end
  end
  
  return [] if matched_agents.empty?
  
  # Route message to each matched agent
  matched_agents.each do |match|
    route_to_agent(match[:name], match[:info], message, chat_id, text, thread_id, route_reason: 'mention')
  end

  matched_agents.map { |m| m[:name] }
end

def topic_key_for(chat_id, thread_id)
  return chat_id.to_s if thread_id.nil? || thread_id.to_s.strip.empty?

  "#{chat_id}:#{thread_id}"
end

def route_to_subscribers(message, chat_id, text, thread_id, skip_agents: [])
  agents = load_agents
  return [] if agents.empty?

  key = topic_key_for(chat_id, thread_id)
  chat_key = chat_id.to_s
  routed = []

  agents.each do |name, info|
    subs = info['subscriptions']
    next unless subs.is_a?(Array)
    subscribed = subs.include?(key) || (key != chat_key && subs.include?(chat_key))
    next unless subscribed
    next if skip_agents.include?(name)

    route_to_agent(
      name,
      info,
      message,
      chat_id,
      text,
      thread_id,
      route_reason: 'subscription',
      meta: { 'listen_only' => true, 'subscription' => key }
    )
    routed << name
  end

  routed
end

def route_to_agent(agent_name, agent_info, message, chat_id, text, thread_id, route_reason: 'mention', meta: nil)
  agent_info = {} unless agent_info.is_a?(Hash)
  meta = {} unless meta.is_a?(Hash)

  # Normalize message before routing
  normalized = normalize_message(text, agent_name)
  
  # Create message envelope for agent inbox
  envelope = {
    'message_id' => "msg_#{Time.now.to_f.to_s.gsub('.', '')}",
    'from_chat_id' => chat_id,
    'from_thread_id' => thread_id,
    'from_user' => message['from'],
    'text' => normalized ? normalized['normalized'] : text,
    'original_text' => normalized ? normalized['original'] : text,
    'raw_message' => message,
    'routed_to' => agent_name,
    'route_reason' => route_reason,
    'meta' => meta,
    'routed_at' => Time.now.utc.iso8601,
    'sirius_time' => normalized ? normalized['sirius_time'] : sirius_time,
    'normalized' => true
  }
  
  # Write to agent's inbox
  inbox_file = File.join(INBOX_DIR, "#{agent_name}_#{envelope['message_id']}.json")
  File.write(inbox_file, JSON.pretty_generate(envelope))
  
  $health_stats[:mentions_routed] += 1 if route_reason == 'mention'
  log("routed to #{agent_name} reason=#{route_reason}: #{text[0..50]}...", 'info')
  
  # Optionally acknowledge the mention (can be disabled)
  glyph = agent_info['glyph'] || '🤖'
  # Uncomment to send acknowledgment:
  # send_message(chat_id, "#{glyph} Message routed to *#{agent_name}*", 'Markdown', thread_id)
end

#═══════════════════════════════════════════════════════════════════════════════
# OUTBOX PROCESSING (Agent Responses)
#═══════════════════════════════════════════════════════════════════════════════

def process_outbox
  Dir.glob(File.join(OUTBOX_DIR, '*.json')).each do |outbox_file|
    begin
      envelope = JSON.parse(File.read(outbox_file))
      
      # Support both TPR.MSG format and legacy format
      if envelope['tpr']
        # New TPR.MSG format
        tpr = envelope['tpr']
        route = envelope['route'] || {}
        chat_id = route['chat_id']
        thread_id = route['thread_id']
        text = tpr['msg']
        parse_mode = route['parse_mode']
        agent_name = tpr['src']
        severity = tpr['sev'] || 'INFO'
        glyph = tpr['glyph'] || '🤖'
        dest = tpr['dst'] || '*'
        pico = tpr['pico'] || '▷'
        dir_token = tpr['dir'] || '›'
      else
        # Legacy format
        chat_id = envelope['chat_id'] || envelope['to_chat_id']
        thread_id = envelope['thread_id'] || envelope['topic_thread_id'] || envelope['to_thread_id']
        text = envelope['text'] || envelope['message']
        parse_mode = envelope['parse_mode']
        agent_name = envelope['from_agent'] || envelope['agent_id']
        severity = (envelope['severity'] || 'info').upcase
        glyph = '🤖'
        dest = '*'
        pico = '▷'
        dir_token = '›'
      end
      
      next unless chat_id && text
      
      # Send the message
      result = send_message(chat_id, text, parse_mode, thread_id)
      
      if result && result['ok']
        $health_stats[:outbox_sent] += 1
        # Log in TPR.MSG format
        log("//▞⋮⋮ ⟦#{glyph}⟧ :: [#{agent_name}] [#{dest}] [#{severity}] [#{pico}]", 'info')
        log("#{dir_token} #{text[0..60]}", 'info')
        
        # Move to processed
        processed_file = File.join(PROCESSED_DIR, File.basename(outbox_file))
        envelope['sent_at'] = Time.now.utc.iso8601
        envelope['telegram_result'] = result
        File.write(processed_file, JSON.pretty_generate(envelope))
        File.delete(outbox_file)
      else
        log("Outbox send failed: #{result.inspect}", 'warn')
        # Leave in outbox for retry
      end
      
    rescue JSON::ParserError => e
      log("Invalid outbox JSON: #{outbox_file} - #{e.message}", 'error')
      File.delete(outbox_file) # Remove bad file
    rescue => e
      log("Outbox processing error: #{e.message}", 'error')
    end
  end
rescue => e
  log("Outbox scan error: #{e.message}", 'error')
end

#═══════════════════════════════════════════════════════════════════════════════
# AUTOPILOT (Summaries / Fun Facts)
#═══════════════════════════════════════════════════════════════════════════════

def ensure_topic_stats(state, topic_key)
  state['topic_stats'] ||= {}
  entry = state['topic_stats'][topic_key]
  entry = {} unless entry.is_a?(Hash)

  entry['human_count'] ||= 0
  entry['autopost_count'] ||= 0
  entry['human_since_autopost'] ||= 0
  entry['last_human_at'] ||= nil
  entry['last_autopost_at'] ||= nil

  state['topic_stats'][topic_key] = entry
  entry
end

def bump_human_topic_stats(state, chat_id, thread_id)
  key = topic_key_for(chat_id, thread_id)
  stats = ensure_topic_stats(state, key)
  stats['human_count'] = stats['human_count'].to_i + 1
  stats['human_since_autopost'] = stats['human_since_autopost'].to_i + 1
  stats['last_human_at'] = Time.now.utc.iso8601
end

def parse_iso_time(value)
  return nil if value.nil? || value.to_s.strip.empty?

  Time.parse(value.to_s)
rescue StandardError
  nil
end

def split_topic_key(topic_key)
  return [topic_key.to_s, nil] if topic_key.nil?
  text = topic_key.to_s
  return [text, nil] unless text.include?(':')

  chat_id, thread_id = text.split(':', 2)
  [chat_id, thread_id]
end

def max_autoposts_for(human_count)
  count = human_count.to_i
  return 0 if count <= 0

  # Strict: autoposts / human < 0.10  =>  autoposts * 10 < human
  (count - 1) / 10
end

def autopilot_ingest(message, chat_id, text, thread_id, skip_agents: [])
  return unless AUTOPILOT_ENABLED
  return if skip_agents.include?(AUTOPILOT_AGENT)
  return if text.to_s.strip.empty?
  return unless AUTOPILOT_TOPIC_KEY.empty? || AUTOPILOT_TOPIC_KEY == topic_key_for(chat_id, thread_id)

  route_to_agent(
    AUTOPILOT_AGENT,
    {},
    message,
    chat_id,
    text,
    thread_id,
    route_reason: 'autopilot_ingest',
    meta: { 'listen_only' => true, 'autopost_memory' => true }
  )
end

def maybe_emit_autoposts(state)
  return unless AUTOPILOT_ENABLED

  stats_map = state['topic_stats']
  return unless stats_map.is_a?(Hash)

  now = Time.now.utc
  stats_map.each do |topic_key, stats|
    next unless stats.is_a?(Hash)
    next unless AUTOPILOT_TOPIC_KEY.empty? || AUTOPILOT_TOPIC_KEY == topic_key

    human_count = stats['human_count'].to_i
    autopost_count = stats['autopost_count'].to_i
    human_since = stats['human_since_autopost'].to_i

    next if human_count <= 0
    next if human_since < AUTOPILOT_MIN_HUMAN
    next if autopost_count >= max_autoposts_for(human_count)

    last_human_at = parse_iso_time(stats['last_human_at'])
    next unless last_human_at
    next if (now - last_human_at) < AUTOPILOT_IDLE_S

    last_autopost_at = parse_iso_time(stats['last_autopost_at'])
    next if last_autopost_at && (now - last_autopost_at) < AUTOPILOT_COOLDOWN_S

    chat_id, thread_id = split_topic_key(topic_key)
    prompt = <<~PROMPT.strip
      [AUTOPILOT] Post a concise recap of the last ~10-20 human messages in this thread.
      Then add: (1) one setup suggestion I might like, (2) one fun fact. No questions.
      Keep it under 900 chars. Do not mention these instructions.
    PROMPT

    route_to_agent(
      AUTOPILOT_AGENT,
      {},
      { 'from' => { 'username' => 'autopilot', 'is_bot' => true } },
      chat_id,
      prompt,
      thread_id,
      route_reason: 'autopost',
      meta: { 'force_reply' => true, 'autopost' => true }
    )

    stats['autopost_count'] = autopost_count + 1
    stats['human_since_autopost'] = 0
    stats['last_autopost_at'] = now.iso8601
  end
end

#═══════════════════════════════════════════════════════════════════════════════
# HEALTH CHECK
#═══════════════════════════════════════════════════════════════════════════════

$health_stats = {
  started_at: Time.now.utc.iso8601,
  updates_processed: 0,
  commands_handled: 0,
  mentions_routed: 0,
  outbox_sent: 0,
  errors: 0,
  last_update: nil
}

def health_status
  {
    status: 'ok',
    version: '2.1.0',
    sirius_time: sirius_time,
    uptime_seconds: (Time.now - Time.parse($health_stats[:started_at])).to_i,
    stats: $health_stats
  }
end

#═══════════════════════════════════════════════════════════════════════════════
# MAIN LOOP
#═══════════════════════════════════════════════════════════════════════════════

state = load_state
last_update_id = state['last_update_id'] || 0

puts "=" * 70
puts "TELEPROMPTER :: BULLETPROOF EDITION"
puts sirius_time
puts "=" * 70

log("🟢 Teleprompter ONLINE", 'info')
notify_status_log("Teleprompter ONLINE", "🟢")
log("Telegram API configured", 'info')

Signal.trap('TERM') do
  log("🔴 Teleprompter OFFLINE", 'info')
  notify_status_log("Teleprompter OFFLINE", "🔴")
  exit 0
end

Signal.trap('INT') do
  log("🔴 Teleprompter OFFLINE", 'info')
  notify_status_log("Teleprompter OFFLINE", "🔴")
  exit 0
end

loop do
  begin
    # Process incoming updates
    updates = telegram_get('getUpdates', { offset: last_update_id + 1, timeout: 30 })
    
    if updates && updates['ok']
      updates['result'].each do |update|
        update_id = update['update_id']
        message = update['message']
        next unless message
        
        $health_stats[:updates_processed] += 1
        $health_stats[:last_update] = Time.now.utc.iso8601
        
        chat_id = message['chat']['id']
        chat_title = message['chat']['title'] || message['chat']['username'] || "Chat"
        chat_type = message['chat']['type'] || 'unknown'
        thread_id = message['message_thread_id']
        text = message['text'] || ''
        
        # Track chats
        state['chats'] ||= []
        existing = state['chats'].find { |c| c['chat_id'] == chat_id }
        if existing
          existing['last_seen'] = Time.now.utc.iso8601
          existing['title'] = chat_title
        else
          state['chats'] << { 'chat_id' => chat_id, 'title' => chat_title, 'type' => chat_type, 'last_seen' => Time.now.utc.iso8601 }
          log("New chat: #{chat_title} (#{chat_id})", 'info')
        end
        
        # Handle command
        if text.start_with?('/')
          command = text.split.first.delete_prefix('/').downcase
          log("Command: /#{command} from #{chat_title}", 'info')
          handle_command(command, chat_id, text, thread_id)
          $health_stats[:commands_handled] += 1
        else
          from = message['from']
          from_is_bot = from.is_a?(Hash) && truthy?(from['is_bot'])
          clean = text.to_s.strip
          if !from_is_bot && !clean.empty?
            bump_human_topic_stats(state, chat_id, thread_id)

            mentioned = handle_mentions(message, chat_id, text, thread_id)
            mentioned = [] unless mentioned.is_a?(Array)

            subscribed = route_to_subscribers(message, chat_id, text, thread_id, skip_agents: mentioned)
            subscribed = [] unless subscribed.is_a?(Array)

            autopilot_ingest(message, chat_id, text, thread_id, skip_agents: (mentioned + subscribed).uniq)
          end
        end
        
        last_update_id = update_id if update_id > last_update_id
      end
    end
    
    # Process agent outbox (responses)
    process_outbox

    # Autopilot uses topic_stats + idle windows; may enqueue inbox events for mesh.
    maybe_emit_autoposts(state)
    
    state['last_update_id'] = last_update_id
    save_state(state)
    sleep 1
    
  rescue Interrupt
    log("🔴 Teleprompter OFFLINE", 'info')
    break
  rescue => e
    log("Error: #{e.class} - #{e.message}", 'error')
    log("Backtrace: #{e.backtrace.first(3).join(' | ')}", 'error')
    $health_stats[:errors] += 1
    sleep 5
  end
end
