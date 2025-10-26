
import os, re, sys, glob, yaml, datetime, hashlib
from pathlib import Path

def load_yaml(path):
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

HERE = Path(__file__).parent
cfg   = load_yaml(HERE / "config.yaml")

def now_iso():
    return datetime.datetime.now().astimezone().isoformat()

def guess_sirius_stamp(dt=None):
    dt = dt or datetime.datetime.now()
    return f"⧗-{str(dt.year)[-2:]}.??"

def read_text_if_exists(path):
    try:
        return Path(path).read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""

def find_first_existing_root(roots):
    for r in roots:
        if Path(r).exists():
            return Path(r)
    return None

def ensure_report_dir(base_dir):
    Path(base_dir).mkdir(parents=True, exist_ok=True)

def check_prism_block(text):
    if not text:
        return False, ["[PRISM] File unreadable or empty"]
    problems = []
    lines = text.splitlines()
    needed = [r"^P:\s", r"^R:\s", r"^I:\s", r"^S:\s", r"^M:\s"]
    idx = 0
    for line in lines:
        if re.search(needed[idx], line):
            idx += 1
            if idx == len(needed):
                break
    if idx < len(needed):
        problems.append(f"[PRISM] Missing or unordered shard lines; matched {idx}/5")
    return (len(problems)==0), problems

def latest_file_age_minutes(folder, globs):
    latest = None
    for patt in globs:
        for fp in Path(folder).glob(patt):
            mtime = fp.stat().st_mtime
            if latest is None or mtime > latest:
                latest = mtime
    if latest is None:
        return None
    age_min = (datetime.datetime.now().timestamp() - latest) / 60.0
    return age_min

def station_paths(root, spec):
    cloud = root / spec["cloud"]
    ops   = root / spec["ops"]
    out_folder = ops / "0UT.3OX"
    receipts_folder = ops / "RECEIPTS"
    brain_file = cloud / ".3ox" / "station.brain.md"
    rules_file = ops / ".3ox" / "STATION.RULES.md"
    return {
        "cloud": cloud, "ops": ops, "out": out_folder,
        "receipts": receipts_folder,
        "brain": brain_file, "rules": rules_file
    }

def policy_presence(root, required_list):
    missing = []
    for rel in required_list:
        p = root / rel
        if not p.exists():
            missing.append(str(p))
    return missing

def write_report(report_dir, data):
    ensure_report_dir(report_dir)
    stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    outpath = Path(report_dir) / f"heartbeat_{stamp}.yaml"
    with open(outpath, "w", encoding="utf-8") as f:
        yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False)
    return outpath

def mirror_to_incoming(root, station_incoming, data):
    try:
        dest = root / station_incoming
        dest.mkdir(parents=True, exist_ok=True)
        stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        with open(dest / f"heartbeat_{stamp}.yaml", "w", encoding="utf-8") as f:
            yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False)
        return True, None
    except Exception as e:
        return False, str(e)

# --- TOML receipt parsing (minimal, key = "value" only; comments allowed) ---
def parse_toml_minimal(text):
    data = {}
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        # allow inline comments
        if "#" in line:
            line = line.split("#",1)[0].strip()
        # basic key = value
        m = re.match(r'^([A-Za-z0-9_\-\.]+)\s*=\s*(.+)$', line)
        if not m:
            continue
        k, v = m.group(1), m.group(2).strip()
        # strip quotes if present
        if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
            v = v[1:-1]
        # try to coerce booleans and numbers
        if re.fullmatch(r"true|false", v, flags=re.IGNORECASE):
            v = v.lower() == "true"
        else:
            try:
                if "." in v:
                    v = float(v)
                else:
                    v = int(v)
            except Exception:
                pass
        data[k] = v
    return data

def sha256_hex(s):
    return hashlib.sha256(s.encode("utf-8", errors="ignore")).hexdigest()

def scan_receipts(folder, globs, limit):
    files = []
    for patt in globs:
        files.extend(list(Path(folder).glob(patt)))
    files.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return files[:limit]

def validate_receipt_fields(rec, required):
    missing = [k for k in required if k not in rec or rec[k] in ("", None)]
    return missing

def summarize_receipts(folder, cfg_receipts):
    if not folder.exists():
        return {"present": False, "count": 0, "latest_minutes": None, "summaries": [], "errors": ["[RECEIPTS] Folder missing"]}
    files = scan_receipts(folder, cfg_receipts.get("globs", ["*.toml"]), cfg_receipts.get("max_scan_files", 200))
    if not files:
        return {"present": True, "count": 0, "latest_minutes": None, "summaries": [], "errors": []}
    now = datetime.datetime.now().timestamp()
    latest_age = (now - files[0].stat().st_mtime)/60.0
    req = cfg_receipts.get("required_fields", [])
    summaries = []
    errors = []
    for fp in files[:cfg_receipts.get("summarize_last", 15)]:
        text = read_text_if_exists(fp)
        data = parse_toml_minimal(text)
        miss = validate_receipt_fields(data, req)
        info = {
            "file": str(fp),
            "missing_fields": miss,
            "ok": len(miss)==0,
            "sirius_time": data.get("sirius_time"),
            "source": data.get("source"),
            "destination": data.get("destination"),
            "status": data.get("status"),
            "hash": data.get("hash"),
            "sha256": sha256_hex(text)[:16]
        }
        if miss:
            errors.append(f"[RECEIPT] {fp.name} missing {miss}")
        summaries.append(info)
    return {
        "present": True,
        "count": len(files),
        "latest_minutes": round(latest_age,1),
        "summaries": summaries,
        "errors": errors
    }

