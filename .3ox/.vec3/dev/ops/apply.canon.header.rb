# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA860]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // APPLY.CANON.HEADER.RB ▞▞
# ▛▞// APPLY.CANON.HEADER.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [dispatch] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.apply.canon.header.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for APPLY.CANON.HEADER.RB
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
    IMPRINT: '▛//▞▞ ⟦⎊⟧ :: ⧗-25.152 // APPLY.Z3N.HEADER ▞▞',
    PHENO: '▛▞// Apply Z3N header to Ruby scripts :: ρ{scan}.φ{detect}.τ{apply} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [z3n.header] [ops] [automation] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: OPS | Auth: SYSTEM | Created: 2026.01.15
##/// Last Updated: 2026.01.15 | Trace.ID: apply.z3n.header.v1.0
##/// Purpose: Scans Ruby scripts and applies Z3N header standard
##///          Detects existing banners (first 5 blocks), replaces entire line
##///          Preserves existing code and functionality
#```
#
#▛//▞ TOOLSET ::
#/scan = Scans directory for .rb files
#/check = Checks if script has Z3N header (Z3N::SPEC)
#/detect = Detects existing banner line (first 5 blocks)
#/replace = Replaces entire banner line with Z3N module
#/backup = Creates backup before modification
SEAL = ':: ∎'

require 'fileutils'
require 'time'
require 'digest'

VEC3_ROOT = File.expand_path('../..', __dir__)
DOT3OX_ROOT = File.expand_path('../..', VEC3_ROOT)
WORKSPACE_ROOT = File.expand_path('../..', DOT3OX_ROOT)
CMD_CENTER = File.join(WORKSPACE_ROOT, '!CMD.CENTER')

# Get Sirius time
def sirius_time
  `cd '#{WORKSPACE_ROOT}' && ruby sirius.clock.rb 2>/dev/null`.strip rescue "⧗-25.152"
end

# Check if script already has Z3N header
def has_z3n_header?(file_path)
  return false unless File.exist?(file_path)
  content = File.read(file_path)
  (content.include?("module Z3N") && content.include?("SPEC = {") && 
   content.include?("SCHEMA: '///▙▖▙▖▞▞▙")) && content.include?("SEAL = ':: ∎'")
end

