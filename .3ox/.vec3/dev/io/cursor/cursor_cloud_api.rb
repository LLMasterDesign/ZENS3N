# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x7FF0]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // CURSOR_CLOUD_API.RB ▞▞
# ▛▞// CURSOR_CLOUD_API.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [vec3] [cursorcloudapi] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.cursor_cloud_api.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for CURSOR_CLOUD_API.RB
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




require 'net/http'
require 'json'
require 'uri'

module Vec3
  module CursorCloudAPI
    API_BASE = "https://api.cursor.com/v0"
    
    def self.load_api_key
      # Try secrets file first
      secrets_file = File.expand_path('../../rc/secrets/api.keys', __FILE__)
      if File.exist?(secrets_file)
        File.readlines(secrets_file).each do |line|
          next if line.strip.empty? || line.start_with?('#')
          if line =~ /^CURSOR_API_KEY=(.+)$/
            key = $1.strip.gsub(/^["']|["']$/, '')
            return key unless key.empty?
          end
        end
      end
      
      # Fallback to environment
      ENV['CURSOR_API_KEY']
    end
    
    def self.launch_agent(prompt, options = {})
      api_key = load_api_key
      unless api_key
        return {
          ok: false,
          error: "CURSOR_API_KEY not found. Add to .3ox/vec3/rc/secrets/api.keys"
        }
      end
      
      uri = URI("#{API_BASE}/agents")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'
      
      payload = {
        prompt: {
          text: prompt
        }
      }
      
      payload[:model] = options[:model] if options[:model]
      payload[:source] = options[:source] if options[:source]
      
      request.body = payload.to_json
      
      begin
        response = http.request(request)
        
        case response.code.to_i
        when 200, 201
          data = JSON.parse(response.body)
          {
            ok: true,
            agent_id: data['id'],
            status: data['status'],
            status_url: data.dig('target', 'url'),
            branch: data.dig('target', 'branchName'),
            created_at: data['createdAt']
          }
        else
          {
            ok: false,
            error: "API error #{response.code}: #{response.body[0..200]}"
          }
        end
      rescue => e
        {
          ok: false,
          error: "Request failed: #{e.message}"
        }
      end
    end
    
    def self.get_agent_status(agent_id)
      api_key = load_api_key
      return {ok: false, error: "No API key"} unless api_key
      
      uri = URI("#{API_BASE}/agents/#{agent_id}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{api_key}"
      
      begin
        response = http.request(request)
        if response.code.to_i == 200
          {ok: true, data: JSON.parse(response.body)}
        else
          {ok: false, error: "Status check failed: #{response.code}"}
        end
      rescue => e
        {ok: false, error: e.message}
      end
    end
    
    # CLI interface
    if __FILE__ == $0
      case ARGV[0]
      when 'launch'
        prompt = ARGV[1..-1].join(' ')
        result = launch_agent(prompt)
        puts JSON.pretty_generate(result)
      when 'status'
        agent_id = ARGV[1]
        result = get_agent_status(agent_id)
        puts JSON.pretty_generate(result)
      else
        puts "Usage: #{$0} launch <prompt>"
        puts "       #{$0} status <agent_id>"
      end
    end
  end
end
# :: ∎