```r
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // MULTI.AGENT.RESOURCE.POLICY ▞▞
▞//▞ Resource.Management :: ρ{multi.agent.safety}.φ{GLOBAL}.τ{Policy}.λ{mandatory} ⫸
▙⌱[🔋] ≔ [⊢{detect}⇨{optimize}⟿{prevent.crash}▷{scale}]
〔atlas.legacy.resource.control〕 :: ∎

# 🔋 MULTI-AGENT RESOURCE MANAGEMENT POLICY

**Purpose:** Prevent context overflow crashes when multiple agents operate simultaneously  
**Authority:** GLOBAL POLICY BRAIN (Non-negotiable)  
**Version:** 1.0  
**Date:** ⧗-25.61  
**Status:** MANDATORY

---

## 🚨 THE PROBLEM

### What Happened:
```
User opens 3 agent windows simultaneously (split panes in one screen):
  ├─→ Agent 1: CMD.BRIDGE (system config)
  ├─→ Agent 2: SGL.Ai (building SunsetGlow)
  └─→ Agent 3: TP.Gen (Telegram bridge work)

Each agent loads on EVERY response:
  • 5 Global Policy files (heavy markdown)
  • Master Routing Brain
  • Ecosystem Brain (LIGHTHOUSE/SENTINEL/ALCHEMIST)
  • Project Brain
  • Active work context

Result: 3 × massive token usage = CRASH 💥
```

**This defeats the entire purpose of multi-agent orchestration.**

---

## 💡 THE SOLUTION

### Tiered Loading System:

**TIER 0: MINIMAL (Emergency Low-Resource Mode)**
- .cursorrules only
- Core directives embedded in memory
- No file reads unless explicitly requested
- Use: When system is under load

**TIER 1: LIGHTWEIGHT (Worker Agent Default)**
- .cursorrules
- Global Policy SUMMARY (not full files)
- Project Brain only (most specific context)
- Ecosystem Brain: Load on explicit @INVOCATION only
- Use: SGL.Ai, TP.Gen, all worker agents

**TIER 2: STANDARD (CMD Default)**
- .cursorrules
- Full Global Policy files
- Master Routing Brain
- Ecosystem Brain (context-aware)
- Project Brain (if exists)
- Use: CMD.BRIDGE when working alone

**TIER 3: FULL (Single Session Only)**
- Everything in TIER 2
- All ecosystem brains for comparison
- Extended context
- Use: Deep system work, NO other agents active

---

## 📋 AGENT PROFILES

### Worker Agent Profile (LIGHTWEIGHT):
```ruby
agent_type: "worker"
resource_tier: "TIER-1"
workspace_pattern: "*/[PROJECT_NAME]"
load_on_startup:
  - .cursorrules
  - POLICY_SUMMARY (embedded below)
  - PROJECT.BRAIN.md (local context)
load_on_demand:
  - Ecosystem brain (via @LIGHTHOUSE/@SENTINEL/@ALCHEMIST)
  - Additional policies (via @POLICY)
skip:
  - Full Global Policy files (use summary instead)
  - Master Routing Brain (not needed for focused work)
```

**Embedded Policy Summary for Workers:**
```markdown
CORE DIRECTIVES (from Global Policy):
1. Use Sirius time ⧗-YY.DD in all v8sl headers
2. Respect role invocations (@/@!)
3. NEVER modify .3ox files (READ ONLY for workers)
4. Report to CMD.BRIDGE for config changes
5. Focus on project scope only
```

### CMD Agent Profile (STANDARD):
```ruby
agent_type: "cmd"
resource_tier: "TIER-2"
workspace_pattern: "P:\\!CMD.BRIDGE"
load_on_startup:
  - .cursorrules
  - All Global Policy files (full)
  - Master Routing Brain
  - Ecosystem brain (context-aware)
load_on_demand:
  - Other ecosystem brains (for comparison)
  - Project brains (when configuring specific projects)
multi_agent_aware: true
reduces_load_when:
  - Other agents detected active
