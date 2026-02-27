#!/bin/bash
set -euo pipefail

ROOT="/root/!LAUNCHPAD"
SRC="$ROOT/!1N.3OX ZENS3N"
RUBY_WATCHER="$ROOT/.3ox/vec3/bin/1n3ox_watcher.rb"

mkdir -p "$SRC"

# Initial sweep (optional): run once at start
ruby "$RUBY_WATCHER" --once --dry-run

# Event-driven watch
inotifywait -m -r -e close_write,create,move "$SRC" --format '%w%f' |
while read -r path; do
  # Debounce: let file settle
  sleep 1
  ruby "$RUBY_WATCHER" --file "$path" --dry-run || true
done
