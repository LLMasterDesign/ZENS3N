#!/usr/bin/env ruby
#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
#▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 ▸ ρ{runtime.flow}.φ{orchestrate}.τ{session}.λ{bind} ⫸ :: RUNTIME.RB

require 'yaml'
require 'json'
require 'digest'
require 'time'
require 'pathname'
require 'fileutils'

begin
  require 'tiktoken_ruby'
  TIKTOKEN_AVAILABLE = true
rescue LoadError
  TIKTOKEN_AVAILABLE = false
  # Fallback mode: Use character-based estimation
  puts "⚠️  tiktoken_ruby not installed - using estimated token counts"
  puts "   For accurate counting: gem install tiktoken_ruby"
end

# ============================================================================
# Workspace Detection
# ============================================================================

module Workspace
  KEYWORDS = {
    'obsidian' => 'OBSIDIAN.BASE',
    'synth' => 'SYNTH.BASE',
    'rvnx' => 'RVNx.BASE',
    'cmd.bridge' => 'CMD.BRIDGE'
  }.freeze

  def self.detect
    env_workspace = ENV['WORKSPACE_ID']
    return env_workspace.strip unless env_workspace.to_s.strip.empty?

    station = ENV['STATION_ID']
    return station.split('/').first unless station.to_s.strip.empty?

    current = Pathname.new(Dir.pwd).cleanpath.to_s.downcase
    KEYWORDS.each do |keyword, workspace|
      return workspace if current.include?(keyword)
    end

    'RVNx.BASE'
  end

  def self.station
    ENV['STATION_ID'] || detect
  end

  def self.routes
    base = {
      critical_error: 'CMD.BRIDGE',
      deploy_ready: 'SYNTH.BASE',
      knowledge_update: 'OBSIDIAN.BASE/LIGHTHOUSE',
      sync_request: 'RVNx.BASE',
      library_update: 'OBSIDIAN.BASE',
      emergency: 'CMD.BRIDGE/EMERGENCY'
    }

    overrides = case detect
                when 'SYNTH.BASE'
                  { deploy_ready: 'SYNTH.BASE/DEPLOY', sync_request: 'SYNTH.BASE/SYNC' }
                when 'OBSIDIAN.BASE'
                  { knowledge_update: 'OBSIDIAN.BASE/LIGHTHOUSE', library_update: 'OBSIDIAN.BASE/ARCHIVE' }
                else
                  {}
                end

    base.merge(overrides)
  end
end

# ============================================================================
# Session Management
# ============================================================================

module Session
  @context = []
  @session_id = nil
  @created_at = nil
  @model = 'claude-sonnet-4'
  @encoder = nil
  @workspace = Workspace.detect
  
  def self.init(session_id, model = 'claude-sonnet-4')
    @session_id = session_id
    @created_at = sirius_time
    @context = []
    @model = model
    @workspace = Workspace.detect
    
    # Initialize tiktoken encoder (if available)
    if TIKTOKEN_AVAILABLE
      begin
        # Use o200k_base encoding for modern models (GPT-4o, Claude Sonnet 4)
        @encoder = Tiktoken.encoding_for_model("gpt-4o")
      rescue => e
        puts "⚠️  Tiktoken initialization failed: #{e.message}"
        @encoder = nil
      end
    else
      @encoder = nil
    end
  end
  
  def self.add(role, message)
    entry = {
      role: role,
      content: message,
      timestamp: sirius_time,
      tokens: count_tokens(message)
    }
    @context << entry
    
    # Log context size
    check_context_limits
  end
  
  def self.count_tokens(text)
    if @encoder
      # Use tiktoken for accurate counting
      begin
        return @encoder.encode(text).length
      rescue => e
        puts "⚠️  Token counting failed: #{e.message}"
        # Fall through to estimation
      end
    end
    
    # Fallback: Character-based estimation
    # Rule of thumb: ~4 characters per token for English text
    # This is what most LLMs would assume
    estimate_tokens(text)
  end
  
  def self.estimate_tokens(text)
    # Industry standard estimation:
    # - Average English: 4 chars per token
    # - Adjust for whitespace and punctuation
    char_count = text.length
    word_count = text.split.length
    
    # Refined estimation: avg 0.75 tokens per word, min 1 token per 6 chars
    [(char_count / 4.0).ceil, (word_count * 0.75).ceil, 1].max
  end
  
  def self.get_context
    @context
  end

  def self.workspace
    @workspace
  end
  
  def self.get_token_stats
    total_tokens = @context.sum { |entry| entry[:tokens] || 0 }
    {
      total_tokens: total_tokens,
      message_count: @context.length,
      model: @model,
      max_tokens: get_max_tokens,
      utilization: (total_tokens.to_f / get_max_tokens * 100).round(2),
      counting_method: @encoder ? 'tiktoken' : 'estimated',
      workspace: @workspace
    }
  end
  
  def self.get_max_tokens
    case @model
    when 'claude-sonnet-4', 'claude-3-5-sonnet', 'gpt-4o'
      200_000
    when 'gpt-4'
      8_000
    when 'gpt-3.5-turbo'
      4_000
    else
      8_000
    end
  end
  
  def self.check_context_limits
    stats = get_token_stats
    if stats[:utilization] > 80
      warning_msg = "Context at #{stats[:utilization]}% (#{stats[:total_tokens]}/#{stats[:max_tokens]} tokens)"
      puts "⚠️  #{warning_msg}"
      Trace.token_warning(warning_msg, stats)
    end
    
    # Log token usage every 10 messages
    if @context.length % 10 == 0
      Trace.token_usage(stats)
    end
  end
  
  def self.clear
    @context = []
  end
  
  def self.save
    stats = get_token_stats
    File.write('.3ox/session.yaml', {
      session_id: @session_id,
      created: @created_at,
      last_active: sirius_time,
      workspace: @workspace,
      model: @model,
      token_stats: stats,
      context: @context
    }.to_yaml)
  end
  
  def self.load(session_id)
    return unless File.exist?('.3ox/session.yaml')
    
    data = YAML.load_file('.3ox/session.yaml')
    @session_id = data[:session_id]
    @created_at = data[:created]
    @context = data[:context] || []
    @workspace = data[:workspace] || Workspace.detect
  end
  
  private
  
  def self.sirius_time
    reset = Time.new(2025, 8, 8)
    now = Time.now
    days = ((now - reset) / 86400).to_i
    year = now.year % 100
    "⧗-#{year}.#{days}"
  end
