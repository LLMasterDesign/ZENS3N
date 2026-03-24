#!/usr/bin/env python3
"""3OX.AI terminal dashboard.

Layout:
- Left pane: navigation + control keys
- Center pane: 50/50 split
- Right pane: 50/50 split
  - Top-right: page-specific details
  - Bottom-right: live run log stream (runtime logs + control output + notes)
"""

import argparse
import curses
import math
import os
import shutil
import subprocess
import threading
import time
from collections import deque
from datetime import datetime, timezone
from pathlib import Path

NAV_ITEMS = ["Overview", "Triad", "Lifecycle", "Live"]
TRIAD_KEYS = ["tape", "pulse", "warden"]
SERVICE_ORDER = ["supervisor", "tape", "pulse", "warden", "queue", "worker"]
SERVICE_UNITS = [
    "3ox-supervisor.service",
    "3ox-pulse.service",
    "3ox-tape.service",
    "3ox-warden.service",
    "vec3.service",
]
MOTION_FRAMES = ["|", "/", "-", "\\"]

CP_DEFAULT = 1
CP_ORANGE = 2
CP_BANNER = 3
CP_DIM = 4
CP_GOOD = 5
CP_WARN = 6

GLYPH_LINE = "▛▞// ⟦ ⎊ ⟧ :: 3OX.Ai tui"
THICK_BAR = "████████████████████████████████"


def safe_add(win, y, x, text, attr=0):
    try:
        h, w = win.getmaxyx()
        if y < 0 or y >= h or x >= w:
            return
        max_len = max(0, w - x - 1)
        if max_len <= 0:
            return
        win.addnstr(y, x, text, max_len, attr)
    except curses.error:
        pass


def clamp(value, low, high):
    return max(low, min(high, value))


def human_bytes(num):
    units = ["B", "KB", "MB", "GB", "TB"]
    n = float(num)
    idx = 0
    while n >= 1024 and idx < len(units) - 1:
        n /= 1024.0
        idx += 1
    if idx == 0:
        return f"{int(n)} {units[idx]}"
    return f"{n:.1f} {units[idx]}"


def parse_iso_utc(ts):
    if ts == "none":
        return None
    try:
        return datetime.fromisoformat(ts.replace("Z", "+00:00")).astimezone(timezone.utc)
    except Exception:
        return None


def seconds_since(dt):
    if not dt:
        return None
    now = datetime.now(timezone.utc)
    return max(0, int((now - dt).total_seconds()))


def fmt_age(seconds):
    if seconds is None:
        return "n/a"
    if seconds < 60:
        return f"{seconds}s"
    if seconds < 3600:
        return f"{seconds // 60}m"
    return f"{seconds // 3600}h{(seconds % 3600) // 60:02d}m"


def priority_label(priority):
    p = float(priority)
    if p <= 1:
        return "VOID"
    if p <= 3:
        return "LOW"
    if p <= 5:
        return "MID"
    if p <= 7:
        return "HIGH"
    return "MAX"


def priority_bar(priority, width=12):
    ratio = clamp(float(priority) / 10.0, 0.0, 1.0)
    filled = int(round(ratio * width))
    return "[" + ("#" * filled) + ("-" * (width - filled)) + "]"


def command_exists(cmd):
    return shutil.which(cmd) is not None


def find_runtime_root():
    env_path = os.environ.get("THREEOX_TRON_DIR")
    candidates = []
    if env_path:
        candidates.append(Path(env_path))

    candidates.extend(
        [
            Path("/root/!CENTRAL.CMD/_TRON/3OX.Ai"),
            Path("/mnt/v/!CENTRAL.CMD/_TRON/3OX.Ai"),
            Path("/root/!ZENS3N.CMD/!ZENS3N.VPS/_TRON/3OX.AI"),
            Path("/root/!ZENS3N.CMD/_TRON/3OX.AI"),
        ]
    )

    for candidate in candidates:
        if candidate.exists():
            return candidate

    return Path.cwd()


