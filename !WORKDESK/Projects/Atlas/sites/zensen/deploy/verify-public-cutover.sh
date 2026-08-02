#!/usr/bin/env bash
set -Eeuo pipefail

die() { printf 'cutover: %s\n' "$*" >&2; exit 1; }
: "${PUBLIC_APPROVED:?Set PUBLIC_APPROVED=yes only after the public cutover is approved}"
[[ "$PUBLIC_APPROVED" == yes ]] || die 'PUBLIC_APPROVED must be yes'
: "${PUBLIC_APPROVAL_REF:?Set PUBLIC_APPROVAL_REF to the launch decision or ticket}"
: "${PUBLIC_URL:?Set PUBLIC_URL to the approved HTTPS /index.html URL}"
: "${PUBLIC_CANONICAL_URL:?Set PUBLIC_CANONICAL_URL to the approved canonical origin URL}"
: "${PUBLIC_EXPECTED_HASH:?Set PUBLIC_EXPECTED_HASH to the approved release hash}"

[[ "$PUBLIC_URL" == https://* ]] || die 'PUBLIC_URL must use HTTPS'
[[ "$PUBLIC_URL" == */index.html ]] || die 'PUBLIC_URL must end in /index.html'

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ZENSEN_URL="$PUBLIC_URL" \
ZENSEN_HEALTH_URL="${PUBLIC_HEALTH_URL:-${PUBLIC_URL%/index.html}/healthz}" \
ZENSEN_EXPECTED_HASH="$PUBLIC_EXPECTED_HASH" \
ZENSEN_REQUIRE_SECURITY_HEADERS=yes \
  bash "$script_dir/verify-release.sh"

page="$(curl --fail --silent --show-error --location --retry 3 "$PUBLIC_URL")"
if grep -Eqi 'noindex|nofollow' <<<"$page"; then
  die 'public page still contains noindex/nofollow; remove staging directives before cutover'
fi
grep -Fq "href=\"$PUBLIC_CANONICAL_URL\"" <<<"$page" || die 'approved canonical URL is missing from the public page'

if [[ "${REQUIRE_SEO_ASSETS:-no}" == yes ]]; then
  base_url="${PUBLIC_URL%/index.html}"
  robots_status="$(curl --silent --show-error --location --retry 3 --output /dev/null --write-out '%{http_code}' "$base_url/robots.txt")"
  sitemap_status="$(curl --silent --show-error --location --retry 3 --output /dev/null --write-out '%{http_code}' "$base_url/sitemap.xml")"
  [[ "$robots_status" =~ ^2 ]] || die "robots.txt returned HTTP $robots_status"
  [[ "$sitemap_status" =~ ^2 ]] || die "sitemap.xml returned HTTP $sitemap_status"
fi

printf 'public cutover verified: approval %s, HTTPS, hash, health, security headers, 404, canonical, and no staging robots directives\n' "$PUBLIC_APPROVAL_REF"
