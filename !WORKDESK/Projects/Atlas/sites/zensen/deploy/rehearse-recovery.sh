#!/usr/bin/env bash
set -Eeuo pipefail

die() { printf 'recovery: %s\n' "$*" >&2; exit 1; }

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$(realpath "$script_dir/../../../../../Websites/zensensystems")"
[[ -f "$source_dir/index.html" ]] || die "canonical entry missing: $source_dir/index.html"
[[ -f "$source_dir/healthz" ]] || die "healthz missing: $source_dir/healthz"

expected_hash="$(sha256sum "$source_dir/index.html" | awk '{print $1}')"
tmp_root="$(mktemp -d /tmp/zensen-recovery.XXXXXX)"
cleanup() { rm -rf -- "$tmp_root"; }
trap cleanup EXIT

tar -czf "$tmp_root/release.tar.gz" -C "$source_dir" index.html 404.html healthz spec.css zen-fonts.css brand fonts spec
mkdir -p "$tmp_root/restored"

started_ns="$(date +%s%N)"
tar -xzf "$tmp_root/release.tar.gz" -C "$tmp_root/restored"
restored_hash="$(sha256sum "$tmp_root/restored/index.html" | awk '{print $1}')"
[[ "$restored_hash" == "$expected_hash" ]] || die "restored hash mismatch: $restored_hash"
[[ "$(cat "$tmp_root/restored/healthz")" == ok ]] || die 'restored healthz mismatch'
finished_ns="$(date +%s%N)"
elapsed_ms="$(( (finished_ns - started_ns) / 1000000 ))"

printf 'recovery rehearsal passed: archive restore, exact hash, and healthz=ok; restore_ms=%s\n' "$elapsed_ms"
printf 'coverage boundary: alert delivery, production backup, VPS restore, and incident paging remain unverified\n'
