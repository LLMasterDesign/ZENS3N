# ZENSEN bounded load rehearsal

Captured: **2026-08-02**

This is the repeatable Chapter 04 / `scale-1` rehearsal. It exercises the approved local and Tailscale preproduction surfaces without claiming 10,000-user capacity. The harness is [bounded-smoke.mjs](deploy/load/bounded-smoke.mjs); it accepts only `localhost`, loopback, or a Tailscale `.ts.net` host, caps each run at 1,000 requests and 50 concurrent workers, and fails on any non-2xx response or missing `ZENSEN` body marker.

## Receipts

| Target | Requests | Concurrency | 2xx | ZENSEN body | Mean | p95 | p99 | Max | Wall |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `127.0.0.1:7120/index.html` | 500 | 25 | 500 | 500 | 45.72 ms | 10.16 ms | 1,271.44 ms | 1,479.58 ms | 1,504.02 ms |
| Tailscale `/zensen/index.html` | 100 | 10 | 100 | 100 | 24.52 ms | 56.93 ms | 83.92 ms | 1,055.54 ms | 1,202.72 ms |

Both runs completed with `all_2xx: true` and `all_contain_zensen: true`. The local p99 remained below the initial 1.5-second target, but this small rehearsal is not evidence of production capacity or a 10k concurrency result.

## Reproduce

```bash
REQUESTS=500 CONCURRENCY=25 \
  TARGET='http://127.0.0.1:7120/index.html' \
  node deploy/load/bounded-smoke.mjs

REQUESTS=100 CONCURRENCY=10 \
  TARGET='https://corbato-en0.billfish-sirius.ts.net/zensen/index.html' \
  node deploy/load/bounded-smoke.mjs
```

The separate `10k.js` k6 scenario remains armed and approval-gated for a properly owned test environment.
