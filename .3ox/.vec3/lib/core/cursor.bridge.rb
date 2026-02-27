# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x8203]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // CURSOR.BRIDGE.RB ▞▞
# ▛▞// CURSOR.BRIDGE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [cursorbridge] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.cursor.bridge.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for CURSOR.BRIDGE.RB
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
##/// Last Updated: 2026.01.05 | Trace.ID: cursor.bridge.v1.0
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.05
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🌉] ≔ [cursor_bridge] [system] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // CURSOR.BRIDGE ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# CURSOR.BRIDGE.RB :: Ruby-to-Elixir Bridge for Cursor Cloud Agent API
# Bridges Ruby code to Elixir-based Cursor API client for external signals
#

require 'json'
require 'open3'
require_relative '../ops/lib/helpers.rb'

module CursorBridge
  include Helpers
  extend self

  CURSOR_ELIXIR_SCRIPT = File.join(File.dirname(__FILE__), 'runners', 'cursor.api.exs')
  
  # ============================================================================
  # ELIXIR EXECUTION (for external signals)
  # ============================================================================
  
  def call_elixir_function(function_name, args = {})
    """Call Elixir function and return JSON result"""
    unless File.exist?(CURSOR_ELIXIR_SCRIPT)
      log_operation('cursor_bridge', 'ERROR', "Elixir script not found: #{CURSOR_ELIXIR_SCRIPT}")
      return nil
    end
    
    # Build Elixir command with proper JSON encoding
    elixir_code = build_elixir_call(function_name, args)
    
    begin
      # Execute Elixir script
      # Use mix run or elixir -r depending on dependencies
      script_dir = File.dirname(CURSOR_ELIXIR_SCRIPT)
      
      stdout, stderr, status = Open3.capture3(
        {
          'CURSOR_API_KEY' => ENV['CURSOR_API_KEY'] || load_api_key_from_secrets
        },
        'elixir', '-r', CURSOR_ELIXIR_SCRIPT, '-e', elixir_code,
        chdir: script_dir
      )
      
      if status.success? && !stdout.strip.empty?
        parse_elixir_output(stdout)
      else
        log_operation('cursor_bridge', 'WARNING', "Elixir execution failed, trying fallback: #{stderr}")
        nil
      end
    rescue => e
      log_operation('cursor_bridge', 'WARNING', "Elixir bridge exception, using fallback: #{e.message}")
      nil
    end
  end
  
  def build_elixir_call(function_name, args)
    """Build Elixir function call string with proper JSON encoding"""
    case function_name
    when :agent_completion
      prompt_escaped = args[:prompt].to_json
      workspace_escaped = (args[:workspace_context] || '').to_json
      opts_json = args[:opts].to_json
      "require Jason; Cursor.API.agent_completion(#{prompt_escaped}, #{workspace_escaped}, #{opts_json}) |> case do {:ok, result} -> Jason.encode!(%{ok: result}) |> IO.puts(); {:error, reason} -> Jason.encode!(%{error: inspect(reason)}) |> IO.puts() end"
    
    when :conversation_completion
      prompt_escaped = args[:prompt].to_json
      history_json = args[:conversation_history].to_json
      workspace_escaped = (args[:workspace_context] || '').to_json
      opts_json = args[:opts].to_json
      "require Jason; Cursor.API.conversation_completion(#{prompt_escaped}, #{history_json}, #{workspace_escaped}, #{opts_json}) |> case do {:ok, result} -> Jason.encode!(%{ok: result}) |> IO.puts(); {:error, reason} -> Jason.encode!(%{error: inspect(reason)}) |> IO.puts() end"
    
    when :health_check
      "require Jason; Cursor.API.health_check() |> case do {:ok, result} -> Jason.encode!(%{ok: result}) |> IO.puts(); {:error, reason} -> Jason.encode!(%{error: inspect(reason)}) |> IO.puts() end"
    
    else
      raise "Unknown function: #{function_name}"
    end
  end
  
  def parse_elixir_output(output)
    """Parse Elixir JSON output"""
    output = output.strip
    return nil if output.empty?
    
    # Try to parse as JSON
    JSON.parse(output)
  rescue => e
    log_operation('cursor_bridge', 'WARNING', "Failed to parse Elixir output: #{e.message}, output: #{output[0..200]}")
    nil
  end
  
  def load_api_key_from_secrets
    """Load API key from secrets file"""
    secrets_file = File.join(get_vec3_root, 'rc', 'secrets', 'api.keys')
    return nil unless File.exist?(secrets_file)
    
    File.readlines(secrets_file).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      
      if line =~ /^CURSOR_API_KEY=(.+)$/
        key = $1.strip.gsub(/^["']|["']$/, '')
        return key unless key.empty?
      end
    end
    
    nil
  end
  
  # ============================================================================
  # HIGH-LEVEL API METHODS
  # ============================================================================
  
  def agent_completion(prompt, workspace_context = nil, options = {})
    """Get agent completion via Elixir (external signal)"""
    result = call_elixir_function(:agent_completion, {
      prompt: prompt,
      workspace_context: workspace_context,
      opts: options
    })
    
    if result && result['ok']
      result['ok']
    elsif result && result['error']
      log_operation('cursor_bridge', 'WARNING', "Elixir API error, trying fallback: #{result['error']}")
      # Fallback to direct HTTP
      agent_completion_fallback(prompt, workspace_context, options)
    else
      # Fallback to direct HTTP if Elixir unavailable
      log_operation('cursor_bridge', 'INFO', 'Elixir bridge unavailable, using HTTP fallback')
      agent_completion_fallback(prompt, workspace_context, options)
    end
  end
  
  def conversation_completion(prompt, conversation_history = [], workspace_context = nil, options = {})
    """Get conversation completion via Elixir (external signal)"""
    result = call_elixir_function(:conversation_completion, {
      prompt: prompt,
      conversation_history: conversation_history,
      workspace_context: workspace_context,
      opts: options
    })
    
    if result && result['ok']
      result['ok']
    elsif result && result['error']
      log_operation('cursor_bridge', 'WARNING', "Elixir API error, trying fallback: #{result['error']}")
      # Fallback to direct HTTP
      conversation_completion_fallback(prompt, conversation_history, workspace_context, options)
    else
      # Fallback to direct HTTP if Elixir unavailable
      log_operation('cursor_bridge', 'INFO', 'Elixir bridge unavailable, using HTTP fallback')
      conversation_completion_fallback(prompt, conversation_history, workspace_context, options)
    end
  end
  
  def conversation_completion_fallback(prompt, conversation_history = [], workspace_context = nil, options = {})
    """Fallback to direct HTTP call if Elixir unavailable"""
    require_relative 'cursor.api'
    CursorAPI.conversation_completion(prompt, conversation_history, workspace_context, options)
  rescue => e
    log_operation('cursor_bridge', 'ERROR', "Fallback also failed: #{e.message}")
    raise
  end
  
  def health_check
    """Check Cursor API health via Elixir"""
    result = call_elixir_function(:health_check, {})
    
    if result && result['ok']
      { available: true, model: result['ok']['model'] }
    elsif result && result['error']
      { available: false, reason: result['error'] }
    else
      { available: false, reason: 'unknown_error' }
    end
  end
  
  # ============================================================================
  # FALLBACK TO DIRECT HTTP (if Elixir unavailable)
  # ============================================================================
  
  def agent_completion_fallback(prompt, workspace_context = nil, options = {})
    """Fallback to direct HTTP call if Elixir unavailable"""
    require_relative 'cursor.api'
    CursorAPI.agent_completion(prompt, workspace_context, options)
  rescue => e
    log_operation('cursor_bridge', 'WARNING', "Fallback also failed: #{e.message}")
    raise
  end
end

# ============================================================================
# COMMAND LINE INTERFACE
# ============================================================================

if __FILE__ == $0
  require 'optparse'
  
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: cursor.bridge.rb [command] [options]"
    
    opts.on("-p", "--prompt TEXT", "Prompt text") do |p|
      options[:prompt] = p
    end
    
    opts.on("--health", "Check API health") do
      health = CursorBridge.health_check
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
      response = CursorBridge.agent_completion(options[:prompt])
      puts response
      exit 0
    rescue => e
      puts "ERROR: #{e.message}"
      exit 1
    end
    
  when 'health'
    health = CursorBridge.health_check
    puts JSON.pretty_generate(health)
    exit health[:available] ? 0 : 1
    
  else
    puts "Commands: test, health"
    puts "Run with -h for help"
  end
end

# :: ∎