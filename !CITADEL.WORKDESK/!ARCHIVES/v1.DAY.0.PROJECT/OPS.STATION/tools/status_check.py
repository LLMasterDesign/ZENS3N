#!/usr/bin/env python3
"""
STATUS CHECK - Framework-Powered OPS Monitor
Uses .3ox runtime for automated station monitoring
"""

import sys
import os
from pathlib import Path
from datetime import datetime
import json

# Import framework runtime
sys.path.insert(0, str(Path(__file__).parent.parent / '.3ox'))
from run import Session, Trace, Receipt, Manifest

class StationMonitor:
    def __init__(self, session_id: str):
        self.session = Session(session_id, 'claude-sonnet-4')
        self.start_time = datetime.now()
        Trace.agent_start('OVERSEER', session_id)
        
    def scan_outputs(self):
        """Scan 0ut.3ox directory for all outputs"""
        output_dir = Path('0ut.3ox')
        if not output_dir.exists():
            return []
        
        files = []
        for item in output_dir.rglob('*'):
            if item.is_file():
                files.append({
                    'path': str(item.relative_to('0ut.3ox')),
                    'size': item.stat().st_size,
                    'modified': datetime.fromtimestamp(item.stat().st_mtime),
                    'station': self._detect_station(item)
                })
        
        return files
    
    def _detect_station(self, path: Path) -> str:
        """Detect which station produced the file"""
        path_str = str(path)
        if 'OBS.BATCH' in path_str:
            return 'OBSIDIAN'
        elif 'SYNTH.BATCH' in path_str:
            return 'SYNTH'
        elif 'OPS.BATCH' in path_str:
            return 'OPS'
        elif 'RVNx.BATCH' in path_str:
            return 'RVNx'
        else:
            return 'DIRECT'
    
    def analyze_integrity(self, files):
        """Analyze file integrity"""
        issues = {
            'empty': [],
            'suspicious': [],
            'valid': []
        }
        
        for file in files:
            if file['size'] == 0:
                issues['empty'].append(file)
            elif file['size'] < 100:
                issues['suspicious'].append(file)
            else:
                issues['valid'].append(file)
        
        return issues
    
    def check_manifest(self):
        """Check FILE.MANIFEST.txt status"""
        if Manifest.MANIFEST_PATH.exists():
            stats = Manifest.get_stats()
            return {
                'exists': True,
                'stats': stats
            }
        else:
            return {
                'exists': False,
                'stats': None
            }
    
    def generate_report(self, files, issues, manifest_status):
        """Generate comprehensive status report"""
        duration = (datetime.now() - self.start_time).total_seconds()
        
        # Count by station
        by_station = {}
        for file in files:
            station = file['station']
            by_station[station] = by_station.get(station, 0) + 1
        
        # Latest activity
        latest = max(files, key=lambda f: f['modified']) if files else None
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'session_id': self.session.session_id,
            'duration_seconds': round(duration, 2),
            'summary': {
                'total_files': len(files),
                'by_station': by_station,
                'integrity': {
                    'valid': len(issues['valid']),
                    'empty': len(issues['empty']),
                    'suspicious': len(issues['suspicious']),
                    'percentage': round(len(issues['valid']) / len(files) * 100, 1) if files else 0
                }
            },
            'manifest': manifest_status,
            'latest_activity': {
                'file': latest['path'] if latest else None,
                'time': latest['modified'].isoformat() if latest else None,
                'station': latest['station'] if latest else None
            } if latest else None,
            'issues_detected': {
                'empty_files': [f['path'] for f in issues['empty']],
                'suspicious_files': [f['path'] for f in issues['suspicious']]
            }
        }
        
        return report
    
    def execute(self):
        """Execute full status check"""
        print("\n" + "="*80)
        print("🎯 FRAMEWORK-POWERED STATUS CHECK")
        print("="*80)
        
        # Log start
        self.session.add('system', 'STATUS_CHECK initiated')
        Trace.log('STATUS_CHECK_START', {'session': self.session.session_id})
        
        # Scan outputs
        print("\n📡 Scanning station outputs...")
        files = self.scan_outputs()
        self.session.add('tool', f'Scanned {len(files)} files from 0ut.3ox/')
        Trace.tool_call('scan_outputs', '0ut.3ox/')
        
        # Analyze integrity
        print(f"🔍 Analyzing {len(files)} files...")
        issues = self.analyze_integrity(files)
        self.session.add('tool', f'Integrity check: {len(issues["valid"])} valid, {len(issues["empty"])} empty, {len(issues["suspicious"])} suspicious')
        Trace.tool_call('analyze_integrity', f'{len(files)} files')
        
        # Check manifest
        print("📄 Checking FILE.MANIFEST.txt...")
        manifest_status = self.check_manifest()
        if manifest_status['exists']:
            print(f"   ✅ FOUND - {manifest_status['stats']['total_entries']} entries")
            self.session.add('tool', f'FILE.MANIFEST.txt exists with {manifest_status["stats"]["total_entries"]} entries')
        else:
            print("   ❌ NOT FOUND - Initializing...")
            Manifest.initialize()
            manifest_status = self.check_manifest()
            self.session.add('tool', 'FILE.MANIFEST.txt created')
        
        # Generate report
        print("\n📊 Generating report...")
        report = self.generate_report(files, issues, manifest_status)
        
        # Save report
        report_path = Path('0ut.3ox/STATUS_REPORT_FRAMEWORK.json')
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2)
        
        # Generate receipt
        receipt = Receipt.generate(str(report_path), 'STATUS_CHECK')
        
        # Add to manifest
        Manifest.add('STATUS_REPORT_FRAMEWORK.json', 'OPS.STATION', 'READY', 'HIGH')
        
        # Display results
        self._display_results(report)
        
        # Save session
        self.session.add('system', 'STATUS_CHECK completed')
        stats = self.session.get_token_stats()
        self.session.save()
        Trace.agent_end('success', f'{report["duration_seconds"]}s', stats)
        
        print("\n" + "="*80)
        print("✅ FRAMEWORK-POWERED STATUS CHECK COMPLETE")
        print("="*80)
        
        return report
    
    def _display_results(self, report):
        """Display results to console"""
        print("\n" + "="*80)
        print("📊 RESULTS")
        print("="*80)
        
        print(f"\n📁 Total Files: {report['summary']['total_files']}")
        print(f"⏱️  Duration: {report['duration_seconds']}s")
        
        print(f"\n🏢 By Station:")
        for station, count in report['summary']['by_station'].items():
            print(f"   {station:12} → {count:3} files")
        
        print(f"\n🔍 Integrity:")
        print(f"   Valid:      {report['summary']['integrity']['valid']}")
        print(f"   Empty:      {report['summary']['integrity']['empty']}")
        print(f"   Suspicious: {report['summary']['integrity']['suspicious']}")
        print(f"   Health:     {report['summary']['integrity']['percentage']}%")
        
        if report['latest_activity']:
            print(f"\n⏰ Latest Activity:")
            print(f"   File:    {report['latest_activity']['file']}")
            print(f"   Time:    {report['latest_activity']['time']}")
            print(f"   Station: {report['latest_activity']['station']}")
        
        if report['issues_detected']['empty_files'] or report['issues_detected']['suspicious_files']:
            print(f"\n⚠️  Issues Detected:")
            if report['issues_detected']['empty_files']:
                print(f"   Empty files ({len(report['issues_detected']['empty_files'])}):")
                for f in report['issues_detected']['empty_files'][:5]:
                    print(f"      - {f}")
            if report['issues_detected']['suspicious_files']:
                print(f"   Suspicious files ({len(report['issues_detected']['suspicious_files'])}):")
                for f in report['issues_detected']['suspicious_files'][:5]:
                    print(f"      - {f}")
        
        print(f"\n📄 FILE.MANIFEST.txt:")
        if report['manifest']['exists']:
            print(f"   Status: ✅ EXISTS")
            print(f"   Entries: {report['manifest']['stats']['total_entries']}")
        else:
            print(f"   Status: ❌ WAS MISSING (now created)")
        
        # Token stats
        stats = self.session.get_token_stats()
        print(f"\n🎯 Framework Stats:")
        print(f"   Tokens: {stats['total_tokens']} ({stats['counting_method']})")
        print(f"   Messages: {stats['message_count']}")
        print(f"   Utilization: {stats['utilization']}%")
        
        print(f"\n📂 Outputs Generated:")
        print(f"   - 0ut.3ox/STATUS_REPORT_FRAMEWORK.json")
        print(f"   - .3ox/session.json")
        print(f"   - .3ox/trace.log (appended)")
        print(f"   - .3ox/receipts.log (appended)")
        print(f"   - 0ut.3ox/FILE.MANIFEST.txt (updated)")

if __name__ == "__main__":
    monitor = StationMonitor('status_check_framework_001')
    report = monitor.execute()

