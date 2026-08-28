#!/usr/bin/env python3
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂ ⋮⋮[0xCONSOLE]⋮⋮
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.385 // CONSOLE :: minsky · see everything ▞▞
#
# telos: two panels, on the phone, over the VPN. PLANES answers
# "is anything public that shouldn't be." HEALTH answers "is the
# box still keeping its promises." Nothing else. :: ∎
#
#   :6050  127.0.0.1 · behind caddy on the tailnet plane :6200
#          CISA ones-digit 0 = Observe. A console observes.
#
# It lives on minsky and not on en0 on purpose: a console that
# runs on the laptop goes dark exactly when the laptop does,
# which is the outage you most need to see.
#
# NO SUDO. Certs are read by TLS handshake, not off the disk.
# DNS is read by querying, not by reading knot.conf. Both test
# what a stranger actually gets rather than what config claims.
#
# minsky cannot ssh to en0 and will not be given a key to — the
# VPS does not get to reach home metal. en0 PUSHES its edge
# state up (it already ssh's here for vps-keep). Staleness of
# that file IS the "en0 is down" signal.

from __future__ import annotations

import datetime as dt
import json
import os
import socket
import ssl
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

DATA = Path(os.environ.get("ZENSEN_DATA", "/srv/zens3n-data"))
WATCH = DATA / "watch"
EN0_FEED = WATCH / "en0.json"
RECEIPTS = WATCH / "console.gensL"
INTERVAL = int(os.environ.get("CONSOLE_INTERVAL", "600"))  # 10 min

# Zones Knot is authoritative for. Public information; the private
# half (DNSSEC keys) is what vps-keep guards, and is never read here.
ZONES = [
    "3ox.me", "3ox.dev", "sysgen.sh", "sysgen.dev", "zensen.live",
    "zensen.systems", "zensen.solutions", "zensen.store",
    "zensensystems.com", "zensenenterprises.com",
]
# One Hetzner secondary is enough to prove AXFR is flowing.
SECONDARY = "213.239.242.238"

# Names that must answer TLS. Wildcard children are minted on
# demand, so only the ones with a standing vhost are checked.
CERT_HOSTS = [
    "3ox.me", "www.3ox.me", "3ox.dev", "www.3ox.dev",
    "sysgen.sh", "www.sysgen.sh", "docs.sysgen.dev",
    "ender.3ox.me", "orion.3ox.me", "tpr.3ox.me",
]

CERT_WARN_DAYS = 14
FEED_STALE_MIN = 90     # en0 pushes hourly; 90min is a real gap

_state: dict = {"booting": True}
_lock = threading.Lock()


# ── helpers ─────────────────────────────────────────────────

def _now() -> str:
    return dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def _run(cmd: list[str], timeout: int = 8) -> str:
    try:
        r = subprocess.run(cmd, capture_output=True, text=True,
                           timeout=timeout)
        return r.stdout.strip()
    except Exception:
        return ""


def receipt(face: str, glyph: str, **kv) -> None:
    """One .gensL line. Ender narrates these; silence is healthy."""
    body = " | ".join(f"{k}={v}" for k, v in kv.items())
    line = (f"▞▞⋮⋮ ⎊::console::{face}@MINSKY :: {glyph} | {body} "
            f"| ts={_now()} :: ∎")
    try:
        WATCH.mkdir(parents=True, exist_ok=True)
        with RECEIPTS.open("a", encoding="utf-8") as fh:
            fh.write(line + "\n")
    except Exception:
        pass


# ── health checks · no sudo, all over the network ───────────

def check_certs() -> list[dict]:
    out = []
    ctx = ssl.create_default_context()
    for host in CERT_HOSTS:
        row = {"host": host, "days": None, "state": "𝜵", "note": ""}
        try:
            with socket.create_connection((host, 443), timeout=6) as sock:
                with ctx.wrap_socket(sock, server_hostname=host) as tls:
                    not_after = tls.getpeercert()["notAfter"]
            exp = dt.datetime.strptime(not_after, "%b %d %H:%M:%S %Y %Z")
            exp = exp.replace(tzinfo=dt.timezone.utc)
            days = (exp - dt.datetime.now(dt.timezone.utc)).days
            row["days"] = days
            row["state"] = "∎" if days > CERT_WARN_DAYS else "◑"
        except Exception as exc:
            row["note"] = type(exc).__name__
        out.append(row)
    return out


