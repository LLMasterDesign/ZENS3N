# ZENSEN domain routing plan

Captured: **2026-08-03**  
Status: **Recommendation only; no DNS or registrar mutation made**  
Owner: **ZENSEN Systems / WrkDsk**

Owning several domains does not require several copies of the company page. Atlas keeps one canonical source and assigns each domain a deliberate role.

## Recommended roles

| Domain | Recommended role | State |
| --- | --- | --- |
| `zensensystems.com` | Canonical public company/product page | Primary candidate; current public surface is still Squarespace Coming Soon/noindex. |
| `zensen.systems` | Hosted staging candidate for Railway | Preferred staging alias; DNS was not resolving during this audit. |
| `zensenenterprises.com` | Corporate/holding-company surface or redirect | Reserved; current public surface is Squarespace Coming Soon/noindex. |
| `zensen.store` | Commerce/offer destination | Reserved; no DNS answer observed during this audit. |
| `zensen.solutions` | Services/enterprise solutions surface | Reserved; no DNS answer observed during this audit. |
| `zensen.live` | Launch/demo/status surface | Reserved; current public surface is Squarespace Coming Soon/noindex. |

These are proposed roles, not approvals. Do not publish identical content to all six domains; that creates canonical, SEO, and operating confusion.

## Deployment boundary

The current GitHub repository is a broad source/evidence monorepo. Railway staging is safe only when:

- the Railway service starts from the committed `railway.toml` at repository root;
- the start command serves only `!WORKDESK/Websites/zensensystems`;
- the repository root is never configured as the public document root; and
- the generated Railway domain is treated as staging until the owner approves a domain cutover.

For a later production hardening pass, a dedicated site-only repository may be created, but it is not required to validate the current static release.

## Safe order of operations

1. Deploy the canonical site to a Railway-generated `*.up.railway.app` staging URL.
2. Verify hash, `/healthz`, known routes, 404, monitoring, and bounded smoke.
3. If desired, approve `zensen.systems` as the Railway staging custom domain and apply only Railway-provided DNS records.
4. Approve `zensensystems.com` as the production canonical domain only after the public cutover verifier passes.
5. Redirect or separately design the remaining domains after the primary offer and corporate information architecture are settled.

References: [Railway readiness](RAILWAY-STAGING-READINESS.md), [public-domain review](PUBLIC-DOMAIN-REVIEW.md), [public cutover gate](PUBLIC-CUTOVER.md).
