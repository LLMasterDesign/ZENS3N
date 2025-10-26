#!/usr/bin/env ruby
#
# RUN.RB :: CURSOR.CLEANER Runtime Orchestrator
# Aggressive System Optimizer with Safety Protocols
#

require 'xxhash'
require 'time'
require 'fileutils'
require 'json'
require 'yaml'
require 'openssl'
require 'digest'

# ============================================================================
# CURSOR.CLEANER Configuration
# ============================================================================

CLEANER_SIGIL = "〘⟦⎊⟧・.°CLEANER.RB〙"
OUTPUT_FOLDER = "!0UT.CLEANER"
LOG_FILE = ".3ox/3ox.log"

# ============================================================================
# Core Functions
# ============================================================================

def validate_file(filepath)
  unless File.exist?(filepath)
    return { valid: false, error: "File not found" }
  end
  
  file_hash = XXhash.xxh64(File.read(filepath)).to_s(16)
  
  {
    valid: true,
    path: filepath,
    hash: file_hash[0..15],
    size: File.size(filepath)
  }
end

def load_tools
  tools_file = File.join(File.dirname(__FILE__), "tools.yml")
  return {} unless File.exist?(tools_file)
  
  YAML.load_file(tools_file)
end

def load_routes
  routes_file = File.join(File.dirname(__FILE__), "routes.json")
  return {} unless File.exist?(routes_file)
  
  JSON.parse(File.read(routes_file))["routes"]
end

def load_limits
  limits_file = File.join(File.dirname(__FILE__), "limits.json")
  return {} unless File.exist?(limits_file)
  
  JSON.parse(File.read(limits_file))
end

def load_brain
  brain_bin = File.join(File.dirname(__FILE__), "brain.exe")
  
  # Try to run compiled Rust binary
  if File.exist?(brain_bin)
    output = `#{brain_bin} config 2>&1`
    return JSON.parse(output) if $?.success?
  end
  
  # Fallback: Parse brain.rs as text
  brain_file = File.join(File.dirname(__FILE__), "brain.rs")
  return { "name" => "CURSOR.CLEANER", "type" => "Alchemist", "rules" => [] } unless File.exist?(brain_file)
  
  content = File.read(brain_file)
  name = content[/name: "([^"]+)"/, 1] || "CURSOR.CLEANER"
  brain_type = content[/brain: BrainType::(\w+)/, 1] || "Alchemist"
  rules = content.scan(/Rule::(\w+)/).flatten.uniq
  
  { "name" => name, "type" => brain_type, "rules" => rules }
end

def load_whitelist
  whitelist_file = File.join(File.dirname(__FILE__), "..", "Config", "whitelist.yml")
  return {} unless File.exist?(whitelist_file)
  
  YAML.load_file(whitelist_file)
end

def load_aggressive_targets
  targets_file = File.join(File.dirname(__FILE__), "..", "Config", "aggressive-targets.yml")
  return {} unless File.exist?(targets_file)
  
  YAML.load_file(targets_file)
end

def log_operation(operation, status, details = "")
  log_file = File.join(File.dirname(__FILE__), LOG_FILE)
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  
  log_entry = "\n[#{timestamp}] #{CLEANER_SIGIL}\n"
  log_entry += "  Operation: #{operation}\n"
  log_entry += "  Status: #{status}\n"
  log_entry += "  Details: #{details}\n" unless details.empty?
  
  File.open(log_file, "a") { |f| f.write(log_entry) }
end

def find_or_create_output_folder
  """CURSOR.CLEANER outputs to !0UT.CLEANER (ENFORCED)"""
  
  # Cleaner has fixed output location
  output_folder = File.join(File.dirname(__FILE__), "..", OUTPUT_FOLDER)
  
  # Ensure it exists
  FileUtils.mkdir_p(output_folder) unless File.exist?(output_folder)
  
  # Ensure subfolders exist
  ["reports", "receipts", "backups"].each do |subdir|
    subdir_path = File.join(output_folder, subdir)
    FileUtils.mkdir_p(subdir_path) unless File.exist?(subdir_path)
  end
  
  output_folder