def check_dns() -> list[dict]:
    """Local Knot serial vs a Hetzner secondary. Drift = AXFR stalled."""
    out = []
    for zone in ZONES:
        row = {"zone": zone, "local": None, "secondary": None,
               "state": "𝜵"}
        loc = _run(["dig", "+short", "+time=3", "+tries=1",
                    "@127.0.0.1", "SOA", zone]).split()
        sec = _run(["dig", "+short", "+time=3", "+tries=1",
                    f"@{SECONDARY}", "SOA", zone]).split()
        if len(loc) > 2:
            row["local"] = loc[2]
        if len(sec) > 2:
            row["secondary"] = sec[2]
        if row["local"] and row["local"] == row["secondary"]:
            row["state"] = "∎"
        elif row["local"] and row["secondary"]:
            row["state"] = "⟊"          # both answer, serials differ
        out.append(row)
    return out


def check_disk() -> dict:
    st = os.statvfs("/")
    total = st.f_blocks * st.f_frsize
    free = st.f_bavail * st.f_frsize
    pct = round(100 * (total - free) / total, 1) if total else 0
    return {
        "total_gb": round(total / 1e9, 1),
        "free_gb": round(free / 1e9, 1),
        "used_pct": pct,
        "state": "∎" if pct < 80 else ("◑" if pct < 92 else "↯"),
    }


def check_feed() -> dict:
    """en0's pushed edge state. Staleness IS the en0-down signal."""
    row = {"present": False, "age_min": None, "state": "↯",
           "note": "no feed from en0"}
    if not EN0_FEED.is_file():
        return row
    age = (time.time() - EN0_FEED.stat().st_mtime) / 60
    row.update(present=True, age_min=round(age, 1), note="")
    row["state"] = "∎" if age < FEED_STALE_MIN else "◑"
    if age >= FEED_STALE_MIN:
        row["note"] = "en0 has not reported — assume it is down"
    return row


def read_planes() -> dict:
    """PLANES panel. The headline is the misplaced count."""
    out = {"en0": None, "misplaced": [], "public": 0, "routed": 0,
           "verdict": "unknown"}
    try:
        feed = json.loads(EN0_FEED.read_text(encoding="utf-8"))
    except Exception:
        return out
    out["en0"] = {"node": feed.get("node"), "ts": feed.get("ts"),
                  "verdict": feed.get("verdict")}
    out["routed"] = feed.get("routed", 0)
    out["public"] = feed.get("public", 0)
    out["verdict"] = feed.get("verdict", "unknown")
    for r in feed.get("routes", []):
        if r.get("public") and r.get("plane") in ("private", "orphan"):
            out["misplaced"].append({
                "port": r["port"], "path": r["path"],
                "plane": r["plane"], "upstream": r.get("upstream", ""),
            })
    return out


def collect() -> dict:
    planes = read_planes()
    certs = check_certs()
    dns = check_dns()
    disk = check_disk()
    feed = check_feed()

    alarms = []
    if planes["misplaced"]:
        alarms.append(("↯", "plane",
                       f"{len(planes['misplaced'])} public that should not be"))
    if feed["state"] != "∎":
        alarms.append((feed["state"], "feed", feed["note"] or "en0 feed"))
    bad_cert = [c for c in certs if c["state"] != "∎"]
    if bad_cert:
        alarms.append(("◑", "certs", f"{len(bad_cert)} need attention"))
    bad_dns = [d for d in dns if d["state"] != "∎"]
    if bad_dns:
        alarms.append(("⟊", "dns", f"{len(bad_dns)} zone(s) out of sync"))
    if disk["state"] != "∎":
        alarms.append((disk["state"], "disk", f"{disk['used_pct']}% used"))

    st = {
        "ts": _now(),
        "planes": planes,
        "certs": certs,
        "dns": dns,
        "disk": disk,
        "feed": feed,
        "alarms": [{"glyph": g, "kind": k, "note": n} for g, k, n in alarms],
    }

    # Silence is a feature: only speak when something is off.
    if alarms:
        for g, k, n in alarms:
            receipt("sweep", g, kind=k, note=n)
    return st


