#!/usr/bin/env bash
set -euo pipefail

# ▛▞ TelePromptR tui2go :: small operator panel
# 4-pane contract: Setup | Status | Action Bar | Last
#
# Safety:
# - Never print TELEGRAM_BOT_TOKEN
# - Never print agent subkeys (agents.json contains subkey)

SELF_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SELF_DIR/.." && pwd)"

TPR_FORGE_SH="${TPR_FORGE_SH:-$ROOT_DIR/_forge/forge.sh}"
TPR_ENV_FILE="${TPR_ENV_FILE:-$ROOT_DIR/_forge/.env}"
TPR_ENV_EXAMPLE="${TPR_ENV_EXAMPLE:-$ROOT_DIR/_forge/.env.example}"
TPR_VAR_DIR="${TPR_VAR_DIR:-$ROOT_DIR/runtime/vps/3ox.station/vec3/var}"

PROFILE="${TUI2GO_PROFILE:-tpr}"

TUI2GO_REFRESH_S="${TUI2GO_REFRESH_S:-2}"
TUI2GO_STATUS_TIMEOUT_S="${TUI2GO_STATUS_TIMEOUT_S:-4}"
TPR_2GO_THEME="${TPR_2GO_THEME:-${TUI2GO_THEME:-neo}}"

LAST_MSG="ready"
LAST_OUTPUT=""
TICK=0

CONTROL_LABEL="${TUI2GO_CONTROL_LABEL:-TPR CONTROL}"

PROFILE_TITLE="TPR CONTROL"
PROFILE_RUNNER="$TPR_FORGE_SH"
PROFILE_ENV="$TPR_ENV_FILE"

THEME_ORDER=("neo" "amber" "acid" "mono")

ESC=$'\033['
RESET="${ESC}0m"

C_BORDER=""
C_TITLE=""
C_BODY=""
C_ACCENT=""
C_MUTED=""
C_HOT=""

trim() {
  local s="${1:-}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

color() {
  local code="$1"
  shift
  if [[ -t 1 ]]; then
    printf '\033[%sm%s\033[0m\n' "$code" "$*"
  else
    printf '%s\n' "$*"
  fi
}

die() {
  color "31" "[tui2go:$PROFILE] ERROR: $*"
  exit 1
}

configure_profile() {
  case "$PROFILE" in
    tpr)
      PROFILE_TITLE="$CONTROL_LABEL"
      PROFILE_RUNNER="$TPR_FORGE_SH"
      PROFILE_ENV="$TPR_ENV_FILE"
      ;;
    *)
      die "invalid profile: $PROFILE (expected: tpr)"
      ;;
  esac
}

