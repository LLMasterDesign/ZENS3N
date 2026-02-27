# Layer 0 Bridge (5TRATA)

Layer 0 canonical locations:

- `/root/!ZENS3N.CMD/_TRON`
- `/mnt/v/!CENTRAL.CMD/_TRON`
- `/mnt/r/!CMD.RELAY`

This bridge is event-driven (`inotifywait`), not polling.
Every event generates receipts in JSONL and mirrors receipt flow to relay meta.

## Files

- `layer0.paths.env` - path contract and runtime mode.
- `LAYER0.CONTRACT.toml` - Layer-0 source-of-truth contract.
- `layer0_lock.sh` - bootstrap alignment and metadata setup.
- `layer0_bridge.sh` - live event-to-sync bridge with receipt emission.

## Usage

Bootstrap once:

```bash
/root/!ZENS3N.CMD/_TRON/Services/layer0/layer0_lock.sh
```

Run bridge once (startup alignment only):

```bash
/root/!ZENS3N.CMD/_TRON/Services/layer0/layer0_bridge.sh --once
```

Run bridge daemon mode:

```bash
/root/!ZENS3N.CMD/_TRON/Services/layer0/layer0_bridge.sh
```

## Receipts

Local:

- `/root/!ZENS3N.CMD/_TRON/.layer0/receipts/layer0.receipts.jsonl`
- `/root/!ZENS3N.CMD/_TRON/.layer0/state/last_sync.json`

Relay mirror:

- `/mnt/r/!CMD.RELAY/_meta/layer0/receipts/layer0.receipts.jsonl`
- `/mnt/r/!CMD.RELAY/_meta/layer0/state/last_sync.json`
- `/mnt/r/!CMD.RELAY/_meta/layer0/grpc.events.jsonl`
