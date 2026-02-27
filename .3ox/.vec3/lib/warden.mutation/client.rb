#!/usr/bin/env ruby
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xWN]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.177 // WARDEN :: Client ▞▞
# ▛▞// Vec3::Warden::Client :: ρ{request}.φ{send}.τ{receive} ▹
# //▞⋮⋮ ⟦🛡️⟧ :: [warden] [client] [ruby] [grpc] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.warden.client.context〕
#
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.177
# /// Ruby client for Warden gRPC server, local fallback included
# ```
#
# ▛//▞ PRISM :: KERNEL
# P:: warden.client ∙ mutation.request ∙ triad.receive
# R:: connect.grpc ∙ propose ∙ commit ∙ local.fallback
# I:: intent.target={remote.mutation ∙ triad.integrity}
# S:: connect → request → await → receive
# M:: protobuf.messages ∙ json.fallback
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ prepare{request ∙ params}
# ⇨ ≔ connect{grpc.server ∙ fallback.local}
# ⟿ ≔ call{method ∙ await.response}
# ▷ ≔ receive{response ∙ triad}
# :: ∎

require 'json'
require 'time'

# Load local components for fallback mode
require_relative '../pulse/pulse'
require_relative '../tape/tape'

# Alias for consistency
Vec3::TAPE = Vec3::Tape unless defined?(Vec3::TAPE)
require_relative '../hasher/hasher'