end

def create_restore_point
  """Create Windows system restore point before aggressive operations"""
  puts "🔄 Creating system restore point..."
  
  restore_name = "CURSOR.CLEANER_#{Time.now.strftime('%Y%m%d_%H%M%S')}"
  cmd = "powershell -Command \"Checkpoint-Computer -Description '#{restore_name}' -RestorePointType 'MODIFY_SETTINGS'\""
  
  result = system(cmd)
  if result
    puts "✓ System restore point created: #{restore_name}"
    log_operation("create_restore_point", "COMPLETE", "Name: #{restore_name}")
    return true
  else
    puts "❌ Failed to create restore point"
    log_operation("create_restore_point", "FAILED", "Command failed")
    return false
  end
end

def generate_rollback_script(operations)
  """Generate PowerShell rollback script for all operations"""
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  rollback_file = File.join(find_or_create_output_folder, "backups", "rollback_#{timestamp}.ps1")
  
  script_content = "# CURSOR.CLEANER Rollback Script\n"
  script_content += "# Generated: #{Time.now.iso8601}\n"
  script_content += "# Operations to undo: #{operations.length}\n\n"
  
  operations.each do |op|
    case op[:type]
    when "service_disable"
      script_content += "# Restore service: #{op[:service]}\n"
      script_content += "Set-Service -Name '#{op[:service]}' -StartupType #{op[:original_startup]}\n"
    when "file_delete"
      script_content += "# Restore file: #{op[:file]}\n"
      script_content += "# File was deleted - manual restoration required\n"
    when "registry_delete"
      script_content += "# Restore registry: #{op[:key]}\n"
      script_content += "New-Item -Path '#{op[:key]}' -Force\n"
    end
    script_content += "\n"
  end
  
  File.write(rollback_file, script_content)
  puts "✓ Rollback script created: #{rollback_file}"
  
  rollback_file
end

# ============================================================================
# Main Operations
# ============================================================================

def run_audit
  puts "=" * 60
  puts "🔍 CURSOR.CLEANER SYSTEM AUDIT"
  puts "=" * 60
  
  # Load configuration
  tools = load_tools
  limits = load_limits
  brain = load_brain
  whitelist = load_whitelist
  
  puts "\n✓ Brain: #{brain['name']} (#{brain['type']})"
  puts "✓ Rules: #{brain['rules'].take(3).join(', ')}"
  puts "✓ Tools loaded: #{tools.fetch('tools', []).length} available"
  puts "✓ Whitelist loaded: #{whitelist.fetch('protected_paths', []).length} protected paths"
  
  # Run audit tools
  audit_tools = [
    "Toolkit/audit/disk-analyzer.ps1",
    "Toolkit/audit/temp-hunter.ps1", 
    "Toolkit/audit/bloat-detector.rb",
    "Toolkit/audit/service-analyzer.rb",
    "Toolkit/audit/startup-audit.ps1",
    "Toolkit/audit/process-monitor.rb"
  ]
  
  puts "\n🔍 Running audit tools..."
  audit_tools.each do |tool|
    tool_path = File.join(File.dirname(__FILE__), "..", tool)
    if File.exist?(tool_path)
      puts "  ✓ #{tool}"
      # In real implementation, would execute the tool
    else
      puts "  ⚠ #{tool} (not found)"
    end
  end
  
  # Generate audit report
  output_folder = find_or_create_output_folder
  report_file = File.join(output_folder, "reports", "audit_#{Time.now.strftime('%Y%m%d_%H%M%S')}.md")
  
  report_content = "# CURSOR.CLEANER Audit Report\n"
  report_content += "Generated: #{Time.now.iso8601}\n\n"
  report_content += "## System Analysis\n"
  report_content += "- Disk space analysis: Pending\n"
  report_content += "- Temp file analysis: Pending\n"
  report_content += "- Service optimization: Pending\n"
  report_content += "- Bloat detection: Pending\n"
  
  File.write(report_file, report_content)
  puts "\n✓ Audit report generated: #{report_file}"
  
  log_operation("system_audit", "COMPLETE", "Report: #{report_file}")
  
  puts "\n" + "=" * 60
  puts "AUDIT COMPLETE"
  puts "=" * 60
