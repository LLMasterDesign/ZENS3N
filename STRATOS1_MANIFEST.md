# !CMD.BRIDGE — Stratos 1 Manifest

Law
---
Stratos 1 inside `!CMD.BRIDGE` must always contain:
1. An intake shelf `!1N.3OX`
2. The coordination station `!CMD.CENTER`
3. Every other directory whose name starts with `!`

Inventory (2025‑11‑24)
----------------------
- `!1N.3OX CMD.MASTER/` → primary intake zone (ground truth for staging/recovery)
- `!CMD.CENTER/` → command hub + vaults
- `!RAVEN.CMD/` → Raven operator station
- `!ZENS3N.CMD/` → Zens3n umbrella (WSL + VPS links)
- `!CMD.CENTER/!CORE/` → symlink to `/root/CORE` (core runtime layer outside _runtime, exposed inside CMD.CENTER)

How to use this file
--------------------
- When a new `!` directory is added or retired, update this manifest and log it in `!CMD.CENTER/Logbook`.
- Non-`!` folders (e.g., `CITADEL.BASE/`, `SYNTH.BASE/`) may live here but are outside Stratos 1.

Change Log
----------
- 2025-11-24: Removed redundant symlink `!1N.3OX CMD.BRIDGE`. `!1N.3OX CMD.MASTER` is now the sole intake zone.
