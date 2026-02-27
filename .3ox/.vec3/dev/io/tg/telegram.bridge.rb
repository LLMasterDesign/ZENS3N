# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xF417]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // TELEGRAM.BRIDGE.RB ▞▞
# ▛▞// TELEGRAM.BRIDGE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [telegram] [json] [glyph] [token] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.telegram.bridge.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for TELEGRAM.BRIDGE.RB
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
##/// Last Updated: ⧗-26.160 | Trace.ID: telegram.bridge.v1.0
##/// Status: [ACTIVE] | Cat: IO | Auth: SYSTEM | Created: ⧗-26.160
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🌉] ≔ [telegram_bridge] [io] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ :: ⧗-26.160 // TELEGRAM.BRIDGE ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
# telegram.bridge.rb :: Ruby-to-Elixir bridge for Telegram operations
# Calls Elixir Vec3.TelegramBridge for external Telegram API communications

require 'json'

module Vec3
  class TelegramBridge
    # Call Elixir TelegramBridge module
    def self.send_message(chat_id, text, opts = {})
      # Build Elixir command
      elixir_code = """
      require Vec3.TelegramBridge
      result = Vec3.TelegramBridge.send_message(
        \"#{chat_id}\",
        \"#{text.gsub('"', '\\"')}\",
        %{
          parse_mode: \"#{opts[:parse_mode] || 'Markdown'}\",
          #{opts[:reply_to_message_id] ? "reply_to_message_id: #{opts[:reply_to_message_id]}," : ""}
          #{opts[:topic_thread_id] ? "topic_thread_id: #{opts[:topic_thread_id]}," : ""}
          #{opts[:disable_notification] ? "disable_notification: #{opts[:disable_notification]}," : ""}
        }
      )
      IO.puts(JSON.encode!(result))
      """
      
      # Execute via mix run
      result = `cd #{File.expand_path('../../../../', __FILE__)} && mix run -e '#{elixir_code.gsub("'", "\\'")}' 2>&1`
      
      # Parse result
      begin
        parsed = JSON.parse(result.strip)
        if parsed["ok"] || parsed[:ok]
          { ok: true, message_id: parsed["message_id"] || parsed[:message_id] }
        else
          { ok: false, error: parsed["error"] || parsed[:error] || "Unknown error" }
        end
      rescue => e
        # Fallback: try direct HTTP call if Elixir unavailable
        send_message_fallback(chat_id, text, opts)
      end
    end
    
    def self.get_bot_info
      elixir_code = """
      require Vec3.TelegramBridge
      result = Vec3.TelegramBridge.get_bot_info()
      IO.puts(JSON.encode!(result))
      """
      
      result = `cd #{File.expand_path('../../../../', __FILE__)} && mix run -e '#{elixir_code.gsub("'", "\\'")}' 2>&1`
      
      begin
        JSON.parse(result.strip)
      rescue => e
        { error: "Elixir bridge unavailable: #{e.message}" }
      end
    end
    
    def self.register_cmd_bridge(chat_id, pico_glyph = "⚙️")
      # Register with Telegram bus (Ruby system)
      require_relative '../../../lib/providers/telegram_bus'
      bus = Vec3::TelegramBus.new
      
      result = bus.register(
        agent_id: "CMD.BRIDGE",
        agent_name: "CMD Bridge",
        agent_type: "base",
        pico_glyph: pico_glyph
      )
      
      # Also register via Elixir if available
      elixir_code = """
      require Vec3.TelegramBridge
      result = Vec3.TelegramBridge.register_cmd_bridge(\"#{chat_id}\", \"#{pico_glyph}\")
      IO.puts(JSON.encode!(result))
      """
      
      begin
        elixir_result = `cd #{File.expand_path('../../../../', __FILE__)} && mix run -e '#{elixir_code.gsub("'", "\\'")}' 2>&1`
        # Combine results
        result
      rescue
        result
      end
    end
    
    private
    
    def self.send_message_fallback(chat_id, text, opts)
      # Fallback to direct HTTP if Elixir unavailable
      require 'net/http'
      require 'uri'
      
      bot_token = ENV['TELEGRAM_BOT_TOKEN'] || read_token_from_secrets
      return { ok: false, error: "No bot token configured" } unless bot_token
      
      uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage")
      
      payload = {
        chat_id: chat_id,
        text: text,
        parse_mode: opts[:parse_mode] || 'Markdown'
      }
      payload[:reply_to_message_id] = opts[:reply_to_message_id] if opts[:reply_to_message_id]
      payload[:message_thread_id] = opts[:topic_thread_id] if opts[:topic_thread_id]
      payload[:disable_notification] = opts[:disable_notification] if opts[:disable_notification]
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path)
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json
      
      response = http.request(request)
      
      if response.code == '200'
        result = JSON.parse(response.body)
        if result['ok']
          { ok: true, message_id: result['result']['message_id'].to_s }
        else
          { ok: false, error: result['description'] }
        end
      else
        { ok: false, error: "HTTP #{response.code}" }
      end
    end
    
    def self.read_token_from_secrets
      secrets_path = File.expand_path('../../../rc/secrets/api.keys', __FILE__)
      return nil unless File.exist?(secrets_path)
      
      File.readlines(secrets_path).each do |line|
        if line =~ /^TELEGRAM_BOT_TOKEN=(.+)$/
          return $1.strip
        end
      end
      nil
    end
  end
end
# :: ∎