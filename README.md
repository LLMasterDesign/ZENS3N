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

Connect this branch to a Railway service and leave the service root at `/`. Railway injects `$PORT`; `railway.toml` starts `server.py` and checks `/healthz`. Generate a Railway domain for staging before adding any custom domain.

## Contents

- `index.html` — company page
- `spec/` — Product, Market, and Valuation views
- `brand/`, `fonts/` — local visual assets
- `healthz` — static health contract
- `server.py` — isolated static server; deployment config paths return 404
- `railway.toml` — Railway start and health-check contract

The entry SHA-256 for this branch is `16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0`. This is a staging branch, not evidence of 10,000-user capacity or public cutover.
