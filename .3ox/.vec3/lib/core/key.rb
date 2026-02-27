# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x3590]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // KEY.RB ▞▞
# ▛▞// KEY.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [vec3] [key] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.key.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for KEY.RB
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
# frozen_string_literal: true

module Z3N
  SPEC = {
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // KEY ▞▞',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [key] [system] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.04
##/// Last Updated: 2026.01.04 | Trace.ID: key.v1.0
##/// Purpose: !/usr/bin/env ruby
##///          (Add second line of purpose here)
##///          (Add third line of purpose here)
#```
#
#▛//▞ TOOLSET ::
#(Add toolset commands here)
#/command1 = description1
#/command2 = description2

###▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂###
#
# Part of 3OX.Ai (ZEN-10)
# Handles license key generation, validation, and revocation

require 'openssl'
require 'base64'
require 'json'
require 'time'

module Vec3
  module Key
    KEYS_DIR = File.expand_path('../../keys', __dir__)
    SECRET = ENV.fetch('KEY_SECRET', 'cmd.bridge.default.secret.2026')

    # 3ox.key format:
    # {
    #   "version": "1.0",
    #   "base_id": "CMD",
    #   "agent_id": "agent_01",
    #   "issued_at": "2026-01-04T07:50:00Z",
    #   "expires_at": "2027-01-04T07:50:00Z",
    #   "permissions": ["read", "write", "execute"],
    #   "slot": "permanent",
    #   "signature": "sha256hmac..."
    # }

    class License
      attr_reader :base_id, :agent_id, :issued_at, :expires_at, :permissions, :slot, :signature

      def initialize(data)
        @version = data['version'] || '1.0'
        @base_id = data['base_id']
        @agent_id = data['agent_id']
        @issued_at = Time.parse(data['issued_at'])
        @expires_at = data['expires_at'] ? Time.parse(data['expires_at']) : nil
        @permissions = data['permissions'] || []
        @slot = data['slot'] || 'temporary'
        @signature = data['signature']
      end

      def valid?
        return false if revoked?
        return false if expired?
        verify_signature
      end

      def expired?
        return false unless @expires_at
        Time.now > @expires_at
      end

      def revoked?
        revoke_file = File.join(KEYS_DIR, "#{@base_id}.#{@agent_id}.revoked")
        File.exist?(revoke_file)
      end

      def verify_signature
        computed = compute_signature
        secure_compare(computed, @signature)
      end

      def compute_signature
        payload = "#{@version}|#{@base_id}|#{@agent_id}|#{@issued_at.iso8601}|#{@slot}"
        OpenSSL::HMAC.hexdigest('SHA256', SECRET, payload)
      end

      def to_h
        {
          'version' => @version,
          'base_id' => @base_id,
          'agent_id' => @agent_id,
          'issued_at' => @issued_at.iso8601,
          'expires_at' => @expires_at&.iso8601,
          'permissions' => @permissions,
          'slot' => @slot,
          'signature' => @signature
        }
      end

      def to_json
        JSON.pretty_generate(to_h)
      end

      private

      def secure_compare(a, b)
        return false if a.nil? || b.nil?
        return false if a.bytesize != b.bytesize
        
        l = a.unpack("C*")
        r = b.unpack("C*")
        result = 0
        l.zip(r) { |x, y| result |= x ^ y }
        result == 0
      end
    end

    class Generator
      def self.generate(base_id:, agent_id:, permissions: [], slot: 'permanent', expires_in: nil)
        now = Time.now.utc
        expires_at = expires_in ? now + expires_in : nil

        license = License.new({
          'version' => '1.0',
          'base_id' => base_id,
          'agent_id' => agent_id,
          'issued_at' => now.iso8601,
          'expires_at' => expires_at&.iso8601,
          'permissions' => permissions,
          'slot' => slot,
          'signature' => ''
        })

        # Compute and set signature
        sig = license.compute_signature
        license.instance_variable_set(:@signature, sig)

        license
      end

      def self.save(license)
        FileUtils.mkdir_p(KEYS_DIR)
        key_file = File.join(KEYS_DIR, "#{license.base_id}.#{license.agent_id}.3ox.key")
        File.write(key_file, license.to_json)
        key_file
      end
    end

    class Validator
      def self.load(base_id:, agent_id:)
        key_file = File.join(KEYS_DIR, "#{base_id}.#{agent_id}.3ox.key")
        return nil unless File.exist?(key_file)
        
        data = JSON.parse(File.read(key_file))
        License.new(data)
      rescue JSON::ParserError
        nil
      end

      def self.validate(base_id:, agent_id:)
        license = load(base_id: base_id, agent_id: agent_id)
        return { valid: false, error: 'Key not found' } unless license
        return { valid: false, error: 'Key expired' } if license.expired?
        return { valid: false, error: 'Key revoked' } if license.revoked?
        return { valid: false, error: 'Invalid signature' } unless license.verify_signature
        
        { valid: true, license: license.to_h }
      end

      def self.revoke(base_id:, agent_id:)
        revoke_file = File.join(KEYS_DIR, "#{base_id}.#{agent_id}.revoked")
        FileUtils.mkdir_p(KEYS_DIR)
        File.write(revoke_file, Time.now.iso8601)
        true
      end

      def self.list_keys
        Dir.glob(File.join(KEYS_DIR, '*.3ox.key')).map do |f|
          name = File.basename(f, '.3ox.key')
          parts = name.split('.', 2)
          {
            base_id: parts[0],
            agent_id: parts[1],
            file: f,
            revoked: File.exist?(f.sub('.3ox.key', '.revoked'))
          }
        end
      end
    end
  end
end

# CLI interface
if __FILE__ == $PROGRAM_NAME
  require 'fileutils'
  
  case ARGV[0]
  when 'generate'
    base_id = ARGV[1] || 'CMD'
    agent_id = ARGV[2] || "agent_#{Time.now.to_i}"
    slot = ARGV[3] || 'permanent'
    
    license = Vec3::Key::Generator.generate(
      base_id: base_id,
      agent_id: agent_id,
      permissions: %w[read write execute],
      slot: slot
    )
    
    path = Vec3::Key::Generator.save(license)
    puts "Generated: #{path}"
    puts license.to_json
    
  when 'validate'
    base_id = ARGV[1]
    agent_id = ARGV[2]
    
    unless base_id && agent_id
      puts "Usage: key.rb validate <base_id> <agent_id>"
      exit 1
    end
    
    result = Vec3::Key::Validator.validate(base_id: base_id, agent_id: agent_id)
    puts JSON.pretty_generate(result)
    exit(result[:valid] ? 0 : 1)
    
  when 'revoke'
    base_id = ARGV[1]
    agent_id = ARGV[2]
    
    unless base_id && agent_id
      puts "Usage: key.rb revoke <base_id> <agent_id>"
      exit 1
    end
    
    Vec3::Key::Validator.revoke(base_id: base_id, agent_id: agent_id)
    puts "Revoked: #{base_id}.#{agent_id}"
    
  when 'list'
    keys = Vec3::Key::Validator.list_keys
    keys.each do |k|
      status = k[:revoked] ? '🔴 REVOKED' : '🟢 ACTIVE'
      puts "#{status} #{k[:base_id]}.#{k[:agent_id]}"
    end
    
  else
    puts <<~USAGE
      3ox.key License Tool
      
      Usage:
        key.rb generate <base_id> <agent_id> [slot]  - Generate new key
        key.rb validate <base_id> <agent_id>         - Validate key
        key.rb revoke <base_id> <agent_id>           - Revoke key
        key.rb list                                  - List all keys
    USAGE
  end
end

# :: ∎