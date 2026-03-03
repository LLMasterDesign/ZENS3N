///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.062 // WORKBOOK :: PORTFOLIO.md ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.03.03]
/// doc:[COMPLETE] modified:[26.03.03] auth:[ZEN.PRO]
/// 3OX.Ai technical synopsis — portfolio, investors, collaborators
```

# 3OX.Ai — Technical Synopsis

## What It Is

3OX.Ai is model-agnostic infrastructure for AI agents that outlasts any single model, any single company, any single decade. Each agent is a self-contained **cube** — six configuration files in a `.3ox/` directory, backed by a `vec3` runtime kernel — that can be deployed to any device, connected to any LLM, and supervised by an OTP-style fault-tolerant process tree. The system is polyglot by design: Rust enforces policy, Elixir streams events, Ruby orchestrates processes. The substrate owns the agent lifecycle. The model is a replaceable component.

## Architecture — The 5-6-7-7-2 Lattice

The entire system is a fixed topology. Five layers of containment, six cube faces, seven kernel directories, seven cross-cube services, two anchors. Everything inside evolves; the shape does not.

**5TRATA** — containment hierarchy: `CMD → Base → Station → Service → Agent`

**L2 — 6 Cube Faces** (every agent has these in `.3ox/`):

| Face | File | What It Does |
|------|------|-------------|
| (1) Spark | `sparkfile.md` | Identity, origin, boot-loader config |
| (2) Brains | `brains.rs` | Persona config (TOML), personality rules |
| (3) Rules | `limits.toml` | Constraints, write policy, safety gates |
| (4) Toolkit | `tools.yml` | Available capabilities and dependencies |
| (5) Links | `routes.json` | Routing, connections, output targets |
| (6) Pulse | `run.rb` | Entry point, receipts, lifecycle |

**L3 — 7 Kernel Directories** (`vec3/` runtime per cube): `rc/` lifecycle · `lib/` references · `dev/` IO bridges · `var/` state · `bin/` executables · `mem/` active rules · `proc/` observation

**3OX.Ai — 7 Service Modules** (cross-cube coordination):

| Module | Language | Role |
|--------|----------|------|
| **Arc** | Elixir | Persona loading, triggered personality traits |
| **Tape** | Elixir | Append-only receipt log, hash-chained (sha256) |
| **Pulse** | Elixir | Event stream with merkle root, heartbeat |
| **Warden** | Rust | Single mutation authority, policy enforcement |
| **Supervisor** | Ruby | Process lifecycle, restart strategy |
| **Worker** | Ruby | GenServer task execution |
| **Queue** | Ruby | Backpressure-aware job distribution |

**2 Anchors**: `_meta` (identity contracts, session checkpoints, merkle proofs) · `_TRON` (per-device runtime, replaces cron with contract-governed services)

## Language Ownership — Why Each One

| Language | Owns | Why |
|----------|------|-----|
| **Rust** | Warden, Brains, CLI | Policy and identity must never fail. Compiled, zero-cost, no runtime panics. The `3ox` CLI and `vec3-boot` loader are Rust binaries. |
| **Elixir/OTP** | Tape, Pulse, Arc | Event streaming and fault tolerance are what BEAM was built for. Supervision trees restart crashed services automatically. Pulse computes merkle roots over hash-chained events. Tape dual-hashes every receipt. |
| **Ruby** | Supervisor, Worker | Orchestration glue. Fast to iterate, easy to script. `run.rb` is the universal agent entry point. Lifecycle scanner, deployment scripts, VPS sync — all Ruby. |
| **gRPC/Protobuf** | Wire protocol | Language-agnostic contracts. Rust, Elixir, and Ruby all speak Protobuf across the wire. |
| **Markdown** | Sparkfiles, contracts | Human-readable truth. No compilation, no parsing ambiguity. Sparkfiles are the boot-loader — they chain to soul, brain, tools, routes, limits. |

## What's Running Today

- **Money.Bagz** agent responds to users via Telegram — live on a Hetzner VPS
- **TelePromptR** routes incoming Telegram messages to the correct agent by topic
- **speaker-mesh** handles LLM inference and streams responses back to chat
- **systemd** manages both services (`speaker-mesh.service`, `teleprompter.service`)
- **`3ox` CLI** (Rust) — `run`, `show`, `show log`, `list`, `help` — finds and launches agent cubes
- **Vec3Boot** (Rust) — interactive boot loader with cube validation, face resolution, task menu
- **Elixir OTP application** — supervision tree running Tape, Pulse, and Warden as GenServers
- **Deployment pipeline** — `sync-vps.sh` rsync to VPS → `run.rb teleprompt` generates config → `merge.sh` into TelePromptR → `systemctl restart`

## Technical Decisions — Show the Thinking

**Why not just Python?** This system needs to run for years without intervention. Python's GIL, lack of supervision trees, and runtime fragility make it wrong for always-on agent infrastructure. Erlang/OTP has been doing this for 38 years in telecom switches that never go down.

**Why not a single language?** Each concern has a natural owner. Policy enforcement is a compiler problem (Rust). Event streaming is a concurrency problem (Elixir/BEAM). Orchestration is a scripting problem (Ruby). Forcing one language to do all three produces worse code in all three areas.

**Why a fixed topology?** The 5-6-7-7-2 lattice means any engineer can open any cube and know exactly where to look. Six faces, always the same six faces. Seven kernel directories, always the same seven. The constraint is the feature — it prevents architectural drift across agents, devices, and years.

**Academic grounding:** Arc's persona system draws from CoALA (Princeton, 2023) for memory architecture, Anthropic's Persona Selection Model (2026) for treating agent identity as character, and structured personality control research (arXiv:2601.10025) for Jungian-type trait modifiers with reinforcement-compensation dynamics.

## The 100-Year Substrate

Unix is 55 and counting. Erlang/OTP is 38. Process supervision, append-only logs, and filesystem hierarchies are patterns that survived the mainframe era, the PC era, the cloud era, and the AI era. 3OX is built on these patterns deliberately.

The bet: **models change, substrates persist.** GPT-4 will be obsolete. So will whatever replaces it. The agent that survives is the one whose identity, routing, policy, and event history live in a substrate that doesn't care which model is plugged in. 3OX owns that substrate.

The topology is fixed. The contents evolve. An agent built on 3OX today can swap its LLM, change its persona, add new tools, move between devices — and its Tape still verifies, its Pulse still chains, its merkle root still holds.

## Links

- **3OX.Ai**: [github.com/LLMasterDesign/3OX.Ai](https://github.com/LLMasterDesign/3OX.Ai)
- **ZENS3N monorepo**: [github.com/LLMasterDesign/ZENS3N](https://github.com/LLMasterDesign/ZENS3N)
- **Domain**: [1n3ox.ai](https://1n3ox.ai)

:: ∎
