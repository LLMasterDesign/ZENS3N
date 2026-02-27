# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x3986]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // RUN.RB.BACKUP.1768500263 ▞▞
# ▛▞// RUN.RB.BACKUP.1768500263 :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [tape] [json] [yaml] [dispatch] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.run.rb.backup.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for RUN.RB.BACKUP.1768500263
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
# vec3/rc/run/run.rb - Internal dispatcher (NOT user-facing)
# Part of 3OX.Ai (ZEN-7)
#
# This is the internal routing layer. Users interact via the 3ox CLI.
# run.rb handles: tool execution, envelope shaping, receipt emission

require 'json'
require 'yaml'
require_relative '../../lib/core/trace'
require_relative '../../lib/core/registry'
require_relative '../dispatch/dispatch'
require_relative '../tape/tape'
require_relative 'tools'
require_relative 'envelope'

module Vec3
  module Run
    VEC3_ROOT = File.expand_path('../..', __dir__)
    
    class Dispatcher
      attr_reader :trace_id
      
      def initialize
        @trace_id = Vec3::Trace.start(component: 'run', operation: 'init')
      end
      
      # Route a command to the appropriate handler
      # @param command [String] the command name
      # @param args [Array] command arguments
      # @param options [Hash] command options
      def route(command, args = [], options = {})
        Vec3::Trace.info(component: 'run', event: 'route', data: { command: command, args: args })
        
        case command
        when 'tool'
          tool_name = args.shift
          run_tool(tool_name, args, options)
        when 'agent'
          agent_name = args.shift
          invoke_agent(agent_name, args, options)
        when 'envelope'
          shape_envelope(args, options)
        when 'station'
          subcommand = args.shift
          manage_station(subcommand, args, options)
        when 'dispatch'
          dispatch_envelope(args, options)
        else
          { error: "Unknown command: #{command}", status: :error }
        end
      end
      
      # Run a tool from tools.yml
      def run_tool(tool_name, args, options = {})
        trace_id = Vec3::Trace.start(component: 'run', operation: 'tool', data: { tool: tool_name })
        
        result = Tools.run(tool_name, args, options)
        
        # Create envelope and dispatch
        envelope = Envelope.shape(
          op: 'tool.run',
          args: { tool: tool_name, tool_args: args },
          permissions: result[:permissions] || [],
          timeout_ms: result[:timeout_ms] || 5000
        )
        
        receipt = Vec3::Dispatch.process(envelope)
        
        Vec3::Trace.finish(trace_id: trace_id, component: 'run', operation: 'tool', status: receipt[:status].to_sym)
        
        {
          tool: tool_name,
          result: result,
          receipt: receipt
        }
      end
      
      # Invoke an agent
      def invoke_agent(agent_name, args, options = {})
        trace_id = Vec3::Trace.start(component: 'run', operation: 'agent', data: { agent: agent_name })
        
        envelope = Envelope.shape(
          op: 'agent.invoke',
          args: { agent: agent_name, agent_args: args },
          permissions: options[:permissions] || ['fs.read'],
          timeout_ms: options[:timeout_ms] || 30000
        )
        
        receipt = Vec3::Dispatch.process(envelope)
        
        Vec3::Trace.finish(trace_id: trace_id, component: 'run', operation: 'agent', status: receipt[:status].to_sym)
        
        receipt
      end
      
      # Shape an envelope from input
      def shape_envelope(args, options = {})
        op = options[:op] || args.shift || 'default'
        
        Envelope.shape(
          op: op,
          args: options[:args] || {},
          permissions: options[:permissions] || [],
          timeout_ms: options[:timeout_ms] || 30000
        )
      end
      
      # Dispatch an envelope (from JSON input)
      def dispatch_envelope(args, options = {})
        envelope_json = args.first || options[:envelope]
        
        if envelope_json.is_a?(String)
          envelope = JSON.parse(envelope_json, symbolize_names: true)
        else
          envelope = envelope_json
        end
        
        Vec3::Dispatch.process(envelope)
      end
      
      # Manage station lifecycle
      def manage_station(subcommand, args, options = {})
        station_id = args.first
        
        case subcommand
        when 'start'
          start_station(station_id, options)
        when 'stop'
          stop_station(station_id, options)
        when 'status'
          station_status(station_id)
        when 'list'
          list_stations
        else
          { error: "Unknown station subcommand: #{subcommand}" }
        end
      end
      
      private
      
      def start_station(station_id, options = {})
        script = File.join(VEC3_ROOT, 'rc', 'start.d', "#{station_id}.rb")
        
        if File.exist?(script)
          pid = spawn("ruby #{script}")
          Process.detach(pid)
          Vec3::Registry.register_station(id: station_id, name: station_id, path: script, status: :running)
          { station: station_id, status: :started, pid: pid }
        else
          { error: "Station start script not found: #{script}" }
        end
      end
      
      def stop_station(station_id, options = {})
        script = File.join(VEC3_ROOT, 'rc', 'stop.d', "#{station_id}.rb")
        
        if File.exist?(script)
          system("ruby #{script}")
          Vec3::Registry.update_station(station_id, status: :stopped)
          { station: station_id, status: :stopped }
        else
          # Try to stop via registry
          stn = Vec3::Registry.station(station_id)
          if stn
            Vec3::Registry.update_station(station_id, status: :stopped)
            { station: station_id, status: :stopped }
          else
            { error: "Station not found: #{station_id}" }
          end
        end
      end
      
      def station_status(station_id)
        stn = Vec3::Registry.station(station_id)
        if stn
          stn
        else
          { error: "Station not found: #{station_id}" }
        end
      end
      
      def list_stations
        Vec3::Registry.stations
      end
    end
    
    # Module-level singleton
    @dispatcher = nil
    
    class << self
      def dispatcher
        @dispatcher ||= Dispatcher.new
      end
      
      def route(command, args = [], options = {})
        dispatcher.route(command, args, options)
      end
    end
  end
end

# CLI interface (internal use only)
if __FILE__ == $0
  command = ARGV.shift
  args = ARGV.dup
  
  # Parse options
  options = {}
  args.delete_if do |arg|
    if arg.start_with?('--')
      key, value = arg[2..].split('=', 2)
      options[key.to_sym] = value || true
      true
    else
      false
    end
  end
  
  result = Vec3::Run.route(command, args, options)
  puts JSON.pretty_generate(result)
end

# :: ∎