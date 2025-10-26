#!/usr/bin/env ruby
#
# Bloat Detector - System Bloat Identification
# CURSOR.CLEANER Toolkit
# Identifies Windows bloatware and unused features
#

require 'json'
require 'time'

class BloatDetector
  def initialize
    @timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @analysis = {
      timestamp: @timestamp,
      installed_apps: [],
      windows_features: [],
      bloatware_detected: [],
      recommendations: [],
      estimated_savings_gb: 0
    }
    
    # Define bloatware patterns
    @bloatware_patterns = [
      /Microsoft\.Xbox/i,
      /Microsoft\.Bing/i,
      /Microsoft\.GetHelp/i,
      /Microsoft\.GetStarted/i,
      /Microsoft\.Microsoft3DViewer/i,
      /Microsoft\.MicrosoftOfficeHub/i,
      /Microsoft\.MicrosoftSolitaireCollection/i,
      /Microsoft\.MixedReality/i,
      /Microsoft\.Office\.OneNote/i,
      /Microsoft\.People/i,
      /Microsoft\.Skype/i,
      /Microsoft\.StorePurchaseApp/i,
      /Microsoft\.Wallet/i,
      /Microsoft\.WindowsAlarms/i,
      /Microsoft\.WindowsCamera/i,
      /Microsoft\.WindowsMaps/i,
      /Microsoft\.WindowsSoundRecorder/i,
      /Microsoft\.Zune/i,
      /CandyCrush/i,
      /Disney/i,
      /Facebook/i,
      /Instagram/i,
      /Netflix/i,
      /Spotify/i,
      /TikTok/i
    ]
  end

  def analyze_bloat
    puts "🔍 CURSOR.CLEANER Bloat Detection"
    puts "=" * 50
    puts "Timestamp: #{@timestamp}"
    
    analyze_installed_apps
    analyze_windows_features
    generate_recommendations
    
    display_results
    save_analysis
    true
  end

  private

  def analyze_installed_apps
    puts "\n📱 Analyzing installed apps..."
    
    # Get installed apps via PowerShell
    ps_command = 'Get-AppxPackage | Select-Object Name, PackageFullName, InstallLocation | ConvertTo-Json'
    apps_json = `powershell -Command "#{ps_command}"`
    
    begin
      apps = JSON.parse(apps_json)
      apps = [apps] unless apps.is_a?(Array)
      
      @analysis[:installed_apps] = apps.map do |app|
        {
          name: app['Name'],
          package_name: app['PackageFullName'],
          install_location: app['InstallLocation'],
          is_bloatware: detect_bloatware?(app['Name'])
        }
      end
      
      # Identify bloatware
      @analysis[:bloatware_detected] = @analysis[:installed_apps].select { |app| app[:is_bloatware] }
      
    rescue JSON::ParserError => e
      puts "❌ Error parsing apps data: #{e.message}"
    end
  end

  def analyze_windows_features
    puts "\n⚙️ Analyzing Windows features..."
    
    # Get Windows features via PowerShell
    ps_command = 'Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq "Enabled" } | Select-Object FeatureName, State | ConvertTo-Json'
    features_json = `powershell -Command "#{ps_command}"`
    
    begin
      features = JSON.parse(features_json)
      features = [features] unless features.is_a?(Array)
      
      @analysis[:windows_features] = features.map do |feature|
        {
          name: feature['FeatureName'],
          state: feature['State'],
          removable: removable_feature?(feature['FeatureName'])
        }
      end
      
    rescue JSON::ParserError => e
      puts "❌ Error parsing features data: #{e.message}"
    end
  end

  def detect_bloatware?(app_name)
    @bloatware_patterns.any? { |pattern| app_name.match?(pattern) }
  end

  def removable_feature?(feature_name)
    removable_features = [
      'FaxServicesClientPackage',
      'Printing-XPSServices-Features',
      'Printing-PrintToPDFServices-Features',
      'Printing-Foundation-Features',
      'MediaPlayback',
      'WindowsMediaPlayer',
      'WorkFolders-Client',
      'SMB1Protocol',
      'SMB1Protocol-Client',
      'SMB1Protocol-Server'
    ]
    
    removable_features.any? { |feature| feature_name.include?(feature) }
  end

  def generate_recommendations
    recommendations = []
    
    # App recommendations
    @analysis[:bloatware_detected].each do |app|
      recommendations << "🗑️ Remove #{app[:name]} - Windows bloatware"
      @analysis[:estimated_savings_gb] += 0.5 # Estimate 0.5GB per app
    end
    
    # Feature recommendations
    removable_features = @analysis[:windows_features].select { |f| f[:removable] }
    removable_features.each do |feature|
      recommendations << "⚙️ Disable #{feature[:name]} - unused Windows feature"
      @analysis[:estimated_savings_gb] += 0.1 # Estimate 0.1GB per feature
    end
    
    # General recommendations
    if @analysis[:bloatware_detected].length > 10
      recommendations << "📊 High bloatware count (#{@analysis[:bloatware_detected].length}) - consider bulk removal"
    end
    
    recommendations << "💡 Estimated space savings: #{@analysis[:estimated_savings_gb].round(2)} GB"
    
    @analysis[:recommendations] = recommendations
  end

  def display_results
    puts "\n📱 INSTALLED APPS:"
    puts "Total Apps: #{@analysis[:installed_apps].length}"
    puts "Bloatware Detected: #{@analysis[:bloatware_detected].length}"
    
    puts "\n🗑️ BLOATWARE APPS:"
    @analysis[:bloatware_detected].each do |app|
      puts "  #{app[:name]}"
    end
    
    puts "\n⚙️ WINDOWS FEATURES:"
    puts "Enabled Features: #{@analysis[:windows_features].length}"
    
    removable_features = @analysis[:windows_features].select { |f| f[:removable] }
    if removable_features.any?
      puts "\nRemovable Features:"
      removable_features.each do |feature|
        puts "  #{feature[:name]}"
      end
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
    report_file = File.join(output_dir, "bloat_analysis_#{timestamp}.json")
    
    File.write(report_file, JSON.pretty_generate(@analysis))
    puts "\n📄 Report saved: #{report_file}"
  end
end

# Execute if run directly
if __FILE__ == $0
  detector = BloatDetector.new
  detector.analyze_bloat
end