end

# ============================================================================
# Receipt System
# ============================================================================

module Receipt
  def self.generate(resource, stage)
    hash, kind = digest_for(resource)

    receipt = {
      resource: resource,
      kind: kind,
      stage: stage,
      hash: hash,
      timestamp: sirius_time,
      station: Workspace.station
    }

    log_receipt(receipt)
    receipt
  end

  def self.validate(resource, expected_hash)
    current_hash, _kind = digest_for(resource)
    current_hash == expected_hash
  end

  def self.log_receipt(receipt)
    FileUtils.mkdir_p('.3ox')
    File.open('.3ox/receipts.log', 'a') do |f|
      f.puts "[#{receipt[:timestamp]}] #{receipt[:stage]} | #{receipt[:resource]} | #{receipt[:hash]} (#{receipt[:kind]})"
    end
  end

  def self.digest_for(resource)
    if File.exist?(resource.to_s)
      [Digest::SHA256.file(resource).hexdigest, :file]
    else
      [Digest::SHA256.hexdigest(resource.to_s), :payload]
    end
  end

  private

  def self.sirius_time
    reset = Time.new(2025, 8, 8)
    now = Time.now
    days = ((now - reset) / 86400).to_i
    year = now.year % 100
    "⧗-#{year}.#{days}"
  end
end

# ============================================================================
# Manifest Management
# ============================================================================

module Manifest
  SCHEMA = {
    '$schema' => 'https://json-schema.org/draft/2020-12/schema',
    'title' => '0ut.3ox Manifest',
    'type' => 'array',
    'items' => {
      'type' => 'object',
      'required' => %w[timestamp status filename destination priority hash trigger workspace],
      'properties' => {
        'timestamp' => { 'type' => 'string' },
        'status' => { 'type' => 'string' },
        'filename' => { 'type' => 'string' },
        'destination' => { 'type' => 'string' },
        'priority' => { 'type' => 'string' },
        'hash' => { 'type' => 'string', 'pattern' => '^[a-f0-9]{64}$' },
        'trigger' => { 'type' => 'string' },
        'workspace' => { 'type' => 'string' }
      }
    }
  }.freeze

  SCHEMA_PATH = '.3ox/manifest.schema.json'.freeze
  OUTPUT_PATH = '0ut.3ox/FILE.MANIFEST.json'.freeze

  def self.append(entry)
    ensure_schema
    validate!(entry)
    FileUtils.mkdir_p('0ut.3ox')
    write_schema_copy

    manifest = if File.exist?(OUTPUT_PATH)
                 JSON.parse(File.read(OUTPUT_PATH))
               else
                 []
               end

    manifest << entry
    File.write(OUTPUT_PATH, JSON.pretty_generate(manifest))
  end

  def self.ensure_schema
    FileUtils.mkdir_p('.3ox')
    return if File.exist?(SCHEMA_PATH)

    File.write(SCHEMA_PATH, JSON.pretty_generate(SCHEMA))
  end

  def self.write_schema_copy
    path = File.join('0ut.3ox', 'manifest.schema.json')
    return if File.exist?(path)

    File.write(path, JSON.pretty_generate(SCHEMA))
  end

  def self.validate!(entry)
    missing = SCHEMA.dig('items', 'required').reject { |key| entry.key?(key) }
    raise ArgumentError, "Manifest entry missing: #{missing.join(', ')}" unless missing.empty?

    unless entry['hash'].is_a?(String) && entry['hash'].match?(/\A[a-f0-9]{64}\z/)
      raise ArgumentError, 'Manifest entry hash must be 64-char hex string'
    end
  end
end

