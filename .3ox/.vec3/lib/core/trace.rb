# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x5D85]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // TRACE.RB ▞▞
# ▛▞// TRACE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [warden] [vector] [json] [dispatch] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.trace.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for TRACE.RB
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
##/// Last Updated: 2026.01.09 | Trace.ID: trace.v1.0
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.09
#```elixir
# vec3/core/trace.rb - Vector tracing and explicit logging
# Part of 3OX.Ai OS Core (ZEN-5)

require 'json'
require 'time'
require 'date'
require 'digest'
require 'fileutils'

module Vec3
  module Trace
    # This file lives at vec3/lib/core/trace.rb → vec3 root is two levels up.
    VEC3_ROOT = File.expand_path('../..', __dir__)  # vec3/lib/core -> vec3/
    LOG_DIR = File.join(VEC3_ROOT, 'var', 'log')
    TRACE_LOG = File.join(LOG_DIR, 'vec3.trace.log')
    
    # Severity levels
    LEVELS = {
      debug: 0,
      info: 1,
      warn: 2,
      error: 3,
      critical: 4
    }.freeze
    
    # Minimum level to log (can be overridden via ENV)
    MIN_LEVEL = LEVELS[ENV.fetch('VEC3_LOG_LEVEL', 'info').to_sym] || 1
    
    class << self
      # Generate trace ID (xxh64-style, 16 hex chars)
      def trace_id
        seed = "#{Process.pid}|#{Thread.current.object_id}|#{Time.now.to_f}"
        Digest::SHA256.hexdigest(seed)[0..15]
      end
      
      # Log a trace event
      # @param level [Symbol] :debug, :info, :warn, :error, :critical
      # @param component [String] e.g., "warden", "dispatch", "run.rb"
      # @param event [String] e.g., "envelope.validated", "receipt.appended"
      # @param data [Hash] additional structured data
      # @param trace_id [String] optional trace correlation ID
      def log(level:, component:, event:, data: {}, trace_id: nil)
        return if LEVELS[level] < MIN_LEVEL
        
        entry = {
          ts: Time.now.utc.iso8601(3),
          level: level.to_s,
          trace_id: trace_id || self.trace_id,
          component: component,
          event: event,
          pid: Process.pid,
          data: data
        }
        
        append_log(entry)
        entry
      end
      
      # Convenience methods
      def debug(component:, event:, **opts)
        log(level: :debug, component: component, event: event, **opts)
      end
      
      def info(component:, event:, **opts)
        log(level: :info, component: component, event: event, **opts)
      end
      
      def warn(component:, event:, **opts)
        log(level: :warn, component: component, event: event, **opts)
      end
      
      def error(component:, event:, **opts)
        log(level: :error, component: component, event: event, **opts)
      end
      
      def critical(component:, event:, **opts)
        log(level: :critical, component: component, event: event, **opts)
      end
      
      # Start a traced operation (returns trace_id for correlation)
      def start(component:, operation:, data: {})
        tid = trace_id
        log(level: :info, component: component, event: "#{operation}.start", data: data, trace_id: tid)
        tid
      end
      
      # End a traced operation
      def finish(trace_id:, component:, operation:, status:, data: {})
        log(
          level: status == :ok ? :info : :error,
          component: component,
          event: "#{operation}.finish",
          data: data.merge(status: status.to_s),
          trace_id: trace_id
        )
      end
      
      private
      
      def append_log(entry)
        FileUtils.mkdir_p(LOG_DIR) unless Dir.exist?(LOG_DIR)
        
        # Log to trace log
        File.open(TRACE_LOG, 'a') do |f|
          f.puts(JSON.generate(entry))
          f.flush
        end
        
        # Also log to PDS for critical operations and core components
        if [:error, :critical].include?(entry[:level].to_sym) || 
           entry[:event].to_s.include?('.finish') ||
           ['supervisor', 'warden', 'router', 'registry'].include?(entry[:component].to_s)
          append_pds_log(entry)
        end
      rescue => e
        $stderr.puts "[Vec3::Trace] Failed to write log: #{e.message}"
      end
      
      def append_pds_log(entry)
        # Log critical operations to PDS
        # PDS = Project Definition Statement / Persistent Documentation System
        pds_dir = File.join(VEC3_ROOT, '..', '..', '!CMD.CENTER', '!CMD.OPS', 'Logbook', 'PDS')
        FileUtils.mkdir_p(pds_dir) unless Dir.exist?(pds_dir)
        
        pds_file = File.join(pds_dir, "operations_#{Date.today.strftime('%Y.%m.%d')}.log")
        
        log_line = "[#{entry[:ts]}] [#{entry[:level]}] [#{entry[:component]}] #{entry[:event]}: #{entry[:data].to_json}"
        
        File.open(pds_file, 'a') do |f|
          f.puts(log_line)
          f.flush
        end
      rescue => e
        # Don't fail if PDS logging fails - it's supplementary
        $stderr.puts "[Vec3::Trace] Failed to write PDS log: #{e.message}"
      end
    end
  end
end

# Shorthand
def trace
  Vec3::Trace
end
# :: ∎