module Vec3
  module Warden
    class Client
      VERSION = '1.0.0'
      DEFAULT_HOST = 'localhost'
      DEFAULT_PORT = 50051
      
      attr_reader :host, :port, :mode
      
      def initialize(host: DEFAULT_HOST, port: DEFAULT_PORT)
        @host = host
        @port = port
        @mode = detect_mode
        @proposals = {}
        @commits = 0
        @started_at = Time.now
      end
      
      # ─────────────────────────────────────────────────────────────
      # ▛▞// API Methods
      # ─────────────────────────────────────────────────────────────
      
      def ping(caller = 'ruby-client')
        case @mode
        when :grpc
          grpc_ping(caller)
        else
          local_ping(caller)
        end
      end
      
      def propose(path:, action:, content:, actor:, metadata: {})
        case @mode
        when :grpc
          grpc_propose(path, action, content, actor, metadata)
        else
          local_propose(path, action, content, actor, metadata)
        end
      end
      
      def commit(proposal_id:, actor:)
        case @mode
        when :grpc
          grpc_commit(proposal_id, actor)
        else
          local_commit(proposal_id, actor)
        end
      end
      
      def status(include_stats: false)
        case @mode
        when :grpc
          grpc_status(include_stats)
        else
          local_status(include_stats)
        end
      end
      
      def pending_proposals
        @proposals.select { |_, p| p[:status] == :pending }.map do |id, p|
          { id: id, path: p[:path], action: p[:action], created_at: p[:created_at] }
        end
      end
      
      private
      
      # ─────────────────────────────────────────────────────────────
      # ▛▞// Mode Detection
      # ─────────────────────────────────────────────────────────────
      
      def detect_mode
        # Check if gRPC gems are available
        begin
          require 'grpc'
          # TODO: Check if server is actually running
          :grpc
        rescue LoadError
          :local
        end
      rescue
        :local
      end
      
      # ─────────────────────────────────────────────────────────────
      # ▛▞//Local Fallback Implementation
      # ─────────────────────────────────────────────────────────────
      
      def local_ping(caller)
        pulse_stats = Vec3::Pulse.stats
        
        {
          status: 'ok',
          version: VERSION,
          mode: 'local',
          chain_head: pulse_stats[:chain_head],
          merkle_root: pulse_stats[:merkle_root],
          ts: Time.now.to_i * 1000,
          caller: caller
        }
      end
      
      def local_propose(path, action, content, actor, metadata)
        proposal_id = generate_proposal_id
        ts = Time.now.utc.iso8601(3)
        
        # Validate
        unless %w[create update delete].include?(action.to_s)
          return { error: "Invalid action: #{action}" }
        end
        
        if path.nil? || path.empty?
          return { error: 'Path cannot be empty' }
        end
        
        # Compute hash
        content_str = content.is_a?(String) ? content : content.to_s
        hash = Vec3::Hasher.dual_hash(content_str)
        
        proposal = {
          proposal_id: proposal_id,
          path: path,
          action: action,
          content: content,
          actor: actor,
          metadata: metadata,
          hash: hash,
          status: :pending,
          created_at: ts
        }
        
        @proposals[proposal_id] = proposal
        
        {
          proposal_id: proposal_id,
          status: 'pending',
          hash: hash,
          ts: ts,
          message: 'Proposal created successfully (local)'
        }
      end
      
      def local_commit(proposal_id, actor)
        ts_start = Time.now
        
        proposal = @proposals[proposal_id]
        
        unless proposal
          return { error: "Proposal not found: #{proposal_id}" }
        end
        
        unless proposal[:status] == :pending
          return { error: "Proposal already processed: #{proposal[:status]}" }
        end
        
        # Emit TRIAD
        triad = emit_triad(proposal, actor, ts_start)
        
        # Update proposal status
        @proposals[proposal_id][:status] = :committed
        @commits += 1
        
        commit_id = generate_commit_id
        ts_end = Time.now.utc.iso8601(3)
        
        {
          commit_id: commit_id,
          status: 'committed',
          triad: triad,
          ts: ts_end,
          message: 'Commit successful - TRIAD emitted (local)'
        }
      end
      
      def local_status(include_stats)
        pulse_stats = Vec3::Pulse.stats
        tape_stats = Vec3::TAPE.stats
        
        uptime = Time.now - @started_at
        
        status = {
          version: VERSION,
          mode: 'local',
          chain_head: pulse_stats[:chain_head],
          merkle_root: pulse_stats[:merkle_root],
          pulse_count: pulse_stats[:total],
          tape_count: tape_stats[:total],
          pending_proposals: @proposals.count { |_, p| p[:status] == :pending },
          commits: @commits,
          uptime: format_uptime(uptime.to_i),
          ts: Time.now.utc.iso8601(3)
        }
        
        if include_stats
          status[:pulse_actions] = pulse_stats[:actions]
          status[:tape_kinds] = tape_stats[:kinds]
        end
        
        status
      end
      
      def emit_triad(proposal, actor, ts_start)
        ts_end = Time.now.utc.iso8601(3)
        ts_start_str = ts_start.utc.iso8601(3)
        
        # 1. PULSE - event
        pulse_event = Vec3::Pulse.append_event({
          action: proposal[:action],
          actor: actor,
          path: proposal[:path],
          proposal_id: proposal[:proposal_id]
        })
        
        # 2. STATE - write the actual content (simulated)
        state_update = {
          path: proposal[:path],
          content: proposal[:content],
          hash: proposal[:hash],
          ts: ts_end
        }
        
        # 3. TAPE - receipt
        envelope = {
          run_id: proposal[:proposal_id],
          envelope_id: "env_#{proposal[:proposal_id]}",
          ts: ts_start_str,
          path: proposal[:path],
          action: proposal[:action],
          actor: actor
        }
        
        receipt = Vec3::TAPE.receipt(
          envelope: envelope,
          status: :ok,
          effects: [{ type: proposal[:action], path: proposal[:path] }],
          outputs: { proposal_id: proposal[:proposal_id] }
        )
        
        {
          pulse: pulse_event,
          state: state_update,
          receipt: receipt
        }
      end
      
      # ─────────────────────────────────────────────────────────────
      # ▛▞// gRPC Implementation (stubs for now)
      # ─────────────────────────────────────────────────────────────
      
      def grpc_ping(caller)
        # TODO: Implement gRPC call
        local_ping(caller)
      end
      
      def grpc_propose(path, action, content, actor, metadata)
        # TODO: Implement gRPC call
        local_propose(path, action, content, actor, metadata)
      end
      
      def grpc_commit(proposal_id, actor)
        # TODO: Implement gRPC call
        local_commit(proposal_id, actor)
      end
      
      def grpc_status(include_stats)
        # TODO: Implement gRPC call
        local_status(include_stats)
      end
      
      # :: ∎
      
      # ─────────────────────────────────────────────────────────────
      # ▛▞// Utilities
      # ─────────────────────────────────────────────────────────────
      
      def generate_proposal_id
        ts = Time.now
        day = ts.yday.to_s.rjust(3, '0')
        year = (ts.year % 100).to_s.rjust(2, '0')
        seq = rand(0xFFFF).to_s(16).rjust(4, '0')
        "prop_#{year}.#{day}_#{seq}"
      end
      
      def generate_commit_id
        ts = Time.now
        day = ts.yday.to_s.rjust(3, '0')
        year = (ts.year % 100).to_s.rjust(2, '0')
        seq = rand(0xFFFF).to_s(16).rjust(4, '0')
        "cmit_#{year}.#{day}_#{seq}"
      end
      
      def format_uptime(seconds)
        days = seconds / 86400
        hours = (seconds % 86400) / 3600
        mins = (seconds % 3600) / 60
        secs = seconds % 60
        
        if days > 0
          "#{days}d #{hours}h #{mins}m"
        elsif hours > 0
          "#{hours}h #{mins}m #{secs}s"
        elsif mins > 0
          "#{mins}m #{secs}s"
        else
          "#{secs}s"
        end
      end
    end
    
    # Module-level convenience methods
    class << self
      def client
        @client ||= Client.new
      end
      
      def ping(caller = 'ruby')
        client.ping(caller)
      end
      
      def propose(**kwargs)
        client.propose(**kwargs)
      end
      
      def commit(**kwargs)
        client.commit(**kwargs)
      end
      
      def status(include_stats: false)
        client.status(include_stats: include_stats)
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  client = Vec3::Warden::Client.new
  
  case ARGV[0]
  when 'ping'
    puts JSON.pretty_generate(client.ping(ARGV[1] || 'cli'))
  when 'status'
    puts JSON.pretty_generate(client.status(include_stats: ARGV[1] == '--stats'))
  when 'propose'
    unless ARGV[1] && ARGV[2]
      puts "Usage: ruby client.rb propose <path> <action> [content] [actor]"
      exit 1
    end
    result = client.propose(
      path: ARGV[1],
      action: ARGV[2],
      content: ARGV[3] || '',
      actor: ARGV[4] || 'cli'
    )
    puts JSON.pretty_generate(result)
  when 'commit'
    unless ARGV[1]
      puts "Usage: ruby client.rb commit <proposal_id> [actor]"
      exit 1
    end
    result = client.commit(proposal_id: ARGV[1], actor: ARGV[2] || 'cli')
    puts JSON.pretty_generate(result)
  when 'propose-commit'
    # Convenience: propose and commit in one step
    unless ARGV[1] && ARGV[2]
      puts "Usage: ruby client.rb propose-commit <path> <action> [content] [actor]"
      exit 1
    end
    actor = ARGV[4] || 'cli'
    prop_result = client.propose(
      path: ARGV[1],
      action: ARGV[2],
      content: ARGV[3] || '',
      actor: actor
    )
    
    if prop_result[:error]
      puts JSON.pretty_generate(prop_result)
      exit 1
    end
    
    commit_result = client.commit(proposal_id: prop_result[:proposal_id], actor: actor)
    puts JSON.pretty_generate({
      proposal: prop_result,
      commit: commit_result
    })
  else
    puts "Usage: ruby client.rb <ping|status|propose|commit|propose-commit> [args]"
    puts ""
    puts "Commands:"
    puts "  ping [caller]                              - Health check"
    puts "  status [--stats]                           - Get server status"
    puts "  propose <path> <action> [content] [actor]  - Create mutation proposal"
    puts "  commit <proposal_id> [actor]               - Commit proposal (emit TRIAD)"
    puts "  propose-commit <path> <action> [content]   - Propose and commit in one step"
  end
end
