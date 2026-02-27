# 5TRATA Layers 0-4 Status

Date: 2026-02-13

## Layer 0 (CMD) - LOCKED
- `_TRON` roots aligned:
- `/root/!ZENS3N.CMD/_TRON`
- `/mnt/v/!CENTRAL.CMD/_TRON`
- Required runtime folders present on both sides:
- `Agents`, `Bases`, `Services`, `Stations`, `systemd`, `3OX.Ai`
- Relay root present and linked:
- `/mnt/r/!CMD.RELAY`
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!CMD.RELAY` -> `/mnt/r/!CMD.RELAY`
- Tracker:
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer0`

## Layer 1 (Base) - LOCKED
- Base anchors exist:
- `/root/!ZENS3N.CMD/!LAUNCHPAD`
- `/mnt/r/!LAUNCH.PAD`
- `/mnt/x/!LAUNCH.PAD`
- Enforced top-level allowlist on:
- `/root/!ZENS3N.CMD/!LAUNCHPAD`
- Tracker:
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer1`
- Reroute sink:
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!1N.3OX ZENS3N/LAYER.REROUTE/layer1`

## Layer 2 (Station) - LOCKED
- Station root exists:
- `/root/!ZENS3N.CMD/_TRON/Stations`
- Enforced station allowlist:
- `Forge`
- Tracker:
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer2`
- Reroute sink:
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!1N.3OX ZENS3N/LAYER.REROUTE/layer2/stations`

## Layer 3 (Service) - LOCKED
- Service roots exist:
- `/root/!ZENS3N.CMD/_TRON/Services`
- `/root/!ZENS3N.CMD/_TRON/3OX.Ai`
- Enforced `_TRON/Services` allowlist:
- `monitor`, `layer0` (symlink)
- Enforced `_TRON/3OX.Ai` allowlist:
- `.meta`, `Arc`, `Pulse`, `Queue`, `Supervisor`, `Tape`, `Warden`, `Worker`
- Tracker:
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer3`
- Reroute sinks:
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!1N.3OX ZENS3N/LAYER.REROUTE/layer3/services_root`
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!1N.3OX ZENS3N/LAYER.REROUTE/layer3/ai_root`

## Layer 4 (Agent) - LOCKED
- Agent roots exist:
- `/root/!ZENS3N.CMD/_TRON/Agents`
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!ZENS3N.OPS/Agents`
- Enforced runtime agent allowlist:
- `MetaTron`
- Enforced ops agent allowlist:
- empty (no top-level dirs currently)
- Tracker:
- `/root/!ZENS3N.CMD/_TRON/systemd/service/5trata/LAYER.TRACK/layer4`
- Reroute sinks:
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!1N.3OX ZENS3N/LAYER.REROUTE/layer4/runtime_agents`
- `/root/!ZENS3N.CMD/!LAUNCHPAD/!1N.3OX ZENS3N/LAYER.REROUTE/layer4/ops_agents`

## Deferred
- Layer 5 (Runtime) intentionally deferred.
