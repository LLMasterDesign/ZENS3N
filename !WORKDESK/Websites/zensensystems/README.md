# ZENSEN Systems

Canonical static company page for ZENSEN Systems.

## Local rehearsal

From this folder:

```bash
python3 ../../Projects/Atlas/sites/zensen/deploy/serve-local.py \
  --directory . --host 0.0.0.0 --port 7120
```

The Atlas server uses a threaded standard-library HTTP server for realistic bounded concurrency during local/Tailscale rehearsal. It is still a preproduction server; production uses the approval-gated Nginx pack.

Then verify:

- Local: `http://127.0.0.1:7120/index.html`
- Health: `http://127.0.0.1:7120/healthz`
- Tailscale rehearsal: `https://corbato-en0.billfish-sirius.ts.net/zensen/`

The Tailscale URL is a private/preproduction rehearsal surface. It is not the production domain and does not prove 10,000-user capacity.

## Contents

- `index.html` — company page
- `spec/` — Product, Market, and Valuation views
- `brand/`, `fonts/` — local visual assets
- `healthz` — static health contract
- `_versions/` — rollback evidence, not a public route

See the Atlas launch baseline for release, GitHub, deployment, and capacity gates.
