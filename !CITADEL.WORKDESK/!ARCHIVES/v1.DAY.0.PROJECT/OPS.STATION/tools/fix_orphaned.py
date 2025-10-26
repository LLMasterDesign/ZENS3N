#!/usr/bin/env python3
"""
Auto-fix orphaned files by adding them to FILE.MANIFEST.txt
"""

import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / '.3ox'))
from run import Manifest, Trace

# Read validation report
report_path = Path('0ut.3ox/VALIDATION_REPORT.json')
if not report_path.exists():
    print("❌ VALIDATION_REPORT.json not found. Run validation first.")
    sys.exit(1)

with open(report_path, 'r') as f:
    report = json.load(f)

# Find orphaned files
orphaned_files = [
    issue['file'] for issue in report['issues_by_severity']['WARNING']
    if issue['type'] == 'ORPHANED_FILE'
]

if not orphaned_files:
    print("✅ No orphaned files to fix")
    sys.exit(0)

print(f"\n📄 Adding {len(orphaned_files)} orphaned files to FILE.MANIFEST.txt...")
print("="*80)

Trace.log('FIX_ORPHANED_START', {'count': len(orphaned_files)})

for filename in orphaned_files:
    # Determine destination based on filename
    if 'REPORT' in filename.upper() or filename.endswith('.md'):
        destination = 'OPS.STATION'
        priority = 'HIGH'
    elif 'BATCH' in filename:
        destination = 'ARCHIVE'
        priority = 'LOW'
    else:
        destination = 'OPS.STATION'
        priority = 'MEDIUM'
    
    # Add to manifest
    Manifest.add(filename, destination, 'READY', priority)
    print(f"   ✅ Added: {filename} → {destination} ({priority})")

Trace.log('FIX_ORPHANED_COMPLETE', {'files_added': len(orphaned_files)})

print("\n" + "="*80)
print(f"✅ {len(orphaned_files)} files added to FILE.MANIFEST.txt")
print("\nRun validation again to verify fixes.")

