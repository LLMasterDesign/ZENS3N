#!/usr/bin/env python3
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂ ⋮⋮[0xBUILD]⋮⋮
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.388 // 3OX.ME :: profile builder ▞▞
#
# Emits one page per 3ox into profiles/<name>/index.html, plus the
# apex router at index.html.
#
# The roster below is hand-carried from each unit's .ID on disk. That
# is deliberate and temporary: the law says {agent}.3ox.me MIRRORS disk
# {Agent}.me, so the end state reads those files directly. You cannot
# automate a mirror before you know what the reflection looks like —
# ship seven, then extract the reader.
#
# Chrome is injected at runtime by /chrome/chrome.js. Slots are filled
# with FULL HTML for data-slot-copy, per chrome/lab.html:99-124 — the
# live zensen satellites pass a bare string there, which overwrites the
# nested .port / .sync-dot / [data-slot=crc] children and silently
# kills the CRC. Do not copy those.

from __future__ import annotations

import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "profiles"

CUBE = ("<svg class='fcube' viewBox='0 0 24 24' aria-hidden='true'>"
        "<path class='f-top' d='M12 3 20 7.5 12 12 4 7.5Z'/>"
        "<path class='f-left' d='M4 7.5 12 12 12 21 4 16.5Z'/>"
        "<path class='f-right' d='M20 7.5 12 12 12 21 20 16.5Z'/></svg>")

# name · glyph · class · title · tag · who · host · ports · port (live badge) · path · state · source
PROFILES = [
    {
        "name": "ender", "glyph": "Δ", "class": "Agent", "hex": "0xENDER",
        "title": "ENDER", "tag": "Warden",
        "who": "Warden-governor of the abzu STRATA under ΛrgOS. Holds MARDUK's "
               "alignment. commission → verify → activate → observe → seal.",
        "not": "¬perform — Ender governs the hands, it is not the hands.",
        "host": "corbato-en0 · 100.118.28.119",
        "ports": [(":8080", "chat"), (":8081", "Ender.gen"),
                  (":8888", "agent-face"), (":7070", "[CMD]")],
        "badge": ":8081", "path": ("PAN7HEON/7HE.ENDER/", "ENDER.ID"),
        "state": "live", "model": "Ornith 35B",
    },
    {
        "name": "raven", "glyph": "ᚱ", "class": "Agent · .sidekik", "hex": "0xRAVEN",
        "title": "RAVEN", "tag": "Witness",
        "who": "Witness · scout · Lucius's sidekik. observe → relay → advise. "
               "Sibling equal to Ender and Orion, never nested beneath them.",
        "not": "¬perform · ¬seal · ¬author-logic.",
        "host": "corbato-en0 · 100.118.28.119",
        "ports": [(":8085", "chat"), (":8095", "guest"), (":8889", "mesh")],
        "badge": ":8085", "path": ("PAN7HEON/7HE.RAVEN/", "RAVEN.ID"),
        "state": "live", "model": "Ornith 9B",
    },
    {
        "name": "forge", "glyph": "⚒", "class": "Agent", "hex": "0xFORGE",
        "title": "FORGE", "tag": "Workshop",
        "who": "Cursor / build agent on the mesh. Owns the workshop face — "
               "edit loop, being-build, local-model aperture discipline.",
        "not": "Not the mesh warden. Not a per-turn chatbot.",
        "host": "corbato-en0 · 100.118.28.119",
        "ports": [(":8888/Forge", "thin door")],
        "badge": ":8888", "path": ("PAN7HEON/7HE.FORGE/", "FORGE.ID"),
        "state": "live", "model": "borrows Ender's front door",
    },
    {
        "name": "orion", "glyph": "Ω", "class": "operator-door", "hex": "0xORION",
        "title": "ORION", "tag": "Door",
        "who": "The door to ORION, the OTP peer. Grants, init docs, and the "
               "supervised turn machine behind them.",
        "not": "The door is not the peer — ORION.CMD opens, Orion.Gen runs.",
        "host": "corbato-en0 · 100.118.28.119",
        "ports": [(":8400", "Orion.Gen")],
        "badge": ":8400", "path": ("ORION.CMD/", "WHOAMI"),
        "state": "live", "model": "BEAM · OTP",
    },
    {
        "name": "tpr", "glyph": "⟿", "class": "Station", "hex": "0xTPR",
        "title": "TELEPROMPTR", "tag": "Relay",
        "who": "The Telegram relay station. Carries a conversation from a phone "
               "to an agent and the answer back, with a receipt at each crossing.",
        "not": "A relay never mutates a service — it detects, serves up, delivers.",
        "host": "corbato-en0 · seat \u201ctpr\u201d",
        "ports": [(":7089", "relay")],
        "badge": ":7089", "path": ("_TRON/Stations/TelePromptR/", "TelePromptR.ID"),
        "state": "live", "model": "webhook · tier router",
    },
    {
        "name": "ledg3r", "glyph": "₪", "class": "Set", "hex": "0xLEDG3R",
        "title": "LEDG3R", "tag": "Finance",
        "who": "The finance guardian. Product LEDG3R, persona Nia, engine Mansa, "
               "being Nisaba — one set, four faces.",
        "not": "Dashboard is live; the data behind it is still mock. Not wired to a bank.",
        "host": "corbato-en0",
        "ports": [(":7096/ledg3r", "dashboard")],
        "badge": ":7096", "path": ("CENTRAL.CMD/PROJECTS/LEDG3R/", "README.md"),
        "state": "building", "model": "Mansa kernel",
    },
    {
        "name": "slate7", "glyph": "◈", "class": "relay-station", "hex": "0xSLATE7",
        "title": "SLATE7", "tag": "Mesh",
        "who": "The always-on mesh node \u2014 \u201cthe VPS we didn\u2019t buy.\u201d Relays and "
               "serves so the rest of the mesh can sleep.",
        "not": "A light unit. It relays and serves; it does not think.",
        "host": "100.125.230.71 · GL-BE3600 / OpenWrt",
        "ports": [(":8101", "Sirius"), (":8118", "mesh")],
        "badge": ":8101", "path": ("!CORE.MEM/Slate7/", "SLATE7.ID"),
        "state": "live", "model": "OpenWrt",
    },
]

