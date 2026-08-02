# ZENSEN launch baseline

Status: **Tailscale preproduction verified · GitHub and production gates open**
Captured: 2026-08-01
Owner: **ZENSEN Systems / WrkDsk**

This is the first execution artifact behind the Atlas launch board. It defines what must be true before ZENSEN moves from the local Tailscale rehearsal to a GitHub release and, later, an approved production deployment. The targets below are acceptance criteria to prove; they are not claims that 10,000-user capacity has already been demonstrated.

## Mission target

Prove the canonical ZENSEN company page locally and through Tailscale, release the exact source to GitHub after approval, then deploy to an approved production target with a repeatable release, observable behavior, tested recovery, and capacity evidence for **10,000 concurrent users**.

## Service-level objectives

| Signal | Initial launch target | Evidence required |
| --- | --- | --- |
| Availability | ≥ 99.9% monthly after launch | Uptime monitor and incident log |
| HTML and critical asset latency | p95 ≤ 750 ms, p99 ≤ 1.5 s at the 10k test load | Timestamped load-test report |
| Request errors | < 0.1% during smoke, ramp, soak, and spike tests | Access logs plus test output |
| Recovery time objective | Restore service within 15 minutes | Timed rollback or restore drill |
| Recovery point objective | No more than 1 hour of unrecoverable change | Versioned artifact and backup record |

These targets apply to the public company page and its critical local assets first. Any dynamic service, form, analytics, or account boundary must receive its own SLO before it is added to the launch surface.

## Environments and source of truth

| Environment | Location | State |
| --- | --- | --- |
| Canonical source | `Websites/zensensystems/` | Active source of truth |
| Local verification | `http://127.0.0.1:7120/` | HTTP 200; entry hash verified |
| Staging ingress | `https://corbato-en0.billfish-sirius.ts.net/zensen/` | HTTP 200; entry hash verified |
| Production VPS | Not provisioned; approval-gated | Future gate |
| GitHub repository | `LLMasterDesign/ZENS3N`, draft PR #21 open | Review/merge gate |
| Public domain | Existing coming-soon surface | Future gate |

No duplicate ZENSEN source may be introduced. The quarantined `Websites/zensensystems.com` folder is not an active surface.

## Target-selection receipt

The workspace references `slate-rt.billfish-sirius.ts.net` as a public HTTPS edge. A read-only check on 2026-08-01 reached the node over Tailscale (`100.125.230.71`), but the available `abzu` and `root` SSH identities were rejected. No files, routes, or services were changed. Treat `slate-rt` as an edge candidate only. It is not a production target. No paid infrastructure is authorized at this stage.

## Current release receipt

- Entry file: `Websites/zensensystems/index.html`
- SHA-256: `16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0`
- Size: `58,144` bytes
- Known-good rollback file: `_versions/index.v1.0.hero-locked.⧗-26.366.html`
- Rollback SHA-256: `b4de78a56ade73fbdc3206f175b7fbe614e46760c6054527b2aaea382b0b65ae`
- Release branch: `agent/zensen-systems-site`
- Release commit: `f2450256d6fe81802df85a524e50e99373627c80`
- Draft PR: `https://github.com/LLMasterDesign/ZENS3N/pull/21`

The local origin and Tailscale ingress both returned HTTP 200 and `58,144` bytes during this baseline capture. Their response body hash matched the canonical entry hash above.

## Product-surface review receipt

- HTML validation: passed for `index.html` and all three `spec/*.html` documents.
- Responsive contract: viewport metadata, mobile media rules, reduced-motion rules, and keyboard focus styles are present on the product surfaces.
- Accessibility structure: every product page has one `h1`; the only image is explicitly decorative with `alt=""`; the menu button has `type="button"` and an accessible label.
- Internal routes/assets: all relative links and asset references resolve from the canonical source.
- Limitation: no browser runtime is installed on this host, so rendered visual/pixel review remains open.

## Bounded Tailscale rehearsal receipt

This is a smoke/load signal for the current static server, not a 10,000-user capacity claim:

| Target | Requests | Concurrency | 2xx | Mean response | Max response | Wall time |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `127.0.0.1:7120/index.html` | 500 | 25 | 500 | 21.4 ms | 1.060 s | 1.13 s |
| Tailscale `/zensen/index.html` | 100 | 10 | 100 | 40.9 ms | 1.059 s | 1.07 s |

The probe used `curl` only because `k6`, `wrk`, `ab`, and `hey` are not installed on this host. The armed `deploy/load/10k.js` remains the proper capacity gate after an approved test environment exists.

## Chapter 01 acceptance gate

- [x] Canonical folder, entry file, and rollback artifact identified.
- [x] Current release hash recorded.
- [x] Local origin verified.
- [x] Staging ingress verified.
- [x] Shared `/healthz` contract verified on local and staging ingress.
- [x] Candidate edge checked without mutating remote state.
- [x] No paid deployment initiated before approval.
- [x] GitHub repository selected, secret-scanned, and draft PR pushed after approval.
- [ ] Draft PR reviewed and merged.
- [ ] Production target provisioned and hardened after approval.
- [ ] DNS/TLS and public-domain cutover verified after approval.
- [ ] 10k concurrency ramp and soak evidence captured.
- [ ] Restore, rollback, and incident drills timed.

The board remains `PLANNING` until the unchecked gates have receipts. Checking a box in the Loom records local operator progress; it does not replace the evidence listed here.

## Execution pack

- Deployment runbook: `deploy/README.md`
- Atomic publisher: `deploy/publish.sh`
- Nginx static-site config: `deploy/nginx/zensen.conf`
- Release verifier: `deploy/verify-release.sh`
- Armed 10k load test: `deploy/load/10k.js`
- Bounded load rehearsal: `LOAD-REHEARSAL.md` and `deploy/load/bounded-smoke.mjs`
- Local deployment rehearsal: `DEPLOYMENT-REHEARSAL.md` and `deploy/rehearse-local.sh`
- Rendered visual receipt: `VISUAL-REVIEW.md`
- GitHub release gate: `GITHUB-RELEASE.md`
- Live Atlas board: `Websites/_Atlas/launch-board.json`

## Next action

Review and merge draft PR #21. Only after merge and explicit deployment approval should we provision paid production infrastructure or change the public-domain state.
