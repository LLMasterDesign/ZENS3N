# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x7D28]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // ANALYSIS_DASHBOARD.RB ▞▞
# ▛▞// ANALYSIS_DASHBOARD.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.analysis_dashboard.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for ANALYSIS_DASHBOARD.RB
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
# ANALYSIS_DASHBOARD.RB :: Monitor cursor agent analysis progress
# Shows status of all running agents and completion progress
#

TOOLS_DIR = File.expand_path(__dir__)
THREEX_ROOT = File.expand_path('../../../../..', __dir__) # /.../.3ox
CMD_ROOT = File.expand_path('..', THREEX_ROOT)           # /.../!CMD.BRIDGE
FORGE_REVIEW_DIR = File.join(CMD_ROOT, '!WORKDESK', '3OX.FORGE', 'review')
def tool_path(name) = File.join(TOOLS_DIR, name)

def show_dashboard
module Z3N
  SPEC = {
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // ANALYSIS_DASHBOARD ▞▞',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [analysis_dashboard] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.05
##/// Last Updated: 2026.01.05 | Trace.ID: analysis_dashboard.v1.0
##/// Purpose: !/usr/bin/env ruby
##///          (Add second line of purpose here)
##///          (Add third line of purpose here)
#```
#
#▛//▞ TOOLSET ::
#(Add toolset commands here)
#/command1 = description1
#/command2 = description2
  puts "▛//▞▞ ⟦⎊⟧ :: ANALYSIS DASHBOARD :: 147 Files ▞▞"
  puts ""

  # Count analysis files
  review_dir = FORGE_REVIEW_DIR
  total_files = Dir.glob("#{review_dir}/*.analysis.md").length

  # Count git branches (rough proxy for agent count)
  branches = `git branch -r 2>/dev/null | grep -c 3ox.agent`.to_i

  # Count merged branches (files that exist in main)
  merged_count = 0
  Dir.glob("#{review_dir}/*.analysis.md").each do |file|
    basename = File.basename(file)
    merged_count += 1 if system("git show main:#{basename} > /dev/null 2>&1")
  end

  remaining = total_files - merged_count

  puts "▛▞// 📊 PROGRESS OVERVIEW"
  puts "▛▞// Total Analysis Files: #{total_files}"
  puts "▛▞// Active Agent Branches: #{branches}"
  puts "▛▞// Completed & Merged: #{merged_count}"
  puts "▛▞// Remaining: #{remaining}"
  puts ""

  # Progress bar
  progress_percent = total_files > 0 ? (merged_count * 100.0 / total_files).round(1) : 0
  bar_width = 50
  filled = (progress_percent * bar_width / 100).to_i
  bar = "█" * filled + "░" * (bar_width - filled)

  puts "▛▞// Progress: [#{bar}] #{progress_percent}%"
  puts ""

  # Status indicators
  if branches > 0
    puts "▛▞// 🚀 STATUS: Agents actively processing"
    puts "▛▞// 💡 TIP: Run batch merge when agents complete:"
    puts "▛▞//     ruby \"#{tool_path('batch_process_analyses.rb')}\" --all"
  elsif remaining > 0
    puts "▛▞// ⏳ STATUS: Ready for batch processing"
    puts "▛▞// 🎯 ACTION: Merge completed analyses:"
    puts "▛▞//     ruby \"#{tool_path('batch_process_analyses.rb')}\" --all"
  else
    puts "▛▞// ✅ STATUS: All analyses processed!"
    puts "▛▞// 🧹 CLEANUP: Remove lingering files:"
    puts "▛▞//     ruby \"#{tool_path('batch_process_analyses.rb')}\" --cleanup"
  end

  puts ""
  puts "▛▞// 📈 PERFORMANCE METRICS"
  puts "▛▞// Parallel agents reduce processing time significantly"
  puts "▛▞// Each agent processes one file independently"
  puts "▛▞// Batch operations handle merges and cleanup efficiently"

  puts ""
  puts ":: ∎"
end

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __FILE__ == $0
  # Change to workspace root
  Dir.chdir(CMD_ROOT)

  show_dashboard
end

# :: ∎