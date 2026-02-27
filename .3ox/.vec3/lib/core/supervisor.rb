# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xD545]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // SUPERVISOR.RB ▞▞
# ▛▞// SUPERVISOR.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [warden] [service] [vector] [json] [toml] [kernel] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.supervisor.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for SUPERVISOR.RB
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
##/// Last Updated: 2026.01.09 | Trace.ID: supervisor.v1.0
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.09
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [supervisor] [system] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // SUPERVISOR ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
# VEC3.SUPERVISOR.RB :: Process Lifecycle Manager
# Router-powered process supervisor with systemd-like keepalive

require 'json'
require 'time'
require 'fileutils'
require_relative 'warden.bridge'
require_relative 'registry'
require_relative '../core/trace'

module Vec3
  class Supervisor
    attr_reader :processes, :router_state_path
    
    # Find workspace root
    WORKSPACE_ROOT = begin
      candidates = [
        '/root/!LAUNCHPAD',
        '/root/!CMD.BRIDGE',
        ENV['WORKSPACE_ROOT'],
        File.expand_path('../../..', __dir__)
      ].compact.find { |path| File.directory?(File.join(path, '.3ox')) } || '/root/!LAUNCHPAD'
    end
    
    STATE_DIR = File.join(WORKSPACE_ROOT, '.3ox', 'vec3', 'var', 'state')
    ROUTER_STATE_PATH = File.join(STATE_DIR, 'router_state.json')
    SUPERVISOR_STATE_PATH = File.join(STATE_DIR, 'supervisor_state.json')
    
    def initialize
      @processes = {}  # name => {pid, config, health_history, index, last_restart, restart_count}
      @router_state_path = ROUTER_STATE_PATH
      @running = false
      @heartbeat_interval = 30  # seconds
      @max_processes = 100
      
      FileUtils.mkdir_p(STATE_DIR)
      
      # Load router bridge (Rust)
      @router_available = check_router_availability
      
      # Load stored state
      load_state if File.exist?(SUPERVISOR_STATE_PATH)
      
      Vec3::Trace.info(component: 'supervisor', event: 'init', data: { router_available: @router_available })
    end
    
    def check_router_availability
      router_rs = File.expand_path('../../ARC.Logic.Core/src/router.rs', __FILE__)
      # Check if router Rust crate exists
      cargo_toml = File.expand_path('../../ARC.Logic.Core/Cargo.toml', __FILE__)
      File.exist?(cargo_toml)
    rescue
      false
    end
    
    # Register process for supervision
    def supervise(process_name, config = {})
      trace_id = Vec3::Trace.start(component: 'supervisor', operation: 'supervise', data: { process: process_name })
      
      begin
        # Check permissions via Warden (Elixir)
        unless check_start_permission(process_name, config)
          Vec3::Trace.error(component: 'supervisor', event: 'denied', data: { process: process_name })
          Vec3::Trace.finish(trace_id: trace_id, component: 'supervisor', operation: 'supervise', status: :denied, data: { reason: 'warden_denied' })
          return { error: "Warden denied permission to start #{process_name}" }
        end
        
        index = @processes.size
        
        # Start process
        script = config[:script] || find_process_script(process_name)
        unless script && File.exist?(script)
          Vec3::Trace.finish(trace_id: trace_id, component: 'supervisor', operation: 'supervise', status: :error, data: { error: 'script_not_found' })
          return { error: "Process script not found: #{script || process_name}" }
        end
        
        pid = start_process(script, config)
        
        @processes[process_name] = {
          index: index,
          pid: pid,
          config: config.merge(script: script),
          health_history: [],
          last_restart: Time.now,
          restart_count: 0,
          started_at: Time.now
        }
        
        # Register with Router (if available)
        register_with_router(process_name, index) if @router_available
        
        # Register with Registry
        Vec3::Registry.register_service(process_name, pid: pid, status: :running) rescue nil
        
        Vec3::Trace.info(component: 'supervisor', event: 'supervise', data: { process: process_name, pid: pid })
        Vec3::Trace.finish(trace_id: trace_id, component: 'supervisor', operation: 'supervise', status: :ok, data: { process: process_name, pid: pid })
        
        { process: process_name, pid: pid, status: :supervised }
      rescue => e
        Vec3::Trace.finish(trace_id: trace_id, component: 'supervisor', operation: 'supervise', status: :error, data: { error: e.message })
        raise
      end
    end
    
    # Check permissions via Warden
    def check_start_permission(process_name, config)
      operation = [:start_process, process_name]
      context = {
        user: ENV['USER'] || 'unknown',
        workspace: WORKSPACE_ROOT,
        current_path: Dir.pwd
      }
      
      result = Vec3::Warden.check_permission(operation, context)
      result[:allow] || result["allow"] || false
    rescue => e
      warn "Warden check failed: #{e.message}"
      true  # Fail open for now
    end
    
    # Main monitoring loop
    def monitor_loop
      @running = true
      trace_id = Vec3::Trace.start(component: 'supervisor', operation: 'monitor_loop', data: { process_count: @processes.size })
      Vec3::Trace.info(component: 'supervisor', event: 'monitor_start')
      
      puts "▛▞// Supervisor started"
      puts "▛▞// Monitoring #{@processes.size} processes"
      puts "▛▞// Heartbeat interval: #{@heartbeat_interval}s"
      
      begin
        while @running
          begin
            monitor_processes
            store_state
            sleep @heartbeat_interval
          rescue => e
            Vec3::Trace.error(component: 'supervisor', event: 'monitor_error', data: { error: e.message })
            sleep 5  # Brief pause on error
          end
        end
        
        Vec3::Trace.finish(trace_id: trace_id, component: 'supervisor', operation: 'monitor_loop', status: :ok, data: { stopped: true })
      rescue => e
        Vec3::Trace.finish(trace_id: trace_id, component: 'supervisor', operation: 'monitor_loop', status: :error, data: { error: e.message })
        raise
      ensure
        cleanup
      end
    end
    
    def stop
      @running = false
    end
    
    private
    
    def monitor_processes
      @processes.each do |name, proc_info|
        # Check process health
        health = check_health(proc_info[:pid])
        proc_info[:health_history] << { time: Time.now, health: health }
        proc_info[:health_history].shift if proc_info[:health_history].size > 100  # Keep last 100
        
        # Update router activation (if router available)
        if @router_available
          update_router_activation(proc_info[:index], health)
          
          # Check for drift (via router)
          if router_drift_detected?(proc_info)
            Vec3::Trace.warn(component: 'supervisor', event: 'drift_detected', data: { process: name })
            restart_process(name, proc_info)
          end
        else
          # Fallback: simple health threshold
          if health < 0.3
            restart_process(name, proc_info)
          end
        end
        
        # Compute heat from process state
        heat = compute_process_heat(proc_info)
        
        # Adjust process parameters based on heat (if router available)
        if @router_available
          apply_heat_to_router(heat)
        end
      end
    end
    
    def check_health(pid)
      return 0.0 unless process_alive?(pid)
      
      # Check resource usage (basic)
      begin
        # Check if process responds (simple check)
        Process.kill(0, pid)
        
        # Basic health score (could be enhanced with actual resource monitoring)
        health = 1.0
        
        # Check process age (older processes might have issues)
        # This is a placeholder - real implementation would check memory, CPU, response time
        
        health.clamp(0.0, 1.0)
      rescue Errno::ESRCH
        0.0  # Process dead
      rescue => e
        warn "Health check error for PID #{pid}: #{e.message}"
        0.5  # Unknown state
      end
    end
    
    def process_alive?(pid)
      Process.kill(0, pid)
      true
    rescue Errno::ESRCH
      false
    rescue => e
      warn "Process check error: #{e.message}"
      false
    end
    
    def router_drift_detected?(proc_info)
      # Check router state for drift
      # This would call Rust router's drift detection
      # For now, simple threshold check
      health = proc_info[:health_history].last&.[](:health) || 1.0
      health < 0.5  # Simple threshold
    end
    
    def update_router_activation(index, health)
      # Update router activation vector
      # This would call Rust router
      # Placeholder for now
    end
    
    def apply_heat_to_router(heat)
      # Apply heat to router parameters
      # This would call Rust router's apply_heat
      # Placeholder for now
    end
    
    def compute_process_heat(proc_info)
      # Compute heat from process state (DERIVED.C1)
      missing_slots = 0
      verify_mismatch = 0.0
      conflict_count = 0
      risk_flag = proc_info[:restart_count] > 5
      unknown_ratio = 0.0
      
      # Basic heat computation
      heat = 0.0
      heat += 0.2 if proc_info[:restart_count] > 0
      heat += 0.3 if risk_flag
      heat = heat.clamp(0.0, 1.0)
    end
    
    def restart_process(name, proc_info)
      trace_id = Vec3::Trace.start(component: 'supervisor', operation: 'restart_process', data: { process: name, pid: proc_info[:pid] })
      Vec3::Trace.warn(component: 'supervisor', event: 'restart', data: { process: name, pid: proc_info[:pid] })
      
      begin
        # Stop old process
        begin
          Process.kill('TERM', proc_info[:pid])
          sleep(backoff_delay(proc_info))
          Process.kill('KILL', proc_info[:pid]) rescue nil  # Force kill if still alive
        rescue Errno::ESRCH
          # Already dead
        end
        
        # Start new process
        new_pid = start_process(proc_info[:config][:script], proc_info[:config])
        proc_info[:pid] = new_pid
        proc_info[:last_restart] = Time.now
        proc_info[:restart_count] += 1
        
        # Update registry
        Vec3::Registry.update_service(name, pid: new_pid, status: :running) rescue nil
        
        Vec3::Trace.info(component: 'supervisor', event: 'restarted', data: { process: name, new_pid: new_pid })
        Vec3::Trace.finish(trace_id: trace_id, component: 'supervisor', operation: 'restart_process', status: :ok, data: { process: name, new_pid: new_pid, restart_count: proc_info[:restart_count] })
        
        puts "  → Restarted #{name} (PID: #{new_pid}, restart count: #{proc_info[:restart_count]})"
      rescue => e
        Vec3::Trace.finish(trace_id: trace_id, component: 'supervisor', operation: 'restart_process', status: :error, data: { error: e.message })
        raise
      end
    end
    
    def backoff_delay(proc_info)
      # Heat-based backoff (DERIVED.C2)
      base_delay = 1.0
      heat = compute_process_heat(proc_info)
      delay = base_delay * (1.0 + heat * 5.0)  # Max 6 seconds at heat=1.0
      delay.clamp(1.0, 10.0)
    end
    
    def start_process(script, config)
      # Start process in background
      pid = spawn("ruby #{script}")
      Process.detach(pid)
      pid
    end
    
    def find_process_script(process_name)
      # Look for start script
      start_script = File.join(WORKSPACE_ROOT, '.3ox', 'vec3', 'rc', 'start.d', "#{process_name}.rb")
      return start_script if File.exist?(start_script)
      
      nil
    end
    
    def register_with_router(process_name, index)
      # Register process with Router (Rust)
      # Placeholder - would call Rust router
    end
    
    def store_state
      state = {
        processes: @processes.transform_values { |p| p.slice(:index, :config, :restart_count) },
        timestamp: Time.now.iso8601
      }
      
      File.write(SUPERVISOR_STATE_PATH, JSON.pretty_generate(state))
    rescue => e
      warn "Failed to store supervisor state: #{e.message}"
    end
    
    def load_state
      return unless File.exist?(SUPERVISOR_STATE_PATH)
      
      state = JSON.parse(File.read(SUPERVISOR_STATE_PATH), symbolize_names: true)
      # Restore process metadata (but not PIDs - those need restart)
      # Placeholder for now
    rescue => e
      warn "Failed to load supervisor state: #{e.message}"
    end
    
    def cleanup
      Vec3::Trace.info(component: 'supervisor', event: 'monitor_stop', data: { processes_supervised: @processes.size })
      store_state
      puts "▛▞// Supervisor stopped"
    end
  end
  
  # Singleton instance
  @supervisor = nil
  
  def self.instance
    @supervisor ||= Supervisor.new
  end
end

# CLI entry point
if __FILE__ == $0
  require 'optparse'
  
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: supervisor.rb [options]"
    
    opts.on("-s", "--start PROCESS", "Start supervising a process") do |process|
      options[:start] = process
    end
    
    opts.on("-m", "--monitor", "Start monitoring loop") do
      options[:monitor] = true
    end
    
    opts.on("-l", "--list", "List supervised processes") do
      options[:list] = true
    end
  end.parse!
  
  supervisor = Vec3::Supervisor.instance
  
  if options[:start]
    result = supervisor.supervise(options[:start])
    puts result.inspect
  elsif options[:monitor]
    trap('INT') { supervisor.stop }
    trap('TERM') { supervisor.stop }
    supervisor.monitor_loop
  elsif options[:list]
    supervisor.processes.each do |name, proc_info|
      puts "#{name}: PID=#{proc_info[:pid]}, Restarts=#{proc_info[:restart_count]}"
    end
  else
    puts "Usage: supervisor.rb --start PROCESS | --monitor | --list"
  end
end
# :: ∎