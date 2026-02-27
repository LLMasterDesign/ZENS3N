# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x782F]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // HEARTBEAT.RB ▞▞
# ▛▞// HEARTBEAT.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.heartbeat.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for HEARTBEAT.RB
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
##/// Last Updated: 2026.01.05 | Trace.ID: heartbeat.v1.0
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.05
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [heartbeat] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // HEARTBEAT ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# HEARTBEAT.RB :: Status Events and Health Monitoring for CMD.BRIDGE
# Ported and adapted from VSO.Agent heartbeat.rb
#

require 'json'
require 'time'
require_relative 'helpers.rb'
require_relative '../cache/redis.rb'

def heartbeat(agent_name = 'CMD.BRIDGE', status = 'active', metrics = {})
  # Determine paths relative to this script
  lib_dir = File.dirname(__FILE__)
  vec3_dev_dir = File.dirname(File.dirname(lib_dir))
  vec3_dir = File.dirname(vec3_dev_dir)
  events_dir = File.join(vec3_dir, 'var', 'events')
  health_dir = File.join(vec3_dir, 'var', 'health')

  Helpers.ensure_dirs(events_dir, health_dir)

  # Collect metrics if not provided
  if metrics.empty?
    metrics = {
      timestamp: Time.now.utc.iso8601,
      sirius_time: Helpers.sirius_time(),
      uptime_seconds: calculate_uptime,
      queue_depth: get_queue_depth,
      active_operations: get_active_operations_count,
      memory_usage: get_memory_usage,
      redis_status: get_redis_status
    }
  else
    metrics[:timestamp] = Time.now.utc.iso8601
    metrics[:sirius_time] = Helpers.sirius_time()
  end

  # Create heartbeat event
  event = {
    timestamp: Time.now.utc.iso8601,
    sirius_time: Helpers.sirius_time(),
    type: 'heartbeat',
    agent: agent_name,
    status: status,
    metrics: metrics
  }

  # Append to stream.log
  stream_log = File.join(events_dir, 'stream.log')
  File.open(stream_log, 'a') do |f|
    f.puts(JSON.generate(event))
  end

  # Update health status file
  update_health_status(agent_name, status, metrics)

  # Store in Redis if available
  if RedisCache.redis_available?
    redis_key = "heartbeat:#{agent_name}:#{Time.now.to_i}"
    RedisCache.redis_set(redis_key, event, 86400) # Keep for 24 hours
  end

  # Return success
  {
    success: true,
    event: event,
    stream_log: stream_log,
    health_file: File.join(health_dir, 'status.json')
  }
end

def calculate_uptime
  # Try to read from health status file or calculate from log
  lib_dir = File.dirname(__FILE__)
  vec3_dev_dir = File.dirname(File.dirname(lib_dir))
  vec3_dir = File.dirname(vec3_dev_dir)
  health_file = File.join(vec3_dir, 'var', 'health', 'status.json')

  if File.exist?(health_file)
    content = File.read(health_file)
    begin
      data = JSON.parse(content)
      start_time_str = data.dig('metrics', 'start_time') || data.dig('start_time')
      if start_time_str
        start_time = Time.parse(start_time_str)
        (Time.now - start_time).to_i
      else
        0
      end
    rescue
      0
    end
  else
    0
  end
rescue
  0
end

def get_queue_depth
  # Count files in queue directory and Redis queues
  lib_dir = File.dirname(__FILE__)
  vec3_dev_dir = File.dirname(File.dirname(lib_dir))
  vec3_dir = File.dirname(vec3_dev_dir)
  queue_dir = File.join(vec3_dir, 'var', 'queue')

  file_count = 0
  if File.directory?(queue_dir)
    file_count = Dir.glob(File.join(queue_dir, '**', '*')).count { |f| File.file?(f) }
  end

  # Add Redis queue lengths if available
  redis_count = 0
  if RedisCache.redis_available?
    redis_count = RedisCache.queue_length('jobs') + RedisCache.queue_length('events')
  end

  file_count + redis_count
