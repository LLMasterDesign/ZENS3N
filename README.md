# ZENSEN Systems

Canonical static company page for ZENSEN Systems.

## Local rehearsal

From this folder:

```bash
python3 server.py --host 0.0.0.0 --port 7120
```

This branch uses a threaded, dependency-free static server. It serves only this directory, hides deployment config files, and returns the themed `404.html` for unknown routes.

Then verify:

- Local: `http://127.0.0.1:7120/index.html`
- Health: `http://127.0.0.1:7120/healthz`
- Tailscale rehearsal remains managed from the Atlas workspace, not this branch.

## Railway

Hosted staging is active at [`https://zens3n-production.up.railway.app`](https://zens3n-production.up.railway.app). The service is connected to `LLMasterDesign/ZENS3N` / `website/zensensystems`, with Railway Root Directory unset/default (`/`). Railway injects `$PORT`; `railway.toml` starts `server.py` and checks `/healthz`.

Verified staging contract:

- `/` — HTTP 200
- `/healthz` — HTTP 200
- `/spec/Market.html` and `/spec/Product.html` — HTTP 200
- unknown route — HTTP 404
- entry SHA-256 — `16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0`

This is a hosted staging surface, not production capacity evidence. Custom DNS,
VPS deployment, and the 10,000-user gate remain approval-gated.

## Railway Main View :: Suite Node Contract

The Railway entry view is the `ZENSEN SYSTEM SUITE` hub at `#suite`. It lists
the internal suite nodes, the six ZENSEN site nodes on `6060`, `6061`, `6062`,
`6063`, `6064`, and `6066`, and the
three separately routed 3OX site nodes on `6050–6052`. Every site node links
back to `#suite`; card-only domains remain publication-pending until DNS is
approved.

The source implementation is `index.html`. The hosted readiness receipt in
Atlas records the last deployed hash; this source change must be deployed and
re-verified before the hosted surface is said to contain the new node map.

## Contents

- `index.html` — company page
- `spec/` — Product, Market, and Valuation views
- `brand/`, `fonts/` — local visual assets
- `healthz` — static health contract
- `server.py` — isolated static server; deployment config paths return 404
- `railway.toml` — Railway start and health-check contract

The entry SHA-256 for this branch is `16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0`. This is a staging branch, not evidence of 10,000-user capacity or public cutover.
