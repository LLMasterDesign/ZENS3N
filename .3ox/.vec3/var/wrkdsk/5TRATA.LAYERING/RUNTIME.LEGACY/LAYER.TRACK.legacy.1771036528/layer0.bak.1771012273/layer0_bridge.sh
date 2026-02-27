#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${LAYER0_ENV_FILE:-$SCRIPT_DIR/layer0.paths.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "layer0.bridge: env file not found: $ENV_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

MODE="${LAYER0_MODE:-authoritative_wsl}"
RUN_ONCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-$MODE}"
      shift 2
      ;;
    --once)
      RUN_ONCE=1
      shift
      ;;
    *)
      echo "layer0.bridge: unknown arg: $1" >&2
      exit 1
      ;;
  esac
done

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "layer0.bridge: missing required command: $1" >&2
    exit 1
  fi
}

json_escape() {
  local s="${1:-}"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf "%s" "$s"
}

ensure_layout() {
  mkdir -p \
    "$LAYER0_LOCAL_META/receipts" \
    "$LAYER0_LOCAL_META/logs" \
    "$LAYER0_LOCAL_META/state"
  touch "$LAYER0_RECEIPTS_JSONL"
}

LOG_FILE="$LAYER0_LOCAL_META/logs/layer0.bridge.log"

log_line() {
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  printf "[%s] %s\n" "$now" "$1" >> "$LOG_FILE"
}

write_state() {
  local status="$1"
  local source="$2"
  local target="$3"
  local detail="$4"
  local now
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  cat > "$LAYER0_STATE_FILE" <<EOF
{"ts":"$(json_escape "$now")","mode":"$(json_escape "$MODE")","status":"$(json_escape "$status")","source":"$(json_escape "$source")","target":"$(json_escape "$target")","detail":"$(json_escape "$detail")"}
EOF
}

write_receipt() {
  local level="$1"
  local event="$2"
  local source="$3"
  local target="$4"
  local detail="$5"
  local now
  local id
  local line
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  id="layer0_$(date +%s)_$RANDOM"
  line="$(printf '{"ts":"%s","receipt_id":"%s","service":"layer0.bridge","level":"%s","event":"%s","source":"%s","target":"%s","detail":"%s"}' \
    "$(json_escape "$now")" \
    "$(json_escape "$id")" \
    "$(json_escape "$level")" \
    "$(json_escape "$event")" \
    "$(json_escape "$source")" \
    "$(json_escape "$target")" \
    "$(json_escape "$detail")")"

  printf "%s\n" "$line" >> "$LAYER0_RECEIPTS_JSONL"

  # Relay spool is best-effort so bridge continues even if relay path is unavailable.
  if mkdir -p "$LAYER0_RELAY_META/receipts" "$LAYER0_RELAY_META/logs" "$LAYER0_RELAY_META/state" 2>/dev/null; then
    printf "%s\n" "$line" >> "$LAYER0_RELAY_META/receipts/layer0.receipts.jsonl" 2>/dev/null || true
    printf "%s\n" "$line" >> "$LAYER0_GRPC_EVENT_SPOOL" 2>/dev/null || true
    cp "$LAYER0_STATE_FILE" "$LAYER0_RELAY_META/state/last_sync.json" 2>/dev/null || true
  fi
}

sync_tree() {
  local src="$1"
  local dst="$2"
  local reason="$3"
  local output=""

  if output="$(rsync -a --delete \
    --exclude ".layer0/" \
    --exclude ".git/" \
    --exclude "*.swp" \
    --exclude "*.tmp" \
    "$src/" "$dst/" 2>&1)"; then
    write_state "ok" "$src" "$dst" "$reason"
    write_receipt "INFO" "layer0.sync.applied" "$src" "$dst" "$reason"
    log_line "sync ok: $src -> $dst :: $reason"
    return 0
  fi

  write_state "error" "$src" "$dst" "$reason :: $output"
  write_receipt "ERROR" "layer0.sync.failed" "$src" "$dst" "$reason :: $output"
  log_line "sync failed: $src -> $dst :: $reason :: $output"
  return 1
}

