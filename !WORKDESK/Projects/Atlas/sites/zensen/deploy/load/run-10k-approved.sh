#!/usr/bin/env bash
set -Eeuo pipefail

die() { printf '10k-preflight: %s\n' "$*" >&2; exit 1; }

[[ -n "${TARGET:-}" ]] || die 'set TARGET to an owned ZENSEN URL.'
[[ "${ARMED:-}" == yes ]] || die 'set ARMED=yes during the approved test window.'
[[ "${APPROVED_TARGET:-}" == yes ]] || die 'set APPROVED_TARGET=yes only after the target and test window are approved.'
[[ -n "${APPROVAL_REF:-}" ]] || die 'set APPROVAL_REF to the launch decision, ticket, or incident record.'

command -v k6 >/dev/null 2>&1 || die 'k6 is not installed; install it before the approved run.'
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec k6 run "$script_dir/10k.js"
