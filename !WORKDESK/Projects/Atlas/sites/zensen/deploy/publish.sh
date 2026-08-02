#!/usr/bin/env bash
set -Eeuo pipefail

die() { printf 'publish: %s\n' "$*" >&2; exit 1; }

: "${ZENSEN_TARGET:?Set ZENSEN_TARGET to the explicit deploy-user@host target}"
remote_root="${ZENSEN_REMOTE_ROOT:-/srv/zensen}"
case "$remote_root" in
  /srv/zensen|/srv/zensen/*) ;;
  *) die 'ZENSEN_REMOTE_ROOT must stay under /srv/zensen' ;;
esac

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$(realpath "$script_dir/../../../../../Websites/zensensystems")"
[[ -f "$source_dir/index.html" ]] || die "canonical entry missing: $source_dir/index.html"

release_id="$(sha256sum "$source_dir/index.html" | awk '{print substr($1,1,16)}')"
archive="$(mktemp --suffix=.tar.gz zensen-release.XXXXXX)"
trap 'rm -f -- "$archive"' EXIT

tar -czf "$archive" -C "$source_dir" \
  index.html healthz spec.css zen-fonts.css brand fonts spec

qroot="$(printf '%q' "$remote_root")"
qrelease="$(printf '%q' "$release_id")"
remote_release="$remote_root/releases/$release_id"

printf 'release %s -> %s:%s\n' "$release_id" "$ZENSEN_TARGET" "$remote_root"
ssh "$ZENSEN_TARGET" "install -d -m 0755 $qroot/releases $qroot/incoming $qroot/releases/$qrelease"
scp "$archive" "$ZENSEN_TARGET:$remote_root/incoming/$release_id.tar.gz"
ssh "$ZENSEN_TARGET" "tar -xzf $qroot/incoming/$release_id.tar.gz -C $qroot/releases/$qrelease && ln -s $qroot/releases/$qrelease $qroot/.current-$qrelease && mv -Tf $qroot/.current-$qrelease $qroot/current && rm -f $qroot/incoming/$qrelease.tar.gz"
printf 'published release %s; run deploy/verify-release.sh against the public URL\n' "$release_id"
