#!/usr/bin/env bash
set -Eeuo pipefail

die() { printf 'verify: %s\n' "$*" >&2; exit 1; }
: "${ZENSEN_URL:?Set ZENSEN_URL to the canonical /index.html URL}"
: "${ZENSEN_EXPECTED_HASH:?Set ZENSEN_EXPECTED_HASH to the canonical index SHA-256}"

status="$(curl --fail --silent --show-error --location --retry 3 --output /dev/null --write-out '%{http_code}' "$ZENSEN_URL")"
[[ "$status" =~ ^2 ]] || die "entry returned HTTP $status"

health_url="${ZENSEN_HEALTH_URL:-${ZENSEN_URL%/index.html}/healthz}"
health="$(curl --fail --silent --show-error --location --retry 3 "$health_url")"
[[ "$health" == "ok" || "$health" == $'ok\n' ]] || die "health endpoint returned unexpected body"

actual="$(curl --fail --silent --show-error --location --retry 3 "$ZENSEN_URL" | sha256sum | awk '{print $1}')"
[[ "$actual" == "$ZENSEN_EXPECTED_HASH" ]] || die "hash mismatch: expected $ZENSEN_EXPECTED_HASH, got $actual"

base_url="${ZENSEN_BASE_URL:-${ZENSEN_URL%/index.html}}"
not_found_status="$(curl --silent --show-error --location --retry 3 --output /dev/null --write-out '%{http_code}' "$base_url/__atlas_404_check__")"
[[ "$not_found_status" == 404 ]] || die "unknown route returned HTTP $not_found_status instead of 404"

if [[ "${ZENSEN_REQUIRE_SECURITY_HEADERS:-no}" == yes ]]; then
  headers="$(curl --fail --silent --show-error --location --retry 3 --dump-header - --output /dev/null "$ZENSEN_URL")"
  for header in X-Content-Type-Options X-Frame-Options Referrer-Policy Permissions-Policy; do
    grep -Eqi "^${header}:" <<<"$headers" || die "required security header missing: $header"
  done
fi

printf 'verified HTTP %s, health ok, 404 ok, SHA-256 %s\n' "$status" "$actual"
