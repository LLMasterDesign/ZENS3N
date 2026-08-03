#!/usr/bin/env python3
"""Small, dependency-free HTTP server for the isolated ZENSEN website branch."""

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
    server_version = "ZENSEN-Static"
    blocked_paths = {"/server.py", "/railway.toml", "/.gitignore"}

    def log_message(self, _format: str, *_args: object) -> None:
        return

    def _request_path(self) -> str:
        return urlsplit(self.path).path

    def _is_blocked(self) -> bool:
        return self._request_path() in self.blocked_paths

    def send_head(self):  # noqa: N802 - stdlib handler API
        if self._is_blocked():
            self.send_error(404)
            return None
        return super().send_head()

    def list_directory(self, _path):  # noqa: N802 - stdlib handler API
        self.send_error(404)
        return None

    def send_error(self, code, message=None, explain=None):  # noqa: N802
        if code == 404 and self._request_path() != "/404.html":
            page = Path(self.directory) / "404.html"
            try:
                body = page.read_bytes()
            except OSError:
                return super().send_error(code, message, explain)
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
    parser.add_argument("--directory", type=Path, default=Path(__file__).parent)
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=int(os.environ.get("PORT", "7120")))
    args = parser.parse_args()

    root = args.directory.expanduser().resolve()
    if not (root / "index.html").is_file():
        parser.error(f"static entry missing: {root / 'index.html'}")
    handler = partial(SiteHandler, directory=str(root))
    server = ReusableServer((args.host, args.port), handler)
    print(
        f"ZENSEN Systems :: Railway container :: serving {root} "
        f"on http://{args.host}:{args.port} :: PORT={args.port}",
        flush=True,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
