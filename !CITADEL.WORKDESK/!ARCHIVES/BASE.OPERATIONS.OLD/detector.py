#!/usr/bin/env python3
"""
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // DETECTOR ▞▞
▞//▞ File Detector :: ρ{file-detection}.φ{monitoring}.τ{automation}.λ{ops} ⫸
▙⌱🔍 ≔ [⊢{incoming-files}⇨{detect}⟿{log}▷{tracking}]
〔BASE.OPS.detection.monitoring〕 :: ∎

BASE.OPERATIONS File Detector
Monitors INCOMING/ folder for new files from stations
Logs arrivals and provides detection reports
"""

import os
import time
from pathlib import Path
from datetime import datetime
import hashlib


# Base paths
BASE_OPS = Path(__file__).parent
INCOMING_DIR = BASE_OPS / "INCOMING"
REGISTRY_LOG = INCOMING_DIR / "REGISTRY.LOG"
STATE_FILE = INCOMING_DIR / ".detector_state.txt"


def calculate_hash(file_path, chunk_size=8192):
    """Calculate SHA256 hash of file"""
    sha256 = hashlib.sha256()
    try:
        with open(file_path, 'rb') as f:
            while chunk := f.read(chunk_size):
                sha256.update(chunk)
        return sha256.hexdigest()[:16]  # First 16 chars
    except Exception as e:
        return "ERROR"


def load_known_files():
    """Load previously detected files from state file"""
    known = set()
    if STATE_FILE.exists():
        try:
            with open(STATE_FILE, 'r', encoding='utf-8') as f:
                for line in f:
                    known.add(line.strip())
        except Exception:
            pass
    return known


def save_known_files(known_files):
    """Save detected files to state file"""
    try:
        with open(STATE_FILE, 'w', encoding='utf-8') as f:
            for file_path in sorted(known_files):
                f.write(f"{file_path}\n")
    except Exception as e:
        print(f"⚠️  Could not save state: {e}")


def scan_incoming():
    """Scan INCOMING folder for new files"""
    if not INCOMING_DIR.exists():
        print(f"⚠️  INCOMING directory not found: {INCOMING_DIR}")
        return []
    
    new_files = []
    known_files = load_known_files()
    
    for station_folder in INCOMING_DIR.iterdir():
        if station_folder.is_dir() and not station_folder.name.startswith('.'):
            for file_path in station_folder.rglob('*'):
                if file_path.is_file():
                    relative_path = str(file_path.relative_to(INCOMING_DIR))
                    
                    if relative_path not in known_files:
                        new_files.append(file_path)
                        known_files.add(relative_path)
    
    # Save updated state
    if new_files:
        save_known_files(known_files)
    
    return new_files


def log_detection(file_path):
    """Log detected file to registry"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    relative_path = file_path.relative_to(INCOMING_DIR)
    station = relative_path.parts[0] if len(relative_path.parts) > 0 else "unknown"
    filename = file_path.name
    size = file_path.stat().st_size
    file_hash = calculate_hash(file_path)
    
    log_entry = f"[{timestamp}] | {station} | {filename} | {size} | DETECTED | hash:{file_hash}\n"
    
    try:
        # Append to registry
        with open(REGISTRY_LOG, 'a', encoding='utf-8') as f:
            f.write(log_entry)
    except Exception as e:
        print(f"⚠️  Could not log to registry: {e}")


def generate_report(new_files):
    """Generate detection report"""
    if not new_files:
        return "No new files detected."
    
    report = f"🔍 BASE.OPS Detection Report\n"
    report += f"{'=' * 50}\n"
    report += f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
    report += f"New Files Detected: {len(new_files)}\n\n"
    
    # Group by station
    by_station = {}
    for file_path in new_files:
        relative_path = file_path.relative_to(INCOMING_DIR)
        station = relative_path.parts[0] if len(relative_path.parts) > 0 else "unknown"
        
        if station not in by_station:
            by_station[station] = []
        by_station[station].append(file_path)
    
    for station, files in sorted(by_station.items()):
        report += f"📡 {station.upper()}:\n"
        for file_path in files:
            size = file_path.stat().st_size
            report += f"   ✓ {file_path.name} ({size} bytes)\n"
        report += "\n"
    
    report += f"{'=' * 50}\n"
    report += f"📋 Registry: {REGISTRY_LOG}\n"
    
    return report


def detect_once():
    """Run detection once and report"""
    print("🔍 BASE.OPS File Detector")
    print("=" * 50)
    
    new_files = scan_incoming()
    
    if not new_files:
        print("✓ No new files detected")
        return
    
    print(f"🆕 Found {len(new_files)} new file(s):\n")
    
    for file_path in new_files:
        relative_path = file_path.relative_to(INCOMING_DIR)
        print(f"   ✓ {relative_path}")
        log_detection(file_path)
    
    print("\n" + "=" * 50)
    print(f"📋 Logged to: {REGISTRY_LOG}")


def watch_mode(interval=5):
    """Watch INCOMING folder continuously"""
    print("🔍 BASE.OPS File Detector - WATCH MODE")
    print("=" * 50)
    print(f"Monitoring: {INCOMING_DIR}")
    print(f"Interval: {interval}s")
    print("Press Ctrl+C to stop\n")
    
    try:
        while True:
            new_files = scan_incoming()
            
            if new_files:
                print(f"\n🆕 [{datetime.now().strftime('%H:%M:%S')}] Detected {len(new_files)} new file(s):")
                for file_path in new_files:
                    relative_path = file_path.relative_to(INCOMING_DIR)
                    print(f"   ✓ {relative_path}")
                    log_detection(file_path)
            
            time.sleep(interval)
    except KeyboardInterrupt:
        print("\n\n✋ Watch mode stopped")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "--watch":
        interval = int(sys.argv[2]) if len(sys.argv) > 2 else 5
        watch_mode(interval)
    else:
        detect_once()

