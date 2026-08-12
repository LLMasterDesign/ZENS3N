#!/usr/bin/env python3
"""Dependency-free static server for the zensen.live satellite."""

from __future__ import annotations

import argparse
import os
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


class ReusableServer(ThreadingHTTPServer):
    allow_reuse_address = True
    daemon_threads = True


class SiteHandler(SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "ZENSEN-LIVE"

    def log_message(self, _format: str, *_args: object) -> None:
        return

    def do_GET(self):  # noqa: N802
        path = urlsplit(self.path).path
        if path == "/Notepad":
            self.send_response(302)
            self.send_header("Location", "/Notepad/")
            self.end_headers()
            return
        return super().do_GET()

    def send_error(self, code, message=None, explain=None):  # noqa: N802
        if code == 404 and urlsplit(self.path).path != "/404.html":
            page = Path(self.directory) / "404.html"
            body = page.read_bytes()
            self.send_response(404, message)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)
            return
        super().send_error(code, message, explain)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=int(os.environ.get("PORT", "6061")))
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    handler = partial(SiteHandler, directory=str(root))
    server = ReusableServer((args.host, args.port), handler)
    print(f"ZENSEN.LIVE :: serving {root} on http://{args.host}:{args.port} :: PORT={args.port}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
