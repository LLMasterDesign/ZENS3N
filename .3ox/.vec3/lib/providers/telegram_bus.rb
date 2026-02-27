# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x1623]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // TELEGRAM_BUS.RB ▞▞
# ▛▞// TELEGRAM_BUS.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [telegram] [json] [glyph] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.telegram_bus.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for TELEGRAM_BUS.RB
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
##/// Last Updated: 2026.01.06 | Trace.ID: telegram_bus.v1.0
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.06
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [telegram_bus] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // TELEGRAM_BUS ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
# telegram_bus.rb :: Shared Telegram Bus for Agents/Stations
# Agents sign on to use Telegram without needing their own API key
# Teleprompter acts as message router/bus

require 'json'
require 'fileutils'
require 'time'

module Vec3
  class TelegramBus
    BUS_DIR = File.expand_path('../../var/telegram_bus', __dir__)
    REGISTRATIONS_FILE = File.join(BUS_DIR, 'registrations.json')
    INBOX_DIR = File.join(BUS_DIR, 'inbox')
    OUTBOX_DIR = File.join(BUS_DIR, 'outbox')
    
    def initialize
      FileUtils.mkdir_p(BUS_DIR)
      FileUtils.mkdir_p(INBOX_DIR)
      FileUtils.mkdir_p(OUTBOX_DIR)
      FileUtils.mkdir_p(File.dirname(REGISTRATIONS_FILE))
    end
    
    # Agent/Station signs on to bus
    def register(agent_id:, agent_name:, agent_type: "station", pico_glyph: "⚙️")
      registrations = load_registrations
      registrations[agent_id] = {
        agent_id: agent_id,
        agent_name: agent_name,
        agent_type: agent_type,
        pico_glyph: pico_glyph,
        registered_at: Time.now.utc.iso8601,
        last_seen: Time.now.utc.iso8601,
        status: "active"
      }
      save_registrations(registrations)
      { status: "registered", agent_id: agent_id }
    end
    
    # Agent sends message through bus (no API key needed)
    def send_message(agent_id:, chat_id:, text:, topic_thread_id: nil)
      # Create message envelope
      message = {
        agent_id: agent_id,
        chat_id: chat_id,
        topic_thread_id: topic_thread_id,
        text: text,
        timestamp: Time.now.utc.iso8601,
        message_id: "bus_#{Time.now.to_f.to_s.gsub('.', '')}"
      }
      
      # Write to outbox (Teleprompter will pick it up)
      outbox_path = File.join(OUTBOX_DIR, "#{message[:message_id]}.json")
      File.write(outbox_path, JSON.pretty_generate(message))
      
      { status: "queued", message_id: message[:message_id] }
    end
    
    # Agent receives messages from bus
    def receive_messages(agent_id:)
      inbox_path = File.join(INBOX_DIR, "#{agent_id}_*.json")
      messages = []
      Dir.glob(inbox_path).each do |path|
        begin
          msg = JSON.parse(File.read(path))
          messages << msg
          File.delete(path) # Consume message
        rescue => e
          warn "Failed to read message #{path}: #{e.message}"
        end
      end
      messages.sort_by { |m| m['timestamp'] || '' }
    end
    
    # Update last seen (heartbeat)
    def heartbeat(agent_id:)
      registrations = load_registrations
      if registrations[agent_id]
        registrations[agent_id]['last_seen'] = Time.now.utc.iso8601
        save_registrations(registrations)
      end
    end
    
    private
    
    def load_registrations
      return {} unless File.exist?(REGISTRATIONS_FILE)
      JSON.parse(File.read(REGISTRATIONS_FILE)) rescue {}
    end
    
    def save_registrations(reg)
      File.write(REGISTRATIONS_FILE, JSON.pretty_generate(reg))
    end
  end
end
# :: ∎