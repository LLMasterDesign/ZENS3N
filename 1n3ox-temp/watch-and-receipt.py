#!/usr/bin/env python3
"""
SIMPLE FILE WATCHER - Works TODAY
Drop a file anywhere → Get a receipt

No complexity. No frameworks. Just works.
"""

import sys
import os
from pathlib import Path
from datetime import datetime
import time
import hashlib

# Fix Windows UTF-8
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.detach(), encoding='utf-8', errors='replace')

def get_hash(filepath):
    """Quick file hash"""
    with open(filepath, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()[:16]

def create_receipt(filepath):
    """Create receipt for file"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    file_hash = get_hash(filepath)
    file_size = Path(filepath).stat().st_size
    
    receipt = f"""
RECEIPT
=======
File: {Path(filepath).name}
Time: {timestamp}
Hash: {file_hash}
Size: {file_size} bytes
Location: {filepath}

Status: LOGGED
"""
    
    # Save receipt next to file
    receipt_path = str(filepath) + ".RECEIPT.txt"
    with open(receipt_path, 'w', encoding='utf-8') as f:
        f.write(receipt)
    
    # Also log to central log
    log_entry = f"[{timestamp}] {Path(filepath).name} | {file_hash} | {file_size} bytes\n"
    with open("FILE_LOG.txt", 'a', encoding='utf-8') as f:
        f.write(log_entry)
    
    return receipt_path

def watch_folder(folder_path):
    """Watch folder for new files"""
    folder = Path(folder_path)
    if not folder.exists():
        print(f"ERROR: Folder not found: {folder_path}")
        return
    
    print(f"\nWatching: {folder}")
    print("Drop files here and receipts will be created automatically")
    print("Press Ctrl+C to stop\n")
    
    seen_files = set(folder.glob("*"))
    
    while True:
        try:
            current_files = set(folder.glob("*"))
            new_files = current_files - seen_files
            
            for new_file in new_files:
                if new_file.is_file() and not str(new_file).endswith('.RECEIPT.txt'):
                    print(f"  NEW: {new_file.name}")
                    receipt_path = create_receipt(new_file)
                    print(f"  RECEIPT: {Path(receipt_path).name}")
                    print()
            
            seen_files = current_files
            time.sleep(2)  # Check every 2 seconds
            
        except KeyboardInterrupt:
            print("\n\nWatcher stopped.")
            print(f"Log saved to: FILE_LOG.txt")
            break
        except Exception as e:
            print(f"ERROR: {e}")
            time.sleep(2)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("""
Usage:
  python watch-and-receipt.py <folder>

Example:
  python watch-and-receipt.py "C:/Users/You/Desktop"
  python watch-and-receipt.py .

This will watch the folder and create receipts for any new files.
""")
    else:
        watch_folder(sys.argv[1])

