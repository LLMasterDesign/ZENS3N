# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xD1F2]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // ANALYZE_REVIEW_DOCS.RB ▞▞
# ▛▞// ANALYZE_REVIEW_DOCS.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.analyze_review_docs.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for ANALYZE_REVIEW_DOCS.RB
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
# ANALYZE_REVIEW_DOCS.RB :: Fill analysis docs using Cursor agents with 3OX context
# Uses cursor agents to analyze review folder files and fill in analysis templates
#

require 'json'
require 'net/http'
require 'uri'
require 'fileutils'
require_relative 'vec3/lib/core/cursor.api.rb'
require_relative 'vec3/lib/core/sirius.clock.rb'

def create_analysis_prompt(analysis_file_path)
  """Create prompt for Cursor agent to fill in analysis docs"""

  # Read the analysis template
  analysis_content = File.read(analysis_file_path)

  # Extract file info from the analysis file
  file_match = analysis_content.match(/File:\s*`([^`]+)`/)
  source_match = analysis_content.match(/Source:\s*`([^`]+)`/)
  categories_match = analysis_content.match(/Categories:\s*(.+)/)

  original_file = file_match ? file_match[1] : "unknown"
  source_path = source_match ? source_match[1] : "unknown"
  categories = categories_match ? categories_match[1].strip : "unknown"

  # Try to read the original file content from wrkdsk mount
  original_content = ""
  begin
    # First try wrkdsk (cursor agent accessible location)
    wrkdsk_path = File.join('/root/!CMD.BRIDGE/.3ox/vec3/var/wrkdsk', File.basename(analysis_file_path).sub('.analysis.md', ''))
    if File.exist?(wrkdsk_path)
      original_content = File.read(wrkdsk_path)
      puts "▛▞// Found original file in wrkdsk: #{wrkdsk_path}"
    else
      # Fallback to original location
      full_source_path = File.expand_path(File.join(File.dirname(analysis_file_path), '..', '..', source_path))
      if File.exist?(full_source_path)
        original_content = File.read(full_source_path)
        puts "▛▞// Found original file at source: #{full_source_path}"
      else
        original_content = "Original file not found at expected locations:\n- wrkdsk: #{wrkdsk_path}\n- source: #{full_source_path}"
      end
    end
  rescue => e
    original_content = "Error reading original file: #{e.message}"
  end

  prompt = <<~PROMPT
    You are a 3OX.Ai analysis agent with full access to the CMD.BRIDGE workspace and .3ox system.

    TASK: Fill in the analysis template for the file "#{original_file}" based on 3OX.Ai architecture and standards.

    ANALYSIS TEMPLATE TO FILL:
    #{analysis_content}

    ORIGINAL FILE CONTENT:
    #{original_content[0..10000]} # Truncate if too long

    CATEGORIES FROM TEMPLATE: #{categories}

    REQUIREMENTS:
    1. **What does this file do?** - Analyze the file content and describe its purpose in 3OX.Ai context
    2. **Does it duplicate existing functionality?** - Check against 3OX.Ai architecture (.3ox/, vec3/, etc.)
    3. **Where should it go in canonical 3OX.Ai?** - Suggest placement (primitives/, scripts/, docs/, examples/, vec3/lib/, vec3/rc/)
    4. **What modifications needed?** - Identify any changes required for 3OX.Ai integration

    DECISION CRITERIA:
    - CURSOR_ANALYZE → if you need more context or specific 3OX.Ai docs
    - ELEVATE → if ready for integration (candidates/)
    - ARCHIVE → if not needed

    Fill in the template sections with detailed analysis. Use 3OX.Ai terminology and reference the system's architecture patterns.

    OUTPUT: Return the complete filled analysis template with all sections completed.
  PROMPT

  prompt
end

def launch_analysis_agent(analysis_file_path)
  """Launch Cursor agent to fill analysis template"""

module Z3N
  SPEC = {
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // ANALYZE_REVIEW_DOCS ▞▞',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [analyze_review_docs] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.05
##/// Last Updated: 2026.01.05 | Trace.ID: analyze_review_docs.v1.0
##/// Purpose: !/usr/bin/env ruby
##///          (Add second line of purpose here)
##///          (Add third line of purpose here)
#```
#
#▛//▞ TOOLSET ::
#(Add toolset commands here)
#/command1 = description1
#/command2 = description2
  puts "▛//▞▞ ⟦⎊⟧ :: ⧗-#{sirius_time()} // ANALYSIS AGENT :: #{File.basename(analysis_file_path)} ▞▞"
  puts ""

  prompt = create_analysis_prompt(analysis_file_path)

  puts "▛▞// Launching analysis agent for: #{File.basename(analysis_file_path)}"
  puts "▛▞// Sirius time: #{sirius_time()}"
  puts ""

  begin
    result = CursorAPI.launch_agent(prompt, {
      model: 'gpt-5.2'
    })

    puts "▛▞// Agent launched successfully!"
    puts "▛▞// Agent ID: #{result['id']}"
    puts "▛▞// Status: #{result['status']}"
    puts "▛▞// View at: #{result.dig('target', 'url')}"
    puts ""

    if result['status'] == 'CREATING'
      puts "▛▞// Agent is analyzing the file and will fill the template."
      puts "▛▞// Check agent status and results when complete."
    end

    result
  rescue => e
    puts "▛▞// ERROR: #{e.message}"
    puts "▛▞// Full backtrace:"
    puts e.backtrace.join("\n")
    nil
  end
end

def check_agent_status(agent_id)
  """Check status of analysis agent"""
  api_key = CursorAPI.load_api_key
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

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __FILE__ == $0
  require 'optparse'

  options = {
    file: nil,
    check_status: nil,
    all: false
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: analyze_review_docs.rb [options]"

    opts.on("-f", "--file PATH", "Specific analysis file to fill") do |f|
      options[:file] = f
    end

    opts.on("-s", "--status AGENT_ID", "Check agent status") do |s|
      options[:check_status] = s
    end

    opts.on("-a", "--all", "Analyze all analysis files in review folder") do
      options[:all] = true
    end

    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!

  review_dir = "/root/!CMD.BRIDGE/!WORKDESK/3OX.FORGE/review"

  if options[:check_status]
    puts "▛▞// Checking agent status: #{options[:check_status]}"
    status = check_agent_status(options[:check_status])

    if status
      puts JSON.pretty_generate(status)
    else
      puts "▛▞// ERROR: Failed to get agent status"
      exit 1
    end

  elsif options[:file]
    analysis_file = File.expand_path(options[:file])
    unless File.exist?(analysis_file)
      puts "▛▞// ERROR: Analysis file not found: #{analysis_file}"
      exit 1
    end

    result = launch_analysis_agent(analysis_file)

    if result
      puts ""
      puts "▛▞// To check status later, run:"
      puts "▛▞//   ruby .3ox/analyze_review_docs.rb --status #{result['id']}"
    end

  elsif options[:all]
    puts "▛▞// Analyzing all analysis files in: #{review_dir}"

    analysis_files = Dir.glob(File.join(review_dir, "*.analysis.md"))
    puts "▛▞// Found #{analysis_files.length} analysis files"

    analysis_files.each do |analysis_file|
      puts "▛▞// Processing: #{File.basename(analysis_file)}"
      result = launch_analysis_agent(analysis_file)

      if result
        puts "▛▞// Agent ID: #{result['id']}"
        # Add delay between launches to avoid rate limiting
        sleep 2
      end
      puts ""
    end

  else
    puts "▛▞// ERROR: Must specify --file, --all, or --status"
    puts "▛▞// Use --help for usage information"
    exit 1
  end
end

# :: ∎