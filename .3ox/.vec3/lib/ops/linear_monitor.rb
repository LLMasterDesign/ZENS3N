# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x758A]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // LINEAR_MONITOR.RB ▞▞
# ▛▞// LINEAR_MONITOR.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [z3n] [linearmonitor] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.linear_monitor.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for LINEAR_MONITOR.RB
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
##/// Last Updated: 2026.01.07 | Trace.ID: linear_monitor.v1.0
##/// Status: [ACTIVE] | Cat: SCRIPT | Auth: SYSTEM | Created: 2026.01.07
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [linear_monitor] [script] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // LINEAR_MONITOR ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
# Linear Monitoring & Change Tracking System
# Integrates Linear API with .3ox vec3 system for progress tracking

require 'json'
require 'net/http'
require 'uri'
require 'fileutils'
require 'time'
require 'find'

class LinearMonitor
  LINEAR_API = 'https://api.linear.app/graphql'
  
  def initialize(api_key_path = nil)
    @workspace_root = File.expand_path('../../../../..', __FILE__)
    # Normalize workspace root (handle WSL paths)
    @workspace_root = '/root/!CMD.BRIDGE' if @workspace_root.include?('/mnt/r/')
    @state_file = File.join(@workspace_root, '.3ox/vec3/var/state/linear_monitor.json')
    @log_dir = File.join(@workspace_root, '.3ox/vec3/var/log')
    FileUtils.mkdir_p(@log_dir)
    FileUtils.mkdir_p(File.dirname(@state_file))
    @api_key = load_api_key(api_key_path)
    load_state
  end
  
  def load_api_key(path = nil)
    if path.nil?
      # Try multiple possible paths (handle WSL path differences)
      script_dir = File.dirname(__FILE__)
      workspace_from_script = File.expand_path('../../../../..', script_dir)
      
      possible_paths = [
        File.join(workspace_from_script, '.3ox/vec3/rc/secrets/api.keys'),
        '/root/!CMD.BRIDGE/.3ox/vec3/rc/secrets/api.keys',
        File.expand_path('.3ox/vec3/rc/secrets/api.keys', ENV['HOME'] || '/root')
      ]
      
      # Add WSL path variant if needed
      if workspace_from_script.include?('/mnt/r/')
        possible_paths << workspace_from_script.gsub('/mnt/r/', '/root/') + '/.3ox/vec3/rc/secrets/api.keys'
      end
      
      possible_paths.compact!
      
      path = possible_paths.find { |p| File.exist?(p) }
      unless path
        log_error("API key file not found. Tried: #{possible_paths.inspect}")
        return nil
      end
    end
    
    return nil unless File.exist?(path)
    
    File.readlines(path).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')
      
      if line =~ /^LINEAR_API_KEY=(.+)$/
        key = $1.strip
        # Remove inline comments
        key = key.split('#').first.strip if key.include?('#')
        log_info("API key loaded from #{path}")
        return key
      end
    end
    
    log_error("LINEAR_API_KEY not found in #{path}")
    nil
  end
  
  def load_state
    @state = if File.exist?(@state_file)
      JSON.parse(File.read(@state_file))
    else
      {
        'last_sync' => nil,
        'known_issues' => {},
        'tracked_projects' => [],
        'change_history' => []
      }
    end
  end
  
  def save_state
    File.write(@state_file, JSON.pretty_generate(@state))
  end
  
  def graphql_query(query, variables = {})
    unless @api_key
      log_error("No API key loaded")
      return nil
    end
    
    uri = URI(LINEAR_API)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path)
    request['Authorization'] = @api_key
    request['Content-Type'] = 'application/json'
    request.body = { query: query, variables: variables }.to_json
    
    response = http.request(request)
    result = JSON.parse(response.body)
    
    if result['errors']
      log_error("GraphQL errors: #{result['errors'].inspect}")
      return nil
    end
    
    result
  rescue => e
    log_error("GraphQL query failed: #{e.message}")
    log_error(e.backtrace.first(3).join("\n")) if e.backtrace
    nil
  end
  
  def get_all_issues
    query = <<~GRAPHQL
      {
        issues {
          nodes {
            id
            identifier
            title
            state {
              name
            }
            priority
            priorityLabel
            assignee {
              name
              email
            }
            createdAt
            updatedAt
            labels {
              nodes {
                name
              }
            }
            description
          }
        }
      }
    GRAPHQL
    
    result = graphql_query(query)
    return [] unless result && result['data']
    
    result['data']['issues']['nodes']
  end
  
  def get_teams
    query = <<~GRAPHQL
      {
        teams {
          nodes {
            id
            name
            key
          }
        }
      }
    GRAPHQL
    
    result = graphql_query(query)
    return [] unless result && result['data']
    
    result['data']['teams']['nodes']
  end
  
  def create_issue(team_id, title, description = nil, priority = nil)
    mutation = <<~GRAPHQL
      mutation CreateIssue($input: IssueCreateInput!) {
        issueCreate(input: $input) {
          success
          issue {
            id
            identifier
            title
          }
        }
      }
    GRAPHQL
    
    variables = {
      input: {
        teamId: team_id,
        title: title,
        description: description,
        priority: priority
      }.compact
    }
    
    result = graphql_query(mutation, variables)
    return nil unless result && result['data'] && result['data']['issueCreate']['success']
    
    result['data']['issueCreate']['issue']
  end
  
  def update_issue(issue_id, state_name = nil, priority = nil)
    # First get state ID
    state_id = nil
    if state_name
      states_query = <<~GRAPHQL
        {
          workflowStates {
            nodes {
              id
              name
            }
          }
        }
      GRAPHQL
      
      states_result = graphql_query(states_query)
      if states_result && states_result['data']
        state = states_result['data']['workflowStates']['nodes'].find { |s| s['name'] == state_name }
        state_id = state['id'] if state
      end
    end
    
    mutation = <<~GRAPHQL
      mutation UpdateIssue($id: String!, $input: IssueUpdateInput!) {
        issueUpdate(id: $id, input: $input) {
          success
          issue {
            id
            title
            state {
              name
            }
          }
        }
      }
    GRAPHQL
    
    input = {}
    input['stateId'] = state_id if state_id
    input['priority'] = priority if priority
    
    return nil if input.empty?
    
    variables = {
      id: issue_id,
      input: input
    }
    
    result = graphql_query(mutation, variables)
    return nil unless result && result['data'] && result['data']['issueUpdate']['success']
    
    result['data']['issueUpdate']['issue']
  end
  
  def assess_progress
    issues = get_all_issues
    return nil unless issues
    
    stats = {
      'total' => issues.length,
      'by_state' => {},
      'by_priority' => {},
      'projects' => {},
      'completion_rate' => 0,
      'recent_activity' => []
    }
    
    done_count = 0
    issues.each do |issue|
      state = issue['state']['name']
      stats['by_state'][state] ||= 0
      stats['by_state'][state] += 1
      
      done_count += 1 if state == 'Done'
      
      priority = issue['priorityLabel'] || 'No priority'
      stats['by_priority'][priority] ||= 0
      stats['by_priority'][priority] += 1
      
      # Extract project from title
      if issue['title'] =~ /^\[(.+?)\]/ 
        project = $1
        stats['projects'][project] ||= { 'total' => 0, 'done' => 0 }
        stats['projects'][project]['total'] += 1
        stats['projects'][project]['done'] += 1 if state == 'Done'
      end
      
      # Track recent activity (last 7 days)
      updated = Time.parse(issue['updatedAt'])
      if updated > (Time.now - 7 * 24 * 60 * 60)
        stats['recent_activity'] << {
          'id' => issue['id'],
          'title' => issue['title'],
          'state' => state,
          'updated' => issue['updatedAt']
        }
      end
    end
    
    stats['completion_rate'] = stats['total'] > 0 ? (done_count.to_f / stats['total'] * 100).round(1) : 0
    
    stats
  end
  
  def generate_progress_report
    stats = assess_progress
    return "Unable to fetch Linear data" unless stats
    
    report = []
    report << "=== LINEAR PROGRESS ASSESSMENT ==="
    report << ""
    report << "Overall Progress:"
    report << "  Total Issues: #{stats['total']}"
    report << "  Completed: #{stats['by_state']['Done'] || 0} (#{stats['completion_rate']}%)"
    report << "  Active: #{stats['total'] - (stats['by_state']['Done'] || 0)}"
    report << ""
    
    if stats['projects'].any?
      report << "Project Breakdown:"
      stats['projects'].each do |project, data|
        pct = data['total'] > 0 ? (data['done'].to_f / data['total'] * 100).round(1) : 0
        report << "  #{project}: #{data['done']}/#{data['total']} (#{pct}%)"
      end
      report << ""
    end
    
    report << "By State:"
    stats['by_state'].sort.each do |state, count|
      report << "  #{state}: #{count}"
    end
    report << ""
    
    if stats['recent_activity'].any?
      report << "Recent Activity (last 7 days):"
      stats['recent_activity'].sort_by { |a| a['updated'] }.reverse.first(10).each do |activity|
        report << "  → #{activity['title']} [#{activity['state']}]"
      end
    end
    
    report.join("\n")
  end
  
  def track_changes(since_time = nil)
    since_time ||= @state['last_change_check'] ? Time.parse(@state['last_change_check']) : Time.now - 24 * 60 * 60
    
    changes = {
      'timestamp' => Time.now.iso8601,
      'new_files' => [],
      'modified_files' => [],
      'git_commits' => [],
      'project_changes' => {}
    }
    
    # Track git changes
    changes['git_commits'] = get_git_changes(since_time)
    
    # Track significant file changes in key directories
    key_dirs = [
      '.3ox',
      '!CMD.CENTER',
      '!WORKDESK',
      'CITADEL.BASE'
    ]
    
    key_dirs.each do |dir|
      dir_path = File.join(@workspace_root, dir)
      next unless File.directory?(dir_path)
      
      file_changes = detect_file_changes(dir_path, since_time)
      changes['new_files'].concat(file_changes[:new])
      changes['modified_files'].concat(file_changes[:modified])
    end
    
    # Detect project-level changes
    changes['project_changes'] = detect_project_changes(changes)
    
    # Log to vec3/var/events
    log_change_event(changes)
    
    @state['change_history'] << changes
    @state['change_history'] = @state['change_history'].last(100)
    @state['last_change_check'] = changes['timestamp']
    save_state
    
    log_info("Change tracking: #{changes['new_files'].length} new, #{changes['modified_files'].length} modified, #{changes['git_commits'].length} commits")
    
    changes
  end
  
  def get_git_changes(since_time)
    return [] unless git_available?
    
    commits = []
    begin
      # Get commits since time
      since_str = since_time.strftime('%Y-%m-%d %H:%M:%S')
      cmd = "cd '#{@workspace_root}' && git log --since='#{since_str}' --pretty=format:'%H|%an|%ae|%ad|%s' --date=iso 2>/dev/null"
      output = `#{cmd}`.strip
      
      output.split("\n").each do |line|
        parts = line.split('|', 5)
        next unless parts.length == 5
        
        commits << {
          'hash' => parts[0],
          'author' => parts[1],
          'email' => parts[2],
          'date' => parts[3],
          'message' => parts[4]
        }
      end
    rescue => e
      log_error("Git change detection failed: #{e.message}")
    end
    
    commits
  end
  
  def detect_file_changes(dir_path, since_time)
    new_files = []
    modified_files = []
    
    begin
      Find.find(dir_path) do |path|
        next unless File.file?(path)
        next if path.include?('.git/') || path.include?('node_modules/')
        next if path.include?('.3ox/var/') # Skip var directories
        
        mtime = File.mtime(path)
        next if mtime < since_time
        
        rel_path = path.sub(@workspace_root + '/', '')
        
        if File.exist?(path) && mtime > since_time
          if @state['known_files'] && @state['known_files'][rel_path]
            modified_files << {
              'path' => rel_path,
              'modified' => mtime.iso8601,
              'size' => File.size(path)
            }
          else
            new_files << {
              'path' => rel_path,
              'created' => mtime.iso8601,
              'size' => File.size(path)
            }
            @state['known_files'] ||= {}
            @state['known_files'][rel_path] = mtime.iso8601
          end
        end
      end
    rescue => e
      log_error("File change detection failed for #{dir_path}: #{e.message}")
    end
    
    { new: new_files, modified: modified_files }
  end
  
  def detect_project_changes(changes)
    project_changes = {}
    
    # Group changes by project
    all_files = changes['new_files'] + changes['modified_files']
    all_files.each do |file|
      path = file['path']
      
      # Extract project from path
      project = nil
      if path =~ /!WORKDESK\/([^\/]+)/
        project = $1
      elsif path =~ /!CMD\.CENTER\/([^\/]+)/
        project = $1
      elsif path =~ /CITADEL\.BASE\/([^\/]+)/
        project = $1
      elsif path =~ /\.3ox\/([^\/]+)/
        project = '.3ox'
      end
      
      next unless project
      
      project_changes[project] ||= { 'new' => [], 'modified' => [] }
      if file['created']
        project_changes[project]['new'] << file
      else
        project_changes[project]['modified'] << file
      end
    end
    
    project_changes
  end
  
  def log_change_event(changes)
    event_file = File.join(@workspace_root, '.3ox/vec3/var/events', "linear_change_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json")
    FileUtils.mkdir_p(File.dirname(event_file))
    File.write(event_file, JSON.pretty_generate(changes))
    log_info("Change event logged to #{File.basename(event_file)}")
  end
  
  def git_available?
    system("cd '#{@workspace_root}' && git rev-parse --git-dir > /dev/null 2>&1")
  end
  
  def sync_with_linear
    log_info("Starting Linear sync...")
    
    issues = get_all_issues
    return false unless issues
    
    # Update known issues
    issues.each do |issue|
      @state['known_issues'][issue['id']] = {
        'identifier' => issue['identifier'],
        'title' => issue['title'],
        'state' => issue['state']['name'],
        'updated' => issue['updatedAt'],
        'last_synced' => Time.now.iso8601
      }
    end
    
    @state['last_sync'] = Time.now.iso8601
    save_state
    
    log_info("Sync complete: #{issues.length} issues tracked")
    true
  end
  
  def log_info(message)
    log_entry = "[#{Time.now.iso8601}] INFO: #{message}\n"
    File.write(File.join(@log_dir, 'linear_monitor.log'), log_entry, mode: 'a')
    puts log_entry.strip
  end
  
  def log_error(message)
    log_entry = "[#{Time.now.iso8601}] ERROR: #{message}\n"
    File.write(File.join(@log_dir, 'linear_monitor.log'), log_entry, mode: 'a')
    $stderr.puts log_entry.strip
  end
end

# CLI interface
if __FILE__ == $0
  monitor = LinearMonitor.new
  
  case ARGV[0]
  when 'sync'
    monitor.sync_with_linear
  when 'report'
    puts monitor.generate_progress_report
  when 'assess'
    stats = monitor.assess_progress
    puts JSON.pretty_generate(stats)
  when 'track'
    monitor.track_changes
  else
    puts "Usage: #{$0} [sync|report|assess|track]"
    puts "  sync   - Sync with Linear API"
    puts "  report - Generate progress report"
    puts "  assess - Get detailed stats (JSON)"
    puts "  track  - Track codebase changes"
  end
end

# :: ∎