# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xAE7F]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // TOOLS.RB.BACKUP.1768500262 ▞▞
# ▛▞// TOOLS.RB.BACKUP.1768500262 :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [tape] [json] [yaml] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.tools.rb.backup.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for TOOLS.RB.BACKUP.1768500262
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
# vec3/rc/run/tools.rb - Tool runner
# Part of 3OX.Ai (ZEN-7)
#
# Executes tools defined in tools.yml

require 'json'
require 'yaml'
require 'open3'
require_relative '../../lib/core/trace'

module Vec3
  module Run
    module Tools
      VEC3_ROOT = File.expand_path('../..', __dir__)
      OPS_DIR = File.expand_path('../../..', __dir__)
      
      class << self
        # Load tools from tools.yml
        def load_tools
          paths = [
            File.join(VEC3_ROOT, 'rc', 'config', 'tools.yml'),
            File.join(OPS_DIR, 'tools.yml')
          ]
          
          file = paths.find { |p| File.exist?(p) }
          return {} unless file
          
          @tools = YAML.safe_load(File.read(file), permitted_classes: [Symbol]) || {}
        end
        
        def tools
          @tools ||= load_tools
        end
        
        # Get a tool by ID
        def get(tool_id)
          # Handle both "tool.name" and "tool_name" formats
          tools[tool_id] || tools["tool.#{tool_id}"] || tools[tool_id.to_s.gsub('.', '_')]
        end
        
        # List all available tools
        def list
          tools.keys
        end
        
        # Run a tool
        # @param tool_id [String] the tool identifier
        # @param args [Array] arguments to pass to the tool
        # @param options [Hash] additional options
        def run(tool_id, args = [], options = {})
          tool = get(tool_id)
          
          unless tool
            return {
              status: :error,
              error: "Tool not found: #{tool_id}",
              available: list
            }
          end
          
          trace_id = Vec3::Trace.start(component: 'tools', operation: 'run', data: { tool: tool_id })
          
          begin
            result = execute_tool(tool, args, options)
            Vec3::Trace.finish(trace_id: trace_id, component: 'tools', operation: 'run', status: :ok, data: { tool: tool_id })
            result
          rescue => e
            Vec3::Trace.finish(trace_id: trace_id, component: 'tools', operation: 'run', status: :error, data: { error: e.message })
            {
              status: :error,
              error: e.message,
              tool: tool_id
            }
          end
        end
        
        private
        
        def execute_tool(tool, args, options)
          tool_config = tool.is_a?(Hash) ? tool : { 'id' => tool }
          
          command = tool_config['command']
          runtime = tool_config['runtime'] || 'ruby'
          timeout_ms = tool_config['timeout_ms'] || 5000
          permissions = extract_permissions(tool_config)
          
          if command
            # Execute external command
            execute_command(command, args, timeout_ms)
          else
            # Execute as internal tool
            execute_internal(tool_config, args, options)
          end.merge(
            permissions: permissions,
            timeout_ms: timeout_ms
          )
        end
        
        def execute_command(command, args, timeout_ms)
          full_command = [command, *args].join(' ')
          timeout_sec = timeout_ms / 1000.0
          
          stdout, stderr, status = nil
          
          begin
            Timeout.timeout(timeout_sec) do
              stdout, stderr, status = Open3.capture3(full_command)
            end
          rescue Timeout::Error
            return { status: :timeout, error: "Command timed out after #{timeout_ms}ms" }
          end
          
          {
            status: status.success? ? :ok : :error,
            stdout: stdout.strip,
            stderr: stderr.strip,
            exit_code: status.exitstatus
          }
        end
        
        def execute_internal(tool_config, args, options)
          tool_id = tool_config['id']
          
          case tool_id
          when 'file_operations'
            execute_file_operations(args, options)
          when 'text_analysis'
            execute_text_analysis(args, options)
          when 'receipt_writer'
            execute_receipt_writer(args, options)
          else
            { status: :ok, message: "Tool #{tool_id} executed (stub)", args: args }
          end
        end
        
        def execute_file_operations(args, options)
          operation = args.shift || options[:operation]
          path = args.shift || options[:path]
          
          case operation
          when 'read'
            if File.exist?(path)
              { status: :ok, content: File.read(path), size: File.size(path) }
            else
              { status: :error, error: "File not found: #{path}" }
            end
          when 'list'
            if Dir.exist?(path)
              { status: :ok, files: Dir.entries(path).reject { |f| f.start_with?('.') } }
            else
              { status: :error, error: "Directory not found: #{path}" }
            end
          when 'exists'
            { status: :ok, exists: File.exist?(path) }
          else
            { status: :error, error: "Unknown file operation: #{operation}" }
          end
        end
        
        def execute_text_analysis(args, options)
          content = args.first || options[:content] || ''
          analysis_type = options[:analysis_type] || 'basic'
          
          case analysis_type
          when 'basic'
            {
              status: :ok,
              word_count: content.split.length,
              char_count: content.length,
              line_count: content.lines.count
            }
          when 'summary'
            {
              status: :ok,
              summary: content.lines.first(3).join.strip,
              word_count: content.split.length
            }
          else
            { status: :ok, content_length: content.length }
          end
        end
        
        def execute_receipt_writer(args, options)
          receipt_data = args.first || options[:receipt] || {}
          
          if receipt_data.is_a?(String)
            receipt_data = JSON.parse(receipt_data, symbolize_names: true)
          end
          
          receipt = Vec3::TAPE.append(receipt_data)
          
          {
            status: :ok,
            receipt_id: receipt[:receipt_id],
            hash: receipt.dig(:hash, :self)
          }
        end
        
        def extract_permissions(tool_config)
          contract = tool_config['contract'] || {}
          safety = contract['safety_level'] || 'low'
          
          case safety
          when 'high'
            ['fs.read', 'fs.write']
          when 'medium'
            ['fs.read']
          else
            []
          end
        end
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  case ARGV[0]
  when 'list'
    puts Vec3::Run::Tools.list.join("\n")
  when 'run'
    tool_id = ARGV[1]
    args = ARGV[2..]
    result = Vec3::Run::Tools.run(tool_id, args)
    puts JSON.pretty_generate(result)
  when 'get'
    tool_id = ARGV[1]
    tool = Vec3::Run::Tools.get(tool_id)
    puts tool ? JSON.pretty_generate(tool) : "Tool not found: #{tool_id}"
  else
    puts "Usage: ruby tools.rb <list|run|get> [tool_id] [args...]"
  end
end

# :: ∎