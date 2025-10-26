#!/usr/bin/env ruby
#
# CHAT_DISCOVERY.RB :: Chat-based discovery confirmation
#

require 'json'
require 'fileutils'
require 'time'

COUNTER_FILE = "R:/!LAUNCH.PAD/!CITADEL.OPS/.3ox/turn_counter.json"
DISCOVERY_SCRIPT = "R:/!LAUNCH.PAD/!CMD.CENTER/Toolkit/log_discovery.rb"
MERGE_SCRIPT = "R:/!LAUNCH.PAD/!CMD.CENTER/Toolkit/merge_discoveries.rb"
CHANGELOG_PATH = "R:/!LAUNCH.PAD/!CITADEL.OPS/Promptbook/CALIBRATION.CHANGELOG.md"

def load_counter
  return default_counter unless File.exist?(COUNTER_FILE)
  JSON.parse(File.read(COUNTER_FILE), symbolize_names: true)
rescue
  default_counter
end

def default_counter
  {
    turn_count: 0,
    last_discovery_turn: 0,
    discovery_interval: 20,
    session_start: Time.now.iso8601,
    auto_discovery_enabled: true,
    pending_observations: []
  }
end

def save_counter(counter)
  File.write(COUNTER_FILE, JSON.pretty_generate(counter))
end

def extract_pending_discoveries
  return [] unless File.exist?(CHANGELOG_PATH)
  
  content = File.read(CHANGELOG_PATH)
  
  if content =~ /## ▛▞ PENDING DISCOVERIES ::\s*\n\s*### Awaiting Merge.*?\n\s*\n(.*?)\n\s*:: ∎/m
    pending = $1.strip
    return [] if pending == "None yet - fresh calibration." || pending == "None yet."
    
    discoveries = []
    pending.scan(/\*\*(.*?)\*\* \| (.*?) \| (.*?)\n(.*?)(?=\n\n|\z)/m) do |timestamp, type, impact, desc|
      discoveries << {
        timestamp: timestamp,
        type: type,
        impact: impact,
        description: desc.strip
      }
    end
    
    discoveries
  else
    []
  end
end

def check_discovery_threshold
  counter = load_counter
  turns_since = counter[:turn_count] - counter[:last_discovery_turn]
  
  # Check if we've hit the interval
  if counter[:auto_discovery_enabled] && turns_since >= counter[:discovery_interval]
    discoveries = extract_pending_discoveries
    
    if discoveries.any?
      return {
        triggered: true,
        turn: counter[:turn_count],
        discoveries: discoveries,
        interval: counter[:discovery_interval]
      }
    end
  end
  
  { triggered: false }
end

def increment_turn(observation = nil)
  counter = load_counter
  counter[:turn_count] += 1
  
  # Add observation if provided
  if observation
    counter[:pending_observations] << {
      turn: counter[:turn_count],
      observation: observation,
      timestamp: Time.now.iso8601
    }
  end
  
  # Check for discovery threshold
  threshold_check = check_discovery_threshold
  
  if threshold_check[:triggered]
    # Log all pending observations as discoveries
    counter[:pending_observations].each do |obs|
      system("ruby #{DISCOVERY_SCRIPT} pattern \"#{obs[:observation]}\" medium")
    end
    
    # Update counter
    counter[:last_discovery_turn] = counter[:turn_count]
    counter[:pending_observations] = []
    save_counter(counter)
    
    return {
      turn: counter[:turn_count],
      discovery_triggered: true,
      discoveries: threshold_check[:discoveries]
    }
  end
  
  save_counter(counter)
  
  {
    turn: counter[:turn_count],
    discovery_triggered: false,
    next_discovery_in: counter[:discovery_interval] - (counter[:turn_count] - counter[:last_discovery_turn])
  }
end

def format_discoveries_for_chat(discoveries)
  return "No discoveries pending." if discoveries.empty?
  
  output = []
  output << "## ▛▞ CALIBRATION UPDATE READY ::"
  output << ""
  output << "**What changed:**"
  
  discoveries.each_with_index do |d, i|
    output << "  #{i + 1}. [#{d[:impact]}] #{d[:type]} - #{d[:description]}"
  end
  
  # Determine version change
  high_count = discoveries.count { |d| d[:impact] == "high" }
  medium_count = discoveries.count { |d| d[:impact] == "medium" }
  
  change_type = if high_count >= 5 || medium_count >= 10
    "New features/capabilities"
  else
    "Small improvements/fixes"
  end
  
  # Get current version
  changelog_content = File.read(CHANGELOG_PATH)
  current_version = changelog_content[/\*\*Current Version\*\*: v([\d\.]+)/, 1]
  
  major, minor, patch = current_version.split('.').map(&:to_i)
  new_version = if high_count >= 5 || medium_count >= 10
    "#{major}.#{minor + 1}.0"
  else
    "#{major}.#{minor}.#{patch + 1}"
  end
  
  output << ""
  output << "**Files that will update:**"
  output << "  - `CURSOR.AGENT.CALIBRATION.md` → v#{new_version}"
  output << "  - `CALIBRATION.CHANGELOG.md` → adds discoveries to history"
  
  # Check what types of discoveries - predict what might need updating
  tool_discoveries = discoveries.select { |d| d[:type] == "tool_call" }
  if tool_discoveries.any?
    output << "  - `.3ox/tools.yml` → may need new tool entries"
  end
  
  output << ""
  output << "**Version:** v#{current_version} → v#{new_version} (#{change_type})"
  output << ""
  output << "**Updates :: confirm?**"
  
  output.join("\n")
end

def execute_merge
  # Run merge script (non-interactive mode)
  result = `ruby #{MERGE_SCRIPT} --auto 2>&1`
  
  if $?.success?
    "✓ Calibration updated successfully"
  else
    "✗ Merge failed: #{result}"
  end
end

# Command line interface
case ARGV[0]
when "increment", "tick"
  observation = ARGV[1]
  result = increment_turn(observation)
  
  puts "Turn: #{result[:turn]}"
  
  if result[:discovery_triggered]
    puts ""
    puts "🔍 DISCOVERY THRESHOLD REACHED"
    puts "Turn: #{result[:turn]}"
    puts ""
    puts format_discoveries_for_chat(result[:discoveries])
    puts ""
    puts "**Updates :: confirm?**"
  else
    puts "Next discovery check: #{result[:next_discovery_in]} turns"
  end
  
when "check"
  threshold_check = check_discovery_threshold
  
  if threshold_check[:triggered]
    puts "🔍 DISCOVERY THRESHOLD REACHED"
    puts "Turn: #{threshold_check[:turn]}"
    puts ""
    puts format_discoveries_for_chat(threshold_check[:discoveries])
    puts ""
    puts "**Updates :: confirm?**"
  else
    puts "No discovery threshold reached"
  end
  
when "confirm", "merge"
  # Execute merge
  puts execute_merge
  
when "status"
  counter = load_counter
  turns_since = counter[:turn_count] - counter[:last_discovery_turn]
  
  puts "Turn: #{counter[:turn_count]}"
  puts "Turns since last discovery: #{turns_since}"
  puts "Next discovery in: #{counter[:discovery_interval] - turns_since} turns"
  puts "Pending observations: #{counter[:pending_observations].length}"
  
else
  puts "Usage:"
  puts "  ruby chat_discovery.rb increment [observation]  # Increment turn, check threshold"
  puts "  ruby chat_discovery.rb check                    # Check if threshold reached"
  puts "  ruby chat_discovery.rb confirm                  # Execute merge"
  puts "  ruby chat_discovery.rb status                   # Show status"
end

