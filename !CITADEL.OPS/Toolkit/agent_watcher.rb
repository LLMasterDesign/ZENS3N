#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../core/agent_orchestrator'

### ///▙▖▙▖▞▞▙ AGENT WATCHER SERVICE ▂▂▂▂▂▂▂▂▂▂▂▂

class AgentWatcher
  def initialize(redis_client = nil)
    @orchestrator = AgentOrchestrator.new(redis_client)
    @completion_callbacks = []
  end
  
  def self.available?
    AgentOrchestrator.available?
  end
  
  def enabled?
    @orchestrator.enabled?
  end
  
  # === Monitoring ===
  
  def check_all_agents
    return { success: false, error: "AgentWatcher not enabled" } unless enabled?
    
    active_agents = @orchestrator.list_active_agents
    completed_agents = []
    
    active_agents.each do |agent|
      # Monitor each agent
      result = @orchestrator.monitor_agent(agent[:id])
      
      if result[:success] && result[:status] == 'completed'
        # Agent completed - get final results
        completion = @orchestrator.complete_agent(agent[:id])
        completed_agents << completion if completion[:success]
        
        # Trigger callbacks
        trigger_completion_callbacks(completion)
      end
    end
    
    {
      success: true,
      checked: active_agents.length,
      completed: completed_agents.length,
      completed_agents: completed_agents
    }
  rescue => e
    { success: false, error: e.message }
  end
  
  def check_agent(agent_id)
    return { success: false, error: "AgentWatcher not enabled" } unless enabled?
    
    result = @orchestrator.monitor_agent(agent_id)
    return result unless result[:success]
    
    if result[:status] == 'completed'
      # Agent completed
      completion = @orchestrator.complete_agent(agent_id)
      trigger_completion_callbacks(completion) if completion[:success]
      
      { success: true, status: 'completed', completion: completion }
    else
      { success: true, status: result[:status], progress: result[:progress] }
    end
  rescue => e
    { success: false, error: e.message }
  end
  
  # === Callback Management ===
  
  def on_agent_complete(&block)
    @completion_callbacks << block
  end
  
  def trigger_completion_callbacks(completion_data)
    @completion_callbacks.each do |callback|
      begin
        callback.call(completion_data)
      rescue => e
        puts "Agent completion callback error: #{e.message}" if ENV['DEV_MODE']
      end
    end
  end
  
  # === Cleanup ===
  
  def cleanup_old_agents(days_old = 7)
    return 0 unless enabled?
    
    @orchestrator.cleanup_completed_agents(days_old)
  end
  
  # === Statistics ===
  
  def get_stats
    return { success: false, error: "AgentWatcher not enabled" } unless enabled?
    
    active_agents = @orchestrator.list_active_agents
    
    stats = {
      total_active: active_agents.length,
      by_status: {},
      by_priority: {},
      oldest_agent: nil,
      newest_agent: nil
    }
    
    if active_agents.any?
      # Group by status
      active_agents.each do |agent|
        status = agent[:status]
        stats[:by_status][status] = (stats[:by_status][status] || 0) + 1
      end
      
      # Find oldest and newest
      sorted_by_time = active_agents.sort_by { |a| a[:created_at] }
      stats[:oldest_agent] = sorted_by_time.first
      stats[:newest_agent] = sorted_by_time.last
    end
    
    { success: true, stats: stats }
  end
  
  # === Batch Operations ===
  
  def batch_monitor
    """
    Monitor all agents and return summary
    """
    result = check_all_agents
    return result unless result[:success]
    
    # Get stats
    stats_result = get_stats
    stats = stats_result[:success] ? stats_result[:stats] : {}
    
    {
      success: true,
      summary: {
        checked: result[:checked],
        completed: result[:completed],
        active_total: stats[:total_active] || 0,
        by_status: stats[:by_status] || {}
      },
      completed_agents: result[:completed_agents]
    }
  end
  
  # === Notifications ===
  
  def format_completion_notification(completion_data)
    return "Agent completion data invalid" unless completion_data[:success]
    
    agent_id = completion_data[:agent_id]
    results = completion_data[:results]
    
    if results && results[:pull_requests]&.any?
      pr = results[:pull_requests].first
      pr_url = pr['html_url']
      
      "✅ **Agent #{agent_id} completed!**\n\n" +
      "🔗 [View PR](#{pr_url})\n" +
      "📅 Completed: #{completion_data[:completed_at]}"
    else
      "✅ **Agent #{agent_id} completed!**\n\n" +
      "📅 Completed: #{completion_data[:completed_at]}"
    end
  end
  
  def format_status_summary(summary_data)
    return "Status summary invalid" unless summary_data[:success]
    
    summary = summary_data[:summary]
    
    lines = ["🤖 **Agent Status Summary**\n"]
    lines << "📊 **Active Agents:** #{summary[:active_total]}"
    lines << "✅ **Completed:** #{summary[:completed]}"
    
    if summary[:by_status]&.any?
      lines << "\n📈 **By Status:**"
      summary[:by_status].each do |status, count|
        lines << "• #{status.capitalize}: #{count}"
      end
    end
    
    lines.join("\n")
  end
end

### ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
# SEAL :: AGENT.WATCHER :: ρ{Monitor} φ{Report} τ{Notify}
# ⧗ :: Watchful eye over agent completion :: ∎
### ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

