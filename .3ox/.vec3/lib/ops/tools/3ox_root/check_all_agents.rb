# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x81FB]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // CHECK_ALL_AGENTS.RB ▞▞
# ▛▞// CHECK_ALL_AGENTS.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.check_all_agents.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for CHECK_ALL_AGENTS.RB
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
#
# CHECK_ALL_AGENTS.RB :: Monitor all running cursor agents at once
#

# List of agent IDs we've launched (add them here as we launch more)
AGENT_IDS = [
  "bc-be8affa0-3b8c-4cbd-b0a6-cdc6b1c049fc", # 0UT.3OX.PROTOCOL.SPEC.md
  "bc-b418c0d5-f4b9-4eb1-b8c7-0936957d2452", # 0UT.3OX_README.md
  "bc-88591699-0263-4b18-a6cf-7463b732ddde", # 2025.12.6.3oxLoad.Journal.md
  "bc-6e997c9c-ad40-4446-b451-d201b095b6bd", # 2025.12.7.VaultRecovery.Journal.md
  "bc-1459d65e-9479-4ac7-9f65-130fcef0423e", # 2025.12.7.VaultRecovery.Plan.md
]

def check_agent_status(agent_id)
  require_relative 'vec3/lib/core/cursor.api.rb'

  begin
    status = CursorAPI.check_agent_status(agent_id)
    if status
      status['status']
    else
      'ERROR'
    end
  rescue => e
    'ERROR'
  end
end

def show_all_statuses
module Z3N
  SPEC = {
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // CHECK_ALL_AGENTS ▞▞',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [check_all_agents] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.05
##/// Last Updated: 2026.01.05 | Trace.ID: check_all_agents.v1.0
##/// Purpose: !/usr/bin/env ruby
##///          (Add second line of purpose here)
##///          (Add third line of purpose here)
#```
#
#▛//▞ TOOLSET ::
#(Add toolset commands here)
#/command1 = description1
#/command2 = description2
  puts "▛//▞▞ ⟦⎊⟧ :: AGENT STATUS DASHBOARD ▞▞"
  puts ""

  completed = []
  running = []
  creating = []
  errors = []

  AGENT_IDS.each do |agent_id|
    status = check_agent_status(agent_id)

    case status
    when 'FINISHED'
      completed << agent_id
    when 'RUNNING'
      running << agent_id
    when 'CREATING'
      creating << agent_id
    else
      errors << agent_id
    end

    puts "▛▞// #{agent_id}: #{status}"
  end

  puts ""
  puts "▛▞// 📊 SUMMARY"
  puts "▛▞// Completed: #{completed.length}"
  puts "▛▞// Running: #{running.length}"
  puts "▛▞// Creating: #{creating.length}"
  puts "▛▞// Errors: #{errors.length}"
  puts ""

  if completed.length > 0
    puts "▛▞// ✅ READY TO MERGE:"
    completed.each do |agent_id|
      puts "▛▞//   ruby analyze_review_docs.rb --status #{agent_id}"
      puts "▛▞//   # Then find and merge the branch"
    end
  end

  puts ""
  puts ":: ∎"
end

# Run if called directly
if __FILE__ == $0
  show_all_statuses
end

# :: ∎