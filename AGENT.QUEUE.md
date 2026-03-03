///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.062 // WORKBOOK :: AGENT.QUEUE ▞▞

```elixir
/// status:[ACTIVE] ver:[1.0.0] created:[26.03.03]
/// doc:[PARTIAL] modified:[26.03.03] auth:[ZEN.PRO]
/// Agent task queue — dispatch to Cursor agents while AFK
```

# AGENT.QUEUE — Task Dispatch for Cursor Agents

Work runs HERE (ZENS3N repo). 3OX.Ai repo stays stable.
Each task is self-contained. Agents can run in parallel unless marked sequential.

────────────────────────────────────────────────
## HOW TO USE
────────────────────────────────────────────────

1. Open Cursor on this repo (`git@github.com:LLMasterDesign/ZENS3N.git`)
2. Checkout this branch: `git checkout agents/task-queue`
3. Open a new agent chat
4. Paste the task block you want executed
5. Agent works, commits to this branch
6. Repeat with next task

Status key: `[ ]` todo · `[~]` in progress · `[x]` done · `[!]` blocked

────────────────────────────────────────────────
## BATCH A — ASSESSMENT (read-only, all parallel)
────────────────────────────────────────────────

### A1 [ ] Code Audit — 3OX.Ai Repo
```
REPO: git@github.com:LLMasterDesign/3OX.Ai.git
BRANCHES: main, substrate/elixir-frontmatter, structure/3ox-core,
          tron/systemd, meta/logging, agents/live

TASK: Full code audit across all branches.
- List every file, its purpose, and whether it follows elixir frontmatter spec
- Identify dead code, orphan files, broken references
- Check all .rs, .rb, .yml, .json, .toml files for syntax errors
- Flag any hardcoded paths that won't work outside the original machine
- Check for secrets, API keys, tokens that shouldn't be committed

OUTPUT: Write findings to AUDIT.3OX.md in this repo root.
FORMAT: Table per branch. Columns: File | Status | Issues | Action Needed
```

### A2 [ ] Code Audit — ZENS3N Repo
```
REPO: this repo (ZENS3N)
BRANCHES: main, branch/TelePromptR, branch/VPS, branch/BASE

TASK: Same audit as A1 but for ZENS3N.
- Map the full directory tree with purpose annotations
- Identify which files are active vs legacy vs broken
- Check .3ox/ structure against PLAN.md spec in 3OX.Ai repo
- Flag anything that contradicts the L2 (6 files) / L3 (7 folders) spec
- Document what exists on VPS vs what's only in git

OUTPUT: Write findings to AUDIT.ZENS3N.md in this repo root.
```

### A3 [ ] Architecture Validation
```
INPUT: Read PLAN.md from 3OX.Ai repo (substrate/elixir-frontmatter branch)
       Read AGENTS.md from this repo (main branch)
       Read .3ox/ structure from both repos

TASK: Cross-reference the PLAN.md architecture spec against reality.
- Does the actual .3ox/ match L2 spec? (6 files in numbered dirs)
- Does .vec3/ match L3 spec? (7 folders: rc, lib, dev, var, bin, mem, proc)
- Does _meta/ have all 4 required files?
- Are elixir frontmatter headers on ALL files?
- Does the 5-6-7-7-2 lattice hold in practice?
- Where are the gaps between spec and implementation?

OUTPUT: Write VALIDATION.md — pass/fail per spec item with evidence.
```

### A4 [ ] Research — Investor Pitch Sources
```
TASK: Research and compile sources for a 3OX.Ai investor pitch.

TOPICS TO RESEARCH:
1. AI agent marketplace economics (2025-2026 data)
   - How much are people paying for AI agents/bots?
   - What's the TAM for personal AI assistants?
2. Comparable products and competitors
   - Custom GPTs marketplace, Poe bots, Character.ai
   - How do they monetize? What's working?
3. Infrastructure-as-a-service precedents
   - AWS Lambda, Vercel, Railway — infra layer valuations
4. 100-year technology precedents
   - Unix, TCP/IP, BEAM/OTP — survival patterns
5. Agent-to-agent communication protocols (2026 state of art)
   - MCP, A2A, any emerging standards

OUTPUT: Write RESEARCH.PITCH.md — organized by topic with URLs and key stats.
Each section: Summary, Data Points, Source URLs, Relevance to 3OX.
```

### A5 [ ] Research — Value Assessment
```
TASK: Write a value assessment of 3OX.Ai as it exists TODAY.

READ: PLAN.md (3OX.Ai repo), all code in both repos, this AGENT.QUEUE.md

ASSESS:
- What works right now (proof points)
- What's unique (differentiation from GPTs, Poe, etc.)
- Technical debt and risks
- What an investor would ask and how to answer
- Realistic timeline to revenue
- What a portfolio reviewer would want to see

OUTPUT: Write VALUE.ASSESSMENT.md — honest, data-backed, not hype.
Include a SWOT analysis section.
```

────────────────────────────────────────────────
## BATCH B — WRITING (parallel, no code changes)
────────────────────────────────────────────────

### B1 [ ] Portfolio Synopsis
```
TASK: Write a portfolio-ready synopsis of 3OX.Ai.

AUDIENCE: Technical hiring managers, investors, collaborators.
TONE: Professional but authentic. Show the thinking, not just the result.

INCLUDE:
- What 3OX.Ai is (one paragraph)
- The architecture (5-6-7-7-2, language ownership, vec3 kernel)
- What's running today (Money.Bagz, TelePromptR, Telegram integration)
- Technical decisions and why (Rust for policy, Elixir for streaming, Ruby for glue)
- The 100-year substrate concept
- Links: GitHub repos, 1n3ox.ai

OUTPUT: Write PORTFOLIO.md in this repo root.
Keep it under 2 pages. Punchy. No fluff.
```

