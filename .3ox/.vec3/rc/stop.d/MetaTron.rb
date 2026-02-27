# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xEB97]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // METATRON.RB ▞▞
# ▛▞// METATRON.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [kernel] [prism] [vec3] [stopd] [metatron] [⊢ ⇨ ⟿ ▷]
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
# vec3/rc/stop.d/MetaTron.rb - MetaTron Stop Script
# Part of 3OX.Ai (ZEN-6)
#
# Stop the MetaTron supervisor service

require 'fileutils'

module Vec3
  module StopD
    class MetaTron
      PID_DIR = File.expand_path('../run', __dir__)
      PID_FILE = File.join(PID_DIR, 'metatron.pid')
      
      def self.stop
        unless File.exist?(PID_FILE)
          puts "⚠️  MetaTron is not running (no PID file)"
          return false
        end
        
        pid = File.read(PID_FILE).strip.to_i
        
        if pid <= 0
          puts "❌ Invalid PID in #{PID_FILE}"
          File.delete(PID_FILE) if File.exist?(PID_FILE)
          return false
        end
        
        begin
          # Check if process is running
          Process.kill(0, pid)
          
          # Send SIGTERM
          puts "🛑 Sending SIGTERM to MetaTron (PID: #{pid})..."
          Process.kill('TERM', pid)
          
          # Wait for graceful shutdown (max 10 seconds)
          10.times do
            sleep 1
            begin
              Process.kill(0, pid)
            rescue Errno::ESRCH
              puts "✅ MetaTron stopped gracefully"
              File.delete(PID_FILE) if File.exist?(PID_FILE)
              return true
            end
          end
          
          # Force kill if still running
          puts "⚠️  MetaTron did not stop gracefully, sending SIGKILL..."
          Process.kill('KILL', pid)
          sleep 1
          File.delete(PID_FILE) if File.exist?(PID_FILE)
          puts "✅ MetaTron force stopped"
          true
          
        rescue Errno::ESRCH
          puts "⚠️  MetaTron process (PID: #{pid}) not found"
          File.delete(PID_FILE) if File.exist?(PID_FILE)
          false
        rescue Errno::EPERM
          puts "❌ Permission denied to stop MetaTron (PID: #{pid})"
          false
        end
      end
    end
  end
end

# Run if executed directly
if __FILE__ == $0
  puts "▛//▞▞ ⟦⚡⟧ :: METATRON STOP ▞▞"
  puts
  Vec3::StopD::MetaTron.stop
  
  # Final message
  puts
  puts "⚡ METATRON: The gate closes; truth remains witnessed."
end

# :: ∎