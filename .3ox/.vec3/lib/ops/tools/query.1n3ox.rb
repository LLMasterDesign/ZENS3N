# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x9B33]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // QUERY.1N3OX.RB ▞▞
# ▛▞// QUERY.1N3OX.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [query1n3ox] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.query.1n3ox.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for QUERY.1N3OX.RB
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
##/// Last Updated: 2026.01.05 | Trace.ID: query.1n3ox.v1.0
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.05
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [query_1n3ox] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // QUERY.1N3OX ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# QUERY.1N3OX.RB :: Query 1N.3OX directory contents
# Can query from unified state or scan directly
#

require 'json'
require 'fileutils'

# Add vec3 to path
VEC3_ROOT = File.expand_path('../..', File.dirname(__FILE__))
$LOAD_PATH.unshift(VEC3_ROOT) unless $LOAD_PATH.include?(VEC3_ROOT)

require_relative 'lib/helpers.rb'
require_relative 'cache/redis.rb'

module Query1N3OX
  include Helpers
  extend self

  def find_1n3ox_dir
    project_root = get_project_root
    
    # Search for existing input folders
    search_patterns = [
      File.join(project_root, "!1N.3OX*"),
      File.join(project_root, "1N.3OX*"),
      File.join(project_root, "!1n.3ox*"),
      File.join(project_root, "1n.3ox*")
    ]

    input_folders = search_patterns.flat_map { |pattern| Dir.glob(pattern, File::FNM_CASEFOLD) }.uniq
    
    return input_folders.first if input_folders.any?
    
    # Fallback: create default
    default_path = File.join(project_root, "!1N.3OX")
    FileUtils.mkdir_p(default_path) unless File.directory?(default_path)
    default_path
  end

  def scan_directory(dir)
    files = []
    subdirs = []
    
    return { files: [], subdirs: [], error: "Directory not found: #{dir}" } unless File.directory?(dir)
    
    Dir.glob(File.join(dir, '*')).each do |path|
      next if File.basename(path).start_with?('.')
      
      if File.directory?(path)
        subdirs << {
          'name' => File.basename(path),
          'path' => path,
          'type' => 'directory'
        }
      else
        stat = File.stat(path)
        ext = File.extname(path).downcase
        
        files << {
          'name' => File.basename(path),
          'path' => path,
          'type' => classify_file_type(ext),
          'size' => stat.size,
          'mtime' => stat.mtime.utc.iso8601,
          'extension' => ext.empty? ? 'none' : ext[1..-1]
        }
      end
    end
    
    { files: files.sort_by { |f| f['name'] }, subdirs: subdirs.sort_by { |d| d['name'] } }
  end

  def classify_file_type(ext)
    case ext
    when '.md', '.markdown' then 'markdown'
    when '.png', '.jpg', '.jpeg', '.gif', '.webp' then 'image'
    when '.pdf' then 'document'
    when '.txt' then 'text'
    when '.json' then 'data'
    when '.rb' then 'script'
    when '.sh' then 'shell'
    else 'file'
    end
  end

  def query_from_unified_state(dir_path)
    return nil unless RedisCache.redis_available?
    
    state = RedisCache.redis_get('cmd.bridge:unified:state')
    return nil unless state && state['files']
    
    # Filter files in this directory
    dir_files = state['files'].select { |path, _| path.start_with?(dir_path) || path.include?(dir_path) }
    
    return nil if dir_files.empty?
    
    files = []
    dir_files.each do |rel_path, info|
      files << {
        'name' => File.basename(rel_path),
        'path' => info['path'] || rel_path,
        'type' => classify_file_type(File.extname(rel_path)),
        'size' => info['size'],
        'mtime' => info['mtime']
      }
    end
    
    { files: files, subdirs: [], source: 'unified_state' }
  end

  def query(dir_path = nil)
    dir_path ||= find_1n3ox_dir
    
    # Try unified state first
    result = query_from_unified_state(dir_path)
    return result if result && result[:files].any?
    
    # Fallback to direct scan
    result = scan_directory(dir_path)
    result[:source] = 'direct_scan'
    result
  end

  def format_output(result)
    return "Error: #{result[:error]}" if result[:error]
    
    output = []
    output << "1N.3OX Directory: #{result[:source] == 'unified_state' ? '(from unified state)' : '(direct scan)'}"
    output << ""
    
    if result[:files].any?
      output << "Files (#{result[:files].length}):"
      result[:files].each do |file|
        size_kb = (file['size'] / 1024.0).round(1)
        output << "  • #{file['name']} [#{file['type']}] (#{size_kb}KB)"
      end
      output << ""
    end
    
    if result[:subdirs].any?
      output << "Subdirectories (#{result[:subdirs].length}):"
      result[:subdirs].each do |dir|
        output << "  📁 #{dir['name']}/"
      end
      output << ""
    end
    
    if result[:files].empty? && result[:subdirs].empty?
      output << "Directory is empty"
    end
    
    output.join("\n")
  end
end

# Standalone execution
if __FILE__ == $0
  dir_path = ARGV[0]
  result = Query1N3OX.query(dir_path)
  puts Query1N3OX.format_output(result)
end

# :: ∎