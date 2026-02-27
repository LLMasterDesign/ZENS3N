#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'net/http'
require 'time'
require 'uri'

class TelePromptRBridge
  TELEGRAM_API = 'https://api.telegram.org/bot'

  def initialize
    @repo_root = File.expand_path('..', __dir__)
    @token = ENV['TELEGRAM_BOT_TOKEN'].to_s.strip

    @cmd_root = ENV['TPR_CMD_ROOT'].to_s.strip
    @cmd_root = '/root/!ZENS3N.CMD/.3ox' if @cmd_root.empty?

    @keys_dir = ENV['TPR_KEYS_DIR'].to_s.strip
    @keys_dir = File.join(@repo_root, '_forge', 'runtime', 'keys') if @keys_dir.empty?

    @bus_outbox_dir = ENV['TPR_BUS_OUTBOX_DIR'].to_s.strip
    @bus_outbox_dir = File.join(@cmd_root, '.vec3', 'var', 'telegram_bus', 'outbox') if @bus_outbox_dir.empty?

    @bus_reg_path = ENV['TPR_BUS_REG_PATH'].to_s.strip
    @bus_reg_path = File.join(@cmd_root, '.vec3', 'var', 'telegram_bus', 'registrations.json') if @bus_reg_path.empty?

    @route_map_path = ENV['TPR_ROUTE_MAP_PATH'].to_s.strip
    @route_map_path = File.join(@repo_root, 'CyberDeck', 'TPR.ROUTE.MAP.json') if @route_map_path.empty?

    @route_audit_path = ENV['TPR_ROUTE_AUDIT_PATH'].to_s.strip
    @route_audit_path = File.join(@repo_root, '_forge', 'runtime', 'route_audit.jsonl') if @route_audit_path.empty?

    @topics_file = ENV['TPR_TOPICS_PATH'].to_s.strip
    @topics_file = File.join(@cmd_root, '.vec3', 'var', 'telegram_topics.json') if @topics_file.empty?

    @poll_interval_s = ENV.fetch('TPR_POLL_INTERVAL_S', '0.5').to_f
    @poll_interval_s = 0.5 if @poll_interval_s <= 0

    FileUtils.mkdir_p(@bus_outbox_dir)
    FileUtils.mkdir_p(File.join(@bus_outbox_dir, 'sent'))
    FileUtils.mkdir_p(File.join(@bus_outbox_dir, 'denied'))
    FileUtils.mkdir_p(@keys_dir)
    FileUtils.mkdir_p(File.dirname(@route_audit_path))
  end

  def start
    puts "[tpr] bridge start mode=#{@token.empty? ? 'dry-run' : 'telegram'}"
    puts "[tpr] outbox=#{@bus_outbox_dir}"
    puts "[tpr] route_map=#{@route_map_path}"

    running = true
    trap('INT') { running = false }
    trap('TERM') { running = false }

    while running
      drained = drain_once
      sleep(@poll_interval_s) if drained.zero?
    end
  end

  def status
    outbox_count = count_json(@bus_outbox_dir)
    sent_count = count_json(File.join(@bus_outbox_dir, 'sent'))
    denied_count = count_json(File.join(@bus_outbox_dir, 'denied'))

    puts "mode=#{@token.empty? ? 'dry-run' : 'telegram'}"
    puts "outbox_dir=#{@bus_outbox_dir}"
    puts "route_map=#{@route_map_path}"
    puts "audit=#{@route_audit_path}"
    puts "keys_dir=#{@keys_dir}"
    puts "queue_outbox=#{outbox_count}"
    puts "queue_sent=#{sent_count}"
    puts "queue_denied=#{denied_count}"
  end

  def drain_once
    processed = 0
    files = Dir.glob(File.join(@bus_outbox_dir, '*.json')).sort

    files.each do |path|
      begin
        envelope = JSON.parse(File.read(path))
        unless envelope.is_a?(Hash)
          move_to(path, 'denied')
          next
        end

        agent_id = envelope['agent_id'].to_s.strip
        text = envelope['text'].to_s

        if agent_id.empty? || text.strip.empty?
          append_route_audit(outcome: 'denied', agent_id: agent_id, envelope: envelope, route: { reason: 'invalid_envelope' }, note: 'missing agent_id/text')
          move_to(path, 'denied')
          next
        end

        route = resolve_agent_route(
          agent_id: agent_id,
          envelope_chat_id: envelope['chat_id'],
          envelope_topic_thread_id: envelope['topic_thread_id']
        )

        unless route[:allowed]
          append_route_audit(outcome: 'denied', agent_id: agent_id, envelope: envelope, route: route, note: route[:reason])
          move_to(path, 'denied')
          processed += 1
          next
        end

        agent_info = load_registrations[agent_id] || {}
        prefix = if agent_info['agent_name']
                   "#{agent_info['pico_glyph'] || 'AI'} #{agent_info['agent_name']}: "
                 else
                   ''
                 end

        response = send_message(route[:chat_id], "#{prefix}#{text}", topic_thread_id: route[:topic_thread_id])

        append_route_audit(
          outcome: 'published',
          agent_id: agent_id,
          envelope: envelope,
          route: route.merge(api_ok: response['ok'], api_desc: response['description'], dry_run: response['dry_run'])
        )

        move_to(path, 'sent')
        processed += 1
      rescue StandardError => e
        append_route_audit(
          outcome: 'denied',
          agent_id: 'unknown',
          envelope: { 'path' => path },
          route: { reason: 'exception', error: e.message },
          note: 'drain_once_exception'
        )
        move_to(path, 'denied')
      end
    end

    processed
  end

  def resolve_agent_route(agent_id:, envelope_chat_id:, envelope_topic_thread_id:)
    route_entry = route_entry_for(agent_id)
    key_data = load_key(agent_id)

    chat_id = normalize_chat_id(envelope_chat_id || route_entry['chat_id'] || key_data['chat_id'])
    return { allowed: false, reason: 'missing_chat_id' } if chat_id.nil?

    topic_candidate = envelope_topic_thread_id
    if topic_candidate.nil? || topic_candidate.to_s.strip.empty?
      topic_candidate = route_entry['default_topic'] || key_data['default_topic']
      topic_candidate = apply_first_message_topic(agent_id, key_data, topic_candidate)
    end

    allowed_chat_ids = Array(route_entry['allowed_chat_ids']) + Array(key_data['allowed_chat_ids'])
    if allowed_chat_ids.empty?
      seed = normalize_chat_id(route_entry['chat_id'] || key_data['chat_id'])
      allowed_chat_ids << seed unless seed.nil?
    end
    allowed_chat_ids = allowed_chat_ids.map { |v| normalize_chat_id(v) }.compact.uniq

    if !allowed_chat_ids.empty? && !allowed_chat_ids.include?(chat_id)
      return { allowed: false, reason: 'chat_id_not_allowed', chat_id: chat_id }
    end

    resolved_topic = resolve_topic(chat_id, topic_candidate)
    return { allowed: false, reason: resolved_topic[:reason], chat_id: chat_id, topic_thread_id: topic_candidate } if resolved_topic[:invalid]

    allowed_topics = Array(route_entry['allowed_topics']) + Array(key_data['subscribed_topics'])
    allowed_topics = allowed_topics.map { |v| v.to_s.strip }.reject(&:empty?).uniq

    if !allowed_topics.empty?
      tokens = [topic_candidate, resolved_topic[:topic_thread_id], resolved_topic[:topic_name]].compact.map(&:to_s).map(&:strip).reject(&:empty?).uniq
      if tokens.any? && (tokens & allowed_topics).empty?
        return { allowed: false, reason: 'topic_not_allowed', chat_id: chat_id, topic_thread_id: resolved_topic[:topic_thread_id] }
      end
    end

    {
      allowed: true,
      reason: 'ok',
      chat_id: chat_id,
      topic_thread_id: resolved_topic[:topic_thread_id],
      topic_name: resolved_topic[:topic_name]
    }
  end

  def send_message(chat_id, text, topic_thread_id: nil)
    text = text[0..4000] + '...' if text.length > 4000

    if @token.empty?
      return { 'ok' => true, 'dry_run' => true, 'description' => 'dry-run (TELEGRAM_BOT_TOKEN unset)' }
    end

    params = { chat_id: chat_id, text: text, parse_mode: 'Markdown' }
    params[:message_thread_id] = topic_thread_id if topic_thread_id
    api_call('sendMessage', params)
  rescue StandardError => e
    { 'ok' => false, 'description' => e.message }
  end

  def api_call(method, params = {})
    uri = URI("#{TELEGRAM_API}#{@token}/#{method}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60

    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req.body = JSON.generate(params)

    res = http.request(req)
    JSON.parse(res.body)
  rescue StandardError => e
    { 'ok' => false, 'description' => e.message }
  end

  def route_entry_for(agent_id)
    map = load_route_map
    default_entry = map['default']
    default_entry = {} unless default_entry.is_a?(Hash)
    agent_entry = map.dig('agents', agent_id)
    agent_entry = {} unless agent_entry.is_a?(Hash)
    default_entry.merge(agent_entry)
  end

  def load_route_map
    return {} unless File.exist?(@route_map_path)

    payload = JSON.parse(File.read(@route_map_path))
    payload.is_a?(Hash) ? payload : {}
  rescue StandardError
    {}
  end

  def load_registrations
    return {} unless File.exist?(@bus_reg_path)

    payload = JSON.parse(File.read(@bus_reg_path))
    payload.is_a?(Hash) ? payload : {}
  rescue StandardError
    {}
  end

  def load_key(agent_id)
    path = File.join(@keys_dir, "#{agent_id}.tgsub.key")
    return {} unless File.exist?(path)

    payload = JSON.parse(File.read(path))
    payload.is_a?(Hash) ? payload : {}
  rescue StandardError
    {}
  end

  def write_key(agent_id, payload)
    FileUtils.mkdir_p(@keys_dir)
    path = File.join(@keys_dir, "#{agent_id}.tgsub.key")
    File.write(path, JSON.pretty_generate(payload))
    path
  rescue StandardError
    nil
  end

  def apply_first_message_topic(agent_id, key_data, fallback_topic)
    return fallback_topic unless key_data.is_a?(Hash)
    return fallback_topic if key_data.empty?
    return fallback_topic if key_data['initialized']

    key_data['initialized'] = true
    key_data['last_seen'] = Time.now.utc.iso8601
    write_key(agent_id, key_data)
    'Initializing'
  end

  def normalize_chat_id(chat_id)
    return nil if chat_id.nil?

    raw = chat_id.to_s.strip
    return nil if raw.empty?
    return raw.to_i if raw.match?(/\A-?\d+\z/)

    raw
  end

  def resolve_topic(chat_id, candidate)
    return { topic_thread_id: nil, topic_name: nil, invalid: false } if candidate.nil?

    raw = candidate.to_s.strip
    return { topic_thread_id: nil, topic_name: nil, invalid: false } if raw.empty?
    return { topic_thread_id: raw.to_i, topic_name: nil, invalid: false } if raw.match?(/\A-?\d+\z/)

    topic_id = find_topic_thread_id(chat_id, raw)
    if topic_id.nil?
      { topic_thread_id: nil, topic_name: raw, invalid: true, reason: 'topic_name_unresolved' }
    else
      { topic_thread_id: topic_id, topic_name: raw, invalid: false }
    end
  end

  def find_topic_thread_id(chat_id, topic_name)
    return nil unless File.exist?(@topics_file)

    payload = JSON.parse(File.read(@topics_file))
    return nil unless payload.is_a?(Hash)

    payload.each_value do |info|
      next unless info.is_a?(Hash)
      next unless info['chat_id'].to_s == chat_id.to_s
      next unless info['topic_name'].to_s == topic_name.to_s

      id = info['topic_thread_id']
      return id.to_i if id.to_s.match?(/\A-?\d+\z/)
      return id
    end
    nil
  rescue StandardError
    nil
  end

  def append_route_audit(outcome:, agent_id:, envelope:, route:, note: nil)
    record = {
      ts: Time.now.utc.iso8601,
      outcome: outcome,
      agent_id: agent_id,
      reason: route[:reason] || route['reason'],
      note: note,
      envelope: {
        message_id: envelope['message_id'],
        chat_id: envelope['chat_id'],
        topic_thread_id: envelope['topic_thread_id']
      },
      resolved: {
        chat_id: route[:chat_id] || route['chat_id'],
        topic_thread_id: route[:topic_thread_id] || route['topic_thread_id'],
        topic_name: route[:topic_name] || route['topic_name'],
        api_ok: route[:api_ok] || route['api_ok'],
        api_desc: route[:api_desc] || route['api_desc'],
        dry_run: route[:dry_run] || route['dry_run']
      }
    }

    File.open(@route_audit_path, 'a') { |f| f.puts(JSON.generate(record)) }
  rescue StandardError => e
    warn "[tpr] route audit write failed: #{e.message}"
  end

  def move_to(path, bucket)
    dir = File.join(@bus_outbox_dir, bucket)
    FileUtils.mkdir_p(dir)
    FileUtils.mv(path, File.join(dir, File.basename(path)))
  rescue StandardError => e
    warn "[tpr] move failed #{path} -> #{bucket}: #{e.message}"
  end

  def count_json(dir)
    return 0 unless Dir.exist?(dir)
    Dir.glob(File.join(dir, '*.json')).size
  end
end

if $PROGRAM_NAME == __FILE__
  bridge = TelePromptRBridge.new
  cmd = ARGV[0] || 'start'

  case cmd
  when 'start'
    bridge.start
  when 'drain-once'
    count = bridge.drain_once
    puts "drained=#{count}"
  when 'status'
    bridge.status
  else
    warn "unknown command: #{cmd}"
    warn 'usage: ruby tools/telepromptr_bridge.rb [start|drain-once|status]'
    exit(2)
  end
end
