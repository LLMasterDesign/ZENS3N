#!/usr/bin/env ruby
#
# MERGE_DISCOVERIES.RB :: Merge logged discoveries into calibration prompt
#

require 'fileutils'

CHANGELOG_PATH = "R:/!LAUNCH.PAD/!CITADEL.OPS/Promptbook/CALIBRATION.CHANGELOG.md"
CALIBRATION_PATH = "R:/!LAUNCH.PAD/!CITADEL.OPS/Promptbook/CURSOR.AGENT.CALIBRATION.md"
DISCOVERY_LOG = "R:/!LAUNCH.PAD/!CMD.CENTER/Toolkit/.discovery.log"

def extract_pending_discoveries
  content = File.read(CHANGELOG_PATH)
  
  if content =~ /## ▛▞ PENDING DISCOVERIES ::\s*\n\s*### Awaiting Merge.*?\n\s*\n(.*?)\n\s*:: ∎/m
    pending = $1.strip
    return [] if pending == "None yet - fresh calibration."
    
    # Parse discoveries
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

def bump_version(current, bump_type)
  major, minor, patch = current.split('.').map(&:to_i)
  
  case bump_type
  when :major
    "#{major + 1}.0.0"
  when :minor
    "#{major}.#{minor + 1}.0"
  when :patch
    "#{major}.#{minor}.#{patch + 1}"
  end
end

def determine_bump_type(discoveries)
  high_count = discoveries.count { |d| d[:impact] == "high" }
  medium_count = discoveries.count { |d| d[:impact] == "medium" }
  
  if high_count >= 5 || medium_count >= 10
    :minor
  else
    :patch
  end
end

def update_calibration_version(new_version)
  content = File.read(CALIBRATION_PATH)
  content.sub!(/\*\*Version\*\*: \d+\.\d+\.\d+/, "**Version**: #{new_version}")
  content.sub!(/\*\*Last Updated\*\*: [\d\-]+/, "**Last Updated**: #{Time.now.strftime('%Y-%m-%d')}")
  
  File.write(CALIBRATION_PATH, content)
end

def move_to_history(discoveries, new_version)
  content = File.read(CHANGELOG_PATH)
  
  # Create new version entry
  timestamp = Time.now.strftime('%Y-%m-%d')
  changes_list = discoveries.map { |d| "- [#{d[:type]}] #{d[:description]}" }.join("\n")
  
  new_entry = <<~ENTRY
  
  ### v#{new_version} - #{timestamp}
  **Status**: CURRENT
  
  **Changes**:
  #{changes_list}
  
  **Merged from**: #{discoveries.length} discoveries
  
  :: ∎
  ENTRY
  
  # Update VERSION HISTORY (mark old as previous, add new)
  content.sub!(/### v([\d\.]+) - ([\d\-]+)\n\*\*Status\*\*: CURRENT/m, "### v\\1 - \\2\n**Status**: PREVIOUS")
  content.sub!(/## ▛▞ VERSION HISTORY ::\n/, "## ▛▞ VERSION HISTORY ::\n#{new_entry}\n")
  
  # Clear pending section
  content.sub!(
    /## ▛▞ PENDING DISCOVERIES ::\s*\n\s*### Awaiting Merge.*?\n\s*\n.*?\n\s*:: ∎/m,
    "## ▛▞ PENDING DISCOVERIES ::\n\n### Awaiting Merge to v#{bump_version(new_version, :minor)}\n\nNone yet.\n\n:: ∎"
  )
  
  File.write(CHANGELOG_PATH, content)
end

# Check for auto mode
auto_mode = ARGV.include?('--auto')

# Main execution
puts "═══════════════════════════════════════════"
puts "CALIBRATION DISCOVERY MERGER"
puts "═══════════════════════════════════════════"
puts ""

discoveries = extract_pending_discoveries

if discoveries.empty?
  puts "✓ No pending discoveries to merge"
  puts "  Log discoveries with: ruby log_discovery.rb"
  exit 0
end

puts "Found #{discoveries.length} pending discoveries:"
discoveries.each_with_index do |d, i|
  puts "  #{i + 1}. [#{d[:impact]}] #{d[:type]} - #{d[:description][0..60]}..."
end
puts ""

# Get current version from changelog
changelog_content = File.read(CHANGELOG_PATH)
current_version = changelog_content[/\*\*Current Version\*\*: v([\d\.]+)/, 1]

bump_type = determine_bump_type(discoveries)
new_version = bump_version(current_version, bump_type)

puts "Current version: v#{current_version}"
puts "Recommended bump: #{bump_type.upcase}"
puts "New version: v#{new_version}"
puts ""

# Skip confirmation in auto mode
unless auto_mode
  puts "Press ENTER to merge, or Ctrl+C to cancel..."
  gets
end

# Perform merge
puts "Merging discoveries..."
update_calibration_version(new_version)
puts "✓ Updated calibration version to v#{new_version}"

move_to_history(discoveries, new_version)
puts "✓ Moved discoveries to changelog history"

# Archive discovery log
if File.exist?(DISCOVERY_LOG)
  archive_path = "#{DISCOVERY_LOG}.#{Time.now.strftime('%Y%m%d_%H%M%S')}"
  FileUtils.cp(DISCOVERY_LOG, archive_path)
  File.delete(DISCOVERY_LOG)
  puts "✓ Archived discovery log to #{File.basename(archive_path)}"
end

puts ""
puts "═══════════════════════════════════════════"
puts "MERGE COMPLETE"
puts "═══════════════════════════════════════════"
puts "Version: v#{new_version}"
puts "Discoveries merged: #{discoveries.length}"
puts ""
puts "Next: Review CURSOR.AGENT.CALIBRATION.md for any manual edits needed"

