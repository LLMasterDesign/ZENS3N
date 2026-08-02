# ZENSEN public cutover gate

This is the final launch gate for the approved public URL. It is intentionally separate from the local/Tailscale rehearsal and must not be run against a public target before the owner approves the cutover window.

## Run after approval

```bash
export PUBLIC_APPROVED=yes
export PUBLIC_APPROVAL_REF='approved decision, ticket, or launch record'
export PUBLIC_URL='https://zensensystems.com/index.html'
export PUBLIC_CANONICAL_URL='https://zensensystems.com/'
export PUBLIC_EXPECTED_HASH='<approved-release-sha256>'
export REQUIRE_SEO_ASSETS=yes
bash deploy/verify-public-cutover.sh
```

The verifier delegates to `verify-release.sh` with security headers required, then checks that the public HTML no longer contains `noindex` or `nofollow`, contains the approved canonical URL, and—when requested—serves `robots.txt` and `sitemap.xml`.

## Evidence required before sign-off

- [ ] PR merged and the deployed commit recorded.
- [ ] Approved host, DNS, and TLS certificate verified.
- [ ] Staging `noindex, nofollow` removed deliberately.
- [ ] Public hash, health, 404, and security headers verified.
- [ ] Monitoring, alert route, rate limits, cost watch, and rollback owner recorded.
- [ ] Ramp/soak/spike/recovery evidence attached before claiming 10k readiness.