# ============================================================================
# Routing & Handoffs
# ============================================================================

module Router
  def self.routes
    Workspace.routes
  end
  
  def self.handoff(trigger, payload = {})
    destination = routes[trigger]
    raise "Unknown routing trigger: #{trigger}" unless destination
    
    # Create handoff package
    package = {
      from: Workspace.station,
      to: destination,
      trigger: trigger,
      payload: payload,
      timestamp: sirius_time,
      workspace: Workspace.detect,
      receipt: Receipt.generate(payload.to_json, 'HANDOFF')
    }
    
    # Ship to 0ut.3ox/
    ship_package(package)
    
    # Log handoff
    log_handoff(package)
    
    package
  end
  
  def self.ship_package(package)
    output_dir = '0ut.3ox'
    FileUtils.mkdir_p(output_dir)
    
    filename = "#{output_dir}/handoff_#{package[:trigger]}_#{Time.now.to_i}.yaml"
    File.write(filename, package.to_yaml)
    
    add_to_manifest(filename, package)
  end
  
  def self.add_to_manifest(file, package)
    entry = {
      'timestamp' => package[:timestamp],
      'status' => 'READY',
      'filename' => File.basename(file),
      'destination' => package[:to],
      'priority' => 'HIGH',
      'hash' => package[:receipt][:hash],
      'trigger' => package[:trigger].to_s,
      'workspace' => package[:workspace]
    }

    Manifest.append(entry)
  end
  
  def self.log_handoff(package)
    FileUtils.mkdir_p('.3ox')
    File.open('.3ox/trace.log', 'a') do |f|
      f.puts "[#{package[:timestamp]}] HANDOFF | #{package[:trigger]} | TO: #{package[:to]} | WORKSPACE: #{package[:workspace]}"
    end
  end
  
  private
  
  def self.sirius_time
    reset = Time.new(2025, 8, 8)
    now = Time.now
    days = ((now - reset) / 86400).to_i
    year = now.year % 100
    "⧗-#{year}.#{days}"
  end
end

# ============================================================================
# Trace Logger
# ============================================================================

module Trace
  def self.log(event, data = {})
    File.open('.3ox/trace.log', 'a') do |f|
      f.puts "[#{sirius_time}] #{event} | #{data.inspect}"
    end
  end
  
  def self.agent_start(agent_name, session_id)
    log('AGENT_START', { agent: agent_name, session: session_id })
  end
  
  def self.agent_end(status, duration = nil, token_stats = nil)
    data = { status: status, duration: duration }
    data[:tokens] = token_stats if token_stats
    log('AGENT_END', data)
  end
  
  def self.tool_call(tool_name, input)
    log('TOOL_CALL', { tool: tool_name, input: input })
  end
  
  def self.tool_result(result)
    log('TOOL_RESULT', { result: result })
  end
  
  def self.token_usage(stats)
    log('TOKEN_USAGE', {
      total: stats[:total_tokens],
      messages: stats[:message_count],
      model: stats[:model],
      utilization: "#{stats[:utilization]}%"
    })
  end
  
  def self.token_warning(message, stats)
    log('TOKEN_WARNING', {
      warning: message,
      current: stats[:total_tokens],
      max: stats[:max_tokens],
      utilization: "#{stats[:utilization]}%"
    })
  end
  
  private
  
  def self.sirius_time
    reset = Time.new(2025, 8, 8)
    now = Time.now
    days = ((now - reset) / 86400).to_i
    year = now.year % 100
    "⧗-#{year}.#{days}.#{now.strftime('%H:%M')}"
  end
end

# ============================================================================
# Example Usage
# ============================================================================

if __FILE__ == $0
  # Initialize session with token counting
  Session.init('example_001', 'claude-sonnet-4')
  Trace.agent_start('SENTINEL', 'example_001')
  
  # Add context (with automatic token counting)
  Session.add(:user, 'Sync this file to the cloud storage')
  Session.add(:agent, 'Validating file integrity and checking for conflicts...')
  Session.add(:user, 'Also generate a receipt for this operation')
  Session.add(:agent, 'Receipt generated. Hash: a1b2c3d4...')
  
  # Display token stats
  stats = Session.get_token_stats
  puts "\n📊 Token Stats:"
  puts "   Total: #{stats[:total_tokens]} tokens"
  puts "   Messages: #{stats[:message_count]}"
  puts "   Model: #{stats[:model]}"
  puts "   Utilization: #{stats[:utilization]}%"
  
  # Generate receipt
  receipt = Receipt.generate(__FILE__, :intake)
  puts "\n🧾 Receipt: #{receipt[:hash][0..15]}..."
  
  # Route handoff
  Router.handoff(:sync_request, { file: __FILE__ })
  
  # Save session (includes token stats)
  Session.save
  Trace.agent_end(:success, '2.3s')
  
  puts "\n✅ Runtime test complete! Check .3ox/ for logs."
  puts "   - session.yaml (with token stats)"
  puts "   - receipts.log"
  puts "   - trace.log"
end

#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ v1.1.0 | ⧗-25.61 ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂#///

