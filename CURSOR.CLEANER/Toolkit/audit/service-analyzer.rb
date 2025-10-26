#!/usr/bin/env ruby
#
# Service Analyzer - Deep Service Optimization Analysis
# CURSOR.CLEANER Toolkit
# Analyzes Windows services for optimization opportunities
#

require 'json'
require 'time'

class ServiceAnalyzer
  def initialize
    @timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @analysis = {
      timestamp: @timestamp,
      total_services: 0,
      running_services: 0,
      auto_start_services: 0,
      optimization_targets: [],
      recommendations: [],
      protected_services: [],
      bloatware_services: []
    }
    
    # Define service categories
    @bloatware_services = [
      'XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc',
      'DiagTrack', 'dmwappushservice', 'WerSvc', 'PcaSvc',
      'Fax', 'PrintWorkflowUserSvc', 'PrintSpooler',
      'WSearch', 'Superfetch', 'SysMain',
      'SkypeApp', 'SkypeBackgroundHost', 'SkypeBridge'
    ]
    
    @protected_services = [
      'Docker Desktop Service', 'com.docker.service',
      'ssh-agent', 'OpenSSH Authentication Agent',
      'WslService', 'LxssManager',
      'Node.js', 'nodejs',
      'Git', 'git',
      'Windows Defender', 'WinDefend', 'MsMpEng',
      'Windows Update', 'wuauserv',
      'Windows Firewall', 'MpsSvc'
    ]
  end

  def analyze_services
    puts "🔍 CURSOR.CLEANER Service Analysis"
    puts "=" * 50
    puts "Timestamp: #{@timestamp}"
    
    # Get all services via PowerShell
    ps_command = 'Get-Service | ConvertTo-Json'
    services_json = `powershell -Command "#{ps_command}"`
    
    begin
      services = JSON.parse(services_json)
      @analysis[:total_services] = services.length
      
      analyze_service_status(services)
      identify_optimization_targets(services)
      generate_recommendations
      
    rescue JSON::ParserError => e
      puts "❌ Error parsing service data: #{e.message}"
      return false
    end
    
    display_results
    save_analysis
    true
  end

  private

  def analyze_service_status(services)
    running_count = 0
    auto_start_count = 0
    
    services.each do |service|
      if service['Status'] == 'Running'
        running_count += 1
      end
      
      # Get detailed service info including startup type
      detail_command = "Get-Service -Name '#{service['Name']}' | Get-Service | Select-Object Name, Status, StartType | ConvertTo-Json"
      detail_json = `powershell -Command "#{detail_command}"`
      
      begin
        detail = JSON.parse(detail_json)
        if detail['StartType'] == 'Automatic'
          auto_start_count += 1
        end
      rescue JSON::ParserError
        # Skip if can't parse detail
      end
    end
    
    @analysis[:running_services] = running_count
    @analysis[:auto_start_services] = auto_start_count
  end

  def identify_optimization_targets(services)
    services.each do |service|
      service_name = service['Name']
      service_status = service['Status']
      
      # Check if it's bloatware
      if @bloatware_services.any? { |bloat| service_name.include?(bloat) }
        @analysis[:bloatware_services] << {
          name: service_name,
          status: service_status,
          action: 'disable',
          priority: 'high',
          reason: 'Windows bloatware'
        }
      end
      
      # Check if it's protected (should not be touched)
      if @protected_services.any? { |prot| service_name.include?(prot) }
        @analysis[:protected_services] << {
          name: service_name,
          status: service_status,
          reason: 'Developer tool or critical system service'
        }
      end
      
      # Identify resource-heavy services that could be optimized
      if service_status == 'Running' && !@protected_services.any? { |prot| service_name.include?(prot) }
        # Check if service is consuming resources
        process_command = "Get-Process | Where-Object { $_.ProcessName -like '*#{service_name}*' } | Select-Object ProcessName, WorkingSet, CPU | ConvertTo-Json"
        process_json = `powershell -Command "#{process_command}"`
        
        begin
          processes = JSON.parse(process_json)
          if processes.is_a?(Array) && processes.any?
            total_memory = processes.sum { |p| p['WorkingSet'] || 0 } / (1024.0 * 1024.0)
            if total_memory > 50 # More than 50MB
              @analysis[:optimization_targets] << {
                name: service_name,
                memory_mb: total_memory.round(2),
                action: 'set_manual',
                priority: 'medium',
                reason: 'High memory usage'
              }
            end
          end
        rescue JSON::ParserError
          # Skip if can't parse process data
        end
      end
    end
  end

  def generate_recommendations
    recommendations = []
    
    # Bloatware recommendations
    @analysis[:bloatware_services].each do |service|
      recommendations << "🔴 Disable #{service[:name]} - #{service[:reason]}"
    end
    
    # Optimization recommendations
    @analysis[:optimization_targets].each do |target|
      recommendations << "🟡 Set #{target[:name]} to Manual - saves #{target[:memory_mb]}MB"
    end
    
    # General recommendations
    if @analysis[:auto_start_services] > 50
      recommendations << "⚡ Too many auto-start services (#{@analysis[:auto_start_services]}) - consider manual startup for non-critical services"
    end
    
    recommendations << "💡 Estimated memory savings: #{calculate_memory_savings}MB"
    
    @analysis[:recommendations] = recommendations
  end

  def calculate_memory_savings
    savings = 0
    
    @analysis[:bloatware_services].each do |service|
      savings += 20 # Estimated 20MB per disabled service
    end
    
    @analysis[:optimization_targets].each do |target|
      savings += target[:memory_mb]
    end
    
    savings.round(2)
  end

  def display_results
    puts "\n📊 SERVICE ANALYSIS:"
    puts "Total Services: #{@analysis[:total_services]}"
    puts "Running Services: #{@analysis[:running_services]}"
    puts "Auto-Start Services: #{@analysis[:auto_start_services]}"
    
    puts "\n🔴 BLOATWARE SERVICES (High Priority):"
    @analysis[:bloatware_services].each do |service|
      puts "  #{service[:name]} (#{service[:status]}) - #{service[:reason]}"
    end
    
    puts "\n🟡 OPTIMIZATION TARGETS (Medium Priority):"
    @analysis[:optimization_targets].each do |target|
      puts "  #{target[:name]}: #{target[:memory_mb]}MB - #{target[:reason]}"
    end
    
    puts "\n✅ PROTECTED SERVICES (Do Not Touch):"
    @analysis[:protected_services].each do |service|
      puts "  #{service[:name]} (#{service[:status]}) - #{service[:reason]}"
    end
    
    puts "\n💡 RECOMMENDATIONS:"
    @analysis[:recommendations].each do |rec|
      puts "  #{rec}"
    end
  end

  def save_analysis
    output_dir = File.join(File.dirname(__FILE__), "..", "..", "!0UT.CLEANER", "reports")
    FileUtils.mkdir_p(output_dir) unless File.exist?(output_dir)
    
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    report_file = File.join(output_dir, "service_analysis_#{timestamp}.json")
    
    File.write(report_file, JSON.pretty_generate(@analysis))
    puts "\n📄 Report saved: #{report_file}"
  end
end

# Execute if run directly
if __FILE__ == $0
  analyzer = ServiceAnalyzer.new
  analyzer.analyze_services
end






