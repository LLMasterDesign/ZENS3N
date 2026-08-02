# Site docs control system

Open the committed [Atlas launch board](../../../../Websites/_Atlas/launch-board.json) to see machine-readable readiness, then open [`LOOM.html`](LOOM.html) for the ZENSEN launch checklist. Checkbox state is local to that browser.

## Folder map

- `LOOM.html` — local canonical map and visual checklist for this surface.
- `../../../../Websites/_Atlas/launch-board.json` — committed Atlas source of truth for this release.
- `SOURCE.md` — the one true source folder, serving command, assets, and deployment ownership.
- `SECTIONS.md` — semantic map. Each section has an ID, purpose, files, dependencies, and acceptance test.
- `SEO.md` — search-engine launch requirements.
- `AEO.md` — answer-engine/AI readability requirements.
- `SECURITY-2FA.md` — authentication and 2FA boundary.
- `CHANGELOG.md` — short record of changes and rollback notes.

## Canonical protocol

Every location that hosts a meaningful page or viewscreen may contain a `LOOM.html`. Agents must read the nearest `LOOM.html` before grepping or loading large implementation files. Framework and runtime changes do not change this protocol.

## Working rule

Never ask an AI to “fix the whole HTML.” Give it a section ID from `SECTIONS.md`, the relevant file, the desired behavior, and the acceptance test. The AI should return the files changed and any cross-section dependency it discovered.

## Suggested edit request

> Work only on `ZENSEN.HERO`. Read `SECTIONS.md` and the named source file. Preserve the public IDs and navigation. Make the hero copy clearer on mobile. Run its acceptance test and report changed files.
