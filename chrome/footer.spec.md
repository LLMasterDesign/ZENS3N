///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂⋮⋮[0xFOOT]⋮⋮
▛//▞▞ ⟦⎊⟧ :: ⧗-26.370 // WORKBOOK :: Footer Spec ▞▞

# Footer Spec — Chrome shared footer

Source of truth for any agent editing the ZENSEN shared footer.

## Files

| File | Role |
|------|------|
| `ZEN.HUB/webshards/src/components/Footer.svelte` | Svelte source (compile target) |
| `ZEN.HUB/website/footer/footer.html` | Compiled output (do not hand-edit) |
| `ZEN.HUB/website/css/chrome.css` | Live CSS (footer section starts at `.foot-frame`) |
| `ZEN.HUB/website/chrome.js` | Inject + fold + slot logic |
| `ZEN.HUB/website/lab.html` | Visual test page |
| `ZENS3N/bin/publish-chrome.sh` | Publish hub → ZENS3N/chrome + all satellites |

## Structure (6 named `<p>` under `.foot-frame`)

```
foot-frame (flex-wrap)
├── foot-title    (order 1) — system mark + tag rail
├── foot-meta     (order 2) — sync · :port · path/file · crc
├── ::before      (order 3) — flex break (100% basis, 0 height)
├── foot-brand    (order 4) — 前線 Front Line Systems
├── foot-glow     (order 5) — 2px radiance bar
├── foot-date     (order 6) — Sirius stamp ⌾-26.ddd.fff
└── foot-banner   (order 7) — ///▙▖▙▖▞▞▙▂▂…〘・.°𝚫 〙
```

## Line count

- **3 lines** at normal width (title+meta | brand+glow+date | banner)
- **4 lines** when narrow — meta wraps below title; nothing else jumps

## Title mark rule

Format: `<strong>{SYSTEM}</strong> // 〔 {Tag} · {Tag} 〕`

- **Bold** = system name, ALL CAPS as branded (3OX, ZENSEN, ORION, ÆGen, CMD)
- **Inside brackets** = Title Case. Never lowercase. Never ALL CAPS.
- Separator inside brackets = red `·` (`.rail-dot`)

### Surface → title mapping

| Batch | Bold mark | Bracket tags |
|-------|-----------|--------------|
| 3OX (default) | 3OX | Zensen · Ender |
| ZENSEN-SITES | ZENSEN | {Role} (Educate, Try, Own, Hire) |
| ÆGEN | ÆGen | Zensen · Runtime |
| CONTROL | ORION | Control |
| STRATA-OP | 1N3OX | Strata |
| CMD-OPS | CMD | Ops |
| SUITE (home) | 3OX | Zensen · Ender |

## Meta strip (`foot-meta`)

Format: `sync● · :port · path/segments/file · ⋮⋮crc:crc⋮⋮`

### Sync

- `sync` text = link to `http://127.0.0.1:{port}/api/health`
- Sync dot (`.sync-dot`) = 6px circle immediately after "sync" text

### Sync dot states

| State | Color | `data-state` attr | Meaning |
|-------|-------|-------------------|---------|
| Synced | Mint `#75e0c4` + glow | (none / default) | Healthy, file in sync |
| Unsynced | Amber `#e0a040` + glow | `unsync` | File not yet pushed or stale |
| Degraded | Red `#f87171` + glow | `degraded` | Service down or error |

### Port

- Displayed as `:NNNN` in lime (`--lime`)
- From `data-slot-copy` HTML or live from the surface manifest

### Path

- Segments wrapped in `<span class="seg">` — fold from the left when narrow
- Filename in `<span class="file">` — never hidden
- `chrome.js` `foldMeta()` hides `.seg` elements left-to-right, then `.meta-lead`

### CRC

- Format: `⋮⋮{hash}:crc⋮⋮` or `⋮⋮∅:crc⋮⋮` when empty
- Set via `data-slot-crc` attr on the mount div

## Stamp (`foot-date`)

- Live: ticks every second via `siriusStamp()` — `⌾-26.{days}.{fff}`
- Frozen: set `data-slot-stamp="⌾-26.370.112"` on mount to lock

## Banner (`foot-banner`)

- Full-bleed via `margin: 0 -17px -8px` (matches frame padding)
- Three spans: `.rl` (left glyph block) · `.rf` (fill `▂`) · `.rr` (right stamp)
- `.rf` is `flex: 1 1 auto; overflow: hidden` — fills remaining width

## Slot attrs (on `data-chrome="footer"` mount div)

| Attribute | Type | Effect |
|-----------|------|--------|
| `data-slot-brand` | HTML | Replaces entire `foot-title` inner (cube + title-run) |
| `data-slot-copy` | HTML | Replaces `foot-meta` inner (sync + path + crc spans) |
| `data-slot-crc` | text | CRC value — formatted by `crcLine()` into `⋮⋮val:crc⋮⋮` |
| `data-slot-stamp` | text | Frozen stamp text. Omit for live tick. |

## Do not

- Change the 6-element structure or their order
- Add min-width floors > the measured `notes.json` + CRC width
- Put lowercase or ALL CAPS inside `〔 〕` brackets
- Hide the filename (`.file`) during fold
- Manually edit `footer/footer.html` — compile from Svelte

:: ∎
