# !ZENS3N.CMD Organization Plan

## Current State
- Legacy folders from GitHub repo (already committed)
- New VPS deployment structure in `!ZENS3N.VPS/`
- Mixed purposes: some local-only, some VPS-bound

## Organization Strategy

### Keep in Root (Active Work)
- `!ZENS3N.VPS/` - VPS deployment code (code/, config/, runtime/, scripts/)
- `!CMD.CENTER/` - Command hub (if needed for VPS coordination)

### Archive/Move Legacy
- `!CITADEL.OPS/` → Move to `_ARCHIVE/LEGACY/!CITADEL.OPS/`
- `!CITADEL.WORKDESK/` → Move to `_ARCHIVE/LEGACY/!CITADEL.WORKDESK/`
- `(CAT.1) Self/` through `(CAT.5) Social/` → Move to `_ARCHIVE/LEGACY/CAT/`
- `3OX.Ai/` → Evaluate: keep if active, archive if legacy
- `BUDGET.BUILDER/`, `CURSOR.CLEANER/`, `SPEC.WRITER/` → Evaluate purpose

### Keep Active (If Still Used)
- `ZENS3N/` - Evaluate if still active
- `ZENS3N.BASE/` - Local workspace (untracked, as intended)

## Proposed Structure
```
!ZENS3N.CMD/
├── !ZENS3N.VPS/          # VPS deployment (active)
│   ├── code/
│   ├── config/
│   ├── runtime/
│   └── scripts/
├── !CMD.CENTER/          # Keep if coordinating VPS
├── ZENS3N.BASE/          # Local workspace (untracked)
├── _ARCHIVE/             # Legacy/old work
│   └── LEGACY/
│       ├── !CITADEL.OPS/
│       ├── !CITADEL.WORKDESK/
│       └── CAT/
└── [Active tools if still used]
