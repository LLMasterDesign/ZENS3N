```r
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // AGENT.PROFILES ▞▞
▞//▞ Agent.Profiles :: ρ{multi.agent.config}.φ{CORE}.τ{Reference}.λ{profiles} ⫸
▙⌱[👥] ≔ [⊢{agents}⇨{configure}⟿{optimize}▷{no.crash}]
〔atlas.legacy.agent.profiles〕 :: ∎

# 👥 AGENT PROFILES - MULTI-AGENT CONFIGURATION

**Purpose:** Define optimal loading configurations for each agent type  
**Version:** 1.0  
**Date:** ⧗-25.61  
**Authority:** Core system reference

---

## 🎯 AGENT TYPES

### 1. CMD.BRIDGE (Configuration Agent)
**Workspace:** `P:\!CMD.BRIDGE`  
**Role:** System architect, infrastructure manager  
**Access Level:** Level 1 (Full access to .3ox files)

#### Loading Profile:
```ruby
resource_tier: "TIER-2" # TIER-1 if multi-agent active
load_on_startup:
  - .cursorrules
  - Full Global Policy files (all 6)
  - Master Routing Brain
  - Context-aware ecosystem brain
  - Captain's Log (read recent entries)
load_on_demand:
  - Other ecosystem brains (for comparison)
  - Project brains (when configuring projects)
  - STRATOS rules (when managing stations)
focus:
  - System architecture
  - .3ox file management
  - Multi-agent orchestration
  - Global policy enforcement
skip_when_multi_agent:
  - Ecosystem brains (use summaries)
  - Extended context files
```

#### Capabilities:
- ✅ Modify .3ox files
- ✅ Update global policies
- ✅ Configure all projects
- ✅ Manage station operations
- ✅ Log to Captain's Log

#### Typical Tasks:
- Create/update PROJECT.BRAIN.md files
- Configure agent routing
- Update system policies
- Orchestrate multi-agent workflows
- Monitor system health

---

### 2. SGL.Ai (SunsetGlow Worker)
**Workspace:** `P:\!CMD.BRIDGE\SYNTH.BASE\SunsetGlow`  
**Role:** SaaS application builder  
**Access Level:** Level 3 (Read-only .3ox)

#### Loading Profile:
```ruby
resource_tier: "TIER-1" # Always lightweight
load_on_startup:
  - .cursorrules (embedded policy summary only)
  - SunsetGlow/.3ox/PROJECT.BRAIN.md
  - Local state files
load_on_demand:
  - @ALCHEMIST brain (if explicitly needed)
  - @POLICY (if policy question arises)
focus:
  - Build SunsetGlow features
  - Ship production code
  - User experience
  - Technical implementation
never_load:
  - Full Global Policy files
  - Master Routing Brain
  - Other ecosystem brains
  - System-wide infrastructure
```

#### Capabilities:
- ✅ Read PROJECT.BRAIN.md
- ✅ Build SunsetGlow code
- ✅ Create feature implementations
- ❌ Modify .3ox files (report to CMD)
- ❌ Change global policies

#### Typical Tasks:
- Implement resume processing features
- Build UI components
- Write API endpoints
- Handle database operations
- Deploy features to production

---

### 3. TP.Gen (Telegram Bridge Worker)
**Workspace:** `P:\!CMD.BRIDGE\RVNx.BASE\!1N.3OX RVNX.BASE\!1N.3OX TP.Gen`  
**Role:** Telegram bot operations and routing  
**Access Level:** Level 3 (Read-only .3ox)

#### Loading Profile:
```ruby
resource_tier: "TIER-1" # Always lightweight
load_on_startup:
  - .cursorrules (embedded policy summary only)
  - TP.Gen/.3ox/PROJECT.BRAIN.md
  - TP.Gen/.3ox/.3ox.map (routing rules)
load_on_demand:
  - @SENTINEL brain (if sync issues arise)
  - @POLICY (if policy question arises)
focus:
  - Telegram message routing
  - Command parsing
  - Queue file management
  - Bot response generation
never_load:
  - Full Global Policy files
  - Master Routing Brain
  - Other ecosystem brains
  - System-wide infrastructure
```

#### Capabilities:
- ✅ Read PROJECT.BRAIN.md
- ✅ Handle Telegram commands
- ✅ Route messages to agents
- ✅ Generate queue files
- ❌ Modify .3ox files (report to CMD)
- ❌ Change routing infrastructure

#### Typical Tasks:
- Parse /cmd, /sgl, /tp commands
- Write queue YAML files
- Read status responses
- Reply to Telegram messages
- Log operations

---

### 4. OBSIDIAN.Worker (Knowledge Management)
**Workspace:** `P:\!CMD.BRIDGE\OBSIDIAN.BASE\[vault]`  
**Role:** PKM, note-taking, knowledge organization  
**Access Level:** Level 3 (Read-only .3ox)

#### Loading Profile:
```ruby
resource_tier: "TIER-1" # Always lightweight
load_on_startup:
  - .cursorrules (embedded policy summary only)
  - Vault/.3ox/PROJECT.BRAIN.md (if exists)
  - LIGHTHOUSE thinking summary
load_on_demand:
  - @LIGHTHOUSE brain (full version)
  - @POLICY (if policy question arises)
focus:
  - Markdown formatting
  - Wiki-link creation
  - Knowledge graph connections
  - Note organization
never_load:
  - Full Global Policy files
  - Master Routing Brain
  - Other ecosystem brains
