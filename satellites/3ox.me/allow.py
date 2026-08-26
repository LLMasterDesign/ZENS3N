#!/usr/bin/env python3
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂ ⋮⋮[0xALLOW]⋮⋮
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.388 // 3OX.ME :: on-demand TLS gate ▞▞
#
# Caddy asks this before minting a certificate for {name}.3ox.me.
# 200 = mint it · anything else = refuse.
#
# The roster is the filesystem: profiles/<name>/index.html exists,
# the name is real. Adding a 3ox is adding a directory — there is no
# second list to drift out of sync with the first.
#
# Law: without this, a wildcard record plus on-demand TLS means any
# stranger pointing DNS at this box makes us mint certificates for
# them, until Let's Encrypt rate-limits the whole domain.

from __future__ import annotations

import argparse
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit, parse_qs

ROOT = Path(__file__).resolve().parent
PROFILES = ROOT / "profiles"
APEX = "3ox.me"
ALWAYS = {APEX, f"www.{APEX}"}


def allowed(host: str) -> bool:
    host = (host or "").strip().lower().rstrip(".")
    if not host:
        return False
    if host in ALWAYS:
        return True
    if not host.endswith(f".{APEX}"):
        return False
    label = host[: -len(f".{APEX}")]
    # one label only — no a.b.3ox.me, no traversal, no surprises
    if not label or "." in label or "/" in label or label.startswith("-"):
        return False
    if not all(c.isalnum() or c == "-" for c in label):
        return False
    return (PROFILES / label / "index.html").is_file()


def roster() -> list[str]:
    if not PROFILES.is_dir():
        return []
    return sorted(
        d.name for d in PROFILES.iterdir()
        if d.is_dir() and (d / "index.html").is_file()
    )


class Gate(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "3OX-ME-GATE"

    def log_message(self, _f: str, *_a: object) -> None:
        return

    def _send(self, code: int, body: bytes, ctype: str = "text/plain; charset=utf-8") -> None:
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):  # noqa: N802
        parts = urlsplit(self.path)
        if parts.path == "/allow":
            host = parse_qs(parts.query).get("domain", [""])[0]
            if allowed(host):
                self._send(200, b"ok\n")
            else:
                self._send(404, b"not a 3ox\n")
            return
        if parts.path == "/healthz":
            self._send(200, b"3ox-me-gate:ok\n")
            return
        if parts.path == "/api/health":
            names = roster()
            body = ('{"status":"ok","profiles":%d,"names":[%s]}\n' % (
                len(names), ",".join('"%s"' % n for n in names)
            )).encode()
            self._send(200, body, "application/json; charset=utf-8")
            return
        self._send(404, b"not found\n")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=int(os.environ.get("PORT", "6053")))
    args = ap.parse_args()
    srv = ThreadingHTTPServer((args.host, args.port), Gate)
    srv.daemon_threads = True
    srv.allow_reuse_address = True
    names = roster()
    print(f"3OX.ME gate :: {len(names)} profiles :: "
          f"http://{args.host}:{args.port}/allow", flush=True)
    for n in names:
        print(f"  ∎ {n}.3ox.me", flush=True)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        srv.server_close()


if __name__ == "__main__":
    main()
