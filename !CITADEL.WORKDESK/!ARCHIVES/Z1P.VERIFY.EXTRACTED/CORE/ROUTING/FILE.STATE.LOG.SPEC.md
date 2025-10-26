///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // SPEC ▞▞
▞//▞ FILE.STATE.LOG :: ρ{state-tracking}.φ{file-system}.τ{specification}.λ{core} ⫸
▙⌱📋 ≔ [⊢{file-changes}⇨{detect}⟿{log}▷{lightweight-state}]
〔3OX.Ai.core.specification〕 :: ∎

# FILE.STATE.LOG Specification

## Purpose
Lightweight file state tracking that allows AI agents to understand folder contents by reading a log file instead of scanning every file (which wastes resources).

## Location
```
[STATION]/.3ox/FILE.STATE.LOG
```

Example:
- `RVNx.BASE/.3ox/FILE.STATE.LOG`
- `OBSIDIAN.BASE/.3ox/FILE.STATE.LOG`
- `SYNTH.BASE/.3ox/FILE.STATE.LOG`

## Format

```
# FILE.STATE.LOG
# Station: [STATION_NAME]
# Last Updated: ⧗-YY.DD
# Purpose: Tracks file state changes for resource-efficient AI scanning

[TIMESTAMP] | ACTION | FILEPATH | SIZE | HASH
```

### Field Definitions:
- **TIMESTAMP**: ISO 8601 format (YYYY-MM-DD HH:MM:SS)
- **ACTION**: ADD | MODIFY | DELETE | MOVE
- **FILEPATH**: Relative path from station root
- **SIZE**: File size in bytes
- **HASH**: SHA256 hash (first 16 chars for readability)

### Example Log:
```
# FILE.STATE.LOG
# Station: RVNx.BASE
# Last Updated: ⧗-25.61
# Purpose: Tracks file state changes for resource-efficient AI scanning

[2025-10-07 14:23:15] | ADD | projects/sunset-glow/README.md | 2048 | abc123def456789...
[2025-10-07 14:25:30] | MODIFY | projects/sunset-glow/README.md | 3072 | def456789abc123...
[2025-10-07 14:30:00] | ADD | scripts/analyzer.py | 1024 | 789ghi012jkl345...
[2025-10-07 14:35:10] | DELETE | old-notes.md | 0 | 000000000000000...
[2025-10-07 14:40:00] | MOVE | drafts/idea.md → projects/idea.md | 512 | mno678pqr901stu...
```

## AI Agent Usage

**Instead of:**
```python
# Expensive: Read every file
for file in scan_directory():
    content = read_file(file)
    analyze(content)
```

**Do this:**
```python
# Efficient: Read state log only
state_log = read_file(".3ox/FILE.STATE.LOG")
recent_changes = filter_by_timestamp(state_log, since="today")
# Now you know what changed without reading every file
```

## Implementation Notes

1. **Auto-Generated**: Created by file watcher script or manual trigger
2. **Append-Only**: New entries added to bottom (no deletion of history)
3. **Rotation**: Log rotates when it exceeds 10,000 lines (archive as FILE.STATE.LOG.01, .02, etc.)
4. **Read Performance**: AI reads log header + last N entries instead of scanning filesystem
5. **Hash Optional**: For large binary files, hash can be "SKIP" to save computation

## Integration with 0ut.3ox

When files are marked for output in `0ut.3ox/`, they should also appear in FILE.STATE.LOG:

```
[2025-10-07 15:00:00] | ADD | 0ut.3ox/report.md | 4096 | xyz789abc012def...
```

This signals the routing system that a file is ready for transit.

---

**Status**: Minted Specification ⧗-25.61  
**Authority**: 3OX.Ai Core Routing System

