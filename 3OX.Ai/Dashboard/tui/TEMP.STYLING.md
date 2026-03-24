# TEMP Styling Options (3OX.Ai TUI)

Glyph contract:
- Main glyph: `▛▞// ⟦ ⎊ ⟧ :: 3OX.Ai tui`
- Header marker: `▛▞//`

## Spinner choices available in gum
Count: **11**

1. `line`
2. `dot`
3. `minidot`
4. `jump`
5. `pulse`
6. `points`
7. `globe`
8. `moon`
9. `monkey`
10. `meter`
11. `hamburger`

## Recommended boot presets

### A) Clean + Fast (Recommended)
- Banner: thick border + orange text
- Spinner: `points` (0.35s preflight only)
- Launch: direct `python3` (no spinner wrapper)

### B) Industrial
- Banner: no border, bold + dim secondary line
- Spinner: `meter`
- Good for: mechanical/system feel

### C) Signal
- Banner: thin border + high contrast
- Spinner: `pulse`
- Good for: alive/monitoring feel

### D) Orbital
- Banner: centered + spacing
- Spinner: `globe`
- Good for: network/distributed feel

### E) Lunar
- Banner: minimal, calm
- Spinner: `moon`
- Good for: low-noise boot

## Important behavior rule
Never run the interactive curses TUI through `gum spin`.
- Wrong: `gum spin -- ... python3 3ox_ai_tui.py` (appears stuck at Launching)
- Correct: use optional short preflight spinner, then `exec python3 3ox_ai_tui.py`

## Env toggles
- `NO_GUM_BOOT=1` → no gum styling
- `NO_GUM_SPIN=1` → gum style only, no preflight spinner

## Quick test commands

```bash
cd /root/!ZENS3N.CMD/!LAUNCHPAD/3OX.Ai/Dashboard/tui
NO_GUM_SPIN=1 ./run.sh
./run.sh
```