# Detect existing banner line (scan first 5 blocks)
def detect_banner_line(content)
  lines = content.split("\n")
  lines.each_with_index do |line, idx|
    # Check first 5 blocks (characters before first space or special char)
    first_5_blocks = line.split(/[\s=]/).first(5).join('')
    
    # Common banner patterns (first 5 blocks)
    if first_5_blocks.include?('///▙') || 
       first_5_blocks.include?('///') ||
       first_5_blocks.include?('▙▖▙') ||
       first_5_blocks.match?(/^#.*[▙▖▞▂]/) ||
       line.match?(/^#.*::\[0x/)
      return idx
    end
  end
  nil
end

# Extract script metadata from file
def extract_metadata(file_path)
  content = File.read(file_path)
  name = File.basename(file_path, '.rb')
  
  # Determine category from path
  category = case file_path
  when /vec3\/lib\/core/ then 'SYSTEM'
  when /vec3\/dev\/ops/ then 'OPS'
  when /vec3\/dev\/io/ then 'IO'
  when /vec3\/rc\/bin/ then 'CLI'
  when /vec3\/rc\/services/ then 'SERVICE'
  when /vec3\/rc\/run/ then 'RUNTIME'
  when /vec3\/rc\/dispatch/ then 'DISPATCH'
  when /!CMD\.CENTER\/!CMD\.OPS/ then 'OPS'
  when /!CMD\.CENTER\/!CORE/ then 'CORE'
  when /!CMD\.CENTER\/STATIONS/ then 'STATION'
  else 'SCRIPT'
  end
  
  # Extract description from first comment
  description = nil
  if content =~ /#\s*(.+?)(?:\n|$)/
    desc = $1.strip
    desc.gsub!(/^[#\s]*/, '')
    desc.gsub!(/::.*$/, '')
    description = desc[0..80] if desc.length > 0
  end
  
  # Extract icon from existing content or default
  icon = '🔧'
  icon = '🔍' if name.include?('scan') || name.include?('discover')
  icon = '⚙️' if name.include?('tool') || name.include?('ops')
  icon = '🌉' if name.include?('bridge')
  icon = '📡' if name.include?('dispatch') || name.include?('route')
  
  {
    name: name,
    category: category,
    description: description || "#{name} script",
    icon: icon,
    tags: [name.gsub('.', '_'), category.downcase, 'ruby']
  }
end

# Generate Z3N header
def generate_header(metadata, file_path)
  sirius = sirius_time
  created = File.mtime(file_path).strftime('%Y.%m.%d')
  
  header = <<~HEADER
#!/usr/bin/env ruby
module Z3N
  SPEC = {
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ :: #{sirius} // #{metadata[:name].upcase} ▞▞',
    PHENO: '▛▞// #{metadata[:description]} :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [#{metadata[:icon]}] ≔ [#{metadata[:tags].join('] [')}] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: #{metadata[:category]} | Auth: SYSTEM | Created: #{created}
##/// Last Updated: #{created} | Trace.ID: #{metadata[:name]}.v1.0
##/// Purpose: #{metadata[:description]}
##///          (Add second line of purpose here)
##///          (Add third line of purpose here)
#```
#
#▛//▞ TOOLSET ::
#(Add toolset commands here)
#/command1 = description1
#/command2 = description2
SEAL = ':: ∎'
HEADER
end

# Apply header to file
def apply_header(file_path, dry_run: false)
  return if has_z3n_header?(file_path)
  
  metadata = extract_metadata(file_path)
  
  if dry_run
    puts "  [DRY RUN] Would add header to: #{file_path}"
    return
  end
  
  # Backup
  backup_path = "#{file_path}.backup.#{Time.now.to_i}"
  FileUtils.cp(file_path, backup_path)
  
  # Read existing content
  content = File.read(file_path)
  lines = content.split("\n")
  
  # Detect existing banner line (first 5 blocks)
  banner_line_idx = detect_banner_line(content)
  
  # Generate new header
  header_lines = generate_header(metadata, file_path).split("\n")
  
  # If banner found, replace that entire line and surrounding Z3N module if present
  if banner_line_idx
    # Check if there's a Z3N module block we should replace
    z3n_start = nil
    z3n_end = nil
    
    # Look for module Z3N before banner
    (0..banner_line_idx).reverse_each do |i|
      if lines[i] =~ /^\s*module\s+Z3N/
        z3n_start = i
        break
      end
    end
    
    # Look for end after banner
    if z3n_start
      (banner_line_idx..[banner_line_idx + 10, lines.length - 1].min).each do |i|
        if lines[i] =~ /^\s*end\s*$/
          z3n_end = i
          break
        end
      end
    end
    
    if z3n_start && z3n_end
      # Replace entire Z3N module block
      lines[z3n_start..z3n_end] = header_lines[1..-2]  # Skip shebang and SEAL, they're separate
    else
      # Just replace banner line with Z3N module
      lines[banner_line_idx] = header_lines[1]  # module Z3N line
      header_lines[2..-2].each_with_index do |line, idx|
        lines.insert(banner_line_idx + 1 + idx, line)
      end
    end
  else
    # No banner found, insert full header at start
    # Remove existing shebang if present
    if lines[0] =~ /^#!\/usr\/bin\/env ruby/
      lines[0] = header_lines[0]  # Replace shebang with new shebang
      header_lines[1..-1].each { |line| lines.insert(1, line) }
    else
      # No shebang, insert everything
      header_lines.reverse.each { |line| lines.unshift(line) }
    end
  end
  
  # Write back
  File.write(file_path, lines.join("\n") + "\n")
  puts "  ✅ Added header to: #{file_path}"
end

# Main - can read from CSV inventory or scan directories
if ARGV.include?('--from-csv')
  # Read from inventory CSV
  csv_path = ARGV[ARGV.index('--from-csv') + 1] || File.join(WORKSPACE_ROOT, '!WORKDESK', 'ruby.scripts.inventory.csv')
  require 'csv'
  
  dry_run = ARGV.include?('--dry-run') || ARGV.include?('-n')
  
  puts "🔧 Applying Z3N headers from inventory..."
  puts "   CSV: #{csv_path}"
  puts "   Mode: #{dry_run ? 'DRY RUN' : 'LIVE'}"
  puts ""
  
  total = 0
  updated = 0
  skipped = 0
  
  CSV.foreach(csv_path, headers: true) do |row|
    next if row['Has Z3N'] == 'YES'
    
    file_path = row['Path']
    next unless File.exist?(file_path)
    
    total += 1
    apply_header(file_path, dry_run: dry_run)
    updated += 1 unless dry_run
  end
  
  puts ""
  puts "📊 Summary:"
  puts "   Total processed: #{total}"
  puts "   #{dry_run ? 'Would update' : 'Updated'}: #{updated}"
  puts "   Skipped (already have header): #{skipped}"
else
  # Scan directories directly
  target_dirs = ARGV.any? ? ARGV.select { |a| !a.start_with?('-') } : [
    File.join(DOT3OX_ROOT, 'vec3'),
    CMD_CENTER
  ]

  dry_run = ARGV.include?('--dry-run') || ARGV.include?('-n')

  puts "🔧 Applying Z3N headers to Ruby scripts..."
  puts "   Mode: #{dry_run ? 'DRY RUN' : 'LIVE'}"
  puts ""

  total = 0
  updated = 0
  skipped = 0

  target_dirs.each do |dir|
    next unless File.directory?(dir)
    
    puts "📁 Scanning: #{dir}"
    
    Dir.glob(File.join(dir, '**/*.rb')).each do |file_path|
      total += 1
      
      if has_z3n_header?(file_path)
        skipped += 1
        next
      end
      
      apply_header(file_path, dry_run: dry_run)
      updated += 1 unless dry_run
    end
  end
  
  puts ""
  puts "📊 Summary:"
  puts "   Total scripts: #{total}"
  puts "   #{dry_run ? 'Would update' : 'Updated'}: #{updated}"
  puts "   Already have header: #{skipped}"
end

puts ""
puts "✅ Done!"
# :: ∎