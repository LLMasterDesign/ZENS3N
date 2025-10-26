#!/usr/bin/env python3
"""
gate_apply.py — Apply approved decisions.json, move files, emit receipts.
Writes receipts to nearest .3ox/0ut.3ox and logs basic results.
"""

import sys
import os
import json
import shutil
import hashlib
from pathlib import Path
from datetime import datetime, timezone
from typing import Optional, Dict, Any


def find_nearest_dot3ox(start_dir: Path) -> Path | None:
    cur = start_dir
    while True:
        candidate = cur / ".3ox"
        if candidate.exists() and candidate.is_dir():
            return candidate
        if cur.parent == cur:
            return None
        cur = cur.parent


def xxh_sha256_16(p: Path) -> str:
    h = hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            h.update(chunk)
    return h.hexdigest()[:16]


def load_nearby_label(src_dir: Path) -> Optional[Dict[str, Any]]:
    # Look for a label.toml either next to the file or at ops root
    candidates = [src_dir / "label.toml"]
    ops_root = src_dir
    for _ in range(4):
        if (ops_root / "label.toml").exists():
            candidates.append(ops_root / "label.toml")
            break
        if ops_root.parent == ops_root:
            break
        ops_root = ops_root.parent
    for p in candidates:
        if p.exists():
            try:
                import tomllib  # py311+
            except Exception:
                try:
                    import tomli as tomllib  # type: ignore
                except Exception:
                    return None
            try:
                return tomllib.loads(p.read_text(encoding='utf-8'))
            except Exception:
                return None
    return None


def write_receipt(dot3ox: Path, src: Path, dst: Path, file_hash: str, status: str, label: Optional[Dict[str, Any]] = None):
    ops_root = dot3ox.parent
    # Find OPS-level 0UT.3OX* folder (e.g., "0UT.3OX CMD")
    candidates = [p for p in ops_root.iterdir() if p.is_dir() and "0UT.3OX" in p.name.upper()]
    if candidates:
        out_dir = candidates[0] / "receipts"
    else:
        # Fallback to .3ox local outbox
        out_dir = dot3ox / "0ut.3ox" / "receipts"
    out_dir.mkdir(parents=True, exist_ok=True)
    
    # Write individual receipt artifact
    ts = datetime.now(timezone.utc).isoformat()
    receipt = out_dir / f"receipt_{ts.replace(':','').replace('-','').replace('.','')}.log"
    with receipt.open('w', encoding='utf-8') as f:
        f.write(f"Operation: move\n")
        f.write(f"File: {src.name}\n")
        f.write(f"From: {src}\n")
        f.write(f"To: {dst}\n")
        f.write(f"Hash: {file_hash}\n")
        f.write(f"Time: {ts}\n")
        f.write(f"Status: {status}\n")
        # Enrich with label metadata if available
        if label:
            shipment = label.get("shipment", {})
            file_meta = label.get("file", {})
            audit = label.get("audit", {})
            f.write(f"Label.Source: {shipment.get('source','')}\n")
            f.write(f"Label.Destination: {shipment.get('destination','')}\n")
            f.write(f"Label.Priority: {shipment.get('priority','')}\n")
            if file_meta.get('name'):
                f.write(f"Label.FileName: {file_meta.get('name')}\n")
            if audit.get('hash'):
                f.write(f"Label.Hash: {audit.get('hash')}\n")
            if audit.get('hash_algo'):
                f.write(f"Label.HashAlgo: {audit.get('hash_algo')}\n")
            if audit.get('sirius_time'):
                f.write(f"Label.SiriusTime: {audit.get('sirius_time')}\n")
    
    # Also update LogBook index (aggregated summary)
    logbook = ops_root / "LogBook"
    if logbook.exists() and logbook.is_dir():
        index_file = logbook / "receipts_index.json"
        if index_file.exists():
            index_data = json.loads(index_file.read_text(encoding='utf-8'))
        else:
            index_data = {"updated_at": "", "receipts": []}
        
        index_data["updated_at"] = datetime.now(timezone.utc).isoformat()
        entry = {
            "timestamp": ts,
            "file": src.name,
            "from": str(src),
            "to": str(dst),
            "hash": file_hash,
            "receipt_path": str(receipt.resolve())
        }
        if label:
            shipment = label.get("shipment", {})
            entry["priority"] = shipment.get("priority")
            entry["destination"] = shipment.get("destination")
        index_data["receipts"].append(entry)
        
        index_file.write_text(json.dumps(index_data, ensure_ascii=False, indent=2), encoding='utf-8')
    
    return receipt


def main():
    if len(sys.argv) < 2:
        print("Usage: python gate_apply.py <decisions_json>")
        sys.exit(2)

    decisions_path = Path(sys.argv[1])
    if not decisions_path.exists():
        print(f"ERROR: decisions file not found: {decisions_path}")
        sys.exit(1)

    data = json.loads(decisions_path.read_text(encoding='utf-8'))
    inbox = Path(data.get("inbox", ".")).resolve()
    dot3ox = find_nearest_dot3ox(inbox)
    moved = []
    skipped = []
    receipts = []

    for item in data.get("decisions", []):
        file_name = item.get("file")
        approve = bool(item.get("approve", False))
        dest_cat = item.get("dest_cat")

        src = (inbox / file_name).resolve()
        if not approve or not src.exists():
            skipped.append(file_name)
            continue

        # Build destination path: <CAT>/<1N.3OX>/<file>
        if not dest_cat:
            skipped.append(file_name)
            continue
        dest_inbox = Path(dest_cat) / "1N.3OX"
        if not dest_inbox.exists():
            skipped.append(file_name)
            continue

        dst = (dest_inbox / file_name).resolve()
        try:
            file_hash = xxh_sha256_16(src)
            shutil.move(str(src), str(dst))
            moved.append(file_name)
            if dot3ox:
                label = load_nearby_label(inbox)
                receipt = write_receipt(dot3ox, src, dst, file_hash, "MOVED", label)
                receipts.append(str(receipt))
        except Exception:
            skipped.append(file_name)
            continue

    print(json.dumps({
        "status": "ok",
        "moved": moved,
        "skipped": skipped,
        "receipts": receipts
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()


