#!/bin/bash
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
# Lifecycle Scanner Service Stop Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/../../var/state/lifecycle_scanner.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "▛▞// Lifecycle Scanner not running"
  exit 0
fi

PID=$(cat "$PID_FILE")
if ! ps -p "$PID" > /dev/null 2>&1; then
  echo "▛▞// Lifecycle Scanner not running (stale PID file)"
  rm -f "$PID_FILE"
  exit 0
fi

echo "▛▞// Stopping Lifecycle Scanner (PID: $PID)..."
kill "$PID"
sleep 2

if ps -p "$PID" > /dev/null 2>&1; then
  echo "▛▞// Force killing..."
  kill -9 "$PID"
fi

rm -f "$PID_FILE"
echo "▛▞// Lifecycle Scanner stopped"
