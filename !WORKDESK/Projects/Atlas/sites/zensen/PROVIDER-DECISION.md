# ZENSEN provider decision receipt

Captured: **2026-08-02**  
Status: **No external provider activated**  
Owner: **ZENSEN Systems / WrkDsk**

Atlas keeps the current Tailscale rehearsal as the active staging surface until a provider is explicitly approved. The existence of an account, free tier, or deployment button is not evidence that a production target has been selected.

## Decision

| Need | Candidate | Decision | Activation trigger |
| --- | --- | --- | --- |
| Current staging | Tailscale + local `7120` | **Active** | Already verified by the launch baseline. |
| Hosted staging | Railway | **Preferred candidate; not activated** | Approve a GitHub-connected staging service and record its URL in the launch baseline. Railway can deploy from a GitHub repository, but its free tier is not a 10k-capacity receipt. |
| Production VPS | Hetzner Cloud | **Preferred candidate; not approved** | Approve a region, budget, SSH identity, firewall policy, backup plan, and test window. |
| Alternative hosting | Hostinger | **Deferred** | Reconsider only if the approved deployment requirements favor its managed workflow. Do not operate a second host in parallel without a reason. |
| First paid offer | Stripe Payment Links | **Preferred monetization path; not activated** | Define the offer, price, fulfillment, refund policy, tax treatment, and destination URL. |
| Dynamic product data | Supabase | **Deferred** | Add only when the product needs accounts, forms, leads, storage, or database-backed behavior. |
| High-ticket digital sales | FanBasis | **Deferred** | Evaluate only if ZENSEN launches a service, course, community, affiliate, or financing funnel. |
| Retrieval / AI search | ZeroEntropy | **Deferred** | Add only when a shipped product needs document retrieval, embeddings, or reranking. |
| Development workspace | Superset | **Deferred** | It is a coding workspace, not a runtime or deployment target; the current SSH/Linux workflow does not require it. |
| `gbrain` | Unidentified | **Unverified** | Record the exact product URL and intended use before evaluation. |

## Guardrails

- No paid infrastructure is purchased by this receipt.
- No API keys, payment links, customer data, or provider credentials belong in the static site repository.
- Railway or Hetzner selection does not prove 10,000-user capacity; the armed load test still requires `ARMED=yes`, `APPROVED_TARGET=yes`, and `APPROVAL_REF`.
- Stripe activation does not equal public launch; the public cutover verifier still requires an approved URL, canonical URL, expected hash, and security-header evidence.
- Any provider choice must be recorded here, in `LAUNCH-BASELINE.md`, and in `_Atlas/launch-board.json` before the related gate is marked complete.

## Next decision

Choose one of these bounded moves:

1. Keep Tailscale as staging and merge/review site work only.
2. Approve Railway for a hosted staging receipt.
3. Approve Hetzner for the real VPS rehearsal.
4. Define the first paid ZENSEN offer and create a Stripe test-mode payment flow.

Until one is approved, Atlas correctly reports the deployment and monetization gates as open.

References: [launch baseline](LAUNCH-BASELINE.md), [public cutover gate](PUBLIC-CUTOVER.md), [release runbook](deploy/README.md).