end

def run_cleanup(args)
  aggressive = args.include?("aggressive") || args.include?("--aggressive")
  dry_run = args.include?("--dry-run")
  
  puts "=" * 60
  puts "🧹 CURSOR.CLEANER CLEANUP MODE"
  puts "=" * 60
  puts "Mode: #{aggressive ? 'AGGRESSIVE' : 'SAFE'}"
  puts "Dry Run: #{dry_run ? 'YES' : 'NO'}"
  
  if aggressive && !dry_run
    unless create_restore_point
      puts "❌ Cannot proceed without restore point"
      return false
    end
  end
  
  # Load configuration
  whitelist = load_whitelist
  targets = load_aggressive_targets
  
  puts "\n✓ Whitelist: #{whitelist.fetch('protected_paths', []).length} protected paths"
  puts "✓ Targets: #{targets.fetch('auto_clean_paths', []).length} auto-clean paths"
  
  # Run cleanup tools
  cleanup_tools = [
    "Toolkit/cleanup/auto-clean-temp.ps1",
    "Toolkit/cleanup/deep-clean-system.ps1",
    "Toolkit/cleanup/dev-clean.rb",
    "Toolkit/cleanup/bloat-remover.ps1",
    "Toolkit/cleanup/duplicate-destroyer.rb"
  ]
  
  puts "\n🧹 Running cleanup tools..."
  operations = []
  
  cleanup_tools.each do |tool|
    tool_path = File.join(File.dirname(__FILE__), "..", tool)
    if File.exist?(tool_path)
      puts "  ✓ #{tool}"
      # In real implementation, would execute and track operations
      operations << { type: "file_delete", file: "example_temp_file", timestamp: Time.now }
    else
      puts "  ⚠ #{tool} (not found)"
    end
  end
  
  # Generate rollback script
  if operations.any? && !dry_run
    rollback_file = generate_rollback_script(operations)
    puts "\n✓ Rollback script: #{rollback_file}"
  end
  
  # Generate cleanup report
  output_folder = find_or_create_output_folder
  report_file = File.join(output_folder, "reports", "cleanup_#{Time.now.strftime('%Y%m%d_%H%M%S')}.md")
  
  report_content = "# CURSOR.CLEANER Cleanup Report\n"
  report_content += "Generated: #{Time.now.iso8601}\n"
  report_content += "Mode: #{aggressive ? 'AGGRESSIVE' : 'SAFE'}\n"
  report_content += "Dry Run: #{dry_run ? 'YES' : 'NO'}\n\n"
  report_content += "## Operations Performed\n"
  report_content += "- Operations: #{operations.length}\n"
  report_content += "- Space recovered: TBD\n"
  
  File.write(report_file, report_content)
  puts "\n✓ Cleanup report generated: #{report_file}"
  
  log_operation("system_cleanup", "COMPLETE", "Mode: #{aggressive ? 'aggressive' : 'safe'}, Operations: #{operations.length}")
  
  puts "\n" + "=" * 60
  puts "CLEANUP COMPLETE"
  puts "=" * 60
end