DEFERRED = [
    ("obsidia", "no cube yet — seat pending under device runtime"),
    ("vso", "archived — real cube, not in the live tree"),
    ("notepad", "authority unresolved"),
]

HEAD = """<!doctype html>
<html lang="en" data-surface="3ox">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="robots" content="noindex,nofollow">
  <title>{title}</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Mono:ital,wght@0,400;0,500;1,400&family=Oxanium:wght@500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/chrome/css/chrome.css">
  <style>
    :root{{color-scheme:dark}}
    body{{margin:0;background:var(--black)}}
    .p-id{{display:flex;align-items:baseline;gap:14px;margin:0 0 6px}}
    .p-glyph{{font-size:2.2rem;line-height:1;color:var(--brand)}}
    .p-class{{font-size:.62rem;letter-spacing:.18em;color:var(--muted);text-transform:uppercase}}
    .p-not{{color:var(--muted);font-style:italic}}
    .p-ports{{width:100%;border-collapse:collapse;font-family:var(--mono);font-size:.8rem;margin:4px 0 0}}
    .p-ports td{{padding:5px 0;border-bottom:1px solid rgba(255,255,255,.08)}}
    .p-ports td:first-child{{color:var(--brand);width:11em}}
    .p-ports td:last-child{{color:var(--muted)}}
    .p-grid{{display:grid;gap:10px;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));margin-top:6px}}
    .p-card{{display:block;padding:12px 14px;border:1px solid rgba(255,255,255,.12);border-radius:10px;text-decoration:none;color:inherit}}
    .p-card:hover{{border-color:var(--brand)}}
    .p-card b{{display:block;font-family:var(--mono);font-size:.9rem}}
    .p-card span{{display:block;font-size:.72rem;color:var(--muted);margin-top:3px}}
    .p-card em{{display:block;font-size:.62rem;color:var(--brand);font-style:normal;letter-spacing:.14em;margin-top:6px;text-transform:uppercase}}
    .p-off{{opacity:.45}}
    .p-off:hover{{border-color:rgba(255,255,255,.12)}}
    .p-card{{position:relative;overflow:hidden;transition:border-color .2s,box-shadow .2s}}
    .p-card::before{{content:"";position:absolute;inset:0 0 auto 0;height:2px;background:var(--radiance);opacity:0;transition:opacity .2s}}
    .p-card:hover::before{{opacity:1}}
    .p-card:hover{{box-shadow:0 0 0 1px var(--line-strong),0 8px 26px rgba(0,0,0,.5)}}
    .p-card:hover b{{text-shadow:0 0 10px var(--neon-glow)}}
    .p-go{{display:inline-block;margin-top:10px;padding:6px 12px;border-radius:7px;
      border:1px solid var(--line);font-family:var(--mono);font-size:.68rem;
      color:var(--white);background:rgba(255,255,255,.03);transition:all .2s}}
    .p-card:hover .p-go{{border-color:transparent;color:var(--black);
      background:var(--radiance);box-shadow:0 0 18px rgba(230,240,255,.22)}}
    .p-off .p-go{{display:none}}
    .fd-lede{{font-size:1.02rem;line-height:1.6}}
    .fd-steps{{counter-reset:s;list-style:none;padding:0}}
    .fd-steps li{{counter-increment:s;padding:10px 0 10px 34px;position:relative;border-bottom:1px solid var(--line)}}
    .fd-steps li::before{{content:counter(s);position:absolute;left:0;top:10px;
      width:20px;height:20px;border-radius:5px;background:var(--radiance);color:var(--black);
      font-family:var(--mono);font-size:.7rem;font-weight:700;display:grid;place-items:center}}
    code{{font-family:var(--mono);color:var(--mint);font-size:.86em}}
  </style>
  <script src="/chrome/chrome.js" defer></script>
</head>
<body>
<main class="zh-page">
"""