rescue
  0
end

def get_active_operations_count
  # Count active operations from various sources
  count = 0

  # Count running processes (simple heuristic)
  begin
    # Look for ruby processes related to cmd.bridge
    ps_output = `ps aux | grep -i "cmd.bridge\\|vec3" | grep -v grep | wc -l`.strip
    count += ps_output.to_i
  rescue
    # Ignore ps errors
  end

  # Count active Redis sessions
  if RedisCache.redis_available?
    sessions = RedisCache.redis_get('active_sessions') || []
    count += sessions.length if sessions.is_a?(Array)
  end

  count
rescue
  0
end

def get_memory_usage
  # Get memory usage info
  begin
    # Try to get RSS from /proc/self/status (Linux)
    if File.exist?('/proc/self/status')
      status_content = File.read('/proc/self/status')
      if status_content =~ /VmRSS:\s+(\d+)\s+kB/
        rss_kb = $1.to_i
        {
          rss_kb: rss_kb,
          rss_mb: (rss_kb / 1024.0).round(1)
        }
      else
        { rss_kb: 0, rss_mb: 0.0 }
      end
    else
      # Fallback for other systems
      { rss_kb: 0, rss_mb: 0.0, note: 'not available on this system' }
    end
  rescue
    { rss_kb: 0, rss_mb: 0.0, error: 'measurement failed' }
  end
end

def get_redis_status
  # Get Redis health status
  if RedisCache.redis_available?
    health = RedisCache.redis_health_check
    {
      available: true,
      status: health[:status],
      db_size: health[:db_size] || 0,
      response_time_ms: health[:response_time_ms] || 0
    }
  else
    {
      available: false,
      status: 'unavailable',
      note: 'redis gem not loaded'
    }
  end
end

def update_health_status(agent_name, status, metrics)
  # Calculate path: from lib/ -> vec3/dev/ops/lib/ -> vec3/dev/ -> vec3/ -> vec3/var/health/status.json
  lib_dir = File.dirname(__FILE__)
  ops_dir = File.dirname(lib_dir)
  dev_dir = File.dirname(ops_dir)
  vec3_dir = File.dirname(dev_dir)
  health_file = File.join(vec3_dir, 'var', 'health', 'status.json')

  Helpers.ensure_dirs(File.dirname(health_file))

  health_data = {
    agent: agent_name,
    status: status,
    last_heartbeat: Time.now.utc.iso8601,
    sirius_time: Helpers.sirius_time(),
    metrics: metrics.merge({
      start_time: metrics[:start_time] || Time.now.utc.iso8601
    }),
    version: '3.0.0',
    capsule_id: 'cmd.bridge.pheno.v1'
  }

  File.write(health_file, JSON.pretty_generate(health_data))

  # Also write a compact version for monitoring tools
  compact_file = File.join(File.dirname(health_file), 'status.compact.json')
  compact_data = {
    agent: agent_name,
    status: status,
    timestamp: Time.now.utc.iso8601,
    sirius_time: Helpers.sirius_time(),
    uptime: metrics[:uptime_seconds] || 0,
    queue: metrics[:queue_depth] || 0,
    redis: get_redis_status()[:status]
  }
  File.write(compact_file, JSON.generate(compact_data))
end

# Standalone execution
if __FILE__ == $0
  agent_name = ARGV[0] || 'CMD.BRIDGE'
  status = ARGV[1] || 'active'

  result = heartbeat(agent_name, status)

  if result[:success]
    puts "✓ Heartbeat recorded: #{result[:event][:timestamp]}"
    puts "  Agent: #{result[:event][:agent]}"
    puts "  Status: #{result[:event][:status]}"
    puts "  Sirius: #{result[:event][:sirius_time]}"
    puts "  Stream: #{result[:stream_log]}"
    puts "  Health: #{result[:health_file]}"
    exit 0
  else
    puts "❌ Heartbeat failed"
    exit 1
  end
end

# :: ∎