# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x1FED]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // IMPRINT.BRIDGE.RB ▞▞
# ▛▞// IMPRINT.BRIDGE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [telegram] [json] [kernel] [prism] [z3n] [imprintbridge] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.imprint.bridge.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for IMPRINT.BRIDGE.RB
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
##/// Last Updated: 2026.01.06 | Trace.ID: imprint.bridge.v1.0
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.06
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🌉] ≔ [imprint_bridge] [system] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // IMPRINT.BRIDGE ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# IMPRINT.BRIDGE.RB :: Ruby-to-Elixir Bridge for Imprint.ID Governance
# Allows brains.exe workers to call Imprint.ID for validation and governance
#
# CRITICAL: This module does NOT modify file canon keys (⟦⎊⟧ / ⟦⌬⟧) or PiCO chain symbols.
# Canon keys are ONLY changed by refactor.station.rb when actively in refactor forge context.
# This bridge is for Imprint.ID governance only - no file content modification.
#

require 'json'
require 'net/http'
require 'uri'
require 'open3'

module ImprintBridge
  IMPRINT_SERVER_URL = ENV['IMPRINT_SERVER_URL'] || 'http://localhost:4000'
  IMPRINT_LAB_PATH = ENV['IMPRINT_LAB_PATH'] || '/root/!CMD.BRIDGE/!ZENS3N.CMD/ZENS3N.BASE/Z3N.LABS/Imprint.ID'
  
  # ============================================================================
  # HTTP CLIENT (for running Imprint server)
  # ============================================================================
  
  def self.load_active_imprint_http
    uri = URI.parse("#{IMPRINT_SERVER_URL}/api/imprint/active")
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      JSON.parse(response.body)
    elsif response.code == '404'
      nil  # No active imprint
    else
      raise "Failed to load imprint: #{response.code} #{response.body}"
    end
  rescue => e
    # Fallback to direct Elixir call if server not running
    load_active_imprint_direct
  end
  
  def self.submit_receipt_http(receipt)
    uri = URI.parse("#{IMPRINT_SERVER_URL}/api/receipt")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = JSON.generate(receipt)
    
    response = http.request(request)
    response.code == '201'
  rescue => e
    # Fallback to direct file write
    submit_receipt_direct(receipt)
  end
  
  # ============================================================================
  # DIRECT ELIXIR EXECUTION (no server required)
  # ============================================================================
  
  def self.load_active_imprint_direct
    # Call Elixir directly via Mix task
    Dir.chdir(IMPRINT_LAB_PATH) do
      stdout, stderr, status = Open3.capture3(
        'mix', 'run', '-e', 'Imprint.load_active() |> IO.inspect()'
      )
      
      if status.success? && stdout.include?('{:ok,')
        # Parse Elixir output (basic parsing)
        # In production, use proper JSON serialization
        extract_imprint_from_elixir_output(stdout)
      else
        nil
      end
    end
  rescue => e
    puts "WARN: Could not load imprint via Elixir: #{e.message}"
    nil
  end
  
  def self.submit_receipt_direct(receipt)
    # Write receipt to file system
    receipts_dir = File.join(IMPRINT_LAB_PATH, 'var', 'receipts')
    FileUtils.mkdir_p(receipts_dir) unless File.directory?(receipts_dir)
    
    receipt_file = File.join(receipts_dir, "#{receipt['trace_id']}.json")
    File.write(receipt_file, JSON.pretty_generate(receipt))
    true
  rescue => e
    puts "ERROR: Failed to write receipt: #{e.message}"
    false
  end
  
  # ============================================================================
  # GOVERNANCE VALIDATION
  # ============================================================================
  
  def self.validate_job(job, imprint = nil)
    # Load active imprint if not provided
    imprint ||= load_active_imprint
    
    unless imprint
      return {
        valid: false,
        reason: 'no_active_imprint',
        action: 'refuse'
      }
    end
    
    # Check if job type is allowed
    job_type = job['job_type']
    payload = job['payload']
    
    # Map job types to tool IDs
    tool_id = map_job_to_tool(job_type, payload)
    
    # Check tool eligibility
    if imprint['tools'] && imprint['tools'][tool_id]
      tool = imprint['tools'][tool_id]
      
      {
        valid: true,
        tool_id: tool_id,
        tool: tool,
        action: 'proceed'
      }
    else
      {
        valid: false,
        reason: 'tool_not_eligible',
        tool_id: tool_id,
        action: 'refuse'
      }
    end
  end
  
  def self.map_job_to_tool(job_type, payload)
    # Map job types to Imprint tool IDs
    case job_type
    when 'ask'
      'tool.text_analysis'
    when 'ingest.file'
      'tool.file_operations'
    when 'shell.cmd'
      'tool.file_operations'
    when 'telegram', 'rest.request'
      'tool.text_analysis'
    else
      'tool.text_analysis'  # Default
    end
  end
  
  # ============================================================================
  # ROUTE MATCHING
  # ============================================================================
  
  def self.match_route(input, imprint = nil)
    imprint ||= load_active_imprint
    
    unless imprint
      return {
        matched: false,
        route_id: 'fallback',
        reason: 'no_active_imprint'
      }
    end
    
    routes = imprint['routes'] || []
    
    # Try to match routes in priority order
    matched_route = routes.find do |route|
      match_route_criteria?(input, route)
    end
    
    if matched_route
      {
        matched: true,
        route_id: matched_route['id'],
        route: matched_route,
        eligible_tools: matched_route['tools'] || []
      }
    else
      {
        matched: false,
        route_id: 'fallback',
        reason: 'no_matching_route'
      }
    end
  end
  
  def self.match_route_criteria?(input, route)
    input_text = input.to_s.downcase
    
    # Check regex match
    if route['regex']
      return true if input_text.match?(Regexp.new(route['regex'], Regexp::IGNORECASE))
    end
    
    # Check contains
    if route['contains']
      route['contains'].each do |term|
        return true if input_text.include?(term.downcase)
      end
    end
    
    # Check keywords
    if route['keywords']
      route['keywords'].each do |keyword|
        return true if input_text.include?(keyword.downcase)
      end
    end
    
    false
  end
  
  # ============================================================================
  # RECEIPT OPERATIONS
  # ============================================================================
  
  def self.create_imprint_receipt(job, result, imprint_id)
    {
      'trace_id' => job['trace_id'] || job['job_id'],
      'job_id' => job['job_id'],
      'imprint_id' => imprint_id,
      'timestamp' => Time.now.utc.iso8601,
      'actor' => job['actor'],
      'intent' => job['job_type'],
      'status' => result[:status] || 'completed',
      'result' => result[:data],
      'error' => result[:error],
      'tools_used' => result[:tools_used] || [],
      'route_id' => result[:route_id]
    }
  end
  
  def self.submit_receipt(receipt)
    # Try HTTP first, fall back to direct
    submit_receipt_http(receipt) || submit_receipt_direct(receipt)
  end
  
  # ============================================================================
  # HEALTH CHECK
  # ============================================================================
  
  def self.health_check
    begin
      uri = URI.parse("#{IMPRINT_SERVER_URL}/health")
      response = Net::HTTP.get_response(uri)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        {
          status: 'ok',
          server: 'running',
          redis: data['redis'],
          timestamp: data['timestamp']
        }
      else
        {
          status: 'error',
          server: 'unreachable',
          message: "HTTP #{response.code}"
        }
      end
    rescue => e
      {
        status: 'error',
        server: 'unreachable',
        message: e.message
      }
    end
  end
  
  # ============================================================================
  # CONVENIENCE METHODS
  # ============================================================================
  
  def self.load_active_imprint
    # Try HTTP first, then direct
    load_active_imprint_http
  rescue => e
    load_active_imprint_direct
  end
  
  def self.imprint_available?
    imprint = load_active_imprint
    !imprint.nil?
  end
  
  def self.extract_imprint_from_elixir_output(output)
    # Basic parser for Elixir term output
    # In production, use proper JSON serialization from Elixir side
    # For now, return nil to indicate parsing not implemented
    # TODO: Implement proper Elixir -> JSON bridge
    nil
  end
end

# ============================================================================
# CLI INTERFACE
# ============================================================================

if __FILE__ == $0
  require 'optparse'
  
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: imprint.bridge.rb [command] [options]"
    
    opts.on("-c", "--command COMMAND", "Command: health, load, validate") do |c|
      options[:command] = c
    end
    
    opts.on("-j", "--job FILE", "Job file (JSON)") do |f|
      options[:job_file] = f
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!
  
  case options[:command]
  when 'health'
    health = ImprintBridge.health_check
    puts JSON.pretty_generate(health)
    exit(health[:status] == 'ok' ? 0 : 1)
    
  when 'load'
    imprint = ImprintBridge.load_active_imprint
    if imprint
      puts JSON.pretty_generate(imprint)
      exit 0
    else
      puts "No active imprint found"
      exit 1
    end
    
  when 'validate'
    unless options[:job_file]
      puts "ERROR: --job FILE required"
      exit 1
    end
    
    job = JSON.parse(File.read(options[:job_file]))
    validation = ImprintBridge.validate_job(job)
    puts JSON.pretty_generate(validation)
    exit(validation[:valid] ? 0 : 1)
    
  else
    puts "Available commands: health, load, validate"
    puts "Run with -h for help"
  end
end

# :: ∎