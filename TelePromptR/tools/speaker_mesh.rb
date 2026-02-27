#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'net/http'
require 'securerandom'
require 'time'
require 'uri'

$stdout.sync = true

class SpeakerMesh
  DEFAULT_POLL_INTERVAL_S = 0.5
  DEFAULT_MEMORY_WINDOW = 28
  DEFAULT_MAX_REPLY_CHARS = 1200
  DEFAULT_API_TIMEOUT_S = 60
  DEFAULT_TEMPERATURE = 0.45
  DEFAULT_MODEL = 'openai/gpt-4.1-mini'

  def initialize
    @repo_root = File.expand_path('..', __dir__)
    @var_dir = env('TPR_VAR_DIR', File.join(@repo_root, 'runtime', 'vps', '3ox.station', 'vec3', 'var'))
    @inbox_dir = env('TPR_INBOX_DIR', File.join(@var_dir, 'inbox'))
    @outbox_dir = env('TPR_OUTBOX_DIR', File.join(@var_dir, 'outbox'))
    @inbox_processed_dir = env('TPR_INBOX_PROCESSED_DIR', File.join(@inbox_dir, 'processed'))
    @inbox_failed_dir = env('TPR_INBOX_FAILED_DIR', File.join(@inbox_dir, 'failed'))
    @agents_path = env('TPR_AGENTS_PATH', File.join(@var_dir, 'agents.json'))
    @config_path = env('TPR_MESH_CONFIG_PATH', File.join(@repo_root, 'CyberDeck', 'TPR.SPEAKER.MESH.json'))
    @state_dir = env('TPR_MESH_STATE_DIR', File.join(@repo_root, '_forge', 'runtime', 'mesh'))
    @memory_dir = File.join(@state_dir, 'memory')

    @poll_interval_s = float_env('TPR_MESH_POLL_INTERVAL_S', DEFAULT_POLL_INTERVAL_S)
    @memory_window = int_env('TPR_MESH_MEMORY_WINDOW', DEFAULT_MEMORY_WINDOW)
    @max_reply_chars = int_env('TPR_MESH_MAX_REPLY_CHARS', DEFAULT_MAX_REPLY_CHARS)
    @api_timeout_s = int_env('TPR_MESH_API_TIMEOUT_S', DEFAULT_API_TIMEOUT_S)
    @temperature = float_env('TPR_MESH_TEMPERATURE', DEFAULT_TEMPERATURE)
    @default_model = env('TPR_MESH_MODEL', DEFAULT_MODEL)
    @dry_run = truthy?(ENV['TPR_MESH_DRY_RUN'])

    @api_key = first_nonempty(ENV['TPR_MESH_API_KEY'], ENV['OPENROUTER_API_KEY'], ENV['OPENAI_API_KEY'])
    @api_base = env('TPR_MESH_API_BASE', default_api_base)

    FileUtils.mkdir_p(@inbox_dir)
    FileUtils.mkdir_p(@outbox_dir)
    FileUtils.mkdir_p(@inbox_processed_dir)
    FileUtils.mkdir_p(@inbox_failed_dir)
    FileUtils.mkdir_p(@memory_dir)
  end

  def start
    log("mesh start mode=#{llm_enabled? ? 'llm' : 'fallback'} api_base=#{@api_base}")

    running = true
    trap('INT') { running = false }
    trap('TERM') { running = false }

    while running
      processed = drain_once
      sleep(@poll_interval_s) if processed.zero?
    end

    log('mesh stop')
  end

  def status
    puts "mesh_mode=#{llm_enabled? ? 'llm' : 'fallback'}"
    puts "dry_run=#{@dry_run}"
    puts "inbox_dir=#{@inbox_dir}"
    puts "outbox_dir=#{@outbox_dir}"
    puts "agents_path=#{@agents_path}"
    puts "mesh_config=#{@config_path}"
    puts "memory_dir=#{@memory_dir}"
    puts "pending_inbox=#{pending_inbox_count}"
  end

  def drain_once
    processed = 0
    files = Dir.glob(File.join(@inbox_dir, '*.json')).sort
    files.each do |path|
      process_file(path)
      processed += 1
    rescue StandardError => e
      log("process failed file=#{File.basename(path)} err=#{e.class}: #{e.message}", 'error')
      safe_move(path, @inbox_failed_dir)
    end
    processed
  end

  private

  def process_file(path)
    envelope = JSON.parse(File.read(path))
    unless envelope.is_a?(Hash)
      safe_move(path, @inbox_failed_dir)
      return
    end

    meta = envelope['meta']
    meta = {} unless meta.is_a?(Hash)

    agent_id = resolve_agent_id(path, envelope)
    text = envelope['text'].to_s.strip
    chat_id = envelope['from_chat_id'] || envelope['chat_id']
    thread_id = envelope['from_thread_id'] || envelope['thread_id']

    if agent_id.empty? || text.empty? || chat_id.nil?
      log("drop invalid envelope file=#{File.basename(path)}")
      safe_move(path, @inbox_failed_dir)
      return
    end

    profile = merged_profile(agent_id)
    unless profile['enabled']
      log("agent disabled agent=#{agent_id}")
      safe_move(path, @inbox_processed_dir)
      return
    end

    user_name = extract_user_name(envelope)

    append_memory(agent_id, role: 'user', content: text, chat_id: chat_id, thread_id: thread_id, user: user_name)

    listen_only_meta = truthy?(meta['listen_only']) || truthy?(meta['listen']) || truthy?(meta['ingest_only'])
    force_reply = truthy?(meta['force_reply']) || truthy?(meta['force']) || truthy?(meta['reply'])
    listen_only_profile = truthy?(profile['listen_only'])

    if (listen_only_profile || listen_only_meta) && !force_reply
      log("listen-only agent=#{agent_id} chat_id=#{chat_id} thread_id=#{thread_id || 'none'}")
      safe_move(path, @inbox_processed_dir)
      return
    end

    reply = compose_reply(agent_id: agent_id, text: text, profile: profile, chat_id: chat_id, thread_id: thread_id, user_name: user_name)
    reply = truncate(reply, profile.fetch('max_reply_chars', @max_reply_chars))

    append_memory(agent_id, role: 'assistant', content: reply, chat_id: chat_id, thread_id: thread_id, user: 'speaker_mesh')

    write_outbox(
      agent_id: agent_id,
      glyph: profile['glyph'],
      chat_id: chat_id,
      thread_id: thread_id,
      text: reply
    )

    safe_move(path, @inbox_processed_dir)
  end

  def compose_reply(agent_id:, text:, profile:, chat_id:, thread_id:, user_name:)
    return fallback_reply(agent_id: agent_id, text: text, profile: profile, user_name: user_name) unless llm_enabled?

    messages = build_messages(
      agent_id: agent_id,
      text: text,
      profile: profile,
      chat_id: chat_id,
      thread_id: thread_id,
      user_name: user_name
    )

    model = profile['model'] || @default_model
    response = call_openai_compatible(messages: messages, model: model, temperature: profile['temperature'])
    reply = extract_llm_text(response)
    return fallback_reply(agent_id: agent_id, text: text, profile: profile, user_name: user_name) if reply.empty?

    reply
  rescue StandardError => e
    log("llm error agent=#{agent_id} err=#{e.class}: #{e.message}", 'warn')
    fallback_reply(agent_id: agent_id, text: text, profile: profile, user_name: user_name)
  end

  def build_messages(agent_id:, text:, profile:, chat_id:, thread_id:, user_name:)
    system_prompt = profile['system_prompt'].to_s
    if system_prompt.empty?
      system_prompt = <<~PROMPT.strip
        You are #{agent_id}, an autonomous speaker in a Telegram supergroup homebase.
        Work with other agents. Keep responses practical and concise.
        If uncertain, ask one concrete follow-up question.
        Avoid roleplay fluff. Prefer actionable next steps.
      PROMPT
    end

    messages = [{ 'role' => 'system', 'content' => system_prompt }]

    # Memory is stored per agent, but we scope context to the current chat/thread
    # to prevent cross-talk when multiple topics are routed into one persona.
    scoped = recent_memory(agent_id, @memory_window * 10)
    scoped = scoped.select { |entry| same_context?(entry, chat_id, thread_id) }.last(@memory_window)
    scoped.each do |entry|
      role = entry['role'].to_s
      content = entry['content'].to_s
      next unless %w[user assistant].include?(role)
      next if content.strip.empty?

      messages << { 'role' => role, 'content' => content }
    end

    user_context = "user=#{user_name} chat_id=#{chat_id} thread_id=#{thread_id || 'none'}"
    messages << { 'role' => 'user', 'content' => "[#{user_context}] #{text}" }
    messages
  end

  def call_openai_compatible(messages:, model:, temperature:)
    uri = URI("#{@api_base}/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.open_timeout = @api_timeout_s
    http.read_timeout = @api_timeout_s

    req = Net::HTTP::Post.new(uri.request_uri)
    req['Authorization'] = "Bearer #{@api_key}"
    req['Content-Type'] = 'application/json'
    req['HTTP-Referer'] = ENV['TPR_MESH_HTTP_REFERER'] if ENV['TPR_MESH_HTTP_REFERER'] && !ENV['TPR_MESH_HTTP_REFERER'].empty?
    req['X-Title'] = ENV['TPR_MESH_X_TITLE'] if ENV['TPR_MESH_X_TITLE'] && !ENV['TPR_MESH_X_TITLE'].empty?
    req.body = JSON.generate(
      model: model,
      temperature: temperature || @temperature,
      messages: messages
    )

    res = http.request(req)
    raise "llm_http_#{res.code}" unless res.code.to_i.between?(200, 299)

    JSON.parse(res.body)
  end

  def extract_llm_text(payload)
    msg = payload.dig('choices', 0, 'message', 'content')
    return msg.strip if msg.is_a?(String)

    if msg.is_a?(Array)
      joined = msg.map do |part|
        next part if part.is_a?(String)
        next part['text'] if part.is_a?(Hash) && part['text'].is_a?(String)

        nil
      end.compact.join("\n")
      return joined.strip unless joined.strip.empty?
    end

    ''
  rescue StandardError
    ''
  end

  def fallback_reply(agent_id:, text:, profile:, user_name:)
    persona = profile['persona'].to_s.strip
    persona = 'operator' if persona.empty?
    prefix = profile['glyph'].to_s
    prefix = 'AI' if prefix.empty?

    if text.include?('?')
      question = "What is the single constraint I should optimize first?"
      return "#{prefix} #{agent_id} (#{persona}): I can run in low-power mode without a dedicated key. I heard: \"#{truncate(text, 220)}\". #{question}"
    end

    "#{prefix} #{agent_id} (#{persona}): Received from #{user_name}. Next step: assign one owner, one deadline, and one output for \"#{truncate(text, 220)}\"."
  end

  def write_outbox(agent_id:, glyph:, chat_id:, thread_id:, text:)
    payload = {
      'tpr' => {
        'src' => agent_id,
        'dst' => 'homebase',
        'sev' => 'INFO',
        'glyph' => glyph.to_s.empty? ? 'AI' : glyph,
        'pico' => 'mesh',
        'dir' => '>',
        'msg' => text
      },
      'route' => {
        'chat_id' => chat_id,
        'thread_id' => thread_id,
        'parse_mode' => nil
      },
      'meta' => {
        'mesh' => true,
        'generated_at' => Time.now.utc.iso8601
      }
    }

    ts = Time.now.utc.strftime('%Y%m%dT%H%M%S%L')
    safe_agent = sanitize_file_token(agent_id)
    name = "#{ts}_mesh_#{safe_agent}_#{SecureRandom.hex(4)}.json"
    final = File.join(@outbox_dir, name)
    temp = "#{final}.tmp"
    File.write(temp, JSON.pretty_generate(payload))
    FileUtils.mv(temp, final)
  end

  def merged_profile(agent_id)
    cfg = mesh_config
    defaults = hash_or_empty(cfg['default'])
    llm = hash_or_empty(cfg['llm'])
    agents = hash_or_empty(cfg['agents'])
    agent_cfg = hash_or_empty(agents[agent_id])
    agent_reg = hash_or_empty(agent_registry[agent_id])

    enabled = if agent_cfg.key?('enabled')
                truthy?(agent_cfg['enabled'])
              elsif defaults.key?('enabled')
                truthy?(defaults['enabled'])
              else
                true
              end

    {
      'enabled' => enabled,
      'persona' => first_nonempty(agent_cfg['persona'], defaults['persona'], 'operator'),
      'glyph' => first_nonempty(agent_cfg['glyph'], agent_reg['glyph'], defaults['glyph'], 'AI'),
      'system_prompt' => first_nonempty(agent_cfg['system_prompt'], defaults['system_prompt']),
      'model' => first_nonempty(agent_cfg['model'], llm['model'], @default_model),
      'temperature' => float_or_default(agent_cfg['temperature'], llm['temperature'], @temperature),
      'max_reply_chars' => int_or_default(agent_cfg['max_reply_chars'], defaults['max_reply_chars'], @max_reply_chars),
      'listen_only' => resolve_listen_only(agent_cfg, defaults, agent_reg)
    }
  end

  def resolve_listen_only(agent_cfg, defaults, agent_reg)
    if agent_cfg.key?('listen_only')
      truthy?(agent_cfg['listen_only'])
    elsif defaults.key?('listen_only')
      truthy?(defaults['listen_only'])
    elsif agent_reg.key?('listen_only')
      truthy?(agent_reg['listen_only'])
    else
      false
    end
  end

  def same_context?(entry, chat_id, thread_id)
    entry['chat_id'].to_s == chat_id.to_s && entry['thread_id'].to_s == thread_id.to_s
  end

  def agent_registry
    @agent_registry ||= begin
      if File.exist?(@agents_path)
        payload = JSON.parse(File.read(@agents_path))
        payload.is_a?(Hash) ? payload : {}
      else
        {}
      end
    rescue StandardError
      {}
    end
  end

  def mesh_config
    @mesh_config ||= begin
      if File.exist?(@config_path)
        payload = JSON.parse(File.read(@config_path))
        payload.is_a?(Hash) ? payload : {}
      else
        {}
      end
    rescue StandardError
      {}
    end
  end

  def append_memory(agent_id, role:, content:, chat_id:, thread_id:, user:)
    path = memory_path(agent_id)
    entry = {
      'ts' => Time.now.utc.iso8601,
      'role' => role,
      'content' => content,
      'chat_id' => chat_id,
      'thread_id' => thread_id,
      'user' => user
    }
    File.open(path, 'a') { |f| f.puts(JSON.generate(entry)) }
    compact_memory(path)
  rescue StandardError => e
    log("memory append failed agent=#{agent_id} err=#{e.class}: #{e.message}", 'warn')
  end

  def recent_memory(agent_id, limit)
    path = memory_path(agent_id)
    return [] unless File.exist?(path)

    File.readlines(path).last(limit).map do |line|
      JSON.parse(line)
    rescue StandardError
      nil
    end.compact
  rescue StandardError
    []
  end

  def compact_memory(path)
    retain = [@memory_window * 4, 80].max
    lines = File.readlines(path)
    return if lines.length <= retain

    File.write(path, lines.last(retain).join)
  end

  def memory_path(agent_id)
    File.join(@memory_dir, "#{sanitize_file_token(agent_id)}.jsonl")
  end

  def resolve_agent_id(path, envelope)
    raw = envelope['routed_to'].to_s.strip
    return raw unless raw.empty?

    base = File.basename(path, '.json')
    return '' unless base.include?('_msg_')

    base.split('_msg_', 2).first
  end

  def extract_user_name(envelope)
    from = envelope['from_user']
    return 'unknown' unless from.is_a?(Hash)

    first_nonempty(from['username'], from['first_name'], from['id'], 'unknown')
  end

  def safe_move(src, dir)
    return unless File.exist?(src)

    FileUtils.mkdir_p(dir)
    base = File.basename(src)
    target = File.join(dir, base)
    if File.exist?(target)
      stamp = Time.now.utc.strftime('%Y%m%dT%H%M%S%L')
      target = File.join(dir, "#{stamp}_#{base}")
    end
    FileUtils.mv(src, target)
    target
  end

  def pending_inbox_count
    Dir.glob(File.join(@inbox_dir, '*.json')).length
  end

  def llm_enabled?
    !@dry_run && !@api_key.to_s.strip.empty?
  end

  def default_api_base
    return 'https://openrouter.ai/api/v1' if ENV['OPENROUTER_API_KEY'] && !ENV['OPENROUTER_API_KEY'].strip.empty?

    'https://api.openai.com/v1'
  end

  def sanitize_file_token(input)
    input.to_s.gsub(/[^a-zA-Z0-9._-]+/, '_')
  end

  def truncate(text, max_chars)
    raw = text.to_s
    return raw if raw.length <= max_chars

    "#{raw[0, max_chars]}..."
  end

  def hash_or_empty(obj)
    obj.is_a?(Hash) ? obj : {}
  end

  def float_or_default(primary, fallback, default)
    candidate = primary.nil? ? fallback : primary
    return default if candidate.nil?

    Float(candidate)
  rescue StandardError
    default
  end

  def int_or_default(primary, fallback, default)
    candidate = primary.nil? ? fallback : primary
    return default if candidate.nil?

    Integer(candidate)
  rescue StandardError
    default
  end

  def env(key, default = nil)
    value = ENV[key]
    return default if value.nil? || value.strip.empty?

    value
  end

  def first_nonempty(*values)
    values.each do |value|
      next if value.nil?
      text = value.to_s.strip
      return text unless text.empty?
    end
    ''
  end

  def int_env(key, default)
    value = ENV[key]
    return default if value.nil? || value.strip.empty?

    Integer(value)
  rescue StandardError
    default
  end

  def float_env(key, default)
    value = ENV[key]
    return default if value.nil? || value.strip.empty?

    Float(value)
  rescue StandardError
    default
  end

  def truthy?(value)
    %w[1 true yes y on].include?(value.to_s.strip.downcase)
  end

  def log(message, level = 'info')
    stamp = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
    puts "[mesh][#{level}][#{stamp}] #{message}"
  end
end

def usage
  warn <<~USAGE
    Usage: ruby tools/speaker_mesh.rb [start|status|drain-once]
  USAGE
end

if $PROGRAM_NAME == __FILE__
  mesh = SpeakerMesh.new
  cmd = ARGV[0] || 'start'

  case cmd
  when 'start'
    mesh.start
  when 'status'
    mesh.status
  when 'drain-once'
    count = mesh.drain_once
    puts "processed=#{count}"
  else
    usage
    exit 2
  end
end