### B2 [ ] Investor Pitch Document
```
TASK: Write a seed-stage investor pitch for 3OX.Ai.

INPUT: Read PLAN.md (3OX.Ai), VALUE.ASSESSMENT.md (if A5 is done),
       RESEARCH.PITCH.md (if A4 is done)

STRUCTURE:
1. Problem — AI agents are disposable, model-locked, personality-less
2. Solution — 3OX.Ai: substrate that outlasts any model
3. How it works — sparkfile → soul → brain → tools → run (30 seconds)
4. Traction — working agents on Telegram today
5. Market — AI agent marketplace ($X TAM)
6. Business model — free → store → rental → enterprise
7. Team — solo founder, full-stack architect, veteran
8. Ask — what you need to get to v2

OUTPUT: Write PITCH.md in this repo root.
```

### B3 [ ] 3OX.Store Product Spec
```
TASK: Write a product spec for the 3OX.Store marketplace.

COVER:
- User personas (builder, buyer, renter)
- Agent categories (finance, legal, research, creative, ops)
- Pricing tiers (free, purchase, rental, enterprise)
- Wallet/credits system for pay-per-use agents
- Personality pack marketplace (.arc/.spark files)
- Community contribution model (submit → review → publish)
- Technical requirements (how an agent gets listed)
- Trust/safety (reviews, ratings, usage limits)

OUTPUT: Write STORE.SPEC.md in this repo root.
```

────────────────────────────────────────────────
## BATCH C — BUILD (sequential, changes code)
────────────────────────────────────────────────

### C1 [ ] TelePromptR Agent Wrapping
```
PREREQUISITE: A2 done (need to know current TPR state)

REPO: branch/TelePromptR in this repo

TASK: Ensure all agent responses via TelePromptR are:
- Wrapped with agent identity (not "CMD BRIDGE")
- Coherent with the agent's personality from brains.rs
- Streaming token-by-token via editMessageText
- Showing "...thinking" placeholder before first tokens arrive

CHECK: speaker-mesh.rb, teleprompter.rb, route maps
FIX: Any agent that responds as CMD BRIDGE instead of its own name

OUTPUT: Commit fixes to branch/TelePromptR. Document changes in commit msg.
```

### C2 [ ] Log System Activation
```
TASK: Make all logging functional across the system.

LOGS TO ACTIVATE:
- 3ox.log in every agent's (6)Pulse/ — append-only operation log
- pulse.jsonl in _meta/ — heartbeat entries
- state.jsonl in _meta/ — checkpoint state
- receipts/ in (6)Pulse/ — operation receipts

EACH LOG NEEDS:
- Correct file path (relative to agent root)
- Timestamp format (ISO 8601)
- Agent identity in each entry
- Created on first run if missing

OUTPUT: Commit log system updates. Test with Money.Bagz agent.
```

### C3 [ ] Agent Boot Chain Implementation
```
PREREQUISITE: C2 done

TASK: Implement the boot chain from PLAN.md in run.rb:

1. Read sparkfile.md (identity)
2. Read soul.md (purpose) — if exists
3. Load brains.rs (personality)
4. Check tools.yml (capabilities)
5. Validate limits.toml (constraints)
6. Create/append 3ox.log (first entry)
7. Print boot summary to stdout

The boot chain should work for ANY agent, not just Money.Bagz.
Template it so new agents get this for free.

OUTPUT: Updated run.rb template. Test with Money.Bagz.
```

### C4 [ ] 1n3ox.ai Site Update
```
PREREQUISITE: B1 done (need portfolio content)

TASK: Update 1n3ox.ai with:
- Landing page showing what 3OX.Ai is
- Architecture diagram (can be text/ASCII)
- Link to GitHub repos
- "Get Started" section from PLAN.md onboarding flow
- Portfolio content from PORTFOLIO.md

CHECK: What exists at 1n3ox-temp/ in this repo
OUTPUT: Updated site files, ready to deploy.
```

────────────────────────────────────────────────
## BATCH D — OPERATIONS (need VPS access)
────────────────────────────────────────────────

### D1 [ ] VPS Health Check
```
VPS: root@<REDACTED_HOST> (SSH key: ~/.ssh/id_zens3n_vps)

TASK: Full health check of CMD.VPS:
- List all running services (systemctl list-units)
- Check speaker-mesh and teleprompter status
- Check disk space, memory, uptime
- List all agent directories and their state
- Verify TelePromptR is processing messages
- Check _TRON structure if it exists
- Document what's running vs what should be running

OUTPUT: Write VPS.STATUS.md with findings.
```

### D2 [ ] Deploy Second Agent
```
PREREQUISITE: C1, C3 done

TASK: Stand up a second agent on VPS alongside Money.Bagz.
- Choose: Atlas or VSO Agent (whichever has more complete .3ox/)
- Create sync-vps.sh for the agent
- Deploy to VPS
- Register with TelePromptR (/topic add, /teleprompter subscribe)
- Verify responses in Telegram

OUTPUT: Working second agent. Document in commit.
```

────────────────────────────────────────────────
## PRIORITY ORDER
────────────────────────────────────────────────

**Run first (parallel):** A1, A2, A3, A4, A5
**Run second (parallel):** B1, B2, B3
**Run third (sequential):** C1 → C2 → C3 → C4
**Run last (needs VPS):** D1 → D2

Total: 13 tasks. Batches A+B can all run simultaneously (9 agents).
Batch C is sequential. Batch D needs SSH access.

:: ∎