watch_root() {
  local label="$1"
  local root="$2"
  local fifo="$3"
  inotifywait -m -r -q \
    -e "$LAYER0_EVENTS" \
    --timefmt "%Y-%m-%dT%H:%M:%S%z" \
    --format "${label}|%T|%w|%e|%f" \
    --exclude "(^|/)\\.layer0(/|$)|(^|/)\\.git(/|$)" \
    "$root" > "$fifo"
}

SUPPRESS_SIDE=""
SUPPRESS_UNTIL=0
SUPPRESS_SECONDS="${LAYER0_SUPPRESS_SECONDS:-3}"

should_ignore_side() {
  local side="$1"
  local now_epoch
  now_epoch="$(date +%s)"
  if [[ "$side" == "$SUPPRESS_SIDE" && "$now_epoch" -le "$SUPPRESS_UNTIL" ]]; then
    return 0
  fi
  return 1
}

set_suppress_side() {
  local side="$1"
  local now_epoch
  now_epoch="$(date +%s)"
  SUPPRESS_SIDE="$side"
  SUPPRESS_UNTIL=$((now_epoch + SUPPRESS_SECONDS))
}

handle_event() {
  local side="$1"
  local ts="$2"
  local dir="$3"
  local events="$4"
  local file="$5"
  local src_root=""
  local dst_root=""
  local dst_side=""
  local full_path=""
  local rel_path=""

  if [[ "$MODE" == "authoritative_wsl" && "$side" != "wsl" ]]; then
    return 0
  fi

  if should_ignore_side "$side"; then
    return 0
  fi

  case "$side" in
    wsl)
      src_root="$LAYER0_WSL_TRON"
      dst_root="$LAYER0_V_TRON"
      dst_side="v"
      ;;
    v)
      src_root="$LAYER0_V_TRON"
      dst_root="$LAYER0_WSL_TRON"
      dst_side="wsl"
      ;;
    *)
      return 0
      ;;
  esac

  full_path="${dir%/}/${file}"
  rel_path="${full_path#$src_root/}"
  if [[ "$rel_path" == "$full_path" ]]; then
    rel_path="${full_path#$src_root}"
    rel_path="${rel_path#/}"
  fi

  if [[ "$rel_path" == .layer0/* || "$rel_path" == .git/* ]]; then
    return 0
  fi

  write_receipt "INFO" "layer0.event.detected" "$src_root" "$dst_root" "$side $events $rel_path @ $ts"
  sync_tree "$src_root" "$dst_root" "$side $events $rel_path @ $ts" || true
  set_suppress_side "$dst_side"
}

require_cmd inotifywait
require_cmd rsync

ensure_layout

if [[ ! -d "$LAYER0_WSL_TRON" || ! -d "$LAYER0_V_TRON" ]]; then
  echo "layer0.bridge: source/destination path missing" >&2
  exit 1
fi

log_line "bridge start mode=$MODE"
write_receipt "INFO" "layer0.bridge.start" "$LAYER0_WSL_TRON" "$LAYER0_V_TRON" "mode=$MODE"

# Always perform a startup alignment from WSL to V: for deterministic state.
sync_tree "$LAYER0_WSL_TRON" "$LAYER0_V_TRON" "startup alignment" || true
set_suppress_side "v"

if [[ "$RUN_ONCE" -eq 1 ]]; then
  write_receipt "INFO" "layer0.bridge.once.complete" "$LAYER0_WSL_TRON" "$LAYER0_V_TRON" "startup-only"
  exit 0
fi

FIFO_PATH="$(mktemp -u "/tmp/layer0.events.XXXXXX")"
mkfifo "$FIFO_PATH"

WATCH_PIDS=()
cleanup() {
  local pid
  for pid in "${WATCH_PIDS[@]:-}"; do
    kill "$pid" >/dev/null 2>&1 || true
  done
  rm -f "$FIFO_PATH"
}
trap cleanup EXIT INT TERM

watch_root "wsl" "$LAYER0_WSL_TRON" "$FIFO_PATH" &
WATCH_PIDS+=("$!")

if [[ "$MODE" == "bidirectional" ]]; then
  watch_root "v" "$LAYER0_V_TRON" "$FIFO_PATH" &
  WATCH_PIDS+=("$!")
fi

while IFS="|" read -r side ts dir events file; do
  handle_event "$side" "$ts" "$dir" "$events" "$file"
done < "$FIFO_PATH"
