# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x5D5D]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // DISPATCH.RB.BACKUP.1768500264 ▞▞
# ▛▞// DISPATCH.RB.BACKUP.1768500264 :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [tape] [json] [dispatch] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.dispatch.rb.backup.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for DISPATCH.RB.BACKUP.1768500264
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
# vec3/rc/dispatch/dispatch.rb - Main Dispatch controller
# Part of 3OX.Ai (ZEN-6)
#
# Validates envelopes, executes workers, produces receipts

require 'json'
require 'timeout'
require 'open3'
require 'fileutils'
require_relative '../../lib/core/trace'
require_relative '../../lib/core/registry'
require_relative '../tape/tape'
require_relative 'law'
require_relative '../responder/responder'
require_relative 'idempotency'
require_relative '../../lib/core/llm'

module Vec3
  module Dispatch
    class Controller
      attr_reader :law, :trace_id
      
      def initialize
        @law = Law.load_all
        @trace_id = Vec3::Trace.start(component: 'dispatch', operation: 'init')
        Vec3::Trace.info(component: 'dispatch', event: 'law.loaded', data: { manifest: @law[:manifest][:manifest_hash] })
      end
      
      # Process an envelope
      # @param envelope [Hash] the envelope to process
      # @return [Hash] the receipt
      def process(envelope)
        envelope = envelope.transform_keys(&:to_sym)
        envelope[:envelope_id] ||= generate_envelope_id
        envelope[:run_id] ||= generate_run_id
        envelope[:ts] ||= Time.now.utc.iso8601(3)
        
        trace_id = Vec3::Trace.start(
          component: 'dispatch',
          operation: 'process',
          data: { envelope_id: envelope[:envelope_id] }
        )
        
        # Step 1: Validate against law
        validation = Law.validate_envelope(envelope)
        
        unless validation[:valid]
          receipt = blocked_receipt(envelope, validation[:errors])
          Vec3::Trace.finish(trace_id: trace_id, component: 'dispatch', operation: 'process', status: :blocked)
          handle_responders(receipt)
          return receipt
        end
        
        # Step 2: Check idempotency
        if envelope[:idempotency_key]
          existing = check_idempotency(envelope[:idempotency_key])
          if existing
            Vec3::Trace.info(component: 'dispatch', event: 'idempotency.hit', data: { key: envelope[:idempotency_key] })
            return existing
          end
        end
        
        # Step 3: Execute
        begin
          result = execute(envelope)
          receipt = success_receipt(envelope, result)
        rescue Timeout::Error => e
          receipt = error_receipt(envelope, [{ code: 'timeout', msg: e.message }])
        rescue => e
          receipt = error_receipt(envelope, [{ code: 'runtime_error', msg: e.message }])
        end
        
        # Step 4: Store idempotency
        if envelope[:idempotency_key]
          store_idempotency(envelope[:idempotency_key], receipt)
        end
        
        # Step 5: Handle responders
        handle_responders(receipt)
        
        Vec3::Trace.finish(
          trace_id: trace_id,
          component: 'dispatch',
          operation: 'process',
          status: receipt[:status].to_sym,
          data: { receipt_id: receipt[:receipt_id] }
        )
        
        receipt
      end
      
      # Execute envelope payload
      def execute(envelope)
        timeout_ms = envelope[:timeout_ms] || 30000
        timeout_sec = timeout_ms / 1000.0
        
        Timeout.timeout(timeout_sec) do
          case envelope[:op]
          when 'agent.invoke'
            execute_agent(envelope)
          when 'tool.run'
            execute_tool(envelope)
          when 'responder.invoke'
            execute_responder(envelope)
          else
            execute_default(envelope)
          end
        end
      end
      
      private
      
      def execute_agent(envelope)
        args = envelope[:args] || {}
        agent = args[:agent] || args['agent']
        
        Vec3::Trace.info(component: 'dispatch', event: 'agent.invoke', data: { agent: agent })
        
        # Minimal brain: agent=think uses Vec3::LLM (network allowed when envelope permissions include net.http).
        if agent.to_s.strip.downcase == 'think'
          prompt = (args[:prompt] || args['prompt']).to_s
          result = Vec3::LLM.call(prompt: prompt)
          if result[:error]
            raise "LLM error: #{result[:error]}"
          end

          {
            agent: 'think',
            status: 'executed',
            outputs: { summary: (result[:content] || '').to_s }
          }
        elsif agent.to_s.strip.downcase == 'codex53'
          execute_codex53_agent(args)
        else
          # TODO: Wire to actual agent runner
          {
            agent: agent,
            status: 'executed',
            outputs: { ref: 'agent_output.txt' }
          }
        end
      end

      def execute_codex53_agent(args)
        base_root = File.expand_path('../../../..', __dir__)
        worktree = ENV.fetch('CODEX53_WORKTREE', File.join(base_root, '!WORKDESK', 'codex53-work'))

        unless Dir.exist?(worktree)
          raise "codex53 worktree missing: #{worktree}. Start service with `3ox start codex53` first."
        end

        prompt = (args[:prompt] || args['prompt']).to_s
        if prompt.strip.empty?
          prompt = Array(args[:agent_args] || args['agent_args']).join(' ').strip
        end
        raise 'codex53 prompt is empty' if prompt.empty?

        codex_home = File.join(base_root, '.3ox', 'Pulse', 'codex53', 'codex_home')
        FileUtils.mkdir_p(codex_home)
        last_message_file = File.join(base_root, '.3ox', 'Pulse', 'codex53', 'state', 'agent_invoke_last_message.txt')
        FileUtils.mkdir_p(File.dirname(last_message_file))
        agent_timeout_sec = Integer(ENV.fetch('CODEX53_AGENT_TIMEOUT_SEC', '25'))

        cmd = [
          'env', "CODEX_HOME=#{codex_home}",
          'timeout', '--signal=TERM', "#{agent_timeout_sec}s",
          'codex', 'exec',
          '--cd', worktree,
          '--skip-git-repo-check',
          '--output-last-message', last_message_file,
          prompt
        ]

        stdout, stderr, status = Open3.capture3(*cmd)
        summary = File.exist?(last_message_file) ? File.read(last_message_file) : stdout
        FileUtils.rm_f(last_message_file)
        timed_out = (status.exitstatus == 124)

        {
          agent: 'codex53',
          status: status.success? ? 'executed' : 'error',
          outputs: {
            summary: summary.to_s,
            exit_code: status.exitstatus,
            timed_out: timed_out,
            stderr: stderr.to_s
          }
        }
      end
      
      def execute_tool(envelope)
        args = envelope[:args] || {}
        tool_id = args[:tool] || args['tool']
        
        Vec3::Trace.info(component: 'dispatch', event: 'tool.run', data: { tool: tool_id })
        
        # TODO: Wire to tool runner
        {
          tool: tool_id,
          status: 'executed',
          outputs: {}
        }
      end
      
      def execute_responder(envelope)
        args = envelope[:args] || {}
        responder = args[:responder] || args['responder']
        cause = args[:cause_receipt] || args['cause_receipt']
        
        Vec3::Trace.info(component: 'dispatch', event: 'responder.invoke', data: { responder: responder, cause: cause })
        
        Responder.invoke(responder, cause)
      end
      
      def execute_default(envelope)
        Vec3::Trace.info(component: 'dispatch', event: 'default.execute', data: { op: envelope[:op] })
        { status: 'executed', op: envelope[:op] }
      end
      
      def blocked_receipt(envelope, errors)
        Vec3::TAPE.receipt(
          envelope: envelope,
          status: :blocked,
          effects: [],
          outputs: { summary: 'blocked by validator' },
          flags: ['!ALERT', '!BLOCKED'],
          errors: errors
        )
      end
      
      def success_receipt(envelope, result)
        effects = result[:effects] || []
        outputs = result[:outputs] || result
        flags = result[:flags] || []
        
        Vec3::TAPE.receipt(
          envelope: envelope,
          status: :ok,
          effects: effects,
          outputs: outputs,
          flags: flags,
          errors: [],
          worker: { type: 'dispatch', version: '1.0.0', pid: Process.pid }
        )
      end
      
      def error_receipt(envelope, errors)
        Vec3::TAPE.receipt(
          envelope: envelope,
          status: :error,
          effects: [],
          outputs: { summary: 'execution failed' },
          flags: ['!ALERT'],
          errors: errors
        )
      end
      
      def handle_responders(receipt)
        flags = receipt[:flags] || []
        
        if flags.include?('!ALERT')
          Responder.alert(receipt)
        end
        
        if flags.include?('!SPEAK')
          Responder.speak(receipt)
        end
      end
      
      def check_idempotency(key)
        Idempotency.check(key)
      end
      
      def store_idempotency(key, receipt)
        Idempotency.store(key, receipt)
      end
      
      def generate_envelope_id
        ts = Time.now.strftime('%y.%j')
        seq = (rand * 10000).to_i.to_s.rjust(4, '0')
        "env_#{ts}_#{seq}"
      end
      
      def generate_run_id
        ts = Time.now.strftime('%y.%j')
        hex = SecureRandom.hex(2)
        "run_#{ts}_#{hex}"
      end
    end
    
    # Module-level singleton
    @controller = nil
    
    class << self
      def controller
        @controller ||= Controller.new
      end
      
      def process(envelope)
        controller.process(envelope)
      end
      
      def reload!
        @controller = nil
        controller
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  require 'securerandom'
  
  case ARGV[0]
  when 'process'
    envelope_json = ARGV[1] || STDIN.read
    envelope = JSON.parse(envelope_json, symbolize_names: true)
    receipt = Vec3::Dispatch.process(envelope)
    puts JSON.pretty_generate(receipt)
  when 'test'
    # Test envelope
    envelope = {
      op: 'agent.invoke',
      args: { agent: 'TestAgent' },
      permissions: ['fs.read'],
      timeout_ms: 5000
    }
    receipt = Vec3::Dispatch.process(envelope)
    puts JSON.pretty_generate(receipt)
  else
    puts "Usage: ruby dispatch.rb <process|test> [envelope_json]"
  end
end

# :: ∎
