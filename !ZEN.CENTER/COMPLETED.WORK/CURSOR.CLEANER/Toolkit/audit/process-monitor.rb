#!/usr/bin/env ruby
#
# Process Monitor - Ruby Implementation
# CURSOR.CLEANER Toolkit
# Real-time process resource analysis for optimization
#

require 'json'
require 'time'

class ProcessMonitor
  def initialize
    @timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @analysis = {
      timestamp: @timestamp,
      total_processes: 0,
      memory_analysis: {},
      cpu_analysis: {},
      optimization_targets: [],
      recommendations: []
    }
  end

  def analyze_processes
    puts "🔍 CURSOR.CLEANER Process Analysis"
    puts "=" * 50
    puts "Timestamp: #{@timestamp}"
    
    # Get process information via PowerShell
    ps_command = 'Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 20 | ConvertTo-Json'
    processes_json = `powershell -Command "#{ps_command}"`
    
    begin
      processes = JSON.parse(processes_json)
      @analysis[:total_processes] = processes.length
      
      analyze_memory_usage(processes)
      analyze_cpu_usage
      identify_optimization_targets(processes)
      generate_recommendations
      
    rescue JSON::ParserError => e
      puts "❌ Error parsing process data: #{e.message}"
      return false
    end
    
    display_results
    save_analysis
    true
  end

  private

  def analyze_memory_usage(processes)
    total_memory = processes.sum { |p| p['WorkingSet'] || 0 } / (1024.0 * 1024.0)
    @analysis[:memory_analysis][:total_memory_mb] = total_memory.round(2)
    
    # Top memory consumers
    high_memory = processes.select { |p| (p['WorkingSet'] || 0) > 100 * 1024 * 1024 }.first(5)
    @analysis[:memory_analysis][:high_memory_processes] = high_memory.map do |p|
      {
        name: p['ProcessName'],
        memory_mb: ((p['WorkingSet'] || 0) / (1024.0 * 1024.0)).round(2),
        pid: p['Id']
      }
    end
  end

  def analyze_cpu_usage
    # Get CPU usage via PowerShell
    cpu_command = 'Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5 | ConvertTo-Json'
    cpu_json = `powershell -Command "#{cpu_command}"`
    
    begin
      cpu_processes = JSON.parse(cpu_json)
      @analysis[:cpu_analysis][:high_cpu_processes] = cpu_processes.map do |p|
        {
          name: p['ProcessName'],
          cpu_seconds: p['CPU'] || 0,
          pid: p['Id']
        }
      end
    rescue JSON::ParserError
      @analysis[:cpu_analysis][:high_cpu_processes] = []
    end
  end

  def identify_optimization_targets(processes)
    bloatware_services = [
      'XboxGameBar', 'XboxApp', 'XboxGipSvc', 'XblAuthManager', 'XblGameSave',
      'SkypeApp', 'SkypeBackgroundHost', 'SkypeBridge',
      'Cortana', 'SearchUI', 'SearchIndexer',
      'DiagTrack', 'dmwappushservice', 'WerSvc',
      'Fax', 'PrintWorkflowUserSvc', 'PrintSpooler'
    ]

    processes.each do |proc|
      process_name = proc['ProcessName']
      memory_mb = ((proc['WorkingSet'] || 0) / (1024.0 * 1024.0)).round(2)
      
      if bloatware_services.include?(process_name)
        @analysis[:optimization_targets] << {
          process_name: process_name,
          memory_mb: memory_mb,
          action: 'disable_service',
          priority: 'high'
        }
      end
      
      # Identify idle processes with high memory usage
      if (proc['CPU'] || 0) == 0 && memory_mb > 50
        @analysis[:optimization_targets] << {
          process_name: process_name,
          memory_mb: memory_mb,
          action: 'kill_idle',
          priority: 'low'
        }
      end
    end

    # Group processes by name to find duplicates
    process_groups = processes.group_by { |p| p['ProcessName'] }
    process_groups.each do |name, group|
      next if group.length <= 1
      
      total_memory = group.sum { |p| p['WorkingSet'] || 0 } / (1024.0 * 1024.0)
      if total_memory > 200
        @analysis[:optimization_targets] << {
          process_name: name,
          instances: group.length,
          total_memory_mb: total_memory.round(2),
          action: 'consolidate_instances',
          priority: 'medium'
        }
      end
    end
  end

  def generate_recommendations
    recommendations = []
    
    @analysis[:optimization_targets].each do |target|
      case target[:action]
      when 'disable_service'
        recommendations << "Disable #{target[:process_name]} service - saves #{target[:memory_mb]}MB"
      when 'consolidate_instances'
        recommendations << "Consolidate #{target[:instances]} instances of #{target[:process_name]} - saves #{target[:total_memory_mb]}MB"
      when 'kill_idle'
        recommendations << "Kill idle #{target[:process_name]} process - saves #{target[:memory_mb]}MB"
      end
    end
    
    @analysis[:recommendations] = recommendations
  end

  def display_results
    puts "\n📊 MEMORY ANALYSIS:"
    puts "Total Memory Usage: #{@analysis[:memory_analysis][:total_memory_mb]} MB"
    
    puts "\n🔝 TOP MEMORY CONSUMERS:"
    @analysis[:memory_analysis][:high_memory_processes].each do |proc|
      puts "  #{proc[:name]}: #{proc[:memory_mb]} MB (PID: #{proc[:pid]})"
    end
    
    puts "\n⚡ TOP CPU CONSUMERS:"
    @analysis[:cpu_analysis][:high_cpu_processes].each do |proc|
      puts "  #{proc[:name]}: #{proc[:cpu_seconds]} seconds (PID: #{proc[:pid]})"
    end
    
    puts "\n🎯 OPTIMIZATION TARGETS:"
    @analysis[:optimization_targets].each do |target|
      priority_icon = case target[:priority]
                     when 'high' then '🔴'
                     when 'medium' then '🟡'
                     when 'low' then '🟢'
                     end
      puts "  #{priority_icon} #{target[:process_name]}: #{target[:action]} - #{target[:memory_mb]}MB"
    end
    
    puts "\n💡 RECOMMENDATIONS:"
    @analysis[:recommendations].each do |rec|
      puts "  • #{rec}"
    end
  end

  def save_analysis
    output_dir = File.join(File.dirname(__FILE__), "..", "..", "!0UT.CLEANER", "reports")
    FileUtils.mkdir_p(output_dir) unless File.exist?(output_dir)
    
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    report_file = File.join(output_dir, "process_analysis_#{timestamp}.json")
    
    File.write(report_file, JSON.pretty_generate(@analysis))
    puts "\n📄 Report saved: #{report_file}"
  end
end

# Execute if run directly
if __FILE__ == $0
  monitor = ProcessMonitor.new
  monitor.analyze_processes
end