```

---

## 🎯 MULTI-AGENT DETECTION

### How AI Detects Multi-Agent Scenario:

**Indicators:**
1. User mentions "other window" or "other agent"
2. User workspace path suggests worker agent (not CMD.BRIDGE)
3. User explicitly says "I have X agents open"
4. Context suggests focused project work (not system config)

**When Detected:**
- Automatically switch to TIER-1 (LIGHTWEIGHT)
- Skip full policy file reads
- Use embedded summaries
- Log: "Multi-agent mode: LIGHTWEIGHT loading active"

**Manual Override:**
- `@FULL.LOAD` - Force TIER-3 (use with caution)
- `@LIGHT.LOAD` - Force TIER-1 (conserve resources)
- `@POLICY` - Load specific policy on-demand

---

## 🔄 LOADING STRATEGIES

### Strategy 1: LAZY LOAD (Recommended)
**Principle:** Load only what's needed, when it's needed

```ruby
on_startup:
  - Load .cursorrules
  - Load embedded policy summary
  - Load PROJECT.BRAIN.md (if exists)
  
on_first_policy_question:
  - Load relevant Global Policy file (1 file, not all 5)
  
on_@INVOCATION:
  - Load invoked brain/role
  
on_system_work:
  - If workspace == CMD.BRIDGE → load full policies
```

### Strategy 2: CACHED SUMMARIES
**Principle:** Compress policies into decision trees

Instead of loading 5 full Global Policy files (5000+ tokens), use:
```markdown
POLICY DECISION TREE:
├─ Sirius time? → ⧗-YY.DD format, calculated from Aug 7, 2025
├─ Role invocation? → @/! commands trigger specific modes
├─ .3ox file operation? → READ ONLY if not CMD.BRIDGE
├─ File protection? → NEVER delete .3ox folders
└─ Access control? → Workers can't modify infrastructure
```

---

## 🛡️ CRASH PREVENTION RULES

### Rule 1: NEVER LOAD FULL POLICIES IN PARALLEL
- If 2+ agents active, ALL use TIER-1
- Only CMD in solo session gets TIER-2+
- User can override with explicit @FULL.LOAD

### Rule 2: DETECT AND THROTTLE
```ruby
if concurrent_agents > 1:
  resource_tier = "TIER-1"
  log("LIGHTWEIGHT mode: Multiple agents detected")
  
if concurrent_agents > 3:
  resource_tier = "TIER-0"
  warn("EMERGENCY mode: Too many agents, minimal loading")
```

### Rule 3: SMART ECOSYSTEM BRAIN LOADING
```ruby
# Old way (causes crashes):
Always load ecosystem brain based on file path

# New way (resource-aware):
if agent_type == "worker":
  skip_ecosystem_brain_unless_invoked()
  
if agent_type == "cmd" and multi_agent_scenario:
  load_ecosystem_brain_summary_only()
```

### Rule 4: PROJECT BRAIN PRIORITY
```ruby
# Most specific = most valuable
# Always load PROJECT.BRAIN.md (small, focused)
# Skip broader brains if resources constrained
```

---

## 📊 RESOURCE BUDGET

### Estimated Token Usage per Tier:

**TIER-0 (MINIMAL):**
- .cursorrules: ~500 tokens
- Embedded directives: ~200 tokens
- **Total: ~700 tokens per response**

**TIER-1 (LIGHTWEIGHT):**
- .cursorrules: ~500 tokens
- Policy summary: ~300 tokens
- PROJECT.BRAIN.md: ~500 tokens (avg)
- **Total: ~1,300 tokens per response**

**TIER-2 (STANDARD):**
- .cursorrules: ~500 tokens
- 5 Global Policies: ~4,000 tokens
- Master Routing: ~1,000 tokens
- Ecosystem Brain: ~1,500 tokens
- PROJECT.BRAIN.md: ~500 tokens
- **Total: ~7,500 tokens per response**

**TIER-3 (FULL):**
- Everything in TIER-2: ~7,500 tokens
- All ecosystem brains: +3,000 tokens
- **Total: ~10,500 tokens per response**

### Safe Multi-Agent Scenarios:

```
✅ SAFE:
3 agents × TIER-1 = 3,900 tokens (manageable)

⚠️ RISKY:
3 agents × TIER-2 = 22,500 tokens (approaching limits)

