# TelePromptR _forge

Hawk-style local runner adapted for TelePromptR.

Default entrypoint:
`runtime/vps/3ox.station/vec3/bin/teleprompter.rb`

## Quick Start

```bash
cd '/root/!ZENS3N.CMD/!LAUNCHPAD/TelePromptR'
cp -n _forge/.env.example _forge/.env
./_forge/forge.sh init
./_forge/forge.sh build
./_forge/forge.sh squad-up
```

## Continuous Auto-Restart

```bash
./_forge/forge.sh watch
```

Or background watch service:

```bash
./_forge/forge.sh service-start
./_forge/forge.sh status
./_forge/forge.sh service-stop
```

## Speaker Mesh

Mesh consumes `var/inbox/*.json` and writes agent replies to `var/outbox/*.json`.

```bash
./_forge/forge.sh mesh-up
./_forge/forge.sh mesh-logs
./_forge/forge.sh mesh-down
```

Full stack:

```bash
./_forge/forge.sh squad-up
./_forge/forge.sh squad-status
./_forge/forge.sh squad-down
```

## Agent Subkeys

```bash
./_forge/forge.sh subkey-create AGENT_ID
./_forge/forge.sh subkey-rotate AGENT_ID
./_forge/forge.sh subkey-list
./_forge/forge.sh subkey-revoke AGENT_ID
```

Subkeys are stored as `*.tgsub.key` JSON files with strict file permissions.

## Multi-Agent Load Test

```bash
./_forge/forge.sh loadtest 24 2
```

This enqueues synthetic envelopes into the active loadtest outbox.
For the default VPS runtime, that is:
`runtime/vps/3ox.station/vec3/var/outbox`.
