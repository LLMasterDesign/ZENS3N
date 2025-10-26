# Internal Setup Verification Checklist

**Purpose:** Verify all local tools and configurations before processing files through 1n3ox  
**Updated:** 2025-10-20  
**Version:** 1.0.0

---

## ▛▞ PHILOSOPHY ::

**Minimize API Tool Calls** by using local scripts:
- Ruby/Python scripts execute locally (no API cost)
- Only use API tools when local execution isn't possible
- Log discoveries locally for calibration updates
- Use turn counters to track efficiency

:: ∎

---

## ▛▞ PRE-FLIGHT VERIFICATION ::

### 1. Core Runtimes

**CITADEL.OPS Runtime:**
```bash
cd "R:\!LAUNCH.PAD\!CITADEL.OPS\.3ox"
ruby run.rb
```

**Expected:**
- ✓ Brain: 7HE.CITADEL (Citadel)
- ✓ Rules: AtomicOpsOnly, AlwaysBackup, ChecksumValidation
- ✓ Tools loaded: 9 available
- ✓ Logged to: 3ox.log

**CAT.ROUTER Runtime:**
```bash
cd "R:\!LAUNCH.PAD\!CITADEL.WORKDESK\(CAT.0) ADMIN\.3ox"
ruby run.rb
```

**Expected:**
- ✓ Brain: CAT.ROUTER (Sentinel)
- ✓ Rules: AtomicOpsOnly, AlwaysBackup, ChecksumValidation
- ✓ Tools loaded: 9 available
- ✓ Logged to: 3ox.log

### 2. CAT Domain Specialists

**Verify each CAT knows its domain:**
```bash
cd "R:\!LAUNCH.PAD"
.\"(CAT.1) Self"\.3ox\brain.exe config
.\"(CAT.2) Education"\.3ox\brain.exe config
.\"(CAT.3) Business"\.3ox\brain.exe config
.\"(CAT.4) Family"\.3ox\brain.exe config
.\"(CAT.5) Social"\.3ox\brain.exe config
```

**Expected:**
- CAT.1.SELF - Personal development specialist
- CAT.2.EDUCATION - Learning & knowledge specialist
- CAT.3.BUSINESS - Professional & career specialist
- CAT.4.FAMILY - Family & relationships specialist
- CAT.5.SOCIAL - Social life & community specialist

### 3. Discovery System

**Check discovery counter:**
```bash
ruby "!CMD.CENTER\Toolkit\chat_discovery.rb" check
```

**Expected:** Shows current turn count, no threshold reached yet

**Test discovery logging:**
```bash
ruby "!CMD.CENTER\Toolkit\log_discovery.rb" tool_call "Testing discovery system" low
```

**Expected:** 
- ✓ Discovery logged
- ✓ Timestamp recorded
- ✓ Appended to CALIBRATION.CHANGELOG.md

:: ∎

---

## ▛▞ LOCAL TOOLS INVENTORY ::

### File Operation Tools (Toolkit/)

| Tool | Purpose | Usage | API Calls |
|------|---------|-------|-----------|
| `1n3ox-scan.py` | Scan inbox for files | `python 1n3ox-scan.py [inbox] [output]` | **0** (local only) |
| `1n3ox-apply.py` | Apply file movements | `python 1n3ox-apply.py decisions.json` | **0** (local only) |
| `count_tokens.py` | Count tokens in files | `python count_tokens.py [file]` | **0** (local only) |

### Discovery Tools (Toolkit/)

| Tool | Purpose | Usage | API Calls |
|------|---------|-------|-----------|
| `auto_discover.rb` | Auto-discovery engine | Called internally | **0** (local only) |
| `chat_discovery.rb` | Turn counter & prompt | `ruby chat_discovery.rb check` | **0** (local only) |
| `log_discovery.rb` | Manual discovery log | `ruby log_discovery.rb [type] [desc]` | **0** (local only) |
| `merge_discoveries.rb` | Merge to changelog | Called on threshold | **0** (local only) |

### CAT Management Tools (CAT.0 ADMIN/.3ox/)

| Tool | Purpose | Usage | API Calls |
|------|---------|-------|-----------|
| `cat-router.rb` | Category dashboard | `ruby cat-router.rb dashboard` | **0** (local only) |
| `cat-trace.rb` | Activity tracking | `ruby cat-trace.rb report` | **0** (local only) |

### Runtime Tools (.3ox/)

