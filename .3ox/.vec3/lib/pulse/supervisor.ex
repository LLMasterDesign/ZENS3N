# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xD249]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // SUPERVISOR.EX ▞▞
# ▛▞// SUPERVISOR.EX :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [merkle] [pulse] [otp] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.supervisor.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for SUPERVISOR.EX
# ```

# 


# 


#

#
# ▛//▞ PRISM :: KERNEL
# P:: supervisor ∙ fault.tolerance ∙ always.on
# R:: spawn.pulse ∙ restart.on.crash ∙ maintain.merkle
# I:: intent.target={event.integrity ∙ merkle.continuity}
# S:: start → spawn.child → monitor → restart
# M:: genserver.child ∙ one_for_one
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ start{supervisor}
# ⇨ ≔ spawn{pulse.genserver}
# ⟿ ≔ monitor{health ∙ crashes}
# ▷ ≔ restart{on.failure}
# :: ∎

defmodule Vec3.Pulse.Supervisor do
  @moduledoc """
  Supervisor for the PULSE GenServer.
  
  Uses `one_for_one` strategy - if PULSE crashes, only PULSE restarts.
  PULSE state is persisted to disk, so restart is safe.
  Merkle root is recomputed on restart from the pulse log.
  """
  
  use Supervisor
  require Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      {Vec3.Pulse, []}
    ]

    Logger.info("[PULSE.Supervisor] Starting...")
    Supervisor.init(children, strategy: :one_for_one)
  end
end
# :: ∎