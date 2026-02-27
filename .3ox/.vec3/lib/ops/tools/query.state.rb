# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x85E2]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // QUERY.STATE.RB ▞▞
# ▛▞// QUERY.STATE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.query.state.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for QUERY.STATE.RB
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
##/// Last Updated: 2026.01.05 | Trace.ID: query.state.v1.0
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.05
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [query_state] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // QUERY.STATE ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# QUERY.STATE.RB :: Query unified watch state from Redis
#

require 'json'

# Add vec3 to path
VEC3_ROOT = File.expand_path('../..', File.dirname(__FILE__))
$LOAD_PATH.unshift(VEC3_ROOT) unless $LOAD_PATH.include?(VEC3_ROOT)

require_relative 'cache/redis.rb'

state = RedisCache.redis_get('cmd.bridge:unified:state')

if state && !state.empty?
  puts "▛▞// Unified Watch State"
  puts "▛▞// Watcher ID: #{state['watcher_id'] || 'none'}"
  puts "▛▞// Started: #{state['started_at']}"
  puts "▛▞// Last Update: #{state['updated_at'] || state['last_update']}"
  puts "▛▞// Sirius Time: #{state['sirius_time']}"
  puts ""
  
  if state['components'] && state['components'].any?
    puts "Components (#{state['components'].length}):"
    state['components'].each do |name, comp|
      status_icon = comp['alive'] ? '✓' : '✗'
      puts "  #{status_icon} #{name}: #{comp['status']} (age: #{comp['age_seconds']}s)"
    end
    puts ""
  end
  
  if state['stats']
    stats = state['stats']
    puts "Statistics:"
    puts "  Total Files: #{stats['total_files'] || 0}"
    puts "  Active Components: #{stats['active_components'] || 0}"
    puts "  New Files: #{stats['new_files'] || 0}"
    puts "  Modified Files: #{stats['modified_files'] || 0}"
    puts "  Moved Files: #{stats['moved_files'] || 0}"
    puts "  Deleted Files: #{stats['deleted_files'] || 0}"
    puts ""
  end
  
  if state['file_changes'] && (state['file_changes']['new'].any? || state['file_changes']['modified'].any?)
    changes = state['file_changes']
    puts "Recent Changes:"
    if changes['new'].any?
      puts "  New: #{changes['new'].length} files"
      changes['new'].first(5).each { |f| puts "    • #{f}" }
    end
    if changes['modified'].any?
      puts "  Modified: #{changes['modified'].length} files"
      changes['modified'].first(5).each { |f| puts "    • #{f}" }
    end
    puts ""
  end
  
  if state['locations'] && state['locations'].any?
    puts "Top Locations (#{state['locations'].keys.length} directories):"
    state['locations'].first(10).each do |location, files|
      puts "  📁 #{location}: #{files.length} files"
    end
  end
  
  puts ""
  puts "Full JSON available via: redis-cli GET cmd.bridge:unified:state"
else
  puts "▛▞// No unified state found"
  puts "▛▞// Start brains.exe to activate unified watch state"
  puts "▛▞//   ruby .3ox/vec3/lib/brains.exe.rb"
end

# :: ∎