def loop() -> None:
    global _state
    while True:
        try:
            st = collect()
        except Exception as exc:                       # never die
            st = {"ts": _now(), "error": f"{type(exc).__name__}: {exc}"}
            receipt("sweep", "𝜵", kind="collector", note=type(exc).__name__)
        with _lock:
            _state = st
        time.sleep(INTERVAL)


# ── face ────────────────────────────────────────────────────

PAGE = """<!doctype html><html lang=en><head><meta charset=utf-8>
<meta name=viewport content="width=device-width,initial-scale=1">
<meta name=color-scheme content=dark>
<title>CONSOLE · minsky</title><style>
:root{--bg:#040609;--ink:#e7ecf5;--dim:#8b94a8;--accent:#4fd1c5;
 --gold:#d8c285;--red:#e06c75;--amber:#d8a657;--line:#232838;
 --mono:ui-monospace,Menlo,Consolas,monospace}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);
 font:13px/1.55 var(--mono);-webkit-text-size-adjust:100%}
main{max-width:640px;margin:0 auto;padding:20px 14px 56px}
h1{font-size:13px;letter-spacing:.14em;color:var(--gold);
 font-weight:700;margin:0 0 2px}
.sub{color:var(--dim);font-size:11px;margin-bottom:20px}
h2{font-size:11px;letter-spacing:.18em;color:var(--accent);
 margin:26px 0 8px;padding-bottom:5px;border-bottom:1px solid var(--line)}
.big{font-size:30px;line-height:1.1;font-weight:700;margin:6px 0}
.ok{color:var(--accent)}.warn{color:var(--amber)}.bad{color:var(--red)}
.dim{color:var(--dim)}
table{width:100%;border-collapse:collapse;font-size:12px}
td{padding:4px 0;border-bottom:1px solid var(--line);
 vertical-align:top}
td.r{text-align:right;white-space:nowrap;padding-left:8px}
.g{width:1.4em;display:inline-block}
.alarm{border-left:3px solid var(--red);padding:7px 10px;
 margin:7px 0;background:#1a0f11}
.quiet{border-left:3px solid var(--accent);padding:7px 10px;
 background:#0a1412;color:var(--dim)}
footer{margin-top:32px;color:var(--dim);font-size:11px;
 border-top:1px solid var(--line);padding-top:10px}
a{color:var(--accent)}
</style></head><body><main id=app>loading…</main>
<script>
const G={'∎':'ok','◑':'warn','⟊':'warn','𝜵':'bad','↯':'bad','⌁':'warn'};
const cls=g=>G[g]||'dim';
const esc=s=>String(s).replace(/[&<>]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));

function render(s){
  if(s.error) return `<h1>CONSOLE</h1><div class=alarm>collector error<br>
    <span class=dim>${esc(s.error)}</span></div>`;
  const p=s.planes||{}, mis=p.misplaced||[];
  let h=`<h1>CONSOLE · MINSKY</h1>
    <div class=sub>tailnet only · ${esc(s.ts||'')}</div>`;

  h+=(s.alarms&&s.alarms.length)
    ? s.alarms.map(a=>`<div class=alarm><span class="g ${cls(a.glyph)}">${a.glyph}</span>
        <b>${esc(a.kind)}</b> — ${esc(a.note)}</div>`).join('')
    : `<div class=quiet>∎ nothing to report</div>`;

  h+=`<h2>PLANES</h2>`;
  if(!p.en0){
    h+=`<div class=alarm>no feed from en0 — cannot see the laptop's routes</div>`;
  }else{
    const n=mis.length;
    h+=`<div class="big ${n?'bad':'ok'}">${n}</div>
      <div class=dim>public that should not be
        &middot; ${p.public||0} public of ${p.routed||0} routed</div>`;
    if(n) h+=`<table>`+mis.map(m=>`<tr>
        <td>:${m.port}${esc(m.path)}<br><span class=dim>${esc(m.upstream)}</span></td>
        <td class="r ${m.plane==='orphan'?'dim':'bad'}">${esc(m.plane)}</td>
      </tr>`).join('')+`</table>`;
  }

  h+=`<h2>HEALTH</h2>`;
  const f=s.feed||{};
  h+=`<table>
    <tr><td><span class="g ${cls(f.state)}">${f.state||'𝜵'}</span>en0 feed</td>
      <td class=r>${f.age_min!=null?esc(f.age_min)+'m ago':'absent'}</td></tr>
    <tr><td><span class="g ${cls((s.disk||{}).state)}">${(s.disk||{}).state||''}</span>disk</td>
      <td class=r>${(s.disk||{}).used_pct}% &middot; ${(s.disk||{}).free_gb}G free</td></tr>
  </table>`;

  h+=`<h2>CERTS</h2><table>`+(s.certs||[]).map(c=>`<tr>
      <td><span class="g ${cls(c.state)}">${c.state}</span>${esc(c.host)}</td>
      <td class=r>${c.days!=null?esc(c.days)+'d':esc(c.note||'—')}</td>
    </tr>`).join('')+`</table>`;

  h+=`<h2>DNS · knot vs hetzner</h2><table>`+(s.dns||[]).map(d=>`<tr>
      <td><span class="g ${cls(d.state)}">${d.state}</span>${esc(d.zone)}</td>
      <td class=r>${esc(d.local??'—')} / ${esc(d.secondary??'—')}</td>
    </tr>`).join('')+`</table>`;

  h+=`<footer>serial: knot / hetzner &middot; certs: days left<br>
    <a href="/state.json">state.json</a></footer>`;
  return h;
}
async function tick(){
  try{
    const r=await fetch('/state.json',{cache:'no-store'});
    document.getElementById('app').innerHTML=render(await r.json());
  }catch(e){
    document.getElementById('app').innerHTML=
      '<h1>CONSOLE</h1><div class=alarm>console unreachable</div>';
  }
}
tick();setInterval(tick,30000);
</script></body></html>"""


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "CONSOLE"

    def log_message(self, *_a):        # caddy logs; don't double up
        return

    def _send(self, code, body: bytes, ctype: str):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(body)

    def do_GET(self):
        path = self.path.split("?", 1)[0].rstrip("/") or "/"
        if path == "/":
            self._send(200, PAGE.encode(), "text/html; charset=utf-8")
        elif path == "/state.json":
            with _lock:
                body = json.dumps(_state, indent=1).encode()
            self._send(200, body, "application/json; charset=utf-8")
        elif path == "/healthz":
            self._send(200, b"ok", "text/plain")
        else:
            self._send(404, b"404\n", "text/plain")

    do_HEAD = do_GET


def main() -> None:
    # INGRESS law #2: everything that is not caddy/sshd/knotd binds
    # 127.0.0.1 or the tailscale address. The console binds the
    # tailscale address, so it needs no vhost and does not collide
    # with ZEN.HUB on :6200 (which the hub deploy regenerates).
    host = os.environ.get("BIND", "100.85.222.9")
    port = int(os.environ.get("PORT", "6050"))
    WATCH.mkdir(parents=True, exist_ok=True)
    threading.Thread(target=loop, daemon=True).start()
    print(f"console :: {host}:{port} :: every {INTERVAL}s", flush=True)
    ThreadingHTTPServer((host, port), Handler).serve_forever()


if __name__ == "__main__":
    main()
