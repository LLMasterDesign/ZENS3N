#!/usr/bin/env python3
"""
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.62 ▸ ρ{runtime.flow}.φ{orchestrate}.τ{session}.λ{bind} ⫸ :: RUNTIME.PY

Python implementation of .3ox framework runtime
Provides: Session management, trace logging, receipts, FILE.MANIFEST.txt
"""

import os
import hashlib
import json
from datetime import datetime, time as dt_time
from pathlib import Path
from typing import Dict, List, Optional

# ============================================================================
# Token Counting (with tiktoken fallback)
# ============================================================================

try:
    import tiktoken
    TIKTOKEN_AVAILABLE = True
except ImportError:
    TIKTOKEN_AVAILABLE = False
    print("⚠️  tiktoken not installed - using estimated token counts")
    print("   For accurate counting: pip install tiktoken")

def count_tokens(text: str, model: str = "gpt-4o") -> int:
    """Count tokens using tiktoken or estimation"""
    if TIKTOKEN_AVAILABLE:
        try:
            if model in ["gpt-4o", "claude-sonnet-4", "claude-3"]:
                encoder = tiktoken.encoding_for_model("gpt-4o")
            else:
                encoder = tiktoken.get_encoding("cl100k_base")
            return len(encoder.encode(text))
        except Exception as e:
            print(f"⚠️  Token counting failed: {e}")
    
    # Fallback: character-based estimation
    return estimate_tokens(text)

