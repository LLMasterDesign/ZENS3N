///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // SPEC ▞▞
▞//▞ 0ut.3ox Protocol :: ρ{file-routing}.φ{transit}.τ{specification}.λ{core} ⫸
▙⌱📤 ≔ [⊢{station-output}⇨{transit}⟿{route}▷{base-ops}]
〔3OX.Ai.core.routing〕 :: ∎

# 0ut.3ox Routing Protocol Specification

## Purpose
Define how files leave stations, transit through CMD.BRIDGE, and arrive at !BASE.OPERATIONS for detection and tracking. **Files never stored in 3OX.Ai** - it only orchestrates routing.

## Architecture Overview

```
[STATION]/0ut.3ox/
    ├── FILE.MANIFEST.txt      ← What to send
    ├── [output-files]          ← Files ready for transit
    └── .SENT/                  ← Archive of sent files
         ↓
    (Transit via CMD.BRIDGE - no storage)
         ↓
!BASE.OPERATIONS/INCOMING/[station-name]/
    ├── [received-files]
    └── REGISTRY.LOG           ← Central tracking
```

## Station Structure

### Location:
```
[STATION]/0ut.3ox/
```

Examples:
- `RVNx.BASE/0ut.3ox/`
- `OBSIDIAN.BASE/0ut.3ox/`
- `SYNTH.BASE/0ut.3ox/`

### Required Files:

#### FILE.MANIFEST.txt
Lists files ready for transit to !BASE.OPERATIONS.

Format:
```
# FILE.MANIFEST.txt
# Station: RVNx.BASE
# Created: ⧗-25.61
# Purpose: Declares files ready for transit to BASE.OPS

[TIMESTAMP] | STATUS | FILEPATH | DESTINATION | PRIORITY

[2025-10-07 15:00:00] | READY | status-report.md | INCOMING/rvnx | HIGH
[2025-10-07 15:05:00] | READY | sync-log.txt | INCOMING/rvnx | MEDIUM
[2025-10-07 15:10:00] | SENT | analysis.pdf | INCOMING/rvnx | LOW
```

**Field Definitions:**
- **TIMESTAMP**: When file was added to manifest
- **STATUS**: READY (pending) | TRANSIT (in-progress) | SENT (completed) | ERROR
- **FILEPATH**: Relative path within 0ut.3ox/
- **DESTINATION**: Target folder in !BASE.OPERATIONS
- **PRIORITY**: HIGH | MEDIUM | LOW (routing priority)

### Output Files:
Place actual files in `0ut.3ox/` alongside manifest:
```
0ut.3ox/
├── FILE.MANIFEST.txt
├── status-report.md      ← Actual file
├── sync-log.txt          ← Actual file
└── analysis.pdf          ← Actual file
```

### Archive After Send:
```
0ut.3ox/.SENT/
├── 2025-10-07/
│   ├── status-report.md
│   └── sync-log.txt
```

## BASE.OPERATIONS Structure

### Incoming Files:
```
!BASE.OPERATIONS/INCOMING/
├── rvnx/              ← From RVNx.BASE
│   ├── status-report.md
│   └── sync-log.txt
├── obsidian/          ← From OBSIDIAN.BASE
│   └── kb-export.md
├── synth/             ← From SYNTH.BASE
│   └── experiment-results.json
└── REGISTRY.LOG       ← Central tracking
```

### REGISTRY.LOG Format:
```
# REGISTRY.LOG
# Location: !BASE.OPERATIONS/INCOMING/
# Purpose: Central tracking of all station outputs
# Updated: ⧗-25.61

[TIMESTAMP] | STATION | FILENAME | SIZE | STATUS | NOTES

[2025-10-07 15:01:00] | rvnx | status-report.md | 4096 | RECEIVED | OK
[2025-10-07 15:06:00] | rvnx | sync-log.txt | 2048 | RECEIVED | OK
[2025-10-07 15:15:00] | obsidian | kb-export.md | 8192 | RECEIVED | OK
[2025-10-07 15:20:00] | synth | experiment.json | 1024 | ERROR | Invalid JSON
```

## Routing Process

