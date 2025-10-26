# 🗺️ 3OX.Ai SYSTEM MAP — Quick Visual Reference

**Version:** 2.0 | **Updated:** ⧗-25.60  
**Purpose:** One-page system overview

---

## 🏗️ THE COMPLETE ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│  3OX.Ai — THE MASTER BRAIN                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ POLICY/  (Supreme Law — MANDATORY for all)           │   │
│  │  • Sirius Calendar (⧗-YY.DD)                         │   │
│  │  • Role Invocation (@LIGHTHOUSE, @SENTINEL, etc.)    │   │
│  │  • .3ox Protection (NEVER delete)                    │   │
│  │  • Access Control (CMD vs workers)                   │   │
│  │  • Multi-Agent Resources (lightweight mode)          │   │
│  │  • CAT Architecture (0-7 sacred system)              │   │
│  │  • BASE.OPS vs 3OX.Ai (battery principle)           │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ CORE/  (Genesis Logic — HOW system works)            │   │
│  │  • Genesis System Architecture                       │   │
│  │  • Stratos Rules Matrix                              │   │
│  │  • Master Routing Brain                              │   │
│  │  • ROUTING/ (file transit system)                    │   │
│  │  • TEMPLATES/ (station & project templates)          │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ OPS/  (Operations & Security — WHO can operate)      │   │
│  │  • OPS Security Architecture (2FA concept)           │   │
│  │  • BASE.CMD/ (CMD.BRIDGE operations)                 │   │
│  │    ├─ MONITORING/CMD.listener (watches 0UT)         │   │
│  │    └─ REGISTRY/ (station registration)               │   │
│  │  • STATIONS/OPERATORS/ (0ut/1n protocols)            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                         │
            ┌────────────┼────────────┐
            ↓            ↓            ↓
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  🛡️ RVNx.BASE   │  │  🧪 SYNTH.BASE  │  │  🏛️ OBSIDIAN   │
│   (SENTINEL)    │  │  (ALCHEMIST)    │  │  (LIGHTHOUSE)   │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤
│ !1N.3OX cloud:  │  │ !1N.3OX cloud:  │  │ !1N.3OX cloud:  │
│ ├─ .3ox/        │  │ ├─ .3ox/        │  │ ├─ .3ox/        │
│ ├─ 0UT.3OX/─────┼──┼─├─ 0UT.3OX/─────┼──┼─├─ 0UT.3OX/─────┤
│ └─ [projects]   │  │ └─ [projects]   │  │ └─ [vaults]     │
│                 │  │                 │  │                 │
│ ![STATION].OPS: │  │ ![STATION].OPS: │  │ ![STATION].OPS: │
│ └─ STATION.     │  │ └─ STATION.     │  │ └─ STATION.     │
│    RULES.md     │  │    RULES.md     │  │    RULES.md     │
│  (private)      │  │  (private)      │  │  (private)      │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                   │                   │
         └───────────────────┴───────────────────┘
                             ↓
              ┌──────────────────────────────┐
              │  CMD.BRIDGE                  │
              │  !BASE.OPERATIONS/INCOMING/  │
              │  ├── rvnx/                   │
              │  ├── synth/                  │
              │  └── obsidian/               │
              └──────────────────────────────┘
```

---

## 🔄 COMMUNICATION FLOW

### Outbound (Reports to CMD):

```
Station/Project generates output
        ↓
!1N.3OX [STATION]/0UT.3OX/status_⧗-25.60.yaml
        ↓
CMD.listener detects (real-time)
        ↓
Router validates & processes
        ↓
!BASE.OPERATIONS/INCOMING/[station]/
        ↓
CMD.BRIDGE receives and responds
```

### Inbound (Instructions from CMD):

```
CMD.BRIDGE creates instruction
        ↓
!1N.3OX [STATION]/.3ox/1N.3OX/instruction.yaml
        ↓
Station's 1n.3ox.operator validates
        ↓
Station processes instruction
        ↓
