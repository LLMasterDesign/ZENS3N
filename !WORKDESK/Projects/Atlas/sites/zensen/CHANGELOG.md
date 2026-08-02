# Changelog

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