def find_central_root():
    candidates = [
        Path("/mnt/r/!LAUNCH.PAD/!CMD.RELAY/QUITFUCKING UPMYPROJECT/CENTRAL"),
        Path("/mnt/r/!CMD.RELAY/QUITFUCKING UPMYPROJECT/CENTRAL"),
        Path("/root/!CENTRAL.CMD/!CMD.RELAY/QUITFUCKING UPMYPROJECT/CENTRAL"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def find_lifecycle_root():
    candidates = [
        Path("/mnt/r/!LAUNCH.PAD/!CMD.RELAY/QUITFUCKING UPMYPROJECT"),
        Path("/mnt/r/!CMD.RELAY/QUITFUCKING UPMYPROJECT"),
        Path("/root/!CENTRAL.CMD/!CMD.RELAY/QUITFUCKING UPMYPROJECT"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def find_vec3_bin(runtime_root):
    candidates = [
        runtime_root.parent / "systemd" / "vec3" / "release" / "bin" / "vec3",
        Path("/root/!CENTRAL.CMD/_TRON/systemd/vec3/release/bin/vec3"),
        Path("/mnt/v/!CENTRAL.CMD/_TRON/systemd/vec3/release/bin/vec3"),
    ]
    for c in candidates:
        if c.exists() and os.access(str(c), os.X_OK):
            return c
    return None


def parse_operation_levels(path):
    levels = {}
    if not path.exists():
        return levels

    current = None
    with path.open("r", encoding="utf-8", errors="replace") as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("[") and line.endswith("]"):
                current = line[1:-1].strip().lower()
                levels[current] = {}
                continue
            if current and "=" in line:
                key, value = [part.strip() for part in line.split("=", 1)]
                value = value.strip().strip('"').strip("'")
                if value.isdigit():
                    value = int(value)
                levels[current][key] = value
    return levels


def parse_service_statuses(path):
    status = {}
    if not path.exists():
        return status

    with path.open("r", encoding="utf-8", errors="replace") as f:
        for raw in f:
            line = raw.strip()
            if not line.startswith("| **"):
                continue
            parts = [p.strip() for p in line.split("|")]
            if len(parts) < 5:
                continue
            name = parts[1].replace("*", "").strip().lower()
            service_status = parts[3].strip()
            status[name] = service_status

    return status


def tail_lines(path, max_lines):
    if not path.exists():
        return []
    lines = deque(maxlen=max_lines)
    with path.open("r", encoding="utf-8", errors="replace") as f:
        for line in f:
            lines.append(line.rstrip("\n"))
    return list(lines)


def count_files_limited(path, max_depth=5, limit=100000):
    if not path.exists() or not path.is_dir():
        return 0

    base_depth = len(path.parts)
    total = 0
    for root, dirs, files in os.walk(path):
        depth = len(Path(root).parts) - base_depth
        if depth >= max_depth:
            dirs[:] = []
        total += len(files)
        if total >= limit:
            return limit
    return total


def count_dirs_limited(path, max_depth=4, numeric_only=False, limit=100000):
    if not path.exists() or not path.is_dir():
        return 0

    base_depth = len(path.parts)
    total = 0
    for root, dirs, _ in os.walk(path):
        depth = len(Path(root).parts) - base_depth
        if depth >= max_depth:
            dirs[:] = []
        for d in dirs:
            if numeric_only and not d.isdigit():
                continue
            total += 1
            if total >= limit:
                return limit
    return total


def latest_markers(log_lines):
    heartbeat = "none"
    merkle_count = "unknown"
    latest_event = "none"

    for line in reversed(log_lines):
        if latest_event == "none" and "merkle" not in line:
            latest_event = line
        if heartbeat == "none" and "pulse heartbeat" in line:
            heartbeat = line.split(" ", 1)[0]
        if merkle_count == "unknown" and "merkle" in line:
            marker = "count="
            idx = line.rfind(marker)
            if idx >= 0:
                merkle_count = line[idx + len(marker) :].split(" ", 1)[0]
            else:
                merkle_count = "present"
        if heartbeat != "none" and merkle_count != "unknown" and latest_event != "none":
            break

    return heartbeat, merkle_count, latest_event


def extract_lifecycle_markers(log_lines):
    markers = ["TRACK", "PLAN", "DRYRUN", "EXECUTE", "EDIT", "SEAL"]
    counts = {m: 0 for m in markers}
    for line in log_lines[-500:]:
        up = line.upper()
        for marker in markers:
            if marker in up:
                counts[marker] += 1
    return counts


def read_current_pointer(path):
    if not path.exists() or not path.is_file():
        return "missing"
    try:
        with path.open("r", encoding="utf-8", errors="replace") as f:
            line = f.readline().strip()
        return line or "empty"
    except Exception:
        return "unreadable"


def probe_unit_state(unit):
    if not command_exists("systemctl"):
        return "unavailable"

    attempts = [
        (["systemctl", "is-active", unit], "sys"),
        (["systemctl", "--user", "is-active", unit], "usr"),
    ]

    last = "unavailable"
    for cmd, scope in attempts:
        try:
            res = subprocess.run(cmd, capture_output=True, text=True, timeout=1.5)
            out = (res.stdout or res.stderr).strip().splitlines()
            token = out[0].strip() if out else ""
            if token:
                last = token
            if token and token not in ("unknown", "not-found"):
                return f"{token} ({scope})"
        except Exception:
            continue
    return last


def append_chat_line(chat_file, text):
    if not text.strip():
        return
    chat_file.parent.mkdir(parents=True, exist_ok=True)
    stamp = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    with chat_file.open("a", encoding="utf-8") as f:
        f.write(f"{stamp} {text.strip()}\n")


class ControlPlane:
    """Executes operator actions and streams output into the run log pane."""

    def __init__(self, runtime_root):
        self.runtime_root = Path(runtime_root)
        self.pulse_script = self.runtime_root / "Pulse" / "pulse.rb"
        self.vec3_bin = find_vec3_bin(self.runtime_root)

        self._lock = threading.Lock()
        self._lines = deque(maxlen=500)
        self._threads = {}

        self._append("control plane ready")
        if self.vec3_bin:
            self._append(f"vec3 bin detected: {self.vec3_bin}")
        else:
            self._append("vec3 bin not detected; fallback control path active")

    def _append(self, message):
        stamp = datetime.utcnow().strftime("%H:%M:%S")
        with self._lock:
            self._lines.append(f"{stamp} {message}")

    def get_lines(self, n=120):
        with self._lock:
            return list(self._lines)[-n:]

    def _build_action_command(self, action):
        if action == "health":
            if self.pulse_script.exists() and command_exists("ruby"):
                return ["ruby", str(self.pulse_script), "health"]
            if command_exists("systemctl"):
                return ["systemctl", "status", "3ox-supervisor.service", "--no-pager"]
            return None

        if action == "status":
            if command_exists("systemctl"):
                return [
                    "systemctl",
                    "status",
                    "3ox-supervisor.service",
                    "3ox-pulse.service",
                    "3ox-tape.service",
                    "3ox-warden.service",
                    "--no-pager",
                ]
            return None

        if self.vec3_bin:
            cmd_map = {
                "start": [str(self.vec3_bin), "start"],
                "stop": [str(self.vec3_bin), "stop"],
                "restart": [str(self.vec3_bin), "restart"],
            }
            return cmd_map.get(action)

        if command_exists("systemctl"):
            cmd_map = {
                "start": ["systemctl", "start", "3ox-supervisor.service"],
                "stop": ["systemctl", "stop", "3ox-supervisor.service"],
                "restart": ["systemctl", "restart", "3ox-supervisor.service"],
            }
            return cmd_map.get(action)

        return None

    def run_action(self, action):
        cmd = self._build_action_command(action)
        if not cmd:
            self._append(f"[{action}] no command path available")
            return

        with self._lock:
            t = self._threads.get(action)
            if t and t.is_alive():
                self._append(f"[{action}] already running")
                return

        th = threading.Thread(target=self._exec, args=(action, cmd), daemon=True)
        with self._lock:
            self._threads[action] = th
        th.start()

    def _exec(self, action, cmd):
        self._append(f"[{action}] $ {' '.join(cmd)}")
        try:
            proc = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )

            assert proc.stdout is not None
            for raw in proc.stdout:
                line = raw.rstrip("\n")
                if line:
                    self._append(f"[{action}] {line}")

            code = proc.wait(timeout=1)
            self._append(f"[{action}] exit={code}")
        except FileNotFoundError:
            self._append(f"[{action}] command not found")
        except subprocess.TimeoutExpired:
            self._append(f"[{action}] timeout")
        except Exception as exc:
            self._append(f"[{action}] error: {exc}")


class Cache:
    def __init__(self):
        self._log_mtime = None
        self._chat_mtime = None
        self._status_mtime = None
        self._ops_mtime = None
        self._slow_refresh_at = 0.0

        self.log_lines = []
        self.chat_lines = []
        self.service_status = {}
        self.ops_levels = {}

        self.event_count = 0
        self.arc_count = 0
        self.receipt_count = 0
        self.drafts_active_count = 0
        self.drafts_rev_count = 0
        self.capsules_count = 0
        self.archive_count = 0
        self.quarantine_count = 0
        self.current_pointer = "missing"
        self.unit_states = {u: "unknown" for u in SERVICE_UNITS}

    def read_tail_cached(self, path, max_lines, kind):
        mtime = None
        if path.exists():
            mtime = path.stat().st_mtime

        if kind == "log":
            if mtime != self._log_mtime:
                self._log_mtime = mtime
                self.log_lines = tail_lines(path, max_lines)
            return self.log_lines[-max_lines:]

        if kind == "chat":
            if mtime != self._chat_mtime:
                self._chat_mtime = mtime
                self.chat_lines = tail_lines(path, max_lines)
            return self.chat_lines[-max_lines:]

        return []

    def read_status_cached(self, path):
        mtime = None
        if path.exists():
            mtime = path.stat().st_mtime
        if mtime != self._status_mtime:
            self._status_mtime = mtime
            self.service_status = parse_service_statuses(path)
        return self.service_status

    def read_ops_cached(self, path):
        mtime = None
        if path.exists():
            mtime = path.stat().st_mtime
        if mtime != self._ops_mtime:
            self._ops_mtime = mtime
            self.ops_levels = parse_operation_levels(path)
        return self.ops_levels

    def refresh_slow_counts(self, runtime_root, lifecycle_root, ttl_seconds=6):
        now = time.time()
        if now < self._slow_refresh_at:
            return

        self.arc_count = count_files_limited(runtime_root / "Arc", max_depth=2)
        self.event_count = count_files_limited(runtime_root / "Pulse" / "meta" / "events", max_depth=8)

        receipt_candidates = [
            lifecycle_root / "_meta" / "receipts" if lifecycle_root else None,
            lifecycle_root / ".3ox" / "_meta" / "receipts" if lifecycle_root else None,
            runtime_root / ".meta" / "receipts",
        ]
        self.receipt_count = 0
        for candidate in receipt_candidates:
            if candidate and candidate.exists():
                self.receipt_count = count_files_limited(candidate, max_depth=8)
                break

        if lifecycle_root:
            self.drafts_active_count = count_files_limited(lifecycle_root / "drafts" / "active", max_depth=10)
            self.drafts_rev_count = count_files_limited(lifecycle_root / "drafts" / "rev", max_depth=10)
            self.capsules_count = count_dirs_limited(lifecycle_root / "capsules", max_depth=6, numeric_only=True)
            self.archive_count = count_files_limited(lifecycle_root / "archive", max_depth=6)
            self.quarantine_count = count_files_limited(lifecycle_root / "quarantine", max_depth=6)
            self.current_pointer = read_current_pointer(lifecycle_root / "CURRENT")
        else:
            self.drafts_active_count = 0
            self.drafts_rev_count = 0
            self.capsules_count = 0
            self.archive_count = 0
            self.quarantine_count = 0
            self.current_pointer = "missing"

        self.unit_states = {u: probe_unit_state(u) for u in SERVICE_UNITS}
        self._slow_refresh_at = now + ttl_seconds


def load_state(cache, control, runtime_root, lifecycle_root, central_root, chat_file):
    ops_file = runtime_root / ".meta" / "operation_levels.toml"
    status_file = runtime_root / "SERVICES.STATUS.md"
    log_file = runtime_root / "3ox.log"

    ops_levels = cache.read_ops_cached(ops_file)
    service_status = cache.read_status_cached(status_file)
    log_lines = cache.read_tail_cached(log_file, max_lines=350, kind="log")
    chat_lines = cache.read_tail_cached(chat_file, max_lines=120, kind="chat")

    cache.refresh_slow_counts(runtime_root, lifecycle_root)

    triad = {}
    for key in TRIAD_KEYS:
        priority = ops_levels.get(key, {}).get("priority", 0)
        triad[key] = int(priority) if isinstance(priority, int) else 0

    x = triad.get("tape", 0) / 10.0
    y = triad.get("pulse", 0) / 10.0
    z = triad.get("warden", 0) / 10.0
    magnitude = math.sqrt((x * x + y * y + z * z) / 3.0)

    heartbeat_ts, merkle_count, latest_event = latest_markers(log_lines)
    heartbeat_dt = parse_iso_utc(heartbeat_ts)
    heartbeat_age = seconds_since(heartbeat_dt)

    log_size = 0
    log_age = None
    if log_file.exists():
        st = log_file.stat()
        log_size = st.st_size
        log_age = max(0, int(time.time() - st.st_mtime))

    lifecycle_markers = extract_lifecycle_markers(log_lines)

    return {
        "ops_levels": ops_levels,
        "service_status": service_status,
        "log_lines": log_lines,
        "chat_lines": chat_lines,
        "control_lines": control.get_lines(150),
        "triad": triad,
        "vector": (x, y, z),
        "magnitude": magnitude,
        "heartbeat": heartbeat_ts,
        "heartbeat_age": heartbeat_age,
        "merkle_count": merkle_count,
        "latest_event": latest_event,
        "runtime_root": str(runtime_root),
        "lifecycle_root": str(lifecycle_root) if lifecycle_root else "missing",
        "central_root": str(central_root) if central_root else "missing",
        "log_file": str(log_file),
        "chat_file": str(chat_file),
        "log_size": log_size,
        "log_age": log_age,
        "event_count": cache.event_count,
        "arc_count": cache.arc_count,
        "receipt_count": cache.receipt_count,
        "drafts_active_count": cache.drafts_active_count,
        "drafts_rev_count": cache.drafts_rev_count,
        "capsules_count": cache.capsules_count,
        "archive_count": cache.archive_count,
        "quarantine_count": cache.quarantine_count,
        "current_pointer": cache.current_pointer,
        "lifecycle_markers": lifecycle_markers,
        "unit_states": cache.unit_states,
    }


def init_theme():
    if not curses.has_colors():
        return
    curses.start_color()
    curses.use_default_colors()

    orange = curses.COLOR_YELLOW
    try:
        if curses.COLORS >= 256:
            orange = 208
    except Exception:
        pass

    curses.init_pair(CP_DEFAULT, -1, -1)
    curses.init_pair(CP_ORANGE, orange, -1)
    curses.init_pair(CP_BANNER, curses.COLOR_BLACK, orange)
    curses.init_pair(CP_DIM, curses.COLOR_CYAN, -1)
    curses.init_pair(CP_GOOD, curses.COLOR_GREEN, -1)
    curses.init_pair(CP_WARN, curses.COLOR_RED, -1)


def pane_title(win, title, accent=False):
    win.erase()
    attr = curses.A_BOLD
    if accent:
        attr |= curses.color_pair(CP_ORANGE)
    win.box()
    safe_add(win, 0, 2, f" ▛▞// {title} ", attr)


def service_attr(status):
    s = (status or "").lower()
    if "active" in s or "running" in s or "working" in s:
        return curses.A_BOLD | curses.color_pair(CP_GOOD)
    if "inactive" in s or "failed" in s or "pending" in s or "unknown" in s or "not-found" in s:
        return curses.A_BOLD | curses.color_pair(CP_WARN)
    return curses.A_NORMAL


def draw_left_nav(win, selected, flash_message):
    h, w = win.getmaxyx()
    pane_title(win, "NAV :: 3OX.AI", accent=True)

    safe_add(win, 1, 2, THICK_BAR[: max(0, w - 4)], curses.color_pair(CP_ORANGE))
    safe_add(win, 2, 2, GLYPH_LINE[: max(0, w - 4)], curses.A_BOLD | curses.color_pair(CP_ORANGE))

    y = 4
    for idx, label in enumerate(NAV_ITEMS):
        attr = curses.A_BOLD if idx == selected else curses.A_NORMAL
        if idx == selected:
            attr |= curses.A_REVERSE | curses.color_pair(CP_ORANGE)
        safe_add(win, y + idx, 2, f"{idx + 1}. {label}", attr)

    cmd_y = y + len(NAV_ITEMS) + 1
    safe_add(win, cmd_y, 2, "Operator Controls", curses.A_BOLD | curses.color_pair(CP_ORANGE))
    commands = [
        "a start", "z stop", "e restart", "h health", "u status",
        "r refresh", "m note", "x marker", "q quit",
    ]
    for i, line in enumerate(commands):
        safe_add(win, cmd_y + 1 + i, 2, f"- {line}", curses.A_DIM)

    footer_start = h - 8
    safe_add(win, footer_start, 2, "Runtime Contract", curses.A_BOLD | curses.color_pair(CP_ORANGE))
    contract = [
        "event-driven runtime",
        "polling non-authoritative",
        "receipts on authority",
        "drift -> quarantine",
    ]
    for i, line in enumerate(contract):
        safe_add(win, footer_start + 1 + i, 2, f"{line}")

    if flash_message:
        safe_add(win, h - 2, 2, flash_message[: max(0, w - 4)], curses.A_BOLD | curses.color_pair(CP_ORANGE))


def draw_main_overview(top, bottom, state):
    pane_title(top, "MAIN TOP :: OVERVIEW", accent=True)
    pane_title(bottom, "MAIN BOTTOM :: CONTRACTS", accent=True)

    lines = [
        f"Runtime root    : {state['runtime_root']}",
        f"Lifecycle root  : {state['lifecycle_root']}",
        f"Central docs    : {state['central_root']}",
        f"Log age/size    : {fmt_age(state['log_age'])} / {human_bytes(state['log_size'])}",
        f"Latest event    : {state['latest_event']}",
        f"Heartbeat age   : {fmt_age(state['heartbeat_age'])} (secondary)",
        f"Merkle count    : {state['merkle_count']}",
        f"Events/Receipts : {state['event_count']} / {state['receipt_count']}",
    ]
    for i, line in enumerate(lines):
        safe_add(top, i + 1, 2, line)

    contracts = [
        "Runtime coordination is event-driven.",
        "Polling cannot define system truth.",
        "Every authoritative action emits a receipt.",
        "Unknown runtime entities are quarantined.",
        "Lifecycle flow: TRACK -> PLAN -> DRYRUN -> EXECUTE -> EDIT -> SEAL.",
    ]
    for i, line in enumerate(contracts):
        safe_add(bottom, i + 1, 2, line, curses.A_BOLD if i < 2 else curses.A_NORMAL)


def draw_main_triad(top, bottom, state):
    pane_title(top, "MAIN TOP :: TRIAD", accent=True)
    pane_title(bottom, "MAIN BOTTOM :: SERVICE STATES", accent=True)

    row = 1
    for key in TRIAD_KEYS:
        st = state["service_status"].get(key, "unknown")
        p = state["triad"].get(key, 0)
        safe_add(top, row, 2, f"{key.upper():<8} {st:<12} p={p} {priority_label(p)}", service_attr(st))
        safe_add(top, row + 1, 4, priority_bar(p))
        row += 2

    safe_add(top, row + 1, 2, "Vector", curses.A_BOLD)
    x, y, z = state["vector"]
    safe_add(top, row + 2, 2, f"({x:.2f}, {y:.2f}, {z:.2f}) magnitude={state['magnitude']:.2f}")

    row = 1
    for unit, st in state["unit_states"].items():
        safe_add(bottom, row, 2, f"{unit:<26} {st}", service_attr(st))
        row += 1


def draw_main_lifecycle(top, bottom, state):
    pane_title(top, "MAIN TOP :: LIFECYCLE STATE", accent=True)
    pane_title(bottom, "MAIN BOTTOM :: STAGE SIGNALS", accent=True)

    rows = [
        f"drafts/active : {state['drafts_active_count']}",
        f"drafts/rev    : {state['drafts_rev_count']}",
        f"capsules      : {state['capsules_count']}",
        f"archive files : {state['archive_count']}",
        f"quarantine    : {state['quarantine_count']}",
        f"CURRENT       : {state['current_pointer']}",
    ]
    for i, line in enumerate(rows):
        safe_add(top, i + 1, 2, line)

    markers = state["lifecycle_markers"]
    row = 1
    for key in ["TRACK", "PLAN", "DRYRUN", "EXECUTE", "EDIT", "SEAL"]:
        safe_add(bottom, row, 2, f"{key:<7} in log tail: {markers.get(key, 0)}")
        row += 1

    safe_add(bottom, row + 1, 2, "Terminal states: capsuled/checkpointed/archived/quarantined/deleted", curses.A_BOLD)


def draw_main_live(top, bottom, state):
    pane_title(top, "MAIN TOP :: LIVE EVENTS", accent=True)
    pane_title(bottom, "MAIN BOTTOM :: HEALTH CHECK", accent=True)

    recent = [ln for ln in state["log_lines"] if "merkle" not in ln][-10:]
    if recent:
        for i, line in enumerate(recent):
            safe_add(top, i + 1, 2, line)
    else:
        safe_add(top, 1, 2, "No recent non-merkle events in current log tail.")

    checks = [
        f"log freshness      : {fmt_age(state['log_age'])}",
        f"heartbeat age      : {fmt_age(state['heartbeat_age'])}",
        f"event files        : {state['event_count']}",
        f"receipt files      : {state['receipt_count']}",
        f"CURRENT pointer    : {state['current_pointer']}",
        f"quarantine count   : {state['quarantine_count']}",
    ]
    for i, line in enumerate(checks):
        safe_add(bottom, i + 1, 2, line)


def draw_main_split(main_win, selected, state):
    pane_title(main_win, f"MAIN :: {NAV_ITEMS[selected].upper()}", accent=True)
    h, w = main_win.getmaxyx()
    inner_h = h - 2

    top_h = inner_h // 2
    bot_h = inner_h - top_h

    top = main_win.derwin(top_h, w - 2, 1, 1)
    bottom = main_win.derwin(bot_h, w - 2, 1 + top_h, 1)

    if selected == 0:
        draw_main_overview(top, bottom, state)
    elif selected == 1:
        draw_main_triad(top, bottom, state)
    elif selected == 2:
        draw_main_lifecycle(top, bottom, state)
    else:
        draw_main_live(top, bottom, state)


def detail_lines(selected, state):
    if selected == 0:
        return [
            "Overview Detail",
            f"Docs: {state['central_root']}",
            "Mode: event-driven runtime",
            "Polling: non-authoritative",
            f"events={state['event_count']} receipts={state['receipt_count']}",
            f"heartbeat={fmt_age(state['heartbeat_age'])}",
            f"log={fmt_age(state['log_age'])} / {human_bytes(state['log_size'])}",
        ]

    if selected == 1:
        rows = ["Triad Detail"]
        for key in TRIAD_KEYS:
            rows.append(f"{key.upper():<8} status={state['service_status'].get(key, 'unknown')} p={state['triad'].get(key, 0)}")
        rows.append("")
        rows.append("Units")
        for unit, st in state["unit_states"].items():
            rows.append(f"{unit:<24} {st}")
        return rows

    if selected == 2:
        rows = [
            "Lifecycle Detail",
            f"active={state['drafts_active_count']} rev={state['drafts_rev_count']}",
            f"capsules={state['capsules_count']} archive={state['archive_count']}",
            f"quarantine={state['quarantine_count']} CURRENT={state['current_pointer']}",
            "markers:",
        ]
        for k, v in state["lifecycle_markers"].items():
            rows.append(f"{k:<7} {v}")
        return rows

    return [
        "Live Detail",
        f"latest={state['latest_event']}",
        f"merkle={state['merkle_count']}",
        f"events={state['event_count']} receipts={state['receipt_count']}",
        f"heartbeat={fmt_age(state['heartbeat_age'])}",
        f"log age={fmt_age(state['log_age'])}",
    ]


def draw_right_top_detail(win, selected, state):
    pane_title(win, "RIGHT TOP :: DETAIL", accent=True)
    lines = detail_lines(selected, state)
    max_lines = max(1, win.getmaxyx()[0] - 2)
    for i, line in enumerate(lines[:max_lines]):
        attr = curses.A_BOLD | curses.color_pair(CP_ORANGE) if i == 0 else curses.A_NORMAL
        safe_add(win, i + 1, 2, line, attr)


def draw_right_bottom_log(win, state, frame):
    pane_title(win, f"RIGHT BOTTOM :: RUN LOG [{frame}]", accent=True)
    h, _ = win.getmaxyx()
    slots = max(1, h - 3)

    feed = []
    for line in state["log_lines"][-(slots * 2):]:
        feed.append(("LOG", line))
    for line in state["control_lines"][-(slots * 2):]:
        feed.append(("CTL", line))
    for line in state["chat_lines"][-40:]:
        feed.append(("NOTE", line))

    window_feed = feed[-slots:]
    for i, (tag, line) in enumerate(window_feed):
        if tag == "LOG":
            attr = curses.A_DIM
        elif tag == "CTL":
            attr = curses.A_BOLD | curses.color_pair(CP_ORANGE)
        else:
            attr = curses.A_NORMAL
        safe_add(win, i + 1, 1, f" {tag:<4} {line}", attr)


def draw_right_split(right_win, selected, state, frame):
    pane_title(right_win, f"RIGHT :: {NAV_ITEMS[selected].upper()}", accent=True)
    h, w = right_win.getmaxyx()
    inner_h = h - 2

    top_h = inner_h // 2
    bot_h = inner_h - top_h

    top = right_win.derwin(top_h, w - 2, 1, 1)
    bottom = right_win.derwin(bot_h, w - 2, 1 + top_h, 1)

    draw_right_top_detail(top, selected, state)
    draw_right_bottom_log(bottom, state, frame)


def draw_banner(stdscr, width, frame):
    now = datetime.now().strftime("%H:%M:%S")
    text = f" 3OX.AI RUNTIME MONITOR [{frame}] {now} "
    bar_len = max(0, width - len(text) - 2)
    bar = "█" * bar_len
    safe_add(stdscr, 0, 0, "".ljust(width), curses.color_pair(CP_BANNER))
    safe_add(stdscr, 0, 1, text + bar, curses.A_BOLD | curses.color_pair(CP_BANNER))


def prompt_message(stdscr, prompt_text):
    h, w = stdscr.getmaxyx()
    stdscr.nodelay(False)
    curses.echo()
    curses.curs_set(1)

    safe_add(stdscr, h - 1, 0, " " * (w - 1), curses.color_pair(CP_BANNER))
    safe_add(stdscr, h - 1, 0, prompt_text, curses.A_BOLD | curses.color_pair(CP_BANNER))
    stdscr.refresh()

    max_len = max(1, w - len(prompt_text) - 1)
    raw = stdscr.getstr(h - 1, len(prompt_text), max_len)
    text = raw.decode("utf-8", errors="replace").strip()

    curses.noecho()
    curses.curs_set(0)
    stdscr.nodelay(True)
    return text


def draw_layout(stdscr, selected, state, flash_message, frame):
    stdscr.erase()
    h, w = stdscr.getmaxyx()

    if h < 26 or w < 130:
        safe_add(stdscr, 1, 2, "Terminal too small for split layout.", curses.A_BOLD)
        safe_add(stdscr, 2, 2, f"Current: {w}x{h}, need at least 130x26")
        safe_add(stdscr, 4, 2, "Resize and press r, or q to quit.")
        stdscr.refresh()
        return

    draw_banner(stdscr, w, frame)

    left_w = 30
    remaining_w = w - left_w
    main_w = remaining_w // 2
    right_w = remaining_w - main_w

    pane_h = h - 1
    left = stdscr.derwin(pane_h, left_w, 1, 0)
    main = stdscr.derwin(pane_h, main_w, 1, left_w)
    right = stdscr.derwin(pane_h, right_w, 1, left_w + main_w)

    draw_left_nav(left, selected, flash_message)
    draw_main_split(main, selected, state)
    draw_right_split(right, selected, state, frame)

    stdscr.refresh()


def run_dashboard(stdscr, runtime_root, lifecycle_root, central_root, chat_file):
    curses.curs_set(0)
    stdscr.nodelay(True)
    init_theme()

    control = ControlPlane(runtime_root)

    selected = 0
    flash_message = ""
    flash_until = 0.0

    cache = Cache()
    last_refresh = 0.0
    state = load_state(cache, control, runtime_root, lifecycle_root, central_root, chat_file)

    while True:
        now = time.time()
        frame = MOTION_FRAMES[int(now * 8) % len(MOTION_FRAMES)]

        if now - last_refresh >= 1.0:
            state = load_state(cache, control, runtime_root, lifecycle_root, central_root, chat_file)
            last_refresh = now

        if flash_until and now > flash_until:
            flash_message = ""
            flash_until = 0.0

        draw_layout(stdscr, selected, state, flash_message, frame)

        key = stdscr.getch()
        if key == -1:
            time.sleep(0.05)
            continue

        if key in (ord("q"), ord("Q")):
            break
        if key in (curses.KEY_UP, ord("k")):
            selected = (selected - 1) % len(NAV_ITEMS)
        elif key in (curses.KEY_DOWN, ord("j")):
            selected = (selected + 1) % len(NAV_ITEMS)
        elif key in (ord("1"), ord("2"), ord("3"), ord("4")):
            selected = int(chr(key)) - 1
        elif key in (ord("r"), ord("R")):
            state = load_state(cache, control, runtime_root, lifecycle_root, central_root, chat_file)
            flash_message = "Refreshed"
            flash_until = time.time() + 1.5
        elif key in (ord("a"), ord("A")):
            control.run_action("start")
            flash_message = "Start dispatched"
            flash_until = time.time() + 1.8
        elif key in (ord("z"), ord("Z")):
            control.run_action("stop")
            flash_message = "Stop dispatched"
            flash_until = time.time() + 1.8
        elif key in (ord("e"), ord("E")):
            control.run_action("restart")
            flash_message = "Restart dispatched"
            flash_until = time.time() + 1.8
        elif key in (ord("h"), ord("H")):
            control.run_action("health")
            flash_message = "Health check dispatched"
            flash_until = time.time() + 1.8
        elif key in (ord("u"), ord("U")):
            control.run_action("status")
            flash_message = "Status command dispatched"
            flash_until = time.time() + 1.8
        elif key in (ord("m"), ord("M")):
            msg = prompt_message(stdscr, "Note> ")
            if msg:
                append_chat_line(chat_file, msg)
                state = load_state(cache, control, runtime_root, lifecycle_root, central_root, chat_file)
                flash_message = "Note appended"
            else:
                flash_message = "No message entered"
            flash_until = time.time() + 2.0
        elif key in (ord("x"), ord("X")):
            append_chat_line(chat_file, "[exec] checkpoint")
            state = load_state(cache, control, runtime_root, lifecycle_root, central_root, chat_file)
            flash_message = "Execution marker appended"
            flash_until = time.time() + 2.0


def run_check(runtime_root, lifecycle_root, central_root, chat_file):
    control = ControlPlane(runtime_root)
    cache = Cache()
    state = load_state(cache, control, runtime_root, lifecycle_root, central_root, chat_file)
    print("runtime_root=", state["runtime_root"])
    print("lifecycle_root=", state["lifecycle_root"])
    print("central_root=", state["central_root"])
    print("log_file=", state["log_file"])
    print("chat_file=", state["chat_file"])
    print("heartbeat=", state["heartbeat"])
    print("heartbeat_age=", fmt_age(state["heartbeat_age"]))
    print("merkle_count=", state["merkle_count"])
    print("event_count=", state["event_count"])
    print("receipt_count=", state["receipt_count"])
    print("drafts_active=", state["drafts_active_count"])
    print("capsules=", state["capsules_count"])
    print("CURRENT=", state["current_pointer"])
    print("triad=", state["triad"])
    print("unit_states=", state["unit_states"])


def main():
    parser = argparse.ArgumentParser(description="3OX.AI TUI monitor")
    parser.add_argument("--check", action="store_true", help="Print snapshot and exit")
    parser.add_argument(
        "--chat-file",
        default=None,
        help="Optional custom chat file path (default: <this dir>/agent_chat.log)",
    )
    args = parser.parse_args()

    runtime_root = find_runtime_root()
    lifecycle_root = find_lifecycle_root()
    central_root = find_central_root()
    default_chat = Path(__file__).resolve().parent / "agent_chat.log"
    chat_file = Path(args.chat_file) if args.chat_file else default_chat

    if args.check:
        run_check(runtime_root, lifecycle_root, central_root, chat_file)
        return

    curses.wrapper(run_dashboard, runtime_root, lifecycle_root, central_root, chat_file)


if __name__ == "__main__":
    main()
