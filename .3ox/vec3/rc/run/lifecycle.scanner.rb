#!/usr/bin/env ruby
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.191 // LIFECYCLE.SCANNER :: 24/7 File Lifecycle Management ▞▞
# ▛▞// LIFECYCLE.SCANNER :: ρ{Scan}.φ{Analyze}.τ{Manage} ▹
# //▞⋮⋮ ⟦📁⟧ :: [scanner] [lifecycle] [24/7] [drive.management] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.lifecycle.scanner.context〕

require 'json'
require 'fileutils'
require 'digest'
require 'find'

class LifecycleScanner
  SCAN_INTERVAL = 300 # 5 minutes
  MAX_FILE_AGE_DAYS = 365 # 1 year
  LARGE_FILE_SIZE = 100 * 1024 * 1024 # 100MB
  STATE_FILE = File.join(__dir__, '../../var/state/scanner_state.json')
  LOG_FILE = File.join(__dir__, '../../var/log/lifecycle_scanner.log')

  def initialize
    @running = true
    @scan_paths = determine_scan_paths
    @state = load_state
    @last_scan = @state['last_scan'] || Time.at(0)
  end

  def run
    puts "▛▞// Lifecycle Scanner starting..."
    puts "▛▞// Scan paths: #{@scan_paths.join(', ')}"
    puts "▛▞// Scan interval: #{SCAN_INTERVAL}s"
    puts "▛▞// Press Ctrl+C to stop"
    puts ""

    Signal.trap('INT') { shutdown }
    Signal.trap('TERM') { shutdown }

    loop do
      break unless @running
      
      begin
        scan_cycle
        save_state
        sleep SCAN_INTERVAL
      rescue => e
        log_error("Scan cycle error: #{e.message}")
        sleep 60 # Wait 1 minute on error
      end
    end

    puts "▛▞// Scanner stopped"
  end

  private

  def determine_scan_paths
    base = File.expand_path('../../../../..', __FILE__)
    [
      File.join(base, '!1N.3OX ZENS3N'),
      File.join(base, '!ZENS3N.OPS'),
      File.join(base, '!WORKDESK'),
      File.join(base, 'codex53-work')
    ].select { |p| Dir.exist?(p) }
  end

  def scan_cycle
    log("Starting scan cycle at #{Time.now}")
    stats = {
      scanned: 0,
      large_files: [],
      old_files: [],
      duplicates: [],
      candidates: []
    }

    @scan_paths.each do |path|
      scan_directory(path, stats)
    end

    analyze_results(stats)
    @last_scan = Time.now
    log("Scan complete: #{stats[:scanned]} files scanned")
  end

  def scan_directory(path, stats)
    return unless Dir.exist?(path)

    Find.find(path) do |file_path|
      next if File.directory?(file_path)
      next if should_skip?(file_path)

      stats[:scanned] += 1
      file_info = analyze_file(file_path)
      
      if file_info[:size] > LARGE_FILE_SIZE
        stats[:large_files] << file_info
      end

      if file_info[:age_days] > MAX_FILE_AGE_DAYS
        stats[:old_files] << file_info
      end

      if file_info[:duplicate]
        stats[:duplicates] << file_info
      end

      stats[:candidates] << file_info if should_candidate?(file_info)
    end
  rescue => e
    log_error("Error scanning #{path}: #{e.message}")
  end

  def should_skip?(path)
    return true if path.include?('/.git/')
    return true if path.include?('/node_modules/')
    return true if path.include?('/.3ox/vec3/var/')
    return true if path.end_with?('.log')
    false
  end

  def analyze_file(file_path)
    stat = File.stat(file_path)
    age_days = (Time.now - stat.mtime).to_i / 86400
    
    {
      path: file_path,
      size: stat.size,
      age_days: age_days,
      mtime: stat.mtime,
      duplicate: check_duplicate(file_path),
      action: determine_action(stat.size, age_days)
    }
  end

  def check_duplicate(file_path)
    # Simple duplicate check by size + name
    basename = File.basename(file_path)
    size = File.size(file_path)
    
    @state['file_index'] ||= {}
    key = "#{basename}:#{size}"
    
    if @state['file_index'][key]
      @state['file_index'][key] << file_path
      return true
    else
      @state['file_index'][key] = [file_path]
      return false
    end
  end

  def determine_action(size, age_days)
    if age_days > 730 # 2 years
      'archive'
    elsif age_days > 365 && size > 50 * 1024 * 1024 # 1 year + 50MB
      'compress'
    elsif size > 500 * 1024 * 1024 # 500MB
      'review'
    else
      'monitor'
    end
  end

  def should_candidate?(file_info)
    file_info[:age_days] > MAX_FILE_AGE_DAYS ||
    file_info[:size] > LARGE_FILE_SIZE ||
    file_info[:duplicate]
  end

  def analyze_results(stats)
    return if stats[:candidates].empty?

    log("Found #{stats[:candidates].size} lifecycle candidates")
    
    report = {
      timestamp: Time.now.iso8601,
      large_files: stats[:large_files].size,
      old_files: stats[:old_files].size,
      duplicates: stats[:duplicates].size,
      candidates: stats[:candidates].first(10).map { |f| {
        path: f[:path],
        size: f[:size],
        age_days: f[:age_days],
        action: f[:action]
      }}
    }

    save_report(report)
  end

  def save_report(report)
    report_dir = File.join(__dir__, '../../var/state/reports')
    FileUtils.mkdir_p(report_dir)
    
    report_file = File.join(report_dir, "lifecycle_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json")
    File.write(report_file, JSON.pretty_generate(report))
    log("Report saved: #{report_file}")
  end

  def load_state
    return {} unless File.exist?(STATE_FILE)
    JSON.parse(File.read(STATE_FILE))
  rescue
    {}
  end

  def save_state
    state = {
      'last_scan' => @last_scan.to_i,
      'file_index' => @state['file_index'] || {}
    }
    
    FileUtils.mkdir_p(File.dirname(STATE_FILE))
    File.write(STATE_FILE, JSON.pretty_generate(state))
  end

  def log(message)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    log_line = "[#{timestamp}] #{message}\n"
    
    FileUtils.mkdir_p(File.dirname(LOG_FILE))
    File.open(LOG_FILE, 'a') { |f| f.write(log_line) }
    puts "▛▞// #{message}"
  end

  def log_error(message)
    log("ERROR: #{message}")
  end

  def shutdown
    puts "\n▛▞// Shutting down scanner..."
    @running = false
    save_state
  end
end

if __FILE__ == $0
  scanner = LifecycleScanner.new
  scanner.run
end

# :: ∎
# //▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙
