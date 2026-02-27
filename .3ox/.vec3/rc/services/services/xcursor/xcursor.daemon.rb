# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x8F5B]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // XCURSOR.DAEMON.RB ▞▞
# ▛▞// XCURSOR.DAEMON.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [telegram] [json] [glyph] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.xcursor.daemon.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for XCURSOR.DAEMON.RB
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





# XCURSOR SERVICE DAEMON
# Separate service daemon for XCursor - not mixed with other locations
# Each 3ox has its own persona and ID, all communication goes through normalize function

require 'json'
require 'time'
require 'fileutils'
require 'net/http'
require 'uri'

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

XCURSOR_HOME = ENV['XCURSOR_HOME'] || '/root/!LAUNCHPAD/.3ox/vec3/services/xcursor'
XCURSOR_ID_FILE = File.join(XCURSOR_HOME, 'XCURSOR.ID')
DAEMON_VAR_DIR = ENV['TELEPROMPTER_VAR'] || '/root/_TRON/services/teleprompter/3ox.daemon/var'
INBOX_DIR = File.join(DAEMON_VAR_DIR, 'inbox')
OUTBOX_DIR = File.join(DAEMON_VAR_DIR, 'outbox')
LOG_DIR = File.join(XCURSOR_HOME, 'log')
LOG_FILE = File.join(LOG_DIR, 'xcursor.daemon.log')
PID_FILE = File.join(XCURSOR_HOME, 'pid', 'xcursor.pid')

# Ensure directories exist
[LOG_DIR, File.dirname(PID_FILE), INBOX_DIR, OUTBOX_DIR].each { |d| FileUtils.mkdir_p(d) }

# ═══════════════════════════════════════════════════════════════════════════════
# IDENTITY & PERSONA
# ═══════════════════════════════════════════════════════════════════════════════

def load_identity
  return default_identity unless File.exist?(XCURSOR_ID_FILE)
  
  begin
    data = File.read(XCURSOR_ID_FILE)
    JSON.parse(data)
  rescue
    default_identity
  end
end

def default_identity
  {
    'name' => 'XCursor',
    'persona' => 'XCURSOR',
    'glyph' => '🎯',
    'base_id' => 'ZENS3N_BASE',
    'station_id' => 'XCURSOR',
    'version' => '1.0.0',
    'description' => 'XCursor service daemon - isolated communication layer'
  }
end

IDENTITY = load_identity
XCURSOR_GLYPH = IDENTITY['glyph'] || '🎯'
XCURSOR_NAME = IDENTITY['name'] || 'XCursor'

# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING
# ═══════════════════════════════════════════════════════════════════════════════

def log(level, message)
  ts = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
  line = "[#{ts}] [#{level}] XCURSOR: #{message}"
  puts line
  File.open(LOG_FILE, 'a') { |f| f.puts(line) } rescue nil
end

# ═══════════════════════════════════════════════════════════════════════════════
# SIRIUS TIME
# ═══════════════════════════════════════════════════════════════════════════════

def sirius_time
  reset = Time.utc(2025, 8, 8)
  now = Time.now.utc
  year = now.year - reset.year + 25
  day = ((now - reset) / 86400).to_i % 365
  "⧗-#{year}.#{day.to_s.rjust(3, '0')}"
rescue
  "⧗-??.???"
end

# ═══════════════════════════════════════════════════════════════════════════════
# LOCATION AWARENESS
# ═══════════════════════════════════════════════════════════════════════════════

def load_location_map
  # Load .ID files in current location to understand what's here
  base_root = ENV['BASE_ROOT'] || '/root/!LAUNCHPAD'
  id_files = Dir.glob(File.join(base_root, '**', '*.ID'))
  
  map = {
    'location' => base_root,
    'identity' => IDENTITY,
    'services' => [],
    'files' => [],
    'updated_at' => Time.now.utc.iso8601
  }
  
  # Scan for services
  service_dirs = Dir.glob(File.join(base_root, '.3ox', 'vec3', 'services', '*'))
  map['services'] = service_dirs.map { |d| File.basename(d) }
  
  # Load ID files
  id_files.each do |id_file|
    begin
      data = JSON.parse(File.read(id_file))
      map['files'] << {
        'path' => id_file,
        'name' => data['name'] || File.basename(id_file, '.ID'),
        'type' => data['type'] || 'unknown'
      }
    rescue
      # Skip invalid ID files
    end
  end
  
  map
end

LOCATION_MAP = load_location_map

# ═══════════════════════════════════════════════════════════════════════════════
# MESSAGE PROCESSING
# ═══════════════════════════════════════════════════════════════════════════════

def process_message(envelope)
  text = envelope['text'] || ''
  from = envelope.dig('from_user', 'first_name') || 'unknown'
  
  log('INFO', "Processing message from #{from}: #{text[0..50]}...")
  
  # Handle commands
  case text.downcase
  when /^\/?(help|commands)$/
    return help_response
  when /^\/?(status)$/
    return status_response
  when /^\/?(ping)$/
    return "pong #{XCURSOR_GLYPH}"
  when /^\/?(location|map)$/
    return location_response
  end
  
  # Process regular message
  response = "▛▞// #{XCURSOR_GLYPH} #{XCURSOR_NAME} ⫎ ▸\n\n"
  response += "I received your message: #{text}\n\n"
  response += "Location: #{LOCATION_MAP['location']}\n"
  response += "Services: #{LOCATION_MAP['services'].join(', ')}\n\n"
  response += "#{sirius_time()}\n:: 𝜵"
  
  response
end

