///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.062 // WORKBOOK :: PITCH.md ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.03.03]
/// doc:[DRAFT] modified:[26.03.03] auth:[ZEN.PRO]
/// Seed-stage investor pitch — 3OX.Ai (substrate + store)
```

# 3OX.Ai — Durable agent substrate + store (model-agnostic)

**One-liner:** 3OX.Ai is infrastructure for AI agents that **outlast any model**—a portable runtime substrate with governed identity, tooling, routing, and receipts, plus a marketplace for pre-built agents and personalities.

**At a glance**
- **Today:** working Telegram agents, streaming responses, topic-based multi-agent routing
- **Business:** Free (self-host) → Store ($20–200) → Rental ($5–50/session) → Enterprise (custom)
- **Thesis:** durable substrate value compounds as models commoditize

## The Problem

The “agent” category is exploding, but most agents are fragile products:
- **Disposable**: no durable identity, governed state, receipts, or lifecycle.
- **Model-locked**: vendor/model shifts break behavior and economics overnight.
- **Personality-less**: tone isn’t owned; differentiation collapses into “generic assistant.”
- **No substrate**: no standard boot chain, tool registry, routing layer, policy layer, or event log.

## The Solution

3OX.Ai turns agents into **durable systems**:
- **Model-agnostic by design**: swap inference providers without losing the agent.
- **Governed runtime**: policy enforcement, supervised execution, append-only receipts/logs.
- **A fixed topology (“5-6-7-7-2 lattice”)** where models are replaceable components, not the product.

## How It Works (30 seconds)

Every agent is a portable “cube” with a deterministic boot chain:
- **sparkfile** → identity + contract (what this agent *is*)
- **soul** → purpose anchor (why it persists)
- **brain** (`brains.rs`) → persona + rules (how it behaves)
- **tools** (`tools.yml`) → capabilities (what it can do)
- **run** (`run.rb`) → supervised execution + routing + receipts (what happened, when)

System ownership is intentionally split by language:
- **Rust**: Warden + Brains (policy + identity-critical logic)
- **Elixir/OTP**: Tape + Pulse + Arc (event streaming, heartbeats, persona loading)
- **Ruby**: Supervisor + Worker (orchestration glue + task execution)

## Traction (Live Today)

Working system components already running:
- **Money.Bagz**: Telegram agent responding today
- **TelePromptR**: topic-based multi-agent routing
- **speaker-mesh**: inference layer with **streaming responses**
- **systemd-managed runtime** for key services (speaker-mesh + teleprompter)

## Market

Agents are shifting from “feature” to a platform layer:
- Enterprise adoption: Gartner is widely cited predicting **40% of enterprise apps** will embed AI agents by end of **2026** (up from <5% in 2025).  
  [1]
- Market growth: BCC Research projects the **AI agents market** growing from **$8B (2025)** to **$48.3B (2030)** (~**43.3% CAGR**).  
  [2]

3OX is positioned where durable value accrues: **the substrate + store**, not a single model.

## Business Model

Simple, layered monetization aligned to adoption:
- **Free (self-host):** open substrate + templates, run anywhere ($0)
- **Store (pre-built agents):** $20–200 purchase
- **Rental (per-use):** $5–50 per session for premium agents / inference
- **Enterprise:** custom agents + governance + deployment

## 3OX.Store — “Netflix for AI” (personalities sold separately)

3OX.Store treats agents as products (portable cubes), not fragile prompts:
- **Agents** sold as packaged systems with identity, tools, routing, and receipts
- **Personality packs** sold separately (`.arc` / `.spark`) to unlock brand tone and human feel
- “Substrate chapters” ship as the ecosystem grows (templates, governance, routing)

## Team

- Solo founder shipping end-to-end (Rust/Elixir/Ruby runtime architecture, infra, and live deployments)
- US veteran building a long-horizon substrate with disciplined operational contracts

## Ask (to reach v2)

Seed support to turn a working substrate into a repeatable, sellable platform:
- **Productize the boot chain**: templates + “new agent” generator + documentation
- **SDK + public API**: stable interfaces for tools, routing, receipts, governance
- **3OX.Store alpha**: listing pipeline, packaging format, payments/credits
- **Operational hardening**: multi-device orchestration (_TRON contracts), observability, safety
- **Traction expansion**: ship 3–5 flagship agents + creator onboarding to build supply

---

### Sources

[1] UC Today — “Gartner predicts 40% of enterprise apps will feature AI agents by 2026”  
https://www.uctoday.com/unified-communications/gartner-predicts-40-of-enterprise-apps-will-feature-ai-agents-by-2026/

[2] BCC Research — “AI Agents Market to Grow 43.3% Annually Through 2030”  
https://www.bccresearch.com/pressroom/ait/ai-agents-market-to-grow-433-annually

:: ∎
