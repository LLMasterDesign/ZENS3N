# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xD564]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // LAW.RB.BACKUP.1768500265 ▞▞
# ▛▞// LAW.RB.BACKUP.1768500265 :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [toml] [yaml] [dispatch] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.law.rb.backup.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for LAW.RB.BACKUP.1768500265
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
# vec3/rc/dispatch/law.rb - Law file loader and hasher
# Part of 3OX.Ai (ZEN-6)
#
# Loads limits.toml, routes.json, tools.yml and computes manifest hashes

require 'json'
require 'yaml'
require 'digest'
require 'fileutils'
require 'time'

# Optional TOML support
begin
  require 'toml-rb'
  TOML_AVAILABLE = true
rescue LoadError
  TOML_AVAILABLE = false
end

module Vec3
  module Dispatch
    module Law
      VEC3_ROOT = File.expand_path('../..', __dir__)
      OPS_DIR = File.expand_path('../../..', __dir__)  # .3ox/
      CONFIG_DIR = File.join(VEC3_ROOT, 'rc', 'config')
      MANIFEST_FILE = File.join(VEC3_ROOT, 'rc', 'dispatch', 'manifest.json')
      
      class << self
        # Load all law files and compute manifest
        def load_all
          @limits = load_limits
          @routes = load_routes
          @tools = load_tools
          @manifest = compute_manifest
          
          {
            limits: @limits,
            routes: @routes,
            tools: @tools,
            manifest: @manifest
          }
        end
        
        # Get cached law or reload
        def limits
          @limits ||= load_limits
        end
        
        def routes
          @routes ||= load_routes
        end
        
        def tools
          @tools ||= load_tools
        end
        
        def manifest
          @manifest ||= compute_manifest
        end
        
        # Reload law files
        def reload!
          @limits = nil
          @routes = nil
          @tools = nil
          @manifest = nil
          load_all
        end
        
        # Load limits.toml
        def load_limits
          paths = [
            File.join(CONFIG_DIR, 'limits.toml'),
            File.join(OPS_DIR, 'limits.toml')
          ]
          
          file = paths.find { |p| File.exist?(p) }
          return {} unless file
          
          if TOML_AVAILABLE
            TomlRB.load_file(file)
          else
            # Fallback: simple TOML parser for basic cases
            parse_simple_toml(File.read(file))
          end
        end
        
        # Load routes.json
        def load_routes
          paths = [
            File.join(CONFIG_DIR, 'routes.json'),
            File.join(OPS_DIR, 'routes.json')
          ]
          
          file = paths.find { |p| File.exist?(p) }
          return { 'routes' => [], 'default_route' => {} } unless file
          
          JSON.parse(File.read(file))
        end
        
        # Load tools.yml
        def load_tools
          paths = [
            File.join(CONFIG_DIR, 'tools.yml'),
            File.join(OPS_DIR, 'tools.yml')
          ]
          
          file = paths.find { |p| File.exist?(p) }
          return {} unless file
          
          YAML.safe_load(File.read(file), permitted_classes: [Symbol])
        end
        
        # Compute manifest with hashes
        def compute_manifest
          limits_hash = hash_content(limits)
          routes_hash = hash_content(routes)
          tools_hash = hash_content(tools)
          
          manifest = {
            limits_hash: "sha256:#{limits_hash}",
            routes_hash: "sha256:#{routes_hash}",
            tools_hash: "sha256:#{tools_hash}",
            manifest_hash: nil,
            ts: Time.now.utc.iso8601,
            version: '1.0.0'
          }
          
          # Compute overall manifest hash
          manifest[:manifest_hash] = "sha256:#{hash_content(manifest.reject { |k, _| k == :manifest_hash })}"
          
          # Save manifest
          save_manifest(manifest)
          
          manifest
        end
        
        # Validate envelope against law
        def validate_envelope(envelope)
          envelope = envelope.transform_keys(&:to_sym)
          errors = []
          
          # Check manifest hash matches
          if envelope[:manifest_hash] && envelope[:manifest_hash] != manifest[:manifest_hash]
            errors << { code: 'manifest_mismatch', msg: 'Envelope manifest does not match current law' }
          end
          
          # Check permissions against limits
          permissions = envelope[:permissions] || []
          
          # Check file system permissions
          if permissions.include?('fs.write') || permissions.include?('fs.write.ops')
            unless limits.dig('safety_limits', 'allow_file_system_write')
              errors << { code: 'permission_denied', msg: 'File system write not allowed' }
            end
          end
          
          # Check network permissions
          if permissions.include?('net.http')
            unless limits.dig('safety_limits', 'allow_external_network')
              errors << { code: 'permission_denied', msg: 'External network not allowed' }
            end
          end
          
          # Check timeout
          timeout = envelope[:timeout_ms] || 30000
          max_timeout = limits.dig('execution_limits', 'max_execution_time_ms') || 30000
          if timeout > max_timeout
            errors << { code: 'limit_exceeded', msg: "Timeout #{timeout}ms exceeds limit #{max_timeout}ms" }
          end
          
          # Check route exists
          if envelope[:route_id]
            route = find_route(envelope[:route_id])
            unless route
              errors << { code: 'route_not_found', msg: "Route #{envelope[:route_id]} not found" }
            end
          end
          
          {
            valid: errors.empty?,
            errors: errors,
            manifest_hash: manifest[:manifest_hash]
          }
        end
        
        # Find route by ID
        def find_route(route_id)
          all_routes = routes['routes'] || []
          all_routes.find { |r| r['id'] == route_id } || routes['default_route']
        end
        
        # Get tools for a route
        def tools_for_route(route_id)
          route = find_route(route_id)
          return [] unless route
          
          tool_ids = route['tools'] || []
          tool_ids.map { |id| tools[id] }.compact
        end
        
        private
        
        def hash_content(content)
          canonical = JSON.generate(content.is_a?(Hash) ? content.sort.to_h : content)
          Digest::SHA256.hexdigest(canonical)
        end
        
        def save_manifest(manifest)
          FileUtils.mkdir_p(File.dirname(MANIFEST_FILE))
          File.write(MANIFEST_FILE, JSON.pretty_generate(manifest))
        end
        
        # Simple TOML parser for basic key=value and [section] format
        def parse_simple_toml(content)
          result = {}
          current_section = nil
          
          content.each_line do |line|
            line = line.strip
            next if line.empty? || line.start_with?('#')
            
            if line.match?(/^\[(.+)\]$/)
              current_section = line.match(/^\[(.+)\]$/)[1]
              result[current_section] = {}
            elsif line.include?('=')
              key, value = line.split('=', 2).map(&:strip)
              value = parse_toml_value(value)
              
              if current_section
                result[current_section][key] = value
              else
                result[key] = value
              end
            end
          end
          
          result
        end
        
        def parse_toml_value(value)
          case value
          when /^"(.*)"$/ then $1
          when /^'(.*)'$/ then $1
          when /^\d+$/ then value.to_i
          when /^\d+\.\d+$/ then value.to_f
          when 'true' then true
          when 'false' then false
          else value.gsub(/^["']|["']$/, '')
          end
        end
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  case ARGV[0]
  when 'load'
    law = Vec3::Dispatch::Law.load_all
    puts JSON.pretty_generate(law[:manifest])
  when 'validate'
    envelope_json = ARGV[1] || STDIN.read
    envelope = JSON.parse(envelope_json)
    result = Vec3::Dispatch::Law.validate_envelope(envelope)
    puts JSON.pretty_generate(result)
    exit(result[:valid] ? 0 : 1)
  when 'manifest'
    puts JSON.pretty_generate(Vec3::Dispatch::Law.manifest)
  else
    puts "Usage: ruby law.rb <load|validate|manifest>"
  end
end

# :: ∎