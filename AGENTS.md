# Base44 Dev Environment

## What this app is

ZENS3N is a multi-project monorepo. The runnable web app is a **self-contained static
company site** at `!WORKDESK/Websites/zensensystems/` — a single `index.html` (inline
CSS + JS) plus `spec/` pages, local fonts, and brand assets. No build step, no
backend, no database, no external API calls, no secrets.

## How it runs here

`docker-compose.base44.yml` serves the static directory with `nginx:alpine`,
bind-mounted read-only, mapped to host port **3000**. No image build needed —
edits to the static files appear on reload.

- Healthcheck: `GET /healthz` → `ok`
- Entry page: `/` → `index.html`
- Spec pages: `/spec/Product.html`, `/spec/Market.html`, `/spec/Valuation.html`

## Verifying it works

```bash
docker compose -f docker-compose.base44.yml up -d
curl -s http://localhost:3000/healthz      # → ok
curl -s http://localhost:3000/             # → 200, <title>ZENSEN SYSTEMS</title>
```

## Notes

- The `index.html` has a redirect for the `/zensen` path-prefix deployment; serving
  at root `/` is unaffected.
- Other repo subdirectories (3OX.BUILDER, TelePromptR, !FORGE) are CLI/tooling
  projects (Bun, Rust/Elixir) and are not part of the web preview.
- No secrets are required.
