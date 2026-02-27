#!/bin/bash
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
# Lifecycle Scanner Service Status Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/../../var/state/lifecycle_scanner.pid"
STATE_FILE="$SCRIPT_DIR/../../var/state/scanner_state.json"
LOG_FILE="$SCRIPT_DIR/../../var/log/lifecycle_scanner.log"

if [ ! -f "$PID_FILE" ]; then
  echo "▛▞// Lifecycle Scanner: STOPPED"
  exit 0
fi

PID=$(cat "$PID_FILE")
if ps -p "$PID" > /dev/null 2>&1; then
  echo "▛▞// Lifecycle Scanner: RUNNING (PID: $PID)"
  
  if [ -f "$STATE_FILE" ]; then
    LAST_SCAN=$(cat "$STATE_FILE" | grep -o '"last_scan":[0-9]*' | grep -o '[0-9]*')
    if [ -n "$LAST_SCAN" ]; then
      LAST_SCAN_TIME=$(date -d "@$LAST_SCAN" 2>/dev/null || date -r "$LAST_SCAN" 2>/dev/null || echo "unknown")
      echo "▛▞//   Last scan: $LAST_SCAN_TIME"
    fi
  fi
  
  if [ -f "$LOG_FILE" ]; then
    echo "▛▞//   Log: $LOG_FILE"
  fi
else
  echo "▛▞// Lifecycle Scanner: STOPPED (stale PID file)"
  rm -f "$PID_FILE"
fi
