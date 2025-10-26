#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'redis'

###▙▖▙▖▞▞▙ FILE WATCHER ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
# Monitors .3ox inbox for new files and processes them

class FileWatcher
  def initialize(redis_host = 'localhost', redis_port = 6379)
    @redis = Redis.new(host: redis_host, port: redis_port)
    @inbox_path = '!RAVEN.ARC/!1N.3OX RAVEN'
    @outbox_path = '!RAVEN.ARC/!0UT.3OX RAVEN'
    @log_path = '!RAVEN.ARC/.3ox/3ox.log'
    
    # Ensure directories exist
    FileUtils.mkdir_p(@inbox_path) unless Dir.exist?(@inbox_path)
    FileUtils.mkdir_p(@outbox_path) unless Dir.exist?(@outbox_path)
    FileUtils.mkdir_p(File.dirname(@log_path)) unless Dir.exist?(File.dirname(@log_path))
  end
  
  def start_watching
    puts "▛▞ FILE WATCHER ▸ Starting..."
    puts "📁 Watching: #{@inbox_path}"
    puts "📤 Outbox: #{@outbox_path}"
    puts "📜 Log: #{@log_path}"
    puts "----------------------------------------"
    
    loop do
      begin
        check_for_new_files
        sleep(5) # Check every 5 seconds
      rescue => e
        log_error("FileWatcher error: #{e.message}")
        sleep(10) # Wait longer on error
      end
    end
  end
  
  private
  
  def check_for_new_files
    return unless Dir.exist?(@inbox_path)
    
    files = Dir.glob("#{@inbox_path}/*")
    
    files.each do |file_path|
      next if File.directory?(file_path)
      
      process_file(file_path)
    end
  end
  
  def process_file(file_path)
    filename = File.basename(file_path)
    
    # Create receipt
    receipt_id = create_receipt(filename, file_path)
    
    # Log the file detection
    log_entry = {
      timestamp: Time.now.iso8601,
      event: 'file_detected',
      filename: filename,
      receipt_id: receipt_id,
      path: file_path
    }
    
    log_to_file(log_entry)
    
    # Move file to outbox (simple processing)
    outbox_file = File.join(@outbox_path, filename)
    
    begin
      FileUtils.mv(file_path, outbox_file)
      
      # Update receipt
      update_receipt(receipt_id, 'processed', outbox_file)
      
      # Log completion
      completion_log = {
        timestamp: Time.now.iso8601,
        event: 'file_processed',
        filename: filename,
        receipt_id: receipt_id,
        outbox_path: outbox_file
      }
      
      log_to_file(completion_log)
      
      puts "✅ Processed: #{filename} (#{receipt_id})"
      
    rescue => e
      log_error("Failed to process #{filename}: #{e.message}")
      update_receipt(receipt_id, 'error', e.message)
    end
  end
  
  def create_receipt(filename, file_path)
    receipt_id = "receipt_#{Time.now.to_i}_#{rand(1000)}"
    
    receipt = {
      id: receipt_id,
      filename: filename,
      original_path: file_path,
      status: 'detected',
      created_at: Time.now.to_i,
      processed_at: nil,
      outbox_path: nil,
      error: nil
    }
    
    # Store in Redis
    @redis.set("receipt:#{receipt_id}", receipt.to_json)
    @redis.expire("receipt:#{receipt_id}", 7 * 24 * 60 * 60) # 7 days
    
    # Add to receipts list
    @redis.lpush('receipts:list', receipt_id)
    @redis.ltrim('receipts:list', 0, 999) # Keep last 1000 receipts
    
    receipt_id
  end
  
  def update_receipt(receipt_id, status, data = nil)
    receipt_data = @redis.get("receipt:#{receipt_id}")
    return unless receipt_data
    
    receipt = JSON.parse(receipt_data)
    receipt['status'] = status
    receipt['processed_at'] = Time.now.to_i if status == 'processed'
    
    case status
    when 'processed'
      receipt['outbox_path'] = data
    when 'error'
      receipt['error'] = data
    end
    
    @redis.set("receipt:#{receipt_id}", receipt.to_json)
  end
  
  def log_to_file(log_entry)
    # Rotate log if it gets too big (>10MB)
    if File.exist?(@log_path) && File.size(@log_path) > 10 * 1024 * 1024
      rotate_log_file
    end
    
    File.open(@log_path, 'a') do |f|
      f.puts(log_entry.to_json)
    end
  rescue => e
    puts "Failed to write to log: #{e.message}"
  end
  
  def rotate_log_file
    # Move current log to .old and start fresh
    old_log = "#{@log_path}.old"
    FileUtils.mv(@log_path, old_log) if File.exist?(@log_path)
    puts "📜 Log rotated: #{@log_path} -> #{old_log}"
  end
  
  def log_error(message)
    error_entry = {
      timestamp: Time.now.iso8601,
      event: 'error',
      message: message
    }
    
    log_to_file(error_entry)
    puts "❌ #{message}"
  end
end

# Run the file watcher if this script is executed directly
if __FILE__ == $0
  watcher = FileWatcher.new
  watcher.start_watching
end
