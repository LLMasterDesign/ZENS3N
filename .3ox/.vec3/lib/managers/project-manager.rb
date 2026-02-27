# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x7FA3]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // PROJECT-MANAGER.RB ▞▞
# ▛▞// PROJECT-MANAGER.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [yaml] [kernel] [prism] [z3n] [projectmanager] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.project-manager.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for PROJECT-MANAGER.RB
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
##/// Last Updated: 2026.01.07 | Trace.ID: project-manager.v1.0
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.07
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [project-manager] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // PROJECT-MANAGER ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# PROJECT-MANAGER.RB :: Complete project management system for 3OX
# Includes versioning, tracking, notifications, and deployment readiness
#

require 'yaml'
require 'json'
require 'fileutils'
require_relative 'tracking-agent.rb'

class ProjectManager
  def initialize
    @projects_dir = '/root/!CMD.BRIDGE/!WORKDESK/PROJECTS'
    @completed_dir = File.join(@projects_dir, 'completed')
    @active_dir = File.join(@projects_dir, 'active')
    @sold_dir = File.join(@projects_dir, 'sold')
    @versions_dir = File.join(@projects_dir, 'versions')

    @tracking_agent = TrackingAgent.new

    setup_directories
    @projects = load_projects
  end

  def setup_directories
    [@projects_dir, @completed_dir, @active_dir, @sold_dir, @versions_dir].each do |dir|
      FileUtils.mkdir_p(dir)
    end
  end

  def load_projects
    projects = {}

    # Load from different directories
    [@active_dir, @completed_dir, @sold_dir].each do |dir|
      Dir.glob("#{dir}/*/project.yaml").each do |project_file|
        project_data = YAML.load_file(project_file)
        project_name = project_data['name']
        projects[project_name] = project_data
      end
    end

    projects
  end

  # ============================================================================
  # PROJECT CREATION & MANAGEMENT
  # ============================================================================

  def create_project(name, type = 'web', description = "")
    puts "🚀 Creating project: #{name} (#{type})"

    project_dir = File.join(@active_dir, name.downcase.gsub(' ', '-'))
    FileUtils.mkdir_p(project_dir)

    project_data = {
      'name' => name,
      'type' => type,
      'description' => description,
      'status' => 'active',
      'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S UTC'),
      'updated_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S UTC'),
      'progress' => 0,
      'estimated_value' => 0,
      'sold_price' => nil,
      'sold_at' => nil,
      'versions' => [],
      'tasks' => [],
      'dependencies' => [],
      'tags' => [],
      'directory' => project_dir
    }

    # Save project file
    project_file = File.join(project_dir, 'project.yaml')
    File.write(project_file, project_data.to_yaml)

    # Create basic project structure
    create_project_structure(project_dir, type)

    @projects[name] = project_data

    puts "✅ Project #{name} created successfully"
    puts "📁 Location: #{project_dir}"

    # Auto-value the project
    puts "💰 Auto-valuing project..."
    valuation = @tracking_agent.value_project(name, description)
    update_project_value(name, valuation)

    project_data
  end

  def create_project_structure(dir, type)
    case type
    when 'web'
      FileUtils.mkdir_p([
        File.join(dir, 'src'),
        File.join(dir, 'public'),
        File.join(dir, 'tests'),
        File.join(dir, 'docs')
      ])

      # Create basic files
      File.write(File.join(dir, 'README.md'), "# #{File.basename(dir)}\n\n#{Time.now}\n")
      File.write(File.join(dir, 'package.json'), '{"name": "' + File.basename(dir) + '", "version": "1.0.0"}')

    when 'api'
      FileUtils.mkdir_p([
        File.join(dir, 'lib'),
        File.join(dir, 'spec'),
        File.join(dir, 'docs'),
        File.join(dir, 'config')
      ])

      File.write(File.join(dir, 'README.md'), "# #{File.basename(dir)} API\n\n#{Time.now}\n")
      File.write(File.join(dir, 'Gemfile'), "source 'https://rubygems.org'\n\ngem 'sinatra'\n")

    when 'cli'
      FileUtils.mkdir_p([
        File.join(dir, 'bin'),
        File.join(dir, 'lib'),
        File.join(dir, 'spec'),
        File.join(dir, 'docs')
      ])

      File.write(File.join(dir, 'README.md'), "# #{File.basename(dir)} CLI\n\n#{Time.now}\n")
      File.write(File.join(dir, 'bin', File.basename(dir)), "#!/usr/bin/env ruby\n\nputs 'Hello from #{File.basename(dir)}'\n")
      File.chmod(0755, File.join(dir, 'bin', File.basename(dir)))
    end
  end

  # ============================================================================
  # VERSIONING SYSTEM
  # ============================================================================

  def create_version(project_name, tag, description = "")
    puts "🏷️  Creating version #{tag} for #{project_name}"

    project = @projects[project_name]
    return puts "❌ Project #{project_name} not found" unless project

    project_dir = project['directory']
    version_dir = File.join(@versions_dir, project_name, tag)
    FileUtils.mkdir_p(version_dir)

    # Copy current project state
    Dir.glob("#{project_dir}/**/*").each do |file|
      next if File.directory?(file)
      next if File.basename(file) == 'project.yaml' # Don't version the project file itself

      relative_path = file.sub(project_dir + '/', '')
      target_file = File.join(version_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(target_file))
      FileUtils.cp(file, target_file)
    end

    version_info = {
      'project' => project_name,
      'tag' => tag,
      'description' => description,
      'created_at' => Time.now.strftime('%Y-%m-%d %H:%M:%S UTC'),
      'files_count' => Dir.glob("#{version_dir}/**/*").length,
      'commit_hash' => `git rev-parse HEAD 2>/dev/null`.strip
    }

    version_file = File.join(version_dir, 'version.yaml')
    File.write(version_file, version_info.to_yaml)

    # Update project
    project['versions'] ||= []
    project['versions'] << version_info
    save_project(project_name)

    puts "✅ Version #{tag} created for #{project_name}"
    puts "📁 Location: #{version_dir}"
    puts "📊 Files: #{version_info['files_count']}"

    version_info
  end

  def list_versions(project_name = nil)
    puts "🏷️  Project Versions:"
    puts "=" * 50

    if project_name
      project = @projects[project_name]
      if project && project['versions']
        puts "#{project_name}:"
        project['versions'].each do |v|
          puts "  • #{v['tag']} - #{v['description']} (#{v['created_at']})"
        end
      else
        puts "No versions found for #{project_name}"
      end
    else
      @projects.each do |name, data|
        versions_count = data['versions']&.length || 0
        puts "• #{name}: #{versions_count} versions"
      end
    end
  end

  # ============================================================================
  # PROJECT TRACKING & STATUS
  # ============================================================================

  def update_progress(project_name, progress, notes = "")
    project = @projects[project_name]
    return puts "❌ Project #{project_name} not found" unless project

    old_progress = project['progress'] || 0
    project['progress'] = progress
    project['updated_at'] = Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')

    # Add to task history
    task = {
      'type' => 'progress_update',
      'from' => old_progress,
      'to' => progress,
      'notes' => notes,
      'timestamp' => Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')
    }

    project['tasks'] ||= []
    project['tasks'] << task

    save_project(project_name)

    puts "📈 Updated #{project_name} progress: #{old_progress}% → #{progress}%"

    # Auto-complete if 100%
    if progress >= 100 && project['status'] != 'completed'
      complete_project(project_name, "Reached 100% completion")
    end
  end

  def complete_project(project_name, notes = "")
    project = @projects[project_name]
    return puts "❌ Project #{project_name} not found" unless project

    project['status'] = 'completed'
    project['completed_at'] = Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')
    project['updated_at'] = Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')

    # Move to completed directory
    old_dir = project['directory']
    new_dir = File.join(@completed_dir, File.basename(old_dir))
    FileUtils.mv(old_dir, new_dir)
    project['directory'] = new_dir

    # Add completion task
    task = {
      'type' => 'completed',
      'notes' => notes,
      'timestamp' => Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')
    }

    project['tasks'] ||= []
    project['tasks'] << task

    save_project(project_name)

    puts "🎉 Project #{project_name} marked as COMPLETED!"
    puts "📁 Moved to: #{new_dir}"

    # Create version automatically
    create_version(project_name, "v1.0.0", "Initial release - project completed")
  end

  def sell_project(project_name, price, notes = "")
    project = @projects[project_name]
    return puts "❌ Project #{project_name} not found" unless project

    project['status'] = 'sold'
    project['sold_price'] = price
    project['sold_at'] = Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')
    project['updated_at'] = Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')

    # Move to sold directory
    old_dir = project['directory']
    new_dir = File.join(@sold_dir, File.basename(old_dir))
    FileUtils.mv(old_dir, new_dir)
    project['directory'] = new_dir

    # Add sale task
    task = {
      'type' => 'sold',
      'price' => price,
      'notes' => notes,
      'timestamp' => Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')
    }

    project['tasks'] ||= []
    project['tasks'] << task

    save_project(project_name)

    puts "💰 Project #{project_name} SOLD for $#{price}!"
    puts "📁 Moved to: #{new_dir}"

    # Calculate profit if we have estimated value
    if project['estimated_value']
      profit = price - project['estimated_value']
      puts "📊 Profit: $#{'%.2f' % profit} (#{(profit > 0 ? '+' : '')}#{'%.1f' % ((profit / project['estimated_value']) * 100)}%)"
    end
  end

  def update_project_value(project_name, valuation)
    project = @projects[project_name]
    return unless project

    project['estimated_value'] = valuation&.dig('estimated_value') || 0
    project['recommended_price'] = valuation&.dig('recommended_price') || 0
    project['valuation_confidence'] = valuation&.dig('confidence') || 0

    save_project(project_name)

    puts "💰 Updated #{project_name} valuation: $#{project['estimated_value']}"
  end

  # ============================================================================
  # REPORTING & ANALYTICS
  # ============================================================================

  def status_report
    puts "📊 3OX PROJECT STATUS REPORT"
    puts "=" * 50
    puts "Generated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts ""

    total_projects = @projects.length
    active_projects = @projects.values.count { |p| p['status'] == 'active' }
    completed_projects = @projects.values.count { |p| p['status'] == 'completed' }
    sold_projects = @projects.values.count { |p| p['status'] == 'sold' }

    puts "📈 OVERVIEW:"
    puts "• Total Projects: #{total_projects}"
    puts "• Active: #{active_projects}"
    puts "• Completed: #{completed_projects}"
    puts "• Sold: #{sold_projects}"
    puts ""

    total_value = @projects.values.sum { |p| p['estimated_value'] || 0 }
    total_sales = @projects.values.sum { |p| p['sold_price'] || 0 }

    puts "💰 FINANCIAL:"
    puts "• Total Estimated Value: $#{'%.2f' % total_value}"
    puts "• Total Sales: $#{'%.2f' % total_sales}"
    puts "• Average Project Value: $#{'%.2f' % (total_value / total_projects)}" if total_projects > 0
    puts ""

    puts "🎯 ACTIVE PROJECTS:"
    @projects.values.select { |p| p['status'] == 'active' }.each do |project|
      progress = project['progress'] || 0
      value = project['estimated_value'] || 0
      puts "• #{project['name']}: #{progress}% complete, $#{value} value"
    end

    puts ""
    puts "🏆 COMPLETED PROJECTS:"
    @projects.values.select { |p| p['status'] == 'completed' }.each do |project|
      puts "• #{project['name']}: Ready for sale"
    end

    puts ""
    puts "💵 SOLD PROJECTS:"
    @projects.values.select { |p| p['status'] == 'sold' }.each do |project|
      price = project['sold_price'] || 0
      puts "• #{project['name']}: Sold for $#{price}"
    end
  end

  def save_project(project_name)
    project = @projects[project_name]
    return unless project

    project_file = File.join(project['directory'], 'project.yaml')
    File.write(project_file, project.to_yaml)
  end

  # ============================================================================
  # DEPLOYMENT READINESS CHECK
  # ============================================================================

  def check_deployment_readiness(project_name)
    puts "🔍 Checking deployment readiness for: #{project_name}"

    project = @projects[project_name]
    return puts "❌ Project #{project_name} not found" unless project

    checks = {
      'has_readme' => File.exist?(File.join(project['directory'], 'README.md')),
      'has_package_json' => File.exist?(File.join(project['directory'], 'package.json')) || File.exist?(File.join(project['directory'], 'Gemfile')),
      'has_tests' => Dir.exist?(File.join(project['directory'], 'tests')) || Dir.exist?(File.join(project['directory'], 'spec')),
      'has_docs' => Dir.exist?(File.join(project['directory'], 'docs')),
      'has_version' => !project['versions'].empty?,
      'progress_complete' => (project['progress'] || 0) >= 100,
      'has_valuation' => project['estimated_value'] && project['estimated_value'] > 0
    }

    passed = checks.values.count(true)
    total = checks.length

    puts "📋 Deployment Readiness: #{passed}/#{total} checks passed"
    puts ""

    checks.each do |check, result|
      status = result ? "✅" : "❌"
      name = check.to_s.gsub('_', ' ').capitalize
      puts "#{status} #{name}"
    end

    puts ""
    if passed == total
      puts "🚀 PROJECT READY FOR DEPLOYMENT!"
      puts "💰 Can be sold/deployed immediately"
    else
      puts "⚠️  Project needs #{total - passed} more items before deployment"
    end

    checks
  end

  # ============================================================================
  # COMMAND LINE INTERFACE
  # ============================================================================

  def run(args)
    command = args.shift

    case command
    when 'create'
      name = args.shift
      type = args.shift || 'web'
      description = args.join(' ')
      create_project(name, type, description)

    when 'progress'
      project_name = args.shift
      progress = args.shift&.to_i
      notes = args.join(' ')
      if project_name && progress
        update_progress(project_name, progress, notes)
      else
        puts "Usage: project-manager.rb progress <project> <percentage> [notes]"
      end

    when 'complete'
      project_name = args.shift
      notes = args.join(' ')
      complete_project(project_name, notes)

    when 'sell'
      project_name = args.shift
      price = args.shift&.to_f
      notes = args.join(' ')
      if project_name && price
        sell_project(project_name, price, notes)
      else
        puts "Usage: project-manager.rb sell <project> <price> [notes]"
      end

    when 'version'
      subcommand = args.shift
      case subcommand
      when 'create'
        project_name = args.shift
        tag = args.shift
        description = args.join(' ')
        create_version(project_name, tag, description)
      else
        puts "Usage: project-manager.rb version create <project> <tag> [description]"
      end

    when 'versions'
      project_name = args.shift
      list_versions(project_name)

    when 'check'
      project_name = args.shift
      check_deployment_readiness(project_name)

    when 'status'
      status_report

    when 'list'
      puts "📋 All Projects:"
      @projects.each do |name, data|
        status = data['status'] || 'unknown'
        progress = data['progress'] || 0
        value = data['estimated_value'] || 0
        puts "• #{name} (#{status}) - #{progress}% - $#{'%.0f' % value}"
      end

    else
      puts "3OX Project Manager v1.0"
      puts ""
      puts "Commands:"
      puts "  create <name> [type] [desc]  - Create new project"
      puts "  progress <project> <pct>     - Update progress"
      puts "  complete <project>           - Mark as completed"
      puts "  sell <project> <price>       - Record sale"
      puts "  version create <p> <tag>     - Create version"
      puts "  versions [project]           - List versions"
      puts "  check <project>              - Deployment readiness"
      puts "  status                       - Full status report"
      puts "  list                         - List all projects"
      puts ""
      puts "Project Types: web, api, cli"
    end
  end
end

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __FILE__ == $0
  manager = ProjectManager.new
  manager.run(ARGV)
end

# :: ∎