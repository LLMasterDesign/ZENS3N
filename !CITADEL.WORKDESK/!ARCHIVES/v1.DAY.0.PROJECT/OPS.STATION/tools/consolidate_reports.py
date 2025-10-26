#!/usr/bin/env python3
"""
REPORT CONSOLIDATION - Framework-Powered Multi-Source Aggregation
Comprehensive executive summary across all connected stations
Uses .3ox runtime for systematic data collection and analysis
"""

import sys
import os
import json
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple
from collections import defaultdict

# Import framework runtime
sys.path.insert(0, str(Path(__file__).parent.parent / '.3ox'))
from run import Session, Trace, Receipt, Manifest

class ReportConsolidator:
    def __init__(self, session_id: str):
        self.session = Session(session_id, 'claude-sonnet-4')
        self.start_time = datetime.now()
        Trace.agent_start('OVERSEER', session_id)
        
        self.data = {
            'manifest_entries': [],
            'reports': [],
            'trace_logs': [],
            'receipts': [],
            'by_station': defaultdict(list),
            'operations': []
        }
        
        self.stats = {
            'total_operations': 0,
            'by_station': {},
            'by_status': {},
            'issues_found': 0
        }
    
    def collect_manifest_data(self):
        """Phase 1: Collect FILE.MANIFEST.txt data"""
        print("\n📋 PHASE 1: Manifest Data Collection")
        print("-" * 80)
        
        entries = Manifest.read()
        
        for entry in entries:
            # Parse: [timestamp] | status | filename | destination | priority
            parts = [p.strip() for p in entry.split('|')]
            if len(parts) >= 5:
                parsed = {
                    'timestamp': parts[0].strip('[]'),
                    'status': parts[1],
                    'filename': parts[2],
                    'destination': parts[3],
                    'priority': parts[4],
                    'raw': entry
                }
                self.data['manifest_entries'].append(parsed)
                
                # Track by destination
                dest = parsed['destination']
                self.data['by_station'][dest].append(parsed)
                
                # Track by status
                status = parsed['status']
                self.stats['by_status'][status] = self.stats['by_status'].get(status, 0) + 1
        
        self.stats['total_operations'] = len(self.data['manifest_entries'])
        
        print(f"   📊 Manifest entries: {len(self.data['manifest_entries'])}")
        print(f"   📊 Stations tracked: {len(self.data['by_station'])}")
        print(f"   📊 Status breakdown: {dict(self.stats['by_status'])}")
        
        self.session.add('tool', f'Manifest parsed: {len(self.data["manifest_entries"])} entries')
        Trace.tool_call('collect_manifest_data', f'{len(self.data["manifest_entries"])} entries')
        
        return self.data['manifest_entries']
    
    def collect_reports(self):
        """Phase 2: Scan and analyze all reports in 0ut.3ox/"""
        print("\n📋 PHASE 2: Report Collection & Analysis")
        print("-" * 80)
        
        output_dir = Path('0ut.3ox')
        report_files = []
        
        # Find all report files
        for pattern in ['*.md', '*.json', '*.txt']:
            report_files.extend(output_dir.glob(pattern))
        
        for report_file in report_files:
            report_data = {
                'filename': report_file.name,
                'path': str(report_file),
                'type': report_file.suffix,
                'size': report_file.stat().st_size,
                'modified': datetime.fromtimestamp(report_file.stat().st_mtime)
            }
            
            # Try to extract key info from different file types
            if report_file.suffix == '.json':
                try:
                    with open(report_file, 'r', encoding='utf-8') as f:
                        content = json.load(f)
                        report_data['content'] = content
                        report_data['summary'] = self._summarize_json(content)
                except:
                    report_data['summary'] = 'JSON parse error'
            
            elif report_file.suffix == '.md':
                try:
                    with open(report_file, 'r', encoding='utf-8') as f:
                        content = f.read()
                        report_data['summary'] = self._summarize_markdown(content)
                        report_data['line_count'] = len(content.split('\n'))
                except:
                    report_data['summary'] = 'Read error'
            
            self.data['reports'].append(report_data)
            print(f"   📄 {report_file.name} ({report_file.suffix}, {report_data['size']} bytes)")
        
        print(f"\n   📊 Total reports: {len(self.data['reports'])}")
        
        self.session.add('tool', f'Reports collected: {len(self.data["reports"])} files')
        Trace.tool_call('collect_reports', f'{len(self.data["reports"])} reports')
        
        return self.data['reports']
    
    def _summarize_json(self, content: Dict) -> str:
        """Summarize JSON report content"""
        summary_parts = []
        
        if 'session_id' in content:
            summary_parts.append(f"Session: {content['session_id']}")
        
        if 'validation_summary' in content:
            vs = content['validation_summary']
            summary_parts.append(f"Validated: {vs.get('validated', 0)}/{vs.get('total_files', 0)} files")
            summary_parts.append(f"Health: {vs.get('health_score', 0)}%")
        
        if 'summary' in content:
            s = content['summary']
            if 'total_files' in s:
                summary_parts.append(f"Files: {s['total_files']}")
            if 'integrity' in s:
                summary_parts.append(f"Integrity: {s['integrity'].get('percentage', 0)}%")
        
        if 'issue_summary' in content:
            iss = content['issue_summary']
            summary_parts.append(f"Issues: {iss.get('total_issues', 0)} ({iss.get('critical', 0)} critical)")
        
        return " | ".join(summary_parts) if summary_parts else "JSON report"
    
    def _summarize_markdown(self, content: str) -> str:
        """Summarize Markdown report content"""
        lines = content.split('\n')
        
        # Extract title (first # heading)
        for line in lines[:20]:
            if line.startswith('# ') and not line.startswith('###'):
                return line.strip('# ').strip()
        
        # Fallback: first non-empty line
        for line in lines[:10]:
            if line.strip() and not line.startswith('#'):
                return line.strip()[:100]
        
        return "Markdown report"
    
    def collect_trace_logs(self):
        """Phase 3: Collect trace log data"""
        print("\n📋 PHASE 3: Trace Log Collection")
        print("-" * 80)
        
        trace_path = Path('.3ox/trace.log')
        
        if not trace_path.exists():
            print(f"   ℹ️  No trace.log found")
            return []
        
        with open(trace_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        for line in lines:
            # Parse: [timestamp] EVENT | data
            match = re.match(r'\[(.*?)\]\s+(\w+)\s+\|\s+(.*)', line.strip())
            if match:
                timestamp, event, data = match.groups()
                try:
                    data_parsed = json.loads(data) if data.strip() else {}
                except:
                    data_parsed = {'raw': data}
                
                self.data['trace_logs'].append({
                    'timestamp': timestamp,
                    'event': event,
                    'data': data_parsed
                })
        
        print(f"   📊 Trace events: {len(self.data['trace_logs'])}")
        
        # Analyze events
        events_by_type = defaultdict(int)
        for log in self.data['trace_logs']:
            events_by_type[log['event']] += 1
        
        print(f"   📊 Event types: {dict(events_by_type)}")
        
        self.session.add('tool', f'Trace logs parsed: {len(self.data["trace_logs"])} events')
        Trace.tool_call('collect_trace_logs', f'{len(self.data["trace_logs"])} events')
        
        return self.data['trace_logs']
    
    def collect_receipts(self):
        """Phase 4: Collect receipt log data"""
        print("\n📋 PHASE 4: Receipt Collection")
        print("-" * 80)
        
        receipts_path = Path('.3ox/receipts.log')
        
        if not receipts_path.exists():
            print(f"   ℹ️  No receipts.log found")
            return []
        
        with open(receipts_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        for line in lines:
            # Parse: [timestamp] stage | file | hash
            parts = line.strip().split('|')
            if len(parts) >= 3:
                self.data['receipts'].append({
                    'timestamp': parts[0].strip('[]'),
                    'stage': parts[1].strip(),
                    'file': parts[2].strip(),
                    'hash': parts[3].strip() if len(parts) > 3 else 'N/A'
                })
        
        print(f"   📊 Receipts: {len(self.data['receipts'])}")
        
        self.session.add('tool', f'Receipts collected: {len(self.data["receipts"])}')
        Trace.tool_call('collect_receipts', f'{len(self.data["receipts"])} receipts')
        
        return self.data['receipts']
    
    def analyze_performance(self):
        """Phase 5: Analyze performance metrics"""
        print("\n📋 PHASE 5: Performance Analysis")
        print("-" * 80)
        
        performance = {
            'operations_by_station': {},
            'operations_by_priority': {},
            'success_rate': 0,
            'total_events': len(self.data['trace_logs']),
            'total_receipts': len(self.data['receipts'])
        }
        
        # Analyze by station
        for station, entries in self.data['by_station'].items():
            performance['operations_by_station'][station] = len(entries)
        
        # Analyze by priority
        priority_count = defaultdict(int)
        for entry in self.data['manifest_entries']:
            priority_count[entry['priority']] += 1
        performance['operations_by_priority'] = dict(priority_count)
        
        # Calculate success rate (READY vs other statuses)
        ready_count = self.stats['by_status'].get('READY', 0)
        total_count = sum(self.stats['by_status'].values())
        if total_count > 0:
            performance['success_rate'] = round((ready_count / total_count) * 100, 1)
        
        print(f"   📊 Operations by station: {performance['operations_by_station']}")
        print(f"   📊 Success rate: {performance['success_rate']}%")
        print(f"   📊 Total events logged: {performance['total_events']}")
        
        self.session.add('analysis', f'Performance analyzed: {performance["success_rate"]}% success rate')
        Trace.tool_call('analyze_performance', f'{total_count} operations analyzed')
        
        return performance
    
    def detect_issues(self):
        """Phase 6: Detect issues and anomalies"""
        print("\n📋 PHASE 6: Issue Detection")
        print("-" * 80)
        
        issues = []
        
        # Check for failed operations
        for status, count in self.stats['by_status'].items():
            if status not in ['READY', 'COMPLETE']:
                issues.append({
                    'type': 'STATUS_ISSUE',
                    'severity': 'WARNING',
                    'message': f"{count} operations with status '{status}'"
                })
        
        # Check for missing stations
        expected_stations = ['OPS.STATION', 'OBSIDIAN.BASE', 'SYNTH.BASE', 'RVNx.BASE']
        for station in expected_stations:
            if station not in self.data['by_station'] or len(self.data['by_station'][station]) == 0:
                if station != 'RVNx.BASE':  # RVNx expected to be inactive
                    issues.append({
                        'type': 'MISSING_STATION',
                        'severity': 'INFO',
                        'message': f"No operations from {station}"
                    })
        
        # Check validation reports for issues
        for report in self.data['reports']:
            if 'VALIDATION' in report['filename'] and 'content' in report:
                content = report['content']
                if 'issue_summary' in content:
                    total_issues = content['issue_summary'].get('total_issues', 0)
                    critical = content['issue_summary'].get('critical', 0)
                    if critical > 0:
                        issues.append({
                            'type': 'VALIDATION_CRITICAL',
                            'severity': 'CRITICAL',
                            'message': f"{critical} critical validation issues detected"
                        })
                    elif total_issues > 0:
                        issues.append({
                            'type': 'VALIDATION_WARNINGS',
                            'severity': 'INFO',
                            'message': f"{total_issues} validation issues detected"
                        })
        
        self.stats['issues_found'] = len(issues)
        
        print(f"   📊 Issues detected: {len(issues)}")
        for issue in issues[:5]:
            print(f"   {issue['severity']}: {issue['message']}")
        
        self.session.add('analysis', f'Issues detected: {len(issues)}')
        Trace.tool_call('detect_issues', f'{len(issues)} issues found')
        
        return issues
    
    def generate_recommendations(self, performance: Dict, issues: List[Dict]) -> List[str]:
        """Generate actionable recommendations"""
        recommendations = []
        
        # Based on success rate
        if performance['success_rate'] < 90:
            recommendations.append(
                "Investigate operations with non-READY status to improve success rate"
            )
        
        # Based on station activity
        inactive_stations = []
        for station in ['OBSIDIAN.BASE', 'SYNTH.BASE']:
            if station not in performance['operations_by_station'] or \
               performance['operations_by_station'][station] == 0:
                inactive_stations.append(station)
        
        if inactive_stations:
            recommendations.append(
                f"Verify connectivity and health of: {', '.join(inactive_stations)}"
            )
        
        # Based on issues
        critical_issues = [i for i in issues if i['severity'] == 'CRITICAL']
        if critical_issues:
            recommendations.append(
                "Address critical validation issues immediately"
            )
        
        # Based on receipts
        if performance['total_receipts'] < self.stats['total_operations'] * 0.5:
            recommendations.append(
                "Increase receipt generation coverage for better auditability"
            )
        
        # General recommendations
        recommendations.append(
            "Continue regular validation and consolidation cycles"
        )
        
        recommendations.append(
            "Monitor trace logs for performance degradation patterns"
        )
        
        return recommendations
    
    def generate_executive_summary(self, performance: Dict, issues: List[Dict]) -> Dict:
        """Generate comprehensive executive summary"""
        duration = (datetime.now() - self.start_time).total_seconds()
        
        recommendations = self.generate_recommendations(performance, issues)
        
        # Calculate activity timeline
        if self.data['manifest_entries']:
            timestamps = [e['timestamp'] for e in self.data['manifest_entries']]
            earliest = min(timestamps)
            latest = max(timestamps)
        else:
            earliest = latest = "N/A"
        
        summary = {
            'generated': datetime.now().isoformat(),
            'session_id': self.session.session_id,
            'consolidation_duration': round(duration, 2),
            
            'overview': {
                'total_operations': self.stats['total_operations'],
                'stations_active': len([s for s, ops in performance['operations_by_station'].items() if ops > 0]),
                'success_rate': performance['success_rate'],
                'issues_detected': len(issues),
                'critical_issues': len([i for i in issues if i['severity'] == 'CRITICAL']),
                'activity_period': {
                    'earliest': earliest,
                    'latest': latest
                }
            },
            
            'by_station': {
                'OBSIDIAN.BASE': {
                    'callsign': 'LIGHTHOUSE',
                    'function': 'Knowledge Operations',
                    'operations': performance['operations_by_station'].get('OBSIDIAN.BASE', 0),
                    'status': 'ACTIVE' if performance['operations_by_station'].get('OBSIDIAN.BASE', 0) > 0 else 'INACTIVE'
                },
                'SYNTH.BASE': {
                    'callsign': 'ALCHEMIST',
                    'function': 'Deployment Operations',
                    'operations': performance['operations_by_station'].get('SYNTH.BASE', 0),
                    'status': 'ACTIVE' if performance['operations_by_station'].get('SYNTH.BASE', 0) > 0 else 'INACTIVE'
                },
                'RVNx.BASE': {
                    'callsign': 'SENTINEL',
                    'function': 'Sync Operations',
                    'operations': performance['operations_by_station'].get('RVNx.BASE', 0),
                    'status': 'INACTIVE (Expected)'
                },
                'OPS.STATION': {
                    'callsign': 'OVERSEER',
                    'function': 'Central Coordination',
                    'operations': performance['operations_by_station'].get('OPS.STATION', 0),
                    'status': 'ACTIVE'
                }
            },
            
            'performance': performance,
            
            'issues': {
                'total': len(issues),
                'by_severity': {
                    'CRITICAL': len([i for i in issues if i['severity'] == 'CRITICAL']),
                    'WARNING': len([i for i in issues if i['severity'] == 'WARNING']),
                    'INFO': len([i for i in issues if i['severity'] == 'INFO'])
                },
                'details': issues
            },
            
            'recommendations': recommendations,
            
            'data_sources': {
                'manifest_entries': len(self.data['manifest_entries']),
                'reports_analyzed': len(self.data['reports']),
                'trace_events': len(self.data['trace_logs']),
                'receipts': len(self.data['receipts'])
            }
        }
        
        return summary
    
    def execute(self):
        """Execute full consolidation process"""
        print("\n" + "="*80)
        print("📊 FRAMEWORK-POWERED REPORT CONSOLIDATION")
        print("="*80)
        print("\n🎯 Multi-Source Data Aggregation - Executive Summary")
        
        # Initialize
        self.session.add('system', 'CONSOLIDATION started')
        Trace.log('CONSOLIDATION_START', {'session': self.session.session_id})
        
        # Phase 1: Manifest Data
        manifest_entries = self.collect_manifest_data()
        
        # Phase 2: Reports
        reports = self.collect_reports()
        
        # Phase 3: Trace Logs
        trace_logs = self.collect_trace_logs()
        
        # Phase 4: Receipts
        receipts = self.collect_receipts()
        
        # Phase 5: Performance Analysis
        performance = self.analyze_performance()
        
        # Phase 6: Issue Detection
        issues = self.detect_issues()
        
        # Generate Executive Summary
        print("\n📊 Generating executive summary...")
        summary = self.generate_executive_summary(performance, issues)
        
        # Save JSON report
        json_path = Path('0ut.3ox/EXECUTIVE_SUMMARY.json')
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2)
        
        # Generate receipt
        receipt = Receipt.generate(str(json_path), 'CONSOLIDATION')
        
        # Add to manifest
        Manifest.add('EXECUTIVE_SUMMARY.json', 'OPS.STATION', 'READY', 'HIGH')
        
        # Display results
        self._display_results(summary)
        
        # Save session
        self.session.add('system', 'CONSOLIDATION completed')
        stats = self.session.get_token_stats()
        self.session.save()
        Trace.agent_end('success', f'{summary["consolidation_duration"]}s', stats)
        
        print("\n" + "="*80)
        print("✅ FRAMEWORK-POWERED CONSOLIDATION COMPLETE")
        print("="*80)
        
        return summary
    
    def _display_results(self, summary):
        """Display results to console"""
        print("\n" + "="*80)
        print("📊 EXECUTIVE SUMMARY - MULTI-STATION OPERATIONS")
        print("="*80)
        
        # Overview
        ov = summary['overview']
        print(f"\n📈 OVERVIEW")
        print(f"   Total Operations: {ov['total_operations']}")
        print(f"   Stations Active: {ov['stations_active']}/4")
        print(f"   Success Rate: {ov['success_rate']}%")
        print(f"   Issues: {ov['issues_detected']} ({ov['critical_issues']} critical)")
        print(f"   Period: {ov['activity_period']['earliest']} → {ov['activity_period']['latest']}")
        
        # By Station
        print(f"\n🏢 BY STATION")
        for station_name, station_data in summary['by_station'].items():
            status_icon = "✅" if station_data['status'].startswith('ACTIVE') else "❌"
            print(f"   {status_icon} {station_name} ({station_data['callsign']})")
            print(f"      Function: {station_data['function']}")
            print(f"      Operations: {station_data['operations']}")
            print(f"      Status: {station_data['status']}")
        
        # Performance
        perf = summary['performance']
        print(f"\n⚡ PERFORMANCE")
        print(f"   Success Rate: {perf['success_rate']}%")
        print(f"   Trace Events: {perf['total_events']}")
        print(f"   Receipts Generated: {perf['total_receipts']}")
        print(f"   Priority Distribution: {perf['operations_by_priority']}")
        
        # Issues
        if summary['issues']['total'] > 0:
            iss = summary['issues']
            print(f"\n⚠️  ISSUES DETECTED")
            print(f"   Total: {iss['total']}")
            print(f"   Critical: {iss['by_severity']['CRITICAL']}")
            print(f"   Warning: {iss['by_severity']['WARNING']}")
            print(f"   Info: {iss['by_severity']['INFO']}")
            
            if iss['details']:
                print(f"\n   Top Issues:")
                for issue in iss['details'][:3]:
                    print(f"   • {issue['severity']}: {issue['message']}")
        
        # Recommendations
        print(f"\n💡 RECOMMENDATIONS")
        for i, rec in enumerate(summary['recommendations'], 1):
            print(f"   {i}. {rec}")
        
        # Data Sources
        ds = summary['data_sources']
        print(f"\n📂 DATA SOURCES")
        print(f"   Manifest Entries: {ds['manifest_entries']}")
        print(f"   Reports Analyzed: {ds['reports_analyzed']}")
        print(f"   Trace Events: {ds['trace_events']}")
        print(f"   Receipts: {ds['receipts']}")
        
        # Framework Stats
        stats = self.session.get_token_stats()
        print(f"\n🎯 Framework Stats:")
        print(f"   Tokens: {stats['total_tokens']} ({stats['counting_method']})")
        print(f"   Messages: {stats['message_count']}")
        print(f"   Duration: {summary['consolidation_duration']}s")
        
        print(f"\n📂 Outputs Generated:")
        print(f"   - 0ut.3ox/EXECUTIVE_SUMMARY.json")
        print(f"   - .3ox/session.json (updated)")
        print(f"   - .3ox/trace.log (appended)")
        print(f"   - .3ox/receipts.log (appended)")
        print(f"   - 0ut.3ox/FILE.MANIFEST.txt (updated)")

if __name__ == "__main__":
    consolidator = ReportConsolidator('consolidation_001')
    summary = consolidator.execute()

