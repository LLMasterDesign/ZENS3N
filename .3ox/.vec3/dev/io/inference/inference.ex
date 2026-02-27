# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x443D]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // INFERENCE.EX ▞▞
# ▛▞// INFERENCE.EX :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [otp] [json] [token] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.inference.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for INFERENCE.EX
# ```

# 


# 


#

#
# ▛//▞ PRISM :: KERNEL
# P:: llm.inference ∙ heartbeat.stream ∙ async.processing
# R:: call.openai ∙ call.cursor ∙ emit.progress ∙ queue.requests
# I:: intent.target={thinking.indicator ∙ response.generation}
# S:: receive → heartbeat.start → infer → stream → complete
# M:: json.response ∙ heartbeat.bar
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ receive{prompt ∙ model ∙ options}
# ⇨ ≔ heartbeat{emit.progress.bar}
# ⟿ ≔ infer{api.call ∙ stream.tokens}
# ▷ ≔ complete{response ∙ stop.heartbeat}
# :: ∎

defmodule Vec3.Inference do
  @moduledoc """
  Vec3.Inference - Elixir GenServer for LLM inference with heartbeat streaming.
  
  Provides async inference calls to OpenAI/Cursor APIs with progress indicators.
  
  ## Heartbeat Format
  
      ...thinking{context}  ▛▞//▮▯▯▯▯▯▯▹
      ...thinking{arc}      ▛▞//▮▮▯▯▯▯▯▹
      ...inference{model}   ▛▞//▮▮▮▯▯▯▯▹
      ...compiling{tokens}  ▛▞//▮▮▮▮▯▯▯▹
      ...complete           ▛▞//▮▮▮▮▮▮▮▹
  
  ## Usage
  
      {:ok, response} = Vec3.Inference.think("What is 2+2?", model: :openai)
      Vec3.Inference.think_async("Complex question", callback: pid)
  """
  
  use GenServer
  require Logger
  
  @keys_dir Application.compile_env(:vec3, :keys_dir, ".3ox/keys")
  
  # Heartbeat bar characters
  @bar_filled "▮"
  @bar_empty "▯"
  @bar_cap "▹"
  @bar_prefix "▛▞//"
  
  # ─────────────────────────────────────────────────────────────
  # Client API
  # ─────────────────────────────────────────────────────────────
  
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @doc """
  Synchronous inference call with heartbeat.
  Returns {:ok, response} or {:error, reason}
  """
  @spec think(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def think(prompt, opts \\ []) do
    GenServer.call(__MODULE__, {:think, prompt, opts}, :infinity)
  end
  
  @doc """
  Async inference - sends result to callback pid.
  """
  @spec think_async(String.t(), keyword()) :: :ok
  def think_async(prompt, opts \\ []) do
    GenServer.cast(__MODULE__, {:think_async, prompt, opts})
  end
  
  @doc """
  Get current status and stats.
  """
  @spec status() :: map()
  def status do
    GenServer.call(__MODULE__, :status)
  end
  
  @doc """
  Format a heartbeat progress bar.
  """
  @spec heartbeat(String.t(), integer(), integer()) :: String.t()
  def heartbeat(stage, current, total \\ 7) do
    filled = min(current, total)
    empty = total - filled
    bar = String.duplicate(@bar_filled, filled) <> String.duplicate(@bar_empty, empty)
    "...#{stage} #{@bar_prefix}#{bar}#{@bar_cap}"
  end
  
  # ─────────────────────────────────────────────────────────────
  # Server Callbacks
  # ─────────────────────────────────────────────────────────────
  
  @impl true
  def init(_opts) do
    state = %{
      openai_key: load_key("OpenAi.key", "OPENAI_KEY"),
      cursor_key: load_key("Cursor.key", "CURSOR_KEY"),
      requests_processed: 0,
      last_request_at: nil,
      started_at: DateTime.utc_now()
    }
    
    Logger.info("[INFERENCE] GenServer initialized")
    Logger.info("[INFERENCE] OpenAI: #{if state.openai_key, do: "loaded", else: "not found"}")
    Logger.info("[INFERENCE] Cursor: #{if state.cursor_key, do: "loaded", else: "not found"}")
    
    {:ok, state}
  end
  
  @impl true
  def handle_call({:think, prompt, opts}, _from, state) do
    model = Keyword.get(opts, :model, :openai)
    system_prompt = Keyword.get(opts, :system, nil)
    heartbeat_callback = Keyword.get(opts, :heartbeat_callback, nil)
    
    # Emit heartbeat stages
    emit_heartbeat(heartbeat_callback, "loading{context}", 1)
    
    result = case model do
      :openai -> call_openai(prompt, system_prompt, state.openai_key, heartbeat_callback)
      :cursor -> call_cursor(prompt, system_prompt, state.cursor_key, heartbeat_callback)
      _ -> {:error, "Unknown model: #{model}"}
    end
    
    emit_heartbeat(heartbeat_callback, "complete", 7)
    
    new_state = %{state |
      requests_processed: state.requests_processed + 1,
      last_request_at: DateTime.utc_now()
    }
    
    {:reply, result, new_state}
  end
  
  @impl true
  def handle_call(:status, _from, state) do
    status = %{
      openai: if(state.openai_key, do: :loaded, else: :missing),
      cursor: if(state.cursor_key, do: :loaded, else: :missing),
      requests_processed: state.requests_processed,
      last_request_at: state.last_request_at,
      uptime_seconds: DateTime.diff(DateTime.utc_now(), state.started_at)
    }
    {:reply, status, state}
  end
  
  @impl true
  def handle_cast({:think_async, prompt, opts}, state) do
    callback = Keyword.get(opts, :callback)
    
    # Spawn task for async processing
    Task.start(fn ->
      result = think(prompt, opts)
      if callback, do: send(callback, {:inference_result, result})
    end)
    
    {:noreply, state}
  end
  
  # ─────────────────────────────────────────────────────────────
  # OpenAI API
  # ─────────────────────────────────────────────────────────────
  
  defp call_openai(prompt, system_prompt, api_key, heartbeat_cb) do
    unless api_key do
      {:error, "OpenAI API key not configured"}
    else
      emit_heartbeat(heartbeat_cb, "thinking{openai}", 2)
      
      messages = build_messages(prompt, system_prompt)
      
      body = Jason.encode!(%{
        model: "gpt-4o-mini",
        messages: messages,
        max_tokens: 1024
      })
      
      emit_heartbeat(heartbeat_cb, "inference{gpt}", 3)
      
      case http_post("https://api.openai.com/v1/chat/completions", body, [
        {"Authorization", "Bearer #{api_key}"},
        {"Content-Type", "application/json"}
      ]) do
        {:ok, response} ->
          emit_heartbeat(heartbeat_cb, "compiling{tokens}", 5)
          parse_openai_response(response)
        {:error, reason} ->
          {:error, reason}
      end
    end
  end
  
  defp parse_openai_response(response) do
    case Jason.decode(response) do
      {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
        {:ok, content}
      {:ok, %{"error" => %{"message" => msg}}} ->
        {:error, msg}
      {:error, _} ->
        {:error, "Failed to parse OpenAI response"}
    end
  end
  
  # ─────────────────────────────────────────────────────────────
  # Cursor API
  # ─────────────────────────────────────────────────────────────
  
  defp call_cursor(prompt, system_prompt, api_key, heartbeat_cb) do
    unless api_key do
      {:error, "Cursor API key not configured"}
    else
      emit_heartbeat(heartbeat_cb, "thinking{cursor}", 2)
      
      # Cursor uses similar format to OpenAI
      messages = build_messages(prompt, system_prompt)
      
      body = Jason.encode!(%{
        model: "cursor-small",
        messages: messages,
        max_tokens: 1024
      })
      
      emit_heartbeat(heartbeat_cb, "inference{cursor}", 3)
      
      case http_post("https://api.cursor.sh/v1/chat/completions", body, [
        {"Authorization", "Bearer #{api_key}"},
        {"Content-Type", "application/json"}
      ]) do
        {:ok, response} ->
          emit_heartbeat(heartbeat_cb, "compiling{tokens}", 5)
          parse_openai_response(response)  # Same format
        {:error, reason} ->
          {:error, reason}
      end
    end
  end
  
  # ─────────────────────────────────────────────────────────────
  # Helpers
  # ─────────────────────────────────────────────────────────────
  
  defp build_messages(prompt, nil), do: [%{role: "user", content: prompt}]
  defp build_messages(prompt, system_prompt) do
    [
      %{role: "system", content: system_prompt},
      %{role: "user", content: prompt}
    ]
  end
  
  defp emit_heartbeat(nil, _stage, _progress), do: :ok
  defp emit_heartbeat(callback, stage, progress) when is_pid(callback) do
    send(callback, {:heartbeat, heartbeat(stage, progress)})
  end
  defp emit_heartbeat(callback, stage, progress) when is_function(callback, 1) do
    callback.(heartbeat(stage, progress))
  end
  defp emit_heartbeat(_, stage, progress) do
    Logger.debug("[INFERENCE] #{heartbeat(stage, progress)}")
  end
  
  defp load_key(filename, prefix) do
    path = Path.join([@keys_dir, filename])
    
    cond do
      File.exists?(path) ->
        content = File.read!(path) |> String.trim()
        # Parse KEY=value format
        case String.split(content, "=", parts: 2) do
          [^prefix, value] -> value
          [value] -> value  # No prefix
          _ -> nil
        end
      true ->
        # Try environment variable
        System.get_env(prefix)
    end
  end
  
  defp http_post(url, body, headers) do
    uri = URI.parse(url)
    
    {:ok, conn} = :ssl.connect(
      String.to_charlist(uri.host),
      uri.port || 443,
      [:binary, active: false, verify: :verify_none],
      10_000
    )
    
    request = """
    POST #{uri.path} HTTP/1.1\r
    Host: #{uri.host}\r
    Content-Length: #{byte_size(body)}\r
    #{Enum.map(headers, fn {k, v} -> "#{k}: #{v}\r\n" end) |> Enum.join()}
    \r
    #{body}
    """
    
    :ssl.send(conn, request)
    
    case recv_response(conn, "") do
      {:ok, response} ->
        :ssl.close(conn)
        # Extract body from HTTP response
        case String.split(response, "\r\n\r\n", parts: 2) do
          [_, body] -> {:ok, body}
          _ -> {:error, "Invalid HTTP response"}
        end
      {:error, reason} ->
        :ssl.close(conn)
        {:error, reason}
    end
  end
  
  defp recv_response(conn, acc) do
    case :ssl.recv(conn, 0, 30_000) do
      {:ok, data} ->
        new_acc = acc <> data
        # Check if we have complete response (simplified)
        if String.contains?(new_acc, "\r\n\r\n") and 
           (String.contains?(new_acc, "\"choices\"") or String.contains?(new_acc, "\"error\"")) do
          {:ok, new_acc}
        else
          recv_response(conn, new_acc)
        end
      {:error, :closed} ->
        {:ok, acc}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
# :: ∎