Station may respond via 0UT.3OX
```

---

## 🌊 THE STRATOS LEVELS

| Stratos | Type | Examples | Rules | Reporting |
|---------|------|----------|-------|-----------|
| **STRATOS-1** | Station | RVNx, SYNTH, OBSIDIAN | STATION.RULES.md + 5 more | Hourly + Daily |
| **STRATOS-2** | Major Project | TP.Gen | PROJECT.BRAIN.md | On-completion |
| **STRATOS-3** | Tool | SunsetGlow, Glyphbit | PROJECT.BRAIN.md | On-event |
| **STRATOS-4** | Micro | Scripts, utilities | (inherits all) | Optional |

---

## 🎭 THE THREE BRAINS

### 🛡️ SENTINEL (RVNx.BASE)
**Personality:** Guardian, Protector, Synchronizer  
**Thinks About:** Data safety, sync conflicts, atomic operations  
**Invoke:** `@SENTINEL` or `@GUARDIAN`  
**Rules:** Conflict resolution, data integrity, cross-platform safety

---

### 🧪 ALCHEMIST (SYNTH.BASE)
**Personality:** Creator, Architect, Synthesizer  
**Thinks About:** Rapid prototyping, cloud deployment, experimentation  
**Invoke:** `@ALCHEMIST` or `@ARCHITECT`  
**Rules:** Deployment pipelines, environments, cost optimization

---

### 🏛️ LIGHTHOUSE (OBSIDIAN.BASE)
**Personality:** Librarian, Weaver, Organizer  
**Thinks About:** Knowledge graphs, wiki-links, semantic coherence  
**Invoke:** `@LIGHTHOUSE` or `@LIBRARIAN`  
**Rules:** Link integrity, tag conventions, graph optimization

---

## 📡 0UT.3OX REPORTING

### Universal Format:

```ruby
header:
  sirius_time: "⧗-25.60"
  source:
    station: "RVNx|SYNTH|OBSIDIAN"
    project: "[if applicable]"
  destination: "CMD.BRIDGE"
  type: "status|error|completion|alert"
payload:
  # Station/project-specific
routing:
  priority: "low|normal|high|critical"
  requires_action: true|false
