# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA502]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // FIND_LOST_AGENTS.RB ▞▞
# ▛▞// FIND_LOST_AGENTS.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.find_lost_agents.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for FIND_LOST_AGENTS.RB
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
##/// Last Updated: 2026.01.07 | Trace.ID: find_lost_agents.v1.0
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.07
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [find_lost_agents] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // FIND_LOST_AGENTS ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# FIND_LOST_AGENTS.RB :: Find agent IDs that need recovery
#

def find_agent_ids_in_logs
  """Find agent IDs in log files"""
  agent_ids = []

  # Search all log files for agent IDs
  Dir.glob("/root/!CMD.BRIDGE/**/*.log").each do |log_file|
    next unless File.file?(log_file)

    File.readlines(log_file).each do |line|
      # Match agent IDs (format: bc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
      if line =~ /bc-[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/
        agent_id = $&
        agent_ids << agent_id unless agent_ids.include?(agent_id)
      end
    end
  end

  agent_ids.uniq
end

def check_agent_batch(agent_ids)
  """Check status of a batch of agents"""
  require_relative 'vec3/lib/core/cursor.api.rb'

  puts "🔍 Checking #{agent_ids.length} agents..."

  completed = []
  running = []
  errors = []

  agent_ids.each do |agent_id|
    begin
      status = CursorAPI.check_agent_status(agent_id)
      if status && status['status'] == 'FINISHED'
        completed << agent_id
        summary = status['summary'] || 'No summary'
        puts "✅ #{agent_id}: COMPLETED - #{summary[0..100]}..."
      elsif status && status['status'] == 'RUNNING'
        running << agent_id
        puts "🔄 #{agent_id}: RUNNING"
      else
        errors << agent_id
        puts "❌ #{agent_id}: ERROR"
      end
    rescue => e
      errors << agent_id
      puts "❌ #{agent_id}: EXCEPTION - #{e.message}"
    end

    sleep 1 # Rate limiting
  end

  puts ""
  puts "📊 RESULTS:"
  puts "✅ Completed: #{completed.length}"
  puts "🔄 Running: #{running.length}"
  puts "❌ Errors: #{errors.length}"

  completed
end

def generate_recovery_commands(completed_agents)
  """Generate commands to recover completed agents"""
  puts ""
  puts "🔧 RECOVERY COMMANDS:"
  puts "=" * 50

  # For demo, associate with known files (in real system would track this)
  known_files = [
    "0UT.3OX.PROTOCOL.SPEC.md",
    "0UT.3OX_README.md",
    "2025.12.6.3oxLoad.Journal.md",
    "2025.12.7.VaultRecovery.Journal.md",
    "2025.12.7.VaultRecovery.Plan.md"
  ]

  completed_agents.each_with_index do |agent_id, index|
    filename = known_files[index] || "unknown_file_#{index}.md"
    puts "ruby agent_recovery.rb --agent #{agent_id} --file \"#{filename}\""
  end

  puts ""
  puts "💡 Run these commands to recover each completed agent's analysis!"
end

def main
  puts "🔍 FINDING LOST AGENTS"
  puts "=" * 50

  # Find agent IDs
  agent_ids = find_agent_ids_in_logs

  if agent_ids.empty?
    puts "❌ No agent IDs found in logs"
    puts ""
    puts "💡 Try running these recent agent IDs manually:"
    puts "ruby agent_recovery.rb --agent bc-be8affa0-3b8c-4cbd-b0a6-cdc6b1c049fc --file \"0UT.3OX.PROTOCOL.SPEC.md\""
    puts "ruby agent_recovery.rb --agent bc-b418c0d5-f4b9-4eb1-b8c7-0936957d2452 --file \"0UT.3OX_README.md\""
    return
  end

  puts "Found #{agent_ids.length} agent IDs:"
  agent_ids.each { |id| puts "  • #{id}" }
  puts ""

  # Check their status
  completed = check_agent_batch(agent_ids)

  if completed.empty?
    puts "❌ No completed agents found"
    return
  end

  # Generate recovery commands
  generate_recovery_commands(completed)
end

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __FILE__ == $0
  main
end

# :: ∎