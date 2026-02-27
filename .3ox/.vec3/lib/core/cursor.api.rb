# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x110C]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // CURSOR.API.RB ▞▞
# ▛▞// CURSOR.API.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [cursorapi] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.cursor.api.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for CURSOR.API.RB
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
SEAL = ':: ∎'
#/command2 = description2
#/command1 = description1
#(Add toolset commands here)
#▛//▞ TOOLSET ::
#
#```
##///          (Add third line of purpose here)
##///          (Add second line of purpose here)
##/// Purpose: !/usr/bin/env ruby
##/// Last Updated: 2026.01.05 | Trace.ID: cursor.api.v1.0
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.05
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [cursor_api] [system] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // CURSOR.API ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# CURSOR.API.RB :: Cursor Cloud Agent API Client for CMD.BRIDGE
# Provides programmatic access to Cursor's Cloud Agent API
#

require 'net/http'
require 'json'
require 'uri'
require_relative '../ops/lib/helpers.rb'

module CursorAPI
  include Helpers
  extend self

  def get_vec3_root
    # Hardcoded path to avoid symlink resolution issues
    '/root/!CMD.BRIDGE/.3ox'
  end

  def log_operation(component, level, message, data = {})
    Helpers.log_operation(component, level, message, data)
  end

  API_BASE = "https://api.cursor.com/v0"
  
  # ============================================================================
  # API KEY MANAGEMENT
  # ============================================================================
  
  def load_api_key
    """Load Cursor API key from secrets file or environment"""
    secrets_file = File.join(get_vec3_root, 'rc', 'secrets', 'api.keys')
    return nil unless File.exist?(secrets_file)
    
    File.readlines(secrets_file).each do |line|
      line = line.strip
      # Skip comments and empty lines
      next if line.empty? || line.start_with?('#')
      
      if line =~ /^CURSOR_API_KEY=(.+)$/
        key = $1.strip
        # Remove quotes if present
        key = key.gsub(/^["']|["']$/, '')
        return key unless key.empty?
      end
    end
    
    # Fallback to environment variable
    ENV['CURSOR_API_KEY']
  end

  def api_key_configured?
    """Check if API key is configured"""
    !load_api_key.nil?
  end

  # ============================================================================
  # CHAT COMPLETIONS API
  # ============================================================================
  
  def launch_agent(prompt, options = {})
    """Launch a Cursor Cloud Agent with a prompt"""
    api_key = load_api_key
    unless api_key
      log_operation('cursor_api', 'ERROR', 'CURSOR_API_KEY not found in secrets')
      raise "CURSOR_API_KEY not configured. Add it to .3ox/vec3/rc/secrets/api.keys"
    end
    
    uri = URI("#{API_BASE}/agents")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120  # Longer timeout for AI requests
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'
    
    # Cursor API expects prompt as an object with text field
    payload = {
      prompt: {
        text: prompt
      }
    }
    
    # Add model if specified (optional - Cursor selects if omitted)
    payload[:model] = options[:model] if options[:model]
    
    request.body = payload.to_json
    
    log_operation('cursor_api', 'INFO', "Launching Cursor Agent with prompt: #{prompt[0..50]}...")
    
    begin
      response = http.request(request)
      
      if response.code == '200' || response.code == '201'
        result = JSON.parse(response.body)
        log_operation('cursor_api', 'COMPLETE', "Cursor Agent launched successfully")
        result
      else
        error_body = response.body rescue "No error details"
        log_operation('cursor_api', 'ERROR', "Cursor API error: #{response.code} - #{error_body[0..200]}")
        raise "Cursor API error: #{response.code} - #{error_body[0..200]}"
      end
    rescue => e
      log_operation('cursor_api', 'ERROR', "Cursor API exception: #{e.message}")
      raise
    end
  end
  
  # Legacy chat_completion for compatibility
  def chat_completion(messages, options = {})
    """Legacy method - extracts prompt and launches agent"""
    user_message = messages.find { |m| m[:role] == 'user' || m['role'] == 'user' }
    prompt = user_message ? (user_message[:content] || user_message['content']) : messages.last[:content]
    launch_agent(prompt, options)
  end

  # ============================================================================
  # AGENT COMPLETION (HIGH-LEVEL)
  # ============================================================================
  
  def agent_completion(prompt, workspace_context = nil, options = {})
    """High-level method to launch Cursor Agent"""
    # Build full prompt with workspace context
    full_prompt = prompt
    if workspace_context
      full_prompt = "Workspace Context:\n#{workspace_context}\n\nUser Request:\n#{prompt}"
    end
    
    result = launch_agent(full_prompt, options)
    
    # Cursor Agent API returns agent info, not direct content
    # The agent runs asynchronously, so we get agent_id and status
    agent_id = result.dig('id') || result.dig('agent_id')
    
    unless agent_id
      log_operation('cursor_api', 'ERROR', 'No agent ID in Cursor API response')
      raise "No agent ID returned from Cursor API"
    end
    
    # Return agent info (actual results come via webhook or polling)
    result
  end

  # ============================================================================
  # CONVERSATION COMPLETION (WITH HISTORY)
  # ============================================================================
  
  def conversation_completion(prompt, conversation_history = [], workspace_context = nil, options = {})
    """Get completion with conversation history"""
    messages = []
    
    # Add system message
    system_content = "You are a helpful AI assistant operating within the CMD.BRIDGE framework."
    if workspace_context
      system_content += "\n\nWorkspace Context:\n#{workspace_context}"
    end
    
    messages << {
      role: 'system',
      content: system_content
    }
    
    # Add conversation history
    conversation_history.each do |msg|
      messages << {
        role: msg['role'] || msg[:role],
        content: msg['content'] || msg[:content]
      }
    end
    
    # Add current prompt
    messages << {
      role: 'user',
      content: prompt
    }
    
    result = chat_completion(messages, options)
    result.dig('choices', 0, 'message', 'content')
  end

  # ============================================================================
  # HEALTH CHECK
  # ============================================================================
  
  def health_check
    """Check if Cursor API is accessible"""
    return { available: false, reason: 'API key not configured' } unless api_key_configured?
    
    begin
      # Check API key info endpoint
      api_key = load_api_key
      uri = URI("#{API_BASE}/me")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'
      
      response = http.request(request)
      
      if response.code == '200'
        api_info = JSON.parse(response.body) rescue {}
        { available: true, api_info: api_info }
      else
        { available: false, reason: "HTTP #{response.code}" }
      end
    rescue => e
      { available: false, reason: e.message }
    end
  end
end

# ============================================================================
# COMMAND LINE INTERFACE
# ============================================================================

if __FILE__ == $0
  require 'optparse'
  
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: cursor.api.rb [command] [options]"
    
    opts.on("-p", "--prompt TEXT", "Prompt text") do |p|
      options[:prompt] = p
    end
    
    opts.on("-m", "--model NAME", "Model name (default: gpt-4)") do |m|
      options[:model] = m
    end
    
    opts.on("-t", "--temperature NUM", Float, "Temperature (default: 0.7)") do |t|
      options[:temperature] = t
    end
    
    opts.on("--health", "Check API health") do
      health = CursorAPI.health_check
      puts JSON.pretty_generate(health)
      exit health[:available] ? 0 : 1
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!
  
  command = ARGV[0] || 'help'
  
  case command
  when 'test'
    unless options[:prompt]
      puts "ERROR: --prompt required"
      exit 1
    end
    
    begin
      response = CursorAPI.agent_completion(
        options[:prompt],
        nil,
        {
          model: options[:model],
          temperature: options[:temperature]
        }
      )
      puts response
      exit 0
    rescue => e
      puts "ERROR: #{e.message}"
      exit 1
    end
    
  when 'health'
    health = CursorAPI.health_check
    puts JSON.pretty_generate(health)
    exit health[:available] ? 0 : 1
    
  else
    puts "Commands: test, health"
    puts "Run with -h for help"
  end
end
# :: ∎