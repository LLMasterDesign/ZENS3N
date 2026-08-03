# Railway hosted-staging readiness receipt

Captured: **2026-08-03**  
Status: **Candidate prepared; not activated**  
Owner: **ZENSEN Systems / WrkDsk**

This receipt makes Railway useful without pretending that a Railway account, a free-tier service, or a successful deployment proves production readiness. Tailscale + local `7120` remains the active rehearsal surface until the owner approves a hosted staging target.

## Why Railway is the next candidate

Railway documents GitHub-connected services, automatic builds, deployment approvals, health checks, and static-site hosting. The ZENSEN source is already in `LLMasterDesign/ZENS3N`; a hosted staging service would give the browser a repeatable public URL while preserving GitHub as the release boundary.

Reference: [Railway static hosting guide](https://docs.railway.com/guides/static-hosting), [Railway services](https://docs.railway.com/services).

## Activation checklist

- [x] Canonical source is `!WORKDESK/Websites/zensensystems`.
- [x] GitHub repository is `LLMasterDesign/ZENS3N`.
- [x] Repository-root `railway.toml` defines the canonical static source, Railway `$PORT` binding, `/healthz` check, and restart policy.
- [x] Tailscale source hash and `/healthz` contract are recorded.
- [x] The public domain remains `noindex`/Coming Soon; hosted staging must not be called production.
- [ ] Owner approves creating or using a Railway project.
- [ ] Railway service is connected to the repository and scoped to `!WORKDESK/Websites/zensensystems`.
- [ ] Railway-generated HTTPS URL is recorded below.
- [ ] `index.html`, `/healthz`, a known spec route, and a real unknown-route `404` are verified.
- [ ] Entry-body hash matches the approved GitHub release hash.
- [ ] Bounded smoke and latency receipts are attached; the 10k gate remains separate.
- [ ] Cost/usage watch and rollback procedure are recorded.

## Receipt fields

Keep these blank until the owner approves activation; do not invent a URL or deployment receipt.

| Field | Value |
| --- | --- |
| Railway project/service | Not activated |
| Hosted staging URL | Not assigned |
| GitHub commit tested | `1a953527eee812c0cd73021c33e85634e5337c0f` (current approved site merge) |
| Entry SHA-256 | `16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0` |
| Railway start contract | `railway.toml` → threaded `serve-local.py` → `!WORKDESK/Websites/zensensystems` |
| `/healthz` result | Not run against Railway |
| Unknown-route `404` result | Not run against Railway |
| Approval reference | Not supplied |

## Atlas update command

After the checklist has real evidence, update only the provider track—not the 10k task:

```bash
node deploy/update-launch-board.mjs \
  --provider-track railway-staging \
  --provider-state active \
  --evidence RAILWAY-STAGING-READINESS.md \
  --url 'https://approved-railway-host.example' \
  --approval-ref 'approved-staging-window-YYYY-MM-DD' \
  --note 'HTTPS, hash, healthz, 404, and bounded smoke verified.'
```

That command is intentionally approval-gated. Railway activation is not evidence of 10,000-user capacity; `deploy/load/run-10k-approved.sh` remains the only armed path for that claim.
