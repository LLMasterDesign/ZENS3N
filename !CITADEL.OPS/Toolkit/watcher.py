#!/usr/bin/env python3
"""
File Watcher - Auto-detects files in 0ut.3ox and triggers routing
Monitors FILE.MANIFEST.txt for READY entries
"""

import sys
import os
# Fix UTF-8 output on Windows
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.detach(), encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.detach(), encoding='utf-8', errors='replace')

import time
import subprocess
from pathlib import Path
from datetime import datetime

# Base paths
CMD_BRIDGE = Path("R:/!CMD.BRIDGE")
BASE_OPS = CMD_BRIDGE / "!BASE.OPERATIONS"
STATIONS_DIR = BASE_OPS / "ROUTING.CONFIGS"

# State tracking
last_check_state = {}


def load_stations():
    """Load all enabled station routing configurations"""
    stations = []
    
    if not STATIONS_DIR.exists():
        print(f"⚠️  Stations directory not found: {STATIONS_DIR}")
        return stations
    
    for routing_file in STATIONS_DIR.glob("*.routing"):
        config = parse_routing_file(routing_file)
        if config and config.get("enabled") == "true":
            stations.append(config)
    
    return stations


def parse_routing_file(file_path):
    """Parse station routing configuration file"""
    config = {}
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    if ':' in line:
                        key, value = line.split(':', 1)
                        config[key.strip()] = value.strip()
        return config
    except Exception as e:
        print(f"❌ Error parsing {file_path}: {e}")
        return None


def get_manifest_state(station):
    """Get current state of manifest (count READY entries)"""
    manifest_path = Path(station['station_path']) / station['manifest_file']
    
    if not manifest_path.exists():
        return 0
    
    ready_count = 0
    try:
        with open(manifest_path, 'r', encoding='utf-8') as f:
            for line in f:
                if '| READY |' in line and not line.startswith('#'):
                    ready_count += 1
    except Exception:
        pass
    
    return ready_count


def check_for_changes(stations):
    """Check if any station has new READY files"""
    global last_check_state
    changes_detected = False
    
    for station in stations:
        station_name = station['station_name']
        current_count = get_manifest_state(station)
        
        # Initialize state if first check
        if station_name not in last_check_state:
            last_check_state[station_name] = current_count
            if current_count > 0:
                print(f"📋 {station_name}: {current_count} file(s) already READY")
            continue
        
        # Check for changes
        previous_count = last_check_state[station_name]
        if current_count > previous_count:
            print(f"🆕 {station_name}: {current_count - previous_count} new file(s) detected")
            changes_detected = True
        
        # Update state
        last_check_state[station_name] = current_count
    
    return changes_detected


def trigger_router():
    """Trigger router.py to process files"""
    router_path = BASE_OPS / "router.py"
    
    if not router_path.exists():
        print(f"❌ Router not found: {router_path}")
        return False
    
    try:
        print("🚀 Triggering router...")
        print("-" * 50)
        
        # Run router and capture output
        result = subprocess.run(
            ["python", str(router_path)],
            cwd=str(CMD_BRIDGE),
            capture_output=True,
            text=True
        )
        
        # Print router output
        if result.stdout:
            print(result.stdout)
        
        if result.returncode == 0:
            print("-" * 50)
            print("✅ Router completed successfully\n")
            return True
        else:
            print(f"❌ Router failed with code {result.returncode}")
            if result.stderr:
                print(f"Error: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error running router: {e}")
        return False


def watch_loop(interval=10):
    """Main watch loop"""
    print("👁️  File Watcher Started")
    print("=" * 50)
    print(f"Monitor interval: {interval} seconds")
    print(f"Watching: Station 0ut.3ox folders")
    print("Press Ctrl+C to stop\n")
    
    stations = load_stations()
    
    if not stations:
        print("❌ No enabled stations found")
        return
    
    print(f"📡 Monitoring {len(stations)} station(s):")
    for station in stations:
        print(f"   - {station['station_name']}")
    print()
    
    try:
        while True:
            timestamp = datetime.now().strftime('%H:%M:%S')
            
            # Check for changes
            if check_for_changes(stations):
                # Changes detected - trigger router
                trigger_router()
            else:
                # No changes - quiet heartbeat
                print(f"[{timestamp}] ✓ Watching...", end='\r')
            
            time.sleep(interval)
            
    except KeyboardInterrupt:
        print("\n\n✋ Watcher stopped by user")


def watch_once():
    """Single check (for testing)"""
    print("👁️  File Watcher - Single Check")
    print("=" * 50)
    
    stations = load_stations()
    
    if not stations:
        print("❌ No enabled stations found")
        return
    
    print(f"📡 Checking {len(stations)} station(s)...\n")
    
    if check_for_changes(stations):
        trigger_router()
    else:
        print("✓ No new files detected")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "--watch":
            # Continuous watch mode
            interval = int(sys.argv[2]) if len(sys.argv) > 2 else 10
            watch_loop(interval)
        elif sys.argv[1] == "--once":
            # Single check
            watch_once()
        else:
            print("Usage:")
            print("  python watcher.py --watch [interval]  # Watch continuously")
            print("  python watcher.py --once              # Check once")
    else:
        # Default: watch mode with 10 second interval
        watch_loop(10)

