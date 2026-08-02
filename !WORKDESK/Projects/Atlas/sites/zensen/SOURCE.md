# SOURCE — canonical site source

Status: **identified and verified on en0**

## Canonical source

- Host: `en0-abzu` (`en0`)
- Remote root: `/home/abzu/!LAUNCHPAD`
- Canonical source folder: `/home/abzu/!LAUNCHPAD/ZENSEN.CMD/!WORKDESK/Websites/zensensystems`
- Static entry file: `index.html`
- Current entry SHA-256: `16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0`
- Current entry size: `58,144` bytes
- Last observed modification: `2026-08-02 01:39:19 -0500`

## Assets

- `brand/`
- `fonts/`
- `spec/`
- `spec.css`
- `zen-fonts.css`
- `healthz`
- `_versions/`

## Quarantined placeholder folder

- The stale `Websites/zensensystems.com` placeholder was moved to `ZENSEN.CMD/!WORKDESK/_Attic/zensensystems.com.placeholder-20260801`.
- It is not a ZENSEN surface, is not served by the current command, and is retained only as a recoverable cleanup record.

## Serve and route

- Serve command: `cd /home/abzu/!LAUNCHPAD/ZENSEN.CMD/!WORKDESK/Websites/zensensystems && python3 -m http.server 7120 --bind 0.0.0.0`
- Local origin: `http://127.0.0.1:7120`
- Tailscale Serve route: `/zensen` → `http://127.0.0.1:7120`
- Current URL: `https://corbato-en0.billfish-sirius.ts.net/zensen/`
- Tailscale status: Funnel endpoint responds and the current serve process is serving the canonical source after the source-folder path correction
- Route verification: **verified** — local origin on port `7120` and the Tailscale `/zensen/` route return the canonical file hash `16f519789d48a7bb103ee25be44228cba06e1df0958ac8724bd6635e6cacfaa0`

## Build and version state

- Build command: none detected; this is currently a static HTML/CSS site.
- Git repository: canonical site is tracked in `LLMasterDesign/ZENS3N` under `!WORKDESK/Websites/zensensystems`; merged source receipt is `1a953527eee812c0cd73021c33e85634e5337c0f`.
- Atlas receipt reconciliation is merged at `509e72909e7b30b6f206c5f082f1916790c3a31d` via PR #22.
- Current known-good saved version: `_versions/index.v1.0.hero-locked.⧗-26.366.html`
- Saved-version SHA-256: `b4de78a56ade73fbdc3206f175b7fbe614e46760c6054527b2aaea382b0b65ae`

## Rollback procedure

Before replacing `index.html`, copy it to a timestamped backup. To roll back, restore the chosen file from `_versions/` or the timestamped backup, then verify the local origin and `/zensen/` route hashes match.

## Deployment status

This is a verified Tailscale-served staging/public-ingress surface, not yet a conventional managed production deployment. The page still declares `noindex, nofollow`; review that deliberately before search launch. See [LAUNCH-BASELINE.md](LAUNCH-BASELINE.md) for the scale, recovery, and VPS gates.

Do not create a second copy. Edit the canonical source folder above, record the change in the ZENSEN changelog, and update the nearest `LOOM.html` when structure or readiness changes.
