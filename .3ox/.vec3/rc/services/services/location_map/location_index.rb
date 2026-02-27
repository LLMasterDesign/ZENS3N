# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xE108]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // LOCATION_INDEX.RB ▞▞
# ▛▞// LOCATION_INDEX.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [toml] [yaml] [kernel] [prism] [locationindex] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.location_index.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for LOCATION_INDEX.RB
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





# LOCATION MAP & INDEX SYSTEM
# Each location knows what's in it via .ID files and generates a map/index

require 'json'
require 'time'
require 'fileutils'

class LocationIndex
  def initialize(base_root)
    @base_root = File.expand_path(base_root)
    @index_file = File.join(@base_root, '.3ox', 'location.index.json')
    @map_file = File.join(@base_root, '.3ox', 'location.map.json')
  end
  
  def scan
    puts "Scanning location: #{@base_root}"
    
    map = {
      'location' => @base_root,
      'scanned_at' => Time.now.utc.iso8601,
      'sirius_time' => sirius_time,
      'identity' => load_base_identity,
      'services' => scan_services,
      'id_files' => scan_id_files,
      'directories' => scan_directories,
      'files' => scan_key_files
    }
    
    # Save map
    FileUtils.mkdir_p(File.dirname(@map_file))
    File.write(@map_file, JSON.pretty_generate(map))
    
    # Create index (searchable version)
    index = create_index(map)
    File.write(@index_file, JSON.pretty_generate(index))
    
    puts "Location map created: #{@map_file}"
    puts "Location index created: #{@index_file}"
    
    map
  end
  
  private
  
  def sirius_time
    reset = Time.utc(2025, 8, 8)
    now = Time.now.utc
    year = now.year - reset.year + 25
    day = ((now - reset) / 86400).to_i % 365
    "⧗-#{year}.#{day.to_s.rjust(3, '0')}"
  rescue
    "⧗-??.???"
  end
  
  def load_base_identity
    id_file = File.join(@base_root, '*.BASE.ID')
    id_files = Dir.glob(id_file)
    
    return {} if id_files.empty?
    
    begin
      data = File.read(id_files.first)
      JSON.parse(data)
    rescue
      {}
    end
  end
  
  def scan_services
    services_dir = File.join(@base_root, '.3ox', 'vec3', 'services')
    return [] unless Dir.exist?(services_dir)
    
    services = []
    Dir.glob(File.join(services_dir, '*')).each do |service_dir|
      next unless File.directory?(service_dir)
      
      service_name = File.basename(service_dir)
      id_file = File.join(service_dir, "#{service_name.upcase}.ID")
      
      service_info = {
        'name' => service_name,
        'path' => service_dir,
        'id_file' => File.exist?(id_file) ? id_file : nil
      }
      
      # Load ID if exists
      if File.exist?(id_file)
        begin
          service_info['identity'] = JSON.parse(File.read(id_file))
        rescue
        end
      end
      
      services << service_info
    end
    
    services
  end
  
  def scan_id_files
    id_files = []
    Dir.glob(File.join(@base_root, '**', '*.ID')).each do |id_file|
      begin
        data = JSON.parse(File.read(id_file))
        id_files << {
          'path' => id_file,
          'name' => data['name'] || File.basename(id_file, '.ID'),
          'type' => data['type'] || 'unknown',
          'identity' => data
        }
      rescue
        # Skip invalid ID files
      end
    end
    
    id_files
  end
  
  def scan_directories
    key_dirs = [
      '.3ox',
      '!CMD.CENTER',
      '!WORKDESK',
      '!ZENS3N.OPS',
      '!1N.3OX ZENS3N'
    ]
    
    dirs = {}
    key_dirs.each do |dir_name|
      dir_path = File.join(@base_root, dir_name)
      if Dir.exist?(dir_path)
        dirs[dir_name] = {
          'path' => dir_path,
          'exists' => true,
          'file_count' => count_files(dir_path)
        }
      end
    end
    
    dirs
  end
  
  def scan_key_files
    key_files = []
    patterns = [
      '*.ID',
      '*.md',
      '*.yml',
      '*.yaml',
      '*.toml',
      '*.json'
    ]
    
    patterns.each do |pattern|
      Dir.glob(File.join(@base_root, '**', pattern)).each do |file|
        next if file.include?('node_modules') || file.include?('.git')
        
        key_files << {
          'path' => file,
          'name' => File.basename(file),
          'type' => File.extname(file),
          'size' => File.size(file)
        }
      end
    end
    
    key_files.first(100)  # Limit to first 100 for performance
  end
  
  def count_files(dir)
    count = 0
    Dir.glob(File.join(dir, '**', '*')).each do |path|
      count += 1 if File.file?(path)
    end
    count
  rescue
    0
  end
  
  def create_index(map)
    {
      'location' => map['location'],
      'scanned_at' => map['scanned_at'],
      'services_by_name' => map['services'].map { |s| s['name'] },
      'services_by_type' => map['services'].group_by { |s| s.dig('identity', 'type') },
      'id_files_by_name' => map['id_files'].map { |f| f['name'] },
      'id_files_by_type' => map['id_files'].group_by { |f| f['type'] },
      'directories' => map['directories'].keys,
      'file_count' => map['files'].length,
      'quick_reference' => {
        'base_identity' => map.dig('identity', 'name'),
        'service_count' => map['services'].length,
        'id_file_count' => map['id_files'].length
      }
    }
  end
end

# Command line interface
if __FILE__ == $0
  base_root = ARGV[0] || '/root/!LAUNCHPAD'
  
  indexer = LocationIndex.new(base_root)
  map = indexer.scan
  
  puts "\n" + "=" * 70
  puts "LOCATION MAP SUMMARY"
  puts "=" * 70
  puts "Location: #{map['location']}"
  puts "Base Identity: #{map.dig('identity', 'name') || 'Unknown'}"
  puts "Services: #{map['services'].length}"
  puts "ID Files: #{map['id_files'].length}"
  puts "Key Directories: #{map['directories'].keys.join(', ')}"
  puts "=" * 70
end

:: ∎
# :: ∎