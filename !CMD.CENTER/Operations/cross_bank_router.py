#!/usr/bin/env python3
"""
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // CROSS-BANK ▞▞
▞//▞ Cross-Bank Router :: ρ{multi-drive}.φ{routing}.τ{sync}.λ{core} ⫸
▙⌱🌉 ≔ [⊢{source-bank}⇨{bridge}⟿{route}▷{dest-bank}]
〔3OX.Ai.cross.bank.routing〕 :: ∎

Cross-Bank Router - Routes files between different drives/memory banks
Handles: P: drive, X: drive, RDP:, network paths
"""

import os
import shutil
import hashlib
from pathlib import Path
from datetime import datetime

# Base paths
CMD_BRIDGE = Path("P:/!CMD.BRIDGE")
BASE_OPS = CMD_BRIDGE / "!BASE.OPERATIONS"

# Known bank locations (add more as needed)
BANKS = {
    'P_DRIVE': {
        'path': 'P:/!CMD.BRIDGE',
        'type': 'local',
        'description': 'CMD.BRIDGE - Central coordination'
    },
    'X_DRIVE': {
        'path': 'X:/OBS Drive',
        'type': 'local',
        'description': 'OBSIDIAN local sync drive',
        'check_exists': True  # Verify before using
    },
    'RDP_REMOTE': {
        'path': None,  # Set dynamically based on RDP connection
        'type': 'remote',
        'description': 'RVNx remote access',
        'requires_connection': True
    }
}


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


def check_bank_available(bank_name):
    """Check if a bank/drive is available"""
    bank = BANKS.get(bank_name)
    if not bank:
        return False, "Unknown bank"
    
    if bank['type'] == 'local':
        if bank.get('check_exists'):
            path = Path(bank['path'])
            if path.exists():
                return True, "Available"
            else:
                return False, f"Drive not found: {bank['path']}"
        else:
            return True, "Assumed available"
    
    elif bank['type'] == 'remote':
        # Would need RDP connection check
        return False, "Remote connection check not implemented"
    
    return False, "Unknown bank type"


def list_available_banks():
    """List all available memory banks"""
    print("📊 Memory Bank Status")
    print("=" * 50)
    
    for bank_name, bank_info in BANKS.items():
        available, status = check_bank_available(bank_name)
        status_icon = "✅" if available else "❌"
        print(f"{status_icon} {bank_name}")
        print(f"   Path: {bank_info['path']}")
        print(f"   Type: {bank_info['type']}")
        print(f"   Status: {status}")
        print()


def generate_cross_bank_receipt(source_path, dest_path, source_bank, dest_bank):
    """Generate receipt for cross-bank transfer"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # Calculate file details
    file_hash = "PENDING"
    file_size = 0
    
    if Path(source_path).exists():
        file_hash = calculate_file_hash(source_path)
        file_size = Path(source_path).stat().st_size
    
    filename = Path(source_path).name
    
    receipt_content = f"""# Cross-Bank Transfer Receipt

FROM.BANK = {source_bank}
FROM.PATH = {source_path}

TO.BANK   = {dest_bank}
TO.PATH   = {dest_path}

DATE      = {timestamp}
STATUS    = DELIVERED

FILES:
- {filename}

FILE_HASH = {file_hash}
FILE_SIZE = {file_size}

NOTES:
Cross-bank transfer between memory banks.
Source: {source_bank} → Destination: {dest_bank}
Verify hash on arrival to ensure integrity across drive boundaries.

CHAIN     = null
RESPONDER = cmd.bridge

