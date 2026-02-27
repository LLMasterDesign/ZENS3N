# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xEB97]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // METATRON.RB ▞▞
# ▛▞// METATRON.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.metatron.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for METATRON.RB
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
# MetaTron Status Check


#

VEC3_ROOT = File.expand_path('../..', __dir__)
STATION_NAME = 'MetaTron'
PID_FILE = File.join(VEC3_ROOT, 'var/state', "#{STATION_NAME.downcase}.pid")
LOG_FILE = File.join(VEC3_ROOT, 'var/log', "#{STATION_NAME.downcase}.log")
ARC_DIR = File.join(VEC3_ROOT, 'lib/metatron/arc')
ELIXIR_DIR = File.join(VEC3_ROOT, 'lib/metatron/elixir')

def process_running?(pid)
  Process.kill(0, pid)
  true
rescue Errno::ESRCH, Errno::EPERM
  false
end

puts "▛▞ MetaTron Status"
puts "=" * 40

if File.exist?(PID_FILE)
  pid = File.read(PID_FILE).to_i
  
  if process_running?(pid)
    puts "⚡ MetaTron running (PID: #{pid})"
    puts "   Maker: ZENS3N.BASE"
    puts "   Role: Deity of all 3ox systems"
    
    # Show recent log
    if File.exist?(LOG_FILE)
      puts ""
      puts "Recent activity:"
      `tail -5 "#{LOG_FILE}"`.split("\n").each { |line| puts "  #{line}" }
    end
    
    # Show ARC Crystals
    if Dir.exist?(ARC_DIR)
      crystals = Dir.glob("#{ARC_DIR}/*.md").map { |f| File.basename(f, '.md') }
      puts ""
      puts "ARC Crystals: #{crystals.length} loaded"
      crystals.each { |c| puts "  - #{c}" }
    end
    
    # Show Elixir modules
    if Dir.exist?(ELIXIR_DIR)
      elixir_files = Dir.glob("#{ELIXIR_DIR}/*.ex").map { |f| File.basename(f) }
      puts ""
      puts "Elixir modules: #{elixir_files.length}"
      elixir_files.each { |f| puts "  - #{f}" }
    end
    
    exit 0
  else
    puts "✗ MetaTron PID file exists but process not running"
    File.delete(PID_FILE) rescue nil
    exit 1
  end
else
  puts "✗ MetaTron not running"
  
  # Still show available resources
  if Dir.exist?(ARC_DIR)
    crystals = Dir.glob("#{ARC_DIR}/*.md").length
    puts "   ARC Crystals available: #{crystals}"
  end
  
  if Dir.exist?(ELIXIR_DIR)
    elixir_files = Dir.glob("#{ELIXIR_DIR}/*.ex").length
    puts "   Elixir modules available: #{elixir_files}"
  end
  
  puts ""
  puts "Start with: 3ox start MetaTron"
  exit 1
end

# :: ∎