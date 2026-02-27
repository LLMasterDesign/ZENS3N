# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xF588]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // CAPTURE_AGENT_RESULTS.RB ▞▞
# ▛▞// CAPTURE_AGENT_RESULTS.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.capture_agent_results.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for CAPTURE_AGENT_RESULTS.RB
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
# CAPTURE_AGENT_RESULTS.RB :: Get completed analysis from cursor agent and apply to files
#

require 'json'

THREEX_ROOT = File.expand_path('../../../../..', __dir__) # /.../.3ox

def check_agent_status(agent_id)
  """Check status of a cursor agent"""
  require 'net/http'
  require 'json'
  require 'uri'
  require_relative '../../../core/cursor.api.rb'

  api_key = nil
  secrets_file = File.join(THREEX_ROOT, 'vec3', 'rc', 'secrets', 'api.keys')
  if File.exist?(secrets_file)
    File.readlines(secrets_file).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      if line =~ /^CURSOR_API_KEY=(.+)$/
        api_key = $1.strip.gsub(/^["']|["']$/, '')
        break
      end
    end
  end

  return nil unless api_key

  uri = URI("https://api.cursor.com/v0/agents/#{agent_id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{api_key}"
  request['Content-Type'] = 'application/json'

  response = http.request(request)

  if response.code == '200'
    JSON.parse(response.body)
  else
    nil
  end
end

def capture_agent_analysis(agent_id)
module Z3N
  SPEC = {
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // CAPTURE_AGENT_RESULTS ▞▞',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [capture_agent_results] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.05
##/// Last Updated: 2026.01.05 | Trace.ID: capture_agent_results.v1.0
##/// Purpose: !/usr/bin/env ruby
##///          (Add second line of purpose here)
##///          (Add third line of purpose here)
#```
#
#▛//▞ TOOLSET ::
#(Add toolset commands here)
#/command1 = description1
#/command2 = description2
  puts "▛//▞▞ ⟦⎊⟧ :: CAPTURE AGENT ANALYSIS :: #{agent_id} ▞▞"
  puts ""

  begin
    status = check_agent_status(agent_id)

    if status && status['status'] == 'FINISHED'
      summary = status['summary']
      puts "▛▞// ✅ Agent completed!"
      puts "▛▞// Summary: #{summary[0..300]}..."
      puts ""

      # For now, let's manually handle the first completed agent
      # In production, this would parse the summary and update the analysis file

      puts "▛▞// 📝 MANUAL STEP NEEDED:"
      puts "▛▞// Copy the agent's summary and paste it into the analysis file"
      puts "▛▞// Then mark decisions and clean up"
      puts ""

      return summary
    else
      puts "▛▞// ⏳ Agent status: #{status ? status['status'] : 'UNKNOWN'}"
      return nil
    end

  rescue => e
    puts "▛▞// ❌ Error: #{e.message}"
    return nil
  end

  puts ":: ∎"
end

def apply_analysis_to_file(filename, analysis_content)
  """Apply completed analysis to the analysis file"""
  analysis_file = "/root/!CMD.BRIDGE/!WORKDESK/3OX.FORGE/review/#{filename}"

  if File.exist?(analysis_file)
    puts "▛▞// 📝 Updating: #{filename}"

    # Read current content
    content = File.read(analysis_file)

    # Apply the analysis content (this would need to be parsed from agent response)
    # For now, just mark as completed
    updated_content = content.gsub(
      'Deep Analysis Required',
      'Analysis Complete - Agent Processed'
    )

    # Write back
    File.write(analysis_file, updated_content)
    puts "▛▞// ✅ File updated"

  else
    puts "▛▞// ❌ File not found: #{analysis_file}"
  end
end

def complete_and_remove_file(filename)
  """Mark analysis complete and remove from workspace"""
  analysis_file = "/root/!CMD.BRIDGE/!WORKDESK/3OX.FORGE/review/#{filename}"

  if File.exist?(analysis_file)
    puts "▛▞// 🗑️ Removing processed file: #{filename}"
    FileUtils.rm_f(analysis_file)
    puts "▛▞// ✅ File removed from workspace"
  end
end

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __FILE__ == $0
  require 'optparse'

  options = {
    agent_id: nil,
    filename: nil,
    complete: false
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: capture_agent_results.rb [options]"

    opts.on("-a", "--agent AGENT_ID", "Capture results from agent") do |a|
      options[:agent_id] = a
    end

    opts.on("-f", "--file FILENAME", "Analysis filename") do |f|
      options[:filename] = f
    end

    opts.on("-c", "--complete", "Mark file complete and remove") do
      options[:complete] = true
    end

    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!

  if options[:agent_id]
    capture_agent_analysis(options[:agent_id])
  elsif options[:complete] && options[:filename]
    complete_and_remove_file(options[:filename])
  else
    puts "▛▞// CAPTURE AGENT RESULTS"
    puts "▛▞//"
    puts "▛▞// 1. Check agent status:"
    puts "▛▞//    ruby capture_agent_results.rb --agent <agent_id>"
    puts "▛▞//"
    puts "▛▞// 2. When complete, remove file:"
    puts "▛▞//    ruby capture_agent_results.rb --file <filename> --complete"
  end
end

# :: ∎