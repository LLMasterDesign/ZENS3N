# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x8731]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // PULSE.EX ▞▞
# ▛▞// PULSE.EX :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [merkle] [pulse] [otp] [json] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.pulse.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for PULSE.EX
# ```

# 


# 


#

#
# ▛//▞ PRISM :: KERNEL
# P:: event.stream ∙ merkle.proof ∙ integrity.anchor
# R:: event.append ∙ merkle.update ∙ chain.verify
# I:: intent.target={change.proof ∙ deterministic.replay ∙ audit.trail}
# S:: receive → hash → chain → merkle → append
# M:: json.event ∙ merkle.root.file
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ receive{event.map ∙ action ∙ actor}
# ⇨ ≔ hash{prev_hash.link ∙ chain_head}
# ⟿ ≔ merkle{compute.tree ∙ update.root}
# ▷ ≔ append{pulse.log ∙ merkle.file}
# :: ∎

defmodule Vec3.Pulse do
  @moduledoc """
  Vec3.Pulse - Append-only event stream with merkle root.
  
  PULSE = Proof of Unified Logical State Events
  
  Every event is:
  1. Hash-chained (prev_hash links to previous event)
  2. Merkle-anchored (root updated on every append)
  3. Immutable (append-only, no updates)
  
  ## Usage
  
      Vec3.Pulse.append_event(%{action: "commit", actor: "cli", path: "..."})
      Vec3.Pulse.get_merkle_root()
      Vec3.Pulse.verify()
  """
  
  use GenServer
  require Logger
  
  # ─────────────────────────────────────────────────────────────
  # Configuration
  # ─────────────────────────────────────────────────────────────
  
  @pulse_dir Application.compile_env(:vec3, :pulse_dir, "vec3/var/pulse")
  @pulse_log Path.join(@pulse_dir, "pulse.jsonl")
  @merkle_file Path.join(@pulse_dir, "merkle.root")
  
  # ─────────────────────────────────────────────────────────────
  # Client API
  # ─────────────────────────────────────────────────────────────
  
  @doc "Start the PULSE GenServer"
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @doc "Append an event to the pulse stream"
  @spec append_event(map()) :: {:ok, map()} | {:error, term()}
  def append_event(event) when is_map(event) do
    GenServer.call(__MODULE__, {:append, event})
  end
  
  @doc "Get current merkle root"
  @spec get_merkle_root() :: map()
  def get_merkle_root do
    GenServer.call(__MODULE__, :get_merkle_root)
  end
  
  @doc "Get chain head (last event hash)"
  @spec get_chain_head() :: String.t() | nil
  def get_chain_head do
    GenServer.call(__MODULE__, :get_chain_head)
  end
  
  @doc "Read all events"
  @spec read_all() :: [map()]
  def read_all do
    GenServer.call(__MODULE__, :read_all)
  end
  
  @doc "Read events with filter"
  @spec read(keyword()) :: [map()]
  def read(filters \\ []) do
    GenServer.call(__MODULE__, {:read, filters})
  end
  
  @doc "Get pulse statistics"
  @spec stats() :: map()
  def stats do
    GenServer.call(__MODULE__, :stats)
  end
  
  @doc "Verify pulse chain integrity"
  @spec verify() :: {:ok, map()} | {:error, map()}
  def verify do
    GenServer.call(__MODULE__, :verify)
  end
  
  # ─────────────────────────────────────────────────────────────
  # Server Callbacks
  # ─────────────────────────────────────────────────────────────
  
  @impl true
  def init(_opts) do
    # Ensure pulse directory exists
    File.mkdir_p!(@pulse_dir)
    
    # Load existing state
    events = load_events()
    chain_head = if length(events) > 0, do: List.last(events)[:event_hash], else: nil
    merkle = load_merkle_root()
    first_event_id = if length(events) > 0, do: List.first(events)[:event_id], else: nil
    
    Logger.info("[PULSE] Initialized. #{length(events)} events, chain_head: #{chain_head || "nil"}")
    
    {:ok, %{
      chain_head: chain_head,
      merkle_root: merkle[:root],
      first_event_id: first_event_id,
      last_event_id: if(length(events) > 0, do: List.last(events)[:event_id], else: nil),
      count: length(events),
      pulse_log: @pulse_log,
      merkle_file: @merkle_file
    }}
  end
  
  @impl true
  def handle_call({:append, event}, _from, state) do
    event_id = generate_event_id()
    ts = DateTime.utc_now() |> DateTime.to_iso8601()
    
    event = event
      |> Map.put(:event_id, event_id)
      |> Map.put(:ts, ts)
      |> Map.put(:prev_hash, state.chain_head)
    
    # Compute event hash
    canonical = Jason.encode!(event |> Enum.sort() |> Map.new())
    event_hash = hash_sha256(canonical)
    
    event = Map.put(event, :event_hash, event_hash)
    
    # Append to pulse log
    :ok = append_to_file(state.pulse_log, event)
    
    # Update merkle root
    new_merkle = compute_and_save_merkle(state, event_id, event_hash)
    
    new_state = %{state |
      chain_head: event_hash,
      merkle_root: new_merkle[:root],
      last_event_id: event_id,
      first_event_id: state.first_event_id || event_id,
      count: state.count + 1
    }
    
    {:reply, {:ok, event}, new_state}
  end
  
  @impl true
  def handle_call(:get_merkle_root, _from, state) do
    merkle = load_merkle_root()
    {:reply, merkle, state}
  end
  
  @impl true
  def handle_call(:get_chain_head, _from, state) do
    {:reply, state.chain_head, state}
  end
  
  @impl true
  def handle_call(:read_all, _from, state) do
    events = load_events()
    {:reply, events, state}
  end
  
  @impl true
  def handle_call({:read, filters}, _from, state) do
    events = load_events()
    
    filtered = events
      |> filter_by(:action, Keyword.get(filters, :action))
      |> filter_by(:actor, Keyword.get(filters, :actor))
      |> filter_by(:path, Keyword.get(filters, :path))
      |> maybe_limit(Keyword.get(filters, :limit))
    
    {:reply, filtered, state}
  end
  
  @impl true
  def handle_call(:stats, _from, state) do
    events = load_events()
    
    actions = events
      |> Enum.group_by(& &1[:action])
      |> Enum.map(fn {k, v} -> {k, length(v)} end)
      |> Map.new()
    
    stats = %{
      total: length(events),
      actions: actions,
      first_event_id: state.first_event_id,
      last_event_id: state.last_event_id,
      chain_head: state.chain_head,
      merkle_root: state.merkle_root
    }
    
    {:reply, stats, state}
  end
  
  @impl true
  def handle_call(:verify, _from, state) do
    events = load_events()
    result = verify_chain(events)
    {:reply, result, state}
  end
  
  # ─────────────────────────────────────────────────────────────
  # Private Functions
  # ─────────────────────────────────────────────────────────────
  
  defp hash_sha256(data) do
    hash = :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
    "sha256:#{hash}"
  end
  
  defp append_to_file(path, event) do
    line = Jason.encode!(event) <> "\n"
    File.write!(path, line, [:append])
    :ok
  end
  
  defp load_events do
    if File.exists?(@pulse_log) do
      @pulse_log
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        case Jason.decode(line, keys: :atoms) do
          {:ok, event} -> event
          {:error, _} -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)
    else
      []
    end
  end
  
  defp load_merkle_root do
    if File.exists?(@merkle_file) do
      case File.read(@merkle_file) do
        {:ok, content} ->
          case Jason.decode(content, keys: :atoms) do
            {:ok, merkle} -> merkle
            _ -> %{root: nil}
          end
        _ -> %{root: nil}
      end
    else
      %{root: nil}
    end
  end
  
  defp compute_and_save_merkle(state, event_id, event_hash) do
    # Get all event hashes
    events = load_events()
    hashes = Enum.map(events, & &1[:event_hash]) ++ [event_hash]
    
    # Compute merkle root
    root = compute_merkle_tree(hashes)
    
    merkle = %{
      root: root,
      algorithm: "sha256",
      scope: "pulse",
      event_range: %{
        from: state.first_event_id || event_id,
        to: event_id
      },
      chain_head: event_hash,
      count: length(hashes),
      ts: DateTime.utc_now() |> DateTime.to_iso8601()
    }
    
    File.write!(@merkle_file, Jason.encode!(merkle, pretty: true))
    
    merkle
  end
  
  defp compute_merkle_tree([]), do: hash_sha256("")
  defp compute_merkle_tree([single]), do: single
  defp compute_merkle_tree(hashes) do
    layer = hashes
    
    compute_layer(layer)
  end
  
  defp compute_layer([single]), do: single
  defp compute_layer(layer) do
    next_layer = layer
      |> Enum.chunk_every(2)
      |> Enum.map(fn
        [a, b] -> hash_sha256(a <> b)
        [a] -> hash_sha256(a <> a)  # Duplicate odd node
      end)
    
    compute_layer(next_layer)
  end
  
  defp generate_event_id do
    ts = DateTime.utc_now()
    day = Date.day_of_year(Date.utc_today())
    year = rem(ts.year, 100)
    hour = ts.hour |> Integer.to_string() |> String.pad_leading(2, "0")
    min = ts.minute |> Integer.to_string() |> String.pad_leading(2, "0")
    sec = ts.second |> Integer.to_string() |> String.pad_leading(2, "0")
    seq = :rand.uniform(0xFFFF) |> Integer.to_string(16) |> String.pad_leading(4, "0")
    "evt_#{year}.#{day}.#{hour}#{min}#{sec}_#{seq}"
  end
  
  defp filter_by(events, _key, nil), do: events
  defp filter_by(events, key, value) do
    Enum.filter(events, &(Map.get(&1, key) == to_string(value)))
  end
  
  defp maybe_limit(events, nil), do: events
  defp maybe_limit(events, limit), do: Enum.take(events, -limit)
  
  defp verify_chain([]), do: {:ok, %{valid: true, count: 0, errors: []}}
  defp verify_chain(events) do
    errors = events
      |> Enum.with_index()
      |> Enum.reduce([], fn {event, idx}, acc ->
        # Verify prev_hash chain (skip first)
        if idx > 0 do
          prev_event = Enum.at(events, idx - 1)
          if event[:prev_hash] != prev_event[:event_hash] do
            [%{index: idx, event_id: event[:event_id], error: :chain_broken} | acc]
          else
            acc
          end
        else
          acc
        end
      end)
      |> Enum.reverse()
    
    if errors == [] do
      {:ok, %{valid: true, count: length(events), errors: []}}
    else
      {:error, %{valid: false, count: length(events), errors: errors}}
    end
  end
end
# :: ∎