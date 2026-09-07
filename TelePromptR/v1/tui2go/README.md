# TelePromptR tui2go

This folder contains TelePromptR's *small* 2GO-style TUI objects.

Design intent:
- TelePromptR does not require a TUI to run.
- The TUI is an operator surface for sharing status + driving `_forge/forge.sh`.
- No secrets printed (no Telegram bot token, no agent subkeys).

## Run

```bash
cd '/root/!ZENS3N.CMD/!LAUNCHPAD/TelePromptR'
./tui2go/tui2go.sh
```

Profile (future-proof):

```bash
./tui2go/tui2go.sh --profile tpr
```

## Wiring (env)

Defaults:
- `TPR_FORGE_SH=./_forge/forge.sh`
- `TPR_ENV_FILE=./_forge/.env`
- `TPR_VAR_DIR=./runtime/vps/3ox.station/vec3/var`

Theme:
- `TPR_2GO_THEME=neo|amber|acid|mono`
