#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$SCRIPT_DIR/3ox_ai_tui.py"

if command -v gum >/dev/null 2>&1 && [[ "${NO_GUM_BOOT:-0}" != "1" ]]; then
  gum style --border thick --border-foreground 214 --padding "0 2" --foreground 214 --bold "▛▞// ⟦ ⎊ ⟧ :: 3OX.Ai tui"
  gum style --foreground 244 "▛▞ nav | main 50/50 | right 50/50"

  # Optional short preflight animation only; do NOT wrap the interactive app.
  if [[ "${NO_GUM_SPIN:-0}" != "1" ]]; then
    gum spin --spinner points --title "▛▞ loading runtime signals" -- sleep 0.35
  fi

  gum style --foreground 214 "▛▞ Launching dashboard"
  exec python3 "$APP"
else
  printf '%s\n' '████████████████████████████████████████'
  printf '%s\n' '▛▞// ⟦ ⎊ ⟧ :: 3OX.Ai tui'
  printf '%s\n' '████████████████████████████████████████'
  echo "▛▞ Launching dashboard"
  exec python3 "$APP"
fi
