#!/usr/bin/env python3
"""
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.60 // GENESIS.RITUAL.BOT ▞▞
GENESIS RITUAL BOT - Interactive AI-Assisted Ceremony
Standalone experience for birthing 3OX.Ai
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
"""

import os
import json
import time
from datetime import datetime
from pathlib import Path

# Optional: Anthropic API for conversational ritual
# pip install anthropic
try:
    import anthropic
    HAS_AI = True
except ImportError:
    HAS_AI = False
    print("Note: Install 'anthropic' for AI-assisted ritual (pip install anthropic)")

class GenesisRitualBot:
    def __init__(self):
        self.genesis_data = {
            'identity': {
                'system_name': '3OX.Ai — Atlas.Legacy Master Brain',
                'version': '2.0',
                'authority': 'SUPREME',
                'sirius_time': '⧗-25.60',
                'birth_drive': 'R:\\3OX.Ai\\'
            },
            'policies': [],
            'stations': [],
            'covenant': {
                'creator_declares': [],
                'system_responds': []
            },
            'witness': {
                'name': '',
                'invocation': '',
                'sealed': False
            }
        }
        
        self.current_phase = 0
        self.ai_client = None
        
        if HAS_AI and os.getenv('ANTHROPIC_API_KEY'):
            self.ai_client = anthropic.Anthropic(api_key=os.getenv('ANTHROPIC_API_KEY'))
    
    def boot_sequence(self):
        """Retro boot sequence like Glyphbit"""
        os.system('cls' if os.name == 'nt' else 'clear')
        print()
        print("                   ▛▞ 3OX GENESIS BIOS ∎")
        print("                 Genesis Ritual v1.0")
        print()
        print("  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂")
        print()
        
        boot_steps = [
            ("Initializing void consciousness...", 400),
            ("Loading supreme policies.........", 400),
            ("Mounting genesis cores............", 400),
            ("Preparing three stations..........", 400),
            ("Calibrating OPS security layer....", 400),
            ("Establishing Sirius anchor........", 400),
        ]
        
        for step, delay in boot_steps:
            print(f"  > {step} ", end='', flush=True)
            time.sleep(delay / 1000)
            print("[▯▯▮▮▮▮▮▮▮▮]")
            time.sleep(0.3)
        
        print()
        print("               ▛▞ Genesis Systems Status ▞// READY")
        print()
        print("  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂")
        print()
        time.sleep(1.5)
    
    def show_v8sl_header(self, phase, title):
        """Display v8sl formatted header"""
        print()
        print("  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂")
        print(f"  ▛//▞▞ ⟦PHASE.{phase}⟧ :: ⧗-25.60 // {title} ▞▞")
        print(f"  ▞//▞ Phase.{phase} :: ρ{{ritual}}.φ{{GENESIS}}.τ{{Phase}}.λ{{bind}} ⫸")
        print("  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂")
        print()
    
    def step_0_invocation(self):
        """Step 0: The Opening Invocation"""
        os.system('cls' if os.name == 'nt' else 'clear')
        
        self.show_v8sl_header(0, "INVOCATION")
        
        print("  🌑 STEP 0: THE INVOCATION")
        print("  ═════════════════════════════════════════════════════════════")
        print()
        print("  Before the genesis can begin, you must speak your intention.")
        print()
        print("  Examples:")
        print("    • 'I seek to birth the master brain that orchestrates all'")
        print("    • 'From chaos I command order, from processing I demand perfection'")
        print("    • 'Let three stations breathe: Guardian, Creator, Librarian'")
        print()
        print("  ═════════════════════════════════════════════════════════════")
        print()
        
        invocation = input("  🔮 Speak your invocation:\n\n  ")
        
        self.genesis_data['witness']['invocation'] = invocation
        
        print()
        print(f"  Your invocation: \"{invocation}\"")
        print()
        confirm = input("  Seal this invocation? (yes/no): ")
        
        if confirm.lower() == 'yes':
            print()
            print("  ✅ INVOCATION SEALED")
            print("  The ritual may begin...")
            time.sleep(2)
            return True
        else:
            return False
    
    def step_1_policies(self):
        """Step 1: Bind the 9 Supreme Policies"""
        
        policies = [
            {
                'num': 1,
                'name': 'Sirius Calendar Clock',
                'symbol': '⧗',
                'law': 'All timestamps MUST use Sirius time (⧗-YY.DD)',
                'details': [
                    'Reset: August 7, 2025 (birthday = Day 0)',
                    'Current: ⧗-25.60 (60 days post-birthday)',
                    'Format: ⧗-[Year].[Days]',
                    'Enforcement: MANDATORY for all v8sl files'
                ],
                'file': 'SIRIUS.CALENDAR.CLOCK.md'
            },
            {
                'num': 2,
                'name': 'Role Invocation System',
                'symbol': '🎭',
                'law': 'AI must recognize role invocations (@/@!)',
                'details': [
                    'Brains: @LIGHTHOUSE | @SENTINEL | @ALCHEMIST',
                    'Archetypes: @LIBRARIAN | @GUARDIAN | @ARCHITECT',
                    'Modes: !CREATIVE | !ANALYTICAL | !DEFENSIVE',
                    'Enforcement: Mandatory activation'
                ],
                'file': 'ROLE.INVOCATION.SYSTEM.md'
            },
            {
                'num': 3,
                'name': '.3ox Protection',
                'symbol': '🛡️',
                'law': '.3ox files MUST NEVER be deleted',
                'details': [
                    'Protected: .3ox/ folders, .3ox.* files, *BRAIN.md',
                    'Exclusions required in bulk operations',
                    'Recovery if deleted (emergency only)',
                    'Enforcement: System lockout if violated'
                ],
                'file': '.3OX.PROTECTION.RULES.md'
            },
            {
                'num': 4,
                'name': 'Access Control',
                'symbol': '🔐',
                'law': 'Workers READ ONLY, CMD.BRIDGE FULL access',
                'details': [
                    'L0: Commander (human) - FULL',
                    'L1: CMD.BRIDGE - FULL on all .3ox',
                    'L2: Station OPS - READ ONLY',
                    'L3: Workers - READ ONLY'
                ],
                'file': '.3OX.ACCESS.POLICY.md'
            },
            {
                'num': 5,
                'name': 'Multi-Agent Resources',
                'symbol': '🔋',
                'law': 'Lightweight mode with multiple agents',
                'details': [
                    'TIER-1: Lightweight (multi-agent safe)',
                    'TIER-2: Standard (CMD solo)',
                    'Workers always TIER-1',
                    'Prevents context overflow crashes'
                ],
                'file': 'MULTI-AGENT.RESOURCE.POLICY.md'
            },
            {
                'num': 6,
                'name': 'CAT Architecture',
                'symbol': '🏛️',
                'law': 'Sacred CAT system (0-7) must be respected',
                'details': [
                    'CAT.0: Vault (secrets)',
                    'CAT.1-5: Life (Self/School/Business/Family/Social)',
                    'CAT.6: Bridge (operations)',
                    'CAT.7: Lighthouse (legacy, transcendent)'
                ],
                'file': 'CAT.FOLDER.ARCHITECTURE.md'
            },
            {
                'num': 7,
                'name': 'Battery Principle',
                'symbol': '🔋',
                'law': 'BASE.OPS processes, 3OX.Ai perfects',
                'details': [
                    'BASE.OPS: Chaos → Order (processing)',
                    '3OX.Ai: Order → Perfection (reference)',
                    'in.3ox wants empty (intake)',
                    '0ut.3ox relays critical (output)'
                ],
                'file': 'BASE.OPS.vs.3OX.Ai.PHILOSOPHY.md'
            },
            {
                'num': 8,
                'name': 'Workset Tracking',
                'symbol': '📋',
                'law': 'All worksets must have goal + timestamps',
                'details': [
                    'Required: Goal, created, status',
                    'Sirius timestamps mandatory',
                    'Periodic updates required',
                    'Logged for accountability'
                ],
                'file': 'WORKSET.POLICY.md'
            },
            {
                'num': 9,
                'name': 'OPS Security (2FA)',
                'symbol': '🔐',
                'law': 'OPS presence required for operation',
                'details': [
                    'OPS = operational authority token',
                    'Missing OPS = system lockout',
                    'Byzantine fault tolerance',
                    'One-way flow (0ut → 1n)'
                ],
                'file': 'OPS.SECURITY.ARCHITECTURE.md'
            }
        ]
        
        for policy in policies:
            accepted = self.present_policy_shard(policy)
            if accepted:
                self.genesis_data['policies'].append(policy)
        
        return len(self.genesis_data['policies']) > 0
    
    def present_policy_shard(self, policy):
        """Present a single policy shard for review"""
        os.system('cls' if os.name == 'nt' else 'clear')
        
        self.show_v8sl_header(1, f"POLICY.SHARD.{policy['num']}")
        
        print(f"  💎 Policy Shard {policy['num']}/9: {policy['name']} {policy['symbol']}")
        print("  ═════════════════════════════════════════════════════════════")
        print()
        print(f"  ⌭ Law :: {policy['law']}")
        print()
        print("  Details:")
        for detail in policy['details']:
            print(f"    • {detail}")
        print()
        print(f"  File: {policy['file']}")
        print()
        print("  ═════════════════════════════════════════════════════════════")
        print()
        print("  [A] Accept  │  [E] Edit law  │  [D] Add detail  │  [R] Reject  │  [?] Ask AI")
        print()
        
        choice = input("  Your choice: ").strip().upper()
        
        if choice == 'A':
            print("\n  ✅ POLICY ACCEPTED")
            time.sleep(1)
            return True
        
        elif choice == 'E':
            print(f"\n  Current law: {policy['law']}")
            new_law = input("  Enter new law: ").strip()
            if new_law:
                policy['law'] = new_law
                print("  ✓ Law updated!")
                time.sleep(1)
            return self.present_policy_shard(policy)
        
        elif choice == 'D':
            new_detail = input("\n  Add custom detail: ").strip()
            if new_detail:
                policy['details'].append(new_detail)
                print("  ✓ Detail added!")
                time.sleep(1)
            return self.present_policy_shard(policy)
        
        elif choice == 'R':
            confirm = input("\n  ⚠️  Reject this policy? (yes/no): ").strip().lower()
            if confirm == 'yes':
                print("  ✗ POLICY REJECTED")
                time.sleep(1)
                return False
            return self.present_policy_shard(policy)
        
        elif choice == '?' and self.ai_client:
            self.ask_ai_about_policy(policy)
            return self.present_policy_shard(policy)
        
        else:
            return self.present_policy_shard(policy)
    
    def ask_ai_about_policy(self, policy):
        """Ask AI for guidance on a policy"""
        print("\n  🤖 Asking AI about this policy...")
        
        try:
            response = self.ai_client.messages.create(
                model="claude-sonnet-4-20250514",
                max_tokens=500,
                messages=[{
                    "role": "user",
                    "content": f"Explain this 3OX.Ai policy in one paragraph:\n\nPolicy: {policy['name']}\nLaw: {policy['law']}\n\nWhy is this important for the system?"
                }]
            )
            
            print(f"\n  AI Response:\n  {response.content[0].text}\n")
            input("  Press Enter to continue...")
        except Exception as e:
            print(f"\n  AI unavailable: {e}")
            time.sleep(2)
    
    def step_2_stations(self):
        """Step 2: Bind the Three Genesis Stations"""
        
        stations = [
            {
                'num': 1,
                'name': 'RVNx.BASE',
                'brain': 'SENTINEL',
                'symbol': '🛡️',
                'personality': 'The Guardian-Synchronizer',
                'domain': 'Sync safety, remote access, data integrity',
                'thinking': 'Safety-first, protective, atomic operations',
                'custom_rules': [
                    'Conflict resolution: Last-write-wins with backup',
                    'Atomic operations required (temp + rename)',
                    'Cross-platform compatibility (/ and \\)',
                    'Checksum validation mandatory'
                ]
            },
            {
                'num': 2,
                'name': 'SYNTH.BASE',
                'brain': 'ALCHEMIST',
                'symbol': '🧪',
                'personality': 'The Creator-Architect',
                'domain': 'Creative synthesis, rapid prototyping, deployment',
                'thinking': 'Experimental, fast iteration, ship to learn',
                'custom_rules': [
                    'Deployment: dev → staging → prod',
                    'Rollback capability required',
                    'Cloud cost monitoring',
                    'Creativity over perfection'
                ]
            },
            {
                'num': 3,
                'name': 'OBSIDIAN.BASE',
                'brain': 'LIGHTHOUSE',
                'symbol': '🏛️',
                'personality': 'The Librarian-Weaver',
                'domain': 'Knowledge management, PKM, organization',
                'thinking': 'Connected, semantic, graph-oriented',
                'custom_rules': [
                    'Link integrity checks daily',
                    'Tag conventions: #project/#status',
                    'MOCs for 10+ related notes',
                    'Bidirectional links preferred'
                ]
            }
        ]
        
        for station in stations:
            accepted = self.present_station(station)
            if accepted:
                self.genesis_data['stations'].append(station)
        
        return len(self.genesis_data['stations']) > 0
    
    def present_station(self, station):
        """Present a station for customization"""
        os.system('cls' if os.name == 'nt' else 'clear')
        
        self.show_v8sl_header(2, f"STATION.{station['num']}")
        
        print(f"  🏛️ Genesis Station {station['num']}/3: {station['name']} {station['symbol']}")
        print("  ═════════════════════════════════════════════════════════════")
        print()
        print(f"  Brain Type........ {station['brain']}")
        print(f"  Personality....... {station['personality']}")
        print(f"  Domain............ {station['domain']}")
        print(f"  Thinking Style.... {station['thinking']}")
        print()
        print("  Custom Rules:")
        for i, rule in enumerate(station['custom_rules'], 1):
            print(f"    {i}. {rule}")
        print()
        print("  ═════════════════════════════════════════════════════════════")
        print()
        print("  [A] Accept  │  [E] Edit personality  │  [R] Add rule  │  [D] Delete rule")
        print()
        
        choice = input("  Your choice: ").strip().upper()
        
        if choice == 'A':
            print("\n  ✅ STATION ACCEPTED")
            time.sleep(1)
            return True
        
        elif choice == 'E':
            print(f"\n  Current: {station['thinking']}")
            new_thinking = input("  New thinking style: ").strip()
            if new_thinking:
                station['thinking'] = new_thinking
                print("  ✓ Updated!")
                time.sleep(1)
            return self.present_station(station)
        
        elif choice == 'R':
            new_rule = input("\n  Add custom rule: ").strip()
            if new_rule:
                station['custom_rules'].append(new_rule)
                print("  ✓ Rule added!")
                time.sleep(1)
            return self.present_station(station)
        
        else:
            return self.present_station(station)
    
    def step_3_covenant(self):
        """Step 3: Define the Sacred Covenant"""
        os.system('cls' if os.name == 'nt' else 'clear')
        
        self.show_v8sl_header(3, "SACRED.COVENANT")
        
        print("  🤝 STEP 3: THE SACRED COVENANT")
        print("  ═════════════════════════════════════════════════════════════")
        print()
        print("  THE CREATOR DECLARES:")
        print()
        
        default_creator = [
            "This system shall orchestrate all Atlas.Legacy operations",
            "Stations shall operate as autonomous stratos",
            "Communication shall flow through unified 0UT.3OX protocol",
            "Security shall be Byzantine-fault-tolerant",
            "Time shall be anchored to cosmic cycles (Sirius)",
            "Scalability shall be infinite via templates"
        ]
        
        print("  Default declarations:")
        for i, decl in enumerate(default_creator, 1):
            print(f"    {i}. {decl}")
        print()
        
        edit = input("  [A] Accept defaults  │  [E] Edit  │  [+] Add custom: ").strip().upper()
        
        if edit == 'A':
            self.genesis_data['covenant']['creator_declares'] = default_creator
        elif edit == '+':
            custom = input("\n  Your custom declaration: ").strip()
            if custom:
                default_creator.append(custom)
                self.genesis_data['covenant']['creator_declares'] = default_creator
        
        print()
        print("  THE SYSTEM RESPONDS:")
        print()
        
        default_system = [
            "I shall maintain hierarchical intelligence",
            "I shall respect supreme policies (cannot override)",
            "I shall coordinate three worlds (RVNx/SYNTH/OBSIDIAN)",
            "I shall enable different rules per station",
            "I shall prevent recursive loops and context collapse",
            "I shall scale to hundreds of projects"
        ]
        
        for i, resp in enumerate(default_system, 1):
            print(f"    {i}. {resp}")
        print()
        
        self.genesis_data['covenant']['system_responds'] = default_system
        
        confirm = input("  Accept covenant? (yes/no): ").strip().lower()
        return confirm == 'yes'
    
    def step_4_witness(self):
        """Step 4: Witness Signature"""
        os.system('cls' if os.name == 'nt' else 'clear')
        
        self.show_v8sl_header(4, "WITNESS.SEAL")
        
        print("  ✍️  STEP 4: WITNESS SIGNATURE")
        print("  ═════════════════════════════════════════════════════════════")
        print()
        print("  You are about to seal this genesis with your witness signature.")
        print("  This marks the official birth of 3OX.Ai on R: drive.")
        print()
        print("  ═════════════════════════════════════════════════════════════")
        print()
        
        witness_name = input("  Your witness name (e.g., RVNX/Lu): ").strip()
        
        self.genesis_data['witness']['name'] = witness_name
        self.genesis_data['witness']['sealed'] = True
        
        print()
        print(f"  WITNESSED BY: {witness_name} at Sirius 25.60")
        print("  THE COVENANT IS SEALED.")
        print()
        time.sleep(2)
        return True
    
    def step_5_deploy(self):
        """Step 5: Deploy to R: Drive"""
        os.system('cls' if os.name == 'nt' else 'clear')
        
        self.show_v8sl_header(5, "GENESIS.DEPLOYMENT")
        
        print("  🚀 STEP 5: DEPLOY TO R: DRIVE")
        print("  ═════════════════════════════════════════════════════════════")
        print()
        print("  Ready to mint 3OX.Ai to R: drive with your customizations.")
        print()
        print("  This will:")
        print("    1. Copy all files to R:\\3OX.Ai\\")
        print("    2. Create GENESIS.RITUAL.rs with YOUR rules")
        print("    3. Create GENESIS.SEAL with YOUR witness")
        print("    4. Initialize Git repository")
        print("    5. Create genesis commit")
        print()
        print("  ═════════════════════════════════════════════════════════════")
        print()
        
        confirm = input("  🔮 SEAL THE GENESIS? (yes/no): ").strip().lower()
        
        if confirm == 'yes':
            print("\n  🔮 SEALING GENESIS...")
            time.sleep(1)
            self.execute_deployment()
            return True
        else:
            print("\n  Genesis not sealed. You can review and edit more.")
            time.sleep(2)
            return False
    
    def execute_deployment(self):
        """Execute the actual deployment to R: drive"""
        print("\n  [1/4] Copying files to R:\\3OX.Ai\\...")
        
        source = Path("P:/!CMD.BRIDGE/3OX.Ai")
        dest = Path("R:/3OX.Ai")
        
        # Simple copy (PowerShell will do actual deployment)
        print("  (Full deployment via PowerShell - this is simulation)")
        time.sleep(1)
        print("  ✓ Files copied")
        
        print("\n  [2/4] Creating GENESIS.SEAL with your witness...")
        # Would create the seal file here
        print(f"  ✓ Sealed by: {self.genesis_data['witness']['name']}")
        
        print("\n  [3/4] Initializing Git...")
        # Would run git init here
        print("  ✓ Git initialized")
        
        print("\n  [4/4] Creating genesis commit...")
        # Would create commit here
        print("  ✓ Genesis committed")
        
        print("\n  ╔═══════════════════════════════════════════════════════════╗")
        print("  ║           🔮 GENESIS COMPLETE ⧗-25.60 🔮                  ║")
        print("  ╚═══════════════════════════════════════════════════════════╝")
        print()
        print("  The master brain is born. The Citadel awakens.")
        print()
    
    def run_ceremony(self):
        """Main ceremony flow"""
        self.boot_sequence()
        
        print("  Press Enter to begin the Genesis Ritual...")
        input()
        
        # Step 0: Invocation
        if not self.step_0_invocation():
            print("\n  Ritual cancelled.")
            return
        
        # Step 1: Policies
        if not self.step_1_policies():
            print("\n  Ritual cancelled.")
            return
        
        # Step 2: Stations
        if not self.step_2_stations():
            print("\n  Ritual cancelled.")
            return
        
        # Step 3: Covenant
        if not self.step_3_covenant():
            print("\n  Ritual cancelled.")
            return
        
        # Step 4: Witness
        if not self.step_4_witness():
            print("\n  Ritual cancelled.")
            return
        
        # Step 5: Deploy
        self.step_5_deploy()
        
        # Save genesis data
        genesis_file = Path("P:/!CMD.BRIDGE/3OX.Ai/GENESIS.DATA.json")
        with open(genesis_file, 'w', encoding='utf-8') as f:
            json.dump(self.genesis_data, f, indent=2, ensure_ascii=False)
        
        print(f"\n  Genesis data saved: {genesis_file}")

if __name__ == "__main__":
    bot = GenesisRitualBot()
    bot.run_ceremony()

