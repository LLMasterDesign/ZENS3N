# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x38D3]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // HASHER.RB ▞▞
# ▛▞// HASHER.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [merkle] [json] [kernel] [prism] [vec3] [hasher] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.hasher.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for HASHER.RB
# ```

# 


# 


#!/usr/bin/env ruby




#

#
# ▛//▞ PRISM :: KERNEL
# P:: dual.hash{internal ∙ outbound} ∙ merkle.tree
# R:: xxh128.fast ∙ sha256.crypto ∙ chain.verify
# I:: intent.target={speed.critical ∙ integrity.proof}
# S:: ingest → compute → format → emit
# M:: "xxh128:{hex}" ∙ "sha256:{hex}"
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ ingest{data.string ∙ binary}
# ⇨ ≔ compute{xxh64.dual ∙ sha256.digest}
# ⟿ ≔ format{prefix:hex ∙ concat}
# ▷ ≔ emit{hash.string}
# :: ∎
#
# ▛//▞ FUNCTIONS
# xxh128(data)       → internal.fast.hash
# sha256(data)       → outbound.crypto.hash
# dual_hash(data)    → {internal: ∙ outbound:}
# merkle_root(hashes) → tree.root.hash
# verify_chain(entries) → {valid: ∙ break_index:}
# :: ∎

require 'digest'
require 'json'

module Vec3
  module Hasher
    NATIVE_DIR = File.join(File.dirname(__FILE__), 'native')
    BINARY_PATH = File.join(NATIVE_DIR, 'target', 'release', 'hasher_cli')
    
    class << self
      # ─────────────────────────────────────────────────────────────
      # xxh128 - Internal hashing
      # ─────────────────────────────────────────────────────────────
      def xxh128(data)
        if native_available?
          call_native('xxh128', data)
        else
          # Fallback: simulate with dual MD5 (not as fast, but deterministic)
          h1 = Digest::MD5.hexdigest(data.to_s + ':0')
          h2 = Digest::MD5.hexdigest(data.to_s + ':1')
          "xxh128:#{h1}#{h2}"
        end
      end
      
      # ─────────────────────────────────────────────────────────────
      # sha256 - Outbound hashing
      # ─────────────────────────────────────────────────────────────
      def sha256(data)
        "sha256:#{Digest::SHA256.hexdigest(data.to_s)}"
      end
      
      # ─────────────────────────────────────────────────────────────
      # merkle_root - Compute Merkle tree root
      # ─────────────────────────────────────────────────────────────
      def merkle_root(hashes)
        return sha256('') if hashes.empty?
        return hashes.first if hashes.length == 1
        
        layer = hashes.dup
        
        while layer.length > 1
          next_layer = []
          layer.each_slice(2) do |pair|
            combined = if pair.length == 2
              "#{pair[0]}#{pair[1]}"
            else
              "#{pair[0]}#{pair[0]}"
            end
            next_layer << sha256(combined)
          end
          layer = next_layer
        end
        
        layer.first
      end
      
      # ─────────────────────────────────────────────────────────────
      # dual_hash - Returns both internal and outbound
      # ─────────────────────────────────────────────────────────────
      def dual_hash(data)
        {
          internal: xxh128(data),
          outbound: sha256(data)
        }
      end
      
      # ─────────────────────────────────────────────────────────────
      # verify_chain - Verify hash chain integrity
      # ─────────────────────────────────────────────────────────────
      def verify_chain(entries)
        # entries: array of {self_hash:, prev_hash:}
        return { valid: true, break_index: -1 } if entries.empty?
        
        entries.each_cons(2).with_index do |(current, next_entry), idx|
          if current[:self_hash] != next_entry[:prev_hash]
            return { valid: false, break_index: idx + 1 }
          end
        end
        
        { valid: true, break_index: -1 }
      end
      
      private
      
      def native_available?
        @native_available ||= File.exist?(BINARY_PATH) && File.executable?(BINARY_PATH)
      end
      
      def call_native(func, data)
        output = `#{BINARY_PATH} #{func} #{Shellwords.escape(data)} 2>/dev/null`.strip
        output.empty? ? nil : output
      rescue
        nil
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  require 'shellwords'
  
  case ARGV[0]
  when 'xxh128'
    puts Vec3::Hasher.xxh128(ARGV[1] || '')
  when 'sha256'
    puts Vec3::Hasher.sha256(ARGV[1] || '')
  when 'dual'
    puts JSON.pretty_generate(Vec3::Hasher.dual_hash(ARGV[1] || ''))
  when 'merkle'
    hashes = ARGV[1..] || []
    puts Vec3::Hasher.merkle_root(hashes)
  when 'test'
    data = 'Hello, 3OX!'
    puts "Testing hasher with: #{data}"
    puts "xxh128:  #{Vec3::Hasher.xxh128(data)}"
    puts "sha256:  #{Vec3::Hasher.sha256(data)}"
    puts "dual:    #{Vec3::Hasher.dual_hash(data)}"
    puts "merkle:  #{Vec3::Hasher.merkle_root([Vec3::Hasher.sha256('a'), Vec3::Hasher.sha256('b')])}"
  else
    puts "Usage: ruby hasher.rb <xxh128|sha256|dual|merkle|test> [data]"
  end
end
# :: ∎