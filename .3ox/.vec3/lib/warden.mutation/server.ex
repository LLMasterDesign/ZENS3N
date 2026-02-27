# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xWN]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.177 // WARDEN :: Server ▞▞
# ▛▞// Vec3.Warden.Server :: ρ{request}.φ{validate}.τ{triad} ▹
# //▞⋮⋮ ⟦🛡️⟧ :: [warden] [grpc] [elixir] [mutation] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.warden.server.context〕
#
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.177
# /// Warden gRPC Server - single mutation authority, TRIAD emission
# ```
#
# ▛//▞ PRISM :: KERNEL
# P:: single.mutation.authority ∙ triad.emission ∙ grpc.interface
# R:: validate.proposals ∙ emit.triad{pulse ∙ state ∙ receipt} ∙ serve.grpc
# I:: intent.target={mutation.control ∙ chain.integrity ∙ remote.access}
# S:: receive → validate → execute → emit.triad → respond
# M:: protobuf.messages ∙ grpc.stream
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ receive{grpc.request ∙ proposal}
# ⇨ ≔ validate{schema ∙ authorization ∙ chain.state}
# ⟿ ≔ execute{mutation ∙ emit.triad}
# ▷ ≔ respond{grpc.response ∙ receipt}
# :: ∎

defmodule Vec3.Warden.Server do
  @moduledoc """
  Vec3.Warden.Server - gRPC server for the Warden.
  
  The single mutation authority for all 3ox writes.
  Implements the TRIAD invariant: every commit produces:
  1. PULSE - event in the pulse stream
  2. STATE - updated state file
  3. TAPE  - receipt in the tape log
  
  ## Usage
  
  Start as part of the supervision tree, then connect via gRPC client.
  """
  
  use GenServer
  require Logger
  
  alias Vec3.Pulse
  alias Vec3.TAPE
  alias Vec3.Hasher
  
  @version "1.0.0"
  
  # ─────────────────────────────────────────────────────────────
  # ▛▞// State Structure
  # ─────────────────────────────────────────────────────────────
  
  defstruct [
    :started_at,
    :proposals,      # %{proposal_id => proposal_map}
    :commits,        # count
    :port            # gRPC port
  ]
  
  # :: ∎

  # ─────────────────────────────────────────────────────────────
  # ▛▞// Client API
  # ─────────────────────────────────────────────────────────────
  
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @doc "Ping - health check"
  def ping(caller \\ "unknown") do
    GenServer.call(__MODULE__, {:ping, caller})
  end
  
  @doc "Propose a mutation"
  def propose(path, action, content, actor, metadata \\ %{}) do
    GenServer.call(__MODULE__, {:propose, %{
      path: path,
      action: action,
      content: content,
      actor: actor,
      metadata: metadata
    }})
  end
  
  @doc "Commit a proposal, emitting TRIAD"
  def commit(proposal_id, actor) do
    GenServer.call(__MODULE__, {:commit, proposal_id, actor})
  end
  
  @doc "Get server status"
  def status(include_stats \\ false) do
    GenServer.call(__MODULE__, {:status, include_stats})
  end
  
  @doc "Get pending proposals"
  def pending_proposals do
    GenServer.call(__MODULE__, :pending_proposals)
  end
  
  # :: ∎

  # ─────────────────────────────────────────────────────────────
  # ▛▞// Server Callbacks
  # ─────────────────────────────────────────────────────────────
  
  @impl true
  def init(opts) do
    port = Keyword.get(opts, :port, 50051)
    
    state = %__MODULE__{
      started_at: DateTime.utc_now(),
      proposals: %{},
      commits: 0,
      port: port
    }
    
    Logger.info("[WARDEN] Server initialized on port #{port}")
    
    {:ok, state}
  end
  
  @impl true
  def handle_call({:ping, caller}, _from, state) do
    pulse_stats = Pulse.stats()
    
    response = %{
      status: "ok",
      version: @version,
      chain_head: pulse_stats[:chain_head],
      merkle_root: pulse_stats[:merkle_root],
      ts: DateTime.utc_now() |> DateTime.to_unix(:millisecond),
      caller: caller
    }
    
    {:reply, {:ok, response}, state}
  end
  
  @impl true
  def handle_call({:propose, params}, _from, state) do
    proposal_id = generate_proposal_id()
    ts = DateTime.utc_now() |> DateTime.to_iso8601()
    
    # Validate proposal
    case validate_proposal(params) do
      :ok ->
        # Compute hash of proposed content
        content_str = if is_binary(params.content), do: params.content, else: to_string(params.content)
        hash = Hasher.dual_hash(content_str)
        
        proposal = %{
          proposal_id: proposal_id,
          path: params.path,
          action: params.action,
          content: params.content,
          actor: params.actor,
          metadata: params.metadata,
          hash: hash,
          status: :pending,
          created_at: ts
        }
        
        new_proposals = Map.put(state.proposals, proposal_id, proposal)
        new_state = %{state | proposals: new_proposals}
        
        response = %{
          proposal_id: proposal_id,
          status: "pending",
          hash: hash,
          ts: ts,
          message: "Proposal created successfully"
        }
        
        Logger.info("[WARDEN] Proposal created: #{proposal_id} for #{params.path}")
        
        {:reply, {:ok, response}, new_state}
      
      {:error, reason} ->
        response = %{
          proposal_id: nil,
          status: "rejected",
          hash: nil,
          ts: ts,
          message: reason
        }
        
        {:reply, {:error, response}, state}
    end
  end
  
  @impl true
  def handle_call({:commit, proposal_id, actor}, _from, state) do
    ts_start = DateTime.utc_now()
    
    case Map.get(state.proposals, proposal_id) do
      nil ->
        {:reply, {:error, %{status: "failed", message: "Proposal not found: #{proposal_id}"}}, state}
      
      proposal when proposal.status != :pending ->
        {:reply, {:error, %{status: "failed", message: "Proposal already processed: #{proposal.status}"}}, state}
      
      proposal ->
        # Execute the TRIAD emission
        case emit_triad(proposal, actor, ts_start) do
          {:ok, triad} ->
            # Mark proposal as committed
            updated_proposal = %{proposal | status: :committed}
            new_proposals = Map.put(state.proposals, proposal_id, updated_proposal)
            
            commit_id = generate_commit_id()
            ts_end = DateTime.utc_now() |> DateTime.to_iso8601()
            
            response = %{
              commit_id: commit_id,
              status: "committed",
              triad: triad,
              ts: ts_end,
              message: "Commit successful - TRIAD emitted"
            }
            
            new_state = %{state | 
              proposals: new_proposals,
              commits: state.commits + 1
            }
            
            Logger.info("[WARDEN] Commit: #{commit_id} for proposal #{proposal_id}")
            
            {:reply, {:ok, response}, new_state}
          
          {:error, reason} ->
            {:reply, {:error, %{status: "failed", message: "TRIAD emission failed: #{reason}"}}, state}
        end
    end
  end
  
  @impl true
  def handle_call({:status, include_stats}, _from, state) do
    pulse_stats = Pulse.stats()
    tape_stats = TAPE.stats()
    
    uptime = DateTime.diff(DateTime.utc_now(), state.started_at, :second)
    uptime_str = format_uptime(uptime)
    
    response = %{
      version: @version,
      chain_head: pulse_stats[:chain_head],
      merkle_root: pulse_stats[:merkle_root],
      pulse_count: pulse_stats[:total],
      tape_count: tape_stats[:total],
      pending_proposals: state.proposals |> Enum.count(fn {_, p} -> p.status == :pending end),
      commits: state.commits,
      uptime: uptime_str,
      ts: DateTime.utc_now() |> DateTime.to_iso8601()
    }
    
    response = if include_stats do
      Map.merge(response, %{
        pulse_actions: pulse_stats[:actions],
        tape_kinds: tape_stats[:kinds]
      })
    else
      response
    end
    
    {:reply, {:ok, response}, state}
  end
  
  @impl true
  def handle_call(:pending_proposals, _from, state) do
    pending = state.proposals
      |> Enum.filter(fn {_, p} -> p.status == :pending end)
      |> Enum.map(fn {id, p} -> %{id: id, path: p.path, action: p.action, created_at: p.created_at} end)
    
    {:reply, {:ok, pending}, state}
  end
  
  # :: ∎

  # ─────────────────────────────────────────────────────────────
  # ▛▞// Private Functions
  # ─────────────────────────────────────────────────────────────
  
  defp validate_proposal(%{path: path, action: action}) when is_binary(path) and is_binary(action) do
    cond do
      path == "" -> {:error, "Path cannot be empty"}
      action not in ["create", "update", "delete"] -> {:error, "Invalid action: #{action}"}
      true -> :ok
    end
  end
  defp validate_proposal(_), do: {:error, "Invalid proposal format"}
  
  defp emit_triad(proposal, actor, ts_start) do
    ts_end = DateTime.utc_now() |> DateTime.to_iso8601()
    ts_start_str = DateTime.to_iso8601(ts_start)
    
    # 1. PULSE - event
    pulse_event = Pulse.append_event(%{
      action: proposal.action,
      actor: actor,
      path: proposal.path,
      proposal_id: proposal.proposal_id
    })
    
    # 2. STATE - write the actual content (simulated for now)
    state_update = %{
      path: proposal.path,
      content: proposal.content,
      hash: proposal.hash,
      ts: ts_end
    }
    
    # 3. TAPE - receipt
    receipt = TAPE.receipt(%{
      kind: "mutation",
      op: proposal.action,
      path: proposal.path,
      actor: actor,
      proposal_id: proposal.proposal_id,
      ts_start: ts_start_str,
      ts_end: ts_end
    })
    
    triad = %{
      pulse: pulse_event,
      state: state_update,
      receipt: receipt
    }
    
    {:ok, triad}
  rescue
    e -> {:error, Exception.message(e)}
  end
  
  defp generate_proposal_id do
    ts = DateTime.utc_now()
    day = Date.day_of_year(Date.utc_today())
    year = rem(ts.year, 100)
    seq = :rand.uniform(0xFFFF) |> Integer.to_string(16) |> String.pad_leading(4, "0")
    "prop_#{year}.#{day}_#{seq}"
  end
  
  defp generate_commit_id do
    ts = DateTime.utc_now()
    day = Date.day_of_year(Date.utc_today())
    year = rem(ts.year, 100)
    seq = :rand.uniform(0xFFFF) |> Integer.to_string(16) |> String.pad_leading(4, "0")
    "cmit_#{year}.#{day}_#{seq}"
  end
  
  defp format_uptime(seconds) do
    days = div(seconds, 86400)
    hours = div(rem(seconds, 86400), 3600)
    mins = div(rem(seconds, 3600), 60)
    secs = rem(seconds, 60)
    
    cond do
      days > 0 -> "#{days}d #{hours}h #{mins}m"
      hours > 0 -> "#{hours}h #{mins}m #{secs}s"
      mins > 0 -> "#{mins}m #{secs}s"
      true -> "#{secs}s"
    end
  end
end

# :: ∎