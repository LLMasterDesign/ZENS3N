# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x05C8]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // WARDEN.EX ▞▞
# ▛▞// WARDEN.EX :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [warden] [vector] [toml] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.warden.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for WARDEN.EX
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

# VEC3.WARDEN.EX :: Security/Policy Engine
# Elixir implementation for policy enforcement and access control
#
# Pattern matching for elegant policy rules
# Actor model for isolated policy evaluation
# Hot reload for policy updates

defmodule Vec3.Warden do
  @moduledoc """
  Warden - Security/Policy Enforcement Engine
  
  Role: Security guard - "Is this action allowed?"
  Uses: Pattern matching for policy rules
  Integrates: Router (Rust) for context-aware policies
  """

  # ============================================================================
  # POLICY TYPES
  # ============================================================================

  @type operation :: {:create_file, String.t()} 
                   | {:read_file, String.t()}
                   | {:write_file, String.t()}
                   | {:delete_file, String.t()}
                   | {:start_process, String.t()}
                   | {:stop_process, String.t()}
                   | {:access_registry, String.t()}
                   | {:execute_command, String.t()}

  @type context :: %{
    user: String.t(),
    workspace: String.t(),
    current_path: String.t(),
    router_activation: list(float()) | nil
  }

  @type result :: {:allow, String.t()} | {:deny, String.t()}

  # ============================================================================
  # PUBLIC API
  # ============================================================================

  @doc """
  Check if an operation is allowed given context
  
  Returns: {:allow, reason} or {:deny, reason}
  """
  @spec check_permission(operation(), context()) :: result()
  def check_permission(operation, context) do
    # Apply policy rules via pattern matching
    case operation do
      # File operations
      {:create_file, path} ->
        check_file_creation(path, context)
      
      {:read_file, path} ->
        check_file_read(path, context)
      
      {:write_file, path} ->
        check_file_write(path, context)
      
      {:delete_file, path} ->
        check_file_deletion(path, context)
      
      # Process operations
      {:start_process, process_name} ->
        check_process_start(process_name, context)
      
      {:stop_process, process_name} ->
        check_process_stop(process_name, context)
      
      # Registry operations
      {:access_registry, registry_path} ->
        check_registry_access(registry_path, context)
      
      # Command execution
      {:execute_command, command} ->
        check_command_execution(command, context)
      
      # Unknown operation - deny by default
      _ ->
        {:deny, "Unknown operation type"}
    end
  end

  # ============================================================================
  # FILE OPERATION POLICIES
  # ============================================================================

  defp check_file_creation(path, context) do
    cond do
      # Deny: Cannot create files in .3ox root
      String.starts_with?(path, "/root/!LAUNCHPAD/.3ox/") and
        not String.contains?(path, "/vec3/") ->
        {:deny, "Cannot create files in .3ox root - use vec3/ subdirectories"}
      
      # Deny: Cannot create files in CORE without authorization
      String.contains?(path, "!CORE/") and not authorized_for_core?(context) ->
        {:deny, "Cannot modify CORE without authorization"}
      
      # Allow: Normal workspace files
      String.starts_with?(path, "/root/!LAUNCHPAD/!WORKDESK/") ->
        {:allow, "Allowed in WORKDESK"}
      
      # Allow: Operations files
      String.starts_with?(path, "/root/!LAUNCHPAD/!CMD.CENTER/!CMD.OPS/") ->
        {:allow, "Allowed in CMD.OPS"}
      
      # Default: Allow with warning
      true ->
        {:allow, "Default allow - monitor for violations"}
    end
  end

  defp check_file_read(path, _context) do
    cond do
      # Allow: Imprint files (public identity)
      String.ends_with?(path, ".imprint") ->
        {:allow, "Imprint files are public"}
      
      # Allow: Most files
      true ->
        {:allow, "Read access allowed"}
    end
  end

  defp check_file_write(path, context) do
    # Same rules as creation
    check_file_creation(path, context)
  end

  defp check_file_deletion(path, context) do
    cond do
      # Deny: Critical system files
      String.contains?(path, "/.3ox/sparkfile.md") ->
        {:deny, "Cannot delete sparkfile.md - critical system file"}
      
      # Deny: Registry files
      String.contains?(path, "BASE_REGISTRY.toml") ->
        {:deny, "Cannot delete BASE_REGISTRY.toml - use registry commands"}
      
      # Same rules as creation for other paths
      true ->
        check_file_creation(path, context)
    end
  end

  # ============================================================================
  # PROCESS OPERATION POLICIES
  # ============================================================================

  defp check_process_start(process_name, context) do
    cond do
      # Allow: Registered services
      is_registered_service?(process_name) ->
        {:allow, "Registered service"}
      
      # Deny: Unknown processes
      true ->
        {:deny, "Unknown process - register first"}
    end
  end

  defp check_process_stop(process_name, _context) do
    # Allow stopping processes (with logging)
    {:allow, "Process stop allowed"}
  end

  # ============================================================================
  # REGISTRY OPERATION POLICIES
  # ============================================================================

  defp check_registry_access(registry_path, context) do
    cond do
      # Allow: Reading registry (discovery)
      String.contains?(registry_path, "BASE_REGISTRY.toml") ->
        {:allow, "Registry discovery allowed"}
      
      # Deny: Writing registry without proper commands
      not authorized_for_registry?(context) ->
        {:deny, "Use '3ox reg' commands to modify registry"}
      
      true ->
        {:allow, "Registry access allowed"}
    end
  end

  # ============================================================================
  # COMMAND EXECUTION POLICIES
  # ============================================================================

  defp check_command_execution(command, context) do
    cond do
      # Deny: Dangerous commands
      String.contains?(command, "rm -rf /") ->
        {:deny, "Dangerous command blocked"}
      
      # Deny: System modification without authorization
      String.contains?(command, "sudo") and not authorized_for_system?(context) ->
        {:deny, "System modification requires authorization"}
      
      # Allow: Normal commands
      true ->
        {:allow, "Command execution allowed"}
    end
  end

  # ============================================================================
  # HELPER FUNCTIONS
  # ============================================================================

  defp authorized_for_core?(context) do
    # Check if user/context authorized for CORE modifications
    # This could check router activation, user permissions, etc.
    get_in(context, [:router_activation]) != nil
  end

  defp authorized_for_registry?(context) do
    # Check if authorized to modify registry
    # Could check for registry operation context
    get_in(context, [:operation_type]) == :registry_operation
  end

  defp authorized_for_system?(context) do
    # Check if authorized for system-level operations
    get_in(context, [:user]) == "root" or
    get_in(context, [:privileged]) == true
  end

  defp is_registered_service?(process_name) do
    # Check if process is registered in registry
    # This would call Registry (Ruby) via bridge
    # For now, return true for known services
    known_services = ["supervisor", "warden", "router", "registry"]
    Enum.member?(known_services, process_name)
  end

  # ============================================================================
  # ROUTER INTEGRATION
  # ============================================================================

  @doc """
  Get context-aware policy selection using Router activation vector
  """
  def get_policy_from_router(activation_vector) when is_list(activation_vector) do
    # Map router activation to policy strictness
    # Higher activation = stricter policies
    
    avg_activation = Enum.sum(activation_vector) / length(activation_vector)
    
    cond do
      avg_activation > 0.8 ->
        :strict
      avg_activation > 0.5 ->
        :moderate
      true ->
        :lenient
    end
  end

  def get_policy_from_router(_) do
    :moderate  # Default
  end
end

# :: ∎