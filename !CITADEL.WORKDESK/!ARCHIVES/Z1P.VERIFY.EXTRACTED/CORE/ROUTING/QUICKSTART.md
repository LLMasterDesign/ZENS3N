# 3OX.Ai Routing System - Quick Start
**⧗-25.61 | Operational**

---

## 🎯 What This System Does

1. **FILE.STATE.LOG** - Read logs instead of scanning files (saves resources)
2. **0ut.3ox** - Output files from stations automatically route to BASE.OPS
3. **No storage in 3OX.Ai** - Pure transit, perfect implementation reference

---

## ⚡ Quick Commands

### Route Files (Transit from Stations → BASE.OPS)
```powershell
python 3OX.Ai\.3ox.index\CORE\ROUTING\router.py
```

### Detect Files (Check what arrived in BASE.OPS)
```powershell
python !BASE.OPERATIONS\detector.py
```

### Check Status
```powershell
# View central tracking
cat !BASE.OPERATIONS\INCOMING\REGISTRY.LOG

# Check pending files
cat RVNx.BASE\0ut.3ox\FILE.MANIFEST.txt | findstr "READY"

# List received files
ls !BASE.OPERATIONS\INCOMING\rvnx\
```

---

## 📤 How to Send Files from a Station

### Step 1: Create your output file
```
RVNx.BASE/0ut.3ox/my-report.md
```

### Step 2: Add to manifest
Edit `RVNx.BASE/0ut.3ox/FILE.MANIFEST.txt`:
```
[2025-10-07 15:00:00] | READY | my-report.md | INCOMING/rvnx | HIGH
```

### Step 3: Route it
```powershell
python 3OX.Ai\.3ox.index\CORE\ROUTING\router.py
```

### Result:
- ✅ File moved to `!BASE.OPERATIONS/INCOMING/rvnx/my-report.md`
- ✅ Original archived to `0ut.3ox/.SENT/2025-10-07/`
- ✅ Logged in REGISTRY.LOG
- ✅ Status updated to SENT

---

## 📥 How to Track Incoming Files

### Run detector once:
```powershell
python !BASE.OPERATIONS\detector.py
```

### Watch mode (continuous):
```powershell
python !BASE.OPERATIONS\detector.py --watch 5
```

### Check registry:
```powershell
cat !BASE.OPERATIONS\INCOMING\REGISTRY.LOG
```

---

## 🗂️ Structure

```
3OX.Ai/.3ox.index/CORE/ROUTING/
├── README.md                    ← Full documentation
├── QUICKSTART.md               ← This file
├── FILE.STATE.LOG.SPEC.md      ← State tracking format
├── 0UT.3OX.PROTOCOL.SPEC.md    ← Routing protocol
├── router.py                   ← Transit orchestrator
└── STATIONS/                   ← Registry of connected stations
    ├── RVNx.BASE.routing
    ├── OBSIDIAN.BASE.routing
    └── SYNTH.BASE.routing

[STATION]/
├── .3ox/
│   └── FILE.STATE.LOG          ← Read this instead of scanning files
└── 0ut.3ox/
    ├── FILE.MANIFEST.txt       ← What to send
    ├── [your-files]            ← Output files
    └── .SENT/                  ← Archive

!BASE.OPERATIONS/
├── detector.py                 ← Monitors incoming files
└── INCOMING/
    ├── rvnx/                   ← From RVNx.BASE
    ├── obsidian/               ← From OBSIDIAN.BASE
    ├── synth/                  ← From SYNTH.BASE
    └── REGISTRY.LOG            ← Central tracking
```

---

## ✅ Tested Example

**Test file:** `RVNx.BASE/0ut.3ox/SYSTEM.STATUS.REPORT.md`

1. ✅ Added to manifest with STATUS=READY
2. ✅ Ran router.py → Transited to BASE.OPS
3. ✅ Ran detector.py → Detected and logged
4. ✅ File archived to .SENT/2025-10-07/
5. ✅ Full audit trail in REGISTRY.LOG

**System works!** 🎉

---

## 🔗 Connected Stations

- **RVNx.BASE** → INCOMING/rvnx (Priority: HIGH)
- **OBSIDIAN.BASE** → INCOMING/obsidian (Priority: MEDIUM)
- **SYNTH.BASE** → INCOMING/synth (Priority: MEDIUM)

View configs: `3OX.Ai/.3ox.index/CORE/ROUTING/STATIONS/*.routing`

---

## 🛡️ Loop Prevention

✓ One-way flow: Station → CMD → BASE.OPS  
✗ Never syncs back to stations  
✗ 3OX.Ai doesn't store files (transit only)  
✗ BASE.OPS never syncs to local drives

See: `!BASE.OPERATIONS/!WHY.THIS.EXISTS.txt`

---

## 📚 Full Docs

Read: `3OX.Ai/.3ox.index/CORE/ROUTING/README.md`

---

**Status:** Operational ⧗-25.61  
**Authority:** 3OX.Ai Core Routing System

