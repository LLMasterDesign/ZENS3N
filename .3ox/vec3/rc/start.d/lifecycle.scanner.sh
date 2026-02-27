#!/bin/bash
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
# Lifecycle Scanner Service Start Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCANNER_SCRIPT="$SCRIPT_DIR/../run/lifecycle.scanner.rb"
PID_FILE="$SCRIPT_DIR/../../var/state/lifecycle_scanner.pid"
LOG_FILE="$SCRIPT_DIR/../../var/log/lifecycle_scanner.log"

if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE")
  if ps -p "$PID" > /dev/null 2>&1; then
    echo "▛▞// Lifecycle Scanner already running (PID: $PID)"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

echo "▛▞// Starting Lifecycle Scanner..."
nohup ruby "$SCANNER_SCRIPT" >> "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"
echo "▛▞// Lifecycle Scanner started (PID: $(cat $PID_FILE))"
