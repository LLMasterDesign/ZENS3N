# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x87A6]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // TELEGRAM.RB ▞▞
# ▛▞// TELEGRAM.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [tape] [telegram] [json] [toml] [yaml] [dispatch] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.telegram.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for TELEGRAM.RB
# ```

# 


# 


# ▛//▞ PRISM :: KERNEL
# P:: identity.matrix ∙ context.anchor ∙ execution.flow
# R:: load.context ∙ execute.logic ∙ emit.result
# I:: intent.target={system.stability ∙ function.execution}
# S:: init → process → terminate
# M:: std.io ∙ file.sys ∙ mem.state
# :: ∎

#!/usr/bin/env ruby
# frozen_string_literal: true

module Z3N
  SPEC = {
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // TELEGRAM ▞▞',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [telegram] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.06
##/// Last Updated: 2026.01.06 | Trace.ID: telegram.v1.0
##/// Purpose: !/usr/bin/env ruby
##///          (Add second line of purpose here)
##///          (Add third line of purpose here)
#```
#
#▛//▞ TOOLSET ::
#(Add toolset commands here)
#/command1 = description1
#/command2 = description2

###▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂###
#
# LAW (NON-NEGOTIABLE):
# - Teleprompter is the only component that speaks to Telegram.
# - Brains/Stations/Dispatch never call Telegram directly. They emit outbox JSON events.
# - Outbox events are durable truth in !CMD.CENTER/!CMD.OPS/0ut.3ox/events
#
# This file keeps the historical name (telegram.rb) for compatibility,
# but its role is Teleprompter: ingest updates, execute jobs, emit outbox, publish outbox to Telegram.

require 'net/http'
require 'json'
require 'uri'
require 'fileutils'
require 'time'

require_relative '../rc/dispatch/dispatch'
require_relative 'llm'
require_relative 'telegram_bus'

module Vec3
  class Teleprompter
    TELEGRAM_API = 'https://api.telegram.org/bot'
    DEFAULT_STATION_ID = 'GENERAL'
    DEFAULT_BASE_ID = 'CMD.BRIDGE'

    attr_reader :token, :offset

    def initialize(token: nil)
      @token = token || env_or_secret('TELEGRAM_BOT_TOKEN')
      raise 'TELEGRAM_BOT_TOKEN not set' unless @token
      @offset = 0
      @running = false

      @base_id = ENV['BASE_ID'].to_s.strip
      @base_id = DEFAULT_BASE_ID if @base_id.empty?

      # Canon outbox location (local truth first)
      @cmd_root = File.expand_path('../../..', __dir__) # /root/!CMD.BRIDGE
      @outbox_events_dir = File.join(@cmd_root, '!CMD.CENTER', '!CMD.OPS', '0ut.3ox', 'events')
      @outbox_sent_dir = File.join(@cmd_root, '!CMD.CENTER', '!CMD.OPS', '0ut.3ox', 'sent')
      FileUtils.mkdir_p(@outbox_events_dir)
      FileUtils.mkdir_p(@outbox_sent_dir)
    end

    def env_or_secret(key)
      return ENV[key] if ENV[key] && !ENV[key].strip.empty?

      # Path: vec3/lib/telegram.rb -> vec3/rc/secrets/api.keys
      secrets_file = File.expand_path('../rc/secrets/api.keys', __dir__)
      return nil unless File.exist?(secrets_file)

      File.readlines(secrets_file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?('#')
        next unless line.start_with?("#{key}=")

        val = line.split('=', 2)[1].to_s.strip
        val = val.gsub(/^["']|["']$/, '')
        return val unless val.empty?
      end

      nil
    end

    # ═══════════════════════════════════════════════════════════════
    # Bot Loop
    # ═══════════════════════════════════════════════════════════════

    def start
      puts "▛▞ Teleprompter starting..."
      @running = true
      
      # Test connection
      me = api_call('getMe')
      if me['ok']
        puts "✓ Connected as @#{me['result']['username']}"
      else
        puts "✗ Connection failed: #{me['description']}"
        return
      end

      # Main loop
      while @running
        updates = get_updates
        updates.each { |update| handle_update(update) }
        drain_outbox
        drain_bus_outbox  # Process messages from agents/stations
        sync_tgsub_keys   # Create/update tgsub.key files for registered agents
        sleep 1
      end
    end

    def stop
      @running = false
      puts "▛▞ Teleprompter stopping..."
    end

    # ═══════════════════════════════════════════════════════════════
    # Updates
    # ═══════════════════════════════════════════════════════════════

    def get_updates
      result = api_call('getUpdates', offset: @offset, timeout: 30)
      return [] unless result['ok']

      updates = result['result'] || []
      @offset = updates.last['update_id'] + 1 unless updates.empty?
      updates
    end

    def handle_update(update)
      message = update['message']
      return unless message

      chat_id = message['chat']['id']
      topic_thread_id = message['message_thread_id']
      text = message['text'] || ''
      user = message['from']['username'] || message['from']['id']
      
      # Watch all topics - detect and store topic info
      if topic_thread_id
        topic_name = get_topic_name(chat_id, topic_thread_id)
        if topic_name
          store_topic_info(chat_id, topic_thread_id, topic_name)
        end
      end

      puts "▛▞ Message from #{user}: #{text}"

      # Parse command
      if text.start_with?('/')
        handle_command(chat_id, topic_thread_id, text, user)
      else
        handle_message(chat_id, topic_thread_id, text, user)
      end
    end

    # ═══════════════════════════════════════════════════════════════
    # Commands
    # ═══════════════════════════════════════════════════════════════

    def handle_command(chat_id, topic_thread_id, text, user)
      parts = text.split(' ', 2)
      command = parts[0].downcase.sub('/', '')
      args = parts[1] || ''

      case command
      when 'start'
        # Check if it's /start (welcome) or /start <station> (command)
        if args.empty?
          emit_reply(
            chat_id: chat_id,
            topic_thread_id: topic_thread_id,
            actor: "telegram:#{user}",
            text: "🖥️ *CMD.BRIDGE Widget*\n\n/status - Full dashboard\n/list - Stations/services\n/start <name> - Start\n/stop <name> - Stop\n/sirius - Time\n/ask <q> - Ask LLM\n/code <prompt> - Codex53"
          )
        else
          # Start a station/service
          result = `cd #{@cmd_root}/.3ox && ruby vec3/rc/3ox.rc start #{args} 2>&1`
          emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "▶️ *Starting #{args}*\n```\n#{result[0..1000]}\n```")
        end
      
      when 'sirius', 'time'
        sirius_time = calculate_sirius_time
        emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "⧗ `#{sirius_time}`")
      
      when 'chatid', 'chat_id'
        # Get topic name if in a forum topic
        topic_name = get_topic_name(chat_id, topic_thread_id) if topic_thread_id
        topic_info = if topic_name
          " (Topic: `#{topic_name}` / Thread: `#{topic_thread_id}`)"
        elsif topic_thread_id
          " (Thread: `#{topic_thread_id}`)"
        else
          ""
        end
        
        # Auto-assign topic to user/agent in topic.toml
        if topic_thread_id && topic_name
          auto_assign_topic_to_user(user, chat_id, topic_thread_id, topic_name)
        end
        
        emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "💬 *Chat ID*\n\nChat: `#{chat_id}`#{topic_info}\n\nUse this in your .3ox config to send messages to this chat.")
      
      when 'status'
        # Run status script and send widget
        status_output = `cd #{@cmd_root} && ruby status 2>&1`
        # Extract just the widget part (skip headers)
        lines = status_output.split("\n")
        widget_start = lines.index { |l| l.include?("RUNNING APPS") } || 0
        widget = lines[widget_start..-1].join("\n")[0..3000]
        emit_reply(
          chat_id: chat_id,
          topic_thread_id: topic_thread_id,
          actor: "telegram:#{user}",
          text: "🖥️ *CMD.BRIDGE STATUS*\n`#{calculate_sirius_time}`\n\n```\n#{widget}\n```"
        )
      
      when 'stop'
        if args.empty?
          emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "Usage: /stop <station|service>\nExample: /stop refactor.station")
        else
          result = `cd #{@cmd_root}/.3ox && ruby vec3/rc/3ox.rc stop #{args} 2>&1`
          emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "⏹️ *Stopping #{args}*\n```\n#{result[0..1000]}\n```")
        end
      
      when 'list'
        result = `cd #{@cmd_root}/.3ox && ruby vec3/rc/3ox.rc list 2>&1`
        emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "📋 *Stations & Services*\n```\n#{result[0..2000]}\n```")
      
      when 'ask'
        if args.empty?
          emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "Usage: /ask <your question>")
        else
          emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "⏳ Thinking...")
          receipt = run_job(
            chat_id: chat_id,
            topic_thread_id: topic_thread_id,
            actor: "telegram:#{user}",
            prompt: args,
            command: 'ask'
          )
          emit_receipt_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, receipt: receipt)
        end

      when 'code'
        if args.empty?
          emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "Usage: /code <prompt>\nRuns Codex53 agent.")
        else
          emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "⏳ Running Codex53...")
          receipt = run_job(
            chat_id: chat_id,
            topic_thread_id: topic_thread_id,
            actor: "telegram:#{user}",
            prompt: args,
            command: 'code'
          )
          emit_receipt_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, receipt: receipt)
        end
      
      when 'help'
        emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "🖥️ *CMD.BRIDGE Widget*\n\n/status - Full dashboard\n/list - Stations/services\n/start <name> - Start\n/stop <name> - Stop\n/sirius - Time\n/chatid - Chat ID\n/ask <q> - Ask LLM\n/code <prompt> - Codex53 agent")
      
      else
        emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "Unknown command: /#{command}\nTry /help")
      end
    end

    def handle_message(chat_id, topic_thread_id, text, user)
      emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: "telegram:#{user}", text: "⏳ Thinking...")
      receipt = run_job(
        chat_id: chat_id,
        topic_thread_id: topic_thread_id,
        actor: "telegram:#{user}",
        prompt: text
      )
      emit_receipt_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, receipt: receipt)
    end

    # ═══════════════════════════════════════════════════════════════
    # Sub-Agent Routing
    # ═══════════════════════════════════════════════════════════════

    def resolve_sub_agent(chat_id:, topic_thread_id:, command: nil)
      config = load_sub_agents_config
      default = config.dig('default', 'dispatch_agent') || 'think'

      # Command override (e.g. /code -> codex53)
      if command && config.dig('by_command', command)
        return config['by_command'][command].to_s.strip
      end

      # Topic override (forum topic name -> agent)
      if topic_thread_id
        topic_name = get_topic_name(chat_id, topic_thread_id)
        if topic_name && config.dig('by_topic', topic_name)
          return config['by_topic'][topic_name].to_s.strip
        end
      end

      default
    end

    def load_sub_agents_config
      config_paths = [
        File.expand_path('../../var/sub_agents.toml', __dir__),
        File.join(@cmd_root, '.3ox', '.vec3', 'var', 'sub_agents.toml'),
        File.join(@cmd_root, '.3ox', 'vec3', 'var', 'sub_agents.toml')
      ]
      config_paths.each do |path|
        next unless File.exist?(path)
        begin
          require 'toml-rb'
          return TomlRB.parse(File.read(path))
        rescue => e
          warn "⚠ Failed to parse sub_agents.toml: #{e.message}"
        end
      end
      {}
    end

    # ═══════════════════════════════════════════════════════════════
    # Job Execution (local-first)
    # ═══════════════════════════════════════════════════════════════

    def run_job(chat_id:, topic_thread_id:, actor:, prompt:, command: nil)
      agent = resolve_sub_agent(chat_id: chat_id, topic_thread_id: topic_thread_id, command: command)
      envelope = {
        op: 'agent.invoke',
        args: { agent: agent, prompt: prompt.to_s },
        permissions: ['net.http'],
        timeout_ms: 120_000,
        route_id: nil,
        manifest_hash: Vec3::Dispatch::Law.manifest[:manifest_hash],
        trace_id: "tg_#{Time.now.to_i}_#{rand(0xFFFF).to_s(16)}",
        base_id: @base_id,
        station_id: DEFAULT_STATION_ID,
        thread_id: topic_thread_id || chat_id,
        chat_id: chat_id,
        topic_thread_id: topic_thread_id,
        actor: actor
      }

      Vec3::Dispatch.process(envelope)
    rescue => e
      {
        kind: 'receipt',
        status: 'error',
        errors: [{ code: 'teleprompter_error', msg: e.message }],
        outputs: { summary: "Error: #{e.message}" },
        flags: ['!ALERT']
      }
    end

    def emit_receipt_reply(chat_id:, topic_thread_id:, receipt:)
      receipt = receipt.transform_keys(&:to_sym)
      outputs = receipt[:outputs] || {}
      summary = outputs[:summary] || outputs['summary'] || receipt[:status].to_s
      text = summary.to_s.strip
      text = "✓ Done" if text.empty?

      emit_reply(chat_id: chat_id, topic_thread_id: topic_thread_id, actor: 'dispatch', text: text, receipt: receipt)
    end

    def emit_reply(chat_id:, topic_thread_id:, actor:, text:, receipt: nil)
      event = build_outbox_event(
        chat_id: chat_id,
        topic_thread_id: topic_thread_id,
        actor: actor,
        text: text,
        receipt: receipt
      )
      write_outbox_event(event)
    end

    # ═══════════════════════════════════════════════════════════════
    # Outbox Publisher (Teleprompter publishes to Telegram)
    # ═══════════════════════════════════════════════════════════════

    def drain_outbox
      Dir.glob(File.join(@outbox_events_dir, '*.json')).sort.each do |path|
        begin
          payload = JSON.parse(File.read(path))
          next unless payload.is_a?(Hash)

          reply = payload['reply'] || {}
          next unless reply.is_a?(Hash)
          text = (reply['text'] || '').to_s
          next if text.strip.empty?

          chat_id = payload['chat_id']
          topic_thread_id = payload['topic_thread_id']

          send_message(chat_id, text, topic_thread_id: topic_thread_id)

          FileUtils.mv(path, File.join(@outbox_sent_dir, File.basename(path)))
        rescue => e
          # Never crash the loop; keep the file so it can be replayed.
          warn "⚠ outbox publish failed: #{File.basename(path)} (#{e.message})"
        end
      end
    end
    
    # Drain bus outbox - messages from agents/stations that signed on
    def drain_bus_outbox
      bus_outbox = File.join(@cmd_root, '.3ox', 'vec3', 'var', 'telegram_bus', 'outbox')
      return unless Dir.exist?(bus_outbox)
      
      Dir.glob(File.join(bus_outbox, '*.json')).sort.each do |path|
        begin
          message = JSON.parse(File.read(path))
          next unless message.is_a?(Hash)
          
          chat_id = message['chat_id']
          text = message['text'] || ''
          topic_thread_id = message['topic_thread_id']
          agent_id = message['agent_id']
          
          next if text.strip.empty?
          
          # Get agent info for prefix
          agent_info = get_bus_agent_info(agent_id)
          prefix = agent_info ? "#{agent_info['pico_glyph']} #{agent_info['agent_name']}: " : ""
          
          # Update tgsub.key heartbeat when agent sends message
          update_tgsub_key_heartbeat(agent_id) if agent_info
          
          # Determine topic: use message topic_thread_id, or agent's default, or "Initializing" for first message
          target_topic = topic_thread_id
          unless target_topic
            # Load agent's topic config
            topic_config = load_topic_config(agent_id)
            target_topic = topic_config[:default_topic]
            
            # Check if this is first message (one-time fire to "Initializing")
            key_file = File.join(@cmd_root, '.3ox', 'keys', "#{agent_id}.tgsub.key")
            if File.exist?(key_file)
              begin
                key_data = JSON.parse(File.read(key_file))
                unless key_data['initialized']
                  target_topic = 'Initializing'
                  key_data['initialized'] = true
                  File.write(key_file, JSON.pretty_generate(key_data))
                end
              rescue
                # If key read fails, use default
              end
            end
          end
          
          # Send message with agent prefix
          send_message(chat_id, "#{prefix}#{text}", topic_thread_id: target_topic)
          
          # Move to sent
          sent_dir = File.join(bus_outbox, 'sent')
          FileUtils.mkdir_p(sent_dir)
          FileUtils.mv(path, File.join(sent_dir, File.basename(path)))
        rescue => e
          warn "⚠ bus outbox publish failed: #{File.basename(path)} (#{e.message})"
        end
      end
    end
    
    def get_bus_agent_info(agent_id)
      bus_reg = File.join(@cmd_root, '.3ox', 'vec3', 'var', 'telegram_bus', 'registrations.json')
      return nil unless File.exist?(bus_reg)
      
      registrations = JSON.parse(File.read(bus_reg)) rescue {}
      registrations[agent_id]
    end
    
    # Create tgsub.key for agent (Teleprompter grants access)
    def create_tgsub_key(agent_id, agent_info)
      keys_dir = File.join(@cmd_root, '.3ox', 'keys')
      FileUtils.mkdir_p(keys_dir)
      
      key_file = File.join(keys_dir, "#{agent_id}.tgsub.key")
      
      # Load topic config to get chat_id and default topic
      topic_config = load_topic_config(agent_id)
      
      key_data = {
        agent_id: agent_id,
        agent_name: agent_info['agent_name'] || agent_id,
        agent_type: agent_info['agent_type'] || 'agent',
        pico_glyph: agent_info['pico_glyph'] || '⚙️',
        chat_id: topic_config[:chat_id] || agent_info['chat_id'],
        default_topic: topic_config[:default_topic],
        subscribed_topics: topic_config[:subscribed_topics] || [],
        issued_at: Time.now.utc.iso8601,
        status: 'active',
        last_seen: Time.now.utc.iso8601,
        initialized: false
      }
      
      File.write(key_file, JSON.pretty_generate(key_data))
      key_file
    end
    
    # Revoke tgsub.key (Teleprompter removes access)
    def revoke_tgsub_key(agent_id)
      keys_dir = File.join(@cmd_root, '.3ox', 'keys')
      key_file = File.join(keys_dir, "#{agent_id}.tgsub.key")
      
      if File.exist?(key_file)
        File.delete(key_file)
        true
      else
        false
      end
    end
    
    # Update tgsub.key heartbeat (Teleprompter refreshes connection)
    def update_tgsub_key_heartbeat(agent_id)
      keys_dir = File.join(@cmd_root, '.3ox', 'keys')
      key_file = File.join(keys_dir, "#{agent_id}.tgsub.key")
      
      return false unless File.exist?(key_file)
      
      begin
        key_data = JSON.parse(File.read(key_file))
        key_data['last_seen'] = Time.now.utc.iso8601
        key_data['status'] = 'active'
        File.write(key_file, JSON.pretty_generate(key_data))
        true
      rescue
        false
      end
    end
    
    # Sync tgsub.keys with bus registrations (create keys for new agents, revoke for inactive)
    def sync_tgsub_keys
      bus_reg = File.join(@cmd_root, '.3ox', 'vec3', 'var', 'telegram_bus', 'registrations.json')
      return unless File.exist?(bus_reg)
      
      registrations = JSON.parse(File.read(bus_reg)) rescue {}
      keys_dir = File.join(@cmd_root, '.3ox', 'keys')
      FileUtils.mkdir_p(keys_dir)
      
      # Create/update keys for active registrations
      registrations.each do |agent_id, agent_info|
        next unless agent_info['status'] == 'active'
        
        key_file = File.join(keys_dir, "#{agent_id}.tgsub.key")
        was_new = !File.exist?(key_file)
        
        if File.exist?(key_file)
          # Update heartbeat if key exists
          update_tgsub_key_heartbeat(agent_id)
        else
          # Create new key for newly registered agent
          create_tgsub_key(agent_id, agent_info)
          
          # Send welcome message to Initializing topic (one-time fire)
          send_welcome_to_initializing(agent_id, agent_info)
        end
      end
      
      # Revoke keys for agents not in registrations (cleanup)
      Dir.glob(File.join(keys_dir, '*.tgsub.key')).each do |key_file|
        agent_id = File.basename(key_file, '.tgsub.key')
        unless registrations[agent_id] && registrations[agent_id]['status'] == 'active'
          # Agent no longer registered, revoke key
          revoke_tgsub_key(agent_id)
        end
      end
    end

    def build_outbox_event(chat_id:, topic_thread_id:, actor:, text:, receipt: nil)
      ts = (Time.now.to_f * 1000).to_i
      job_id = receipt&.dig(:envelope_id) || receipt&.dig('envelope_id') || "job_#{ts}"
      trace_id = receipt&.dig(:run_id) || receipt&.dig('run_id') || "trace_#{ts}"

      {
        event_type: 'job.result',
        job_id: job_id,
        trace_id: trace_id,
        base_id: @base_id,
        station_id: DEFAULT_STATION_ID,
        thread_id: topic_thread_id || chat_id,
        chat_id: chat_id,
        topic_thread_id: topic_thread_id,
        status: receipt ? (receipt[:status] || receipt['status'] || 'ok') : 'ok',
        reply: { text: text.to_s, attachments: [] },
        artifacts: [],
        memory_patch: { pins_add: {}, pins_remove: [], summary: nil, recent_append: [] },
        suggested_next: { station_id: nil, job_type: nil, requires_confirmation: false },
        receipts: receipt ? { receipt_id: receipt[:receipt_id] || receipt['receipt_id'], worker_id: actor.to_s } : { worker_id: actor.to_s },
        ts: ts
      }
    end

    def write_outbox_event(event)
      ts = Time.now.utc.strftime('%Y%m%dT%H%M%S')
      job_id = (event[:job_id] || event['job_id'] || 'job').to_s.gsub(/[^a-zA-Z0-9_\-]/, '_')
      path = File.join(@outbox_events_dir, "#{ts}_#{job_id}.json")
      File.write(path, JSON.pretty_generate(event))
      path
    end

    def safe_tape_stats
      require_relative '../rc/tape/tape'
      Vec3::TAPE.stats
    rescue
      { total: 0, ok: 0, blocked: 0, error: 0, last_receipt: nil }
    end

    # ═══════════════════════════════════════════════════════════════
    # Telegram API
    # ═══════════════════════════════════════════════════════════════

    def api_call(method, params = {})
      uri = URI("#{TELEGRAM_API}#{@token}/#{method}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 60

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = JSON.generate(params)

      response = http.request(request)
      JSON.parse(response.body)
    rescue => e
      { 'ok' => false, 'description' => e.message }
    end

    def send_message(chat_id, text, topic_thread_id: nil)
      # Truncate if too long
      text = text[0..4000] + '...' if text.length > 4000
      
      params = { chat_id: chat_id, text: text, parse_mode: 'Markdown' }
      params[:message_thread_id] = topic_thread_id if topic_thread_id
      api_call('sendMessage', params)
    rescue => e
      # Retry without markdown
      params = { chat_id: chat_id, text: text }
      params[:message_thread_id] = topic_thread_id if topic_thread_id
      api_call('sendMessage', params)
    end

    # ═══════════════════════════════════════════════════════════════
    # Utilities
    # ═══════════════════════════════════════════════════════════════

    def calculate_sirius_time
      reset_date = Time.new(2025, 8, 8)
      now = Time.now
      days_since = ((now - reset_date) / 86400).floor
      year = 25 + (days_since / 365)
      day_of_year = days_since % 365
      "⧗-#{year}.#{day_of_year.to_s.rjust(3, '0')}"
    end
    
    # Get forum topic name from Telegram API
    def get_topic_name(chat_id, topic_thread_id)
      return nil unless topic_thread_id
      
      # Try to get forum topic info
      result = api_call('getForumTopic', chat_id: chat_id, message_thread_id: topic_thread_id)
      if result['ok'] && result['result']
        result['result']['name']
      else
        # Fallback: check stored topic info
        get_stored_topic_name(chat_id, topic_thread_id)
      end
    rescue
      get_stored_topic_name(chat_id, topic_thread_id)
    end
    
    # Store topic info for later lookup
    def store_topic_info(chat_id, topic_thread_id, topic_name)
      topics_file = File.join(@cmd_root, '.3ox', 'vec3', 'var', 'telegram_topics.json')
      topics = File.exist?(topics_file) ? JSON.parse(File.read(topics_file)) : {}
      
      key = "#{chat_id}_#{topic_thread_id}"
      topics[key] = {
        chat_id: chat_id,
        topic_thread_id: topic_thread_id,
        topic_name: topic_name,
        last_seen: Time.now.utc.iso8601
      }
      
      FileUtils.mkdir_p(File.dirname(topics_file))
      File.write(topics_file, JSON.pretty_generate(topics))
    end
    
    # Get stored topic name
    def get_stored_topic_name(chat_id, topic_thread_id)
      topics_file = File.join(@cmd_root, '.3ox', 'vec3', 'var', 'telegram_topics.json')
      return nil unless File.exist?(topics_file)
      
      topics = JSON.parse(File.read(topics_file)) rescue {}
      key = "#{chat_id}_#{topic_thread_id}"
      topics.dig(key, 'topic_name')
    end
    
    # Auto-assign topic to user in topic.toml
    def auto_assign_topic_to_user(user, chat_id, topic_thread_id, topic_name)
      topic_config_path = File.join(@cmd_root, '.3ox', 'vec3', 'var', 'topic.toml')
      return unless File.exist?(topic_config_path)
      
      begin
        require 'toml-rb'
        config = TomlRB.parse(File.read(topic_config_path))
        
        # Create agent entry if doesn't exist
        config['agents'] ||= {}
        agent_key = user.to_s.gsub(/[^a-zA-Z0-9_]/, '_')
        config['agents'][agent_key] ||= {}
        
        # Update chat_id and add topic to subscribed_topics
        config['agents'][agent_key]['chat_id'] = chat_id
        config['agents'][agent_key]['subscribed_topics'] ||= []
        unless config['agents'][agent_key]['subscribed_topics'].include?(topic_name)
          config['agents'][agent_key]['subscribed_topics'] << topic_name
        end
        
        # If this is "Initializing" topic, set as default for first-time
        if topic_name == 'Initializing' && !config['agents'][agent_key]['default_topic']
          config['agents'][agent_key]['default_topic'] = 'Initializing'
        end
        
        # Write back to TOML (simple format preservation)
        write_topic_toml(config, topic_config_path)
        
        puts "✓ Auto-assigned topic '#{topic_name}' to agent #{agent_key}"
      rescue => e
        warn "⚠ Failed to auto-assign topic: #{e.message}"
      end
    end
    
    # Write TOML config (simple implementation)
    def write_topic_toml(config, path)
      lines = []
      
      # Write telegram section
      if config['telegram']
        lines << "[telegram]"
        lines << "chat_id = #{config['telegram']['chat_id'] || 0}"
        lines << %Q(default_topic = "#{config['telegram']['default_topic'] || 'general'}")
        if config['telegram']['subscribed_topics']
          topics = config['telegram']['subscribed_topics'].map { |t| %Q("#{t}") }.join(', ')
          lines << "subscribed_topics = [#{topics}]"
        end
        lines << ""
      end
      
      # Write agent sections
      if config['agents']
        config['agents'].each do |agent_id, agent_config|
          lines << "[agents.#{agent_id}]"
          lines << "chat_id = #{agent_config['chat_id'] || 0}"
          if agent_config['default_topic']
            lines << %Q(default_topic = "#{agent_config['default_topic']}")
          end
          if agent_config['subscribed_topics'] && !agent_config['subscribed_topics'].empty?
            topics = agent_config['subscribed_topics'].map { |t| %Q("#{t}") }.join(', ')
            lines << "subscribed_topics = [#{topics}]"
          end
          lines << ""
        end
      end
      
      File.write(path, lines.join("\n"))
    end
    
    # Send welcome message to Initializing topic (one-time fire)
    def send_welcome_to_initializing(agent_id, agent_info)
      topic_config = load_topic_config(agent_id)
      chat_id = topic_config[:chat_id]
      
      return unless chat_id && chat_id != 0
      
      # Find Initializing topic thread_id
      initializing_topic_id = find_topic_thread_id(chat_id, 'Initializing')
      return unless initializing_topic_id
      
      welcome_text = "🎯 *Agent Online*\n\n" \
                    "Agent: `#{agent_id}`\n" \
                    "Name: #{agent_info['agent_name']}\n" \
                    "Status: Active\n\n" \
                    "Teleprompter connection established."
      
      send_message(chat_id, welcome_text, topic_thread_id: initializing_topic_id)
    rescue => e
      warn "⚠ Failed to send welcome to Initializing: #{e.message}"
    end
    
    # Find topic thread_id by name
    def find_topic_thread_id(chat_id, topic_name)
      topics_file = File.join(@cmd_root, '.3ox', 'vec3', 'var', 'telegram_topics.json')
      return nil unless File.exist?(topics_file)
      
      topics = JSON.parse(File.read(topics_file)) rescue {}
      topics.each do |key, info|
        if info['chat_id'] == chat_id && info['topic_name'] == topic_name
          return info['topic_thread_id']
        end
      end
      nil
    end
    
    # Load topic configuration (topic.toml or topic.yml)
    def load_topic_config(agent_id)
      config_dir = File.join(@cmd_root, '.3ox', 'vec3', 'var')
      
      # Try TOML first (better for Rust/Elixir)
      toml_file = File.join(config_dir, 'topic.toml')
      if File.exist?(toml_file)
        begin
          require 'toml-rb'
          config = TomlRB.parse(File.read(toml_file))
          agent_config = config.dig('agents', agent_id) || config['default'] || {}
          return {
            chat_id: agent_config['chat_id'] || config.dig('telegram', 'chat_id'),
            default_topic: agent_config['default_topic'] || config.dig('telegram', 'default_topic'),
            subscribed_topics: agent_config['subscribed_topics'] || config.dig('telegram', 'subscribed_topics') || []
          }
        rescue => e
          warn "⚠ Failed to parse topic.toml: #{e.message}"
        end
      end
      
      # Fallback to YAML
      yml_file = File.join(config_dir, 'topic.yml')
      if File.exist?(yml_file)
        begin
          require 'yaml'
          config = YAML.safe_load(File.read(yml_file))
          agent_config = config.dig('agents', agent_id) || config['default'] || {}
          return {
            chat_id: agent_config['chat_id'] || config.dig('telegram', 'chat_id'),
            default_topic: agent_config['default_topic'] || config.dig('telegram', 'default_topic'),
            subscribed_topics: agent_config['subscribed_topics'] || config.dig('telegram', 'subscribed_topics') || []
          }
        rescue => e
          warn "⚠ Failed to parse topic.yml: #{e.message}"
        end
      end
      
      # Default fallback
      { chat_id: nil, default_topic: nil, subscribed_topics: [] }
    end
  end
end

# ═══════════════════════════════════════════════════════════════
# CLI
# ═══════════════════════════════════════════════════════════════

if __FILE__ == $PROGRAM_NAME
  case ARGV[0]
  when 'start'
    bot = Vec3::Teleprompter.new
    
    # Handle Ctrl+C gracefully
    trap('INT') { bot.stop }
    trap('TERM') { bot.stop }
    
    bot.start
  when 'test'
    bot = Vec3::Teleprompter.new
    me = bot.api_call('getMe')
    puts JSON.pretty_generate(me)
  when 'reset'
    puts "▛▞ Resetting Teleprompter state..."
    
    # Clear bus registrations
    bus_reg = File.join(File.expand_path('../../..', __dir__), '.3ox', 'vec3', 'var', 'telegram_bus', 'registrations.json')
    if File.exist?(bus_reg)
      File.delete(bus_reg)
      puts "✓ Cleared bus registrations"
    end
    
    # Clear tgsub.keys
    keys_dir = File.join(File.expand_path('../../..', __dir__), '.3ox', 'keys')
    if Dir.exist?(keys_dir)
      tgsub_keys = Dir.glob(File.join(keys_dir, '*.tgsub.key'))
      tgsub_keys.each do |key_file|
        File.delete(key_file)
        puts "✓ Removed #{File.basename(key_file)}"
      end
    end
    
    # Clear outbox
    bus_outbox = File.join(File.expand_path('../../..', __dir__), '.3ox', 'vec3', 'var', 'telegram_bus', 'outbox')
    if Dir.exist?(bus_outbox)
      Dir.glob(File.join(bus_outbox, '*.json')).each { |f| File.delete(f) }
      puts "✓ Cleared bus outbox"
    end
    
    puts "✓ Reset complete - Teleprompter state cleared"
    puts "  Agents will need to re-register when Teleprompter starts"
  else
    puts <<~USAGE
      ▛▞ 3OX Teleprompter (Telegram Substrate)

      Usage:
        telegram.rb start     # Start Teleprompter
        telegram.rb test      # Test connection
        telegram.rb reset     # Reset state (clear registrations & keys)

      Environment:
        TELEGRAM_BOT_TOKEN    # Your bot token from @BotFather
        TELEGRAM_CHAT_ID      # Optional: default chat for non-thread events (not required for replies)
        BASE_ID               # Optional: default base id (default: CMD.BRIDGE)
        ANTHROPIC_API_KEY     # For LLM responses (when using /ask)
    USAGE
  end
end

# Back-compat: historical name
module Vec3
  TelegramBot = Teleprompter
end
# :: ∎