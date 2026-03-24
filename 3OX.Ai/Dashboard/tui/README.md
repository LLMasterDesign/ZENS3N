# 3OX.AI TUI

Canonical location:
- `/root/!ZENS3N.CMD/!LAUNCHPAD/3OX.Ai/Dashboard/tui`

Layout:
- Left pane: nav + monitor checklist
- Center pane: 50/50 split by page
- Right pane: 50/50 split
  - Top-right: detailed data for current page
  - Bottom-right: run log (3ox.log + chat notes)

## Run

```bash
cd /root/!ZENS3N.CMD/!LAUNCHPAD/3OX.Ai/Dashboard/tui
./run.sh
```

## Keys

- `Up` / `Down` or `j` / `k`: change page
- `1..4`: jump page
- `r`: refresh
- `m`: append chat line to `agent_chat.log`
- `x`: append execution marker
- `q`: quit

## Data Sources

- `_TRON/3OX.Ai/3ox.log`
- `_TRON/3OX.Ai/Pulse/meta/events`
- `_TRON/3OX.Ai/.meta/operation_levels.toml`
- `_TRON/3OX.Ai/SERVICES.STATUS.md`