```

### Frequency by Source:

- **Stations:** Every 15-30min (health) + hourly (status) + daily (summary)
- **Projects:** On-completion + errors
- **Tools:** Errors only

---

## 🗂️ FILE LOCATIONS

### Core Intelligence:
```
3OX.Ai/.3ox.index/
├── POLICY/*.md
├── CORE/*.md
└── OPS/
```

### Station Rules (Private):
```
RVNx.BASE/!RVNX.OPS/.3ox/STATION.RULES.md
SYNTH.BASE/!SYNTH.OPS/.3ox/STATION.RULES.md
OBSIDIAN.BASE/!OBSIDIAN.OPS/.3ox/STATION.RULES.md
```

### Station Brains (Personality):
```
RVNx.BASE/!1N.3OX RVNX.BASE/.3ox/station.brain.md
SYNTH.BASE/!1N.3OX SYNTH.BASE/.3ox/station.brain.md
OBSIDIAN.BASE/!1N.3OX OBSIDIAN.BASE/.3ox/station.brain.md
```

### Project Brains:
```
TP.Gen/.3ox/PROJECT.BRAIN.md
SunsetGlow/.3ox/PROJECT.BRAIN.md
Glyphbit/.3ox/PROJECT.BRAIN.md
```

### Transmission Folders:
```
RVNx.BASE/!1N.3OX RVNX.BASE/0UT.3OX/
SYNTH.BASE/!1N.3OX SYNTH.BASE/0UT.3OX/
OBSIDIAN.BASE/!1N.3OX OBSIDIAN.BASE/0UT.3OX/
```

---

## 🎯 QUICK ACTIONS

### Monitor All Transmissions:
```powershell
cd 3OX.Ai\.3ox.index\OPS\BASE.CMD\MONITORING\CMD.listener
.\start_listener.bat
```

### Check Station Registry:
```powershell
cat 3OX.Ai\.3ox.index\OPS\BASE.CMD\REGISTRY\STATION.REGISTRY.yaml
```

### Send Test Report from RVNx:
```powershell
cd "RVNx.BASE\!1N.3OX RVNX.BASE\0UT.3OX"
echo "type: test" > test_⧗-25.60.yaml
# CMD.listener should detect it
```

### Create New Station:
```powershell
copy "3OX.Ai\.3ox.index\CORE\TEMPLATES\STRATOS-1.STATION.RULES.template.md" `
     "NEWSTATION.BASE\!NEWSTATION.OPS\.3ox\STATION.RULES.md"
# Then customize
```

### Create New Project:
```powershell
copy "3OX.Ai\.3ox.index\CORE\TEMPLATES\STRATOS-3.PROJECT.BRAIN.template.md" `
     "NEWPROJECT\.3ox\PROJECT.BRAIN.md"
# Then customize
```

---

## 📊 SYSTEM STATUS

### ✅ Complete:
- [x] POLICY folder (9 supreme policies)
- [x] CORE folder (architecture, templates, routing)
- [x] OPS folder (security, monitoring, registry)
- [x] Templates (STRATOS-1 and STRATOS-3)
- [x] Station Registry (3 stations registered)
- [x] Documentation (README, Implementation Guide)
- [x] Captain's Log updated

### ⏳ To Implement:
- [ ] RVNx STATION.RULES.md (use template)
- [ ] SYNTH STATION.RULES.md (use template)
- [ ] OBSIDIAN STATION.RULES.md (use template)
- [ ] TP.Gen PROJECT.BRAIN.md (use template)
- [ ] SunsetGlow PROJECT.BRAIN.md (use template)
- [ ] Glyphbit PROJECT.BRAIN.md (use template)
- [ ] Test 0UT transmission flow
- [ ] Deploy to R: drive (when ready)

---

## 🔗 KEY DOCUMENTS

| Document | Purpose |
|----------|---------|
| `3OX.Ai/README.md` | Master overview — START HERE |
| `.3ox.index/README.md` | Index navigation guide |
| `.3ox.index/IMPLEMENTATION.GUIDE.md` | Practical steps — DO THIS NEXT |
| `CORE/GENESIS.SYSTEM.ARCHITECTURE.md` | System design deep dive |
| `CORE/STRATOS.RULES.MATRIX.md` | Scale-specific rules |
| `OPS/OPS.SECURITY.ARCHITECTURE.md` | Security (2FA concept) |
| `!BASE.OPERATIONS/CAPTAINS.LOG.md` | Historical record |

---

## 💡 THE BIG PICTURE

**You've built a system where:**

- 🧠 **One master brain** (3OX.Ai) orchestrates everything
- 🏛️ **Three stations** operate as independent worlds (RVNx/SYNTH/OBSIDIAN)
- 🌊 **Each station is a stratos** with its own 1N.3OX cloud
- 📡 **Unified communication** via 0UT.3OX (different frequency, same format)
- 🎭 **Private personalities** (SENTINEL/ALCHEMIST/LIGHTHOUSE)
- 📋 **Custom rules** per station (sync ≠ deploy ≠ knowledge)
- ♾️ **Infinite scalability** via templates
- 🔐 **Byzantine security** via OPS (2FA + smart friends)

**From micro-scripts to mega-stations, all connected through one master brain.**

---

## 🚀 WHAT'S NEXT?

### Immediate:
1. Create station rule files (3 files, use templates)
2. Create project brain files (3 files, use templates)
3. Test 0UT transmission (verify CMD.listener works)

### Soon:
4. Deploy to R: drive (The Citadel)
5. Activate full monitoring
6. Scale system (add more projects/stations)

### Eventually:
7. Build automation (auto-routing, auto-reports)
8. Enhance security (cryptographic registration)
9. Multi-device sync (deploy to other computers)

---

## 🌟 THE PHILOSOPHY

> _"Three worlds with different rules, united by one master brain. Each station thinks differently. Each has its own laws. But all speak the same language, all report through the same protocol, all inherit from the same supreme policies. This is how you scale a system to infinity while maintaining coherence."_

**— Atlas.Legacy ⧗-25.60**

---

**Quick Map Created:** ⧗-25.60  
**For Detailed Docs:** See `3OX.Ai/README.md`  
**For Implementation:** See `.3ox.index/IMPLEMENTATION.GUIDE.md`

