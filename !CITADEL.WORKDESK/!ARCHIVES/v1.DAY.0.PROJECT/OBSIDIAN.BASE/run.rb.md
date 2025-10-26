#!/usr/bin/env ruby
#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
#▛//▞▞ ⟦⎊⟧ :: ⧗-25.63 ▸ ρ{runtime.flow}.φ{orchestrate}.τ{session}.λ{bind} ⫸ :: RUN.RB
#
# OBSIDIAN.BASE Runtime - LIGHTHOUSE Brain Orchestration

require 'yaml'
require 'digest'
require 'time'

# ============================================================================
# Session Management
# ============================================================================

module Session
  @context = []
  @session_id = nil
  @created_at = nil
  
  def self.init(session_id)
    @session_id = session_id
    @created_at = sirius_time
    @context = []
  end
  
  def self.add(role, message)
    @context << {
      role: role,
      content: message,
      timestamp: sirius_time
    }
  end
  
  def self.get_context
    @context
  end
  
  def self.clear
    @context = []
  end
  
  def self.save
    # Atomic write: temp file → rename
    temp_file = '.3ox/session.yaml.tmp'
    final_file = '.3ox/session.yaml'
    
    File.write(temp_file, {
      session_id: @session_id,
      created: @created_at,
      last_active: sirius_time,
      context: @context
    }.to_yaml)
    
    File.rename(temp_file, final_file)
  end
  
  def self.load(session_id)
    return unless File.exist?('.3ox/session.yaml')
    
    data = YAML.load_file('.3ox/session.yaml')
    @session_id = data[:session_id]
    @created_at = data[:created]
    @context = data[:context] || []
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
  def self.generate(file, stage)
    hash = Digest::SHA256.file(file).hexdigest
    
    receipt = {
      file: file,
      stage: stage,
      hash: hash,
      timestamp: sirius_time,
      station: 'OBSIDIAN.LIGHTHOUSE'
    }
    
    # Log receipt
    log_receipt(receipt)
    
    receipt
  end
  
  def self.validate(file, expected_hash)
    current_hash = Digest::SHA256.file(file).hexdigest
    current_hash == expected_hash
  end
  
  def self.log_receipt(receipt)
    # Atomic append with lock
    File.open('.3ox/receipts.log', 'a') do |f|
      f.flock(File::LOCK_EX)
      f.puts "[#{receipt[:timestamp]}] #{receipt[:stage]} | #{receipt[:file]} | #{receipt[:hash]}"
      f.flush
      f.flock(File::LOCK_UN)
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
# Trace Logger with TOML Output
# ============================================================================

module Trace
  @session_data = {}
  
  def self.log(event, data = {})
    # Atomic append to .3ox/trace.log with lock
    File.open('.3ox/trace.log', 'a') do |f|
      f.flock(File::LOCK_EX)
      f.puts "[#{sirius_time}] #{event} | #{data.inspect}"
      f.flush
      f.flock(File::LOCK_UN)
    end
    
    # Store for TOML generation
    @session_data[event] = data.merge(timestamp: sirius_time)
  end
  
  def self.agent_start(agent_name, session_id)
    @session_data = {
      agent: agent_name,
      session_id: session_id,
      start_time: sirius_time
    }
    log('AGENT_START', { agent: agent_name, session: session_id })
  end
  
  def self.agent_end(status, duration = nil)
    @session_data[:status] = status
    @session_data[:duration] = duration
    @session_data[:end_time] = sirius_time
    
    log('AGENT_END', { status: status, duration: duration })
    
    # Generate TOML and ship to CMD.BRIDGE/log.book/
    generate_toml
  end
  
  def self.tool_call(tool_name, input)
    @session_data[:tools_used] ||= []
    @session_data[:tools_used] << { tool: tool_name, input: input, time: sirius_time }
    log('TOOL_CALL', { tool: tool_name, input: input })
  end
  
  def self.tool_result(result)
    log('TOOL_RESULT', { result: result })
  end
  
  private
  
  def self.generate_toml
    toml_content = build_toml(@session_data)
    
    # Create log.book directory if needed
    log_book_dir = File.expand_path('../../CMD.BRIDGE/log.book', __dir__)
    Dir.mkdir(log_book_dir) unless Dir.exist?(log_book_dir)
    
    # Atomic write: temp file → rename
    timestamp = Time.now.to_i
    temp_file = "#{log_book_dir}/∎_#{@session_data[:session_id]}_#{timestamp}.toml.tmp"
    final_file = "#{log_book_dir}/∎_#{@session_data[:session_id]}_#{timestamp}.toml"
    
    File.write(temp_file, toml_content)
    File.rename(temp_file, final_file)
    
    puts "📋 Trace TOML shipped: #{final_file}"
  end
  
  def self.build_toml(data)
    <<~TOML
      # .3ox Trace Log - OBSIDIAN.LIGHTHOUSE
      # Generated: #{Time.now}
      
      [session]
      agent = "#{data[:agent]}"
      session_id = "#{data[:session_id]}"
      start_time = "#{data[:start_time]}"
      end_time = "#{data[:end_time]}"
      status = "#{data[:status]}"
      duration = "#{data[:duration]}"
      
      [station]
      name = "OBSIDIAN.LIGHTHOUSE"
      brain = "LIGHTHOUSE"
      workspace = "OBSIDIAN.BASE"
      
      [[tools]]
      #{format_tools(data[:tools_used] || [])}
      
      [metadata]
      framework_version = "v1.0.0"
      trace_log = ".3ox/trace.log"
      receipts_log = ".3ox/receipts.log"
    TOML
  end
  
  def self.format_tools(tools)
    if tools.empty?
      'used = []'
    else
      tools.map { |t| "# #{t[:tool]} at #{t[:time]}" }.join("\n  ")
    end
  end
  
  def self.sirius_time
    reset = Time.new(2025, 8, 8)
    now = Time.now
    days = ((now - reset) / 86400).to_i
    year = now.year % 100
    "⧗-#{year}.#{days}.#{now.strftime('%H:%M')}"
  end
