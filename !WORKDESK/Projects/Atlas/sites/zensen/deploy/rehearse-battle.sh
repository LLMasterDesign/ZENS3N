#!/usr/bin/env bash
set -Eeuo pipefail

die() { printf 'battle: %s\n' "$*" >&2; exit 1; }

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$(realpath "$script_dir/../../../../../Websites/zensensystems")"
smoke="$(realpath "$script_dir/load/bounded-smoke.mjs")"
[[ -f "$source_dir/index.html" ]] || die "canonical entry missing: $source_dir/index.html"
[[ -f "$smoke" ]] || die "bounded smoke harness missing: $smoke"

port="${PORT:-7141}"
[[ "$port" =~ ^[0-9]+$ ]] || die 'PORT must be numeric'
expected_hash="$(sha256sum "$source_dir/index.html" | awk '{print $1}')"
tmp_root="$(mktemp -d /tmp/zensen-battle.XXXXXX)"
server_pid=""
cleanup() {
  if [[ -n "$server_pid" ]]; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  rm -rf -- "$tmp_root"
}
trap cleanup EXIT

mkdir -p "$tmp_root/releases/baseline" "$tmp_root/releases/candidate"
cp -a "$source_dir/." "$tmp_root/releases/baseline/"
cp -a "$source_dir/." "$tmp_root/releases/candidate/"
rm -f -- "$tmp_root/releases/candidate/healthz"

switch_current() {
  local release="$1"
  ln -s "$tmp_root/releases/$release" "$tmp_root/.current-$release"
  mv -Tf "$tmp_root/.current-$release" "$tmp_root/current"
}

check_ready() {
  local label="$1"
  local status actual
  status="$(curl --fail --silent --show-error --output /dev/null --write-out '%{http_code}' "http://127.0.0.1:$port/current/index.html")"
  actual="$(curl --fail --silent --show-error "http://127.0.0.1:$port/current/index.html" | sha256sum | awk '{print $1}')"
  [[ "$status" == 200 ]] || die "$label entry returned HTTP $status"
  [[ "$actual" == "$expected_hash" ]] || die "$label hash mismatch: $actual"
  [[ "$(curl --fail --silent --show-error "http://127.0.0.1:$port/current/healthz")" == ok ]] || die "$label health failed"
  printf '%s: HTTP %s, hash %s, health ok\n' "$label" "$status" "$actual"
}

expect_not_ready() {
  if curl --fail --silent --show-error "http://127.0.0.1:$port/current/healthz" >/dev/null; then
    die 'bad candidate unexpectedly passed health check'
  fi
  printf 'bad candidate correctly rejected: health check failed\n'
}

switch_current baseline
python3 -m http.server "$port" --bind 127.0.0.1 --directory "$tmp_root" >"$tmp_root/server.log" 2>&1 &
server_pid=$!
for _ in {1..30}; do
  if curl --fail --silent "http://127.0.0.1:$port/current/healthz" >/dev/null 2>&1; then break; fi
  sleep 0.1
done
check_ready 'baseline'

REQUESTS=1000 CONCURRENCY=50 TARGET="http://127.0.0.1:$port/current/index.html" node "$smoke" >"$tmp_root/soak.json"
printf 'bounded soak passed: %s\n' "$(jq -c '{requests,concurrency,successes,p95_ms,p99_ms}' "$tmp_root/soak.json")"
REQUESTS=250 CONCURRENCY=50 TARGET="http://127.0.0.1:$port/current/index.html" node "$smoke" >"$tmp_root/spike.json"
printf 'bounded spike passed: %s\n' "$(jq -c '{requests,concurrency,successes,p95_ms,p99_ms}' "$tmp_root/spike.json")"

switch_current candidate
expect_not_ready
switch_current baseline
check_ready 'rollback after bad candidate'

kill "$server_pid"
wait "$server_pid" 2>/dev/null || true
server_pid=""
if curl --fail --silent --show-error "http://127.0.0.1:$port/current/healthz" >/dev/null; then
  die 'dead server unexpectedly answered'
fi
printf 'process failure correctly observed: health request failed\n'

python3 -m http.server "$port" --bind 127.0.0.1 --directory "$tmp_root" >"$tmp_root/server-restart.log" 2>&1 &
server_pid=$!
for _ in {1..30}; do
  if curl --fail --silent "http://127.0.0.1:$port/current/healthz" >/dev/null 2>&1; then break; fi
  sleep 0.1
done
check_ready 'post-restart recovery'
printf 'battle rehearsal passed: bounded soak, spike, bad-release rejection, rollback, process-failure observation, and restart recovery\n'
printf 'coverage boundary: VPS/Nginx/DNS/TLS, production backups/alerts/paging, and 10k capacity remain unverified\n'
