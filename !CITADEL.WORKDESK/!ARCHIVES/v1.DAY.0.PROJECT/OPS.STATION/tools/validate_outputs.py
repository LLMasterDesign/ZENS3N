#!/usr/bin/env python3
"""
OUTPUT VALIDATION - Framework-Powered Quality Control
Comprehensive validation of all files in 0ut.3ox directory
Uses .3ox runtime for automated validation and integrity checking
"""

import sys
import os
import hashlib
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple
import json
import re

# Import framework runtime
sys.path.insert(0, str(Path(__file__).parent.parent / '.3ox'))
from run import Session, Trace, Receipt, Manifest

class OutputValidator:
    def __init__(self, session_id: str):
        self.session = Session(session_id, 'claude-sonnet-4')
        self.start_time = datetime.now()
        Trace.agent_start('OVERSEER', session_id)
        
        self.issues = {
            'CRITICAL': [],
            'WARNING': [],
            'INFO': []
        }
        
        self.validation_stats = {
            'total_files': 0,
            'validated': 0,
            'failed': 0,
            'orphaned': 0,
            'duplicates': 0
        }
    
    def calculate_checksum(self, file_path: Path) -> str:
        """Calculate SHA256 checksum for file"""
        try:
            with open(file_path, 'rb') as f:
                return hashlib.sha256(f.read()).hexdigest()
        except Exception as e:
            return f"ERROR: {str(e)}"
    
    def scan_all_files(self) -> List[Dict]:
        """Scan all files in 0ut.3ox directory"""
        output_dir = Path('0ut.3ox')
        if not output_dir.exists():
            self.issues['CRITICAL'].append({
                'type': 'MISSING_DIRECTORY',
                'message': '0ut.3ox directory does not exist',
                'severity': 'CRITICAL'
            })
            return []
        
        files = []
        for item in output_dir.rglob('*'):
            if item.is_file():
                file_info = {
                    'path': str(item.relative_to('0ut.3ox')),
                    'full_path': str(item),
                    'size': item.stat().st_size,
                    'modified': datetime.fromtimestamp(item.stat().st_mtime),
                    'checksum': self.calculate_checksum(item)
                }
                files.append(file_info)
        
        self.validation_stats['total_files'] = len(files)
        self.session.add('tool', f'Scanned {len(files)} files from 0ut.3ox/')
        Trace.tool_call('scan_all_files', f'{len(files)} files found')
        
        return files
    
    def validate_file_integrity(self, files: List[Dict]) -> List[Dict]:
        """Phase 1: Validate file integrity"""
        print("\n📋 PHASE 1: File Integrity Validation")
        print("-" * 80)
        
        validated = []
        for file in files:
            # Check for empty files
            if file['size'] == 0:
                self.issues['WARNING'].append({
                    'type': 'EMPTY_FILE',
                    'file': file['path'],
                    'message': f"File is empty (0 bytes)",
                    'severity': 'WARNING'
                })
                print(f"   ⚠️  EMPTY: {file['path']}")
            
            # Check for suspiciously small files
            elif file['size'] < 50 and not file['path'].endswith('.R'):
                self.issues['INFO'].append({
                    'type': 'SMALL_FILE',
                    'file': file['path'],
                    'size': file['size'],
                    'message': f"File unusually small ({file['size']} bytes)",
                    'severity': 'INFO'
                })
                print(f"   ℹ️  SMALL: {file['path']} ({file['size']} bytes)")
            
            # Check checksum calculation
            if file['checksum'].startswith('ERROR'):
                self.issues['CRITICAL'].append({
                    'type': 'CHECKSUM_FAILED',
                    'file': file['path'],
                    'error': file['checksum'],
                    'message': f"Failed to calculate checksum: {file['checksum']}",
                    'severity': 'CRITICAL'
                })
                print(f"   ❌ CHECKSUM ERROR: {file['path']}")
                self.validation_stats['failed'] += 1
            else:
                validated.append(file)
                self.validation_stats['validated'] += 1
        
        self.session.add('validation', f'Integrity check: {len(validated)} passed, {self.validation_stats["failed"]} failed')
        Trace.tool_call('validate_file_integrity', f'{len(validated)}/{len(files)} passed')
        
        return validated
    
    def cross_reference_manifest(self, files: List[Dict]) -> Tuple[List[str], List[str]]:
        """Phase 2: Cross-reference with FILE.MANIFEST.txt"""
        print("\n📋 PHASE 2: Manifest Cross-Reference")
        print("-" * 80)
        
        # Read manifest entries
        manifest_entries = Manifest.read()
        manifest_files = set()
        
        for entry in manifest_entries:
            # Parse manifest line: [timestamp] | status | filename | destination | priority
            parts = [p.strip() for p in entry.split('|')]
            if len(parts) >= 3:
                filename = parts[2].strip()
                manifest_files.add(filename)
        
        # Get actual files (basenames only for comparison)
        actual_files = {Path(f['path']).name for f in files}
        
        # Find orphaned files (in directory but not in manifest)
        orphaned = actual_files - manifest_files
        
        # Find missing files (in manifest but not in directory)
        missing = manifest_files - actual_files
        
        if orphaned:
            for file in orphaned:
                # Skip FILE.MANIFEST.txt itself and hidden files
                if file != 'FILE.MANIFEST.txt' and not file.startswith('.'):
                    self.issues['WARNING'].append({
                        'type': 'ORPHANED_FILE',
                        'file': file,
                        'message': f"File exists but has no manifest entry",
                        'severity': 'WARNING'
                    })
                    print(f"   ⚠️  ORPHANED: {file}")
                    self.validation_stats['orphaned'] += 1
        
        if missing:
            for file in missing:
                self.issues['WARNING'].append({
                    'type': 'MISSING_FILE',
                    'file': file,
                    'message': f"Manifest entry exists but file not found",
                    'severity': 'WARNING'
                })
                print(f"   ⚠️  MISSING: {file}")
        
        print(f"\n   📊 Manifest has {len(manifest_files)} entries")
        print(f"   📊 Directory has {len(actual_files)} files")
        print(f"   📊 Orphaned: {len(orphaned)}, Missing: {len(missing)}")
        
        self.session.add('validation', f'Manifest check: {len(orphaned)} orphaned, {len(missing)} missing')
        Trace.tool_call('cross_reference_manifest', f'{len(manifest_files)} manifest entries')
        
        return list(orphaned), list(missing)
    
    def check_duplicates(self, files: List[Dict]) -> List[Tuple[str, str]]:
        """Phase 3: Check for duplicate files by checksum"""
        print("\n📋 PHASE 3: Duplicate Detection")
        print("-" * 80)
        
        checksum_map = {}
        duplicates = []
        
        for file in files:
            checksum = file['checksum']
            if not checksum.startswith('ERROR'):
                if checksum in checksum_map:
                    # Found duplicate
                    original = checksum_map[checksum]
                    duplicates.append((original, file['path']))
                    
                    self.issues['INFO'].append({
                        'type': 'DUPLICATE_CONTENT',
                        'file1': original,
                        'file2': file['path'],
                        'checksum': checksum[:16] + '...',
                        'message': f"Identical content detected",
                        'severity': 'INFO'
                    })
                    print(f"   ℹ️  DUPLICATE: {file['path']} = {original}")
                    self.validation_stats['duplicates'] += 1
                else:
                    checksum_map[checksum] = file['path']
        
        if not duplicates:
            print(f"   ✅ No duplicates found")
        
        self.session.add('validation', f'Duplicate check: {len(duplicates)} pairs found')
        Trace.tool_call('check_duplicates', f'{len(duplicates)} duplicate pairs')
        
        return duplicates
    
    def validate_timestamps(self, files: List[Dict]) -> List[Dict]:
        """Phase 4: Validate timestamps"""
        print("\n📋 PHASE 4: Timestamp Validation")
        print("-" * 80)
        
        # Sort by modification time
        sorted_files = sorted(files, key=lambda f: f['modified'])
        
        timestamp_issues = []
        
        # Check for files with future timestamps
        now = datetime.now()
        for file in files:
            if file['modified'] > now:
                self.issues['WARNING'].append({
                    'type': 'FUTURE_TIMESTAMP',
                    'file': file['path'],
                    'timestamp': file['modified'].isoformat(),
                    'message': f"File has future timestamp",
                    'severity': 'WARNING'
                })
                timestamp_issues.append(file)
                print(f"   ⚠️  FUTURE: {file['path']} ({file['modified']})")
        
        # Check manifest for Sirius time format
        manifest_entries = Manifest.read()
        sirius_pattern = re.compile(r'⧗-\d+\.\d+')
        
        for entry in manifest_entries:
            if not sirius_pattern.search(entry):
                # Only report if it's not a comment line
                if not entry.strip().startswith('#'):
                    self.issues['INFO'].append({
                        'type': 'INVALID_TIMESTAMP_FORMAT',
                        'entry': entry.strip()[:50] + '...',
                        'message': f"Manifest entry missing Sirius time format (⧗-YY.DDD)",
                        'severity': 'INFO'
                    })
        
        if not timestamp_issues:
            print(f"   ✅ All timestamps valid")
            print(f"   📊 Earliest: {sorted_files[0]['modified']}")
            print(f"   📊 Latest: {sorted_files[-1]['modified']}")
        
        self.session.add('validation', f'Timestamp check: {len(timestamp_issues)} issues')
        Trace.tool_call('validate_timestamps', f'{len(files)} files checked')
        
        return timestamp_issues
    
    def validate_receipts(self, files: List[Dict]) -> int:
        """Phase 5: Validate receipts if available"""
        print("\n📋 PHASE 5: Receipt Validation")
        print("-" * 80)
        
        receipts_path = Path('.3ox/receipts.log')
        if not receipts_path.exists():
            print(f"   ℹ️  No receipts.log found - skipping receipt validation")
            return 0
        
        # Read receipts
        receipts = {}
        with open(receipts_path, 'r', encoding='utf-8') as f:
            for line in f:
                # Format: [timestamp] stage | file | hash
                parts = line.strip().split('|')
                if len(parts) >= 3:
                    file_path = parts[1].strip()
                    file_hash = parts[2].strip()
                    receipts[file_path] = file_hash
        
        validated_count = 0
        for file in files:
            full_path = file['full_path']
            if full_path in receipts:
                expected_hash = receipts[full_path]
                actual_hash = file['checksum']
                
                if expected_hash != actual_hash:
                    self.issues['CRITICAL'].append({
                        'type': 'RECEIPT_MISMATCH',
                        'file': file['path'],
                        'expected': expected_hash[:16] + '...',
                        'actual': actual_hash[:16] + '...',
                        'message': f"File checksum doesn't match receipt",
                        'severity': 'CRITICAL'
                    })
                    print(f"   ❌ MISMATCH: {file['path']}")
                else:
                    validated_count += 1
        
        print(f"   ✅ {validated_count} files validated against receipts")
        
        self.session.add('validation', f'Receipt check: {validated_count} validated')
        Trace.tool_call('validate_receipts', f'{validated_count} files matched')
        
        return validated_count
    
    def generate_report(self, files: List[Dict]) -> Dict:
        """Generate comprehensive validation report"""
        duration = (datetime.now() - self.start_time).total_seconds()
        
        # Categorize issues by severity
        critical_count = len(self.issues['CRITICAL'])
        warning_count = len(self.issues['WARNING'])
        info_count = len(self.issues['INFO'])
        total_issues = critical_count + warning_count + info_count
        
        # Calculate health score
        if self.validation_stats['total_files'] > 0:
            health_score = (
                (self.validation_stats['validated'] - critical_count - (warning_count * 0.5)) /
                self.validation_stats['total_files'] * 100
            )
            health_score = max(0, min(100, health_score))
        else:
            health_score = 0
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'session_id': self.session.session_id,
            'duration_seconds': round(duration, 2),
            'validation_summary': {
                'total_files': self.validation_stats['total_files'],
                'validated': self.validation_stats['validated'],
                'failed': self.validation_stats['failed'],
                'health_score': round(health_score, 1)
            },
            'issue_summary': {
                'total_issues': total_issues,
                'critical': critical_count,
                'warning': warning_count,
                'info': info_count
            },
            'statistics': {
                'orphaned_files': self.validation_stats['orphaned'],
                'duplicate_files': self.validation_stats['duplicates']
            },
            'issues_by_severity': {
                'CRITICAL': self.issues['CRITICAL'],
                'WARNING': self.issues['WARNING'],
                'INFO': self.issues['INFO']
            },
            'validation_phases': [
                'File Integrity Validation',
                'Manifest Cross-Reference',
                'Duplicate Detection',
                'Timestamp Validation',
                'Receipt Validation'
            ]
        }
        
        return report
    
    def execute(self):
        """Execute full validation process"""
        print("\n" + "="*80)
        print("🔍 FRAMEWORK-POWERED OUTPUT VALIDATION")
        print("="*80)
        
        # Initialize
        self.session.add('system', 'VALIDATION started')
        Trace.log('VALIDATION_START', {'session': self.session.session_id})
        
        # Scan all files
        print("\n📡 Scanning outputs...")
        files = self.scan_all_files()
        
        if not files:
            print("\n⚠️  No files found to validate")
            return None
        
        # Phase 1: File Integrity
        validated_files = self.validate_file_integrity(files)
        
        # Phase 2: Manifest Cross-Reference
        orphaned, missing = self.cross_reference_manifest(files)
        
        # Phase 3: Duplicate Detection
        duplicates = self.check_duplicates(validated_files)
        
        # Phase 4: Timestamp Validation
        timestamp_issues = self.validate_timestamps(files)
        
        # Phase 5: Receipt Validation
        receipt_validated = self.validate_receipts(files)
        
        # Generate report
        print("\n📊 Generating validation report...")
        report = self.generate_report(files)
        
        # Save report
        report_path = Path('0ut.3ox/VALIDATION_REPORT.json')
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2)
        
        # Generate receipt
        receipt = Receipt.generate(str(report_path), 'VALIDATION')
        
        # Add to manifest
        Manifest.add('VALIDATION_REPORT.json', 'OPS.STATION', 'READY', 'HIGH')
        
        # Display results
        self._display_results(report)
        
        # Save session
        self.session.add('system', 'VALIDATION completed')
        stats = self.session.get_token_stats()
        self.session.save()
        Trace.agent_end('success', f'{report["duration_seconds"]}s', stats)
        
        print("\n" + "="*80)
        print("✅ FRAMEWORK-POWERED VALIDATION COMPLETE")
        print("="*80)
        
        return report
    
    def _display_results(self, report):
        """Display results to console"""
        print("\n" + "="*80)
        print("📊 VALIDATION RESULTS")
        print("="*80)
        
        # Health score with visual indicator
        health = report['validation_summary']['health_score']
        if health >= 90:
            health_icon = "✅"
            health_status = "EXCELLENT"
        elif health >= 75:
            health_icon = "✔️"
            health_status = "GOOD"
        elif health >= 50:
            health_icon = "⚠️"
            health_status = "FAIR"
        else:
            health_icon = "❌"
            health_status = "POOR"
        
        print(f"\n{health_icon} HEALTH SCORE: {health}% ({health_status})")
        
        print(f"\n📁 Files Validated: {report['validation_summary']['validated']}/{report['validation_summary']['total_files']}")
        print(f"⏱️  Duration: {report['duration_seconds']}s")
        
        # Issue summary
        print(f"\n🔍 Issues Found: {report['issue_summary']['total_issues']}")
        print(f"   ❌ CRITICAL: {report['issue_summary']['critical']}")
        print(f"   ⚠️  WARNING:  {report['issue_summary']['warning']}")
        print(f"   ℹ️  INFO:     {report['issue_summary']['info']}")
        
        # Statistics
        if report['statistics']['orphaned_files'] or report['statistics']['duplicate_files']:
            print(f"\n📊 Statistics:")
            if report['statistics']['orphaned_files']:
                print(f"   Orphaned Files: {report['statistics']['orphaned_files']}")
            if report['statistics']['duplicate_files']:
                print(f"   Duplicate Files: {report['statistics']['duplicate_files']}")
        
        # Show critical issues
        if report['issues_by_severity']['CRITICAL']:
            print(f"\n❌ CRITICAL ISSUES:")
            for issue in report['issues_by_severity']['CRITICAL'][:5]:
                print(f"   • {issue['type']}: {issue.get('file', 'N/A')}")
                print(f"     {issue['message']}")
        
        # Show warnings
        if report['issues_by_severity']['WARNING']:
            print(f"\n⚠️  WARNINGS (showing first 5):")
            for issue in report['issues_by_severity']['WARNING'][:5]:
                print(f"   • {issue['type']}: {issue.get('file', 'N/A')}")
        
        # Token stats
        stats = self.session.get_token_stats()
        print(f"\n🎯 Framework Stats:")
        print(f"   Tokens: {stats['total_tokens']} ({stats['counting_method']})")
        print(f"   Messages: {stats['message_count']}")
        print(f"   Utilization: {stats['utilization']}%")
        
        print(f"\n📂 Outputs Generated:")
        print(f"   - 0ut.3ox/VALIDATION_REPORT.json")
        print(f"   - .3ox/session.json (updated)")
        print(f"   - .3ox/trace.log (appended)")
        print(f"   - .3ox/receipts.log (appended)")
        print(f"   - 0ut.3ox/FILE.MANIFEST.txt (updated)")

if __name__ == "__main__":
    validator = OutputValidator('validation_001')
    report = validator.execute()

