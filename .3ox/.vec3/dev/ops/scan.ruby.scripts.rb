# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x676C]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // SCAN.RUBY.SCRIPTS.RB ▞▞
# ▛▞// SCAN.RUBY.SCRIPTS.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.scan.ruby.scripts.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for SCAN.RUBY.SCRIPTS.RB
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
module Z3N
  SPEC = {
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ :: ⧗-25.152 // SCAN.RUBY.SCRIPTS ▞▞',
    PHENO: '▛▞// Scan directories for Ruby scripts and generate inventory sheet :: ρ{scan}.φ{collect}.τ{report} ▹',
    PiCO: '//▞⋮⋮ [🔍] ≔ [ruby.scan] [inventory] [automation] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: OPS | Auth: SYSTEM | Created: 2026.01.15
##/// Last Updated: 2026.01.15 | Trace.ID: scan.ruby.scripts.v1.0
##/// Purpose: Scans specified directories for all Ruby scripts
##///          Generates inventory sheet with paths, sizes, and metadata
##///          Outputs CSV format for easy processing
#```
#
#▛//▞ TOOLSET ::
#/scan = Scans directory for .rb files recursively
#/inventory = Generates inventory sheet with script details
#/report = Outputs results in CSV format
SEAL = ':: ∎'

require 'csv'
require 'fileutils'

# Use absolute path to avoid expansion issues
WORKSPACE_ROOT = '/root/!LAUNCHPAD'
DOT3OX_ROOT = File.join(WORKSPACE_ROOT, '.3ox')
CMD_CENTER = File.join(WORKSPACE_ROOT, '!CMD.CENTER')
# Ensure !WORKDESK exists
WORKDESK = File.join(WORKSPACE_ROOT, '!WORKDESK')
FileUtils.mkdir_p(WORKDESK) unless File.directory?(WORKDESK)

# Scan directory for Ruby scripts
def scan_directory(dir_path, area_name)
  return [] unless File.directory?(dir_path)
  
  scripts = []
  Dir.glob(File.join(dir_path, '**/*.rb')).each do |file_path|
    next unless File.file?(file_path)
    
    # Check if has Z3N header
    content = File.read(file_path)
    has_z3n = content.include?("module Z3N") && content.include?("SPEC = {") && 
              content.include?("SCHEMA: '///▙▖▙▖▞▞▙") && content.include?("SEAL = ':: ∎'")
    
    # Detect existing banner
    has_banner = false
    banner_line = nil
    content.split("\n").each_with_index do |line, idx|
      first_5 = line.split(/[\s=]/).first(5).join('')
      if first_5.include?('///▙') || first_5.include?('///') || 
         first_5.include?('▙▖▙') || line.match?(/^#.*[▙▖▞▂]/) || line.match?(/^#.*::\[0x/)
        has_banner = true
        banner_line = idx
        break
      end
    end
    
    scripts << {
      area: area_name,
      path: file_path,
      relative_path: file_path.sub(WORKSPACE_ROOT + '/', ''),
      size: File.size(file_path),
      has_z3n: has_z3n,
      has_banner: has_banner,
      banner_line: banner_line,
      mtime: File.mtime(file_path).strftime('%Y-%m-%d %H:%M:%S')
    }
  end
  
  scripts
end

# Main
# Filter out --output flag and its value from ARGV
scan_args = ARGV.dup
if scan_args.include?('--output')
  output_idx = scan_args.index('--output')
  scan_args.delete_at(output_idx)  # Remove --output
  scan_args.delete_at(output_idx)  # Remove output file path
end

areas = scan_args.any? ? scan_args.map { |arg| { path: File.expand_path(arg, WORKSPACE_ROOT), name: File.basename(arg) } } : [
  { path: File.join(DOT3OX_ROOT, 'vec3'), name: 'vec3' },
  { path: CMD_CENTER, name: 'CMD.CENTER' }
]

all_scripts = []

puts "🔍 Scanning for Ruby scripts..."
puts ""

areas.each do |area|
  puts "📁 Scanning: #{area[:name]} (#{area[:path]})"
  scripts = scan_directory(area[:path], area[:name])
  all_scripts.concat(scripts)
  puts "   Found: #{scripts.length} scripts"
end

puts ""
puts "📊 Total scripts found: #{all_scripts.length}"
puts ""

# Generate CSV report
# Allow output file to be specified via --output or ENV, default to inventory.csv
output_file = if ARGV.include?('--output')
  ARGV[ARGV.index('--output') + 1]
elsif ENV['SCAN_OUTPUT_FILE']
  ENV['SCAN_OUTPUT_FILE']
else
  File.join(WORKDESK, 'ruby.scripts.inventory.csv')
end
FileUtils.mkdir_p(File.dirname(output_file))
CSV.open(output_file, 'w') do |csv|
  csv << ['Area', 'Path', 'Relative Path', 'Size (bytes)', 'Has Z3N', 'Has Banner', 'Banner Line', 'Modified']
  all_scripts.each do |script|
    csv << [
      script[:area],
      script[:path],
      script[:relative_path],
      script[:size],
      script[:has_z3n] ? 'YES' : 'NO',
      script[:has_banner] ? 'YES' : 'NO',
      script[:banner_line] || '',
      script[:mtime]
    ]
  end
end

puts "✅ Inventory saved to: #{output_file}"
puts ""
puts "Summary:"
puts "  Total: #{all_scripts.length}"
puts "  With Z3N header: #{all_scripts.count { |s| s[:has_z3n] }}"
puts "  With banner: #{all_scripts.count { |s| s[:has_banner] }}"
puts "  Need header: #{all_scripts.count { |s| !s[:has_z3n] }}"
# :: ∎