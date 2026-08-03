# Changelog

## 2026-08-03

- Wired the ZENSEN Loom to render live Atlas task counts, provider tracks, and the current performance boundary from `launch-board.json`.
- Added the safety-bounded staging monitor rehearsal and recorded hash, health, and 404 canary checks as partial Live Chapter 06 evidence.
- Replaced the single-threaded local rehearsal server with a tracked threaded HTTP/1.1 server; the latest Tailscale bounded p99 is 109.33 ms, while local p99 remains a documented 1,888.26 ms warning.
- Extended the Atlas updater to recompute task/provider summary counts on every state update, preventing the launch board from carrying stale totals.
- Ran the isolated local battle rehearsal: bounded soak/spike, bad-release rejection, rollback, process-failure observation, and restart recovery passed; real deployment and operational alert evidence remain open.
- Added machine-tracked `railway-staging` and `stripe-test-offer` provider tracks with readiness receipts; activation remains approval-gated.
- Extended `deploy/update-launch-board.mjs` to update provider tracks only with evidence, and to require an approval reference plus URL for activation states.
- Recorded the provider decision boundary: Tailscale remains active staging; Railway and Hetzner are deferred candidates, Stripe is the preferred first monetization path, and no external service was activated.
- Added `deploy/update-launch-board.mjs`, an evidence-gated Atlas updater that requires approval references for the 10k and public-cutover tasks.
- Extended the updater to record partial evidence on pending tasks without promoting their state.
- Added a k6 preflight wrapper that refuses the 10k run before contacting a target unless all approval variables and the runner are present.
- PR #24 merged at `aff448b0ec931b0697675e3196f1756775f6dbff`; the provider decision and evidence-gated board updater are now published on `main`.
- PR #21 was merged into `LLMasterDesign/ZENS3N` `main` at `1a953527eee812c0cd73021c33e85634e5337c0f`; Atlas and the release baseline now reflect the merged source.
- Recorded the public-domain review: `zensensystems.com` still serves the Squarespace Coming Soon/noindex surface, so no public cutover was made.
- Added a local recovery rehearsal receipt: immutable archive restore, exact entry hash, and `healthz` pass in 12 ms; production backup, alerting, and incident paging remain open.
- PR #27 merged at `290b0e21a0d792bc5f8312419df9e4c9fa912bd2`; the recovery receipt is now published on `main` while its uncovered operational boundaries remain pending.
- Recorded a bounded stress ceiling: all requests passed locally/Tailscale, but p99 exceeded the initial 1,500 ms target at the capped rehearsal load; no 10k claim was made.
- PR #29 merged at `565c867931ff5c30366059440f3564f3a453fed1`; the bounded performance warning is now published on `main`.
- Atlas receipt PR #22 was merged at `509e72909e7b30b6f206c5f082f1916790c3a31d`; the board and release docs are now reconciled on `main`.

## 2026-08-02

- Made the committed ZENSEN Loom self-contained for the scoped monorepo release; its Atlas links now resolve to the included launch board instead of omitted workspace-only files.
- Passed HTML validation for the company page and three product specs; added an explicit menu-button type and recorded responsive/accessibility evidence. Release commit `f2450256d6fe81802df85a524e50e99373627c80`; current entry receipt is SHA-256 `16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0`.
- Completed rendered review at 1440px and 390px, including the mobile menu and all three spec pages; recorded the receipt in `VISUAL-REVIEW.md`.
- Added the safety-bounded repeatable load harness and recorded 500 local plus 100 Tailscale successful requests in `LOAD-REHEARSAL.md`; the armed 10k scenario remains a separate gate.
- Hardened the armed 10k scenario with explicit `APPROVED_TARGET=yes` and `APPROVAL_REF` requirements in addition to `ARMED=yes`; no capacity claim was made.
- Added a loopback deployment rehearsal covering immutable archive, atomic switch, rollback, and restart; real VPS and battle-test evidence remain open.
- Added the themed `404.html` and baseline Nginx security headers; monitoring, rate limits, cost watch, and public cutover remain open.
- Recorded `SECURITY-REVIEW.md`: the bundle is secret-clean and static-only; live Nginx/TLS/monitoring and authorized edge review remain target-gated.
- Extended `verify-release.sh` to require a real unknown-route `404` and optionally enforce the Nginx security headers with `ZENSEN_REQUIRE_SECURITY_HEADERS=yes`.
- Added the approval-gated `PUBLIC-CUTOVER.md` and `verify-public-cutover.sh`; public noindex removal, domain/TLS, SEO assets, and SLO sign-off remain unexecuted.

