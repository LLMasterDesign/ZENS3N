#!/usr/bin/env ruby
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
# ▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // OPERATOR ▞▞
# ▞//▞ Receipt Manager :: ρ{create}.φ{track}.τ{verify}.λ{runtime} ⫸
# ▙⌱📋 ≔ [⊢{transfer}⇨{receipt}⟿{audit}▷{tracking}]
# 〔BASE.OPS.receipt.manager〕 :: ∎

require 'digest'
require 'time'
require 'fileutils'

class TransferReceipt
  attr_accessor :receipt_id, :sirius_time,
                :from_station, :from_path, :from_agent,
                :to_station, :to_path, :to_agent,
                :filename, :file_hash, :file_size, :file_type,
                :timestamp_exit, :timestamp_arrival,
                :transit_method, :status,
                :task_description, :next_action, :priority, :dependencies,
                :receipt_path, :related_receipts, :notes
  
  def initialize
    @sirius_time = calculate_sirius_time
    @timestamp_exit = Time.now.strftime('%Y-%m-%dT%H:%M:%S')
    @status = 'Created'
    @dependencies = []
    @related_receipts = []
  end
  
  def calculate_sirius_time
    reset = Time.new(2025, 8, 8)
    days = ((Time.now - reset) / 86400).to_i
    year = Time.now.year % 100
    "⧗-#{year}.#{days}"
  end
  
  def generate_receipt_id
    hash = Digest::SHA256.hexdigest("#{@timestamp_exit}#{@filename}#{@from_path}")[0...8]
    timestamp = Time.now.strftime('%Y%m%d')
    @receipt_id = "TR-#{timestamp}-#{hash}"
  end
  
  def calculate_file_hash(filepath)
    return 'MISSING' unless File.exist?(filepath)
    Digest::SHA256.file(filepath).hexdigest[0...16]
  end
  
  def to_toml
    # Generate TOML format receipt
    <<~TOML
      # Transfer Receipt
      # Generated: #{@sirius_time}
      # Status: #{@status}
      
      [identity]
      receipt_id = "#{@receipt_id}"
      sirius_time = "#{@sirius_time}"
      
      [origin]
      from_station = "#{@from_station}"
      from_path = "#{@from_path}"
      #{@from_agent ? "from_agent = \"#{@from_agent}\"" : '# from_agent = ""'}
      
      [destination]
      to_station = "#{@to_station}"
      to_path = "#{@to_path}"
      #{@to_agent ? "to_agent = \"#{@to_agent}\"" : '# to_agent = ""'}
      
      [file]
      filename = "#{@filename}"
      file_hash = "#{@file_hash}"
      file_size = #{@file_size}
      file_type = "#{@file_type}"
      
      [transit]
      timestamp_exit = "#{@timestamp_exit}"
      #{@timestamp_arrival ? "timestamp_arrival = \"#{@timestamp_arrival}\"" : '# timestamp_arrival = ""'}
      transit_method = "#{@transit_method}"
      status = "#{@status}"
      
      [task]
      #{@task_description ? "description = \"#{@task_description}\"" : '# description = ""'}
      #{@next_action ? "next_action = \"#{@next_action}\"" : '# next_action = ""'}
      priority = "#{@priority || 'MEDIUM'}"
      dependencies = #{@dependencies.inspect}
      
      [audit]
      receipt_path = "#{@receipt_path}"
      related_receipts = #{@related_receipts.inspect}
      #{@notes ? "notes = \"#{@notes}\"" : '# notes = ""'}
    TOML
  end
  
  def save_with_file(destination_path)
    # Save receipt NEXT TO the transferred file
    receipt_file = "#{destination_path}.receipt.toml"
    File.write(receipt_file, to_toml)
    puts "✓ Receipt saved with file: #{receipt_file}"
    receipt_file
  end
  
  def save_to_registry(base_ops_path)
    # Save copy to central registry
    date = Time.now.strftime('%Y-%m-%d')
    registry_dir = File.join(base_ops_path, 'RECEIPTS', date)
    FileUtils.mkdir_p(registry_dir)
    
    receipt_file = File.join(registry_dir, "#{@receipt_id}.receipt.toml")
    File.write(receipt_file, to_toml)
    puts "✓ Receipt logged to registry: #{receipt_file}"
    
    @receipt_path = receipt_file
    receipt_file
  end
end

