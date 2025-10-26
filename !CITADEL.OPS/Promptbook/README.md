# PROMPTBOOK - Agent Calibration System

## Overview

This directory contains the calibration and versioning system for Cursor AI agents operating in the 3OX workspace.

## Files

### CURSOR.AGENT.CALIBRATION.md
**Current Version**: v1.0.0  
**Token Count**: ~2,554 tokens (cl100k_base)

Main calibration prompt. Load this when:
- Starting new chat session
- Agent drifts from expected behavior
- After major system changes
- Periodic recalibration

### CALIBRATION.CHANGELOG.md
Version history and discovery log. Tracks:
- All version changes
- Pending discoveries waiting to merge
- Impact assessments for version bumps

## Workflow

### 1. During Session - Log Discoveries

When you discover something useful (new tool capability, better pattern, optimization):

```bash
ruby !CMD.CENTER/Toolkit/log_discovery.rb <type> "<description>" [impact]
```

**Types:**
- `tool_call` - New tool capability discovered
- `pattern` - Better workflow or pattern found
- `integration` - New integration point
- `optimization` - Performance/token improvement
- `error_fix` - Resolution for common error

**Impact:** `high`, `medium`, `low`

**Example:**
```bash
ruby !CMD.CENTER/Toolkit/log_discovery.rb tool_call "grep multiline support with -U flag" high
```

### 2. Accumulation

Discoveries pile up in `CALIBRATION.CHANGELOG.md` under **PENDING DISCOVERIES**.

### 3. Periodic Merge

When enough discoveries accumulate:

```bash
ruby !CMD.CENTER/Toolkit/merge_discoveries.rb
```

This will:
1. Review all pending discoveries
2. Determine version bump type (MAJOR/MINOR/PATCH)
3. Update `CURSOR.AGENT.CALIBRATION.md` with new version
4. Move discoveries to version history
5. Archive discovery log
6. Generate receipts

### 4. Version Changes

**What Updates:**

When you confirm a calibration update, these files change:

- `CURSOR.AGENT.CALIBRATION.md` - Main calibration gets new version number and may add sections
- `CALIBRATION.CHANGELOG.md` - Discoveries move from PENDING to history
- `.3ox/tools.yml` - May add new tool definitions (if tool discoveries)
- `.3ox/brain.rs` - May update if agent behavior changes

**Version Numbers:**

- **Major changes** (v2.0.0 → v3.0.0): Complete restructure, new brain type
- **New features** (v2.0.0 → v2.1.0): 5+ high impact discoveries, new capabilities
- **Small updates** (v2.0.0 → v2.0.1): Bug fixes, clarifications, minor improvements

## Self-Recalibration

The system is designed for continuous improvement:

```
┌─────────────────┐
│ Agent Session   │
└────────┬────────┘
         │ discovers new pattern
         ▼
┌─────────────────┐
│ Log Discovery   │ ← ruby log_discovery.rb
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ CHANGELOG       │ ← Accumulates in PENDING
└────────┬────────┘
         │ enough impact?
         ▼
┌─────────────────┐
│ Merge           │ ← ruby merge_discoveries.rb
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ CALIBRATION     │ ← Updated with new version
│ v1.0.0 → v1.1.0 │
└─────────────────┘
```

## Token Counting

To check calibration prompt size:

```bash
ruby -r tiktoken_ruby -e "enc = Tiktoken.encoding_for_model('gpt-4'); text = File.read('CURSOR.AGENT.CALIBRATION.md'); puts 'Tokens: ' + enc.encode(text).length.to_s"
```

Or use the helper script:

```bash
python !CMD.CENTER/Toolkit/count_tokens.py CURSOR.AGENT.CALIBRATION.md
```

## Integration with 3OX System

- **Receipts**: All operations generate receipts via `run.rb`
- **Hashing**: xxHash64 validation on all file ops
- **Routing**: Outputs go to `!0UT.3OX` sibling folders
- **Logging**: Operations logged to `.3ox/3ox.log` with sigil

## Quick Commands

```bash
# View current version
head -20 CURSOR.AGENT.CALIBRATION.md | grep Version

# Check pending discoveries
cat CALIBRATION.CHANGELOG.md | grep -A 20 "PENDING DISCOVERIES"

# Log a discovery
ruby !CMD.CENTER/Toolkit/log_discovery.rb pattern "Better output routing" medium

# Merge when ready
ruby !CMD.CENTER/Toolkit/merge_discoveries.rb

# Generate receipt
cd "!CITADEL.WORKDESK/(CAT.0) ADMIN/.3ox"
ruby run.rb calibration_updated
```

## Location

**Important**: 7HE.CITADEL operates from `!CITADEL.OPS`, NOT from CAT system folders.

```
R:\!LAUNCH.PAD\
├── !CITADEL.OPS\
│   ├── .3ox\                          ← 7HE.CITADEL operational data
│   │   └── turn_counter.json          ← Auto-discovery counter
│   └── Promptbook\                    ← 7HE.CITADEL calibration (YOU ARE HERE)
│       ├── CURSOR.AGENT.CALIBRATION.md
│       ├── CALIBRATION.CHANGELOG.md
│       └── README.md
│
├── !CMD.CENTER\
│   └── Toolkit\
│       ├── log_discovery.rb           ← Log discoveries
│       ├── merge_discoveries.rb       ← Merge to calibration
│       ├── auto_discover.rb           ← Auto tracking
│       └── .discovery.log             ← JSON lines log
│
└── !CITADEL.WORKDESK\
    └── (CAT.0) ADMIN\
        └── .3ox\                      ← CANONICAL CAT SYSTEM (do not modify)
            ├── brain.rs               ← CAT system brain
            ├── run.rb                 ← CAT runtime
            └── tools.yml              ← CAT tools only
```

## Maintenance

- **Weekly**: Check pending discoveries, consider merge
- **After major changes**: Log discovery immediately
- **Monthly**: Review changelog, clean up old archives
- **On drift**: Reload calibration, check version current

---

**System**: 3OX.Ai Workspace  
**User**: Lucius  
**Agent**: GUARDIAN (Sentinel)  
**Last Updated**: 2025-10-20