resolve_path() {
  local input="$1"
  if [[ -z "$input" ]]; then
    printf '%s' ""
  elif [[ "$input" == /* ]]; then
    printf '%s' "$input"
  else
    printf '%s' "$ROOT_DIR/$input"
  fi
}

env_value() {
  # Read KEY=VALUE from PROFILE_ENV (best-effort). Never exports.
  local key="$1"
  local default="${2:-}"
  local file="${PROFILE_ENV:-$TPR_ENV_FILE}"

  if ! [[ -f "$file" ]]; then
    printf '%s' "$default"
    return 0
  fi

  local line k v
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -n "$line" ]] || continue
    [[ "${line:0:1}" == "#" ]] && continue
    [[ "$line" == *=* ]] || continue

    k="$(trim "${line%%=*}")"
    [[ "$k" == "$key" ]] || continue

    v="$(trim "${line#*=}")"
    if [[ "$v" =~ ^\".*\"$ ]] || [[ "$v" =~ ^\'.*\'$ ]]; then
      v="${v:1:${#v}-2}"
    fi
    printf '%s' "$v"
    return 0
  done < "$file"

  printf '%s' "$default"
}

runtime_dir_line() {
  local raw d
  raw="$(env_value "FORGE_RUNTIME_DIR" "")"
  d="$(trim "$raw")"
  if [[ -n "$d" ]]; then
    resolve_path "$d"
  else
    printf '%s' "$ROOT_DIR/_forge/runtime"
  fi
}

ensure_env() {
  if [[ -f "$PROFILE_ENV" ]]; then
    return 0
  fi
  [[ -f "$TPR_ENV_EXAMPLE" ]] || die "missing env template: $TPR_ENV_EXAMPLE"
  cp "$TPR_ENV_EXAMPLE" "$PROFILE_ENV"
  chmod 600 "$PROFILE_ENV" 2>/dev/null || true
}

run_with_timeout() {
  local sec="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout -k 1 "${sec}s" "$@"
  else
    "$@"
  fi
}

run_status_cmd() {
  local label="$1"
  shift
  local out rc
  set +e
  out="$(run_with_timeout "$TUI2GO_STATUS_TIMEOUT_S" "$@" 2>&1)"
  rc=$?
  set -e

  if [[ $rc -eq 124 ]] || [[ $rc -eq 137 ]]; then
    echo "$label    timeout (${TUI2GO_STATUS_TIMEOUT_S}s)"
    return 0
  fi
  if [[ $rc -ne 0 ]]; then
    echo "$label    failed ($rc)"
    [[ -n "$out" ]] && echo "$out"
    return 0
  fi
  printf '%s' "$out"
}

apply_theme() {
  case "$TPR_2GO_THEME" in
    neo)
      C_BORDER="${ESC}38;5;45m"
      C_TITLE="${ESC}38;5;214;1m"
      C_BODY="${ESC}38;5;252m"
      C_ACCENT="${ESC}38;5;51m"
      C_MUTED="${ESC}38;5;244m"
      C_HOT="${ESC}38;5;196m"
      ;;
    amber)
      C_BORDER="${ESC}38;5;214m"
      C_TITLE="${ESC}38;5;220;1m"
      C_BODY="${ESC}38;5;255m"
      C_ACCENT="${ESC}38;5;178m"
      C_MUTED="${ESC}38;5;245m"
      C_HOT="${ESC}38;5;160m"
      ;;
    acid)
      C_BORDER="${ESC}38;5;46m"
      C_TITLE="${ESC}38;5;46;1m"
      C_BODY="${ESC}38;5;255m"
      C_ACCENT="${ESC}38;5;255m"
      C_MUTED="${ESC}38;5;245m"
      C_HOT="${ESC}38;5;196m"
      ;;
    mono)
      C_BORDER="${ESC}37m"
      C_TITLE="${ESC}97;1m"
      C_BODY="${ESC}37m"
      C_ACCENT="${ESC}97m"
      C_MUTED="${ESC}90m"
      C_HOT="${ESC}91m"
      ;;
    *)
      TPR_2GO_THEME="neo"
      apply_theme
      return
      ;;
  esac
}

next_theme() {
  local i
  for i in "${!THEME_ORDER[@]}"; do
    if [[ "${THEME_ORDER[$i]}" == "$TPR_2GO_THEME" ]]; then
      TPR_2GO_THEME="${THEME_ORDER[$(((i + 1) % ${#THEME_ORDER[@]}))]}"
      apply_theme
      LAST_MSG="theme :: $TPR_2GO_THEME"
      return
    fi
  done
  TPR_2GO_THEME="neo"
  apply_theme
}

repeat_char() {
  local n="$1"
  local ch="$2"
  if (( n <= 0 )); then
    return
  fi
  printf "%*s" "$n" "" | tr ' ' "$ch"
}

terminal_cols() {
  local cols
  cols="$(tput cols 2>/dev/null || true)"
  if [[ -z "$cols" ]] || ! [[ "$cols" =~ ^[0-9]+$ ]]; then
    cols=120
  fi
  if (( cols < 84 )); then
    cols=84
  fi
  printf '%s' "$cols"
}

spinner_frame() {
  local frames=("[/]" "[|]" "[\\]" "[-]" "[\\]" "[|]")
  printf '%s' "${frames[$((TICK % ${#frames[@]}))]}"
}

blank_block_line() {
  local width="$1"
  printf "%${width}s" ""
}

render_block() {
  local title="$1"
  local content="$2"
  local width="$3"
  local inner=$((width - 2))
  local bodyw=$((inner - 1))
  local rule
  rule="$(repeat_char "$inner" '─')"

  printf '%b┌%s┐%b\n' "$C_BORDER" "$rule" "$RESET"
  printf '%b│%b%-*s%b%b│%b\n' "$C_BORDER" "$C_TITLE" "$inner" " $title" "$RESET" "$C_BORDER" "$RESET"
  printf '%b├%s┤%b\n' "$C_BORDER" "$rule" "$RESET"

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" ]]; then
      printf '%b│%b%-*s%b%b│%b\n' "$C_BORDER" "$C_BODY" "$inner" "" "$RESET" "$C_BORDER" "$RESET"
      continue
    fi
    while IFS= read -r wrapped || [[ -n "$wrapped" ]]; do
      printf '%b│%b %-*s%b%b│%b\n' "$C_BORDER" "$C_BODY" "$bodyw" "$wrapped" "$RESET" "$C_BORDER" "$RESET"
    done < <(printf '%s\n' "$line" | fold -s -w "$bodyw")
  done <<< "$content"

  printf '%b└%s┘%b\n' "$C_BORDER" "$rule" "$RESET"
}

render_two_pane() {
  local left_title="$1"
  local left_content="$2"
  local right_title="$3"
  local right_content="$4"
  local cols pane_width
  cols="$(terminal_cols)"
  pane_width=$(((cols - 2) / 2 - 1))
  if (( pane_width < 38 )); then
    pane_width=38
  fi

  local left_tmp right_tmp
  left_tmp="$(mktemp)"
  right_tmp="$(mktemp)"
  render_block "$left_title" "$left_content" "$pane_width" > "$left_tmp"
  render_block "$right_title" "$right_content" "$pane_width" > "$right_tmp"

  local left_lines right_lines max i l r
  mapfile -t left_lines < "$left_tmp"
  mapfile -t right_lines < "$right_tmp"
  rm -f "$left_tmp" "$right_tmp"

  max=${#left_lines[@]}
  if (( ${#right_lines[@]} > max )); then
    max=${#right_lines[@]}
  fi

  for ((i = 0; i < max; i++)); do
    l="${left_lines[$i]:-$(blank_block_line "$pane_width") }"
    r="${right_lines[$i]:-$(blank_block_line "$pane_width") }"
    printf '%s  %s\n' "$l" "$r"
  done
}

draw_action_bar() {
  local cols inner rule
  cols="$(terminal_cols)"
  inner=$((cols - 2))
  rule="$(repeat_char "$inner" '─')"

  printf '%b┌%s┐%b\n' "$C_BORDER" "$rule" "$RESET"
  printf '%b│%b%-*s%b%b│%b\n' "$C_BORDER" "$C_TITLE" "$inner" " Action Bar" "$RESET" "$C_BORDER" "$RESET"
  printf '%b├%s┤%b\n' "$C_BORDER" "$rule" "$RESET"
  printf '%b│%b %-*s%b%b│%b\n' "$C_BORDER" "$C_ACCENT" $((inner - 1)) "[space] refresh  [t] theme  [u] squad-up  [d] squad-down  [r] restart  [s] service-start  [x] service-stop" "$RESET" "$C_BORDER" "$RESET"
  printf '%b│%b %-*s%b%b│%b\n' "$C_BORDER" "$C_ACCENT" $((inner - 1)) "[l] logs  [m] mesh-logs  [a] agents  [p] topics  [g] git  [q] quit" "$RESET" "$C_BORDER" "$RESET"
  printf '%b└%s┘%b\n' "$C_BORDER" "$rule" "$RESET"
}

draw_last_panel() {
  local cols inner rule
  cols="$(terminal_cols)"
  inner=$((cols - 2))
  rule="$(repeat_char "$inner" '─')"

  printf '%b┌%s┐%b\n' "$C_BORDER" "$rule" "$RESET"
  printf '%b│%b%-*s%b%b│%b\n' "$C_BORDER" "$C_TITLE" "$inner" " Last" "$RESET" "$C_BORDER" "$RESET"
  printf '%b├%s┤%b\n' "$C_BORDER" "$rule" "$RESET"
  printf '%b│%b %-*s%b%b│%b\n' "$C_BORDER" "$C_MUTED" $((inner - 1)) "$LAST_MSG" "$RESET" "$C_BORDER" "$RESET"

  if [[ -n "$LAST_OUTPUT" ]]; then
    while IFS= read -r line; do
      printf '%b│%b %-*s%b%b│%b\n' "$C_BORDER" "$C_BODY" $((inner - 1)) "$line" "$RESET" "$C_BORDER" "$RESET"
    done < <(printf '%s\n' "$LAST_OUTPUT" | tail -n 6 | fold -s -w $((inner - 1)))
  else
    printf '%b│%b %-*s%b%b│%b\n' "$C_BORDER" "$C_BODY" $((inner - 1)) "no action output yet" "$RESET" "$C_BORDER" "$RESET"
  fi

  printf '%b└%s┘%b\n' "$C_BORDER" "$rule" "$RESET"
}

keys_dir_line() {
  # Mirror forge default: <runtime_dir>/keys when env blank/unset.
  local runtime_dir default kd
  runtime_dir="$(runtime_dir_line)"
  default="$runtime_dir/keys"

  kd="$(trim "$(env_value "TPR_KEYS_DIR" "")")"
  if [[ -z "$kd" ]]; then
    kd="$default"
  else
    kd="$(resolve_path "$kd")"
  fi

  printf '%s' "$kd"
}

setup_snapshot() {
  local token_file mesh_cfg route_map kd
  token_file="$TPR_VAR_DIR/telegram_token.json"
  mesh_cfg="$ROOT_DIR/CyberDeck/TPR.SPEAKER.MESH.json"
  route_map="$ROOT_DIR/CyberDeck/TPR.ROUTE.MAP.json"
  kd="$(keys_dir_line)"
  cat <<SETUP
repo      $ROOT_DIR
profile   $PROFILE
runner    $PROFILE_RUNNER
env       $PROFILE_ENV
var       $TPR_VAR_DIR
token     $token_file ($( [[ -f "$token_file" ]] && printf present || printf missing ))
keys_dir  $kd
mesh_cfg  $mesh_cfg ($( [[ -f "$mesh_cfg" ]] && printf present || printf missing ))
route_map $route_map ($( [[ -f "$route_map" ]] && printf present || printf missing ))
theme     $TPR_2GO_THEME
SETUP
}

queues_snapshot_line() {
  local count_json inbox outbox processed inbox_n outbox_n processed_n
  count_json() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
      echo 0
      return 0
    fi
    find "$dir" -maxdepth 1 -type f -name '*.json' 2>/dev/null | wc -l | tr -d ' '
  }
  inbox="$TPR_VAR_DIR/inbox"
  outbox="$TPR_VAR_DIR/outbox"
  processed="$TPR_VAR_DIR/processed"
  inbox_n="$(count_json "$inbox")"
  outbox_n="$(count_json "$outbox")"
  processed_n="$(count_json "$processed")"
  echo "queues      inbox=$inbox_n outbox=$outbox_n processed=$processed_n"
}

agents_count_line() {
  local f="$TPR_VAR_DIR/agents.json"
  if [[ ! -f "$f" ]]; then
    echo "agents      0"
    return 0
  fi
  python3 - "$f" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as fp:
        data = json.load(fp)
except Exception:
    print("agents      0")
    sys.exit(0)
if isinstance(data, dict):
    print(f"agents      {len(data)}")
else:
    print("agents      0")
PY
}

topics_count_line() {
  local f="$TPR_VAR_DIR/topics.json"
  if [[ ! -f "$f" ]]; then
    echo "topics      0"
    return 0
  fi
  python3 - "$f" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as fp:
        data = json.load(fp)
except Exception:
    print("topics      0")
    sys.exit(0)
if isinstance(data, dict):
    print(f"topics      {len(data)}")
else:
    print("topics      0")
PY
}

profile_watch_paths_raw() {
  printf '%s' "$(env_value "FORGE_WATCH_PATHS" "_forge;tools;CyberDeck;runtime/vps;README.md")"
}

watch_file_path() {
  printf '%s' "$(runtime_dir_line)/watch.files"
}

watch_activity_snapshot() {
  local watch_paths watch_file count rel line shown
  watch_paths="$(profile_watch_paths_raw)"
  watch_file="$(watch_file_path)"

  echo "watchset  $watch_paths"

  if [[ -f "$watch_file" ]]; then
    count="$(wc -l < "$watch_file" 2>/dev/null | tr -d ' ')"
    [[ "$count" =~ ^[0-9]+$ ]] || count=0
    echo "watching  files=$count source=${watch_file#$ROOT_DIR/}"

    shown=0
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ -n "$line" ]] || continue
      rel="${line#$ROOT_DIR/}"
      echo "watching  $rel"
      shown=$((shown + 1))
      if (( shown >= 3 )); then
        break
      fi
    done < "$watch_file"
  else
    echo "watching  no watch.files at ${watch_file#$ROOT_DIR/}"
  fi
}

resolve_git_dir() {
  local dotgit="$ROOT_DIR/.git"
  if [[ -d "$dotgit" ]]; then
    printf '%s' "$dotgit"
    return 0
  fi

  if [[ -f "$dotgit" ]]; then
    local line path
    line="$(head -n 1 "$dotgit" 2>/dev/null || true)"
    line="$(trim "$line")"
    if [[ "$line" == gitdir:* ]]; then
      path="$(trim "${line#gitdir:}")"
      if [[ "$path" == /* ]]; then
        printf '%s' "$path"
      else
        printf '%s' "$ROOT_DIR/$path"
      fi
      return 0
    fi
  fi
  return 1
}

resolve_ref_sha() {
  local git_dir="$1"
  local ref="$2"
  local ref_file="$git_dir/$ref"
  if [[ -f "$ref_file" ]]; then
    tr -d '[:space:]' < "$ref_file"
    return 0
  fi

  local packed="$git_dir/packed-refs"
  if [[ -f "$packed" ]]; then
    awk -v r="$ref" '$1 ~ /^[0-9a-fA-F]{40}$/ && $2 == r {sha=$1} END {if (sha != "") print sha}' "$packed"
  fi
}

short_sha() {
  local s="${1:-}"
  if [[ ${#s} -ge 12 ]]; then
    printf '%s' "${s:0:12}"
  else
    printf '%s' "$s"
  fi
}

git_compact_line() {
  local git_dir
  if ! git_dir="$(resolve_git_dir)"; then
    echo "git       repo-missing"
    return 0
  fi

  local head_line branch_ref branch_name local_sha remote_ref remote_sha pending
  head_line="$(head -n 1 "$git_dir/HEAD" 2>/dev/null || true)"
  if [[ "$head_line" != ref:\ * ]]; then
    echo "git       detached-head"
    return 0
  fi

  branch_ref="$(trim "${head_line#ref: }")"
  branch_name="${branch_ref#refs/heads/}"
  local_sha="$(resolve_ref_sha "$git_dir" "$branch_ref")"
  remote_ref="refs/remotes/origin/$branch_name"
  remote_sha="$(resolve_ref_sha "$git_dir" "$remote_ref")"

  pending="unknown"
  if [[ -n "$remote_sha" ]]; then
    if [[ "$local_sha" == "$remote_sha" ]]; then
      pending="no"
    else
      pending="yes"
    fi
  fi

  echo "git       pending=$pending branch=$branch_name local=$(short_sha "$local_sha") remote=$(short_sha "$remote_sha")"
}

commit_queue_snapshot() {
  local git_dir
  if ! git_dir="$(resolve_git_dir)"; then
    echo "queue     repo-missing"
    return 0
  fi

  local head_line branch_ref branch_name local_sha remote_ref remote_sha
  head_line="$(head -n 1 "$git_dir/HEAD" 2>/dev/null || true)"
  if [[ "$head_line" != ref:\ * ]]; then
    echo "queue     detached-head"
    return 0
  fi

  branch_ref="$(trim "${head_line#ref: }")"
  branch_name="${branch_ref#refs/heads/}"
  local_sha="$(resolve_ref_sha "$git_dir" "$branch_ref")"
  remote_ref="refs/remotes/origin/$branch_name"
  remote_sha="$(resolve_ref_sha "$git_dir" "$remote_ref")"

  if [[ -z "$remote_sha" ]]; then
    echo "queue     upstream-missing origin/$branch_name"
    return 0
  fi

  if [[ "$local_sha" == "$remote_sha" ]]; then
    echo "queue     empty"
    return 0
  fi

  local count_out count_rc count
  set +e
  count_out="$(run_with_timeout "$TUI2GO_STATUS_TIMEOUT_S" git --git-dir="$git_dir" rev-list --count "$remote_ref..$branch_ref" 2>/dev/null)"
  count_rc=$?
  set -e

  count="unknown"
  if [[ $count_rc -eq 0 ]] && [[ "$count_out" =~ ^[0-9]+$ ]]; then
    count="$count_out"
  fi
  echo "queue     pending=$count"

  local log_out log_rc
  set +e
  log_out="$(run_with_timeout "$TUI2GO_STATUS_TIMEOUT_S" git --git-dir="$git_dir" log --oneline --max-count 5 "$remote_ref..$branch_ref" 2>/dev/null)"
  log_rc=$?
  set -e

  if [[ $log_rc -eq 0 ]] && [[ -n "$log_out" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ -n "$line" ]] || continue
      echo "commit    $line"
    done <<< "$log_out"
  else
    echo "commit    details-unavailable"
  fi
}

git_monitor_full() {
  local git_dir
  if ! git_dir="$(resolve_git_dir)"; then
    echo "repo      not-a-git-repo"
    return 0
  fi

  local head_line branch_ref branch_name local_sha remote_ref remote_sha
  head_line="$(head -n 1 "$git_dir/HEAD" 2>/dev/null || true)"
  if [[ "$head_line" != ref:\ * ]]; then
    echo "branch    detached"
    echo "pending   unknown"
    return 0
  fi

  branch_ref="$(trim "${head_line#ref: }")"
  branch_name="${branch_ref#refs/heads/}"
  local_sha="$(resolve_ref_sha "$git_dir" "$branch_ref")"
  remote_ref="refs/remotes/origin/$branch_name"
  remote_sha="$(resolve_ref_sha "$git_dir" "$remote_ref")"

  echo "repo      $ROOT_DIR"
  echo "branch    $branch_name"
  echo "local     $(short_sha "$local_sha")"
  if [[ -n "$remote_sha" ]]; then
    echo "remote    $(short_sha "$remote_sha")"
    if [[ "$local_sha" == "$remote_sha" ]]; then
      echo "pending   no (local == upstream)"
    else
      echo "pending   yes (local != upstream)"
    fi
  else
    echo "remote    (missing)"
    echo "pending   unknown"
  fi

  commit_queue_snapshot
}

status_snapshot() {
  local base
  base="$(run_status_cmd "tpr" bash "$PROFILE_RUNNER" status)"
  {
    printf '%s\n' "$base"
    echo "---"
    queues_snapshot_line
    agents_count_line
    topics_count_line
    echo "---"
    watch_activity_snapshot
    echo "---"
    git_compact_line
    commit_queue_snapshot
  } | sed -e 's/[[:space:]]\+$//'
}

draw_screen() {
  local setup status
  setup="$(setup_snapshot)"
  status="$(status_snapshot)"

  printf '\033[H\033[2J'
  printf '%b%s ▛▞ // 2GO // %s%b\n' "$C_TITLE" "$(spinner_frame)" "$PROFILE_TITLE" "$RESET"
  printf '%btheme=%s  4-pane layout%b\n\n' "$C_MUTED" "$TPR_2GO_THEME" "$RESET"
  render_two_pane "Setup" "$setup" "Status" "$status"
  printf '\n'
  draw_action_bar
  draw_last_panel
}

run_action() {
  local action="$1"
  shift
  local out rc
  set +e
  out="$("$@" 2>&1)"
  rc=$?
  set -e

  if [[ $rc -eq 0 ]]; then
    LAST_MSG="ok :: $action"
  else
    LAST_MSG="fail($rc) :: $action"
  fi
  LAST_OUTPUT="$out"
}

run_action_restart() {
  local o1 o2 rc1 rc2
  set +e
  o1="$(bash "$PROFILE_RUNNER" squad-down 2>&1)"; rc1=$?
  o2="$(bash "$PROFILE_RUNNER" squad-up 2>&1)"; rc2=$?
  set -e
  LAST_OUTPUT="$o1"$'\n'"$o2"
  if [[ $rc1 -eq 0 && $rc2 -eq 0 ]]; then
    LAST_MSG="ok :: squad-restart"
  else
    LAST_MSG="fail :: squad-restart"
  fi
}

agents_snapshot() {
  local f="$TPR_VAR_DIR/agents.json"
  if [[ ! -f "$f" ]]; then
    LAST_MSG="agents :: 0"
    LAST_OUTPUT="agents.json missing"
    return 0
  fi
  LAST_MSG="agents snapshot"
  LAST_OUTPUT="$(python3 - "$f" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fp:
    data = json.load(fp)
if not isinstance(data, dict):
    print("agents\t0")
    raise SystemExit(0)
print(f"agents\t{len(data)}")
for name in sorted(data.keys()):
    info = data.get(name) or {}
    if not isinstance(info, dict):
        info = {}
    glyph = info.get("glyph") or info.get("pico_glyph") or "AI"
    status = info.get("status") or "unknown"
    chat_id = info.get("chat_id") or ""
    subs = info.get("subscriptions") or []
    subs_n = len(subs) if isinstance(subs, list) else 0
    last_seen = info.get("last_seen") or ""
    # Never print subkey.
    print(f"{name}\t{glyph}\t{status}\tsubs={subs_n}\tchat={chat_id}\tlast={last_seen}")
PY
)"
}

topics_snapshot() {
  local f="$TPR_VAR_DIR/topics.json"
  if [[ ! -f "$f" ]]; then
    LAST_MSG="topics :: 0"
    LAST_OUTPUT="topics.json missing"
    return 0
  fi
  LAST_MSG="topics snapshot"
  LAST_OUTPUT="$(python3 - "$f" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fp:
    data = json.load(fp)
if not isinstance(data, dict):
    print("topics\t0")
    raise SystemExit(0)
print(f"topics\t{len(data)}")
for key in sorted(data.keys()):
    info = data.get(key) or {}
    if not isinstance(info, dict):
        info = {}
    name = info.get("name") or key
    chat_id = info.get("chat_id") or ""
    thread_id = info.get("thread_id") or ""
    print(f"{name}\tchat={chat_id}\tthread={thread_id}\tkey={key}")
PY
)"
}

cmd_setup() {
  ensure_env
  [[ -x "$PROFILE_RUNNER" ]] || die "runner missing: $PROFILE_RUNNER"
  LAST_MSG="ok :: setup"
  LAST_OUTPUT="env=$( [[ -f \"$PROFILE_ENV\" ]] && printf present || printf missing )"
}

cmd_info() {
  ensure_env
  printf 'repo      %s\n' "$ROOT_DIR"
  printf 'profile   %s\n' "$PROFILE"
  printf 'runner    %s (%s)\n' "$PROFILE_RUNNER" "$( [[ -x "$PROFILE_RUNNER" ]] && printf ready || printf missing )"
  printf 'env_file  %s (%s)\n' "$PROFILE_ENV" "$( [[ -f "$PROFILE_ENV" ]] && printf present || printf missing )"
  printf 'var_dir   %s (%s)\n' "$TPR_VAR_DIR" "$( [[ -d "$TPR_VAR_DIR" ]] && printf present || printf missing )"
  printf 'runtime   %s\n' "$(runtime_dir_line)"
  printf 'theme     %s\n' "$TPR_2GO_THEME"
}

cmd_status() {
  ensure_env
  [[ -x "$PROFILE_RUNNER" ]] || die "runner missing: $PROFILE_RUNNER"
  status_snapshot
}

cmd_wrap() {
  ensure_env
  [[ $# -gt 0 ]] || die "usage: wrap <cmd> [args...]"
  exec "$@"
}

cmd_run() {
  ensure_env
  [[ -x "$PROFILE_RUNNER" ]] || die "runner missing: $PROFILE_RUNNER"

  if ! [[ -t 0 && -t 1 ]]; then
    echo "tui2go requires an interactive terminal (TTY)." >&2
    exit 2
  fi

  apply_theme
  while true; do
    draw_screen
    if IFS= read -rsn1 -t "$TUI2GO_REFRESH_S" key; then
      case "$key" in
        " ")
          LAST_MSG="refresh"
          ;;
        "t"|"T")
          next_theme
          ;;
        "u"|"U")
          run_action "squad-up" bash "$PROFILE_RUNNER" squad-up
          ;;
        "d"|"D")
          run_action "squad-down" bash "$PROFILE_RUNNER" squad-down
          ;;
        "r"|"R")
          run_action_restart
          ;;
        "s"|"S")
          run_action "service-start" bash "$PROFILE_RUNNER" service-start
          ;;
        "x"|"X")
          run_action "service-stop" bash "$PROFILE_RUNNER" service-stop
          ;;
        "l"|"L")
          run_action "logs" bash "$PROFILE_RUNNER" logs
          ;;
        "m"|"M")
          run_action "mesh-logs" bash "$PROFILE_RUNNER" mesh-logs
          ;;
        "a"|"A")
          agents_snapshot
          ;;
        "p"|"P")
          topics_snapshot
          ;;
        "g"|"G")
          LAST_MSG="ok :: git-monitor"
          LAST_OUTPUT="$(git_monitor_full)"
          ;;
        "q"|"Q")
          break
          ;;
        *)
          LAST_MSG="key ignored :: $key"
          ;;
      esac
    fi
    TICK=$((TICK + 1))
  done
}

usage() {
  cat <<USAGE
Usage: ./tui2go/tui2go.sh [--profile tpr] <command>

Commands:
  run|2go|tui   launch interactive panel (default)
  setup         create _forge/.env if missing (no secrets printed)
  info          show wiring
  status        print status snapshot (non-interactive)
  git-monitor   show git compact status + pending commits (if repo)
  wrap <cmd..>  run a command (this panel does not export secrets)

Runtime proxies:
  init build up down restart
  mesh-up mesh-down mesh-restart mesh-logs
  squad-up squad-down squad-status
  logs loadtest watch service-start service-stop

Env:
  TUI2GO_PROFILE=tpr
  TUI2GO_CONTROL_LABEL="TPR CONTROL"
  TPR_FORGE_SH=$TPR_FORGE_SH
  TPR_ENV_FILE=$TPR_ENV_FILE
  TPR_VAR_DIR=$TPR_VAR_DIR
  TPR_2GO_THEME=neo|amber|acid|mono
USAGE
}

if [[ "${1:-}" == "--profile" ]]; then
  PROFILE="${2:-}"
  shift 2 || true
fi
cmd="${1:-run}"
if [[ $# -gt 0 ]]; then
  shift
fi

configure_profile

case "$cmd" in
  run|2go|2go-tui|tui2go|tui|panel)
    cmd_run "$@"
    ;;
  setup)
    cmd_setup "$@"
    ;;
  info)
    cmd_info "$@"
    ;;
  status)
    cmd_status "$@"
    ;;
  git-monitor|push-status|git)
    git_monitor_full
    ;;
  wrap)
    cmd_wrap "$@"
    ;;
  init|build|up|down|restart|mesh-up|mesh-down|mesh-restart|mesh-logs|squad-up|squad-down|squad-status|logs|loadtest|watch|service-start|service-stop)
    exec "$PROFILE_RUNNER" "$cmd" "$@"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    die "unknown command: $cmd"
    ;;
esac

# :: ∎
