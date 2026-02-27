# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x8725]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // IDEMPOTENCY.RB.BACKUP.1768500265 ▞▞
# ▛▞// IDEMPOTENCY.RB.BACKUP.1768500265 :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [dispatch] [kernel] [prism] [vec3] [idempotency] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.idempotency.rb.backup.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for IDEMPOTENCY.RB.BACKUP.1768500265
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
# vec3/rc/dispatch/idempotency.rb - Idempotency store
# Part of 3OX.Ai (ZEN-6)
#
# Prevents duplicate side effects during retries

require 'json'
require 'fileutils'
require 'digest'

module Vec3
  module Dispatch
    module Idempotency
      VEC3_ROOT = File.expand_path('../..', __dir__)
      STATE_DIR = File.join(VEC3_ROOT, 'var', 'state')
      IDEM_FILE = File.join(STATE_DIR, 'idempotency.json')
      
      # Default TTL: 24 hours
      DEFAULT_TTL = 86400
      
      class << self
        # Check if key exists and is not expired
        # @param key [String] the idempotency key
        # @return [Hash, nil] the stored receipt or nil
        def check(key)
          store = load_store
          entry = store[key]
          return nil unless entry
          
          # Check TTL
          if entry['expires_at'] && Time.parse(entry['expires_at']) < Time.now
            delete(key)
            return nil
          end
          
          entry['receipt']
        end
        
        # Store key with receipt
        # @param key [String] the idempotency key
        # @param receipt [Hash] the receipt to store
        # @param ttl [Integer] TTL in seconds (default 24h)
        def store(key, receipt, ttl: DEFAULT_TTL)
          store_data = load_store
          
          store_data[key] = {
            'receipt_id' => receipt[:receipt_id] || receipt['receipt_id'],
            'status' => receipt[:status] || receipt['status'],
            'receipt' => receipt,
            'created_at' => Time.now.utc.iso8601,
            'expires_at' => (Time.now + ttl).utc.iso8601
          }
          
          save_store(store_data)
        end
        
        # Delete a key
        def delete(key)
          store_data = load_store
          store_data.delete(key)
          save_store(store_data)
        end
        
        # Cleanup expired entries
        def cleanup
          store_data = load_store
          now = Time.now
          
          expired = store_data.select do |_, entry|
            entry['expires_at'] && Time.parse(entry['expires_at']) < now
          end
          
          expired.keys.each { |k| store_data.delete(k) }
          save_store(store_data)
          
          { cleaned: expired.length, remaining: store_data.length }
        end
        
        # Get stats
        def stats
          store_data = load_store
          now = Time.now
          
          active = store_data.count do |_, entry|
            !entry['expires_at'] || Time.parse(entry['expires_at']) >= now
          end
          
          {
            total: store_data.length,
            active: active,
            expired: store_data.length - active
          }
        end
        
        private
        
        def load_store
          FileUtils.mkdir_p(STATE_DIR)
          return {} unless File.exist?(IDEM_FILE)
          JSON.parse(File.read(IDEM_FILE))
        rescue JSON::ParserError
          {}
        end
        
        def save_store(data)
          FileUtils.mkdir_p(STATE_DIR)
          File.write(IDEM_FILE, JSON.pretty_generate(data))
        end
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  require 'time'
  
  case ARGV[0]
  when 'check'
    key = ARGV[1]
    result = Vec3::Dispatch::Idempotency.check(key)
    if result
      puts JSON.pretty_generate(result)
    else
      puts "Key not found or expired"
      exit 1
    end
  when 'store'
    key = ARGV[1]
    receipt = JSON.parse(ARGV[2] || STDIN.read)
    Vec3::Dispatch::Idempotency.store(key, receipt)
    puts "Stored: #{key}"
  when 'cleanup'
    result = Vec3::Dispatch::Idempotency.cleanup
    puts JSON.pretty_generate(result)
  when 'stats'
    puts JSON.pretty_generate(Vec3::Dispatch::Idempotency.stats)
  else
    puts "Usage: ruby idempotency.rb <check|store|cleanup|stats> [args]"
  end
end

# :: ∎