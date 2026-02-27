# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x830B]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // ENVELOPE.RB.BACKUP.1768500262 ▞▞
# ▛▞// ENVELOPE.RB.BACKUP.1768500262 :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [tape] [json] [dispatch] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.envelope.rb.backup.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for ENVELOPE.RB.BACKUP.1768500262
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
# vec3/rc/run/envelope.rb - Envelope shaper
# Part of 3OX.Ai (ZEN-7)
#
# Creates valid envelopes for TAPE/Dispatch

require 'json'
require 'securerandom'
require_relative '../dispatch/law'

module Vec3
  module Run
    module Envelope
      class << self
        # Shape an envelope from parameters
        # @param op [String] the operation type
        # @param args [Hash] operation arguments
        # @param permissions [Array] required permissions
        # @param timeout_ms [Integer] timeout in milliseconds
        # @param options [Hash] additional envelope options
        def shape(op:, args: {}, permissions: [], timeout_ms: 30000, **options)
          manifest = Vec3::Dispatch::Law.manifest
          
          {
            kind: 'envelope',
            envelope_id: generate_envelope_id,
            run_id: options[:run_id] || generate_run_id,
            ts: Time.now.utc.iso8601(3),
            op: op,
            args: args,
            priority: options[:priority] || 2,
            persona: options[:persona] || 'MAIN',
            route_id: options[:route_id] || find_route(op),
            limits_hash: manifest[:limits_hash],
            tools_hash: manifest[:tools_hash],
            routes_hash: manifest[:routes_hash],
            manifest_hash: manifest[:manifest_hash],
            idempotency_key: options[:idempotency_key],
            sandbox: {
              root: options[:sandbox_root] || '!WORKDESK/tmp'
            },
            timeout_ms: timeout_ms,
            permissions: permissions,
            trace: {
              source: options[:source] || 'run.rb',
              user: options[:user] || ENV['USER'] || 'system'
            }
          }
        end
        
        # Shape envelope from JSON input
        def from_json(json_string)
          data = JSON.parse(json_string, symbolize_names: true)
          shape(**data)
        end
        
        # Shape envelope from stdin
        def from_stdin
          input = $stdin.read.strip
          from_json(input)
        end
        
        # Validate an envelope structure
        def validate(envelope)
          envelope = envelope.transform_keys(&:to_sym)
          errors = []
          
          # Required fields
          [:op, :timeout_ms].each do |field|
            errors << "Missing required field: #{field}" unless envelope[field]
          end
          
          # Type checks
          if envelope[:timeout_ms] && !envelope[:timeout_ms].is_a?(Integer)
            errors << "timeout_ms must be an integer"
          end
          
          if envelope[:permissions] && !envelope[:permissions].is_a?(Array)
            errors << "permissions must be an array"
          end
          
          {
            valid: errors.empty?,
            errors: errors,
            envelope: envelope
          }
        end
        
        private
        
        def generate_envelope_id
          ts = Time.now.strftime('%y.%j')
          seq = SecureRandom.hex(2)
          "env_#{ts}_#{seq}"
        end
        
        def generate_run_id
          ts = Time.now.strftime('%y.%j')
          hex = SecureRandom.hex(2)
          "run_#{ts}_#{hex}"
        end
        
        def find_route(op)
          case op
          when /^agent\./
            'pheno_operation'
          when /^tool\./
            'system_operation'
          when /^receipt\./
            'receipt_operation'
          else
            'fallback'
          end
        end
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  require 'time'
  
  case ARGV[0]
  when 'shape'
    op = ARGV[1] || 'default'
    envelope = Vec3::Run::Envelope.shape(op: op, args: { input: ARGV[2..].join(' ') })
    puts JSON.pretty_generate(envelope)
  when 'stdin'
    envelope = Vec3::Run::Envelope.from_stdin
    puts JSON.pretty_generate(envelope)
  when 'validate'
    envelope = JSON.parse(ARGV[1] || $stdin.read, symbolize_names: true)
    result = Vec3::Run::Envelope.validate(envelope)
    puts JSON.pretty_generate(result)
    exit(result[:valid] ? 0 : 1)
  else
    puts "Usage: ruby envelope.rb <shape|stdin|validate> [args...]"
  end
end

# :: ∎