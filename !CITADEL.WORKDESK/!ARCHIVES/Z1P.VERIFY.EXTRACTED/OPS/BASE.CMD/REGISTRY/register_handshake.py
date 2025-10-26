#!/usr/bin/env python3
"""
3OX Registration Handshake Protocol
Implements challenge-response authentication for .3ox folders

Usage (Station Side):
    python register_handshake.py --entity NEWSTATION.BASE --fingerprint abc123

Usage (CMD Side):
    python register_handshake.py --cmd --verify NEWSTATION.BASE

Implements:
    - Challenge-response authentication
    - Ed25519 signature verification
    - Registry activation
"""

import yaml
import json
import secrets
import hashlib
from pathlib import Path
from datetime import datetime, timedelta
from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization
from cryptography.exceptions import InvalidSignature
import argparse

class HandshakeProtocol:
    def __init__(self, entity_name, fingerprint=None, cmd_mode=False):
        self.entity_name = entity_name
        self.fingerprint = fingerprint
        self.cmd_mode = cmd_mode
        self.registry_file = Path(__file__).parent / "STATION.REGISTRY.yaml"
        self.handshake_log = Path(__file__).parent / "AUDIT" / "handshakes.log"
        
    def get_sirius_time(self):
        """Calculate current Sirius time"""
        sirius_start = datetime(2025, 8, 8)
        now = datetime.now()
        days = (now - sirius_start).days
        year = now.year % 100
        return f"⧗-{year}.{days}"
    
    def log_event(self, event_type, details):
        """Log handshake event to audit log"""
        self.handshake_log.parent.mkdir(exist_ok=True)
        
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'sirius_time': self.get_sirius_time(),
            'event_type': event_type,
            'entity': self.entity_name,
            'fingerprint': self.fingerprint,
            'details': details
        }
        
        with open(self.handshake_log, 'a', encoding='utf-8') as f:
            f.write(json.dumps(log_entry) + '\n')
    
    def load_registry(self):
        """Load station registry"""
        with open(self.registry_file, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    
    def save_registry(self, registry):
        """Save updated registry"""
        with open(self.registry_file, 'w', encoding='utf-8') as f:
            yaml.dump(registry, f, default_flow_style=False, allow_unicode=True)
    
    def find_entity_in_registry(self):
        """Find entity in registry by name or fingerprint"""
        registry = self.load_registry()
        
        for station in registry.get('stations', []):
            if station['entity_name'] == self.entity_name:
                if self.fingerprint:
                    if station['cryptographic_identity']['fingerprint'] == self.fingerprint:
                        return station
                else:
                    return station
        
        return None
    
    def load_private_key(self):
        """Load private key from entity's .3ox folder"""
        key_file = Path(f"P:/!CMD.BRIDGE/{self.entity_name}/.3ox/IDENTITY.key")
        
        if not key_file.exists():
            raise FileNotFoundError(f"Private key not found: {key_file}")
        
        with open(key_file, 'rb') as f:
            private_key = serialization.load_pem_private_key(
                f.read(),
                password=None
            )
        
        return private_key
    
    def load_public_key(self, pub_key_file):
        """Load public key from CMD registry"""
        key_path = Path(__file__).parent / pub_key_file
        
        if not key_path.exists():
            raise FileNotFoundError(f"Public key not found: {key_path}")
        
        with open(key_path, 'rb') as f:
            public_key = serialization.load_pem_public_key(f.read())
        
        return public_key
    
    # STATION SIDE: Initiate Handshake
    def station_initiate(self):
        """Station initiates handshake with CMD"""
        print(f"\n🤝 Initiating handshake for {self.entity_name}")
        print("=" * 60)
        
        # Step 1: Send HELLO
        hello_message = {
            'message': 'HELLO',
            'fingerprint': self.fingerprint,
            'entity_name': self.entity_name,
            'timestamp': self.get_sirius_time()
        }
        
        print(f"📡 Sending HELLO to CMD.BRIDGE")
        print(f"   Fingerprint: {self.fingerprint}")
        
        # Save hello message for CMD to process
        hello_file = Path(__file__).parent / "HANDSHAKES" / f"{self.entity_name}.hello.json"
        hello_file.parent.mkdir(exist_ok=True)
        
        with open(hello_file, 'w', encoding='utf-8') as f:
            json.dump(hello_message, f, indent=2)
        
        self.log_event("HELLO_SENT", hello_message)
        
        print(f"\n✅ HELLO message sent")
        print(f"📁 Saved to: {hello_file}")
        print("\n⏳ Waiting for CMD to issue challenge...")
        print("   Run this command on CMD side:")
        print(f"   python register_handshake.py --cmd --challenge {self.entity_name}")
        print("=" * 60)
    
    # CMD SIDE: Issue Challenge
    def cmd_issue_challenge(self):
        """CMD issues challenge to station"""
        print(f"\n🎯 Issuing challenge to {self.entity_name}")
        print("=" * 60)
        
        # Find entity in registry
        entity = self.find_entity_in_registry()
        if not entity:
            print(f"❌ Entity {self.entity_name} not found in registry")
            return False
        
        # Generate challenge (random nonce)
        nonce = secrets.token_bytes(32)
        challenge_id = secrets.token_hex(16)
        
        challenge_message = {
            'message': 'CHALLENGE',
            'nonce': nonce.hex(),
            'challenge_id': challenge_id,
            'expires': (datetime.now() + timedelta(minutes=5)).isoformat(),
            'fingerprint': entity['cryptographic_identity']['fingerprint']
        }
        
        # Save challenge for station to respond
        challenge_file = Path(__file__).parent / "HANDSHAKES" / f"{self.entity_name}.challenge.json"
        
        with open(challenge_file, 'w', encoding='utf-8') as f:
            json.dump(challenge_message, f, indent=2)
        
        self.log_event("CHALLENGE_ISSUED", {'challenge_id': challenge_id})
        
        print(f"✅ Challenge issued")
        print(f"   Challenge ID: {challenge_id}")
        print(f"   Nonce: {nonce.hex()[:32]}...")
        print(f"   Expires: 5 minutes")
        print(f"\n📁 Saved to: {challenge_file}")
        print("\n⏳ Station must respond with signed nonce...")
        print("   Station runs:")
        print(f"   python register_handshake.py --entity {self.entity_name} --respond")
        print("=" * 60)
        
        return True
    
    # STATION SIDE: Respond to Challenge
    def station_respond(self):
        """Station responds to CMD challenge"""
        print(f"\n🔐 Responding to CMD challenge")
        print("=" * 60)
        
        # Load challenge
        challenge_file = Path(__file__).parent / "HANDSHAKES" / f"{self.entity_name}.challenge.json"
        
        if not challenge_file.exists():
            print(f"❌ No challenge found. CMD must issue challenge first.")
            return False
        
        with open(challenge_file, 'r', encoding='utf-8') as f:
            challenge = json.load(f)
        
        # Check expiration
        expires = datetime.fromisoformat(challenge['expires'])
        if datetime.now() > expires:
            print(f"❌ Challenge expired. Request new challenge from CMD.")
            return False
        
        # Load private key
        try:
            private_key = self.load_private_key()
        except FileNotFoundError as e:
            print(f"❌ {e}")
            print("   Install IDENTITY.key from registration package first")
            return False
        
        # Sign the nonce
        nonce_bytes = bytes.fromhex(challenge['nonce'])
        signature = private_key.sign(nonce_bytes)
        
        # Create response
        response_message = {
            'message': 'RESPONSE',
            'challenge_id': challenge['challenge_id'],
            'signature': signature.hex(),
            'timestamp': self.get_sirius_time(),
            'fingerprint': self.fingerprint
        }
        
        # Save response for CMD to verify
        response_file = Path(__file__).parent / "HANDSHAKES" / f"{self.entity_name}.response.json"
        
        with open(response_file, 'w', encoding='utf-8') as f:
            json.dump(response_message, f, indent=2)
        
        self.log_event("RESPONSE_SENT", {'challenge_id': challenge['challenge_id']})
        
        print(f"✅ Response generated")
        print(f"   Challenge ID: {challenge['challenge_id']}")
        print(f"   Signature: {signature.hex()[:32]}...")
        print(f"\n📁 Saved to: {response_file}")
        print("\n⏳ Waiting for CMD to verify...")
        print("   CMD runs:")
        print(f"   python register_handshake.py --cmd --verify {self.entity_name}")
        print("=" * 60)
        
        return True
    
    # CMD SIDE: Verify Response
    def cmd_verify_response(self):
        """CMD verifies station's signed response"""
        print(f"\n✅ Verifying response from {self.entity_name}")
        print("=" * 60)
        
        # Load challenge
        challenge_file = Path(__file__).parent / "HANDSHAKES" / f"{self.entity_name}.challenge.json"
        if not challenge_file.exists():
            print(f"❌ No challenge found for {self.entity_name}")
            return False
        
        with open(challenge_file, 'r', encoding='utf-8') as f:
            challenge = json.load(f)
        
        # Load response
        response_file = Path(__file__).parent / "HANDSHAKES" / f"{self.entity_name}.response.json"
        if not response_file.exists():
            print(f"❌ No response found. Station must respond first.")
            return False
        
        with open(response_file, 'r', encoding='utf-8') as f:
            response = json.load(f)
        
        # Verify challenge IDs match
        if challenge['challenge_id'] != response['challenge_id']:
            print(f"❌ Challenge ID mismatch")
            self.log_event("VERIFICATION_FAILED", {'reason': 'challenge_id_mismatch'})
            return False
        
        # Find entity in registry
        entity = self.find_entity_in_registry()
        if not entity:
            print(f"❌ Entity not found in registry")
            return False
        
        # Load public key
        try:
            public_key = self.load_public_key(entity['cryptographic_identity']['public_key_file'])
        except FileNotFoundError as e:
            print(f"❌ {e}")
            return False
        
        # Verify signature
        nonce_bytes = bytes.fromhex(challenge['nonce'])
        signature_bytes = bytes.fromhex(response['signature'])
        
        try:
            public_key.verify(signature_bytes, nonce_bytes)
            print(f"🎉 Signature VALID!")
        except InvalidSignature:
            print(f"❌ Signature INVALID - Authentication failed")
            self.log_event("VERIFICATION_FAILED", {'reason': 'invalid_signature'})
            return False
        
        # SIGNATURE VERIFIED - Activate entity
        print(f"\n🚀 Activating {self.entity_name}...")
        
        # Update registry
        registry = self.load_registry()
        for station in registry['stations']:
            if station['entity_name'] == self.entity_name:
                station['status'] = 'ACTIVE'
                station['registration']['activation_date'] = self.get_sirius_time()
                station['operational']['enabled'] = True
                station['operational']['last_handshake'] = self.get_sirius_time()
                break
        
        self.save_registry(registry)
        
        self.log_event("HANDSHAKE_COMPLETE", {'status': 'ACTIVATED'})
        
        # Create welcome message
        welcome_message = {
            'message': 'WELCOME',
            'status': 'AUTHORIZED',
            'tx_rx_enabled': True,
            'activation_date': self.get_sirius_time()
        }
        
        welcome_file = Path(__file__).parent / "HANDSHAKES" / f"{self.entity_name}.welcome.json"
        with open(welcome_file, 'w', encoding='utf-8') as f:
            json.dump(welcome_message, f, indent=2)
        
        print(f"✅ {self.entity_name} is now ACTIVE")
        print(f"   Status: AUTHORIZED")
        print(f"   TX/RX: ENABLED")
        print(f"   Activation: {self.get_sirius_time()}")
        print(f"\n📝 Registry updated")
        print(f"🎊 HANDSHAKE COMPLETE - Entity is operational!")
        print("=" * 60)
        
        # Clean up handshake files
        for f in [challenge_file, response_file]:
            if f.exists():
                f.unlink()
        
        return True

def main():
    parser = argparse.ArgumentParser(
        description='3OX Registration Handshake Protocol'
    )
    parser.add_argument('--entity', help='Entity name (e.g., NEWSTATION.BASE)')
    parser.add_argument('--fingerprint', help='Cryptographic fingerprint')
    parser.add_argument('--cmd', action='store_true', help='CMD mode')
    parser.add_argument('--challenge', metavar='ENTITY', help='CMD: Issue challenge to entity')
    parser.add_argument('--verify', metavar='ENTITY', help='CMD: Verify response from entity')
    parser.add_argument('--respond', action='store_true', help='Station: Respond to challenge')
    
    args = parser.parse_args()
    
    try:
        if args.cmd:
            # CMD MODE
            if args.challenge:
                # Issue challenge
                protocol = HandshakeProtocol(args.challenge, cmd_mode=True)
                success = protocol.cmd_issue_challenge()
            elif args.verify:
                # Verify response
                protocol = HandshakeProtocol(args.verify, cmd_mode=True)
                success = protocol.cmd_verify_response()
            else:
                print("❌ CMD mode requires --challenge or --verify")
                return 1
        else:
            # STATION MODE
            if not args.entity or not args.fingerprint:
                if args.respond:
                    # Respond to challenge
                    if not args.entity:
                        print("❌ --entity required")
                        return 1
                    protocol = HandshakeProtocol(args.entity)
                    success = protocol.station_respond()
                else:
                    print("❌ Station mode requires --entity and --fingerprint")
                    return 1
            else:
                # Initiate handshake
                protocol = HandshakeProtocol(args.entity, args.fingerprint)
                success = protocol.station_initiate()
        
        return 0 if success else 1
    
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    exit(main())



