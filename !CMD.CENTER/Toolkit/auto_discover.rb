#!/usr/bin/env ruby
#
# AUTO_DISCOVER.RB :: Automatic discovery tracking
#

require 'json'
require 'fileutils'

COUNTER_FILE = "R:/!LAUNCH.PAD/!CITADEL.OPS/.3ox/turn_counter.json"
DISCOVERY_SCRIPT = "R:/!LAUNCH.PAD/!CMD.CENTER/Toolkit/log_discovery.rb"

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
  
  # Check if discovery should be triggered
  turns_since_last = counter[:turn_count] - counter[:last_discovery_turn]
  
  if counter[:auto_discovery_enabled] && turns_since_last >= counter[:discovery_interval]
    trigger_discovery(counter)
    counter[:last_discovery_turn] = counter[:turn_count]
    counter[:pending_observations] = []
  end
  
  save_counter(counter)
  
  {
    turn: counter[:turn_count],
    next_discovery_in: counter[:discovery_interval] - turns_since_last,
    pending_observations: counter[:pending_observations].length
  }
end

def trigger_discovery(counter)
  return if counter[:pending_observations].empty?
  
  # Summarize observations
  observations = counter[:pending_observations].map { |o| o[:observation] }.join("; ")
  summary = "Periodic checkpoint (#{counter[:pending_observations].length} observations): #{observations}"
  
  # Log discovery
  system("ruby #{DISCOVERY_SCRIPT} pattern \"#{summary}\" medium")
  
  puts ""
  puts "🔍 AUTO-DISCOVERY TRIGGERED"
  puts "   Turn: #{counter[:turn_count]}"
  puts "   Observations: #{counter[:pending_observations].length}"
  puts "   Next check: +#{counter[:discovery_interval]} turns"
end

def add_observation(text)
  counter = load_counter
  counter[:pending_observations] << {
    turn: counter[:turn_count],
    observation: text,
    timestamp: Time.now.iso8601
  }
  save_counter(counter)
  
  puts "✓ Observation queued: #{text}"
  puts "  Current observations: #{counter[:pending_observations].length}"
  puts "  Next auto-discovery: #{counter[:discovery_interval] - (counter[:turn_count] - counter[:last_discovery_turn])} turns"
end

def status
  counter = load_counter
  turns_since = counter[:turn_count] - counter[:last_discovery_turn]
  
  puts "═══════════════════════════════════════════"
  puts "AUTO-DISCOVERY STATUS"
  puts "═══════════════════════════════════════════"
  puts "Enabled: #{counter[:auto_discovery_enabled]}"
  puts "Current turn: #{counter[:turn_count]}"
  puts "Interval: #{counter[:discovery_interval]}"
  puts "Turns since last: #{turns_since}"
  puts "Next discovery: #{counter[:discovery_interval] - turns_since} turns"
  puts "Pending observations: #{counter[:pending_observations].length}"
  puts "═══════════════════════════════════════════"
  
  if counter[:pending_observations].any?
    puts ""
    puts "Queued observations:"
    counter[:pending_observations].each_with_index do |obs, i|
      puts "  #{i + 1}. [Turn #{obs[:turn]}] #{obs[:observation]}"
    end
  end
end

# Command line interface
case ARGV[0]
when "increment", "tick"
  observation = ARGV[1]
  result = increment_turn(observation)
  puts "Turn: #{result[:turn]}"
  puts "Next discovery in: #{result[:next_discovery_in]} turns"
  
when "observe", "add"
  text = ARGV[1..-1].join(" ")
  add_observation(text)
  
when "status"
  status
  
when "reset"
  save_counter(default_counter)
  puts "✓ Counter reset"
  
else
  puts "Usage:"
  puts "  ruby auto_discover.rb increment [observation]  # Increment turn, optionally add observation"
  puts "  ruby auto_discover.rb observe <text>           # Queue observation without incrementing"
  puts "  ruby auto_discover.rb status                   # Show current status"
  puts "  ruby auto_discover.rb reset                    # Reset counter"
  puts ""
  puts "Example:"
  puts "  ruby auto_discover.rb increment 'Found new grep flag'"
  puts "  ruby auto_discover.rb observe 'Routing can auto-create dirs'"
end

