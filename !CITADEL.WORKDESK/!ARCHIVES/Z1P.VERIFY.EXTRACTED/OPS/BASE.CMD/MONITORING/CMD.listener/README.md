# CMD.BRIDGE Background Listener

**Purpose:** Monitor 0ut.3ox and 1n.3ox transactions across all STRATOS stations in real-time  
**Status:** Optional background utility  
**Authority:** CMD.BRIDGE Level 1 (L1) only

---

## 🎯 What This Does

Watches the entire `P:/!CMD.BRIDGE/` directory for 0ut.3ox and 1n.3ox file changes and logs them to centralized transaction logs.

**Logs saved to:**
- `!BASE.OPERATIONS/LOGS/0ut.3ox.transactions.log` (outgoing)
- `!BASE.OPERATIONS/LOGS/1n.3ox.transactions.log` (incoming)

---

## 🚀 When to Use

### ✅ Use the Listener When:
- You want **real-time monitoring** of all station transactions
- You need **continuous logging** without manual intervention
- You're debugging transaction flow issues
- You want to track when files appear in 0ut.3ox folders

### ❌ DON'T Use the Listener When:
- Working with **multiple Cursor instances** (resource heavy)
- You only need **on-demand routing** (use `router.py` instead)
- You're in a **resource-constrained environment**

---

## 🛠️ How to Run

### Start the Listener:
```powershell
# From CMD.BRIDGE root:
3OX.Ai\.3ox.index\OPS\L3\CMD.listener\start_listener.bat

# Or directly:
cd 3OX.Ai\.3ox.index\OPS\L3\CMD.listener
python listener.py
```

### Stop the Listener:
- Press `Ctrl+C` in the terminal

---

## 📋 What Gets Logged

### Transaction Log Format:
```
[TX] ⧗-25.61 - CREATED: RVNx.BASE/0ut.3ox/report.yaml
  Data: {
    "type": "status_report",
    "station": "RVNx.BASE",
    "timestamp": "2025-10-07T14:23:15"
  }

[RX] ⧗-25.61 - MODIFIED: SYNTH.BASE/1n.3ox/config.yaml
```

---

## ⚖️ Listener vs Router

There are **two different systems** for handling 0ut.3ox files:

### 1. **Listener (This Script)** - Real-time Logging Only
- **What:** Watches and logs transactions  
- **Where:** Runs at CMD.BRIDGE  
- **When:** Background continuous monitoring  
- **Output:** Transaction logs only  
- **Use Case:** Debugging, monitoring, audit trails

### 2. **Router (`ROUTING/router.py`)** - File Transit
- **What:** Actually moves files from stations to BASE.OPS  
- **Where:** Runs at CMD.BRIDGE  
- **When:** On-demand or scheduled  
- **Output:** Files moved to `!BASE.OPERATIONS/INCOMING/`  
- **Use Case:** Production file routing

**They work together:**
- Listener logs when files appear in 0ut.3ox
- Router moves those files to BASE.OPS
- Both create audit trails

---

## 🏛️ Architecture

```
P:/!CMD.BRIDGE/                     (listener watches this)
├── RVNx.BASE/
│   ├── 0ut.3ox/                    ← Monitored
│   └── 1n.3ox/                     ← Monitored
├── SYNTH.BASE/
│   ├── 0ut.3ox/                    ← Monitored
│   └── 1n.3ox/                     ← Monitored
├── OBSIDIAN.BASE/
│   ├── 0ut.3ox/                    ← Monitored
│   └── 1n.3ox/                     ← Monitored
└── !BASE.OPERATIONS/
    └── LOGS/
        ├── 0ut.3ox.transactions.log ← Output
        └── 1n.3ox.transactions.log  ← Output
```

---

## ⚠️ Important Rules

### 🚫 DO NOT Deploy to STRATOS Stations

**This script runs ONLY at CMD.BRIDGE (L1)**, never at individual stations:

- ❌ Don't put this in RVNx.BASE
- ❌ Don't put this in SYNTH.BASE
- ❌ Don't put this in OBSIDIAN.BASE
- ✅ Only run from CMD.BRIDGE

**Why?**
- **Resource Efficiency**: One listener monitors all stations
- **Multi-Agent Safe**: Prevents redundant background processes
- **Centralized Logging**: Single source of truth
- **Architecture**: CMD observes, stations work

### 📜 Rule #1 Compliance

This listener is designed to be **optional** and **single-instance**:
- Use in single-agent scenarios when deep monitoring is needed
- Skip in multi-agent scenarios (too resource heavy)
- Always run from CMD.BRIDGE only

---

## 🔧 Dependencies

Install required packages:
```powershell
pip install -r requirements.txt
```

**Required:**
- `watchdog` - File system monitoring
- `pyyaml` - YAML parsing

---

## 📊 Resource Usage

- **CPU:** Low (idle most of time, spikes on file changes)
- **Memory:** ~50-100 MB
- **Disk I/O:** Minimal (append-only logs)

**Multi-Agent Impact:**
- If running 3+ Cursor instances, skip this listener
- Use on-demand `router.py` instead for resource efficiency

---

## 🔗 Related Systems

- **`ROUTING/router.py`** - File transit orchestrator
- **`!BASE.OPERATIONS/detector.py`** - Incoming file detector
- **`ROUTING/README.md`** - Full routing system documentation

---

**Last Updated:** ⧗-25.61  
**Authority:** CMD.BRIDGE Operations  
**Status:** Operational (optional utility)

