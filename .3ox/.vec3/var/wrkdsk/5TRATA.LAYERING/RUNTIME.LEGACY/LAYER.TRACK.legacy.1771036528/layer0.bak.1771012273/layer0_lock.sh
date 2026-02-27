#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${LAYER0_ENV_FILE:-$SCRIPT_DIR/layer0.paths.env}"
CONTRACT_FILE="$SCRIPT_DIR/LAYER0.CONTRACT.toml"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "layer0.lock: env file not found: $ENV_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf "[dry-run]"
    printf " %q" "$@"
    printf "\n"
    return 0
  fi
  "$@"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "layer0.lock: missing required command: $1" >&2
    exit 1
  fi
}

require_cmd rsync

echo "layer0.lock: validating Layer-0 paths"
for path in "$LAYER0_WSL_TRON" "$LAYER0_V_TRON" "$LAYER0_RELAY_ROOT"; do
  if [[ ! -d "$path" ]]; then
    echo "layer0.lock: missing directory: $path" >&2
    exit 1
  fi
done

run_cmd mkdir -p \
  "$LAYER0_LOCAL_META/receipts" \
  "$LAYER0_LOCAL_META/logs" \
  "$LAYER0_LOCAL_META/state"

run_cmd mkdir -p \
  "$LAYER0_RELAY_META/receipts" \
  "$LAYER0_RELAY_META/logs" \
  "$LAYER0_RELAY_META/state"

run_cmd touch "$LAYER0_RECEIPTS_JSONL"

if [[ -f "$CONTRACT_FILE" ]]; then
  run_cmd cp "$CONTRACT_FILE" "$LAYER0_LOCAL_META/LAYER0.CONTRACT.toml"
  run_cmd cp "$CONTRACT_FILE" "$LAYER0_RELAY_META/LAYER0.CONTRACT.toml"
fi

echo "layer0.lock: initial alignment push WSL -> V:"
if [[ "$DRY_RUN" -eq 1 ]]; then
  printf "[dry-run] rsync -a --delete --exclude .layer0/ --exclude .git/ --exclude *.swp --exclude *.tmp %q %q\n" \
    "$LAYER0_WSL_TRON/" \
    "$LAYER0_V_TRON/"
else
  rsync -a --delete \
    --exclude ".layer0/" \
    --exclude ".git/" \
    --exclude "*.swp" \
    --exclude "*.tmp" \
    "$LAYER0_WSL_TRON/" \
    "$LAYER0_V_TRON/"
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  printf '{"ts":"%s","service":"layer0.lock","level":"INFO","event":"layer0.lock.applied","source":"%s","target":"%s"}\n' \
    "$now" \
    "$LAYER0_WSL_TRON" \
    "$LAYER0_V_TRON" >> "$LAYER0_RECEIPTS_JSONL"
fi

echo "layer0.lock: done"
