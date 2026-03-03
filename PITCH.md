///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.062 // WORKBOOK :: PITCH.md ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.03.03]
/// doc:[DRAFT] modified:[26.03.03] auth:[ZEN.PRO]
/// Seed-stage investor pitch — 3OX.Ai (substrate + store)
```

# 3OX.Ai — Agents that outlast any model

## 1) Problem — AI agents are disposable, model-locked, personality-less

Today’s “agents” are mostly prompts glued to a single model + vendor stack:
- Disposable: no durable identity, no governed state, no receipts, no lifecycle.
- Model-locked: when the model or policy changes, the “agent” breaks.
- Personality-less: everyone ships the same generic assistant voice; brands can’t own tone.
- No substrate: no standard boot chain, tool registry, routing, policy layer, or event log.

## 2) Solution — 3OX.Ai: substrate infrastructure that outlasts any model

3OX.Ai is infrastructure for building and running agents as **durable systems**:
- Model-agnostic by design: swap models without losing the agent’s identity or runtime.
- Built on proven longevity patterns (Unix filesystem discipline, OTP supervision, contracts).
- A fixed topology (“5-6-7-7-2 lattice”) where models are replaceable components.

## 3) How it works — sparkfile → soul → brain → tools → run (30 seconds)

Every agent is a portable “cube” with a deterministic boot chain:
1. **sparkfile** — identity + contract (what this agent *is*).
2. **soul** — purpose anchor (why it persists; optional but first-class).
3. **brain** (`brains.rs`) — persona + rules (how it behaves).
4. **tools** (`tools.yml`) — capabilities (what it can do).
5. **run** (`run.rb`) — supervised execution + routing + receipts (what happened, when).

Under the hood, 3OX splits ownership by language where it matters:
- **Rust**: Warden + Brains (policy + identity-critical logic).
- **Elixir/OTP**: Tape + Pulse + Arc (event streaming, heartbeats, persona loading).
- **Ruby**: Supervisor + Worker (orchestration glue + task execution).

## 4) Traction — working agents on Telegram today, streaming + routing

Already running in production-like conditions:
- **Money.Bagz**: a working Telegram agent responding today.
- **TelePromptR**: topic-based routing to multiple agents.
- **speaker-mesh**: inference layer with **streaming responses**.
- **systemd-managed runtime** for key services (speaker-mesh + teleprompter).

## 5) Market — the agent economy is becoming a platform layer

Signals that “agents” are moving from feature → platform category:
- Enterprise adoption: Gartner is widely cited predicting **40% of enterprise apps** will embed AI agents by end of **2026** (up from <5% in 2025).  
  Source: https://www.uctoday.com/unified-communications/gartner-predicts-40-of-enterprise-apps-will-feature-ai-agents-by-2026/
- Market growth: BCC Research projects the **AI agents market** growing from **$8B (2025)** to **$48.3B (2030)** (~**43.3% CAGR**).  
  Source: https://www.bccresearch.com/pressroom/ait/ai-agents-market-to-grow-433-annually

3OX is positioned where the enduring value accrues: **the substrate + store**, not any single model.

## 6) Business model — Free → Store → Rental → Enterprise

Land with builders, expand with distribution, then move upmarket:
- **Free (self-host):** open substrate + templates, run anywhere.
- **Store (pre-built agents):** $20–200 one-time purchase.
- **Rental (per-use):** $5–50 per session for premium agents / inference.
- **Enterprise:** custom agents + governance + deployment.

## 7) 3OX.Store concept — Netflix for AI (personalities sold separately)

3OX.Store is a marketplace where:
- Agents are **products** (portable cubes), not fragile prompts.
- **Personalities are modular**: sell `.arc` / `.spark` packs independently of tools.
- “Substrate chapters” ship as the ecosystem evolves (templates, governance, routing).

## 8) Team — solo founder, full-stack system architect, US veteran

- Solo founder shipping end-to-end: language runtime architecture (Rust/Elixir/Ruby), infra, and live agent deployments.
- US veteran; building a long-horizon substrate with disciplined operational contracts.

## 9) Ask — what’s needed to reach v2

Seed support to turn a working substrate into a repeatable, sellable platform:
- **Productize boot chain**: templates + “new agent” generator + docs.
- **SDK + public API**: stable interfaces for tools, routing, receipts, and governance.
- **3OX.Store alpha**: listing pipeline, packaging format, and payments/credits.
- **Operational hardening**: multi-device orchestration (_TRON contracts), observability, safety.
- **Traction expansion**: ship 3–5 flagship agents + creator onboarding for community supply.

:: ∎