FOOT_MOUNT = """  <div data-chrome="footer"
       data-slot-brand="{cube} <span class='title-run'><strong>{title}</strong> <span class='sl'>//</span> <span class='brk'>〔</span> <span>3OX</span><span class='rail-dot'>·</span><span>{tag}</span> <span class='brk'>〕</span></span>"
       data-slot-copy="<span class='meta-lead'>sync<span class='sync-dot'{dot}></span><span class='rail-dot'>&middot;</span><span class='port'>{badge}</span><span class='rail-dot'>&middot;</span></span><a class='path' href='#'><span class='seg'>{seg}</span><span class='file'>{file}</span></a><span class='rail-dot meta-crc-dot'>&middot;</span><span data-slot='crc'></span>"
       data-slot-crc="{crc}"></div>
</main>
</body>
</html>
"""


def crc_of(name: str) -> str:
    import hashlib
    return hashlib.blake2s(name.encode(), digest_size=2).hexdigest()


def page(p: dict) -> str:
    e = html.escape
    ports = "".join(
        f"    <tr><td>{e(port)}</td><td>{e(what)}</td></tr>\n"
        for port, what in p["ports"]
    )
    dot = "" if p["state"] == "live" else " data-state='degraded'"
    body = f"""  <div data-chrome="header"
       data-slot-hex="{p['hex']}"
       data-slot-eyebrow="{p['name']}.3ox.me // {e(p['class']).upper()} // {p['state'].upper()}"
       data-slot-title="{e(p['title'])}"></div>

  <section class="zh-body">
    <p class="p-id"><span class="p-glyph">{p['glyph']}</span>
       <span class="p-class">{e(p['class'])} · {e(p['model'])}</span></p>

    <p>{e(p['who'])}</p>
    <p class="p-not">{e(p['not'])}</p>

    <p class="zh-rail">HOST :: {e(p['host'])}</p>

    <table class="p-ports">
{ports}    </table>

    <div class="zh-ctas">
      <a class="zh-btn" href="https://3ox.me/Zensen/">All Zensen 3ox</a>
      <a class="zh-btn ghost" href="https://3ox.dev">3ox.dev</a>
    </div>
  </section>

"""
    return (HEAD.format(title=f"{p['name']}.3ox.me :: {p['title']}")
            + body
            + FOOT_MOUNT.format(cube=CUBE, title=p["title"], tag=p["tag"],
                                badge=p["badge"], dot=dot,
                                seg=p["path"][0], file=p["path"][1],
                                crc=crc_of(p["name"])))