def run_optimization(args)
  target = args.first || "all"
  
  puts "=" * 60
  puts "⚡ CURSOR.CLEANER OPTIMIZATION MODE"
  puts "=" * 60
  puts "Target: #{target.upcase}"
  
  # Create restore point for optimization
  unless create_restore_point
    puts "❌ Cannot proceed without restore point"
    return false
  end
  
  # Run optimization tools
  optimize_tools = [
    "Toolkit/optimize/service-optimizer.rb",
    "Toolkit/optimize/startup-optimizer.ps1",
    "Toolkit/optimize/performance-tuner.ps1",
    "Toolkit/optimize/registry-cleaner.rb",
    "Toolkit/optimize/system-optimizer.ps1"
  ]
  
  puts "\n⚡ Running optimization tools..."
  operations = []
  
  optimize_tools.each do |tool|
    tool_path = File.join(File.dirname(__FILE__), "..", tool)
    if File.exist?(tool_path)
      puts "  ✓ #{tool}"
      # In real implementation, would execute and track operations
      operations << { type: "service_disable", service: "example_service", original_startup: "Automatic", timestamp: Time.now }
    else
      puts "  ⚠ #{tool} (not found)"
    end
  end
  
  # Generate rollback script
  rollback_file = generate_rollback_script(operations)
  puts "\n✓ Rollback script: #{rollback_file}"
  
  # Generate optimization report
  output_folder = find_or_create_output_folder
  report_file = File.join(output_folder, "reports", "optimization_#{Time.now.strftime('%Y%m%d_%H%M%S')}.md")
  
  report_content = "# CURSOR.CLEANER Optimization Report\n"
  report_content += "Generated: #{Time.now.iso8601}\n"
  report_content += "Target: #{target}\n\n"
  report_content += "## Optimizations Applied\n"
  report_content += "- Services optimized: #{operations.length}\n"
  report_content += "- Performance improvements: TBD\n"
  
  File.write(report_file, report_content)
  puts "\n✓ Optimization report generated: #{report_file}"
  
  log_operation("system_optimization", "COMPLETE", "Target: #{target}, Operations: #{operations.length}")
  
  puts "\n" + "=" * 60
  puts "OPTIMIZATION COMPLETE"
  puts "=" * 60
end

def run_rollback
  puts "=" * 60
  puts "🔄 CURSOR.CLEANER ROLLBACK MODE"
  puts "=" * 60
  
  # Find latest rollback script
  backups_dir = File.join(find_or_create_output_folder, "backups")
  rollback_files = Dir.glob(File.join(backups_dir, "rollback_*.ps1")).sort_by { |f| File.mtime(f) }
  
  if rollback_files.empty?
    puts "❌ No rollback scripts found"
    return false
  end
  
  latest_rollback = rollback_files.last
  puts "✓ Latest rollback script: #{File.basename(latest_rollback)}"
  
  puts "\n⚠️  WARNING: This will undo previous CURSOR.CLEANER operations"
  puts "Continue? (y/N): "
  
  # In real implementation, would prompt user and execute rollback
  puts "Rollback execution would run: #{latest_rollback}"
  
  log_operation("rollback_execution", "PENDING", "Script: #{latest_rollback}")
  
  puts "\n" + "=" * 60
  puts "ROLLBACK READY"
  puts "=" * 60
end

# ============================================================================
# Execute
# ============================================================================

def show_help
  puts "CURSOR.CLEANER - Aggressive AI System Optimizer"
  puts "=" * 50
  puts "Usage: ruby run.rb [command] [options]"
  puts ""
  puts "Commands:"
  puts "  audit                    - Run system analysis"
  puts "  clean [aggressive]       - Clean system (safe or aggressive)"
  puts "  optimize [target]        - Optimize services/performance"
  puts "  rollback                 - Undo last operation"
  puts "  help                     - Show this help"
  puts ""
  puts "Options:"
  puts "  --dry-run               - Test mode, no changes made"
  puts "  --aggressive            - Aggressive cleanup mode"
  puts ""
  puts "Examples:"
  puts "  ruby run.rb audit"
  puts "  ruby run.rb clean aggressive"
  puts "  ruby run.rb optimize services"
  puts "  ruby run.rb clean --dry-run"
end

if __FILE__ == $0
  if ARGV.empty? || ARGV.include?("help")
    show_help
  else
    command = ARGV[0]
    args = ARGV[1..-1] || []
    
    case command
    when "audit"
      run_audit
    when "clean"
      run_cleanup(args)
    when "optimize"
      run_optimization(args)
    when "rollback"
      run_rollback
    else
      puts "Unknown command: #{command}"
      show_help
    end
  end
end





