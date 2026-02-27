# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x3011]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // BRAINS.CURSOR.RB ▞▞
# ▛▞// BRAINS.CURSOR.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [token] [kernel] [prism] [z3n] [cursorbrainsworker] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.brains.cursor.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for BRAINS.CURSOR.RB
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
##/// Last Updated: 2026.01.05 | Trace.ID: brains.cursor.v1.0
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.05
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [brains_cursor] [system] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // BRAINS.CURSOR ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# BRAINS.CURSOR.RB :: Cursor Brains Worker for CMD.BRIDGE
# Consumes jobs from Redis queue and executes via Cursor Cloud Agent API
# Follows Teleprompter architecture pattern
#

require 'json'
require 'time'
require 'fileutils'
require 'securerandom'
require_relative 'cursor.bridge'  # Use Elixir bridge for external signals
begin
  require_relative '../ops/cache/redis.rb'
rescue LoadError
  # Optional legacy dependency (missing in minimal runtime)
end
require_relative '../ops/lib/helpers.rb'
begin
  require_relative '../ops/conversation.context.rb'
rescue LoadError
  # Optional legacy dependency (missing in minimal runtime)
end
require_relative '../bin/sirius.clock.rb'

class CursorBrainsWorker
  include Helpers
  
  def initialize(base_id: 'CMD.BRIDGE', station_id: 'GENERAL')
    @base_id = base_id
    @station_id = station_id
    @running = true
    @worker_id = "cursor_worker_#{Process.pid}_#{SecureRandom.hex(8)}"
    @cursor_bridge = CursorBridge  # Use Elixir bridge for external signals
    
    log_operation('cursor_worker', 'INIT', "Worker #{@worker_id} starting for Base=#{@base_id}, Station=#{@station_id}")
    
    # Check Cursor API availability via Elixir bridge
    health = @cursor_bridge.health_check
    if health[:available]
      log_operation('cursor_worker', 'COMPLETE', "Cursor API health check passed via Elixir bridge")
    else
      log_operation('cursor_worker', 'WARNING', "Cursor API health check failed: #{health[:reason]}")
      log_operation('cursor_worker', 'INFO', "Will attempt fallback to direct HTTP if needed")
    end
  end
  
  # ============================================================================
  # JOB PROCESSING
  # ============================================================================
  
  def process_job(job_json)
    """Process a single job from the queue"""
    job_data = JSON.parse(job_json)
    job_id = job_data['job_id']
    trace_id = job_data['trace_id']
    
    log_operation('cursor_worker', 'INFO', "Processing job #{job_id}, type=#{job_data['job_type']}")
    
    begin
      # Load conversation context from Redis
      thread_id = job_data['thread_id']
      context = load_conversation_context(thread_id)
      
      # Get workspace context
      workspace_context = get_workspace_context
      
      # Build messages with context
      prompt = job_data['payload']['prompt']
      messages = build_messages(context, prompt)
      
      # Call Cursor API via Elixir bridge (external signal)
      response_text = @cursor_bridge.conversation_completion(
        prompt,
        context,
        workspace_context,
        {
          model: 'gpt-4',
          max_tokens: 4096,
          temperature: 0.7
        }
      )
      
      # Save to conversation context
      save_conversation_context(thread_id, 'user', prompt)
      save_conversation_context(thread_id, 'assistant', response_text)
      
      # Create result event (following outbox spec)
      result = create_result_event(job_data, response_text, 'ok')
      
      # Write outbox event to disk
      write_outbox_event(result)
      
      # Store result in Redis for bot to pick up
      store_result_in_redis(job_id, result)
      
      # Write receipt
      write_receipt(job_data, result)
      
      log_operation('cursor_worker', 'COMPLETE', "Job #{job_id} completed successfully")
      
      result
      
    rescue => e
      log_operation('cursor_worker', 'ERROR', "Job #{job_id} failed: #{e.message}")
      
      # Create error result
      error_result = create_result_event(job_data, "Error: #{e.message}", 'error')
      write_outbox_event(error_result)
      store_result_in_redis(job_id, error_result)
      
      raise
    end
  end
  
  # ============================================================================
  # MAIN LOOP
  # ============================================================================
  
  def run
    """Main worker loop - consumes jobs from Redis queue"""
    log_operation('cursor_worker', 'COMPLETE', "Worker #{@worker_id} entering main loop")
    
    Signal.trap('INT') { @running = false }
    Signal.trap('TERM') { @running = false }
    
    while @running
      begin
        if RedisCache.redis_available?
          redis = RedisCache.get_redis_connection
          
          # Blocking pop from queue (timeout 1 second)
          job_data = redis.brpop('queue:jobs', timeout: 1)
          
          if job_data
            _, job_json = job_data
            process_job(job_json)
          end
        else
          log_operation('cursor_worker', 'WARNING', 'Redis unavailable, waiting...')
          sleep 5
        end
      rescue Interrupt
        log_operation('cursor_worker', 'COMPLETE', "Worker #{@worker_id} received interrupt signal")
        @running = false
      rescue => e
        log_operation('cursor_worker', 'ERROR', "Worker loop error: #{e.message}")
        sleep 2  # Brief pause before retry
      end
    end
    
    log_operation('cursor_worker', 'COMPLETE', "Worker #{@worker_id} stopped")
  end
  
  # ============================================================================
  # RESULT EVENT CREATION
  # ============================================================================
  
  def create_result_event(job_data, response_text, status)
    """Create result event following outbox spec"""
    {
      'event_type' => 'job.result',
      'job_id' => job_data['job_id'],
      'trace_id' => job_data['trace_id'],
      'base_id' => job_data['base_id'],
      'station_id' => job_data['station_id'],
      'thread_id' => job_data['thread_id'],
      'chat_id' => job_data['chat_id'],
      'topic_thread_id' => job_data['topic_thread_id'],
      'status' => status,
      'reply' => {
        'text' => response_text,
        'attachments' => []
      },
      'artifacts' => [],
      'memory_patch' => {
        'pins_add' => {},
        'pins_remove' => [],
        'summary' => nil,
        'recent_append' => [
          {
            'role' => 'user',
            'text' => job_data['payload']['prompt'],
            'ts' => Time.now.to_i
          },
          {
            'role' => 'assistant',
            'text' => response_text,
            'ts' => Time.now.to_i
          }
        ]
      },
      'suggested_next' => {
        'station_id' => nil,
        'job_type' => nil,
        'requires_confirmation' => false
      },
      'receipts' => {
        'worker_id' => @worker_id,
        'timing_ms' => 0  # TODO: Track actual timing
      },
      'ts' => Time.now.to_i
    }
  end
  
  # ============================================================================
  # OUTBOX EVENT WRITING
  # ============================================================================
  
  def write_outbox_event(result)
    """Write outbox event to disk following spec"""
    base_root = File.expand_path(File.join(get_vec3_root, '..', '..'))
    outbox_dir = File.join(base_root, '.OPS', '0ut.3ox', 'events')
    FileUtils.mkdir_p(outbox_dir)
    
    timestamp = result['ts']
    job_id = result['job_id']
    event_file = File.join(outbox_dir, "#{timestamp}_#{job_id}.json")
    
    File.write(event_file, JSON.pretty_generate(result))
    log_operation('cursor_worker', 'COMPLETE', "Outbox event written: #{event_file}")
  end
  
  # ============================================================================
  # REDIS RESULT STORAGE
  # ============================================================================
  
  def store_result_in_redis(job_id, result)
    """Store result in Redis for bot to pick up"""
    return unless RedisCache.redis_available?
    
    redis = RedisCache.get_redis_connection
    result_key = "result:#{job_id}"
    
    # Store with 5 minute TTL
    redis.setex(result_key, 300, JSON.generate(result))
  end
  
  # ============================================================================
  # RECEIPT WRITING
  # ============================================================================
  
  def write_receipt(job_data, result)
    """Write receipt to disk"""
    receipts_dir = File.join(get_vec3_root, 'var', 'receipts', 'cursor')
    FileUtils.mkdir_p(receipts_dir)
    
    receipt = {
      'timestamp' => Time.now.utc.iso8601,
      'sirius_time' => sirius_time(),
      'actor' => 'cursor_worker',
      'intent' => 'job_execution',
      'job_id' => job_data['job_id'],
      'trace_id' => job_data['trace_id'],
      'base_id' => job_data['base_id'],
      'station_id' => job_data['station_id'],
      'thread_id' => job_data['thread_id'],
      'status' => result['status'],
      'worker_id' => @worker_id,
      'payload' => job_data['payload'],
      'result' => {
        'reply_text_length' => result.dig('reply', 'text')&.length || 0,
        'status' => result['status']
      }
    }
    
    receipt_file = File.join(receipts_dir, "#{job_data['trace_id']}.receipt.json")
    File.write(receipt_file, JSON.pretty_generate(receipt))
    
    # Also store in Redis
    if RedisCache.redis_available?
      RedisCache.store_receipt(job_data['trace_id'], receipt, 86400 * 30)
    end
  end
  
  # ============================================================================
  # CONTEXT MANAGEMENT
  # ============================================================================
  
  def load_conversation_context(thread_id)
    """Load conversation context from Redis"""
    ConversationContext.get_conversation(thread_id, limit: 20)
  rescue => e
    log_operation('cursor_worker', 'WARNING', "Failed to load context: #{e.message}")
    []
  end
  
  def save_conversation_context(thread_id, role, content)
    """Save message to conversation context"""
    ConversationContext.add_message(thread_id, role, content)
  rescue => e
    log_operation('cursor_worker', 'WARNING', "Failed to save context: #{e.message}")
  end
  
  def build_messages(context, new_prompt)
    """Build messages array from context and new prompt"""
    messages = []
    
    context.each do |msg|
      messages << {
        role: msg['role'],
        content: msg['content']
      }
    end
    
    messages << {
      role: 'user',
      content: new_prompt
    }
    
    messages
  end
  
  def get_workspace_context
    """Get workspace context (sparkfile, etc.)"""
    base_root = File.expand_path(File.join(get_vec3_root, '..', '..'))
    sparkfile_path = File.join(base_root, '.3ox', 'sparkfile.md')
    
    if File.exist?(sparkfile_path)
      File.read(sparkfile_path)
    else
      nil
    end
  end
  
  # ============================================================================
  # UTILITY
  # ============================================================================
  
  def stop
    """Stop the worker"""
    @running = false
    log_operation('cursor_worker', 'COMPLETE', "Worker #{@worker_id} stop requested")
  end
  
  def running?
    @running
  end
end

# ============================================================================
# COMMAND LINE INTERFACE
# ============================================================================

if __FILE__ == $0
  require 'optparse'
  
  options = {
    base_id: 'CMD.BRIDGE',
    station_id: 'GENERAL'
  }
  
  OptionParser.new do |opts|
    opts.banner = "Usage: brains.cursor.rb [options]"
    
    opts.on("-b", "--base-id ID", "Base ID (default: CMD.BRIDGE)") do |b|
      options[:base_id] = b
    end
    
    opts.on("-s", "--station-id ID", "Station ID (default: GENERAL)") do |s|
      options[:station_id] = s
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!
  
  begin
    worker = CursorBrainsWorker.new(
      base_id: options[:base_id],
      station_id: options[:station_id]
    )
    worker.run
  rescue => e
    puts "▛▞// Fatal error: #{e.message}"
    puts e.backtrace if ENV['DEBUG']
    exit 1
  end
end

# :: ∎