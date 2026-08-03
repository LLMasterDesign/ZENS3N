# ZENSEN staging monitor rehearsal

Captured: **2026-08-03**  
Status: **Partial Live Chapter 06 evidence**

`deploy/monitor-staging.sh` repeatedly checks the canonical entry hash, `/healthz`, and a real unknown route. It is safety-bounded to loopback or Tailscale `.ts.net` targets and exits nonzero on any failed sample.

This is a canary rehearsal, not a production uptime monitor. It does not prove alert delivery, paging, rate limiting, cost controls, or 99.9% monthly availability.

## Reproduce

```bash
TARGET='https://corbato-en0.billfish-sirius.ts.net/zensen/index.html' \
HEALTH_URL='https://corbato-en0.billfish-sirius.ts.net/zensen/healthz' \
NOT_FOUND_URL='https://corbato-en0.billfish-sirius.ts.net/zensen/__atlas_monitor_404__' \
EXPECTED_HASH='16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0' \
SAMPLES=30 INTERVAL_S=1 \
bash deploy/monitor-staging.sh
```

The observed command output is attached to the Atlas board as partial evidence for `live-1`; live monitoring and alerting remain open until an approved deployment target exists.
