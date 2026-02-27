# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xAF4B]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // AGENT_RECOVERY.RB ▞▞
# ▛▞// AGENT_RECOVERY.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.agent_recovery.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for AGENT_RECOVERY.RB
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
##/// Last Updated: 2026.01.07 | Trace.ID: agent_recovery.v1.0
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.07
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [agent_recovery] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // AGENT_RECOVERY ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# AGENT_RECOVERY.RB :: Recover completed agent analysis and integrate results
#

require 'json'
require 'net/http'
require 'uri'
require 'fileutils'

API_KEY = nil
secrets_file = '/root/!CMD.BRIDGE/.3ox/rc/secrets/api.keys'
if File.exist?(secrets_file)
  File.readlines(secrets_file).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    if line =~ /^CURSOR_API_KEY=(.+)$/
      API_KEY = $1.strip.gsub(/^["']|["']$/, '')
      break
    end
  end
end

def check_agent_status(agent_id)
  """Check status of a cursor agent"""
  return { 'status' => 'ERROR', 'error' => 'No API key' } unless API_KEY

  uri = URI("https://api.cursor.com/v0/agents/#{agent_id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{API_KEY}"
  request['Content-Type'] = 'application/json'

  response = http.request(request)

  if response.code == '200'
    JSON.parse(response.body)
  else
    { 'status' => 'ERROR', 'error' => "HTTP #{response.code}" }
  end
rescue => e
  { 'status' => 'ERROR', 'error' => e.message }
end

def extract_analysis_from_summary(summary)
  """Extract analysis decisions from agent summary"""
  analysis = {
    decision: 'unknown',
    placement: 'docs',
    reasoning: summary
  }

  # Parse common patterns from agent summaries
  if summary.include?('ELEVATED') || summary.include?('ELEVATE')
    analysis[:decision] = 'elevate'
    if summary.include?('docs/')
      analysis[:placement] = 'docs'
    elsif summary.include?('scripts/')
      analysis[:placement] = 'scripts'
    elsif summary.include?('primitives/')
      analysis[:placement] = 'primitives'
    end
  elsif summary.include?('ARCHIVED') || summary.include?('ARCHIVE')
    analysis[:decision] = 'archive'
  end

  analysis
end

def recover_completed_agent(agent_id, filename)
  """Recover analysis from a completed agent"""
  puts "🔍 Recovering agent: #{agent_id} (#{filename})"

  status = check_agent_status(agent_id)

  if status['status'] == 'FINISHED'
    summary = status['summary'] || 'No summary available'
    puts "✅ Agent completed!"
    puts "📋 Summary: #{summary[0..200]}..."

    # Extract analysis
    analysis = extract_analysis_from_summary(summary)

    puts "📋 Decision: #{analysis[:decision].upcase} → #{analysis[:placement]}"

    # Apply the analysis
    apply_recovered_analysis(filename, analysis)

    return true
  elsif status['status'] == 'ERROR'
    puts "❌ Agent error: #{status['error']}"
    return false
  else
    puts "⏳ Agent status: #{status['status']}"
    return false
  end
end

def apply_recovered_analysis(filename, analysis)
  """Apply recovered analysis to files"""
  review_dir = "/root/!CMD.BRIDGE/!WORKDESK/3OX.FORGE/review"
  analysis_file = "#{review_dir}/#{filename}.analysis.md"

  # Create/update analysis file
  if File.exist?(analysis_file)
    content = File.read(analysis_file)
    # Update decision section
    content = update_analysis_content(content, analysis)
  else
    content = create_analysis_content(filename, analysis)
  end

  File.write(analysis_file, content)
  puts "📝 Analysis file updated: #{analysis_file}"

  # Move to appropriate location based on decision
  move_based_on_decision(filename, analysis)
end

def update_analysis_content(content, analysis)
  """Update existing analysis content with recovered decisions"""

  # Update decision section
  decision_text = case analysis[:decision]
                   when 'elevate' then "[x] ELEVATE → candidates/"
                   when 'archive' then "[x] ARCHIVE"
                   else "[ ] CURSOR_ANALYZE"
                   end

  content = content.gsub(/## Decision\n\n.*?\n\n:: ∎/m) do |match|
    "## Decision\n\n#{decision_text}\n\n:: ∎"
  end

  # Update placement if elevating
  if analysis[:decision] == 'elevate'
    placement_marker = case analysis[:placement]
                       when 'docs' then '[x] docs/'
                       when 'scripts' then '[x] scripts/'
                       when 'primitives' then '[x] primitives/'
                       else '[x] docs/'
                       end

    content = content.gsub(/3\. \*\*Where should it go in canonical 3OX\.Ai\?\*\*\n   - \[ \] primitives\/\n   - \[ \] scripts\/\n   - \[x\] docs\/\n   - \[ \] examples\/\n   - \[ \] vec3\/lib\/\n   - \[ \] vec3\/rc\//) do |match|
      match.gsub('[x] docs/', placement_marker).gsub('[ ] primitives/', '[ ] primitives/').gsub('[ ] scripts/', '[ ] scripts/')
    end
  end

  content
end

def create_analysis_content(filename, analysis)
  """Create new analysis content"""
  # This would create a full analysis template - simplified for now
  "Analysis recovered from agent for #{filename}\nDecision: #{analysis[:decision]}\nPlacement: #{analysis[:placement]}"
end

def move_based_on_decision(filename, analysis)
  """Move file based on recovered decision"""
  review_dir = "/root/!CMD.BRIDGE/!WORKDESK/3OX.FORGE/review"
  source_file = "#{review_dir}/#{filename}.analysis.md"

  return unless File.exist?(source_file)

  case analysis[:decision]
  when 'elevate'
    candidates_dir = "/root/!CMD.BRIDGE/.3ox/pipeline/candidates"
    FileUtils.mkdir_p(candidates_dir)
    target_file = "#{candidates_dir}/#{filename}.analysis.md"
    FileUtils.cp(source_file, target_file)
    puts "📤 Moved to candidates: #{filename}"
  when 'archive'
    archive_dir = "/root/!CMD.BRIDGE/!WORKDESK/3OX.FORGE/archive"
    FileUtils.mkdir_p(archive_dir)
    target_file = "#{archive_dir}/#{filename}.analysis.md"
    FileUtils.mv(source_file, target_file)
    puts "📦 Moved to archive: #{filename}"
  end
end

def scan_for_completed_agents
  """Scan for agents that may have completed"""
  puts "🔍 Scanning for completed agents..."

  # This would need a list of agent IDs that were launched
  # For now, we'll need manual input or log parsing

  puts "📝 Please provide agent IDs to check:"
  puts "Example: bc-12345678-1234-1234-1234-123456789012"
  puts ""
  puts "Or run: ruby agent_recovery.rb --agent <agent_id> --file <filename>"
end

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __FILE__ == $0
  require 'optparse'

  options = {
    agent_id: nil,
    filename: nil,
    scan: false
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: agent_recovery.rb [options]"

    opts.on("-a", "--agent AGENT_ID", "Recover specific agent") do |a|
      options[:agent_id] = a
    end

    opts.on("-f", "--file FILENAME", "Analysis filename (without .analysis.md)") do |f|
      options[:filename] = f
    end

    opts.on("-s", "--scan", "Scan for completed agents") do
      options[:scan] = true
    end

    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!

  if options[:agent_id] && options[:filename]
    recover_completed_agent(options[:agent_id], options[:filename])
  elsif options[:scan]
    scan_for_completed_agents
  else
    puts "▛▞// AGENT RECOVERY SYSTEM"
    puts "▛▞//"
    puts "▛▞// Recover specific agent:"
    puts "▛▞//   ruby agent_recovery.rb --agent <agent_id> --file <filename>"
    puts "▛▞//"
    puts "▛▞// Scan for completed agents:"
    puts "▛▞//   ruby agent_recovery.rb --scan"
    puts "▛▞//"
    puts "▛▞// Example:"
    puts "▛▞//   ruby agent_recovery.rb --agent bc-12345678-1234-1234-1234-123456789012 --file example.md"
  end
end

# :: ∎