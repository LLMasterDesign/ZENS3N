# PRISM Heartbeat — Validation Loop (v1.0)

This kit adds a self-auditing **validation heartbeat** to your 3OX.Ai system.  
It watches stations (RVNx, SYNTH, OBSIDIAN), verifies **PRISM shard alignment** in brains/rules, enforces folder invariants, and checks **0UT.3OX freshness**.  
On each tick, it emits a consolidated YAML report and (optionally) drops it into your `!BASE.OPERATIONS/INCOMING/` pipeline for CMD.BRIDGE.

---

## What it does

1. **Shard Integrity** — confirms the presence and order of `PRISM` lines (`P`, `R`, `I`, `S`, `M`) in brains/rules.  
2. **File/Folder Invariants** — ensures required folders exist (`.3ox`, `0UT.3OX`, templates, OPS paths).  
3. **0UT Freshness** — looks for a recent status/error/completion file per station; warns if stale.  
4. **Sirius Time Lint** — accepts `⧗-YY.DD` stamps; if unknown, falls back to ISO datestamp and flags a soft warning.  
5. **Policy Enforcement (optional)** — checks for presence of core policy docs listed in config.  
6. **Emit Report** — writes `heartbeat_{timestamp}.yaml` and (if configured) mirrors a copy into `!BASE.OPERATIONS/INCOMING/<station>/`.

---

## Quick start

1) Edit **`config.yaml`** to point at your real paths. Example defaults assume a root like `P:\!CMD.BRIDGE\` or `R:\` (but any path works).  
2) Run once manually:
```powershell
python heartbeat.py
```
3) Schedule as a Windows Task (or cron). A helper script is included:
```powershell
.\start_heartbeat.ps1
```

---

## Reports

Output example (truncated):

```yaml
timestamp: "2025-10-08T12:00:00-05:00"
sirius_time_guess: "⧗-25.??"
stations:
  RVNx:
    prism_ok: true
    out_fresh_minutes: 12
    invariants:
      .3ox_present: true
      ops_present: true
      out_folder_present: true
    notes: []
  SYNTH:
    prism_ok: false
    errors:
      - "[PRISM] Missing 'M:' line in station.brain.md"
summary:
  status: "WARN"
  details: "1 station failing PRISM check; SYNTH stale 0UT > 90m"
```

---

## Files

- `heartbeat.py` — main validator
- `config.yaml` — paths & thresholds
- `schemas/prism_regex.yaml` — regex patterns for shard checks
- `start_heartbeat.ps1` — Windows Task Scheduler bootstrap

---

## Uninstall

Delete the scheduled task (if created) and remove this folder.

— ∎


---

## Receipts (TOML/Rust-style) Support

- Place station receipts under: `!STATION.OPS/RECEIPTS/`
- Accepted file patterns: `*.toml`, `*.rs.toml`, `*.receipt`
- Required fields (configurable in `config.yaml`):
  - `sirius_time`, `source`, `destination`, `status`, `hash`
- The heartbeat summarizes the **last N** receipts per station and flags any missing fields.
