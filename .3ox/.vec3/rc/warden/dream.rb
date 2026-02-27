# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xDRM]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.179 // DREAM.RB :: The Dream Daemon ▞▞
# ▛▞// DREAM :: ρ{Sleep}.φ{Dream}.τ{Awake} ▹
# //▞⋮⋮ ⟦💤⟧ :: [daemon] [dream] [entropy] [pulse] [⊢ ⇨ ⟿ ▷]

#!/usr/bin/env ruby
require 'json'
require 'fileutils'
require 'time'
require_relative '../tape/tape'

module Vec3
  class Dream
    # Path resolution: We are in vec3/rc/warden/
    # Go up 3 levels to get to 3ox.cmd/vec3/
    BASE_DIR = File.expand_path('../../..', __FILE__)
    
    # Define Core Paths
    META_DIR = File.join(File.dirname(BASE_DIR), '.meta') # .meta is sibling to vec3 in 3ox.cmd
    VAR_DIR = File.join(BASE_DIR, 'var')
    SPOOL_DIR = File.join(VAR_DIR, 'spool')
    PULSE_FILE = File.join(META_DIR, 'pulse.jsonl')
    MERKLE_FILE = File.join(META_DIR, 'merkle.root')
    
    # Thresholds
    PULSE_THRESHOLD = 300 # 5 minutes silence
    SPOOL_THRESHOLD = 10  # 10 items in spool
    
    # Teleprompter path
    TELEPROMPTER_BIN = "/root/!LAUNCHPAD/CMD.VPS/TelePromptR/3ox.station/vec3/bin/teleprompter.rb"
    
    def initialize
      @running = true
      ensure_dirs
    end
    
    def ensure_dirs
      FileUtils.mkdir_p(SPOOL_DIR)
      FileUtils.mkdir_p(META_DIR)
    end
    
    def cycle
      puts "::: DREAM :: Checking vitals..."
      
      check_entropy
      check_spool
      check_pulse
      
      puts "::: DREAM :: Cycle complete."
    end
    
    def check_entropy
      # If merkle.root hasn't changed in N cycles -> Verify integrity
      if File.exist?(MERKLE_FILE)
        mtime = File.mtime(MERKLE_FILE)
        age = Time.now - mtime
        
        if age > 3600 # 1 hour unchanged
          puts "::: DREAM :: Entropy low (Merkle unchanged for #{age.to_i}s). Verifying integrity..."
          Vec3::TAPE.append({
            kind: 'dream_event',
            action: 'verify_integrity',
            reason: 'entropy_low',
            age: age
          })
          # Trigger verification (simulated)
          FileUtils.touch(MERKLE_FILE) # Refresh for now
        end
      end
    end
    
    def check_spool
      # If var/spool/ size > Limit -> Trigger Memory Commit
      if Dir.exist?(SPOOL_DIR)
        count = Dir.entries(SPOOL_DIR).count - 2 # minus . and ..
        if count > SPOOL_THRESHOLD
          puts "::: DREAM :: Spool full (#{count} items). Triggering Commit..."
          Vec3::TAPE.append({
            kind: 'dream_event',
            action: 'commit_memory',
            reason: 'spool_full',
            count: count
          })
          # Trigger commit logic here
        end
      end
    end
    
    def check_pulse
      # If Pulse silent > Threshold -> Emit "status.check" event
      last_pulse = 0
      if File.exist?(PULSE_FILE)
        last_line = File.readlines(PULSE_FILE).last
        if last_line
          begin
            event = JSON.parse(last_line)
            last_pulse = Time.parse(event['ts']).to_i
          rescue
            last_pulse = File.mtime(PULSE_FILE).to_i
          end
        end
      else
        # Create pulse if missing
        update_pulse("system.init")
        last_pulse = Time.now.to_i
      end
      
      silence = Time.now.to_i - last_pulse
      
      if silence > PULSE_THRESHOLD
        puts "::: DREAM :: Boredom detected (Silent for #{silence}s). Emitting status check..."
        update_pulse("status.check")
        
        # Notify Telegram via Teleprompter
        if File.exist?(TELEPROMPTER_BIN)
          msg = "⚡ **ZENS3N**: Dream Cycle Active. Boredom detected (Silent for #{silence}s)."
          system("ruby", TELEPROMPTER_BIN, "send", msg)
        end

        Vec3::TAPE.append({
          kind: 'dream_event',
          action: 'status_check',
          reason: 'boredom',
          silence: silence
        })
      end
    end
    
    def update_pulse(event_type)
      FileUtils.mkdir_p(META_DIR)
      event = {
        ts: Time.now.utc.iso8601(3),
        event: event_type,
        origin: 'vec3.dream'
      }
      File.open(PULSE_FILE, 'a') do |f|
        f.puts(JSON.generate(event))
      end
    end
  end
end

# Run one cycle if executed directly
if __FILE__ == $0
  Vec3::Dream.new.cycle
end
