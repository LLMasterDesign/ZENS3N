# Layer 0 Layout Lock (5TRATA)

Layer 0 canonical locations:

- `/root/!ZENS3N.CMD/_TRON`
- `/mnt/v/!CENTRAL.CMD/_TRON`
- `/mnt/r/!CMD.RELAY`

Layer 0 is root-folder topology only.
No file/content synchronization is performed.

This guardian is event-driven (`inotifywait`), not polling.
Every layout event emits receipts and re-enforces required folders/symlinks.

## Files

- `layer0.paths.env` - path contract and runtime mode.
- `LAYER0.CONTRACT.toml` - Layer-0 source-of-truth contract.
- `layer0_lock.sh` - bootstrap/enforce folder topology.
- `layer0_bridge.sh` - live layout guardian with receipt emission.

## Single Tracker Location

All Layer-0 tracking state lives at:

- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer0`

This location holds receipts, state, and logs.

## Usage

Bootstrap once (layout only):

```bash
/root/!ZENS3N.CMD/_TRON/Services/layer0/layer0_lock.sh
```

Run bridge once (startup check only):

```bash
/root/!ZENS3N.CMD/_TRON/Services/layer0/layer0_bridge.sh --once
```

Run bridge daemon mode (continuous topology guard):

```bash
/root/!ZENS3N.CMD/_TRON/Services/layer0/layer0_bridge.sh
```

## Required Layout

- `/root/!ZENS3N.CMD/_TRON`: `Agents`, `Bases`, `Services`, `Stations`, `systemd`, `3OX.Ai`
- `/mnt/v/!CENTRAL.CMD/_TRON`: `Agents`, `Bases`, `Services`, `Stations`, `systemd`, `3OX.Ai`
- `/mnt/r/!CMD.RELAY`: `!CMD.BRIDGE`, `!CMD.CENTER`, `!CMD.HUB`, `_meta`

Unexpected top-level folders in either `_TRON` root are moved to:

- `/root/!ZENS3N.CMD/!LAUNCHPAD/!1N.3OX ZENS3N/LAYER.REROUTE/layer0/wsl_tron`
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!1N.3OX ZENS3N/LAYER.REROUTE/layer0/v_tron`

## Receipts

Local only (relay is treated read-only in Layer-0):

- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer0/receipts/layer0.receipts.jsonl`
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer0/state/layer0.state.json`
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer0/logs/layer0.bridge.log`
