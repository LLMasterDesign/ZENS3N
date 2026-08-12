#!/usr/bin/env bash
# Mirror ZEN.HUB/website → ZENS3N/chrome (+ satellite chrome copies).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HUB="$(cd "$ROOT/../ZEN.HUB/website" && pwd)"
DEST="$ROOT/chrome"

if [[ ! -f "$HUB/chrome.js" ]]; then
  echo "publish-chrome: missing hub chrome.js at $HUB" >&2
  exit 1
fi

mkdir -p "$DEST"
rsync -a --delete \
  --exclude '.git/' \
  --exclude '*.swp' \
  "$HUB/" "$DEST/"

SATS=(
  "satellites/zensen.live"
  "satellites/zensen.systems"
  "satellites/zensen.store"
  "satellites/zensen.solutions"
)

for rel in "${SATS[@]}"; do
  sat="$ROOT/$rel/chrome"
  mkdir -p "$sat"
  rsync -a --delete \
    --exclude '.git/' \
    --exclude '*.swp' \
    "$HUB/" "$sat/"
done

echo "publish-chrome: hub → $DEST"
for rel in "${SATS[@]}"; do
  echo "publish-chrome: hub → $ROOT/$rel/chrome"
done
