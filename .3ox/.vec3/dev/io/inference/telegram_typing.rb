# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xFD5A]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // TELEGRAM_TYPING.RB ▞▞
# ▛▞// TELEGRAM_TYPING.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [telegram] [json] [token] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.telegram_typing.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for TELEGRAM_TYPING.RB
# ```

# 


# 


#!/usr/bin/env ruby




#

#
# ▛//▞ PRISM :: KERNEL
# P:: telegram.typing ∙ streaming.thoughts ∙ heartbeat.display
# R:: send.typing ∙ edit.message ∙ emit.thoughts
# I:: intent.target={user.feedback ∙ llm.progress}
# S:: start → type → think → update → complete
# M:: typing.action ∙ edited.message
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ start{chat_id ∙ thread_id}
# ⇨ ≔ type{sendChatAction}
# ⟿ ≔ think{send.thoughts ∙ edit.message}
# ▷ ≔ complete{final.response}
# :: ∎

require 'net/http'
require 'json'
require 'uri'

module Vec3
  class TelegramTyping
    TELEGRAM_API = "https://api.telegram.org"
    
    # Heartbeat bar format
    BAR_FILLED = "▮"
    BAR_EMPTY = "▯"
    BAR_CAP = "▹"
    BAR_PREFIX = "▛▞//"
    
    # Thought stages with descriptions
    STAGES = [
      { key: "context",    thought: "📖 Accessing knowledge..." },
      { key: "arc",        thought: "🧭 Routing through archetypes..." },
      { key: "inference",  thought: "🧠 Generating response..." },
      { key: "tokens",     thought: "⚡ Crystallizing output..." },
      { key: "verify",     thought: "✓ Validating coherence..." },
      { key: "format",     thought: "📜 Structuring response..." },
      { key: "complete",   thought: "✨ Response ready." }
    ]
    
    attr_reader :chat_id, :thread_id, :token, :thinking_message_id
    
    def initialize(token:, chat_id:, thread_id: nil)
      @token = token
      @chat_id = chat_id
      @thread_id = thread_id
      @thinking_message_id = nil
      @current_stage = 0
    end
    
    # Send typing action to Telegram
    def send_typing
      api_call("sendChatAction", {
        chat_id: @chat_id,
        action: "typing",
        message_thread_id: @thread_id
      }.compact)
    end
    
    # Start thinking - send initial message with progress bar
    def start_thinking
      send_typing
      
      text = format_thinking_message(0)
      
      result = api_call("sendMessage", {
        chat_id: @chat_id,
        message_thread_id: @thread_id,
        text: text,
        parse_mode: "Markdown"
      }.compact)
      
      if result && result["ok"] && result["result"]
        @thinking_message_id = result["result"]["message_id"]
      end
      
      @thinking_message_id
    end
    
    # Update thinking progress
    def update_thinking(stage_index)
      return unless @thinking_message_id
      
      @current_stage = stage_index
      text = format_thinking_message(stage_index)
      
      # Keep sending typing action
      send_typing
      
      api_call("editMessageText", {
        chat_id: @chat_id,
        message_id: @thinking_message_id,
        text: text,
        parse_mode: "Markdown"
      })
    end
    
    # Complete thinking - replace with final response
    def complete_thinking(final_text)
      if @thinking_message_id
        # Edit the thinking message to final response
        api_call("editMessageText", {
          chat_id: @chat_id,
          message_id: @thinking_message_id,
          text: final_text,
          parse_mode: "Markdown"
        })
      else
        # Fallback: send new message
        api_call("sendMessage", {
          chat_id: @chat_id,
          message_thread_id: @thread_id,
          text: final_text,
          parse_mode: "Markdown"
        }.compact)
      end
    end
    
    # Delete thinking message (if sending separate response)
    def delete_thinking
      return unless @thinking_message_id
      
      api_call("deleteMessage", {
        chat_id: @chat_id,
        message_id: @thinking_message_id
      })
      
      @thinking_message_id = nil
    end
    
    # Create a heartbeat callback for inference
    def heartbeat_callback
      stage_map = {
        "loading{context}" => 0,
        "thinking{openai}" => 1,
        "thinking{cursor}" => 1,
        "inference{gpt}" => 2,
        "inference{cursor}" => 2,
        "compiling{tokens}" => 3
      }
      
      ->(bar) do
        # Parse stage from bar string
        if bar =~ /\.\.\.(\w+\{[^}]+\})/
          stage_key = $1
          if stage_idx = stage_map[stage_key]
            update_thinking(stage_idx)
          end
        end
      end
    end
    
    private
    
    def format_thinking_message(stage_index)
      stage = STAGES[[stage_index, STAGES.length - 1].min]
      bar = heartbeat_bar(stage_index + 1, STAGES.length)
      
      "💭 *...thinking...*\n\n" \
      "#{stage[:thought]}\n\n" \
      "`#{bar}`"
    end
    
    def heartbeat_bar(current, total = 7)
      filled = [current, total].min
      empty = total - filled
      bar = BAR_FILLED * filled + BAR_EMPTY * empty
      "#{BAR_PREFIX}#{bar}#{BAR_CAP}"
    end
    
    def api_call(method, params)
      uri = URI("#{TELEGRAM_API}/bot#{@token}/#{method}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 30
      
      request = Net::HTTP::Post.new(uri.path)
      request['Content-Type'] = 'application/json'
      request.body = JSON.generate(params)
      
      response = http.request(request)
      JSON.parse(response.body)
    rescue => e
      { "ok" => false, "error" => e.message }
    end
  end
end

# CLI test
if __FILE__ == $0
  puts "TelegramTyping - requires token and chat_id to test"
  puts "Usage: ruby telegram_typing.rb <token> <chat_id> [thread_id]"
  
  if ARGV.length >= 2
    token = ARGV[0]
    chat_id = ARGV[1].to_i
    thread_id = ARGV[2]&.to_i
    
    typing = Vec3::TelegramTyping.new(token: token, chat_id: chat_id, thread_id: thread_id)
    
    puts "Starting thinking indicator..."
    typing.start_thinking
    
    (0..5).each do |i|
      sleep 1
      puts "Stage #{i}..."
      typing.update_thinking(i)
    end
    
    sleep 1
    puts "Completing..."
    typing.complete_thinking("▛▞// 👑 *MetaTron* ▞▞\n\nTest complete. The thinking indicator works.\n\n⧗-26.177")
    
    puts "Done!"
  end
end
# :: ∎