### Step 1: Station Prepares Output
```python
# AI agent in RVNx.BASE
1. Generate output file: "status-report.md"
2. Place in: RVNx.BASE/0ut.3ox/status-report.md
3. Update manifest: Add entry with STATUS=READY
4. Update .3ox/FILE.STATE.LOG (for tracking)
```

### Step 2: Transit Trigger
```python
# Automated (via Python watcher) or manual
router.py detects new READY entries in FILE.MANIFEST.txt
```

### Step 3: CMD.BRIDGE Routes (No Storage)
```python
# router.py (in 3OX.Ai)
1. Read manifest from RVNx.BASE/0ut.3ox/FILE.MANIFEST.txt
2. Update STATUS=TRANSIT
3. Move file: RVNx.BASE/0ut.3ox/X → !BASE.OPERATIONS/INCOMING/rvnx/X
4. Update STATUS=SENT
5. Log to REGISTRY.LOG
6. Archive to .SENT/
```

### Step 4: BASE.OPS Detection
```python
# Detection script monitors !BASE.OPERATIONS/INCOMING/
1. New file detected in INCOMING/rvnx/
2. Log to REGISTRY.LOG
3. Trigger any downstream processing (optional)
```

## 3OX.Ai Station Registry

3OX.Ai maintains a registry of connected stations without storing their files.

### Location:
```
3OX.Ai/.3ox.index/CORE/ROUTING/STATIONS/
├── RVNx.BASE.routing
├── OBSIDIAN.BASE.routing
└── SYNTH.BASE.routing
```

### Station Routing File Format:
```ruby
# RVNx.BASE.routing
station_name: RVNx.BASE
station_path: P:/!CMD.BRIDGE/RVNx.BASE
output_folder: 0ut.3ox
manifest_file: 0ut.3ox/FILE.MANIFEST.txt
destination: INCOMING/rvnx
priority: HIGH
enabled: true
last_sync: ⧗-25.61
notes: Primary sync station for remote access
```

## Implementation Scripts

### router.py (in 3OX.Ai)
Orchestrates transit from stations to BASE.OPS:
```python
# Pseudocode
def route_files():
    for station in load_stations():
        manifest = read_manifest(station)
        for file in manifest.get_ready_files():
            move_to_base_ops(file, station)
            update_manifest_status(file, "SENT")
            log_to_registry(file, station)
            archive_file(file, station)
```

### watcher.py (Optional)
Watches 0ut.3ox folders for changes and triggers routing:
```python
# Monitors FILE.MANIFEST.txt in all stations
# Triggers router.py when READY entries detected
```

### detector.py (in BASE.OPS)
Monitors INCOMING/ for new files:
```python
# Watches !BASE.OPERATIONS/INCOMING/
# Logs new arrivals to REGISTRY.LOG
# Can trigger downstream processing
```

## Loop Prevention

**CRITICAL**: Files flow ONE WAY to prevent infinite loops:
```
Station → CMD.BRIDGE → BASE.OPS
  (generate)  (transit)  (detect)

✓ Files move from station to BASE.OPS
✗ Files NEVER sync back to stations
✗ Files NEVER stored in 3OX.Ai
✗ BASE.OPS content NEVER syncs to local drives
```

This is sync-safe and loop-safe by design.

## Manual Triggering

If automated routing not available:
```powershell
# Trigger routing manually
python 3OX.Ai/.3ox.index/CORE/ROUTING/router.py

# Check registry
cat !BASE.OPERATIONS/INCOMING/REGISTRY.LOG

# View station manifest
cat RVNx.BASE/0ut.3ox/FILE.MANIFEST.txt
```

## Status Checking

```python
# Check what's pending transit
grep "READY" */0ut.3ox/FILE.MANIFEST.txt

# Check what's been received
ls -la !BASE.OPERATIONS/INCOMING/*/

# View full routing history
cat !BASE.OPERATIONS/INCOMING/REGISTRY.LOG
```

---

**Status**: Minted Protocol ⧗-25.61  
**Authority**: 3OX.Ai Core Routing System  
**Integration**: FILE.STATE.LOG + 0ut.3ox + BASE.OPS Detection