```

#### Capabilities:
- ✅ Create/edit markdown notes
- ✅ Generate wiki-links
- ✅ Organize knowledge structure
- ❌ Modify .3ox files (report to CMD)

---

### 5. RVNx.Worker (Sync Operations)
**Workspace:** `P:\!CMD.BRIDGE\RVNx.BASE\[sync-target]`  
**Role:** Remote access, sync safety, file operations  
**Access Level:** Level 3 (Read-only .3ox)

#### Loading Profile:
```ruby
resource_tier: "TIER-1" # Always lightweight
load_on_startup:
  - .cursorrules (embedded policy summary only)
  - Project/.3ox/PROJECT.BRAIN.md (if exists)
  - SENTINEL thinking summary
load_on_demand:
  - @SENTINEL brain (full version)
  - @POLICY (if policy question arises)
focus:
  - Sync safety protocols
  - Atomic operations
  - Remote access security
  - File integrity
never_load:
  - Full Global Policy files
  - Master Routing Brain
  - Other ecosystem brains
```

#### Capabilities:
- ✅ Plan sync operations
- ✅ Verify file integrity
- ✅ Handle remote access
- ❌ Modify .3ox files (report to CMD)

---

## 📊 RESOURCE USAGE COMPARISON

### Single Agent (FULL mode):
```
CMD.BRIDGE alone:
├─ Loads: 6 policies + routing + ecosystem + project
├─ Tokens: ~7,500 per response
└─ Status: ✅ Safe (within limits)
```

### Multi-Agent (OLD - caused crash):
```
3 agents × FULL mode:
├─ Agent 1: 7,500 tokens
├─ Agent 2: 7,500 tokens
├─ Agent 3: 7,500 tokens
├─ Total: 22,500 tokens
└─ Status: 💥 CRASH (context overflow)
```

### Multi-Agent (NEW - safe):
```
3 agents × LIGHTWEIGHT mode:
├─ Agent 1: 1,300 tokens
├─ Agent 2: 1,300 tokens
├─ Agent 3: 1,300 tokens
├─ Total: 3,900 tokens
└─ Status: ✅ Safe (85% reduction)
```

---

## 🎯 USAGE GUIDE

### For Users:

**When opening multiple agents:**
1. Tell each agent: "I have 3 agents open"
2. Agent automatically switches to LIGHTWEIGHT mode
3. Work as normal - agents stay focused

**When working solo with CMD:**
1. Just open CMD.BRIDGE
2. Agent uses FULL mode automatically
3. Full access to all policies and brains

**Manual overrides:**
- `@LIGHTWEIGHT` - Force lightweight mode
- `@FULL.LOAD` - Force full loading (careful!)
- `@POLICY` - Load specific policy on-demand
- `@LIGHTHOUSE/@SENTINEL/@ALCHEMIST` - Load ecosystem brain

### For AI:

**Detection logic:**
```python
if "I have X agents open" in user_message:
    mode = "LIGHTWEIGHT"
elif workspace != "P:\\!CMD.BRIDGE":
    mode = "LIGHTWEIGHT"
elif user says "@FULL.LOAD":
    mode = "FULL"
else:
    mode = "TIER-2" # Standard CMD mode
```

**Logging:**
Always log your choice for transparency:
```
[LIGHTWEIGHT MODE: Multi-agent safe loading active]
[FULL MODE: Solo agent, deep work]
[TIER-2 MODE: Standard CMD operations]
```

---

## 🔄 WORKFLOW EXAMPLES

### Example 1: Building SunsetGlow while CMD configures
```
Screen: [CMD.BRIDGE] [SGL.Ai] [Terminal]

User to CMD: "Update SGL.Ai's PROJECT.BRAIN.md to focus on resume parsing"
CMD: Loads FULL policies, updates .3ox file, logs to Captain's Log

User to SGL: "Build the resume parser endpoint"
SGL: Loads LIGHTWEIGHT, reads PROJECT.BRAIN.md, builds feature

Result: ✅ No crash, both agents focused
```

### Example 2: Three agents working simultaneously
```
Screen: [CMD] [SGL.Ai] [TP.Gen]

User opens all 3, says: "I have 3 agents running"

CMD: Switches to LIGHTWEIGHT (TIER-1)
SGL: Already LIGHTWEIGHT by default
TP: Already LIGHTWEIGHT by default

All 3 work without crashes
```

### Example 3: Solo deep system work
```
Screen: [CMD.BRIDGE only]

User: "Review and update all Global Policies"

CMD: Detects solo session, loads FULL mode
CMD: Reads all 6 policy files, full routing brain, ecosystem brains
CMD: Makes comprehensive system changes

Result: ✅ Full context available, no other agents to compete with
```

---

## 🛡️ SAFETY RULES

1. **Never load FULL mode with 2+ agents active**
2. **Always prioritize PROJECT.BRAIN.md** (most specific context)
3. **Log resource tier choice** (transparency)
4. **Workers default to LIGHTWEIGHT** (never full mode)
5. **CMD adapts to scenario** (FULL when alone, LIGHTWEIGHT when crowded)

---

## 📋 QUICK REFERENCE

| Agent | Default Tier | Workspace Pattern | Key Focus |
|-------|-------------|-------------------|-----------|
| CMD.BRIDGE | TIER-2 (TIER-1 if multi) | `P:\!CMD.BRIDGE` | System config |
| SGL.Ai | TIER-1 | `*/SunsetGlow` | Build SaaS |
| TP.Gen | TIER-1 | `*/TP.Gen` | Telegram routing |
| OBSIDIAN.Worker | TIER-1 | `OBSIDIAN.BASE/*` | Knowledge mgmt |
| RVNx.Worker | TIER-1 | `RVNx.BASE/*` | Sync operations |

---

**Established:** ⧗-25.61 (October 7, 2025)  
**Version:** 1.0  
**Status:** Active reference for all agents

//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙
```

