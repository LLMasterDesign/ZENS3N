#!/usr/bin/env python3
"""
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // ROUTER ▞▞
▞//▞ Transit Router :: ρ{file-transit}.φ{routing}.τ{automation}.λ{core} ⫸
▙⌱🚀 ≔ [⊢{station-output}⇨{detect}⟿{route}▷{base-ops}]
〔3OX.Ai.core.routing.transit〕 :: ∎

3OX.Ai Transit Router
Routes files from station 0ut.3ox folders to !BASE.OPERATIONS/INCOMING/

No files stored in 3OX.Ai - pure transit orchestration.
"""

import os
import shutil
import hashlib
from pathlib import Path
from datetime import datetime
import yaml

# Base paths
CMD_BRIDGE = Path("P:/!CMD.BRIDGE")
BASE_OPS = CMD_BRIDGE / "!BASE.OPERATIONS"
STATIONS_DIR = BASE_OPS / "ROUTING.CONFIGS"
INCOMING_DIR = BASE_OPS / "INCOMING"
REGISTRY_LOG = INCOMING_DIR / "REGISTRY.LOG"


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


def read_manifest(station):
    """Read FILE.MANIFEST.txt from station output folder"""
    manifest_path = Path(station['station_path']) / station['manifest_file']
    
    if not manifest_path.exists():
        return []
    
    ready_files = []
    try:
        with open(manifest_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    parts = [p.strip() for p in line.split('|')]
                    if len(parts) >= 5:
                        timestamp, status, filepath, destination, priority = parts[:5]
                        if status == "READY":
                            ready_files.append({
                                'timestamp': timestamp,
                                'filepath': filepath,
                                'destination': destination,
                                'priority': priority
                            })
    except Exception as e:
        print(f"❌ Error reading manifest for {station['station_name']}: {e}")
    
    return ready_files


def update_manifest_status(station, filepath, new_status):
    """Update file status in manifest"""
    manifest_path = Path(station['station_path']) / station['manifest_file']
    
    if not manifest_path.exists():
        return
    
    lines = []
    try:
        with open(manifest_path, 'r', encoding='utf-8') as f:
            for line in f:
                if filepath in line and '| READY |' in line:
                    line = line.replace('| READY |', f'| {new_status} |')
                lines.append(line)
        
        with open(manifest_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)
    except Exception as e:
        print(f"❌ Error updating manifest: {e}")


def move_to_base_ops(file_info, station):
    """Move file from station to BASE.OPS INCOMING"""
    source_path = Path(station['station_path']) / station['output_folder'] / file_info['filepath']
    dest_folder = INCOMING_DIR / station['station_name'].replace('.BASE', '').lower()
    dest_path = dest_folder / file_info['filepath']
    
    # Ensure destination folder exists
    dest_folder.mkdir(parents=True, exist_ok=True)
    
    try:
        if source_path.exists():
            shutil.copy2(source_path, dest_path)
            print(f"✓ Routed: {file_info['filepath']} → {dest_folder.name}/")
            return True
        else:
            print(f"⚠️  Source file not found: {source_path}")
            return False
    except Exception as e:
        print(f"❌ Error moving file {file_info['filepath']}: {e}")
        return False


def archive_file(file_info, station):
    """Archive sent file to .SENT folder"""
    source_path = Path(station['station_path']) / station['output_folder'] / file_info['filepath']
    today = datetime.now().strftime('%Y-%m-%d')
    archive_folder = Path(station['station_path']) / station['output_folder'] / '.SENT' / today
    archive_path = archive_folder / file_info['filepath']
    
    archive_folder.mkdir(parents=True, exist_ok=True)
    
    try:
        if source_path.exists():
            shutil.move(str(source_path), str(archive_path))
            print(f"  ↳ Archived to .SENT/{today}/")
    except Exception as e:
        print(f"⚠️  Could not archive {file_info['filepath']}: {e}")


def calculate_file_hash(file_path):
    """Calculate SHA256 hash of file (first 16 chars)"""
    try:
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()[:16].upper()
    except Exception as e:
        print(f"⚠️  Could not calculate hash: {e}")
        return "HASH_ERROR"


def generate_receipt(file_info, station, dest_path):
    """Generate transfer receipt using SYNTH's template format"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    station_name = station['station_name']
    
    # Calculate file details
    file_hash = "PENDING"
    file_size = 0
    source_path = Path(station['station_path']) / station['output_folder'] / file_info['filepath']
    
    if source_path.exists():
        file_hash = calculate_file_hash(source_path)
        file_size = source_path.stat().st_size
    
    # Build receipt content using SYNTH's format
    receipt_content = f"""# Transfer Receipt

FROM.OUT = {station['station_path']}/{station['output_folder']}/
TO.IN    = {dest_path.parent}/
DATE     = {timestamp}
STATUS   = DELIVERED

ACTION   = archive
TARGET   = {file_info.get('destination', 'INCOMING/' + station_name.replace('.BASE', '').lower())}
PRIORITY = {file_info.get('priority', 'normal')}

FILES:
- {file_info['filepath']}

FILE_HASH = {file_hash}
FILE_SIZE = {file_size}

NOTES:
File routed automatically by transit router.
Generated at: {timestamp}
Origin: {station_name}

CHAIN     = null
RESPONDER = cmd.bridge
"""
    
    return receipt_content


def save_receipt(receipt_content, dest_path):
    """Save receipt next to destination file"""
    receipt_path = Path(str(dest_path) + '.receipt.md')
    
    try:
        with open(receipt_path, 'w', encoding='utf-8') as f:
            f.write(receipt_content)
        print(f"  ↳ Receipt: {receipt_path.name}")
        return True
    except Exception as e:
        print(f"⚠️  Could not save receipt: {e}")
        return False


def log_to_registry(file_info, station, status="RECEIVED"):
    """Log transit to central REGISTRY.LOG"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    station_name = station['station_name'].replace('.BASE', '').lower()
    
    # Get file size if possible
    dest_path = INCOMING_DIR / station_name / file_info['filepath']
    size = dest_path.stat().st_size if dest_path.exists() else 0
    
    log_entry = f"[{timestamp}] | {station_name} | {file_info['filepath']} | {size} | {status} | OK\n"
    
    try:
        # Create registry if it doesn't exist
        if not REGISTRY_LOG.exists():
            REGISTRY_LOG.parent.mkdir(parents=True, exist_ok=True)
            with open(REGISTRY_LOG, 'w', encoding='utf-8') as f:
                f.write("# REGISTRY.LOG\n")
                f.write("# Location: !BASE.OPERATIONS/INCOMING/\n")
                f.write("# Purpose: Central tracking of all station outputs\n")
                f.write(f"# Updated: ⧗-25.61\n\n")
                f.write("[TIMESTAMP] | STATION | FILENAME | SIZE | STATUS | NOTES\n\n")
        
        # Append entry
        with open(REGISTRY_LOG, 'a', encoding='utf-8') as f:
            f.write(log_entry)
    except Exception as e:
        print(f"⚠️  Could not log to registry: {e}")


def route_files():
    """Main routing function"""
    print("🚀 3OX.Ai Transit Router")
    print("=" * 50)
    
    stations = load_stations()
    
    if not stations:
        print("⚠️  No enabled stations found")
        return
    
    print(f"📡 Found {len(stations)} enabled station(s)\n")
    
    total_routed = 0
    
    for station in stations:
        print(f"🔍 Checking: {station['station_name']}")
        
        ready_files = read_manifest(station)
        
        if not ready_files:
            print(f"   No files ready for transit\n")
            continue
        
        print(f"   Found {len(ready_files)} file(s) ready for transit")
        
        for file_info in ready_files:
            # Update status to TRANSIT
            update_manifest_status(station, file_info['filepath'], 'TRANSIT')
            
            # Move to BASE.OPS
            if move_to_base_ops(file_info, station):
                # Generate destination path
                dest_folder = INCOMING_DIR / station['station_name'].replace('.BASE', '').lower()
                dest_path = dest_folder / file_info['filepath']
                
                # Generate and save receipt
                receipt_content = generate_receipt(file_info, station, dest_path)
                save_receipt(receipt_content, dest_path)
                
                # Log to registry
                log_to_registry(file_info, station, "RECEIVED")
                
                # Update status to SENT
                update_manifest_status(station, file_info['filepath'], 'SENT')
                
                # Archive original
                archive_file(file_info, station)
                
                total_routed += 1
            else:
                # Mark as ERROR
                update_manifest_status(station, file_info['filepath'], 'ERROR')
        
        print()
    
    print("=" * 50)
    print(f"✅ Transit complete: {total_routed} file(s) routed to BASE.OPS")
    print(f"📋 Registry: {REGISTRY_LOG}")


if __name__ == "__main__":
    route_files()

