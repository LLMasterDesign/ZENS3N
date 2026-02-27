# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x8F1F]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // PROD.EXS ▞▞
# ▛▞// PROD.EXS :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [grpc] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.prod.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for PROD.EXS
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

# Production specific configuration
config :logger, level: :info

config :vec3,
  grpc_port: String.to_integer(System.get_env("VEC3_GRPC_PORT", "50051"))

# :: ∎