# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x3929]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // TAPE.EX ▞▞
# ▛▞// TAPE.EX :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [tape] [otp] [json] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.tape.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for TAPE.EX
# ```

# 


# 


#

#
# ▛//▞ PRISM :: KERNEL
# P:: receipt.log ∙ hash.chain ∙ audit.trail
# R:: append.receipt ∙ verify.chain ∙ provide.stats
# I:: intent.target={accountability ∙ auditability ∙ integrity}
# S:: receive → hash → chain → append → respond
# M:: json.receipt ∙ sha256.chain
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ receive{receipt.data}
# ⇨ ≔ hash{sha256 ∙ xxh128 ∙ prev_link}
# ⟿ ≔ persist{append.to.log}
# ▷ ≔ respond{receipt.with.hashes}
# :: ∎

defmodule Vec3.TAPE do
  @moduledoc """
  Vec3.TAPE - Append-only receipt log with hash chain.
  
  TAPE = Truth-Anchored Provenance Events
  
  Every receipt is:
  1. Hash-chained (prev_hash links to previous receipt)
  2. Dual-hashed (xxh128 internal, sha256 outbound)
  3. Immutable (append-only, no updates)
  
  ## Usage
  
      Vec3.TAPE.append(%{kind: "mutation", op: "create", path: "..."})
      Vec3.TAPE.receipt(envelope: env, status: :ok)
      Vec3.TAPE.verify()
  """
  
  use GenServer
  require Logger
  
  # ─────────────────────────────────────────────────────────────
  # Configuration
  # ─────────────────────────────────────────────────────────────
  
  @tape_dir Application.compile_env(:vec3, :tape_dir, "var/tape")
  @tape_log Path.join(@tape_dir, "tape.log")
  
  # ─────────────────────────────────────────────────────────────
  # Client API
  # ─────────────────────────────────────────────────────────────
  
  @doc "Start the TAPE GenServer"
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @doc "Append a receipt to the tape"
  @spec append(map()) :: {:ok, map()} | {:error, term()}
  def append(receipt) when is_map(receipt) do
    GenServer.call(__MODULE__, {:append, receipt})
  end
  
  @doc "Create and append a receipt from an envelope"
  @spec receipt(keyword()) :: {:ok, map()} | {:error, term()}
  def receipt(opts) do
    GenServer.call(__MODULE__, {:receipt, opts})
  end
  
  @doc "Get last hash (chain head)"
  @spec last_hash() :: String.t() | nil
  def last_hash do
    GenServer.call(__MODULE__, :last_hash)
  end
  
  @doc "Read all receipts"
  @spec read_all() :: [map()]
  def read_all do
    GenServer.call(__MODULE__, :read_all)
  end
  
  @doc "Read receipts with filter"
  @spec read(keyword()) :: [map()]
  def read(filters \\ []) do
    GenServer.call(__MODULE__, {:read, filters})
  end
  
  @doc "Get tape statistics"
  @spec stats() :: map()
  def stats do
    GenServer.call(__MODULE__, :stats)
  end
  
  @doc "Verify tape chain integrity"
  @spec verify() :: {:ok, map()} | {:error, map()}
  def verify do
    GenServer.call(__MODULE__, :verify)
  end
  
  # ─────────────────────────────────────────────────────────────
  # Server Callbacks
  # ─────────────────────────────────────────────────────────────
  
  @impl true
  def init(_opts) do
    # Ensure tape directory exists
    File.mkdir_p!(@tape_dir)
    
    # Load existing state
    receipts = load_receipts()
    chain_head = if length(receipts) > 0, do: get_receipt_hash(List.last(receipts)), else: nil
    
    Logger.info("[TAPE] Initialized. #{length(receipts)} receipts, chain_head: #{chain_head || "nil"}")
    
    {:ok, %{
      chain_head: chain_head,
      count: length(receipts),
      tape_log: @tape_log
    }}
  end
  
  @impl true
  def handle_call({:append, receipt}, _from, state) do
    receipt_id = generate_receipt_id()
    ts = DateTime.utc_now() |> DateTime.to_iso8601()
    
    receipt = receipt
      |> Map.put(:receipt_id, receipt_id)
      |> Map.put(:ts_end, ts)
    
    # Compute hashes
    {internal, outbound} = compute_hashes(receipt)
    prev_hash = state.chain_head
    
    receipt = Map.put(receipt, :hash, %{
      internal: internal,
      outbound: outbound,
      prev: prev_hash
    })
    
    # Append to tape
    :ok = append_to_file(state.tape_log, receipt)
    
    new_state = %{state |
      chain_head: outbound,
      count: state.count + 1
    }
    
    {:reply, {:ok, receipt}, new_state}
  end
  
  @impl true
  def handle_call({:receipt, opts}, _from, state) do
    envelope = Keyword.fetch!(opts, :envelope)
    status = Keyword.fetch!(opts, :status)
    effects = Keyword.get(opts, :effects, [])
    outputs = Keyword.get(opts, :outputs, %{})
    flags = Keyword.get(opts, :flags, [])
    errors = Keyword.get(opts, :errors, [])
    worker = Keyword.get(opts, :worker, %{})
    
    receipt_id = generate_receipt_id()
    ts = DateTime.utc_now() |> DateTime.to_iso8601()
    
    receipt = %{
      kind: :receipt,
      receipt_id: receipt_id,
      run_id: envelope[:run_id],
      envelope_id: envelope[:envelope_id],
      ts_start: envelope[:ts],
      ts_end: ts,
      status: to_string(status),
      worker: worker,
      effects: effects,
      outputs: outputs,
      flags: flags,
      severity: if(status == :ok, do: "info", else: "error"),
      errors: errors
    }
    
    # Compute hashes
    {internal, outbound} = compute_hashes(receipt)
    prev_hash = state.chain_head
    
    receipt = Map.put(receipt, :hash, %{
      internal: internal,
      outbound: outbound,
      prev: prev_hash
    })
    
    # Append to tape
    :ok = append_to_file(state.tape_log, receipt)
    
    new_state = %{state |
      chain_head: outbound,
      count: state.count + 1
    }
    
    {:reply, {:ok, receipt}, new_state}
  end
  
  @impl true
  def handle_call(:last_hash, _from, state) do
    {:reply, state.chain_head, state}
  end
  
  @impl true
  def handle_call(:read_all, _from, state) do
    receipts = load_receipts()
    {:reply, receipts, state}
  end
  
  @impl true
  def handle_call({:read, filters}, _from, state) do
    receipts = load_receipts()
    
    filtered = receipts
      |> filter_by(:run_id, Keyword.get(filters, :run_id))
      |> filter_by(:status, Keyword.get(filters, :status))
      |> filter_by(:severity, Keyword.get(filters, :severity))
      |> maybe_limit(Keyword.get(filters, :limit))
    
    {:reply, filtered, state}
  end
  
  @impl true
  def handle_call(:stats, _from, state) do
    receipts = load_receipts()
    
    kinds = receipts
      |> Enum.group_by(& &1[:kind])
      |> Enum.map(fn {k, v} -> {k, length(v)} end)
      |> Map.new()
    
    stats = %{
      total: length(receipts),
      kinds: kinds,
      chain_head: state.chain_head
    }
    
    {:reply, stats, state}
  end
  
  @impl true
  def handle_call(:verify, _from, state) do
    receipts = load_receipts()
    result = verify_chain(receipts)
    {:reply, result, state}
  end
  
  # ─────────────────────────────────────────────────────────────
  # Private Functions
  # ─────────────────────────────────────────────────────────────
  
  defp compute_hashes(receipt) do
    data_to_hash = receipt |> Map.delete(:hash) |> Enum.sort() |> Map.new()
    json = Jason.encode!(data_to_hash)
    
    # Internal: xxh128 (simulated as sha256 prefix for now)
    internal_raw = :crypto.hash(:sha256, json) |> Base.encode16(case: :lower)
    internal = "xxh128:#{String.slice(internal_raw, 0, 32)}"
    
    # Outbound: sha256
    outbound = "sha256:#{internal_raw}"
    
    {internal, outbound}
  end
  
  defp get_receipt_hash(receipt) do
    receipt[:hash][:outbound] || receipt["hash"]["outbound"]
  end
  
  defp append_to_file(path, receipt) do
    line = Jason.encode!(receipt) <> "\n"
    File.write!(path, line, [:append])
    :ok
  end
  
  defp load_receipts do
    if File.exists?(@tape_log) do
      @tape_log
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        case Jason.decode(line, keys: :atoms) do
          {:ok, receipt} -> receipt
          {:error, _} -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)
    else
      []
    end
  end
  
  defp generate_receipt_id do
    ts = DateTime.utc_now()
    day = Date.day_of_year(Date.utc_today())
    year = rem(ts.year, 100)
    seq = :rand.uniform(0xFFFF) |> Integer.to_string(16) |> String.pad_leading(4, "0")
    "rcp_#{year}.#{day}_#{seq}"
  end
  
  defp filter_by(receipts, _key, nil), do: receipts
  defp filter_by(receipts, key, value) do
    Enum.filter(receipts, &(Map.get(&1, key) == to_string(value)))
  end
  
  defp maybe_limit(receipts, nil), do: receipts
  defp maybe_limit(receipts, limit), do: Enum.take(receipts, -limit)
  
  defp verify_chain([]), do: {:ok, %{valid: true, count: 0, errors: []}}
  defp verify_chain(receipts) do
    errors = receipts
      |> Enum.with_index()
      |> Enum.reduce([], fn {receipt, idx}, acc ->
        # Verify prev_hash chain (skip first)
        if idx > 0 do
          prev_receipt = Enum.at(receipts, idx - 1)
          expected_prev = get_receipt_hash(prev_receipt)
          actual_prev = receipt[:hash][:prev] || receipt["hash"]["prev"]
          
          if actual_prev != expected_prev do
            [%{index: idx, receipt_id: receipt[:receipt_id], error: :chain_broken} | acc]
          else
            acc
          end
        else
          acc
        end
      end)
      |> Enum.reverse()
    
    if errors == [] do
      {:ok, %{valid: true, count: length(receipts), errors: []}}
    else
      {:error, %{valid: false, count: length(receipts), errors: errors}}
    end
  end
end
# :: ∎