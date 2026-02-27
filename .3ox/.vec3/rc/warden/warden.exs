# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x3F28]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // WARDEN.EXS ▞▞
# ▛▞// WARDEN.EXS :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [warden] [json] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.warden.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for WARDEN.EXS
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

#
# Warden is the ONLY authority gate.
# All state transitions must pass through Warden.
# This file is called from Ruby via: elixir rc/auth/warden.exs <envelope_json>
#
# Warden responsibilities:
# - Authorize or deny transitions
# - Validate envelope shape
# - Check permissions against 3ox.key
# - Return {:ok, envelope} or {:deny, reason}

defmodule Vec3.Warden do
  @moduledoc """
  Authorization gate for vec3.
  Called from Ruby orchestration layer.
  """

  @doc """
  Authorize an envelope for execution.
  Returns {:ok, envelope} or {:deny, reason}
  """
  @spec authorize(map()) :: {:ok, map()} | {:deny, String.t()}
  def authorize(%{"op" => op, "actor" => actor} = envelope) do
    with :ok <- validate_shape(envelope),
         :ok <- check_permissions(actor, op),
         :ok <- check_limits(envelope) do
      {:ok, envelope}
    else
      {:error, reason} -> {:deny, reason}
    end
  end

  def authorize(_), do: {:deny, "Invalid envelope shape"}

  # ═══════════════════════════════════════════════════════════════
  # Validation
  # ═══════════════════════════════════════════════════════════════

  defp validate_shape(%{"op" => op, "actor" => _actor}) when is_binary(op), do: :ok
  defp validate_shape(_), do: {:error, "Missing required fields: op, actor"}

  defp check_permissions(_actor, _op) do
    # TODO: Load 3ox.key and verify permissions
    # For now, allow all
    :ok
  end

  defp check_limits(%{"timeout_ms" => timeout}) when timeout > 300_000 do
    {:error, "Timeout exceeds maximum (300s)"}
  end
  defp check_limits(_), do: :ok
end

# ═══════════════════════════════════════════════════════════════
# CLI Entry Point
# ═══════════════════════════════════════════════════════════════

case System.argv() do
  [envelope_json] ->
    case Jason.decode(envelope_json) do
      {:ok, envelope} ->
        case Vec3.Warden.authorize(envelope) do
          {:ok, env} ->
            IO.puts(Jason.encode!(%{status: "ok", envelope: env}))
            System.halt(0)
          {:deny, reason} ->
            IO.puts(Jason.encode!(%{status: "denied", reason: reason}))
            System.halt(1)
        end
      {:error, _} ->
        IO.puts(Jason.encode!(%{status: "error", reason: "Invalid JSON"}))
        System.halt(1)
    end
  _ ->
    IO.puts("Usage: elixir warden.exs '<envelope_json>'")
    System.halt(1)
end

# :: ∎