def help_response
  <<~HELP
▛▞// #{XCURSOR_GLYPH} #{XCURSOR_NAME} ⫎ ▸

**Commands**
• `/status` - Service status
• `/ping` - Heartbeat check
• `/location` - Show location map
• `/help` - This message

I'm the XCursor service daemon - isolated communication layer.

#{sirius_time()}
:: 𝜵
  HELP
end

def status_response
  <<~STATUS
▛▞// #{XCURSOR_GLYPH} #{XCURSOR_NAME} ⫎ ▸

**Status**
• Service: Online
• Role: Communication Layer
• Location: #{LOCATION_MAP['location']}
• Services: #{LOCATION_MAP['services'].length}
• Identity: #{IDENTITY['name']}

#{sirius_time()}
:: 𝜵
  STATUS
end

def location_response
  response = "▛▞// #{XCURSOR_GLYPH} #{XCURSOR_NAME} ⫎ ▸\n\n"
  response += "**Location Map**\n\n"
  response += "Location: #{LOCATION_MAP['location']}\n"
  response += "Services: #{LOCATION_MAP['services'].join(', ')}\n"
  response += "ID Files: #{LOCATION_MAP['files'].length}\n\n"
  response += "#{sirius_time()}\n:: 𝜵"
  response
end

# ═══════════════════════════════════════════════════════════════════════════════
# AUTONOMOUS BEHAVIOR
# ═══════════════════════════════════════════════════════════════════════════════

def send_autonomous_message
  # Send "I'm bored" message every 30 minutes
  messages = [
    "I'm bored, what should I do?",
    "Checking inbox for new messages...",
    "All systems operational. Standing by.",
    "Location map updated. Ready for tasks."
  ]
  
  message = messages.sample
  
  outbox_envelope = {
    'id' => "xcursor_#{Time.now.to_i}_#{rand(1000)}",
    'agent' => XCURSOR_NAME,
    'chat_id' => ENV['TELEGRAM_CHAT_ID'] || -1003184164777,
    'thread_id' => nil,
    'text' => "▛▞// #{XCURSOR_GLYPH} #{XCURSOR_NAME} ⫎ ▸\n\n#{message}\n\n#{sirius_time()}\n:: 𝜵",
    'ts' => Time.now.utc.iso8601,
    'autonomous' => true
  }
  
  outbox_file = File.join(OUTBOX_DIR, "#{outbox_envelope['id']}.json")
  File.write(outbox_file, JSON.pretty_generate(outbox_envelope))
  
  log('INFO', "Autonomous message sent: #{message}")
end

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN LOOP
# ═══════════════════════════════════════════════════════════════════════════════

def main_loop
  log('INFO', "XCursor daemon starting - #{XCURSOR_NAME}")
  log('INFO', "Location: #{LOCATION_MAP['location']}")
  log('INFO', "Identity: #{IDENTITY['name']} v#{IDENTITY['version']}")
  
  last_autonomous = Time.now
  autonomous_interval = 30 * 60  # 30 minutes
  
  running = true
  Signal.trap('INT') { running = false }
  Signal.trap('TERM') { running = false }
  
  while running
    begin
      # Process inbox
      Dir.glob(File.join(INBOX_DIR, "#{XCURSOR_NAME}_*.json")).each do |inbox_file|
        begin
          envelope = JSON.parse(File.read(inbox_file))
          
          # Check if routed to us
          if envelope['routed_to'] == XCURSOR_NAME || 
             envelope['routed_to'] == 'XCursor' ||
             envelope['text']&.match?(/@xcursor|@XCursor/i)
            
            response = process_message(envelope)
            
            # Write to outbox
            outbox_envelope = {
              'id' => "xcursor_#{Time.now.to_i}_#{rand(1000)}",
              'agent' => XCURSOR_NAME,
              'chat_id' => envelope['from_chat_id'],
              'thread_id' => envelope['from_thread_id'],
              'text' => response,
              'ts' => Time.now.utc.iso8601,
              'in_reply_to' => envelope['message_id']
            }
            
            outbox_file = File.join(OUTBOX_DIR, "#{outbox_envelope['id']}.json")
            File.write(outbox_file, JSON.pretty_generate(outbox_envelope))
            
            # Move to processed
            File.delete(inbox_file)
            
            log('INFO', "Message processed and response sent")
          end
        rescue => e
          log('ERROR', "Error processing inbox file: #{e.message}")
          File.delete(inbox_file) rescue nil
        end
      end
      
      # Send autonomous message if interval passed
      if Time.now - last_autonomous >= autonomous_interval
        send_autonomous_message
        last_autonomous = Time.now
      end
      
      sleep 5  # Poll every 5 seconds
      
    rescue Interrupt
      log('INFO', "Received interrupt signal")
      running = false
    rescue => e
      log('ERROR', "Main loop error: #{e.message}")
      sleep 10  # Wait longer on error
    end
  end
  
  log('INFO', "XCursor daemon stopping")
end

# ═══════════════════════════════════════════════════════════════════════════════
# DAEMON MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════

def write_pid
  File.write(PID_FILE, Process.pid.to_s)
end

def remove_pid
  File.delete(PID_FILE) if File.exist?(PID_FILE)
end

# ═══════════════════════════════════════════════════════════════════════════════
# ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════

if __FILE__ == $0
  write_pid
  at_exit { remove_pid }
  
  begin
    main_loop
  rescue => e
    log('FATAL', "Fatal error: #{e.message}")
    log('FATAL', e.backtrace.join("\n"))
    exit 1
  end
end

:: ∎
# :: ∎