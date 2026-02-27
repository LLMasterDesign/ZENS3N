# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x8985]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // API.EX ▞▞
# ▛▞// API.EX :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [warden] [tape] [pulse] [json] [dispatch] [kernel] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.api.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for API.EX
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

defmodule Vec3.Core.API do
  @moduledoc """
  HTTP API for Ruby daemons to interact with Vec3 services.
  
  Endpoints:
  - POST /tape/append  - Log a receipt
  - POST /pulse/emit   - Emit an event
  - POST /gate/commit  - Commit a mutation
  - GET  /health       - Health check
  """
  
  use Plug.Router
  require Logger

  plug Plug.Parsers,
    parsers: [:json],
    json_decoder: Jason

  plug :match
  plug :dispatch

  # ═══════════════════════════════════════════════════════════════════════════════
  # HEALTH
  # ═══════════════════════════════════════════════════════════════════════════════

  get "/health" do
    response = %{
      status: "ok",
      services: %{
        tape: Process.alive?(Process.whereis(Vec3.Core.Tape)),
        pulse: Process.alive?(Process.whereis(Vec3.Core.Pulse)),
        warden: Process.alive?(Process.whereis(Vec3.Core.Warden))
      },
      ts: DateTime.utc_now() |> DateTime.to_iso8601()
    }
    
    send_json(conn, 200, response)
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # TAPE
  # ═══════════════════════════════════════════════════════════════════════════════

  post "/tape/append" do
    case Vec3.Core.Tape.append(conn.body_params) do
      {:ok, receipt} ->
        send_json(conn, 200, %{ok: true, receipt: receipt})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  get "/tape/tail" do
    n = conn.query_params["n"] || "10"
    receipts = Vec3.Core.Tape.tail(String.to_integer(n))
    send_json(conn, 200, %{ok: true, receipts: receipts})
  end

  get "/tape/head" do
    hash = Vec3.Core.Tape.head_hash()
    send_json(conn, 200, %{ok: true, head_hash: hash})
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # PULSE
  # ═══════════════════════════════════════════════════════════════════════════════

  post "/pulse/emit" do
    event_type = conn.body_params["type"] |> String.to_atom()
    payload = conn.body_params["payload"] || %{}
    
    Vec3.Core.Pulse.emit(event_type, payload)
    send_json(conn, 200, %{ok: true})
  end

  get "/pulse/recent" do
    n = conn.query_params["n"] || "20"
    events = Vec3.Core.Pulse.recent(String.to_integer(n))
    send_json(conn, 200, %{ok: true, events: events})
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # WARDEN
  # ═══════════════════════════════════════════════════════════════════════════════

  post "/gate/commit" do
    mutation = atomize_keys(conn.body_params)
    
    case Vec3.Core.Warden.commit(mutation) do
      {:ok, receipt} ->
        send_json(conn, 200, %{ok: true, receipt: receipt})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  get "/gate/stats" do
    stats = Vec3.Core.Warden.stats()
    send_json(conn, 200, %{ok: true, stats: stats})
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # AGENTS REGISTRY
  # ═══════════════════════════════════════════════════════════════════════════════

  get "/agents/list" do
    registry_file = Path.join([
      System.get_env("VEC3_ROOT") || File.cwd!(),
      "var", "state", "registry.runtime.json"
    ])
    
    case File.read(registry_file) do
      {:ok, content} ->
        data = Jason.decode!(content)
        send_json(conn, 200, %{status: "ok", agents: data["agents"], bases: data["bases"], stations: data["stations"]})
      {:error, _} ->
        send_json(conn, 200, %{status: "ok", agents: %{}, bases: %{}, stations: %{}})
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # TASKS
  # ═══════════════════════════════════════════════════════════════════════════════

  post "/tasks/create" do
    type = conn.body_params["type"] |> String.to_atom()
    description = conn.body_params["description"]
    opts = [
      requester: conn.body_params["requester"] || "api",
      priority: (conn.body_params["priority"] || "medium") |> String.to_atom(),
      chat_id: conn.body_params["chat_id"],
      thread_id: conn.body_params["thread_id"]
    ]
    
    case Vec3.Services.Tasks.create(type, description, opts) do
      {:ok, task} ->
        send_json(conn, 200, %{ok: true, task: task})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  get "/tasks/list" do
    status = case conn.query_params["status"] do
      nil -> :all
      s -> String.to_atom(s)
    end
    
    tasks = Vec3.Services.Tasks.list(status)
    send_json(conn, 200, %{ok: true, tasks: tasks})
  end

  get "/tasks/:id" do
    case Vec3.Services.Tasks.get(id) do
      nil ->
        send_json(conn, 404, %{ok: false, error: "not_found"})
      task ->
        send_json(conn, 200, %{ok: true, task: task})
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # SKILLS
  # ═══════════════════════════════════════════════════════════════════════════════

  get "/skills/:agent" do
    skills = Vec3.Services.Tasks.Skills.for_agent(agent)
    send_json(conn, 200, %{ok: true, agent: agent, skills: skills})
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # ATLAS
  # ═══════════════════════════════════════════════════════════════════════════════

  get "/atlas/structure" do
    structure = Vec3.Services.Atlas.structure()
    send_json(conn, 200, %{ok: true, structure: structure})
  end

  get "/atlas/where/:query" do
    case Vec3.Services.Atlas.where_is(query) do
      {:ok, matches} ->
        send_json(conn, 200, %{ok: true, matches: matches})
      {:not_found, msg} ->
        send_json(conn, 404, %{ok: false, error: msg})
    end
  end

  get "/atlas/what/:query" do
    case Vec3.Services.Atlas.what_is(query) do
      {:ok, info} ->
        send_json(conn, 200, %{ok: true, info: info})
      {:not_found, msg} ->
        send_json(conn, 404, %{ok: false, error: msg})
    end
  end

  get "/atlas/recipes" do
    recipes = Vec3.Services.Atlas.recipes()
    send_json(conn, 200, %{ok: true, recipes: recipes})
  end

  post "/atlas/repair" do
    error = conn.body_params["error"]
    case Vec3.Services.Atlas.find_repair(error) do
      {:ok, recipe} ->
        send_json(conn, 200, %{ok: true, recipe: recipe})
      {:no_recipe, msg} ->
        send_json(conn, 404, %{ok: false, error: msg})
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # SCANNER
  # ═══════════════════════════════════════════════════════════════════════════════

  get "/scanner/status" do
    status = Vec3.Services.Scanner.status()
    send_json(conn, 200, %{ok: true, status: status})
  end

  post "/scanner/scan" do
    path = conn.body_params["path"]
    case Vec3.Services.Scanner.scan(path) do
      {:ok, results} ->
        send_json(conn, 200, %{ok: true, results: results})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  get "/scanner/duplicates" do
    path = conn.query_params["path"]
    case Vec3.Services.Scanner.find_duplicates(path) do
      {:ok, result} ->
        send_json(conn, 200, %{ok: true, result: result})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  get "/scanner/similar" do
    pattern = conn.query_params["pattern"]
    case Vec3.Services.Scanner.find_similar(pattern) do
      {:ok, matches} ->
        send_json(conn, 200, %{ok: true, matches: matches})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  get "/scanner/hash" do
    path = conn.query_params["path"]
    case Vec3.Services.Scanner.hash(path) do
      {:ok, hash} ->
        send_json(conn, 200, %{ok: true, path: path, hash: hash})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  post "/scanner/compare" do
    path1 = conn.body_params["path1"]
    path2 = conn.body_params["path2"]
    case Vec3.Services.Scanner.compare(path1, path2) do
      {:ok, result} ->
        send_json(conn, 200, %{ok: true, result: result})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # CURSOR BRIDGE
  # ═══════════════════════════════════════════════════════════════════════════════

  get "/cursor/status" do
    status = Vec3.Services.CursorBridge.status()
    send_json(conn, 200, %{ok: true, status: status})
  end

  post "/cursor/queue" do
    command = conn.body_params["command"]
    opts = [
      type: String.to_atom(conn.body_params["type"] || "prompt"),
      requester: conn.body_params["requester"] || "api",
      chat_id: conn.body_params["chat_id"],
      thread_id: conn.body_params["thread_id"]
    ]
    
    case Vec3.Services.CursorBridge.queue_command(command, opts) do
      {:ok, cmd} ->
        send_json(conn, 200, %{ok: true, command: cmd})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  get "/cursor/pending" do
    pending = Vec3.Services.CursorBridge.pending()
    send_json(conn, 200, %{ok: true, pending: pending})
  end

  get "/cursor/results" do
    results = Vec3.Services.CursorBridge.results()
    send_json(conn, 200, %{ok: true, results: results})
  end

  post "/cursor/complete" do
    command_id = conn.body_params["command_id"]
    result = conn.body_params["result"]
    
    case Vec3.Services.CursorBridge.complete(command_id, result) do
      {:ok, cmd} ->
        send_json(conn, 200, %{ok: true, command: cmd})
      {:error, reason} ->
        send_json(conn, 400, %{ok: false, error: reason})
    end
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # FALLBACK
  # ═══════════════════════════════════════════════════════════════════════════════

  match _ do
    send_json(conn, 404, %{error: "not_found"})
  end

  # ═══════════════════════════════════════════════════════════════════════════════
  # HELPERS
  # ═══════════════════════════════════════════════════════════════════════════════

  defp send_json(conn, status, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(data))
  end

  defp atomize_keys(map) when is_map(map) do
    map
    |> Enum.map(fn 
      {k, v} when is_binary(k) -> {String.to_atom(k), atomize_keys(v)}
      {k, v} -> {k, atomize_keys(v)}
    end)
    |> Map.new()
  end
  defp atomize_keys(value), do: value
end
# :: ∎