#!/usr/bin/env python3
"""Threaded, loopback/Tailscale rehearsal server for the static ZENSEN bundle."""

from __future__ import annotations

import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


DEFAULT_ROOT = Path(__file__).resolve().parents[5] / "Websites" / "zensensystems"


class ReusableThreadingHTTPServer(ThreadingHTTPServer):
    allow_reuse_address = True
    daemon_threads = True


class ThreadedStaticHandler(SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, _format: str, *_args: object) -> None:
        # The rehearsal server must not serialize every request through an SSH PTY.
        return


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--directory", type=Path, default=DEFAULT_ROOT)
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=7120)
    args = parser.parse_args()

    root = args.directory.expanduser().resolve()
    if not (root / "index.html").is_file():
        parser.error(f"static entry missing: {root / 'index.html'}")

    handler = partial(ThreadedStaticHandler, directory=str(root))
    server = ReusableThreadingHTTPServer((args.host, args.port), handler)
    print(f"serving {root} on http://{args.host}:{args.port}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
