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
require 'time'
require 'digest'
require 'fileutils'
require_relative '../../lib/core/trace'
require_relative '../../lib/core/registry'
require_relative '../dispatch/dispatch'
require_relative '../tape/tape'
require_relative 'tools'
require_relative 'envelope'

module Vec3
  module Run
    VEC3_ROOT = File.expand_path('../..', __dir__)
    CUBE_ROOT = File.expand_path('..', VEC3_ROOT)

    class BootChain
      def initialize(cube_root: CUBE_ROOT)
        @cube_root = cube_root
      end

      def boot(print_summary: true)
        booted_at = Time.now.utc.iso8601
        paths = resolve_paths

        spark = load_sparkfile(paths[:sparkfile])
        soul = load_soul(paths[:soul])
        brains = load_brains(paths[:brains])
        tools = load_tools(paths[:tools])
        limits = load_limits(paths[:limits])

        summary = {
          booted_at: booted_at,
          cube_root: @cube_root,
          identity: spark[:identity],
          purpose: soul[:purpose],
          personality: brains[:personality],
          capabilities: {
            count: tools[:capabilities].length,
            list: tools[:capabilities]
          },
          constraints: limits[:constraints],
          steps: {
            sparkfile: spark[:step],
            soul: soul[:step],
            brains: brains[:step],
            tools: tools[:step],
            limits: limits[:step]
          }
        }

        log_result = append_boot_log(paths[:pulse_dir], summary)
        summary[:log_path] = log_result[:path]
        summary[:steps][:log] = log_result[:step]
        summary[:steps][:summary] = {
          status: :ok,
          detail: 'boot summary printed to stdout'
        }

        print_boot_summary(summary) if print_summary
        summary
      end

      private

      def resolve_paths
        spark_dir = resolve_first_dir(
          File.join(@cube_root, '(1)Spark'),
          File.join(@cube_root, 'Spark'),
          @cube_root
        )
        brains_dir = resolve_first_dir(
          File.join(@cube_root, '(2)Brains'),
          File.join(@cube_root, 'Brains'),
          @cube_root
        )
        rules_dir = resolve_first_dir(
          File.join(@cube_root, '(3)Rules'),
          File.join(@cube_root, 'Rules'),
          @cube_root
        )
        tools_dir = resolve_first_dir(
          File.join(@cube_root, '(4)Toolkit/Tools'),
          File.join(@cube_root, '(4)Toolkit'),
          File.join(@cube_root, 'Toolkit/Tools'),
          @cube_root
        )
        pulse_dir = resolve_first_dir(
          File.join(@cube_root, '(6)Pulse'),
          File.join(@cube_root, 'Pulse'),
          @cube_root
        )

        {
          sparkfile: find_sparkfile(spark_dir),
          soul: File.join(spark_dir, 'soul.md'),
          brains: resolve_first_file(
            File.join(brains_dir, 'brains.rs'),
            File.join(brains_dir, 'brain.rs'),
            File.join(@cube_root, 'brains.rs'),
            File.join(@cube_root, 'brain.rs')
          ),
          tools: resolve_first_file(
            File.join(tools_dir, 'tools.yml'),
            File.join(@cube_root, 'tools.yml')
          ),
          limits: resolve_first_file(
            File.join(rules_dir, 'limits.toml'),
            File.join(@cube_root, 'limits.toml'),
            File.join(@cube_root, 'limits.json')
          ),
          pulse_dir: pulse_dir
        }
      end

      def resolve_first_dir(*candidates)
        found = candidates.find { |path| path && Dir.exist?(path) }
        found || candidates.first
      end

      def resolve_first_file(*candidates)
        candidates.find { |path| path && File.exist?(path) }
      end

      def find_sparkfile(spark_dir)
        exact = resolve_first_file(
          File.join(spark_dir, 'sparkfile.md'),
          File.join(spark_dir, 'Sparkfile.md')
        )
        return exact if exact

        drift_matches = Dir.glob(File.join(spark_dir, '*sparkfile*.md')).sort
        drift_matches.first
      end

      def load_sparkfile(path)
        return missing_step('sparkfile', path) unless path && File.exist?(path)

        content = File.read(path)
        identity = extract_identity(content, path)
        {
          identity: identity,
          step: {
            status: :ok,
            path: path,
            detail: "identity extracted: #{identity[:id]}"
          }
        }
      rescue => e
        error_step('sparkfile', path, e)
      end

      def load_soul(path)
        unless path && File.exist?(path)
          return {
            purpose: nil,
            step: {
              status: :skipped,
              path: path,
              detail: 'soul.md not found, skipped gracefully'
            }
          }
        end

        content = File.read(path)
        purpose = extract_soul_purpose(content)
        {
          purpose: purpose,
          step: {
            status: :ok,
            path: path,
            detail: purpose ? "purpose loaded: #{purpose}" : 'soul loaded (no concise purpose line found)'
          }
        }
      rescue => e
        error_step('soul', path, e).merge(purpose: nil)
      end

      def load_brains(path)
        return missing_step('brains', path).merge(personality: {}) unless path && File.exist?(path)

        content = File.read(path)
        personality = extract_personality(content)
        {
          personality: personality,
          step: {
            status: :ok,
            path: path,
            detail: "personality loaded: #{personality[:name] || 'unknown'}"
          }
        }
      rescue => e
        error_step('brains', path, e).merge(personality: {})
      end

      def load_tools(path)
        return missing_step('tools', path).merge(capabilities: []) unless path && File.exist?(path)

        content = File.read(path)
        parsed = YAML.safe_load(content, permitted_classes: [Symbol], aliases: true)
        capabilities = extract_capabilities(parsed)
        {
          capabilities: capabilities,
          step: {
            status: :ok,
            path: path,
            detail: "capabilities loaded: #{capabilities.length}"
          }
        }
      rescue => e
        error_step('tools', path, e).merge(capabilities: [])
      end

      def load_limits(path)
        return missing_step('limits', path).merge(constraints: {}) unless path && File.exist?(path)

        content = File.read(path)
        constraints = parse_limits(content)
        step_status = constraints[:valid] ? :ok : :error
        {
          constraints: constraints,
          step: {
            status: step_status,
            path: path,
            detail: constraints[:valid] ? "constraints validated (sections: #{constraints[:sections].length})" : "constraints parse issues: #{constraints[:errors].length}"
          }
        }
      rescue => e
        error_step('limits', path, e).merge(constraints: {})
      end

      def missing_step(name, path)
        {
          step: {
            status: :error,
            path: path,
            detail: "#{name} file not found"
          }
        }
      end

      def error_step(name, path, error)
        {
          step: {
            status: :error,
            path: path,
            detail: "#{name} load failed: #{error.message}"
          }
        }
      end

      def extract_identity(content, path)
        cube_id = extract_scalar(content, 'cube.id')
        version = extract_scalar(content, 'cube.version')
        runtime = extract_scalar(content, 'runtime')
        operator = content[/OPERATOR\s*::\s*([^\n▞]+)/, 1]&.strip
        identity_line = content[/IDENTITY\s*::\s*([^\n]+)/, 1]&.strip

        id = cube_id || identity_line || operator || File.basename(path, '.md')

        {
          id: id,
          version: version,
          runtime: runtime,
          source: path,
          fingerprint: Digest::SHA256.hexdigest(content)[0, 12]
        }
      end

      def extract_scalar(content, key)
        patterns = [
          /^\s*#{Regexp.escape(key)}\s*=\s*"([^"]+)"/,
          /^\s*#{Regexp.escape(key)}\s*=\s*'([^']+)'/,
          /^\s*#{Regexp.escape(key)}\s*=\s*([^\s#]+)/
        ]

        patterns.each do |pattern|
          match = content.match(pattern)
          return match[1].strip if match
        end
        nil
      end

      def extract_soul_purpose(content)
        meaningful = content.lines.map(&:strip).reject do |line|
          line.empty? || line.start_with?('::', '```', '//', '///', '▛', '▞')
        end
        first = meaningful.first
        first&.sub(/^#+\s*/, '')
      end

      def extract_personality(content)
        name = extract_scalar(content, 'name') || content[/name:\s*"([^"]+)"/, 1]
        mode = extract_scalar(content, 'mode')
        system = extract_scalar(content, 'system')
        description = extract_scalar(content, 'description')
        version = extract_scalar(content, 'version')
        brain_type = content[/brain:\s*BrainType::(\w+)/, 1]

        {
          name: name,
          mode: mode,
          system: system,
          description: description,
          version: version,
          brain_type: brain_type
        }.compact
      end

      def extract_capabilities(parsed)
        return [] unless parsed

        tools_node = if parsed.is_a?(Hash)
          parsed['tools'] || parsed[:tools]
        end

        capabilities = case tools_node
        when Hash
          tools_node.keys
        when Array
          tools_node.map do |entry|
            next unless entry
            entry['id'] || entry[:id] || entry['name'] || entry[:name] || entry.to_s
          end
        else
          []
        end

        capabilities.compact.map(&:to_s).uniq.sort
      end

      def parse_limits(content)
        sections = []
        keys = []
        errors = []
        current_section = nil
        in_array = false

        content.each_line.with_index(1) do |line, line_number|
          stripped = line.strip
          next if stripped.empty? || stripped.start_with?('#')

          if in_array
            in_array = false if stripped == ']'
            next
          end

          if stripped.start_with?('[') && stripped.end_with?(']')
            current_section = stripped[1..-2].strip
            sections << current_section
            next
          end

          if (match = stripped.match(/^([A-Za-z0-9_.-]+)\s*=\s*(.+)$/))
            key = match[1]
            value = match[2].strip
            in_array = value.end_with?('[')
            keys << {
              section: current_section,
              key: key
            }
            next
          end

          errors << "line #{line_number}: #{stripped}"
        end

        {
          valid: errors.empty?,
          sections: sections.uniq,
          key_count: keys.length,
          errors: errors
        }
      end

      def append_boot_log(pulse_dir, summary)
        FileUtils.mkdir_p(pulse_dir) unless Dir.exist?(pulse_dir)
        log_path = File.join(pulse_dir, '3ox.log')

        event = {
          ts: Time.now.utc.iso8601,
          event: 'boot.chain',
          actor: 'run.rb',
          identity: summary.dig(:identity, :id),
          soul_status: summary.dig(:steps, :soul, :status),
          capabilities: summary.dig(:capabilities, :count),
          limits_valid: summary.dig(:constraints, :valid)
        }

        File.open(log_path, 'a') { |file| file.puts(JSON.generate(event)) }
        {
          path: log_path,
          step: {
            status: :ok,
            path: log_path,
            detail: 'boot event appended to 3ox.log'
          }
        }
      rescue => e
        {
          path: File.join(pulse_dir, '3ox.log'),
          step: {
            status: :error,
            path: File.join(pulse_dir, '3ox.log'),
            detail: "log write failed: #{e.message}"
          }
        }
      end

      def print_boot_summary(summary)
        capability_preview = summary.dig(:capabilities, :list)&.first(10) || []
        preview_suffix = summary.dig(:capabilities, :count).to_i > capability_preview.length ? ' ...' : ''
        personality = summary[:personality] || {}

        puts "=== 3OX BOOT CHAIN ==="
        puts "Booted At: #{summary[:booted_at]}"
        puts "Cube Root: #{summary[:cube_root]}"
        puts
        puts "[1/7] Sparkfile Identity : #{format_step(summary.dig(:steps, :sparkfile))}"
        puts "      Identity         : #{summary.dig(:identity, :id) || 'unknown'}"
        puts "[2/7] Soul Purpose      : #{format_step(summary.dig(:steps, :soul))}"
        puts "      Purpose          : #{summary[:purpose] || '(not set)'}"
        puts "[3/7] Brains Personality: #{format_step(summary.dig(:steps, :brains))}"
        puts "      Personality      : #{personality[:name] || 'unknown'} | mode=#{personality[:mode] || 'n/a'} | system=#{personality[:system] || 'n/a'}"
        puts "[4/7] Toolkit Tools     : #{format_step(summary.dig(:steps, :tools))}"
        puts "      Capabilities     : #{summary.dig(:capabilities, :count)} -> #{capability_preview.join(', ')}#{preview_suffix}"
        puts "[5/7] Rules Limits      : #{format_step(summary.dig(:steps, :limits))}"
        puts "      Constraints      : valid=#{summary.dig(:constraints, :valid)} sections=#{summary.dig(:constraints, :sections)&.length || 0}"
        puts "[6/7] Pulse Log         : #{format_step(summary.dig(:steps, :log))}"
        puts "      Log Path          : #{summary[:log_path]}"
        puts "[7/7] Boot Summary      : #{format_step(summary.dig(:steps, :summary))}"
        puts "=== BOOT COMPLETE ==="
      end

      def format_step(step)
        return 'error (missing step metadata)' unless step

        status = step[:status] || 'unknown'
        detail = step[:detail] || ''
        "#{status} - #{detail}"
      end
    end
    
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
        when 'boot'
          run_boot_chain(options)
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

      def run_boot_chain(options = {})
        print_summary = options.fetch(:print_summary, true)
        BootChain.new.boot(print_summary: print_summary)
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
      
      def boot(print_summary: true)
        BootChain.new.boot(print_summary: print_summary)
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

  if command.nil? || command.strip.empty?
    result = Vec3::Run.boot(print_summary: true)
    puts JSON.pretty_generate(result) if options[:json]
  elsif command == 'boot'
    result = Vec3::Run.route(command, args, options)
    puts JSON.pretty_generate(result) if options[:json]
  else
    result = Vec3::Run.route(command, args, options)
    puts JSON.pretty_generate(result)
  end
end

# :: ∎