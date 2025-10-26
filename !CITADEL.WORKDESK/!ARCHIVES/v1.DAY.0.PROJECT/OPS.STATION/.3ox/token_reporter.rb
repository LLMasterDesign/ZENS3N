#!/usr/bin/env ruby
#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
#▛//▞▞ ⟦⎊⟧ :: TOKEN REPORTER :: Simple token usage reporting
#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

require 'yaml'
require 'time'
require 'fileutils'

module TokenReporter
  
  # ============================================================================
  # Log Token Usage to Dedicated Log File
  # ============================================================================
  
  def self.log_usage(session_id, stats, metadata = {})
    FileUtils.mkdir_p('.3ox') unless Dir.exist?('.3ox')
    
    File.open('.3ox/tokens.log', 'a') do |f|
      f.puts format_log_entry(session_id, stats, metadata)
    end
  end
  
  def self.format_log_entry(session_id, stats, metadata)
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    agent = metadata[:agent] || 'UNKNOWN'
    
    [
      timestamp,
      session_id.ljust(15),
      agent.ljust(12),
      "#{stats[:total_tokens].to_s.rjust(6)}t",
      "#{stats[:message_count].to_s.rjust(3)}m",
      "#{sprintf('%.1f', stats[:utilization])}%".rjust(6),
      stats[:model]
    ].join(' | ')
  end
  
  # ============================================================================
  # Generate Detailed Report
  # ============================================================================
  
  def self.generate_report(output_path = nil)
    output_path ||= "0ut.3ox/reports/token_report_#{Time.now.to_i}.txt"
    FileUtils.mkdir_p(File.dirname(output_path))
    
    report = build_report
    
    File.write(output_path, report)
    puts "📊 Token report generated: #{output_path}"
    
    output_path
  end
  
  def self.build_report
    sessions = parse_token_logs
    trace_data = parse_trace_logs
    
    report = []
    report << "="*80
    report << "TOKEN USAGE REPORT"
    report << "Generated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    report << "="*80
    report << ""
    
    # Summary Statistics
    report << "SUMMARY"
    report << "-"*80
    report << summary_stats(sessions)
    report << ""
    
    # Per-Session Breakdown
    report << "RECENT SESSIONS"
    report << "-"*80
    sessions.last(10).each do |session|
      report << format_session_detail(session)
    end
    report << ""
    
    # Warnings
    warnings = extract_warnings(trace_data)
    if warnings.any?
      report << "WARNINGS"
      report << "-"*80
      warnings.each { |w| report << "  ⚠️  #{w}" }
      report << ""
    end
    
    report << "="*80
    
    report.join("\n")
  end
  
  # ============================================================================
  # Parse Log Files
  # ============================================================================
  
  def self.parse_token_logs
    return [] unless File.exist?('.3ox/tokens.log')
    
    sessions = []
    File.readlines('.3ox/tokens.log').each do |line|
      parts = line.strip.split(' | ')
      next if parts.length < 6
      
      sessions << {
        timestamp: parts[0],
        session_id: parts[1].strip,
        agent: parts[2].strip,
        tokens: parts[3].gsub('t', '').strip.to_i,
        messages: parts[4].gsub('m', '').strip.to_i,
        utilization: parts[5].gsub('%', '').strip.to_f,
        model: parts[6]
      }
    end
    
    sessions
  end
  
  def self.parse_trace_logs
    return [] unless File.exist?('.3ox/trace.log')
    
    traces = []
    File.readlines('.3ox/trace.log').each do |line|
      traces << line if line.include?('TOKEN_')
    end
    
    traces
  end
  
  # ============================================================================
  # Report Sections
  # ============================================================================
  
  def self.summary_stats(sessions)
    return "No session data available" if sessions.empty?
    
    total_tokens = sessions.sum { |s| s[:tokens] }
    total_messages = sessions.sum { |s| s[:messages] }
    avg_tokens_per_session = (total_tokens.to_f / sessions.length).round(0)
    avg_tokens_per_message = sessions.map { |s| s[:messages] > 0 ? s[:tokens].to_f / s[:messages] : 0 }.sum / sessions.length
    
    models = sessions.map { |s| s[:model] }.tally
    
    lines = []
    lines << "  Total Sessions: #{sessions.length}"
    lines << "  Total Tokens: #{total_tokens.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    lines << "  Total Messages: #{total_messages}"
    lines << "  Avg Tokens/Session: #{avg_tokens_per_session}"
    lines << "  Avg Tokens/Message: #{sprintf('%.1f', avg_tokens_per_message)}"
    lines << ""
    lines << "  Models Used:"
    models.each { |model, count| lines << "    #{model}: #{count} sessions" }
    
    lines.join("\n")
  end
  
  def self.format_session_detail(session)
    [
      "",
      "  Session: #{session[:session_id]}",
      "  Time: #{session[:timestamp]}",
      "  Agent: #{session[:agent]}",
      "  Model: #{session[:model]}",
      "  Tokens: #{session[:tokens]} (#{sprintf('%.1f', session[:utilization])}% utilization)",
      "  Messages: #{session[:messages]}"
    ].join("\n")
  end
  
  def self.extract_warnings(trace_data)
    warnings = []
    trace_data.each do |line|
      if line.include?('TOKEN_WARNING')
        # Extract warning message
        match = line.match(/warning["\s:=>]*([^",}]+)/)
        warnings << match[1].strip if match
      end
    end
    warnings.uniq
  end
  
  # ============================================================================
  # Ship Report to 0ut.3ox
  # ============================================================================
  
  def self.ship_to_ops(session_id, stats, agent_name)
    # Log to tokens.log
    log_usage(session_id, stats, { agent: agent_name })
    
    # Add to manifest for ops pickup
    manifest_path = '0ut.3ox/FILE.MANIFEST.txt'
    FileUtils.mkdir_p('0ut.3ox') unless Dir.exist?('0ut.3ox')
    
    File.open(manifest_path, 'a') do |f|
      f.puts "[#{sirius_time}] | TOKEN_STATS | #{session_id} | #{stats[:total_tokens]}t | #{agent_name}"
    end
    
    # Generate report if this is an end-of-session
    generate_report if should_generate_report?
  end
  
  def self.should_generate_report?
    # Generate report once per day or every 50 sessions
    last_report = Dir.glob('0ut.3ox/reports/token_report_*.txt').max
    
    if last_report
      last_time = File.mtime(last_report)
      return true if Time.now - last_time > 86400  # 24 hours
    else
      return true
    end
    
    # Check session count
    sessions = parse_token_logs
    sessions.length % 50 == 0
  end
  
  private
  
  def self.sirius_time
    reset = Time.new(2025, 8, 8)
    now = Time.now
    days = ((now - reset) / 86400).to_i
    year = now.year % 100
    "⧗-#{year}.#{days}"
  end
end

# ============================================================================
# CLI Usage
# ============================================================================

if __FILE__ == $0
  puts "Token Reporter - Generating report..."
  report_path = TokenReporter.generate_report
  puts "\n✅ Report saved to: #{report_path}"
  puts "\nTo view:"
  puts "  cat #{report_path}"
end

