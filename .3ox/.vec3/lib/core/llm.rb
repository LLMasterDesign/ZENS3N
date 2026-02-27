# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x1B28]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // LLM.RB ▞▞
# ▛▞// LLM.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [token] [kernel] [prism] [z3n] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.llm.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for LLM.RB
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
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // LLM ▞▞',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [llm] [system] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.05
##/// Last Updated: 2026.01.05 | Trace.ID: llm.v1.0
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
# LLM Bridge - Connects to Claude/OpenAI/Local models
# This is THE integration point for AI.

require 'net/http'
require 'json'
require 'uri'

module Vec3
  module LLM
    ANTHROPIC_API = 'https://api.anthropic.com/v1/messages'
    OPENAI_API = 'https://api.openai.com/v1/chat/completions'
    
    class << self
      # Main call interface
      # @param prompt [String] The prompt to send
      # @param tools [Array] Optional tools the model can use
      # @param model [String] Model name (default: claude-sonnet-4-20250514)
      # @param provider [Symbol] :anthropic or :openai
      # @return [Hash] Response with content and tool_use
      def call(prompt:, tools: [], model: nil, provider: :anthropic, system: nil)
        case provider
        when :anthropic
          call_anthropic(prompt: prompt, tools: tools, model: model || 'claude-sonnet-4-20250514', system: system)
        when :openai
          call_openai(prompt: prompt, tools: tools, model: model || 'gpt-4o', system: system)
        else
          { error: "Unknown provider: #{provider}" }
        end
      rescue StandardError => e
        { error: e.message, backtrace: e.backtrace&.first(5) }
      end

      # ═══════════════════════════════════════════════════════════════
      # Anthropic
      # ═══════════════════════════════════════════════════════════════

      def call_anthropic(prompt:, tools:, model:, system: nil)
        api_key = ENV['ANTHROPIC_API_KEY']
        return { error: 'ANTHROPIC_API_KEY not set' } unless api_key

        uri = URI(ANTHROPIC_API)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 120

        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request['x-api-key'] = api_key
        request['anthropic-version'] = '2023-06-01'

        body = {
          model: model,
          max_tokens: 4096,
          messages: [{ role: 'user', content: prompt }]
        }
        body[:system] = system if system
        body[:tools] = format_tools_anthropic(tools) unless tools.empty?

        request.body = JSON.generate(body)
        response = http.request(request)

        parse_anthropic_response(response)
      end

      def format_tools_anthropic(tools)
        tools.map do |tool|
          {
            name: tool[:name],
            description: tool[:description],
            input_schema: tool[:parameters] || { type: 'object', properties: {} }
          }
        end
      end

      def parse_anthropic_response(response)
        data = JSON.parse(response.body)
        
        if response.code.to_i >= 400
          return { error: data['error']&.dig('message') || 'API error', status: response.code }
        end

        content = data['content'] || []
        text = content.find { |c| c['type'] == 'text' }&.dig('text')
        tool_use = content.find { |c| c['type'] == 'tool_use' }

        {
          content: text,
          tool_use: tool_use ? { name: tool_use['name'], input: tool_use['input'] } : nil,
          model: data['model'],
          usage: data['usage'],
          stop_reason: data['stop_reason']
        }
      end

      # ═══════════════════════════════════════════════════════════════
      # OpenAI
      # ═══════════════════════════════════════════════════════════════

      def call_openai(prompt:, tools:, model:, system: nil)
        api_key = ENV['OPENAI_API_KEY']
        return { error: 'OPENAI_API_KEY not set' } unless api_key

        uri = URI(OPENAI_API)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 120

        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/json'
        request['Authorization'] = "Bearer #{api_key}"

        messages = []
        messages << { role: 'system', content: system } if system
        messages << { role: 'user', content: prompt }

        body = {
          model: model,
          messages: messages,
          max_tokens: 4096
        }
        body[:tools] = format_tools_openai(tools) unless tools.empty?

        request.body = JSON.generate(body)
        response = http.request(request)

        parse_openai_response(response)
      end

      def format_tools_openai(tools)
        tools.map do |tool|
          {
            type: 'function',
            function: {
              name: tool[:name],
              description: tool[:description],
              parameters: tool[:parameters] || { type: 'object', properties: {} }
            }
          }
        end
      end

      def parse_openai_response(response)
        data = JSON.parse(response.body)
        
        if response.code.to_i >= 400
          return { error: data['error']&.dig('message') || 'API error', status: response.code }
        end

        choice = data['choices']&.first
        message = choice&.dig('message')

        tool_calls = message&.dig('tool_calls')&.first
        tool_use = if tool_calls
          { 
            name: tool_calls.dig('function', 'name'),
            input: JSON.parse(tool_calls.dig('function', 'arguments') || '{}')
          }
        end

        {
          content: message&.dig('content'),
          tool_use: tool_use,
          model: data['model'],
          usage: data['usage'],
          stop_reason: choice&.dig('finish_reason')
        }
      end
    end
  end
end

# ═══════════════════════════════════════════════════════════════
# CLI
# ═══════════════════════════════════════════════════════════════

if __FILE__ == $PROGRAM_NAME
  case ARGV[0]
  when 'test'
    result = Vec3::LLM.call(
      prompt: 'Say "Hello from 3OX" and nothing else.',
      model: 'claude-sonnet-4-20250514'
    )
    puts JSON.pretty_generate(result)
  when 'call'
    prompt = ARGV[1] || $stdin.read
    result = Vec3::LLM.call(prompt: prompt)
    puts JSON.pretty_generate(result)
  else
    puts <<~USAGE
      ▛▞ Vec3::LLM - LLM Bridge
      
      Usage:
        llm.rb test              # Test connection
        llm.rb call "<prompt>"   # Call with prompt
        echo "prompt" | llm.rb call  # Call from stdin
      
      Environment:
        ANTHROPIC_API_KEY       # For Claude
        OPENAI_API_KEY          # For GPT
    USAGE
  end
end

# :: ∎