## 2026-08-02

- Installed and authenticated the GitHub CLI for `LLMasterDesign`.
- Published the scoped ZENSEN Systems site, Atlas launch board, and release evidence to branch `agent/zensen-systems-site` at commit `45be2c1`.
- Opened draft PR [#21](https://github.com/LLMasterDesign/ZENS3N/pull/21); merge and deployment remain approval-gated.

## 2026-08-01

- Recorded a bounded rehearsal receipt: local `7120` handled 500/500 requests at concurrency 25 and Tailscale `/zensen/` handled 100/100 at concurrency 10; this is not a 10k capacity claim.

## 2026-08-01

- Added Open Graph/Twitter image metadata and a theme-color declaration; refreshed the canonical release receipt to SHA-256 `02bd2faf3dfe4a9fbfe157971329f73bdce1e11d73da38314084ed63479d513b`.

## 2026-08-01

- Recorded the read-only `slate-rt` target check: Tailscale reachable, SSH identities unavailable, no remote mutation performed; production host remains unassigned.

## 2026-08-01

- Added the canonical `healthz` contract and production VPS pack: atomic publisher, Nginx config, release verifier, and safety-armed 10k k6 scenario.

## 2026-08-01

- Captured `LAUNCH-BASELINE.md` with proposed SLOs, environment boundaries, current release and rollback hashes, and explicit VPS/10k/battle-test gates.
- Corrected the stale degraded deployment note after re-verifying local `7120` and Tailscale `/zensen/` responses against the canonical entry hash.

## 2026-08-01

- Restored the canonical `7120` server from `Websites/zensensystems` and verified the Tailscale `/zensen/` route returns HTTP 200 with a matching SHA-256 hash.
- Synced Atlas deployment state from degraded to verified staging.

## 2026-08-01

- Mapped all stable ZENSEN section IDs to narrow source boundaries in `SECTIONS.md`.
- Added the direct AEO identity sentence, meta description, canonical, Open Graph metadata, and constrained Organization JSON-LD to the canonical `index.html`.
- Kept `noindex, nofollow` because the current source is still Tailscale staging and the public domain is still a Squarespace coming-soon page.
- Recorded `ZENSEN.AUTH` as intentionally empty on this static public-facing surface.
- Updated `SOURCE.md` with the post-edit entry hash, size, and modification time after local route verification.
- Corrected the documented canonical folder and serve command from the stale `!WORKDESK/SITE` path to the live `!WORKDESK/Websites/zensensystems` path; no second copy was created.
- Marked deployment degraded after proving the long-running `7120` Python handler and Tailscale `/zensen/` route return `404`; the canonical file itself passes on isolated local port `7121`.
- Quarantined the stale, non-real `Websites/zensensystems.com` placeholder under `!WORKDESK/_Attic/zensensystems.com.placeholder-20260801`; the only active ZENSEN location is `Websites/zensensystems`.

## 2026-08-01

- Added the `LOOM.html` visual deployment control panel.
- Added focused docs for source ownership, semantic sections, SEO, AEO, security/2FA, and change tracking.
- Recorded that the current Tailscale-hosted page is staging/private, not public production.
- Locked the naming contract: `ATLAS.html` maps the ecosystem; `LOOM.html` maps each local page or interface.
- Added the Atlas control plane with universal header/footer parts, site-build checklist, task rules, and a reserved generator/server contract.