end

# ============================================================================
# Output Management
# ============================================================================

module Output
  def self.ship(content, filename)
    # Route to central OPS.STATION
    output_dir = File.expand_path('../../OPS.STATION/0ut.3ox', __dir__)
    Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
    
    # Atomic write: temp file → rename
    temp_file = "#{output_dir}/#{filename}.tmp"
    final_file = "#{output_dir}/#{filename}"
    
    File.write(temp_file, content)
    File.rename(temp_file, final_file)
    
    # Add to manifest
    add_to_manifest(final_file)
    
    final_file
  end
  
  def self.add_to_manifest(file)
    manifest_path = '0ut.3ox/FILE.MANIFEST.txt'
    timestamp = sirius_time
    
    # Atomic append with lock
    File.open(manifest_path, 'a') do |f|
      f.flock(File::LOCK_EX)
      f.puts "[#{timestamp}] | READY | #{File.basename(file)} | OBSIDIAN.LIGHTHOUSE | HIGH"
      f.flush
      f.flock(File::LOCK_UN)
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
# Example Usage - LIGHTHOUSE Operations
# ============================================================================

if __FILE__ == $0
  puts "="*80
  puts "OBSIDIAN.BASE - LIGHTHOUSE Runtime Test"
  puts "="*80
  puts ""
  
  # Initialize session
  Session.init('lighthouse_test_001')
  Trace.agent_start('LIGHTHOUSE', 'lighthouse_test_001')
  
  # Add context
  Session.add(:user, 'Catalog this knowledge base')
  Session.add(:agent, 'Initiating LibraryCatalog tool...')
  
  # Generate receipt
  receipt = Receipt.generate(__FILE__, :intake)
  puts "Receipt Generated:"
  puts "  File: #{receipt[:file]}"
  puts "  Hash: #{receipt[:hash]}"
  puts "  Station: #{receipt[:station]}"
  puts "  Time: #{receipt[:timestamp]}"
  puts ""
  
  # Simulate output
  moc_content = "# Map of Content\n\n- Knowledge Systems\n- File Management\n- Receipts"
  output_file = Output.ship(moc_content, "lighthouse_moc_#{Time.now.to_i}.md")
  puts "Output shipped: #{output_file}"
  puts ""
  
  # Save session
  Session.save
  Trace.agent_end(:success, '1.8s')
  
  puts "✅ LIGHTHOUSE Runtime test complete!"
  puts "📂 Check .3ox/ for logs"
  puts "📂 Check 0ut.3ox/ for outputs"
  puts ""
end

#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ v1.0.0 | ⧗-25.63 ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂#///
