# TelePromptR

TelePromptR runtime workspace.

This repo is initialized with Hawk-style `_forge` controls so you can build/run/restart/watch TelePromptR from one place.

Default runtime is the pulled VPS implementation at:
`runtime/vps/3ox.station/vec3/bin/teleprompter.rb`

## Quick Start

```bash
cd '/root/!ZENS3N.CMD/!LAUNCHPAD/TelePromptR'
cp -n _forge/.env.example _forge/.env
./_forge/forge.sh init
./_forge/forge.sh build
./_forge/forge.sh squad-up
./_forge/forge.sh status
```

## 3ox Integration

To set up TelePromptR for use with 3ox agents:

```bash
# Run the setup script (reads branch and configures proto)
./setup.3ox.proto.sh

# This will:
# - Create relay directory structure in .3ox
# - Copy proto definitions to .3ox/specs/tpr/
# - Create integration helper: .3ox/vec3/lib/core/telegram.tpr.rb
# - Set up registration and routing files
```

See `COMMO.SNIP.md` for detailed integration instructions and what TPR needs to change for Telegram communication.

**Quick integration example:**
```ruby
require_relative '.3ox/vec3/lib/core/telegram.tpr'

# Register agent
TelegramTPR.register_agent(agent_id: 'my_agent', chat_id: -1001234567890)

# Send message
TelegramTPR.send_message(agent_id: 'my_agent', text: 'Hello from 3ox!')

# Read inbox
TelegramTPR.read_inbox.each do |envelope|
  puts "Received: #{envelope['text']}"
  TelegramTPR.mark_processed(envelope['_filepath'])
end
```

## tui2go (Small Panel)

TelePromptR does not require a TUI to run, but `tui2go` is a tiny operator panel
for sharing state and driving `_forge` commands.

```bash
./tui2go.sh
```

Safety: `tui2go` never prints the Telegram bot token or agent subkeys.

For continuous auto-reboot on code/config changes:

```bash
./_forge/forge.sh watch
```

Or run watch loop in background:

```bash
./_forge/forge.sh service-start
./_forge/forge.sh status
./_forge/forge.sh service-stop
```

## Homebase Speaker Mesh

Use one shared responder so agents without dedicated API keys/runtime can still talk:

```bash
./_forge/forge.sh mesh-up
./_forge/forge.sh mesh-logs
./_forge/forge.sh mesh-down
```

Start both TelePromptR and mesh together:

```bash
./_forge/forge.sh squad-up
./_forge/forge.sh squad-status
./_forge/forge.sh squad-down
```

Mesh behavior/personas live in `CyberDeck/TPR.SPEAKER.MESH.json`.
If `TPR_MESH_API_KEY` is unset, mesh uses deterministic fallback replies.

Queue a multi-agent stress burst (24 agents, 2 msgs each):

```bash
./_forge/forge.sh loadtest 24 2
```

By default, loadtest writes envelopes into
`runtime/vps/3ox.station/vec3/var/outbox` so the VPS runtime can publish them.

## Secure Agent Subkeys

Issue and rotate `*.tgsub.key` files (JSON, `0600` perms) via `_forge`:

```bash
./_forge/forge.sh subkey-create AGENT_ID
./_forge/forge.sh subkey-rotate AGENT_ID
./_forge/forge.sh subkey-list
./_forge/forge.sh subkey-revoke AGENT_ID
```

Default key dir: `_forge/runtime/keys` (override with `TPR_KEYS_DIR` in `_forge/.env`).

## VPS Provenance

Pulled from:
- `root@5.78.109.54:/root/!CMD.VPS/TelePromptR/3ox.station/vec3/bin/teleprompter.rb`
- `root@5.78.109.54:/root/!CMD.VPS/TelePromptR/STATION.ID`
- `root@5.78.109.54:/root/!CMD.VPS/TelePromptR/TELEPROMPTER.ID`

## Notes + Upgrade Plan

- `CyberDeck/TPR.CYBERDESK.INDEX.md`
- `CyberDeck/TPR.UPGRADE.BACKLOG.md`
- `CyberDeck/TPR.AGENTIC.LOOP.NOTES.md`
- `CyberDeck/TPR.MULTI_AGENT.ROUTING.SPEC.md`
- `CyberDeck/TPR.CAPACITY.SPEC.md`
- `CyberDeck/TPR.LANGUAGES.SHEET.md`
- `CyberDeck/TPR.RESEARCH.PACK.md`
- `CyberDeck/TPR.ROUTE.MAP.json`
- `CyberDeck/TPR.SPEAKER.MESH.json`

Formal schemas:
- `specs/README.md`
