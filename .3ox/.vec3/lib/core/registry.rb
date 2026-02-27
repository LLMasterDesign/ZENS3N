# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x2F54]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // REGISTRY.RB ▞▞
# ▛▞// REGISTRY.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [yaml] [kernel] [prism] [z3n] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.registry.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for REGISTRY.RB
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
##/// Last Updated: 2026.01.05 | Trace.ID: registry.v1.0
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.05
#```elixir
# vec3/core/registry.rb - Service and station registry
# Part of 3OX.Ai OS Core (ZEN-5)

require 'yaml'
require 'json'
require 'fileutils'

module Vec3
  module Registry
    # This file lives at vec3/lib/core/registry.rb → vec3 root is two levels up.
    VEC3_ROOT = File.expand_path('../..', __dir__)  # vec3/lib/core -> vec3/
    STATE_DIR = File.join(VEC3_ROOT, 'var', 'state')
    REGISTRY_FILE = File.join(STATE_DIR, 'registry.json')
    
    class << self
      # Get all registered services
      def services
        load_registry[:services] || {}
      end
      
      # Get all registered stations
      def stations
        load_registry[:stations] || {}
      end
      
      # Register a service
      def register_service(id:, name:, command:, pid: nil, status: :stopped)
        reg = load_registry
        reg[:services] ||= {}
        id = id.to_s  # Normalize to string key
        reg[:services][id] = {
          id: id,
          name: name,
          command: command,
          pid: pid,
          status: status.to_s,
          registered_at: Time.now.utc.iso8601,
          updated_at: Time.now.utc.iso8601
        }
        save_registry(reg)
      end
      
      # Register a station
      def register_station(id:, name:, path:, status: :stopped)
        reg = load_registry
        reg[:stations] ||= {}
        id = id.to_s  # Normalize to string key
        reg[:stations][id] = {
          id: id,
          name: name,
          path: path,
          status: status.to_s,
          registered_at: Time.now.utc.iso8601,
          updated_at: Time.now.utc.iso8601
        }
        save_registry(reg)
      end
      
      # Update service status
      def update_service(id, **attrs)
        reg = load_registry
        return false unless reg[:services]&.[](id)
        reg[:services][id].merge!(attrs.transform_keys(&:to_sym))
        reg[:services][id][:updated_at] = Time.now.utc.iso8601
        save_registry(reg)
        true
      end
      
      # Update station status
      def update_station(id, **attrs)
        reg = load_registry
        return false unless reg[:stations]&.[](id)
        reg[:stations][id].merge!(attrs.transform_keys(&:to_sym))
        reg[:stations][id][:updated_at] = Time.now.utc.iso8601
        save_registry(reg)
        true
      end
      
      # Get service by ID
      def service(id)
        services[id] || services[id.to_s]
      end
      
      # Get station by ID
      def station(id)
        stations[id] || stations[id.to_s]
      end
      
      # Remove service
      def unregister_service(id)
        reg = load_registry
        reg[:services]&.delete(id)
        reg[:services]&.delete(id.to_s)
        save_registry(reg)
      end
      
      # Remove station
      def unregister_station(id)
        reg = load_registry
        reg[:stations]&.delete(id)
        reg[:stations]&.delete(id.to_s)
        save_registry(reg)
      end
      
      private
      
      def load_registry
        FileUtils.mkdir_p(STATE_DIR) unless Dir.exist?(STATE_DIR)
        return { services: {}, stations: {} } unless File.exist?(REGISTRY_FILE)
        JSON.parse(File.read(REGISTRY_FILE), symbolize_names: true)
      rescue JSON::ParserError
        { services: {}, stations: {} }
      end
      
      def save_registry(data)
        FileUtils.mkdir_p(STATE_DIR) unless Dir.exist?(STATE_DIR)
        File.write(REGISTRY_FILE, JSON.pretty_generate(data))
      end
    end
  end
end
# :: ∎