class ReceiptManager
  BASE_OPS = 'P:/!CMD.BRIDGE/!BASE.OPERATIONS'
  
  def self.create_for_transfer(file_path, destination_path, options = {})
    receipt = TransferReceipt.new
    
    # Auto-detect station from path
    receipt.from_station = extract_station(file_path)
    receipt.to_station = extract_station(destination_path)
    
    # File details
    receipt.filename = File.basename(file_path)
    receipt.from_path = file_path
    receipt.to_path = destination_path
    receipt.file_hash = receipt.calculate_file_hash(file_path)
    receipt.file_size = File.exist?(file_path) ? File.size(file_path) : 0
    receipt.file_type = File.extname(file_path)
    
    # Task handoff (CRITICAL)
    receipt.task_description = options[:task]
    receipt.next_action = options[:next_action]
    receipt.priority = options[:priority] || 'MEDIUM'
    receipt.dependencies = options[:dependencies] || []
    
    # Transit details
    receipt.transit_method = options[:method] || 'RouterScript'
    receipt.from_agent = options[:from_agent]
    receipt.to_agent = options[:to_agent]
    receipt.notes = options[:notes]
    
    # Generate ID
    receipt.generate_receipt_id
    
    receipt
  end
  
  def self.extract_station(path)
    # Extract station name from path
    if path.include?('RVNx.BASE')
      'RVNx.BASE'
    elsif path.include?('OBSIDIAN.BASE')
      'OBSIDIAN.BASE'
    elsif path.include?('SYNTH.BASE')
      'SYNTH.BASE'
    else
      'UNKNOWN'
    end
  end
  
  def self.mark_arrived(receipt_file)
    # Update receipt when file arrives
    return unless File.exist?(receipt_file)
    
    content = File.read(receipt_file)
    timestamp = Time.now.strftime('%Y-%m-%dT%H:%M:%S')
    
    updated = content.gsub(/# timestamp_arrival = ""/, "timestamp_arrival = \"#{timestamp}\"")
    updated = updated.gsub(/status = "Created"/, 'status = "Arrived"')
    updated = updated.gsub(/status = "InTransit"/, 'status = "Arrived"')
    
    File.write(receipt_file, updated)
    puts "✓ Receipt updated: File arrived at #{timestamp}"
  end
  
  def self.verify_hash(receipt_file, actual_file_path)
    # Verify file integrity using receipt hash
    return false unless File.exist?(receipt_file) && File.exist?(actual_file_path)
    
    content = File.read(receipt_file)
    recorded_hash = content[/file_hash = "([^"]+)"/, 1]
    
    receipt = TransferReceipt.new
    actual_hash = receipt.calculate_file_hash(actual_file_path)
    
    if recorded_hash == actual_hash
      puts "✓ Hash verified: File integrity confirmed"
      
      updated = content.gsub(/status = "Arrived"/, 'status = "Verified"')
      File.write(receipt_file, updated)
      true
    else
      puts "❌ Hash mismatch: File may be corrupted"
      false
    end
  end
  
  def self.read_task_from_receipt(receipt_file)
    # Read what to do next from receipt
    return nil unless File.exist?(receipt_file)
    
    content = File.read(receipt_file)
    
    task = content[/description = "([^"]+)"/, 1]
    next_action = content[/next_action = "([^"]+)"/, 1]
    priority = content[/priority = "([^"]+)"/, 1]
    
    {
      task: task,
      next_action: next_action,
      priority: priority
    }
  end
end

# Example usage:
if __FILE__ == $0
  puts "📋 Transfer Receipt Manager"
  puts "=" * 50
  
  # Example: Create receipt for file transfer
  receipt = ReceiptManager.create_for_transfer(
    'RVNx.BASE/!RVNX.OPS/0ut.3ox/status-report.md',
    'OBSIDIAN.BASE/!1N.3OX OBSIDIAN/Reports/status-report.md',
    task: 'Review status report and integrate into weekly notes',
    next_action: 'Read report → Create wiki links → Tag with #status #weekly',
    priority: 'HIGH',
    from_agent: 'CMD.BRIDGE',
    to_agent: 'LIGHTHOUSE',
    notes: 'Weekly status from RVNx operations'
  )
  
  # Save with file (travels together)
  receipt.save_with_file('OBSIDIAN.BASE/!1N.3OX OBSIDIAN/Reports/status-report.md')
  
  # Save to central registry (audit trail)
  receipt.save_to_registry(ReceiptManager::BASE_OPS)
  
  puts "\n✅ Transfer receipt created and stored"
  puts "📋 Receipt ID: #{receipt.receipt_id}"
  puts "🎯 Task: #{receipt.task_description}"
  puts "▶️  Next: #{receipt.next_action}"
end

