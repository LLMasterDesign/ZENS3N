#!/usr/bin/env ruby
#
# LOG_DISCOVERY.RB :: Log new learnings for calibration updates
#

require 'time'
require 'fileutils'
require 'json'

CHANGELOG_PATH = "R:/!LAUNCH.PAD/!CITADEL.OPS/Promptbook/CALIBRATION.CHANGELOG.md"
DISCOVERY_LOG = "R:/!LAUNCH.PAD/!CMD.CENTER/Toolkit/.discovery.log"

def log_discovery(type, description, impact = "medium")
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  
  entry = {
    timestamp: timestamp,
    type: type,
    description: description,
    impact: impact
  }
  
  # Append to discovery log (JSON lines format)
  File.open(DISCOVERY_LOG, "a") do |f|
    f.puts entry.to_json
  end
  
  puts "✓ Discovery logged: #{type} - #{description}"
  puts "  Timestamp: #{timestamp}"
  puts "  Impact: #{impact}"
  puts "  Log: #{DISCOVERY_LOG}"
  
  # Also append to changelog pending section
  append_to_changelog(entry)
end

def append_to_changelog(entry)
  content = File.read(CHANGELOG_PATH)
  
  # Find PENDING DISCOVERIES section
  if content =~ /## ▛▞ PENDING DISCOVERIES ::\s*\n\s*### Awaiting Merge.*?\n\s*\n(.*?)\n\s*:: ∎/m
    pending_section = $1
    
    # Create new entry
    new_entry = <<~ENTRY
    **#{entry[:timestamp]}** | #{entry[:type]} | #{entry[:impact]}
    #{entry[:description]}
    
    ENTRY
    
    # Replace pending section
    updated_section = pending_section.strip
    updated_section = "None yet - fresh calibration." if updated_section.empty?
    updated_section = "" if updated_section == "None yet - fresh calibration."
    updated_section += "\n\n" unless updated_section.empty?
    updated_section += new_entry.strip
    
    content.sub!(
      /## ▛▞ PENDING DISCOVERIES ::\s*\n\s*### Awaiting Merge.*?\n\s*\n.*?\n\s*:: ∎/m,
      "## ▛▞ PENDING DISCOVERIES ::\n\n### Awaiting Merge to v1.1.0\n\n#{updated_section}\n\n:: ∎"
    )
    
    File.write(CHANGELOG_PATH, content)
    puts "✓ Added to CHANGELOG pending section"
  end
end

# Parse command line
if ARGV.length < 2
  puts "Usage: ruby log_discovery.rb <type> <description> [impact]"
  puts ""
  puts "Types: tool_call, pattern, integration, optimization, error_fix"
  puts "Impact: high, medium, low (default: medium)"
  puts ""
  puts "Example:"
  puts "  ruby log_discovery.rb tool_call 'grep supports multiline with -U flag' high"
  exit 1
end

type = ARGV[0]
description = ARGV[1]
impact = ARGV[2] || "medium"

log_discovery(type, description, impact)

puts ""
puts "To merge discoveries into calibration:"
puts "  ruby merge_discoveries.rb"