---
**Bank Transfer Protocol v1**
"""
    
    return receipt_content


def route_cross_bank(source_path, dest_path, source_bank='P_DRIVE', dest_bank='X_DRIVE', generate_receipt=True):
    """
    Route file from one bank to another
    
    source_path: Full path to source file
    dest_path: Full path to destination
    source_bank: Source bank name (from BANKS dict)
    dest_bank: Destination bank name
    generate_receipt: Whether to create transfer receipt
    """
    source = Path(source_path)
    dest = Path(dest_path)
    
    # Verify source exists
    if not source.exists():
        print(f"❌ Source file not found: {source}")
        return False
    
    # Check destination bank is available
    available, status = check_bank_available(dest_bank)
    if not available:
        print(f"❌ Destination bank unavailable: {status}")
        return False
    
    # Create destination directory if needed
    dest.parent.mkdir(parents=True, exist_ok=True)
    
    try:
        # Copy file
        shutil.copy2(source, dest)
        print(f"✓ Transferred: {source.name}")
        print(f"  From: {source_bank}")
        print(f"  To:   {dest_bank}")
        
        # Generate receipt if requested
        if generate_receipt:
            receipt_content = generate_cross_bank_receipt(
                str(source), str(dest), source_bank, dest_bank
            )
            receipt_path = Path(str(dest) + '.receipt.md')
            receipt_path.write_text(receipt_content, encoding='utf-8')
            print(f"  ↳ Receipt: {receipt_path.name}")
        
        return True
        
    except Exception as e:
        print(f"❌ Transfer failed: {e}")
        return False


def sync_to_obsidian_drive(source_file, relative_dest_path):
    """
    Convenience function: Copy file to X: drive OBSIDIAN sync
    
    source_file: File in P:/!CMD.BRIDGE
    relative_dest_path: Path relative to X:/OBS Drive
    """
    x_drive = BANKS['X_DRIVE']['path']
    dest_path = Path(x_drive) / relative_dest_path
    
    return route_cross_bank(
        source_file,
        str(dest_path),
        source_bank='P_DRIVE',
        dest_bank='X_DRIVE'
    )


def sync_from_obsidian_drive(source_relative_path, dest_file):
    """
    Convenience function: Copy file from X: drive to P: drive
    
    source_relative_path: Path relative to X:/OBS Drive
    dest_file: Destination in P:/!CMD.BRIDGE
    """
    x_drive = BANKS['X_DRIVE']['path']
    source_path = Path(x_drive) / source_relative_path
    
    return route_cross_bank(
        str(source_path),
        dest_file,
        source_bank='X_DRIVE',
        dest_bank='P_DRIVE'
    )


def batch_cross_bank_transfer(file_list, source_bank, dest_bank):
    """
    Transfer multiple files between banks
    
    file_list: List of (source_path, dest_path) tuples
    """
    print(f"📦 Batch Transfer: {source_bank} → {dest_bank}")
    print("=" * 50)
    
    successful = 0
    failed = 0
    
    for source_path, dest_path in file_list:
        if route_cross_bank(source_path, dest_path, source_bank, dest_bank):
            successful += 1
        else:
            failed += 1
    
    print("=" * 50)
    print(f"✅ Successful: {successful}")
    if failed > 0:
        print(f"❌ Failed: {failed}")
    
    return successful, failed


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "--list-banks":
            list_available_banks()
        
        elif command == "--test":
            print("🧪 Testing Cross-Bank Router\n")
            
            # Test 1: Check banks
            print("Test 1: Checking available banks")
            list_available_banks()
            
            # Test 2: Would need actual files to test transfer
            print("\nTest 2: Transfer test")
            print("(Requires source file to test)")
            print("\nUsage for real transfer:")
            print("  from cross_bank_router import route_cross_bank")
            print("  route_cross_bank('P:/source.md', 'X:/dest.md', 'P_DRIVE', 'X_DRIVE')")
        
        elif command == "--help":
            print("Cross-Bank Router - Routes files between memory banks")
            print("\nCommands:")
            print("  --list-banks     List available memory banks")
            print("  --test           Test the router")
            print("  --help           Show this help")
            print("\nPython API:")
            print("  route_cross_bank(source, dest, source_bank, dest_bank)")
            print("  sync_to_obsidian_drive(source, relative_dest)")
            print("  sync_from_obsidian_drive(relative_source, dest)")
    else:
        list_available_banks()

