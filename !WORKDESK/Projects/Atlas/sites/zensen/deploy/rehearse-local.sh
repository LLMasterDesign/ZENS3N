#!/usr/bin/env bash
set -Eeuo pipefail

die() { printf 'rehearse: %s\n' "$*" >&2; exit 1; }

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$(realpath "$script_dir/../../../../../Websites/zensensystems")"
[[ -f "$source_dir/index.html" ]] || die "canonical entry missing: $source_dir/index.html"

port="${PORT:-7131}"
[[ "$port" =~ ^[0-9]+$ ]] || die 'PORT must be numeric'
expected_hash="$(sha256sum "$source_dir/index.html" | awk '{print $1}')"
release_id="${expected_hash:0:16}"
tmp_root="$(mktemp -d /tmp/zensen-rehearsal.XXXXXX)"
server_pid=""
cleanup() {
  if [[ -n "$server_pid" ]]; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  rm -rf -- "$tmp_root"
}
trap cleanup EXIT

mkdir -p "$tmp_root/releases/baseline-$release_id" "$tmp_root/releases/candidate-$release_id"
tar -czf "$tmp_root/release.tar.gz" -C "$source_dir" index.html 404.html healthz spec.css zen-fonts.css brand fonts spec
tar -xzf "$tmp_root/release.tar.gz" -C "$tmp_root/releases/baseline-$release_id"
tar -xzf "$tmp_root/release.tar.gz" -C "$tmp_root/releases/candidate-$release_id"
printf 'candidate\n' > "$tmp_root/releases/candidate-$release_id/.atlas-rehearsal-marker"

switch_current() {
  local release="$1"
  ln -s "$tmp_root/releases/$release" "$tmp_root/.current-$release"
  mv -Tf "$tmp_root/.current-$release" "$tmp_root/current"
}

check_current() {
  local label="$1"
  local actual
  local status
  status="$(curl --fail --silent --show-error --output /dev/null --write-out '%{http_code}' "http://127.0.0.1:$port/current/index.html")"
  actual="$(curl --fail --silent --show-error "http://127.0.0.1:$port/current/index.html" | sha256sum | awk '{print $1}')"
  [[ "$status" == 200 ]] || die "$label entry returned HTTP $status"
  [[ "$actual" == "$expected_hash" ]] || die "$label hash mismatch: $actual"
  [[ "$(curl --fail --silent --show-error "http://127.0.0.1:$port/current/healthz")" == ok ]] || die "$label health failed"
  printf '%s: HTTP %s, hash %s, health ok\n' "$label" "$status" "$actual"
}

switch_current "baseline-$release_id"
python3 -m http.server "$port" --bind 127.0.0.1 --directory "$tmp_root" >"$tmp_root/server.log" 2>&1 &
server_pid=$!
for _ in {1..30}; do
  if curl --fail --silent "http://127.0.0.1:$port/current/healthz" >/dev/null 2>&1; then break; fi
  sleep 0.1
done
check_current 'initial release'

switch_current "candidate-$release_id"
check_current 'candidate switch'

switch_current "baseline-$release_id"
check_current 'rollback'

kill "$server_pid"
wait "$server_pid" 2>/dev/null || true
server_pid=""
python3 -m http.server "$port" --bind 127.0.0.1 --directory "$tmp_root" >"$tmp_root/server-restart.log" 2>&1 &
server_pid=$!
for _ in {1..30}; do
  if curl --fail --silent "http://127.0.0.1:$port/current/healthz" >/dev/null 2>&1; then break; fi
  sleep 0.1
done
check_current 'post-restart rollback'
printf 'deployment rehearsal passed: atomic switch, rollback, and restart\n'
