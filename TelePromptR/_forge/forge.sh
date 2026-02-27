#!/usr/bin/env bash
set -euo pipefail

# TelePromptR _forge runner
# Hawk-style control loop: build/up/down/restart/status/watch/service mode.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORGE_DIR="$ROOT_DIR/_forge"
RUNTIME_DIR="${FORGE_RUNTIME_DIR:-$FORGE_DIR/runtime}"
ENV_FILE="${FORGE_ENV_FILE:-$FORGE_DIR/.env}"

TPR_PID_FILE="$RUNTIME_DIR/telepromptr.pid"
MESH_PID_FILE="$RUNTIME_DIR/speaker_mesh.pid"
WATCH_PID_FILE="$RUNTIME_DIR/watch.pid"

TPR_LOG_FILE="$RUNTIME_DIR/telepromptr.log"
MESH_LOG_FILE="$RUNTIME_DIR/speaker_mesh.log"
WATCH_LOG_FILE="$RUNTIME_DIR/watch.log"

trim() {
  local s="${1:-}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

log() {
  printf '[forge] %s\n' "$*"
}

load_env() {
  if ! [[ -f "$ENV_FILE" ]]; then
    return 0
  fi

  while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
    local line
    line="$(trim "$raw_line")"
    [[ -n "$line" ]] || continue
    [[ "${line:0:1}" == "#" ]] && continue
    [[ "$line" == *=* ]] || continue

    local key value
    key="$(trim "${line%%=*}")"
    value="$(trim "${line#*=}")"

    if [[ "$value" =~ ^\".*\"$ ]] || [[ "$value" =~ ^\'.*\'$ ]]; then
      value="${value:1:${#value}-2}"
    fi

    export "$key=$value"
  done < "$ENV_FILE"
}

load_env

TPR_BIN="${TPR_BIN:-ruby}"
TPR_ENTRYPOINT="${TPR_ENTRYPOINT:-$ROOT_DIR/runtime/vps/3ox.station/vec3/bin/teleprompter.rb}"
TPR_START_ARGS="${TPR_START_ARGS:-}"
TPR_BASE_ID="${TPR_BASE_ID:-CMD.BRIDGE}"
TPR_KEYS_DIR="${TPR_KEYS_DIR:-$RUNTIME_DIR/keys}"
TPR_CMD_ROOT="${TPR_CMD_ROOT:-/root/!ZENS3N.CMD/.3ox}"
TPR_LOADTEST_REG_PATH="${TPR_LOADTEST_REG_PATH:-$RUNTIME_DIR/loadtest.registrations.json}"
TPR_MESH_BIN="${TPR_MESH_BIN:-ruby}"
TPR_MESH_ENTRYPOINT="${TPR_MESH_ENTRYPOINT:-$ROOT_DIR/tools/speaker_mesh.rb}"
TPR_MESH_START_ARGS="${TPR_MESH_START_ARGS:-start}"

FORGE_WATCH_ON_CHANGE="${FORGE_WATCH_ON_CHANGE:-restart}"
FORGE_WATCH_REBUILD="${FORGE_WATCH_REBUILD:-1}"
FORGE_WATCH_BUILD_ON_START="${FORGE_WATCH_BUILD_ON_START:-1}"
FORGE_WATCH_INTERVAL_S="${FORGE_WATCH_INTERVAL_S:-1.0}"
FORGE_WATCH_PATHS="${FORGE_WATCH_PATHS:-_forge;tools;CyberDeck;README.md}"
FORGE_TAIL_LINES="${FORGE_TAIL_LINES:-120}"
FORGE_LOADTEST_AGENTS="${FORGE_LOADTEST_AGENTS:-24}"
FORGE_LOADTEST_MESSAGES_PER_AGENT="${FORGE_LOADTEST_MESSAGES_PER_AGENT:-2}"

ensure_runtime_dir() {
  mkdir -p "$RUNTIME_DIR"
  mkdir -p "$TPR_KEYS_DIR"
  chmod 700 "$TPR_KEYS_DIR" 2>/dev/null || true
}

pid_alive() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  local pid
  pid="$(cat "$file" 2>/dev/null || true)"
  [[ -n "$pid" ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

kill_from_pid_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  local pid
  pid="$(cat "$file" 2>/dev/null || true)"
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    sleep 0.2
    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid" 2>/dev/null || true
    fi
  fi

  rm -f "$file"
}

append_semicolon_list_args() {
  local -n cmd_ref="$1"
  local raw="${2:-}"

  local IFS=';'
  read -r -a parts <<< "$raw"
  local item
  for item in "${parts[@]}"; do
    item="$(trim "$item")"
    [[ -n "$item" ]] || continue
    cmd_ref+=("$item")
  done
}

default_loadtest_outbox_dir() {
  if [[ -n "${TPR_BUS_OUTBOX_DIR:-}" ]]; then
    printf '%s' "$TPR_BUS_OUTBOX_DIR"
    return 0
  fi

  local vps_entrypoint="$ROOT_DIR/runtime/vps/3ox.station/vec3/bin/teleprompter.rb"
  if [[ "$TPR_ENTRYPOINT" == "$vps_entrypoint" ]]; then
    printf '%s' "$ROOT_DIR/runtime/vps/3ox.station/vec3/var/outbox"
    return 0
  fi

  printf '%s' "$TPR_CMD_ROOT/.vec3/var/telegram_bus/outbox"
}

default_loadtest_reg_path() {
  if [[ -n "${TPR_RELAY_REG_PATH:-}" ]]; then
    printf '%s' "$TPR_RELAY_REG_PATH"
    return 0
  fi

  printf '%s' "$TPR_LOADTEST_REG_PATH"
}

resolve_path() {
  local input="$1"
  if [[ "$input" == /* ]]; then
    printf '%s' "$input"
  else
    printf '%s' "$ROOT_DIR/$input"
  fi
}

require_entrypoint() {
  if [[ -f "$TPR_ENTRYPOINT" ]]; then
    return 0
  fi

  log "entrypoint not found: $TPR_ENTRYPOINT"
  log "set TPR_ENTRYPOINT in $ENV_FILE"
  exit 2
}

require_mesh_entrypoint() {
  if [[ -f "$TPR_MESH_ENTRYPOINT" ]]; then
    return 0
  fi

  log "mesh entrypoint not found: $TPR_MESH_ENTRYPOINT"
  log "set TPR_MESH_ENTRYPOINT in $ENV_FILE"
  exit 2
}

run_build() {
  require_entrypoint

  log "syntax-check entrypoint"
  "$TPR_BIN" -c "$TPR_ENTRYPOINT" >/dev/null

  log "syntax-check subkey tool"
  "$TPR_BIN" -c "$ROOT_DIR/tools/subkeyctl.rb" >/dev/null

  log "syntax-check loadtest tool"
  "$TPR_BIN" -c "$ROOT_DIR/tools/loadtest_bus.rb" >/dev/null

  log "syntax-check speaker mesh"
  "$TPR_BIN" -c "$ROOT_DIR/tools/speaker_mesh.rb" >/dev/null

  log "build checks passed"
}

start_tpr() {
  ensure_runtime_dir
  require_entrypoint

  if pid_alive "$TPR_PID_FILE"; then
    log "telepromptr already running (pid $(cat "$TPR_PID_FILE"))"
    return 0
  fi

  if [[ -z "${TELEGRAM_BOT_TOKEN:-}" ]]; then
    log "TELEGRAM_BOT_TOKEN not set in env; entrypoint may rely on external secrets"
  fi

  local cmd=("$TPR_BIN" "$TPR_ENTRYPOINT")
  append_semicolon_list_args cmd "${TPR_START_ARGS// /;}"

  log "starting telepromptr"
  nohup env \
    TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}" \
    BASE_ID="$TPR_BASE_ID" \
    TPR_KEYS_DIR="$TPR_KEYS_DIR" \
    "${cmd[@]}" >"$TPR_LOG_FILE" 2>&1 &
  echo "$!" > "$TPR_PID_FILE"

  sleep 0.3
  if ! pid_alive "$TPR_PID_FILE"; then
    log "telepromptr exited early"
    if [[ -s "$TPR_LOG_FILE" ]]; then
      sed -n '1,120p' "$TPR_LOG_FILE" >&2 || true
    fi
    rm -f "$TPR_PID_FILE"
    return 1
  fi
}

start_mesh() {
  ensure_runtime_dir
  require_mesh_entrypoint

  if pid_alive "$MESH_PID_FILE"; then
    log "speaker mesh already running (pid $(cat "$MESH_PID_FILE"))"
    return 0
  fi

  local cmd=("$TPR_MESH_BIN" "$TPR_MESH_ENTRYPOINT")
  append_semicolon_list_args cmd "${TPR_MESH_START_ARGS// /;}"

  log "starting speaker mesh"
  nohup env \
    TPR_VAR_DIR="${TPR_VAR_DIR:-$ROOT_DIR/runtime/vps/3ox.station/vec3/var}" \
    TPR_INBOX_DIR="${TPR_INBOX_DIR:-}" \
    TPR_OUTBOX_DIR="${TPR_OUTBOX_DIR:-}" \
    TPR_MESH_CONFIG_PATH="${TPR_MESH_CONFIG_PATH:-$ROOT_DIR/CyberDeck/TPR.SPEAKER.MESH.json}" \
    TPR_MESH_STATE_DIR="${TPR_MESH_STATE_DIR:-$RUNTIME_DIR/mesh}" \
    TPR_MESH_API_KEY="${TPR_MESH_API_KEY:-}" \
    TPR_MESH_API_BASE="${TPR_MESH_API_BASE:-}" \
    TPR_MESH_MODEL="${TPR_MESH_MODEL:-}" \
    OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}" \
    OPENAI_API_KEY="${OPENAI_API_KEY:-}" \
    "${cmd[@]}" >"$MESH_LOG_FILE" 2>&1 &
  echo "$!" > "$MESH_PID_FILE"

  sleep 0.3
  if ! pid_alive "$MESH_PID_FILE"; then
    log "speaker mesh exited early"
    if [[ -s "$MESH_LOG_FILE" ]]; then
      sed -n '1,120p' "$MESH_LOG_FILE" >&2 || true
    fi
    rm -f "$MESH_PID_FILE"
    return 1
  fi
}

cmd_up() {
  start_tpr
  cmd_status
}

cmd_down() {
  kill_from_pid_file "$TPR_PID_FILE"
  log "telepromptr stopped"
}

cmd_restart() {
  cmd_down
  cmd_up
}

cmd_mesh_up() {
  start_mesh
  cmd_status
}

cmd_mesh_down() {
  kill_from_pid_file "$MESH_PID_FILE"
  log "speaker mesh stopped"
}

cmd_mesh_restart() {
  cmd_mesh_down
  cmd_mesh_up
}

cmd_squad_up() {
  start_tpr
  start_mesh
  cmd_status
}

cmd_squad_down() {
  cmd_mesh_down
  cmd_down
}

cmd_squad_status() {
  cmd_status
}

status_line() {
  local name="$1"
  local pid_file="$2"

  if pid_alive "$pid_file"; then
    printf '%-12s %s\n' "$name" "running pid=$(cat "$pid_file")"
  else
    printf '%-12s %s\n' "$name" "stopped"
  fi
}

cmd_status() {
  ensure_runtime_dir
  status_line "telepromptr" "$TPR_PID_FILE"
  status_line "speaker-mesh" "$MESH_PID_FILE"
  status_line "watch" "$WATCH_PID_FILE"
  printf 'entrypoint   %s\n' "$TPR_ENTRYPOINT"
  printf 'mesh-entry   %s\n' "$TPR_MESH_ENTRYPOINT"
  printf 'keys-dir     %s\n' "$TPR_KEYS_DIR"
  printf 'env-file     %s\n' "$ENV_FILE"
  printf 'log-file     %s\n' "$TPR_LOG_FILE"
  printf 'mesh-log     %s\n' "$MESH_LOG_FILE"
  printf 'loadtest-outbox %s\n' "$(default_loadtest_outbox_dir)"
  printf 'loadtest-reg    %s\n' "$(default_loadtest_reg_path)"
}

cmd_logs() {
  ensure_runtime_dir
  if [[ -f "$TPR_LOG_FILE" ]]; then
    tail -n "$FORGE_TAIL_LINES" "$TPR_LOG_FILE"
  else
    log "log file missing: $TPR_LOG_FILE"
    return 2
  fi
}

cmd_mesh_logs() {
  ensure_runtime_dir
  if [[ -f "$MESH_LOG_FILE" ]]; then
    tail -n "$FORGE_TAIL_LINES" "$MESH_LOG_FILE"
  else
    log "mesh log file missing: $MESH_LOG_FILE"
    return 2
  fi
}

cmd_loadtest() {
  local agents="${1:-$FORGE_LOADTEST_AGENTS}"
  local messages="${2:-$FORGE_LOADTEST_MESSAGES_PER_AGENT}"
  TPR_RELAY_OUTBOX_DIR="$(default_loadtest_outbox_dir)" \
    TPR_RELAY_REG_PATH="$(default_loadtest_reg_path)" \
    "$TPR_BIN" "$ROOT_DIR/tools/loadtest_bus.rb" --agents "$agents" --messages "$messages"
}

watch_signature() {
  local file_list="$RUNTIME_DIR/watch.files"
  : > "$file_list"

  local IFS=';'
  read -r -a paths <<< "$FORGE_WATCH_PATHS"

  local rel abs
  for rel in "${paths[@]}"; do
    rel="$(trim "$rel")"
    [[ -n "$rel" ]] || continue

    abs="$(resolve_path "$rel")"
    if [[ -d "$abs" ]]; then
      find "$abs" -type f -print >> "$file_list"
    elif [[ -f "$abs" ]]; then
      printf '%s\n' "$abs" >> "$file_list"
    fi
  done

  if ! [[ -s "$file_list" ]]; then
    printf 'none\n'
    return 0
  fi

  sort "$file_list" | xargs -r sha1sum 2>/dev/null | sha1sum | awk '{print $1}'
}

cmd_watch() {
  ensure_runtime_dir

  if [[ "$FORGE_WATCH_BUILD_ON_START" == "1" ]]; then
    log "build-on-start enabled"
    if ! run_build; then
      log "initial build failed; watch loop not started"
      return 1
    fi
  fi

  cmd_up

  local sig
  sig="$(watch_signature)"
  log "watch started (on_change=$FORGE_WATCH_ON_CHANGE rebuild=$FORGE_WATCH_REBUILD)"

  while true; do
    sleep "$FORGE_WATCH_INTERVAL_S"

    local next_sig
    next_sig="$(watch_signature)"
    if [[ "$next_sig" == "$sig" ]]; then
      continue
    fi

    sig="$next_sig"
    log "change detected"

    case "$FORGE_WATCH_ON_CHANGE" in
      restart)
        if [[ "$FORGE_WATCH_REBUILD" == "1" ]]; then
          if ! run_build; then
            log "build failed; stack paused"
            cmd_down
            continue
          fi
        fi
        cmd_restart
        ;;
      pause)
        cmd_down
        log "stack paused because files changed"
        ;;
      *)
        log "invalid FORGE_WATCH_ON_CHANGE: $FORGE_WATCH_ON_CHANGE (expected restart|pause)"
        ;;
    esac
  done
}

cmd_service_start() {
  ensure_runtime_dir

  if pid_alive "$WATCH_PID_FILE"; then
    log "watch service already running (pid $(cat "$WATCH_PID_FILE"))"
    return 0
  fi

  log "starting watch service in background"
  nohup "$0" watch >"$WATCH_LOG_FILE" 2>&1 &
  echo "$!" > "$WATCH_PID_FILE"

  sleep 0.4
  if ! pid_alive "$WATCH_PID_FILE"; then
    log "watch service exited early; check $WATCH_LOG_FILE"
    rm -f "$WATCH_PID_FILE"
    return 1
  fi

  cmd_status
}

cmd_service_stop() {
  kill_from_pid_file "$WATCH_PID_FILE"
  cmd_down
}

cmd_init() {
  ensure_runtime_dir

  if [[ -f "$ENV_FILE" ]]; then
    log "env exists: $ENV_FILE"
  else
    cp "$FORGE_DIR/.env.example" "$ENV_FILE"
    chmod 600 "$ENV_FILE" 2>/dev/null || true
    log "created $ENV_FILE"
  fi

  chmod 700 "$TPR_KEYS_DIR" 2>/dev/null || true
}

cmd_subkey_create() {
  local agent_id="${1:-}"
  "$TPR_BIN" "$ROOT_DIR/tools/subkeyctl.rb" --keys-dir "$TPR_KEYS_DIR" create "$agent_id"
}

cmd_subkey_rotate() {
  local agent_id="${1:-}"
  "$TPR_BIN" "$ROOT_DIR/tools/subkeyctl.rb" --keys-dir "$TPR_KEYS_DIR" rotate "$agent_id"
}

cmd_subkey_revoke() {
  local agent_id="${1:-}"
  "$TPR_BIN" "$ROOT_DIR/tools/subkeyctl.rb" --keys-dir "$TPR_KEYS_DIR" revoke "$agent_id"
}

cmd_subkey_list() {
  "$TPR_BIN" "$ROOT_DIR/tools/subkeyctl.rb" --keys-dir "$TPR_KEYS_DIR" list
}

usage() {
  cat <<USAGE
Usage: ./_forge/forge.sh <command>

Commands:
  init               create _forge/.env if missing
  build              syntax-check TelePromptR entrypoint + tools
  up                 start TelePromptR runtime
  down               stop TelePromptR runtime
  restart            restart TelePromptR runtime
  mesh-up            start speaker mesh (inbox -> outbox responder)
  mesh-down          stop speaker mesh
  mesh-restart       restart speaker mesh
  mesh-logs          tail speaker mesh log
  squad-up           start TelePromptR + speaker mesh
  squad-down         stop TelePromptR + speaker mesh
  squad-status       show TelePromptR + speaker mesh status
  status             show process and path status
  logs               tail runtime log
  loadtest [A [M]]   enqueue synthetic bus messages (A agents, M msgs/agent)
  watch              auto-rebuild/restart on file changes
  service-start      run watch loop in background
  service-stop       stop background watch loop and runtime

  subkey-create ID   issue secure tgsub key for agent
  subkey-rotate ID   rotate tgsub key for agent
  subkey-revoke ID   revoke tgsub key for agent
  subkey-list        list issued tgsub keys (masked)

Examples:
  ./_forge/forge.sh init
  ./_forge/forge.sh build
  ./_forge/forge.sh up
  ./_forge/forge.sh squad-up
  ./_forge/forge.sh watch
  ./_forge/forge.sh loadtest 24 2
  ./_forge/forge.sh subkey-create metatron
USAGE
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  init)
    cmd_init
    ;;
  build)
    run_build
    ;;
  up)
    cmd_up
    ;;
  down)
    cmd_down
    ;;
  restart)
    cmd_restart
    ;;
  mesh-up)
    cmd_mesh_up
    ;;
  mesh-down)
    cmd_mesh_down
    ;;
  mesh-restart)
    cmd_mesh_restart
    ;;
  mesh-logs)
    cmd_mesh_logs
    ;;
  squad-up)
    cmd_squad_up
    ;;
  squad-down)
    cmd_squad_down
    ;;
  squad-status)
    cmd_squad_status
    ;;
  status)
    cmd_status
    ;;
  logs)
    cmd_logs
    ;;
  loadtest)
    cmd_loadtest "${1:-}" "${2:-}"
    ;;
  watch)
    cmd_watch
    ;;
  service-start)
    cmd_service_start
    ;;
  service-stop)
    cmd_service_stop
    ;;
  subkey-create)
    cmd_subkey_create "${1:-}"
    ;;
  subkey-rotate)
    cmd_subkey_rotate "${1:-}"
    ;;
  subkey-revoke)
    cmd_subkey_revoke "${1:-}"
    ;;
  subkey-list)
    cmd_subkey_list
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    log "unknown command: $cmd"
    usage
    exit 2
    ;;
esac