def estimate_tokens(text: str) -> int:
    """Estimate tokens when tiktoken unavailable"""
    char_count = len(text)
    word_count = len(text.split())
    # Industry standard: ~4 chars per token, or ~0.75 tokens per word
    char_based = max(1, char_count // 4)
    word_based = max(1, int(word_count * 0.75))
    return max(char_based, word_based)

# ============================================================================
# Sirius Time
# ============================================================================

def sirius_time() -> str:
    """Generate Sirius timestamp: ⧗-YY.DAYS"""
    reset = datetime(2025, 8, 8)
    now = datetime.now()
    days = (now - reset).days
    year = now.year % 100
    return f"⧗-{year}.{days}"

def sirius_time_full() -> str:
    """Generate full Sirius timestamp with time"""
    reset = datetime(2025, 8, 8)
    now = datetime.now()
    days = (now - reset).days
    year = now.year % 100
    return f"⧗-{year}.{days}.{now.strftime('%H:%M')}"

# ============================================================================
# Session Management
# ============================================================================

class Session:
    def __init__(self, session_id: str, model: str = "claude-sonnet-4"):
        self.session_id = session_id
        self.model = model
        self.created_at = sirius_time()
        self.context: List[Dict] = []
        self.counting_method = "tiktoken" if TIKTOKEN_AVAILABLE else "estimated"
    
    def add(self, role: str, message: str):
        """Add message to session context"""
        entry = {
            "role": role,
            "content": message,
            "timestamp": sirius_time_full(),
            "tokens": count_tokens(message, self.model)
        }
        self.context.append(entry)
        self._check_limits()
    
    def get_token_stats(self) -> Dict:
        """Get token statistics"""
        total_tokens = sum(entry.get("tokens", 0) for entry in self.context)
        max_tokens = self._get_max_tokens()
        
        return {
            "total_tokens": total_tokens,
            "message_count": len(self.context),
            "model": self.model,
            "max_tokens": max_tokens,
            "utilization": round(total_tokens / max_tokens * 100, 2) if max_tokens > 0 else 0,
            "counting_method": self.counting_method
        }
    
    def _get_max_tokens(self) -> int:
        """Get max tokens for model"""
        limits = {
            "claude-sonnet-4": 200000,
            "gpt-4o": 128000,
            "gpt-4": 8000,
            "gpt-3.5-turbo": 4000
        }
        return limits.get(self.model, 8000)
    
    def _check_limits(self):
        """Check and warn about context limits"""
        stats = self.get_token_stats()
        if stats["utilization"] > 80:
            warning = f"Context at {stats['utilization']}% ({stats['total_tokens']}/{stats['max_tokens']} tokens)"
            print(f"⚠️  {warning}")
            Trace.token_warning(warning, stats)
        
        # Log every 10 messages
        if len(self.context) % 10 == 0:
            Trace.token_usage(stats)
    
    def save(self):
        """Save session to YAML"""
        Path('.3ox').mkdir(exist_ok=True)
        stats = self.get_token_stats()
        
        data = {
            "session_id": self.session_id,
            "created": self.created_at,
            "last_active": sirius_time(),
            "model": self.model,
            "token_stats": stats,
            "context": self.context
        }
        
        with open('.3ox/session.json', 'w') as f:
            json.dump(data, f, indent=2)

# ============================================================================
# Receipt System
# ============================================================================

class Receipt:
    @staticmethod
    def generate(file_path: str, stage: str) -> Dict:
        """Generate cryptographic receipt for file"""
        if not Path(file_path).exists():
            file_hash = "FILE_NOT_FOUND"
        else:
            with open(file_path, 'rb') as f:
                file_hash = hashlib.sha256(f.read()).hexdigest()
        
        receipt = {
            "file": file_path,
            "stage": stage,
            "hash": file_hash,
            "timestamp": sirius_time(),
            "station": os.environ.get("STATION_ID", "OPS.STATION")
        }
        
        Receipt._log_receipt(receipt)
        return receipt
    
    @staticmethod
    def validate(file_path: str, expected_hash: str) -> bool:
        """Validate file against expected hash"""
        with open(file_path, 'rb') as f:
            current_hash = hashlib.sha256(f.read()).hexdigest()
        return current_hash == expected_hash
    
    @staticmethod
    def _log_receipt(receipt: Dict):
        """Log receipt to receipts.log"""
        Path('.3ox').mkdir(exist_ok=True)
        with open('.3ox/receipts.log', 'a', encoding='utf-8') as f:
            f.write(f"[{receipt['timestamp']}] {receipt['stage']} | {receipt['file']} | {receipt['hash']}\n")

# ============================================================================
# Trace Logger
# ============================================================================

class Trace:
    @staticmethod
    def log(event: str, data: Optional[Dict] = None):
        """Log event to trace.log"""
        Path('.3ox').mkdir(exist_ok=True)
        data_str = json.dumps(data) if data else ""
        with open('.3ox/trace.log', 'a', encoding='utf-8') as f:
            f.write(f"[{sirius_time_full()}] {event} | {data_str}\n")
    
    @staticmethod
    def agent_start(agent_name: str, session_id: str):
        """Log agent start"""
        Trace.log('AGENT_START', {'agent': agent_name, 'session': session_id})
    
    @staticmethod
    def agent_end(status: str, duration: Optional[str] = None, token_stats: Optional[Dict] = None):
        """Log agent end"""
        data = {'status': status}
        if duration:
            data['duration'] = duration
        if token_stats:
            data['tokens'] = token_stats
        Trace.log('AGENT_END', data)
    
    @staticmethod
    def tool_call(tool_name: str, input_data: str):
        """Log tool call"""
        Trace.log('TOOL_CALL', {'tool': tool_name, 'input': input_data})
    
    @staticmethod
    def tool_result(result: str):
        """Log tool result"""
        Trace.log('TOOL_RESULT', {'result': result})
    
    @staticmethod
    def token_usage(stats: Dict):
        """Log token usage"""
        Trace.log('TOKEN_USAGE', {
            'total': stats['total_tokens'],
            'messages': stats['message_count'],
            'model': stats['model'],
            'utilization': f"{stats['utilization']}%"
        })
    
    @staticmethod
    def token_warning(message: str, stats: Dict):
        """Log token warning"""
        Trace.log('TOKEN_WARNING', {
            'warning': message,
            'current': stats['total_tokens'],
            'max': stats['max_tokens'],
            'utilization': f"{stats['utilization']}%"
        })

# ============================================================================
# FILE.MANIFEST.txt Management
# ============================================================================

class Manifest:
    MANIFEST_PATH = Path('0ut.3ox/FILE.MANIFEST.txt')
    
    @staticmethod
    def initialize():
        """Initialize FILE.MANIFEST.txt with header"""
        Manifest.MANIFEST_PATH.parent.mkdir(exist_ok=True)
        
        if not Manifest.MANIFEST_PATH.exists():
            header = f"""# FILE.MANIFEST.txt
# .3ox Framework Output Manifest
# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
# Format: [timestamp] | status | filename | destination | priority
# ============================================================================

"""
            with open(Manifest.MANIFEST_PATH, 'w', encoding='utf-8') as f:
                f.write(header)
    
    @staticmethod
    def add(filename: str, destination: str, status: str = "READY", priority: str = "MEDIUM"):
        """Add entry to manifest"""
        Manifest.initialize()
        
        timestamp = sirius_time()
        entry = f"[{timestamp}] | {status:8} | {filename:40} | {destination:20} | {priority}\n"
        
        with open(Manifest.MANIFEST_PATH, 'a', encoding='utf-8') as f:
            f.write(entry)
    
    @staticmethod
    def read() -> List[str]:
        """Read all manifest entries"""
        if not Manifest.MANIFEST_PATH.exists():
            return []
        
        with open(Manifest.MANIFEST_PATH, 'r') as f:
            lines = f.readlines()
        
        # Filter out comments and headers
        return [line for line in lines if line.strip() and not line.startswith('#')]
    
    @staticmethod
    def get_stats() -> Dict:
        """Get manifest statistics"""
        entries = Manifest.read()
        
        statuses = {}
        destinations = {}
        
        for entry in entries:
            parts = entry.split('|')
            if len(parts) >= 3:
                status = parts[1].strip()
                dest = parts[3].strip() if len(parts) > 3 else "UNKNOWN"
                
                statuses[status] = statuses.get(status, 0) + 1
                destinations[dest] = destinations.get(dest, 0) + 1
        
        return {
            "total_entries": len(entries),
            "by_status": statuses,
            "by_destination": destinations
        }

# ============================================================================
# Router & Handoffs
# ============================================================================

class Router:
    ROUTES = {
        "critical_error": "CMD.BRIDGE",
        "deploy_ready": "SYNTH.BASE",
        "knowledge_update": "OBSIDIAN.BASE/LIGHTHOUSE",
        "sync_request": "RVNx.BASE",
        "library_update": "OBSIDIAN.BASE",
        "emergency": "CMD.BRIDGE/EMERGENCY"
    }
    
    @staticmethod
    def handoff(trigger: str, payload: Optional[Dict] = None) -> Dict:
        """Create handoff package"""
        destination = Router.ROUTES.get(trigger)
        if not destination:
            raise ValueError(f"Unknown routing trigger: {trigger}")
        
        package = {
            "from": os.environ.get("STATION_ID", "OPS.STATION"),
            "to": destination,
            "trigger": trigger,
            "payload": payload or {},
            "timestamp": sirius_time(),
            "receipt": Receipt.generate(str(payload), "HANDOFF")
        }
        
        Router._ship_package(package)
        Router._log_handoff(package)
        
        return package
    
    @staticmethod
    def _ship_package(package: Dict):
        """Ship package to 0ut.3ox/"""
        output_dir = Path('0ut.3ox')
        output_dir.mkdir(exist_ok=True)
        
        timestamp = int(datetime.now().timestamp())
        filename = f"handoff_{package['trigger']}_{timestamp}.json"
        filepath = output_dir / filename
        
        with open(filepath, 'w') as f:
            json.dump(package, f, indent=2)
        
        # Add to manifest
        Manifest.add(filename, package['to'], 'READY', 'HIGH')
    
    @staticmethod
    def _log_handoff(package: Dict):
        """Log handoff to trace"""
        Trace.log('HANDOFF', {
            'trigger': package['trigger'],
            'to': package['to']
        })

# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("="*80)
    print(".3OX FRAMEWORK RUNTIME - PYTHON IMPLEMENTATION")
    print("="*80)
    
    # Initialize session
    session = Session('test_001', 'claude-sonnet-4')
    Trace.agent_start('OVERSEER', 'test_001')
    
    # Add context
    session.add('user', 'Check station status and validate outputs')
    session.add('agent', 'Validating file integrity and checking for conflicts...')
    session.add('user', 'Generate receipt and manifest')
    session.add('agent', 'Receipt generated. Updating FILE.MANIFEST.txt...')
    
    # Display stats
    stats = session.get_token_stats()
    print(f"\n📊 Token Stats:")
    print(f"   Total: {stats['total_tokens']} tokens")
    print(f"   Messages: {stats['message_count']}")
    print(f"   Model: {stats['model']}")
    print(f"   Utilization: {stats['utilization']}%")
    print(f"   Method: {stats['counting_method']}")
    
    # Initialize manifest
    Manifest.initialize()
    Manifest.add("STATUS_REPORT_2025-10-10.md", "OPS.STATION", "READY", "HIGH")
    Manifest.add("PRE_FLIGHT_REPORT.md", "OPS.STATION", "READY", "MEDIUM")
    
    print(f"\n📄 FILE.MANIFEST.txt:")
    manifest_stats = Manifest.get_stats()
    print(f"   Total entries: {manifest_stats['total_entries']}")
    print(f"   By status: {manifest_stats['by_status']}")
    
    # Generate receipt
    receipt = Receipt.generate(__file__, 'INIT')
    print(f"\n🧾 Receipt: {receipt['hash'][:16]}...")
    
    # Save session
    session.save()
    Trace.agent_end('success', '2.3s', stats)
    
    print("\n✅ Runtime test complete! Check .3ox/ for logs:")
    print("   - .3ox/session.json")
    print("   - .3ox/receipts.log")
    print("   - .3ox/trace.log")
    print("   - 0ut.3ox/FILE.MANIFEST.txt")
    print("="*80)