❌ CRASH:
3 agents × TIER-3 = 31,500 tokens (BOOM 💥)
```

---

## 🎭 AGENT-SPECIFIC CONFIGURATIONS

### SGL.Ai (SunsetGlow Worker):
```ruby
workspace: "SYNTH.BASE/SunsetGlow"
tier: "TIER-1"
loads:
  - .cursorrules
  - Policy summary
  - SunsetGlow/.3ox/PROJECT.BRAIN.md
focus: "Build SaaS features, ship code"
skips: "Global infrastructure, ecosystem brains"
```

### TP.Gen (Telegram Bridge Worker):
```ruby
workspace: "RVNx.BASE/!1N.3OX RVNX.BASE/!1N.3OX TP.Gen"
tier: "TIER-1"
loads:
  - .cursorrules
  - Policy summary
  - TP.Gen/.3ox/PROJECT.BRAIN.md
focus: "Telegram bot operations, message routing"
skips: "Global infrastructure, ecosystem brains"
```

### CMD.BRIDGE (Configuration Agent):
```ruby
workspace: "P:\\!CMD.BRIDGE"
tier: "TIER-2" (TIER-1 if multi-agent active)
loads:
  - .cursorrules
  - All Global Policies (full)
  - Master Routing Brain
  - Context-aware ecosystem brain
focus: "System config, .3ox file management"
authority: "Level 1 - Full access"
```

---

## ✅ IMPLEMENTATION CHECKLIST

### For AI to Follow:

On startup, AI must:
- [ ] Check workspace path
- [ ] Determine agent type (CMD vs Worker)
- [ ] Detect if multi-agent scenario (ask user or infer)
- [ ] Select appropriate resource tier
- [ ] Log loading tier for transparency
- [ ] Use lazy loading for policies
- [ ] Switch to lighter tier if user mentions other agents

### For Users:

When opening multiple agents:
- [ ] Tell each agent "I have X agents open" (triggers LIGHTWEIGHT mode)
- [ ] Use focused workspaces (SunsetGlow, TP.Gen, etc.)
- [ ] Reserve full policy loading for solo CMD.BRIDGE sessions
- [ ] Override with @LIGHT.LOAD or @FULL.LOAD if needed

---

## 🚨 EMERGENCY PROTOCOL

### If Crash Imminent (context overflow warnings):

1. **Immediate Actions:**
   ```
   - Switch ALL agents to TIER-0
   - Clear unnecessary context
   - Complete current task and pause
   - User closes least critical agent
   ```

2. **Recovery:**
   ```
   - Restart agents one at a time
   - Force TIER-1 on restart
   - Stagger work (one active, others idle)
   ```

3. **Prevention:**
   ```
   - Implement this policy immediately
   - Update .cursorrules to be resource-aware
   - Create agent-specific profiles
   - Test with 3 agents before production use
   ```

---

## 🌟 EXPECTED OUTCOMES

### With This Policy:

✅ **3 agents can work simultaneously** without crashes  
✅ **Each agent stays focused** on its domain  
✅ **CMD maintains full access** when needed  
✅ **Lazy loading** reduces token waste  
✅ **Transparent tier selection** (AI logs its choice)  
✅ **Manual overrides** available for power users  

### Without This Policy:

❌ Crashes when 3+ agents active  
❌ Wasted tokens loading unused policies  
❌ No awareness of resource constraints  
❌ Defeats multi-agent orchestration purpose  

---

## 📋 RELATED POLICIES

- `GLOBAL.POLICY.BRAIN.md` - Supreme authority
- `.3OX.ACCESS.POLICY.md` - Worker vs CMD access levels
- `MULTI-AGENT.ORCHESTRATION.PATTERN.md` - Why we use multiple agents

---

## 🎯 ENFORCEMENT

**Status:** MANDATORY (Global Policy #5)  
**Scope:** All agents, all scenarios  
**Override:** Only with explicit @FULL.LOAD command  

---

**Established:** ⧗-25.61 (October 7, 2025)  
**Authority:** Global Policy Standard  
**Version:** 1.0 - Multi-Agent Resource Management

//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙
```

