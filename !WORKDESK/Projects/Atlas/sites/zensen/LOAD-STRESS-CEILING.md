# ZENSEN bounded stress-ceiling receipt

Captured: **2026-08-02**  
Purpose: **Find the safe preproduction boundary without claiming 10k capacity**

## Latest serving-path receipt — 2026-08-03

The current local/Tailscale process uses the threaded [`deploy/serve-local.py`](deploy/serve-local.py) rehearsal server. The latest bounded run is recorded in [SERVING-PERFORMANCE-REVIEW.md](SERVING-PERFORMANCE-REVIEW.md): Tailscale p99 is `109.33 ms` at 200 requests / 20 workers; local p99 is `1,888.26 ms` at 1,000 requests / 50 workers. Correctness passed on both, but local performance remains a warning.

## Receipts

| Target | Requests | Concurrency | 2xx | Mean | p95 | p99 | Max | Result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `127.0.0.1:7120/index.html` | 1,000 | 50 | 1,000 | 76.63 ms | 24.18 ms | 2,055.23 ms | 4,371.06 ms | HTTP correctness passed; p99 target exceeded |
| Tailscale `/zensen/index.html` | 200 | 20 | 200 | 114.45 ms | 1,036.59 ms | 2,092.65 ms | 2,095.19 ms | HTTP correctness passed; p99 target exceeded |

All requests returned HTTP 200 and contained the ZENSEN marker. The initial baseline p99 objective is 1,500 ms; both bounded ceiling observations exceeded it. This is a performance warning, not a 10k result.

## Interpretation

- `scale-1` remains a successful bounded correctness/repeatability rehearsal.
- `scale-2` remains pending and must not be marked complete from this receipt.
- Before any public capacity claim, profile the serving path and repeat the test on an approved target with the armed k6 scenario.
- No production or public-domain mutation was made.

## Reproduce

```bash
REQUESTS=1000 CONCURRENCY=50 TARGET='http://127.0.0.1:7120/index.html' node deploy/load/bounded-smoke.mjs
REQUESTS=200 CONCURRENCY=20 TARGET='https://corbato-en0.billfish-sirius.ts.net/zensen/index.html' node deploy/load/bounded-smoke.mjs
```
