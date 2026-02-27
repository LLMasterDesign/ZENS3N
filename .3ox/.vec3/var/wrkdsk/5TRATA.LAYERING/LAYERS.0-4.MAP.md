# 5TRATA Live Map (Layers 0-4)

Date: 2026-02-13
Scope: live filesystem map for tuning; Layer 5 intentionally excluded.

## Layer 0: CMD
- `/root/!ZENS3N.CMD/_TRON`
- `/mnt/v/!CENTRAL.CMD/_TRON`
- `/mnt/r/!CMD.RELAY`
- Required runtime dirs now aligned on both `_TRON` roots:
- `3OX.Ai`, `Agents`, `Bases`, `Services`, `Stations`, `systemd`

## Layer 1: Base
- Primary base root:
- `/root/!ZENS3N.CMD/!LAUNCHPAD`
- Current top-level dirs:
- `!1N.3OX ZENS3N`
- `!CMD.CENTER`
- `!WORKDESK`
- `!ZENS3N.OPS`
- `.3ox`
- `.cursor`
- `.git`
- `.vscode`
- `Antigravity`
- `codex53-work`
- Base lock tracker:
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer1`

## Layer 2: Station
- Station runtime root:
- `/root/!ZENS3N.CMD/_TRON/Stations`
- Current stations:
- `Forge`
- Suggested next lock:
- `Stations` allowlist contract (`Forge` + future approved names only).

## Layer 3: Service
- Runtime service root:
- `/root/!ZENS3N.CMD/_TRON/Services`
- Current entries:
- `monitor` (dir)
- `layer0` (compat symlink -> `../systemd/service/5trata/layer-0`)
- Daemon service domain:
- `/root/!ZENS3N.CMD/_TRON/3OX.Ai`
- Current modules:
- `Arc`, `Pulse`, `Queue`, `Supervisor`, `Tape`, `Warden`, `Worker`
- Suggested next lock:
- Service allowlist for both `_TRON/Services` and `_TRON/3OX.Ai`.

## Layer 4: Agent
- Runtime agent root:
- `/root/!ZENS3N.CMD/_TRON/Agents`
- Current runtime agents:
- `MetaTron`
- Ops-side agents root:
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!ZENS3N.OPS/Agents`
- Suggested next lock:
- Agent placement contract (`runtime agents` vs `ops agents`).
