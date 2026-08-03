# ZENSEN serving-path performance review

Captured: **2026-08-03**  
Environment: **local/Tailscale preproduction**  
Server: [`deploy/serve-local.py`](deploy/serve-local.py)

The original ceiling receipt used Python's single-threaded `http.server`. Atlas now uses a tracked threaded HTTP/1.1 rehearsal server so local concurrency testing does not serialize every request through one handler or an SSH terminal. This improves the Tailscale ingress boundary, but it is still not a production or 10k capacity test.

## Latest bounded receipt

| Target | Requests | Concurrency | 2xx | ZENSEN marker | p95 | p99 | Max | Result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `127.0.0.1:7120/index.html` | 1,000 | 50 | 1,000 | 1,000 | 45.46 ms | 1,888.26 ms | 4,494.77 ms | Correctness passed; local p99 target exceeded |
| Tailscale `/zensen/index.html` | 200 | 20 | 200 | 200 | 81.22 ms | 109.33 ms | 129.39 ms | Correctness and 1.5 s p99 target passed |

Both targets also passed the release verifier: HTTP 200, `healthz=ok`, real unknown-route 404, and entry SHA-256 `16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0`.

## Interpretation

- Tailscale's bounded ceiling is now below the initial p99 target on the threaded path.
- The local host still has a tail above 1.5 seconds at 1,000 requests / 50 workers; do not erase that warning or extrapolate it to 10k users.
- Production capacity still requires the approval-gated k6 ramp/soak on an owned target, plus error-rate, recovery, rollback, and monitoring receipts.

## Reproduce

```bash
python3 deploy/serve-local.py --directory ../../../../Websites/zensensystems --host 0.0.0.0 --port 7120
REQUESTS=1000 CONCURRENCY=50 TARGET='http://127.0.0.1:7120/index.html' node deploy/load/bounded-smoke.mjs
REQUESTS=200 CONCURRENCY=20 TARGET='https://corbato-en0.billfish-sirius.ts.net/zensen/index.html' node deploy/load/bounded-smoke.mjs
```
