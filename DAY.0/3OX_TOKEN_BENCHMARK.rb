#!/usr/bin/env ruby
# 3OX Token Benchmark :: Compare prose vs gensing syntax
# Token estimate: chars/4 (GPT-4 typical)

PAIRS = [
  {
    name: "Input-Process-Output flow",
    prose: <<~PROSE.strip,
      When the user provides input, you should validate and normalize it. Then map the request to the contract defined in tools.yml, routes.json, and limits.json. Finally, emit the agent response with logs and status.
    PROSE
    gensing: <<~GENSING.strip,
      ρ{Input} ≔ ingest.normalize.validate{user.prompt}
      φ{Bind} ≔ map.resolve.contract{tools.yml ∙ routes.json ∙ limits.json}
      τ{Output} ≔ emit.render.publish{agent.response ∙ logs ∙ status}
      :: ∎
    GENSING
  },
  {
    name: "PiCO trace",
    prose: <<~PROSE.strip,
      First, detect the user's request or business operation. Then process it with authoritative business focus. Next, carry the output through the system with structured response format. Finally, project the result to the user with business-ready output.
    PROSE
    gensing: <<~GENSING.strip,
      ⊢ ≔ detect.request{Lucius.command ∨ business.operation ∨ system.need}
      ⇨ ≔ process.business{authoritative ∙ production.focus ∙ system.maintain}
      ⟿ ≔ return.output{structured.response ∙ business.format ∙ system.persist}
      ▷ ≔ project.authority{business.system ∙ production.ready ∙ authoritative.output}
      :: ∎
    GENSING
  },
  {
    name: "File operation",
    prose: <<~PROSE.strip,
      When the user requests to create a file, validate the path, check permissions, write the content, then log a receipt.
    PROSE
    gensing: <<~GENSING.strip,
      ρ{Input} ≔ user.request{create.file}
      φ{Process} ≔ validate.path ∙ check.permissions ∙ write.content
      τ{Output} ≔ file.created{path} ∙ receipt.logged
      :: ∎
    GENSING
  },
  {
    name: "Sparkfile header",
    prose: <<~PROSE.strip,
      This is the ZENS3N sparkfile. It defines system identity and behavior. The document uses the PRISM kernel for input, process, and output flow. Version 1.0.0. Authority: ZENS3N.BASE.
    PROSE
    gensing: <<~GENSING.strip,
      ▛//▞▞ ⟦⎊⟧ :: ⧗-26.152 // ZENS3N.BASE :: Sparkfile ▞▞
      ▛▞// Sparkfile :: ρ{Config}.φ{Identity}.τ{System} ▹
      :: ∎
    GENSING
  },
  {
    name: "Section delimiter (×1)",
    prose: "That concludes this data section. Let me know if you need anything else.",
    gensing: ":: ∎",
  },
  {
    name: "Section delimiter (×10 repeated)",
    prose: ("That concludes this data section. " * 10).strip,
    gensing: (":: ∎\n" * 10).strip,
  },
  {
    name: "Conversation end",
    prose: "That's everything I have for now. Feel free to ask if you have more questions.",
    gensing: ":: 𝜵",
  },
]

def est_tokens(str)
  (str.bytesize / 4.0).ceil
end

puts "▛▞// 3OX TOKEN BENCHMARK"
puts "═" * 50
puts "Method: chars/4 ≈ tokens (GPT-4 typical)"
puts ""

total_prose_chars = 0
total_prose_tokens = 0
total_gensing_chars = 0
total_gensing_tokens = 0

PAIRS.each_with_index do |pair, i|
  prose_c = pair[:prose].bytesize
  gensing_c = pair[:gensing].bytesize
  prose_t = est_tokens(pair[:prose])
  gensing_t = est_tokens(pair[:gensing])
  savings = prose_t > 0 ? ((1 - gensing_t.to_f / prose_t) * 100).round(1) : 0

  total_prose_chars += prose_c
  total_prose_tokens += prose_t
  total_gensing_chars += gensing_c
  total_gensing_tokens += gensing_t

  puts "[#{i + 1}] #{pair[:name]}"
  puts "    Prose:   #{prose_c} chars, ~#{prose_t} tokens"
  puts "    Gensing: #{gensing_c} chars, ~#{gensing_t} tokens"
  puts "    Savings: #{savings}%"
  puts ""
end

overall_savings = total_prose_tokens > 0 ? ((1 - total_gensing_tokens.to_f / total_prose_tokens) * 100).round(1) : 0

puts "═" * 50
puts "TOTAL"
puts "  Prose:   #{total_prose_chars} chars, ~#{total_prose_tokens} tokens"
puts "  Gensing: #{total_gensing_chars} chars, ~#{total_gensing_tokens} tokens"
puts "  Overall savings: #{overall_savings}%"
puts ""
puts "Note: Use tiktoken for exact counts. chars/4 is conservative estimate."
puts ":: ∎"
