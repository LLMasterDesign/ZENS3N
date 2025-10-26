#!/usr/bin/env python3
"""
gate_scan.py — Scan an inbox (!1N.3OX) and propose destinations.
Writes proposals.json per .3ox tools contract. No file moves.
"""

import sys
import os
import json
import hashlib
from pathlib import Path
from datetime import datetime, timezone


def xxh_sha256_16(p: Path) -> str:
    h = hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            h.update(chunk)
    return h.hexdigest()[:16]


def suggest_category(file_path: Path) -> tuple[str, str]:
    # Default: suggest sibling 0UT.3OX folder
    return "0UT.3OX", "default"


def find_inbox() -> Path:
    """Find sibling !1N.3OX* folder dynamically"""
    # Go up from Toolkit to parent (e.g., !CMD.CENTER)
    toolkit_dir = Path(__file__).resolve().parent
    parent_dir = toolkit_dir.parent
    
    # Find any !1N.3OX* folder
    inbox_folders = list(parent_dir.glob("!1N.3OX*"))
    if inbox_folders:
        return inbox_folders[0]
    
    # Fallback: create default
    return parent_dir / "!1N.3OX"


def main():
    # Auto-find inbox or use arg if provided
    if len(sys.argv) > 1:
        inbox_dir = Path(sys.argv[1])
    else:
        inbox_dir = find_inbox()
    
    out_json = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("proposals.json")

    if not inbox_dir.exists() or not inbox_dir.is_dir():
        print(f"ERROR: inbox not found: {inbox_dir}")
        sys.exit(1)

    items = []
    # Recursively scan all files, limit to 20
    for entry in sorted(inbox_dir.rglob("*")):
        if not entry.is_file():
            continue
        if len(items) >= 20:
            break
        try:
            size = entry.stat().st_size
            file_hash = xxh_sha256_16(entry)
            # Use relative path from inbox for clarity
            rel_path = entry.relative_to(inbox_dir)
            items.append({
                "file": str(rel_path),
                "path": str(entry.resolve()),
                "size_bytes": size,
                "hash": file_hash
            })
        except Exception as e:
            # Skip unreadable files, keep scan resilient
            continue

    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "inbox": str(inbox_dir.resolve()),
        "items": items,
    }

    out_json.parent.mkdir(parents=True, exist_ok=True)
    with out_json.open('w', encoding='utf-8') as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)

    print(json.dumps({"status": "ok", "found": len(items), "proposals": str(out_json)}, ensure_ascii=False))


if __name__ == "__main__":
    main()