def zensen() -> str:
    e = html.escape
    cards = "".join(
        f"      <a class=\"p-card\" href=\"https://{p['name']}.3ox.me\">"
        f"<b>{p['glyph']} {e(p['title'])}</b>"
        f"<span>{e(p['who'].split('.')[0])}.</span>"
        f"<em>{p['name']}.3ox.me · {p['state']}</em>"
        f"<span class=\"p-go\">Open →</span></a>\n"
        for p in PROFILES
    )
    off = "".join(
        f"      <span class=\"p-card p-off\"><b>{e(n)}</b>"
        f"<span>{e(why)}</span><em>not yet</em></span>\n"
        for n, why in DEFERRED
    )
    body = f"""  <div data-chrome="header"
       data-slot-hex="0xZENSEN"
       data-slot-eyebrow="3OX.ME / ZENSEN // NAMESPACE // X LANE"
       data-slot-title="Zensen"></div>

  <section class="zh-body">
    <p>The 3oxes Zensen runs. Each one is a cube — an agent, a station, a set —
       reachable at its own name. <code>{{name}}.3ox.me</code> mirrors disk
       <code>{{Name}}.me</code>; the page is the reflection, the cube is the thing.</p>

    <p class="zh-rail">NAMESPACE :: Zensen · {len(PROFILES)} LIVE · {len(DEFERRED)} DECLARED</p>

    <div class="p-grid">
{cards}    </div>

    <p class="zh-rail" style="margin-top:22px">DECLARED · NOT YET STANDING</p>
    <div class="p-grid">
{off}    </div>
  </section>

"""
    return (HEAD.format(title="3ox.me/Zensen :: the Zensen namespace")
            + body
            + FOOT_MOUNT.format(cube=CUBE, title="3OX", tag="Profiles",
                                badge=":6053", dot="",
                                seg="satellites/3ox.me/", file="profiles/",
                                crc=crc_of("3ox.me")))


def front_door() -> str:
    example = PROFILES[0]
    body = f"""  <div data-chrome="header"
       data-slot-hex="0x3OXME"
       data-slot-eyebrow="3OX.ME // THE FRONT DOOR // X LANE"
       data-slot-title="Every 3ox has a face"></div>

  <section class="zh-body">
    <p class="fd-lede">A <b>3ox</b> is a cube — one agent, station, or set, with an
       identity that outlives whatever model or runtime is behind it today.
       This is where a 3ox becomes reachable by name.</p>

    <p class="zh-rail">APEX :: 3ox.me · NAMESPACES :: 1 · PROCESSES :: {{len(PROFILES)}}</p>

    <h3>How it works</h3>
    <ol class="fd-steps">
      <li><b>Claim a namespace.</b> <code>3ox.me/&lt;you&gt;/</code> is yours —
          the list of every 3ox you run.</li>
      <li><b>Register a process.</b> Each one takes a name and answers at
          <code>&lt;proc&gt;.3ox.me</code>, with its own origin and its own certificate.</li>
      <li><b>The page mirrors the disk.</b> A 3ox's identity lives in its own cube;
          the page is generated from it, so the two cannot drift apart.</li>
    </ol>

    <h3>See one</h3>
    <div class="p-grid">
      <a class="p-card" href="https://{{example['name']}}.3ox.me"><b>{{example['glyph']}} {{example['title']}}</b><span>{{example['who'].split('.')[0]}}.</span><em>{{example['name']}}.3ox.me · live</em><span class="p-go">Open →</span></a>
      <a class="p-card" href="/Zensen/"><b>◈ Zensen</b><span>The first namespace — {{len(PROFILES)}} processes running.</span><em>3ox.me/Zensen/ · live</em><span class="p-go">Open →</span></a>
    </div>

    <h3>Claim yours</h3>
    <p>Namespaces are not open yet — registration needs an account system, and
       that is being built rather than faked. Until then <code>3ox.me/Zensen/</code>
       is the worked example of what yours will look like.</p>
  </section>

"""
    return (HEAD.format(title="3ox.me :: every 3ox has a face")
            + body
            + FOOT_MOUNT.format(cube=CUBE, title="3OX", tag="Front Door",
                                badge=":6053", dot="",
                                seg="satellites/3ox.me/", file="index.html",
                                crc=crc_of("3ox.me")))


def main() -> None:
    OUT.mkdir(exist_ok=True)
    for p in PROFILES:
        d = OUT / p["name"]
        d.mkdir(exist_ok=True)
        (d / "index.html").write_text(page(p), encoding="utf-8")
        print(f"  ∎ profiles/{p['name']}/index.html")
    (ROOT / "Zensen").mkdir(exist_ok=True)
    (ROOT / "Zensen" / "index.html").write_text(zensen(), encoding="utf-8")
    print(f"  ∎ Zensen/index.html  ({len(PROFILES)} live · {len(DEFERRED)} declared)")
    (ROOT / "index.html").write_text(front_door(), encoding="utf-8")
    print("  ∎ index.html  (front door)")
    (ROOT / "roster.json").write_text(
        json.dumps({"live": [p["name"] for p in PROFILES],
                    "declared": [n for n, _ in DEFERRED]}, indent=2) + "\n",
        encoding="utf-8")
    print("  ∎ roster.json")


if __name__ == "__main__":
    main()