def main():
    root = find_first_existing_root(cfg["root_paths"])
    report = {
        "timestamp": now_iso(),
        "sirius_time_guess": guess_sirius_stamp(),
        "root_detected": str(root) if root else None,
        "stations": {},
        "policy": {},
        "summary": {}
    }
    if not root:
        report["summary"] = {"status": "FAIL", "details": "No configured root path found"}
        outp = write_report(Path(__file__).parent / "reports", report)
        print(f"[Heartbeat] Wrote report: {outp}")
        return 2

    # policy presence
    missing_policy = []
    for rel in cfg.get("required_files", []):
        p = root / rel
        if not p.exists(): missing_policy.append(str(p))
    report["policy"]["missing"] = missing_policy

    warn_thresh = cfg.get("freshness_minutes_warn", 60)
    fail_thresh = cfg.get("freshness_minutes_fail", 180)
    mirrors = []
    warnings = 0

    receipts_cfg = cfg.get("receipts", {"enabled": False})
    for name, spec in cfg["stations"].items():
        # Build station paths
        cloud = root / spec["cloud"]
        ops   = root / spec["ops"]
        out_folder = ops / "0UT.3OX"
        receipts_folder = ops / "RECEIPTS"
        brain_file = cloud / ".3ox" / "station.brain.md"
        rules_file = ops / ".3ox" / "STATION.RULES.md"

        notes, errors = [], []
        invariants = {
            ".3ox_present": (cloud / ".3ox").exists(),
            "ops_present": ops.exists(),
            "out_folder_present": out_folder.exists(),
        }
        for k,v in invariants.items():
            if not v: errors.append(f"[INV] Missing required path: {k}")

        # PRISM checks
        prism_ok = True
        for p in [brain_file, rules_file]:
            if p.exists():
                ok, probs = check_prism_block(read_text_if_exists(p))
                if not ok:
                    prism_ok = False
                    errors.extend([*probs, f"[PRISM] Problem in {p}"])
            else:
                notes.append(f"[INFO] Optional file not found: {p}")

        # 0UT freshness
        age_min = None
        if out_folder.exists():
            age_min = latest_file_age_minutes(out_folder, cfg.get("out_globs", ["*.yaml","*.yml","*.json"]))
        else:
            errors.append("[OUT] 0UT.3OX folder missing")

        freshness_state = "NONE"
        if age_min is None:
            freshness_state = "NONE"
            warnings += 1
            notes.append("[OUT] No recent files detected in 0UT.3OX")
        else:
            if age_min > fail_thresh:
                freshness_state = "STALE_FAIL"
                errors.append(f"[OUT] Stale 0UT.3OX: {age_min:.0f} minutes")
            elif age_min > warn_thresh:
                freshness_state = "STALE_WARN"
                notes.append(f"[OUT] Stale 0UT.3OX: {age_min:.0f} minutes")
            else:
                freshness_state = "FRESH"

        # Receipts
        receipts_report = {}
        if receipts_cfg.get("enabled", False):
            receipts_report = summarize_receipts(receipts_folder, receipts_cfg)
            if receipts_report.get("errors"):
                notes.extend(receipts_report["errors"])

        # assemble per-station
        station_block = {
            "paths": {
                "cloud": str(cloud), "ops": str(ops), "out": str(out_folder),
                "receipts": str(receipts_folder),
                "brain": str(brain_file), "rules": str(rules_file)
            },
            "invariants": invariants,
            "prism_ok": prism_ok,
            "out_fresh_minutes": None if age_min is None else round(age_min, 1),
            "freshness_state": freshness_state,
            "receipts": receipts_report if receipts_cfg.get("enabled", False) else {"enabled": False},
            "notes": notes,
            "errors": errors
        }
        report["stations"][name] = station_block

        # mirror minimal per-station report
        if cfg.get("report_output",{}).get("mirror_to_incoming", False):
            try:
                dest = root / spec["incoming"]
                dest.mkdir(parents=True, exist_ok=True)
                stamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                payload = {
                    "timestamp": report["timestamp"],
                    "station": name,
                    "prism_ok": prism_ok,
                    "freshness_state": freshness_state,
                    "out_fresh_minutes": station_block["out_fresh_minutes"],
                    "receipts": {
                        "present": station_block.get("receipts",{}).get("present"),
                        "count": station_block.get("receipts",{}).get("count"),
                        "latest_minutes": station_block.get("receipts",{}).get("latest_minutes"),
                    },
                    "errors": errors,
                    "notes": notes
                }
                with open(dest / f"heartbeat_{stamp}.yaml", "w", encoding="utf-8") as f:
                    yaml.safe_dump(payload, f, allow_unicode=True, sort_keys=False)
            except Exception as e:
                pass

    # summarize
    status = "OK"
    detail = []
    if missing_policy:
        status = "WARN"; detail.append(f"{len(missing_policy)} policy docs missing")
    if any("[INV]" in " ".join(st["errors"]) for st in report["stations"].values()):
        status = "FAIL"; detail.append("Invariant path(s) missing")
    if any(not st["prism_ok"] for st in report["stations"].values()):
        if status != "FAIL": status = "WARN"
        detail.append("PRISM issues detected")
    # any stale
    stales = [s for s in report["stations"].values() if s["freshness_state"] in ("STALE_WARN","STALE_FAIL","NONE")]
    if stales and status != "FAIL":
        status = "WARN"; detail.append("stale or missing 0UT detected")
    report["summary"] = { "status": status, "details": " ; ".join(detail) if detail else "All green" }

    outp = write_report(HERE / cfg["report_output"]["local_report_dir"], report)
    print(f"[Heartbeat] Wrote report: {outp}")
    return 0 if status=="OK" else (1 if status=="WARN" else 2)

if __name__ == "__main__":
    sys.exit(main())