| Tool | Purpose | Usage | API Calls |
|------|---------|-------|-----------|
| `run.rb` | Core runtime test | `ruby run.rb` | **0** (local only) |
| `brain.exe` | Brain config reader | `./brain.exe config` | **0** (local only) |

:: ∎

---

## ▛▞ WORKFLOW VERIFICATION ::

### Test 1: File Scanning (Local Only)

```bash
# Scan 1N.3OX inbox
cd "R:\!LAUNCH.PAD\!CITADEL.OPS\Toolkit"
python 1n3ox-scan.py "../!1N.3OX CITADEL.CMD" proposals.json

# Verify proposals.json created
cat proposals.json
```

**API Calls Used:** 0  
**Expected:** JSON file with inbox contents

### Test 2: CAT Dashboard (Local Only)

```bash
# Check all CAT activity
cd "R:\!LAUNCH.PAD\!CITADEL.WORKDESK\(CAT.0) ADMIN\.3ox"
ruby cat-router.rb dashboard
```

**API Calls Used:** 0  
**Expected:** Dashboard showing CAT status

### Test 3: Discovery Logging (Local Only)

```bash
# Log a discovery
ruby "!CMD.CENTER\Toolkit\log_discovery.rb" optimization "Using local tools reduces API calls" high

# Check changelog
cat "!CITADEL.OPS\Promptbook\CALIBRATION.CHANGELOG.md"
```

**API Calls Used:** 0  
**Expected:** Discovery appended to pending section

### Test 4: Turn Counter (Local Only)

```bash
# Increment turn with observation
ruby "!CMD.CENTER\Toolkit\chat_discovery.rb" increment "Verified local tool execution"

# Check status
ruby "!CMD.CENTER\Toolkit\chat_discovery.rb" check
```

**API Calls Used:** 0  
**Expected:** Turn count incremented, observation logged

:: ∎

---

## ▛▞ API CALL OPTIMIZATION RULES ::

### When to Use Local Tools (0 API Calls)

✅ **Use local tools for:**
- File scanning and listing
- Brain configuration reading
- CAT dashboard and reporting
- Discovery logging
- Turn counting
- Receipt generation
- Hash validation
- Log parsing
- JSON file processing

### When to Use API Tools (Costs API Calls)

❌ **Only use API tools for:**
- Reading unknown file contents (when needed)
- Searching codebase for patterns
- Editing files (search_replace, write)
- Running terminal commands that need results
- Complex codebase analysis

### Optimization Strategy

**Before every action, ask:**
1. Can this be done with a local script? → Use local script
2. Does a tool already exist in Toolkit/? → Use that tool
3. Is this operation logged/tracked? → Increment turn counter
4. Is this a new pattern? → Log discovery

**Target:**
- 90% of operations use local tools (0 API cost)
- 10% of operations use API tools (necessary only)

:: ∎

---

## ▛▞ VERIFICATION CHECKLIST ::

**Before Processing 1N.3OX Files:**

- [ ] ✓ CITADEL.OPS runtime tested and operational
- [ ] ✓ CAT.ROUTER runtime tested and operational
- [ ] ✓ All CAT domains (1-5) have correct brain configurations
- [ ] ✓ Discovery system tested and logging properly
- [ ] ✓ Turn counter operational
- [ ] ✓ Local tools inventory verified
- [ ] ✓ File scanning tools tested
- [ ] ✓ CAT dashboard tools tested
- [ ] ✓ All .3ox folders have correct activation keys
- [ ] ✓ Output folders (!0UT.3OX) exist and accessible
- [ ] ✓ Logging to 3ox.log working in all locations

**After Verification:**

✓ System ready for 1N.3OX file processing  
✓ Local tools operational (minimize API costs)  
✓ Discovery logging active  
✓ All CAT domains configured

:: ∎

---

## ▛▞ EXPECTED OUTPUTS ::

### Successful Verification

```
✓ CITADEL.OPS: 7HE.CITADEL operational
✓ CAT.ROUTER: CAT.ROUTER operational
✓ CAT.1-5: Domain specialists configured
✓ Discovery: Logging active
✓ Turn Counter: Operational
✓ Local Tools: 10+ tools available
✓ API Optimization: Ready

STATUS: READY FOR 1N.3OX PROCESSING
```

### If Issues Found

```
✗ [Component]: Error description
→ Fix: Specific remediation steps
→ Verify: How to confirm fix worked
```

:: ∎

---

**Protocol:** INTERNAL.SETUP.VERIFICATION v1.0.0  
**Purpose:** Ensure local infrastructure before external processing  
**Optimization:** Minimize API costs, maximize local execution

:: ∎



