# GitHub release gate

Status: **publishing · draft PR pending**

This is the release gate between the verified local/Tailscale surface and any future deployment. The intended GitHub repository root is the canonical site folder:

`ZENSEN.CMD/!WORKDESK/Websites/zensensystems`

Do not push the parent `!WORKDESK`, the Atlas control plane, credentials, logs, or unrelated surfaces into the site repository.

## Before approval

- [x] Canonical source is singular: `Websites/zensensystems/`.
- [x] Local `7120` entry and Tailscale `/zensen/` entry hashes match.
- [x] Local and Tailscale `/healthz` return `200 ok`.
- [x] `README.md` and `.gitignore` exist at the site root.
- [x] No application secrets are required by the static site.
- [x] Owner confirmed GitHub account, repository name, visibility, and default branch.
- [x] Owner explicitly approved the first push to `LLMasterDesign/ZENS3N`.
- [x] `gh auth status` passes for `LLMasterDesign`.

## First approved push

Run these only after approval, from the canonical site folder:

```bash
git init -b main
git add README.md .gitignore index.html healthz zen-fonts.css spec.css brand fonts spec
git diff --cached --check
git status --short
git commit -m "Release ZENSEN Systems company page"
git remote add origin <approved-github-repository-url>
git push -u origin main
```

Before `git add`, scan the staged set for secrets and confirm the exact entry hash. Do not add `.env`, private keys, SSH material, logs, test captures, or unrelated Atlas files.

## After push

- Record the repository URL, commit SHA, and tag in `LAUNCH-BASELINE.md`.
- Re-run local/Tailscale hash and health verification from the pushed commit.
- Decide whether GitHub Pages, another static host, or an approved VPS is the next deployment target.
- Keep `noindex, nofollow` until the public domain cutover is deliberate.

GitHub publication is a source-release action, not proof of production capacity. The 10k target still requires an approved test environment and the armed load-test evidence.
