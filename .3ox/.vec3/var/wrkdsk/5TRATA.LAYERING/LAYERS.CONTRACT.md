# 5TRATA Layers Contract (English Model)

Canonical sequence:

1. Layer 0: CMD
2. Layer 1: Base
3. Layer 2: Station
4. Layer 3: Service
5. Layer 4: Agent
6. Layer 5: Runtime (deferred until 0-4 are hard-locked)

## Layer 0: CMD
- Purpose: command roots and relay glue.
- Locked roots:
- `/root/!ZENS3N.CMD/_TRON`
- `/mnt/v/!CENTRAL.CMD/_TRON`
- `/mnt/r/!CMD.RELAY` (read-only validation in lock)
- Required `_TRON` top-level folders:
- `Agents`, `Bases`, `Services`, `Stations`, `systemd`, `3OX.Ai`
- Layer-0 tracker:
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer0`
- Reroute sink:
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!1N.3OX ZENS3N/LAYER.REROUTE/layer0`

## Layer 1: Base
- Purpose: base anchors and launchpad-level placement.
- Live anchors:
- `/root/!ZENS3N.CMD/!LAUNCHPAD`
- `/mnt/r/!LAUNCH.PAD`
- `/mnt/x/!LAUNCH.PAD`
- Core base context present:
- `/root/!ZENS3N.CMD/!LAUNCHPAD/.3ox`
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!CMD.RELAY` (symlink)

## Layer 2: Station
- Purpose: station runtime domains.
- Live station roots:
- `/root/!ZENS3N.CMD/_TRON/Stations`
- Current station folders:
- `Forge`

## Layer 3: Service
- Purpose: service daemons and supervision groups.
- Live service roots:
- `/root/!ZENS3N.CMD/_TRON/Services`
- `/root/!ZENS3N.CMD/_TRON/3OX.Ai`
- 3OX.Ai modules found:
- `Pulse`, `Queue`, `Supervisor`, `Tape`, `Warden`, `Worker`, `Arc`

## Layer 4: Agent
- Purpose: agent domains and orchestration identities.
- Live agent roots:
- `/root/!ZENS3N.CMD/_TRON/Agents`
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!ZENS3N.OPS/Agents`
- Current `_TRON` agent folder:
- `MetaTron`

## Layer 5: Runtime (Deferred)
- Deferred on purpose while Layers 0-4 are tuned.
- Runtime surfaces already visible (do not tune yet):
- `/root/!ZENS3N.CMD/_TRON/systemd`
- `/root/!ZENS3N.CMD/!LAUNCHPAD/.3ox/.vec3`
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata`

## Lock Rule
- Lock one layer fully before mutating the next layer.
- No Layer-5 tuning until Layers 0-4 are explicitly accepted.
