# ZENSEN static-surface security review

Captured: **2026-08-02**

This is a preproduction review of the static bundle and deployment recipe. It is not a penetration test or a production security sign-off.

## Proven locally

- [x] No secret-shaped content found in the site bundle: no private-key blocks, common cloud access-key shapes, GitHub tokens, Slack tokens, or password assignments.
- [x] Public HTML contains no login/session implementation or credential storage.
- [x] Staging HTML keeps `noindex, nofollow`; public indexing remains a deliberate cutover decision.
- [x] `404.html` is themed, carries `noindex, nofollow`, and is included in the release archive.
- [x] Nginx recipe declares `nosniff`, `DENY` framing, strict-origin referrer policy, and disabled camera/microphone/geolocation permissions.
- [x] `/healthz` is no-store and the 10k scenario requires explicit target approval plus an approval receipt.

## Still open

- [ ] Run `nginx -t` on the selected deployment host; Nginx is not installed on this local host.
- [ ] Configure TLS, security updates, firewall, monitoring, rate limits, alert delivery, and cost watch on the approved target.
- [ ] Perform an authorized dependency/edge penetration review before public cutover.
