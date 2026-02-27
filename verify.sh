#!/usr/bin/env bash
# ZENS3N.CMD Validator

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +"%Y-%m-%d %H:%M:%S")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok=0; warn=0; fail=0
status_ok()  { echo -e "${GREEN}OK${NC}"; : $((ok++)); }
status_warn(){ echo -e "${YELLOW}WARN${NC}"; : $((warn++)); }
status_fail(){ echo -e "${RED}FAIL${NC}"; : $((fail++)); }

echo "▞ Verifying !ZENS3N.CMD at $TS"
echo "=============================="

# 1) ZENS3N.BASE folder
printf "ZENS3N.BASE folder ... "
if [ -d "$BASE_DIR/ZENS3N.BASE" ]; then status_ok; else status_warn; fi

# 2) Lab chamber traces (best-effort)
printf "Z.3-* CHAMBER traces ... "
if rg -n "Z.3-.*CHAMBER" "$BASE_DIR" >/dev/null 2>&1; then status_ok; else status_warn; fi

# 3) Built artifacts (3ox-explorer target) optional
printf "3ox-explorer target artifacts ... "
if rg -n "3ox-explorer/target" "$BASE_DIR" >/dev/null 2>&1; then status_ok; else status_warn; fi

overall="OK"; [ $fail -gt 0 ] && overall="FAIL" || { [ $warn -gt 0 ] && overall="WARN" || true; }

cat > "$BASE_DIR/STATUS.md" <<EOF
# !ZENS3N.CMD — Status

Time: $TS
Overall: $overall

Checks
- ZENS3N.BASE: $( [ -d "$BASE_DIR/ZENS3N.BASE" ] && echo present || echo missing )
- Z.3-* chamber traces: $( rg -n "Z.3-.*CHAMBER" "$BASE_DIR" >/dev/null 2>&1 && echo found || echo none )
- 3ox-explorer/target: $( rg -n "3ox-explorer/target" "$BASE_DIR" >/dev/null 2>&1 && echo found || echo none )

Notes
- This validator is non-destructive and summarizes presence.

EOF

echo "--------------------------------"
echo "OK: $ok | WARN: $warn | FAIL: $fail"
exit 0
