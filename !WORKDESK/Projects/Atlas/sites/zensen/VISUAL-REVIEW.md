# ZENSEN rendered visual review

Captured: **2026-08-02**
Target: `http://127.0.0.1:7120/`
Method: isolated headless Chromium with reduced-motion emulation where noted

## Results

| Surface | Viewport | Result |
| --- | --- | --- |
| Company page | 1440 × 900 | Rendered; 1 `h1`; 7 content cards visible; no horizontal overflow; no console errors |
| Company page | 390 × 844 | Rendered; scroll width equals viewport; 7 content cards visible; no console errors |
| Mobile menu | 390 × 844 after scroll | Menu opens; `aria-expanded="true"`; 10 navigation links visible |
| Product spec | 390 × 844 | Scroll width equals viewport; 1 `h1`; no console errors |
| Market spec | 390 × 844 | Scroll width equals viewport; 1 `h1`; no console errors |
| Valuation spec | 390 × 844 | Scroll width equals viewport; 1 `h1`; no console errors |

The rendered screenshots showed the Oxanium/DM Mono theme, card hierarchy, footer, mobile stacking, and open-menu state without clipped content. The browser run also confirmed the menu remains non-interactive at the top of the page until the fixed header becomes visible after scrolling, then opens normally.

## Recheck contract

Repeat the review against the local `7120` server at the same two viewports. Keep the browser check outside the production bundle; this document records the acceptance result, not a runtime dependency. A public deployment still requires the approved release, domain, and production checks in `LAUNCH-BASELINE.md`.
