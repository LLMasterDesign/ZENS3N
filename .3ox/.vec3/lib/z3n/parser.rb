# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x1A50]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // PARSER.RB ▞▞
# ▛▞// PARSER.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [vec3] [parser] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.parser.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for PARSER.RB
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
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // PARSER ▞▞',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [parser] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.05
##/// Last Updated: 2026.01.05 | Trace.ID: parser.v1.0
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
# Parses .z3n files with PHENO binding syntax:
# - ⫸ 〔runtime.binding.context〕 blocks
# - ⫸ 〔runtime.prompt〕 blocks
# - Header governance stamps

require 'pathname'

module Vec3
  module Z3N
    class Parser
      BINDING_MARKER = '⫸ 〔runtime.binding.context〕'
      PROMPT_MARKER = '⫸ 〔runtime.prompt〕'
      HEADER_PATTERN = /^\/\/\/.*Status:.*\|.*Version:.*\|.*Authority:/

      attr_reader :header, :bindings, :prompt, :raw

      def initialize(content)
        @raw = content
        @header = {}
        @bindings = []
        @prompt = ''
        parse
      end

      def self.parse_file(path)
        content = File.read(path)
        new(content)
      end

      def parse
        lines = @raw.lines
        current_section = :header
        binding_config = { mode: 'wrap', cap: 12000 }

        lines.each do |line|
          stripped = line.strip

          # Detect section markers
          if stripped == BINDING_MARKER
            current_section = :binding
            next
          elsif stripped == PROMPT_MARKER
            current_section = :prompt
            next
          elsif stripped.start_with?('⫸')
            current_section = :unknown
            next
          end

          case current_section
          when :header
            parse_header_line(stripped)
          when :binding
            parse_binding_line(stripped, binding_config)
          when :prompt
            @prompt += line
          end
        end

        @prompt = @prompt.strip
      end

      private

      def parse_header_line(line)
        if line.match?(HEADER_PATTERN)
          parts = line.gsub('///', '').split('|').map(&:strip)
          parts.each do |part|
            key, value = part.split(':', 2).map(&:strip)
            @header[key.downcase.tr(' ', '_').to_sym] = value if key && value
          end
        end
      end

      def parse_binding_line(line, config)
        return if line.empty?

        case line
        when /^mode:(\w+)/
          config[:mode] = $1
        when /^cap:(\d+)/
          config[:cap] = $1.to_i
        when /^\+@\s+(.+)/
          @bindings << { type: :reference, path: $1.strip, cap: config[:cap] }
        when /^\+\?\s+(.+)/
          @bindings << { type: :optional, path: $1.strip, cap: config[:cap] }
        when /^\+\s+(.+)/
          @bindings << { type: :include, path: $1.strip, cap: config[:cap] }
        when /^\*\s+(.+)/
          @bindings << { type: :glob, pattern: $1.strip, cap: config[:cap] }
        when /^-\s+(.+)/
          @bindings << { type: :exclude, path: $1.strip }
        end
      end

      public

      # Resolve bindings to actual file contents
      def resolve(base_path: '.')
        base = Pathname.new(base_path)
        resolved = []

        @bindings.each do |binding|
          case binding[:type]
          when :include, :reference, :optional
            path = base.join(binding[:path])
            if path.exist?
              content = path.read
              content = content[0..binding[:cap]] if binding[:cap] && content.length > binding[:cap]
              resolved << {
                path: binding[:path],
                type: binding[:type],
                content: content,
                truncated: content.length < path.read.length
              }
            elsif binding[:type] != :optional
              resolved << { path: binding[:path], type: binding[:type], error: 'File not found' }
            end
          when :glob
            Dir.glob(base.join(binding[:pattern]).to_s).sort.each do |file|
              content = File.read(file)
              content = content[0..binding[:cap]] if binding[:cap] && content.length > binding[:cap]
              resolved << {
                path: file.sub(base.to_s + '/', ''),
                type: :glob_match,
                content: content
              }
            end
          end
        end

        resolved
      end

      # Build context bundle for LLM
      def build_bundle(base_path: '.')
        resolved = resolve(base_path: base_path)
        
        bundle = []
        resolved.each do |entry|
          next if entry[:error]
          
          role = case entry[:type]
                 when :reference then 'reference'
                 when :include, :glob_match then 'context'
                 when :optional then 'optional'
                 else 'context'
                 end
          
          bundle << "[CTX::#{entry[:path]}::role=#{role}]"
          bundle << entry[:content]
          bundle << ''
        end

        bundle << '[PROMPT]'
        bundle << @prompt

        bundle.join("\n")
      end

      def to_h
        {
          header: @header,
          bindings: @bindings,
          prompt: @prompt
        }
      end
    end
  end
end

# ═══════════════════════════════════════════════════════════════
# CLI
# ═══════════════════════════════════════════════════════════════

if __FILE__ == $PROGRAM_NAME
  require 'json'

  case ARGV[0]
  when 'parse'
    file = ARGV[1]
    unless file && File.exist?(file)
      puts "Usage: parser.rb parse <file.z3n>"
      exit 1
    end
    
    parser = Vec3::Z3N::Parser.parse_file(file)
    puts JSON.pretty_generate(parser.to_h)
    
  when 'bundle'
    file = ARGV[1]
    base = ARGV[2] || '.'
    unless file && File.exist?(file)
      puts "Usage: parser.rb bundle <file.z3n> [base_path]"
      exit 1
    end
    
    parser = Vec3::Z3N::Parser.parse_file(file)
    puts parser.build_bundle(base_path: base)
    
  else
    puts <<~USAGE
      ▛▞ Vec3::Z3N::Parser - Z3N File Parser
      
      Usage:
        parser.rb parse <file.z3n>           # Parse and show structure
        parser.rb bundle <file.z3n> [base]   # Build context bundle
      
      Z3N Format:
        ⫸ 〔runtime.binding.context〕
        +@ path/to/ref.md        # Include as reference
        + path/to/file.md        # Include
        +? path/to/optional.md   # Include if exists
        * path/to/*.md           # Glob include
        - path/to/exclude.md     # Exclude
        cap:4000                 # Set cap
        
        ⫸ 〔runtime.prompt〕
        Your prompt here
    USAGE
  end
end
# :: ∎