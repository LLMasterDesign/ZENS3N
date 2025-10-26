#!/usr/bin/env python3
"""
SIMPLIFIED .3OX ACTIVATION (Personal Use)
For solo operator - no ticket queue, just direct activation

Usage:
    # Activate a new .3ox folder
    python simple_activate.py SYNTH.BASE
    
    # This generates keys and activates immediately
    # No waiting, no approval process
"""

import yaml
import hashlib
import secrets
from pathlib import Path
from datetime import datetime, timedelta
from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization
import sys

class SimpleActivator:
    def __init__(self, entity_name):
        self.entity_name = entity_name
        self.base_path = Path(f"P:/!CMD.BRIDGE/{entity_name}")
        self.registry_file = Path(__file__).parent / "STATION.REGISTRY.yaml"
        
    def get_sirius_time(self):
        """Calculate current Sirius time"""
        sirius_start = datetime(2025, 8, 8)
        now = datetime.now()
        days = (now - sirius_start).days
        year = now.year % 100
        return f"⧗-{year}.{days}"
    
    def generate_keys(self):
        """Generate Ed25519 key pair"""
        print(f"🔑 Generating crypto identity for {self.entity_name}...")
        
        private_key = ed25519.Ed25519PrivateKey.generate()
        public_key = private_key.public_key()
        
        private_pem = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        public_pem = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        
        fingerprint = hashlib.sha256(public_pem).hexdigest()[:16]
        
        return {
            'private_pem': private_pem,
            'public_pem': public_pem,
            'fingerprint': fingerprint
        }
    
    def create_folder_structure(self):
        """Create .3ox folder structure"""
        print(f"📁 Creating folder structure...")
        
        folders = [
            self.base_path / ".3ox",
            self.base_path / "0ut.3ox",
            self.base_path / "0ut.3ox" / ".SENT",
            self.base_path / "1n.3ox"  # If station
        ]
        
        for folder in folders:
            folder.mkdir(parents=True, exist_ok=True)
        
        # Create FILE.MANIFEST.txt
        manifest = self.base_path / "0ut.3ox" / "FILE.MANIFEST.txt"
        if not manifest.exists():
            manifest.write_text(f"""# FILE.MANIFEST.txt for {self.entity_name}
# Format: [TIMESTAMP] | STATUS | FILEPATH | DESTINATION | PRIORITY

# Example:
# [2025-10-07 14:00:00] | READY | report.yaml | INCOMING/{self.entity_name.lower()} | HIGH

# Add your files below:
""", encoding='utf-8')
        
        print(f"✅ Folder structure created at {self.base_path}")
    
    def install_keys(self, keys):
        """Install cryptographic keys to .3ox folder"""
        print(f"🔐 Installing cryptographic keys...")
        
        # Save private key
        private_key_file = self.base_path / ".3ox" / "IDENTITY.key"
        private_key_file.write_bytes(keys['private_pem'])
        
        # Save public key
        public_key_file = self.base_path / ".3ox" / "IDENTITY.pub"
        public_key_file.write_bytes(keys['public_pem'])
        
        # Save fingerprint
        fingerprint_file = self.base_path / ".3ox" / "FINGERPRINT.txt"
        fingerprint_file.write_text(f"Fingerprint: {keys['fingerprint']}\nGenerated: {self.get_sirius_time()}", encoding='utf-8')
        
        print(f"✅ Keys installed")
        print(f"   Private: {private_key_file}")
        print(f"   Public: {public_key_file}")
        print(f"   Fingerprint: {keys['fingerprint']}")
        
        # Also save to CMD registry KEYS folder
        registry_keys_dir = Path(__file__).parent / "KEYS"
        registry_keys_dir.mkdir(exist_ok=True)
        
        cmd_public_key = registry_keys_dir / f"{self.entity_name}.pub"
        cmd_public_key.write_bytes(keys['public_pem'])
        
        return cmd_public_key
    
    def update_registry(self, keys, public_key_path):
        """Add to STATION.REGISTRY.yaml"""
        print(f"📝 Updating registry...")
        
        # Load existing registry
        if self.registry_file.exists():
            with open(self.registry_file, 'r', encoding='utf-8') as f:
                registry = yaml.safe_load(f) or {}
        else:
            registry = {}
        
        if 'stations' not in registry:
            registry['stations'] = []
        
        # Create entry
        entry = {
            'entity_name': self.entity_name,
            'entity_type': 'STATION',
            'status': 'ACTIVE',  # Immediately active for personal use
            'registration': {
                'activated_by': 'simple_activate.py',
                'activation_date': self.get_sirius_time()
            },
            'cryptographic_identity': {
                'fingerprint': keys['fingerprint'],
                'public_key_file': f"KEYS/{self.entity_name}.pub",
                'key_algorithm': 'Ed25519',
                'key_expires': f"⧗-[+1y]"
            },
            'paths': {
                'station_root': str(self.base_path),
                'identity_key': f"{self.entity_name}/.3ox/IDENTITY.key",
                'output_folder': f"{self.entity_name}/0ut.3ox",
                'manifest_file': f"{self.entity_name}/0ut.3ox/FILE.MANIFEST.txt"
            },
            'routing': {
                'destination': f"!BASE.OPERATIONS/INCOMING/{self.entity_name.lower()}",
                'priority': 'MEDIUM',
                'enabled': True
            },
            'operational': {
                'enabled': True,
                'last_transaction': None,
                'total_transactions': 0
            }
        }
        
        # Check if already exists
        existing = False
        for i, station in enumerate(registry['stations']):
            if station['entity_name'] == self.entity_name:
                registry['stations'][i] = entry
                existing = True
                break
        
        if not existing:
            registry['stations'].append(entry)
        
        # Save registry
        with open(self.registry_file, 'w', encoding='utf-8') as f:
            yaml.dump(registry, f, default_flow_style=False, allow_unicode=True)
        
        print(f"✅ Registry updated")
    
    def create_agent_instructions(self):
        """Create instructions for Cursor agents"""
        instructions = self.base_path / ".3ox" / "AGENT.INSTRUCTIONS.md"
        
        content = f"""# Cursor Agent Instructions for {self.entity_name}

## 📡 How to Send Reports to CMD

When you have a breakthrough or complete 20 passes, send a report:

### Method 1: Quick Report (Automatic)
Just create a file in `0ut.3ox/` and add to manifest:

```bash
# 1. Create your report
cat > 0ut.3ox/status_report_{self.get_sirius_time()}.yaml << 'EOF'
type: status_report
station: {self.entity_name}
timestamp: {self.get_sirius_time()}
event: breakthrough
details: |
  [Describe what you accomplished]
EOF

# 2. Add to manifest
echo "[$(date '+%Y-%m-%d %H:%M:%S')] | READY | status_report_{self.get_sirius_time()}.yaml | INCOMING/{self.entity_name.lower()} | HIGH" >> 0ut.3ox/FILE.MANIFEST.txt

# 3. Done! Router will pick it up automatically
```

### Method 2: Let CMD Know Directly
If you need immediate attention:

```bash
# Create in BASE.OPERATIONS/INCOMING/{self.entity_name.lower()}/
# CMD monitors that folder
```

## 🔑 Your Cryptographic Identity

- **Fingerprint:** See `.3ox/FINGERPRINT.txt`
- **Private Key:** `.3ox/IDENTITY.key` (NEVER share this)
- **Public Key:** `.3ox/IDENTITY.pub`

## 📋 Reporting Triggers

Send a report when:
- ✅ Breakthrough accomplished
- ✅ 20 passes completed
- ✅ Error needs escalation
- ✅ Task completed
- ✅ Need CMD assistance

## 🎯 Report Format

```ruby
type: "status_report|breakthrough|error|completion"
station: "{self.entity_name}"
timestamp: "⧗-YY.DD"
event: "what happened"
details: |
  Detailed description
  Multiple lines OK
priority: "HIGH|MEDIUM|LOW"
```

---

**Status:** ✅ ACTIVE  
**Authorized:** {self.get_sirius_time()}
"""
        
        instructions.write_text(content, encoding='utf-8')
        print(f"📖 Agent instructions created: {instructions}")
    
    def activate(self):
        """Complete activation process"""
        print(f"\n{'='*60}")
        print(f"🚀 ACTIVATING {self.entity_name}")
        print(f"{'='*60}\n")
        
        # Generate keys
        keys = self.generate_keys()
        
        # Create folder structure
        self.create_folder_structure()
        
        # Install keys
        public_key_path = self.install_keys(keys)
        
        # Update registry
        self.update_registry(keys, public_key_path)
        
        # Create agent instructions
        self.create_agent_instructions()
        
        print(f"\n{'='*60}")
        print(f"✅ {self.entity_name} ACTIVATED!")
        print(f"{'='*60}")
        print(f"\n📊 Summary:")
        print(f"   Status: ACTIVE")
        print(f"   Fingerprint: {keys['fingerprint']}")
        print(f"   Location: {self.base_path}")
        print(f"   Agent Instructions: {self.base_path}/.3ox/AGENT.INSTRUCTIONS.md")
        print(f"\n🎯 Next Steps:")
        print(f"   1. Agents can now send reports to 0ut.3ox/")
        print(f"   2. Router will automatically process them")
        print(f"   3. Reports go to !BASE.OPERATIONS/INCOMING/{self.entity_name.lower()}/")
        print(f"\n{'='*60}\n")

def main():
    if len(sys.argv) < 2:
        print("Usage: python simple_activate.py ENTITY_NAME")
        print("Example: python simple_activate.py SYNTH.BASE")
        return 1
    
    entity_name = sys.argv[1]
    
    try:
        activator = SimpleActivator(entity_name)
        activator.activate()
        return 0
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    exit(main())

