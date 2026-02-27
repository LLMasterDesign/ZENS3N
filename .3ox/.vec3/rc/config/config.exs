# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x9934]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // CONFIG.EXS ▞▞
# ▛▞// CONFIG.EXS :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [tape] [pulse] [grpc] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.config.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for CONFIG.EXS
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

import Config

# General application configuration
config :vec3,
  # Directories
  tape_dir: System.get_env("VEC3_TAPE_DIR", "var/tape"),
  pulse_dir: System.get_env("VEC3_PULSE_DIR", "var/pulse"),
  state_dir: System.get_env("VEC3_STATE_DIR", "var/state"),
  
  # gRPC
  grpc_port: String.to_integer(System.get_env("VEC3_GRPC_PORT", "50051")),
  
  # Hashing
  hash_algorithm_internal: :xxh128,
  hash_algorithm_outbound: :sha256

# Logger configuration
config :logger,
  level: :info

config :logger, :console,
  format: "$time [$level] $message\n"

# Import environment specific config
import_config "#{config_env()}.exs"

# :: ∎