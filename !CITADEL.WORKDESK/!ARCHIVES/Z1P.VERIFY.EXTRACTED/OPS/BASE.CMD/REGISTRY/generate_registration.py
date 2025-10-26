#!/usr/bin/env python3
"""
3OX Registration Package Generator
Generates cryptographic identity and registration package for new .3ox folders

Usage:
    python generate_registration.py --request NEWSTATION.registration.request.yaml
    
Generates:
    - Cryptographic key pair (Ed25519)
    - Registration package with upload link
    - Updates STATION.REGISTRY.yaml
"""

import yaml
import hashlib
import secrets
from pathlib import Path
from datetime import datetime, timedelta
from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization
import argparse

class RegistrationGenerator:
    def __init__(self, request_file):
        self.request_file = Path(request_file)
        self.request_data = self.load_request()
        self.entity_name = self.request_data['entity_information']['name']
        
    def load_request(self):
        """Load registration request YAML"""
        with open(self.request_file, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    
    def get_sirius_time(self):
        """Calculate current Sirius time"""
        sirius_start = datetime(2025, 8, 8)
        now = datetime.now()
        days = (now - sirius_start).days
        year = now.year % 100
        return f"⧗-{year}.{days}"
    
    def generate_keys(self):
        """Generate Ed25519 key pair"""
        print(f"🔑 Generating cryptographic identity for {self.entity_name}...")
        
        # Generate Ed25519 key pair (modern, secure, fast)
        private_key = ed25519.Ed25519PrivateKey.generate()
        public_key = private_key.public_key()
        
        # Serialize private key
        private_pem = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        # Serialize public key
        public_pem = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        
        # Generate fingerprint (unique ID)
        fingerprint = hashlib.sha256(public_pem).hexdigest()[:16]
        
        print(f"✅ Generated Ed25519 key pair")
        print(f"   Fingerprint: {fingerprint}")
        
        return {
            'private_pem': private_pem.decode('utf-8'),
            'public_pem': public_pem.decode('utf-8'),
            'fingerprint': fingerprint
        }
    
    def generate_upload_credentials(self):
        """Generate one-time upload link and secret"""
        upload_secret = secrets.token_urlsafe(32)
        upload_link = f"https://cmd.3ox.ai/register/{upload_secret}"
        expiration = datetime.now() + timedelta(hours=24)
        
        return {
            'upload_secret': upload_secret,
            'upload_link': upload_link,
            'expiration': expiration.isoformat()
        }
    
    def create_registration_package(self, keys, upload_creds):
        """Create complete registration package"""
        sirius_now = self.get_sirius_time()
        sirius_expire = self.calculate_expiration(365)  # 1 year
        
        package = {
            'package_metadata': {
                'package_id': f"PKG-{self.request_data['request_metadata']['request_id']}",
                'generated_for': self.entity_name,
                'generated_by': 'CMD.BRIDGE',
                'generated_date': sirius_now,
                'expires_date': f"{sirius_now} + 24hrs",
                'status': 'ACTIVE'
            },
            'upload_credentials': {
                'upload_link': upload_creds['upload_link'],
                'upload_secret': upload_creds['upload_secret'],
                'valid_until': upload_creds['expiration'],
                'instructions': self.get_upload_instructions()
            },
            'cryptographic_identity': {
                'fingerprint': keys['fingerprint'],
                'public_key_pem': keys['public_pem'],
                'private_key_pem': keys['private_pem'],
                'key_algorithm': 'Ed25519',
                'key_strength': '256-bit',
                'expires': sirius_expire
            },
            'installation_instructions': self.get_installation_instructions(keys['fingerprint']),
            'handshake_protocol': {
                'challenge_response': {
                    'description': 'CMD issues challenge, station signs with private key',
                    'algorithm': 'Ed25519 signature'
                },
                'verification': {
                    'cmd_verifies': 'Signature with stored public key',
                    'success': 'Activate tx/rx capabilities',
                    'failure': 'Reject and alert'
                }
            },
            'security_warnings': [
                'NEVER share your private key (IDENTITY.key)',
                'Upload link is one-time use only',
                'Private key grants full tx/rx authority',
                'Report compromise immediately to CMD',
                'Keys expire in 1 year - renewal required'
            ]
        }
        
        return package
    
    def calculate_expiration(self, days):
        """Calculate Sirius time expiration"""
        # Simplified - add days to current Sirius time
        return f"⧗-[+{days}d]"
    
    def get_upload_instructions(self):
        return """1. Visit upload link above (one-time use)
2. Link expires in 24 hours
3. Upload will fail if link already used
4. Contact CMD if link expired"""
    
    def get_installation_instructions(self, fingerprint):
        return {
            'step_1_create_structure': f"""Create the following folder structure:

{self.entity_name}/
├── .3ox/
│   ├── IDENTITY.key       ← Install private key here
│   ├── IDENTITY.pub       ← Install public key here
│   └── registration.yaml  ← Save this package here
├── 0ut.3ox/
│   ├── FILE.MANIFEST.txt
│   └── .SENT/
└── 1n.3ox/  (if STATION)""",
            
            'step_2_install_keys': f"""Copy cryptographic keys to .3ox folder:

# Save private key
cat > {self.entity_name}/.3ox/IDENTITY.key << 'EOF'
[paste private_key_pem from above]
EOF

# Save public key
cat > {self.entity_name}/.3ox/IDENTITY.pub << 'EOF'
[paste public_key_pem from above]
EOF

# Set restrictive permissions (Linux/Mac)
chmod 600 {self.entity_name}/.3ox/IDENTITY.key
chmod 644 {self.entity_name}/.3ox/IDENTITY.pub""",
            
            'step_3_handshake': f"""Initiate registration handshake with CMD:

python 3OX.Ai/.3ox.index/OPS/BASE.CMD/REGISTRY/register_handshake.py \\
  --entity {self.entity_name} \\
  --fingerprint {fingerprint}

This will:
- Prove you possess the private key
- Verify identity with CMD
- Activate tx/rx capabilities""",
            
            'step_4_verify': """Verify registration successful:

# Check STATION.REGISTRY.yaml for your entry
cat 3OX.Ai/.3ox.index/OPS/BASE.CMD/REGISTRY/STATION.REGISTRY.yaml

# Should show:
# - entity_name: [ENTITY-NAME]
# - status: ACTIVE
# - fingerprint: [your fingerprint]"""
        }
    
    def save_package(self, package):
        """Save registration package to file"""
        package_dir = Path(__file__).parent / "PACKAGES"
        package_dir.mkdir(exist_ok=True)
        
        package_file = package_dir / f"{self.entity_name}.registration.package.yaml"
        
        with open(package_file, 'w', encoding='utf-8') as f:
            f.write("///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂\n")
            f.write("# .3OX REGISTRATION PACKAGE\n")
            f.write("# CONFIDENTIAL - DO NOT SHARE\n")
            f.write("# One-time use only\n")
            f.write("///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂\n\n")
            yaml.dump(package, f, default_flow_style=False, allow_unicode=True)
            f.write("\n///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙\n")
        
        print(f"📦 Registration package saved: {package_file}")
        return package_file
    
    def save_public_key(self, public_pem, fingerprint):
        """Save public key to KEYS directory"""
        keys_dir = Path(__file__).parent / "KEYS"
        keys_dir.mkdir(exist_ok=True)
        
        key_file = keys_dir / f"{self.entity_name}.pub"
        
        with open(key_file, 'w', encoding='utf-8') as f:
            f.write(public_pem)
        
        print(f"🔑 Public key saved: {key_file}")
        return key_file
    
    def update_registry(self, fingerprint, package_file):
        """Update STATION.REGISTRY.yaml with new entry"""
        registry_file = Path(__file__).parent / "STATION.REGISTRY.yaml"
        
        # Load existing registry
        if registry_file.exists():
            with open(registry_file, 'r', encoding='utf-8') as f:
                registry = yaml.safe_load(f) or {}
        else:
            registry = {'stations': []}
        
        # Create new entry
        new_entry = {
            'entity_name': self.entity_name,
            'entity_type': self.request_data['entity_information']['type'],
            'stratos_level': self.request_data['entity_information']['stratos_level'],
            'status': 'PENDING_HANDSHAKE',
            'registration': {
                'request_id': self.request_data['request_metadata']['request_id'],
                'approved_by': 'CMD Operator',
                'approval_date': self.get_sirius_time(),
                'activation_date': None
            },
            'cryptographic_identity': {
                'fingerprint': fingerprint,
                'public_key_file': f"KEYS/{self.entity_name}.pub",
                'key_algorithm': 'Ed25519',
                'key_expires': self.calculate_expiration(365)
            },
            'paths': {
                'station_root': f"P:/!CMD.BRIDGE/{self.entity_name}",
                'identity_key': f"{self.entity_name}/.3ox/IDENTITY.key",
                'output_folder': f"{self.entity_name}/0ut.3ox",
                'manifest_file': f"{self.entity_name}/0ut.3ox/FILE.MANIFEST.txt"
            },
            'routing': {
                'destination': f"!BASE.OPERATIONS/INCOMING/{self.entity_name.lower()}",
                'priority': self.request_data['operational_details'].get('priority', 'MEDIUM'),
                'rate_limit': '100/hour'
            },
            'operational': {
                'enabled': False,  # Will enable after handshake
                'last_handshake': None,
                'last_transaction': None,
                'total_transactions': 0
            },
            'security': {
                'suspicious_activity': False,
                'failed_auth_attempts': 0,
                'last_security_event': None
            }
        }
        
        # Add to registry
        if 'stations' not in registry:
            registry['stations'] = []
        registry['stations'].append(new_entry)
        
        # Save updated registry
        with open(registry_file, 'w', encoding='utf-8') as f:
            yaml.dump(registry, f, default_flow_style=False, allow_unicode=True)
        
        print(f"📝 Registry updated: {registry_file}")
    
    def generate(self):
        """Complete registration generation process"""
        print(f"\n🚀 Generating Registration Package for {self.entity_name}")
        print("=" * 60)
        
        # Generate keys
        keys = self.generate_keys()
        
        # Generate upload credentials
        upload_creds = self.generate_upload_credentials()
        
        # Create package
        package = self.create_registration_package(keys, upload_creds)
        
        # Save package
        package_file = self.save_package(package)
        
        # Save public key
        self.save_public_key(keys['public_pem'], keys['fingerprint'])
        
        # Update registry
        self.update_registry(keys['fingerprint'], package_file)
        
        print("\n✅ Registration Package Generated Successfully!")
        print("=" * 60)
        print(f"📦 Package: {package_file}")
        print(f"🔗 Upload Link: {upload_creds['upload_link']}")
        print(f"⏰ Expires: {upload_creds['expiration']}")
        print(f"🔑 Fingerprint: {keys['fingerprint']}")
        print("\n📧 Send package to requester via secure channel")
        print("=" * 60)

def main():
    parser = argparse.ArgumentParser(
        description='Generate 3OX registration package for new .3ox folder'
    )
    parser.add_argument(
        '--request',
        required=True,
        help='Path to registration request YAML file'
    )
    
    args = parser.parse_args()
    
    try:
        generator = RegistrationGenerator(args.request)
        generator.generate()
    except Exception as e:
        print(f"❌ Error: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())



