# Semantic section map

These IDs are the stable vocabulary for human and AI edits. Keep IDs stable even when the visible design changes.

| ID | Section | Job | Owner file | Acceptance test |
|---|---|---|---|---|
| `ZENSEN.NAV` | Navigation | Move between major areas | `index.html:1188-1201, 1560-1592` | Every link works at `/zensen/` and on mobile |
| `ZENSEN.HERO` | Hero | Explain what ZENSEN is and who it is for | `index.html:1224-1264` | A new visitor understands it in 10 seconds |
| `ZENSEN.PROOF` | Proof/status | Establish credibility with concrete evidence | `index.html:1278-1393` | Claims have visible source/context |
| `ZENSEN.SECTIONS` | Main content | Present the product/system areas | `index.html:1278-1414` | Each card has one purpose and a destination |
| `ZENSEN.FOOTER` | Footer | Provide identity, contact, legal, and navigation | `index.html:1424-1456` | Contact and policy links work |
| `ZENSEN.META` | Metadata | Control title, description, canonical, JSON-LD | `index.html:4-35` | View-source contains one canonical and valid metadata |
| `ZENSEN.AUTH` | Protected area | Gate admin/private features | `index.html` (none) | Public pages never contain secrets or admin tokens |

## Section contract

Every section should document: purpose, public DOM ID, source file, data it consumes, links it owns, dependencies, owner, and a small acceptance test. If a change needs another section, record that dependency before editing.

## Current boundary notes

- `ZENSEN.META` owns the title, description, canonical, Open Graph, and Organization JSON-LD in the document head. It depends on the visible identity in `ZENSEN.HERO` and the public contact address in `ZENSEN.FOOTER`.
- `ZENSEN.HERO` owns the plain-English identity sentence and the first-view product explanation. It uses no external data.
- `ZENSEN.AUTH` is intentionally empty on this static public-facing surface. Admin, billing, finance, legal, invest, and systems routes are out of scope and must not be added to client HTML.
