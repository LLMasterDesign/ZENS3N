# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xCE4D]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // INFERENCE.RB ▞▞
# ▛▞// INFERENCE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [token] [kernel] [prism] [vec3] [inference] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.inference.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for INFERENCE.RB
# ```

# 


# 


#!/usr/bin/env ruby




#

#
# ▛//▞ PRISM :: KERNEL
# P:: llm.inference ∙ heartbeat.emit ∙ api.client
# R:: call.openai ∙ call.cursor ∙ parse.response
# I:: intent.target={metatron.brain ∙ agent.responses}
# S:: receive → heartbeat → api.call → parse → return
# M:: json.response ∙ heartbeat.string
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ receive{prompt ∙ model ∙ system}
# ⇨ ≔ heartbeat{emit.progress}
# ⟿ ≔ api{http.post ∙ stream}
# ▷ ≔ return{response.text}
# :: ∎

require 'net/http'
require 'json'
require 'uri'

module Vec3
  module Inference
    KEYS_DIR = File.expand_path('../../../../keys', __dir__)
    
    # Thought stages for streaming display
    THOUGHT_STAGES = [
      { stage: "loading{context}", thought: "Accessing knowledge..." },
      { stage: "thinking{arc}", thought: "Routing through archetypes..." },
      { stage: "inference{model}", thought: "Generating response..." },
      { stage: "compiling{tokens}", thought: "Crystallizing output..." },
      { stage: "verifying{truth}", thought: "Validating coherence..." },
      { stage: "formatting{sxsl}", thought: "Structuring response..." },
      { stage: "complete", thought: "Response ready." }
    ]
    
    # Heartbeat bar format
    BAR_FILLED = "▮"
    BAR_EMPTY = "▯"
    BAR_CAP = "▹"
    BAR_PREFIX = "▛▞//"
    
    class << self
      # ─────────────────────────────────────────────────────────────
      # Main API
      # ─────────────────────────────────────────────────────────────
      
      # Think with LLM - returns response string
      # @param prompt [String] User prompt
      # @param model [Symbol] :openai or :cursor
      # @param system [String] Optional system prompt
      # @param heartbeat [Proc] Optional callback for progress
      # @return [Hash] { ok: true, response: "..." } or { ok: false, error: "..." }
      def think(prompt, model: :openai, system: nil, heartbeat: nil)
        emit_heartbeat(heartbeat, "loading{context}", 1)
        
        case model
        when :openai
          call_openai(prompt, system, heartbeat)
        when :cursor
          call_cursor(prompt, system, heartbeat)
        else
          { ok: false, error: "Unknown model: #{model}" }
        end
      rescue => e
        { ok: false, error: e.message }
      end
      
      # Format heartbeat progress bar
      def heartbeat(stage, current, total = 7)
        filled = [current, total].min
        empty = total - filled
        bar = BAR_FILLED * filled + BAR_EMPTY * empty
        "...#{stage} #{BAR_PREFIX}#{bar}#{BAR_CAP}"
      end
      
      # Get status
      def status
        {
          openai: load_key('OpenAi.key', 'OPENAI_KEY') ? :loaded : :missing,
          cursor: load_key('Cursor.key', 'CURSOR_KEY') ? :loaded : :missing,
          keys_dir: KEYS_DIR
        }
      end
      
      private
      
      # ─────────────────────────────────────────────────────────────
      # OpenAI
      # ─────────────────────────────────────────────────────────────
      
      def call_openai(prompt, system, heartbeat)
        api_key = load_key('OpenAi.key', 'OPENAI_KEY')
        return { ok: false, error: "OpenAI API key not found" } unless api_key
        
        emit_heartbeat(heartbeat, "thinking{openai}", 2)
        
        messages = build_messages(prompt, system)
        
        body = {
          model: "gpt-4o-mini",
          messages: messages,
          max_tokens: 1024
        }
        
        emit_heartbeat(heartbeat, "inference{gpt}", 3)
        
        response = http_post(
          "https://api.openai.com/v1/chat/completions",
          body,
          { "Authorization" => "Bearer #{api_key}" }
        )
        
        emit_heartbeat(heartbeat, "compiling{tokens}", 5)
        
        parse_openai_response(response)
      end
      
      # ─────────────────────────────────────────────────────────────
      # Cursor
      # ─────────────────────────────────────────────────────────────
      
      def call_cursor(prompt, system, heartbeat)
        api_key = load_key('Cursor.key', 'CURSOR_KEY')
        return { ok: false, error: "Cursor API key not found" } unless api_key
        
        emit_heartbeat(heartbeat, "thinking{cursor}", 2)
        
        messages = build_messages(prompt, system)
        
        body = {
          model: "cursor-small",
          messages: messages,
          max_tokens: 1024
        }
        
        emit_heartbeat(heartbeat, "inference{cursor}", 3)
        
        response = http_post(
          "https://api.cursor.sh/v1/chat/completions",
          body,
          { "Authorization" => "Bearer #{api_key}" }
        )
        
        emit_heartbeat(heartbeat, "compiling{tokens}", 5)
        
        parse_openai_response(response)  # Same format
      end
      
      # ─────────────────────────────────────────────────────────────
      # Helpers
      # ─────────────────────────────────────────────────────────────
      
      def build_messages(prompt, system)
        messages = []
        messages << { role: "system", content: system } if system
        messages << { role: "user", content: prompt }
        messages
      end
      
      def parse_openai_response(response)
        return { ok: false, error: "HTTP error: #{response[:error]}" } if response[:error]
        
        data = JSON.parse(response[:body], symbolize_names: true)
        
        if data[:choices] && data[:choices][0]
          content = data[:choices][0][:message][:content]
          { ok: true, response: content }
        elsif data[:error]
          { ok: false, error: data[:error][:message] }
        else
          { ok: false, error: "Invalid response format" }
        end
      rescue JSON::ParserError => e
        { ok: false, error: "JSON parse error: #{e.message}" }
      end
      
      def http_post(url, body, headers = {})
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 30
        http.read_timeout = 60
        
        request = Net::HTTP::Post.new(uri.path)
        request['Content-Type'] = 'application/json'
        headers.each { |k, v| request[k] = v }
        request.body = JSON.generate(body)
        
        response = http.request(request)
        
        { status: response.code.to_i, body: response.body }
      rescue => e
        { error: e.message }
      end
      
      def emit_heartbeat(callback, stage, progress)
        return unless callback
        
        bar = heartbeat(stage, progress)
        
        if callback.is_a?(Proc)
          callback.call(bar)
        elsif callback.respond_to?(:call)
          callback.call(bar)
        end
      end
      
      def load_key(filename, prefix)
        path = File.join(KEYS_DIR, filename)
        
        if File.exist?(path)
          content = File.read(path).strip
          # Parse KEY=value format
          if content.include?('=')
            parts = content.split('=', 2)
            parts[1] if parts[0] == prefix
          else
            content
          end
        else
          ENV[prefix]
        end
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  case ARGV[0]
  when 'status'
    puts JSON.pretty_generate(Vec3::Inference.status)
  when 'test'
    prompt = ARGV[1] || "What is 2 + 2?"
    model = (ARGV[2] || 'openai').to_sym
    
    puts "Prompt: #{prompt}"
    puts "Model: #{model}"
    puts ""
    
    result = Vec3::Inference.think(
      prompt,
      model: model,
      heartbeat: ->(bar) { puts bar }
    )
    
    puts Vec3::Inference.heartbeat("complete", 7)
    puts ""
    
    if result[:ok]
      puts "Response:"
      puts result[:response]
    else
      puts "Error: #{result[:error]}"
    end
  when 'heartbeat'
    7.times do |i|
      puts Vec3::Inference.heartbeat("thinking{demo}", i + 1)
      sleep 0.3
    end
  else
    puts "Usage: ruby inference.rb <status|test [prompt] [model]|heartbeat>"
  end
end
# :: ∎