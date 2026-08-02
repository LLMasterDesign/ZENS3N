# GitHub release gate

Status: **merged to main · deployment gate open**

This is the release gate between the verified local/Tailscale surface and any future deployment. ZENSEN is being released as a scoped change inside the existing monorepo:

`LLMasterDesign/ZENS3N`

The site lives at `!WORKDESK/Websites/zensensystems`; the Atlas board and evidence pack are intentionally included at their matching `!WORKDESK` paths. Do not add credentials, logs, or unrelated surfaces.

## Before approval

- [x] Canonical source is singular: `Websites/zensensystems/`.
- [x] Local `7120` entry and Tailscale `/zensen/` entry hashes match.
- [x] Local and Tailscale `/healthz` return `200 ok`.
- [x] `README.md` and `.gitignore` exist at the site root.
- [x] No application secrets are required by the static site.
- [x] Owner confirmed GitHub account, repository name, visibility, and default branch.
- [x] Owner explicitly approved the first push to `LLMasterDesign/ZENS3N`.
- [x] `gh auth status` passes for `LLMasterDesign`.

## Merged release

The approved branch was merged into `main`:

```text
Repository: https://github.com/LLMasterDesign/ZENS3N
Branch: agent/zensen-systems-site
Head commit: cb59658a9e11e3198315b2b55f02dd2c0641d81e
Merge commit: 1a953527eee812c0cd73021c33e85634e5337c0f
PR: https://github.com/LLMasterDesign/ZENS3N/pull/21
```

The staged set was whitespace-checked, secret-shaped paths were scanned, internal links/assets were checked, and the exact entry hash was confirmed before the push.

## After merge

- Merge SHA is recorded in `LAUNCH-BASELINE.md` and `_Atlas/launch-board.json`.
- Re-run local/Tailscale hash and health verification from the pushed commit.
- Decide whether GitHub Pages, another static host, or an approved VPS is the next deployment target.
- Keep `noindex, nofollow` until the public domain cutover is deliberate.

GitHub publication is a source-release action, not proof of production capacity. The 10k target still requires an approved test environment and the armed load-test evidence.
