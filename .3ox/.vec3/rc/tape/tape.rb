# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x0122]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // TAPE.RB ▞▞
# ▛▞// TAPE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [tape] [json] [kernel] [prism] [z3n] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.tape.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for TAPE.RB
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

module Z3N
end
# vec3/rc/tape/tape.rb - TAPE: Transit Appended Prompt Envelope
# Part of 3OX.Ai (ZEN-6)
#
# Append-only truth log for all receipts

require 'json'
require 'digest'
require 'fileutils'

module Vec3
  module TAPE
    TAPE_DIR = File.dirname(__FILE__)
    TAPE_LOG = File.join(TAPE_DIR, 'exs.log')
    MANIFEST_FILE = File.join(TAPE_DIR, 'manifest.json')
    
    class << self
      # Append a receipt to the tape
      # @param receipt [Hash] the receipt to append
      # @return [Hash] the receipt with hash fields added
      def append(receipt)
        receipt = receipt.transform_keys(&:to_sym)
        
        # Ensure required fields
        receipt[:kind] ||= 'receipt'
        receipt[:ts_end] ||= Time.now.utc.iso8601(3)
        
        # Compute self hash
        canonical = JSON.generate(receipt.sort.to_h)
        self_hash = Digest::SHA256.hexdigest(canonical)
        
        # Get previous hash
        prev_hash = last_hash
        
        # Add hash chain
        receipt[:hash] = {
          self: "sha256:#{self_hash}",
          prev: prev_hash
        }
        
        # Append to tape
        FileUtils.mkdir_p(TAPE_DIR) unless Dir.exist?(TAPE_DIR)
        File.open(TAPE_LOG, 'a') do |f|
          f.puts(JSON.generate(receipt))
          f.flush
        end
        
        receipt
      end
      
      # Create and append a receipt from an envelope
      # @param envelope [Hash] the source envelope
      # @param status [Symbol] :ok, :blocked, :error
      # @param effects [Array] side effects that occurred
      # @param outputs [Hash] output references
      # @param flags [Array] flags like !ALERT, !SPEAK
      # @param errors [Array] error objects if any
      def receipt(envelope:, status:, effects: [], outputs: {}, flags: [], errors: [], worker: {})
        envelope = envelope.transform_keys(&:to_sym)
        
        rcpt = {
          kind: 'receipt',
          receipt_id: generate_receipt_id,
          run_id: envelope[:run_id],
          envelope_id: envelope[:envelope_id],
          ts_start: envelope[:ts],
          ts_end: Time.now.utc.iso8601(3),
          status: status.to_s,
          worker: worker,
          effects: effects,
          outputs: outputs,
          flags: flags,
          severity: status == :ok ? 'info' : 'error',
          errors: errors
        }
        
        append(rcpt)
      end
      
      # Read all receipts from tape
      def read_all
        return [] unless File.exist?(TAPE_LOG)
        File.readlines(TAPE_LOG).map do |line|
          JSON.parse(line.strip, symbolize_names: true)
        rescue JSON::ParserError
          nil
        end.compact
      end
      
      # Read receipts with filter
      def read(run_id: nil, envelope_id: nil, status: nil, severity: nil, limit: nil)
        receipts = read_all
        
        receipts = receipts.select { |r| r[:run_id] == run_id } if run_id
        receipts = receipts.select { |r| r[:envelope_id] == envelope_id } if envelope_id
        receipts = receipts.select { |r| r[:status] == status.to_s } if status
        receipts = receipts.select { |r| r[:severity] == severity.to_s } if severity
        receipts = receipts.last(limit) if limit
        
        receipts
      end
      
      # Verify tape chain integrity
      def verify
        receipts = read_all
        return { valid: true, count: 0, errors: [] } if receipts.empty?
        
        errors = []
        receipts.each_with_index do |rcpt, idx|
          # Check self hash
          hash_field = rcpt.delete(:hash)
          canonical = JSON.generate(rcpt.sort.to_h)
          computed = "sha256:#{Digest::SHA256.hexdigest(canonical)}"
          rcpt[:hash] = hash_field
          
          if hash_field[:self] != computed
            errors << { index: idx, receipt_id: rcpt[:receipt_id], error: 'self_hash_mismatch' }
          end
          
          # Check prev hash chain (skip first)
          if idx > 0
            prev_rcpt = receipts[idx - 1]
            if hash_field[:prev] != prev_rcpt[:hash][:self]
              errors << { index: idx, receipt_id: rcpt[:receipt_id], error: 'chain_broken' }
            end
          end
        end
        
        {
          valid: errors.empty?,
          count: receipts.length,
          errors: errors
        }
      end
      
      # Get tape stats
      def stats
        receipts = read_all
        {
          total: receipts.length,
          ok: receipts.count { |r| r[:status] == 'ok' },
          blocked: receipts.count { |r| r[:status] == 'blocked' },
          error: receipts.count { |r| r[:status] == 'error' },
          last_receipt: receipts.last&.dig(:receipt_id),
          last_ts: receipts.last&.dig(:ts_end)
        }
      end
      
      private
      
      def last_hash
        return nil unless File.exist?(TAPE_LOG)
        last_line = File.readlines(TAPE_LOG).last&.strip
        return nil if last_line.nil? || last_line.empty?
        
        last_receipt = JSON.parse(last_line, symbolize_names: true)
        last_receipt.dig(:hash, :self)
      rescue
        nil
      end
      
      def generate_receipt_id
        ts = Time.now.strftime('%y.%j')
        seq = (rand * 10000).to_i.to_s.rjust(4, '0')
        "rcpt_#{ts}_#{seq}"
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  case ARGV[0]
  when 'stats'
    puts JSON.pretty_generate(Vec3::TAPE.stats)
  when 'verify'
    result = Vec3::TAPE.verify
    puts JSON.pretty_generate(result)
    exit(result[:valid] ? 0 : 1)
  when 'read'
    opts = {}
    opts[:run_id] = ARGV[1] if ARGV[1]
    opts[:limit] = ARGV[2].to_i if ARGV[2]
    Vec3::TAPE.read(**opts).each { |r| puts JSON.generate(r) }
  when 'tail'
    n = (ARGV[1] || 10).to_i
    Vec3::TAPE.read(limit: n).each { |r| puts JSON.generate(r) }
  else
    puts "Usage: ruby tape.rb <stats|verify|read [run_id] [limit]|tail [n]>"
  end
end
# :: ∎