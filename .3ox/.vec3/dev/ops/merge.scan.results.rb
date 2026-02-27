# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x54CF]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // MERGE.SCAN.RESULTS.RB ▞▞
# ▛▞// MERGE.SCAN.RESULTS.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.merge.scan.results.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for MERGE.SCAN.RESULTS.RB
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
    IMPRINT: '▛//▞▞ ⟦⎊⟧ :: ⧗-25.152 // MERGE.SCAN.RESULTS ▞▞',
    PHENO: '▛▞// Merge multiple agent scan CSVs into single inventory :: ρ{collect}.φ{merge}.τ{unify} ▹',
    PiCO: '//▞⋮⋮ [🔀] ≔ [csv.merge] [inventory] [automation] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: OPS | Auth: SYSTEM | Created: 2026.01.15
##/// Last Updated: 2026.01.15 | Trace.ID: merge.scan.results.v1.0
##/// Purpose: Merges multiple agent scan CSV files into single inventory
##///          Combines results from worktree agents scanning different areas
##///          Outputs unified CSV for header application
#```
#
#▛//▞ TOOLSET ::
#/collect = Collects all agent CSV files
#/merge = Merges CSV rows into single file
#/validate = Validates merged inventory
SEAL = ':: ∎'

require 'csv'
require 'fileutils'

# Calculate paths correctly - use absolute path
WORKSPACE_ROOT = '/root/!LAUNCHPAD'
WORKDESK = File.join(WORKSPACE_ROOT, '!WORKDESK')
FileUtils.mkdir_p(WORKDESK) unless File.directory?(WORKDESK)

# Find all agent CSV files
csv_files = Dir.glob(File.join(WORKDESK, 'ruby.scripts.agent*.csv')).sort

if csv_files.empty?
  puts "❌ No agent CSV files found in #{WORKDESK}"
  puts "   Looking for: ruby.scripts.agent*.csv"
  exit 1
end

puts "🔀 Merging scan results..."
puts "   Found #{csv_files.length} agent files:"
csv_files.each { |f| puts "     - #{File.basename(f)}" }
puts ""

all_rows = []
csv_files.each do |file|
  count = 0
  CSV.foreach(file, headers: true) do |row|
    all_rows << row
    count += 1
  end
  puts "   #{File.basename(file)}: #{count} scripts"
end

# Write merged CSV
output_file = File.join(WORKDESK, 'ruby.scripts.inventory.csv')
CSV.open(output_file, 'w') do |csv|
  csv << ['Area', 'Path', 'Relative Path', 'Size (bytes)', 'Has Z3N', 'Has Banner', 'Banner Line', 'Modified']
  all_rows.each { |row| csv << row }
end

puts ""
puts "✅ Merged #{all_rows.length} scripts into: #{File.basename(output_file)}"
puts ""
puts "Summary:"
puts "  Total: #{all_rows.length}"
puts "  With Z3N: #{all_rows.count { |r| r['Has Z3N'] == 'YES' }}"
puts "  With banner: #{all_rows.count { |r| r['Has Banner'] == 'YES' }}"
puts "  Need header: #{all_rows.count { |r| r['Has Z3N'] == 'NO' }}"
puts ""
puts "Next step:"
puts "  cd /root/!LAUNCHPAD/.3ox"
puts "  ruby vec3/dev/ops/apply.canon.header.rb --from-csv ../!WORKDESK/ruby.scripts.inventory.csv"

# :: ∎