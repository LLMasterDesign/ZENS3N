#!/usr/bin/env bash
set -Eeuo pipefail

die() { printf 'monitor: %s\n' "$*" >&2; exit 2; }

target="${TARGET:-}"
health_url="${HEALTH_URL:-}"
not_found_url="${NOT_FOUND_URL:-}"
expected_hash="${EXPECTED_HASH:-}"
samples="${SAMPLES:-30}"
interval_s="${INTERVAL_S:-1}"
timeout_s="${TIMEOUT_S:-10}"

[[ -n "$target" ]] || die 'set TARGET'
[[ -n "$health_url" ]] || die 'set HEALTH_URL'
[[ -n "$not_found_url" ]] || die 'set NOT_FOUND_URL'
[[ "$expected_hash" =~ ^[0-9a-f]{64}$ ]] || die 'EXPECTED_HASH must be a 64-character SHA-256 value'
[[ "$samples" =~ ^[1-9][0-9]*$ ]] || die 'SAMPLES must be a positive integer'
[[ "$interval_s" =~ ^[0-9]+([.][0-9]+)?$ ]] || die 'INTERVAL_S must be numeric'
[[ "$timeout_s" =~ ^[1-9][0-9]*$ ]] || die 'TIMEOUT_S must be a positive integer'

case "$target" in
  http://localhost:*/*|http://127.0.0.1:*/*|https://*.ts.net/*) ;;
  *) die 'TARGET is safety-bounded to localhost, loopback, or a Tailscale .ts.net host' ;;
esac

tmp_root="$(mktemp -d /tmp/zensen-monitor.XXXXXX)"
cleanup() { rm -rf -- "$tmp_root"; }
trap cleanup EXIT

successes=0
failures=0
hash_matches=0
health_passes=0
not_found_passes=0
max_ms=0
first_error=''

for ((sample = 1; sample <= samples; sample += 1)); do
  started_ns="$(date +%s%N)"
  sample_error=''
  page_file="$tmp_root/page-$sample"
  if ! curl --silent --show-error --fail --max-time "$timeout_s" --output "$page_file" "$target"; then
    sample_error='entry request failed'
  else
    actual_hash="$(sha256sum "$page_file" | awk '{print $1}')"
    if [[ "$actual_hash" == "$expected_hash" ]]; then
      hash_matches=$((hash_matches + 1))
    else
      sample_error="entry hash mismatch: $actual_hash"
    fi
  fi

  if [[ -z "$sample_error" ]]; then
    if [[ "$(curl --silent --show-error --fail --max-time "$timeout_s" "$health_url")" == ok ]]; then
      health_passes=$((health_passes + 1))
    else
      sample_error='health check failed'
    fi
  fi

  if [[ -z "$sample_error" ]]; then
    not_found_status="$(curl --silent --show-error --max-time "$timeout_s" --output /dev/null --write-out '%{http_code}' "$not_found_url" || true)"
    if [[ "$not_found_status" == 404 ]]; then
      not_found_passes=$((not_found_passes + 1))
    else
      sample_error="unknown route returned HTTP $not_found_status"
    fi
  fi

  finished_ns="$(date +%s%N)"
  elapsed_ms="$(( (finished_ns - started_ns) / 1000000 ))"
  (( elapsed_ms > max_ms )) && max_ms="$elapsed_ms"
  if [[ -z "$sample_error" ]]; then
    successes=$((successes + 1))
  else
    failures=$((failures + 1))
    [[ -n "$first_error" ]] || first_error="$sample_error"
  fi
  sleep "$interval_s"
done

printf '{"target":"%s","samples":%d,"successes":%d,"failures":%d,"hash_matches":%d,"health_passes":%d,"not_found_404":%d,"max_sample_ms":%d,"first_error":"%s"}\n' \
  "$target" "$samples" "$successes" "$failures" "$hash_matches" "$health_passes" "$not_found_passes" "$max_ms" "$first_error"

if (( failures > 0 )); then exit 1; fi
