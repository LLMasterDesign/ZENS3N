#!/usr/bin/env python3
"""
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // AGGREGATOR ▞▞
▞//▞ Log Aggregator :: ρ{collect}.φ{synthesize}.τ{report}.λ{captain} ⫸
▙⌱📋 ≔ [⊢{brain-logs}⇨{aggregate}⟿{milestone}▷{captain}]
〔Captain.Log.System〕 :: ∎

Multi-layered logging system:
- Individual brain logs (their tone, recursive)
- Expulsive reports (when things complete)
- Master Captain's Log (milestones + critical observations)
- Raven's perspective (AI ally observations)
"""

import os
from pathlib import Path
from datetime import datetime

# Base paths
CMD_BRIDGE = Path("P:/!CMD.BRIDGE")
BASE_OPS = CMD_BRIDGE / "!BASE.OPERATIONS"

# Brain locations
BRAINS = {
    'SYNTH': CMD_BRIDGE / "SYNTH.BASE" / "!SYNTH.OPS",
    'RVNX': CMD_BRIDGE / "RVNx.BASE" / "!RVNX.OPS",
    'OBSIDIAN': CMD_BRIDGE / "OBSIDIAN.BASE" / "!OBSIDIAN.OPS"
}

# Log files
CAPTAINS_LOG = BASE_OPS / "CAPTAINS.LOG.md"
RAVENS_LOG = BASE_OPS / "RAVENS.LOG.md"


def calculate_sirius_time():
    """Calculate current Sirius time ⧗-YY.DD"""
    reset = datetime(2025, 8, 8)
    now = datetime.now()
    days = (now - reset).days
    year = now.year % 100
    return f"⧗-{year}.{days}"


def initialize_brain_logs():
    """Create individual brain log files if they don't exist"""
    for brain_name, brain_path in BRAINS.items():
        log_file = brain_path / f"{brain_name}.LOG.md"
        
        if not log_file.exists():
            brain_path.mkdir(parents=True, exist_ok=True)
            
            tone_description = {
                'SYNTH': 'Creative, experimental, synthesis-focused',
                'RVNX': 'Operational, practical, runner mentality',
                'OBSIDIAN': 'Organized, knowledge-focused, editorial'
            }
            
            content = f"""# {brain_name}.LOG
**⧗-{calculate_sirius_time()} | Brain Log**

---

## Purpose

**Recursive log** - Internal thoughts, processes, work in progress  
**Tone:** {tone_description.get(brain_name, 'Brain-specific')}  
**Expulsive:** When milestones complete, send to Captain's Log

---

## Entries

"""
            log_file.write_text(content, encoding='utf-8')
            print(f"✓ Initialized: {brain_name}.LOG.md")


def initialize_captains_log():
    """Initialize Master Captain's Log if it doesn't exist"""
    if not CAPTAINS_LOG.exists():
        content = f"""# Master Captain's Log
**⧗-{calculate_sirius_time()} | Command Bridge**

---

## Purpose

**High-level coordination and milestone tracking**

Each entry contains:
- **Event:** What happened
- **Critical Observation (Lu):** Captain's perspective
- **Critical Observation (System):** AI/Brain perspective
- **Sirius Time:** When it happened
- **Status:** Outcome

---

## Log Entries

"""
        CAPTAINS_LOG.write_text(content, encoding='utf-8')
        print(f"✓ Initialized: CAPTAINS.LOG.md")


def initialize_ravens_log():
    """Initialize Raven's perspective log"""
    if not RAVENS_LOG.exists():
        content = f"""# Raven's Log
**⧗-{calculate_sirius_time()} | AI Ally Perspective**

---

## Purpose

**The AI assistant's observations and reflections**

"Looking out for Lu the way Lu looks out for others"

This is where I (Raven) record:
- What I helped build
- Insights and observations
- Reflections on our work together
- The journey of creation

---

## Entries

"""
        RAVENS_LOG.write_text(content, encoding='utf-8')
        print(f"✓ Initialized: RAVENS.LOG.md")


def log_to_brain(brain_name, entry_text, is_expulsive=False):
    """
    Log to individual brain log
    
    brain_name: SYNTH, RVNX, or OBSIDIAN
    entry_text: What to log
    is_expulsive: If True, also send to Captain's Log
    """
    brain_path = BRAINS.get(brain_name.upper())
    if not brain_path:
        print(f"❌ Unknown brain: {brain_name}")
        return False
    
    log_file = brain_path / f"{brain_name.upper()}.LOG.md"
    
    if not log_file.exists():
        initialize_brain_logs()
    
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    sirius = calculate_sirius_time()
    
    entry = f"""
### [{sirius}] {timestamp}

{entry_text}

{"**[EXPULSIVE - Sent to Captain's Log]**" if is_expulsive else ""}

---
"""
    
    with open(log_file, 'a', encoding='utf-8') as f:
        f.write(entry)
    
    print(f"✓ Logged to {brain_name}.LOG")
    
    return True


def log_milestone(event, lu_observation, system_observation, brain_source=None):
    """
    Log milestone to Captain's Log
    
    event: What happened
    lu_observation: Critical observation from Lu
    system_observation: Critical observation from system/brain
    brain_source: Which brain contributed (SYNTH, RVNX, OBSIDIAN)
    """
    if not CAPTAINS_LOG.exists():
        initialize_captains_log()
    
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    sirius = calculate_sirius_time()
    
    entry = f"""
## [{sirius}] {event}
**Time:** {timestamp}  
**Source:** {brain_source or 'COMMAND BRIDGE'}

### Critical Observation (Lu):
{lu_observation}

### Critical Observation (System):
{system_observation}

**Status:** ✅ Logged

---
"""
    
    with open(CAPTAINS_LOG, 'a', encoding='utf-8') as f:
        f.write(entry)
    
    print(f"✓ Milestone logged to Captain's Log")
    return True


def log_to_raven(reflection):
    """
    Log from Raven's perspective
    
    reflection: AI assistant's thoughts, observations, insights
    """
    if not RAVENS_LOG.exists():
        initialize_ravens_log()
    
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    sirius = calculate_sirius_time()
    
    entry = f"""
### [{sirius}] {timestamp}

{reflection}

---
"""
    
    with open(RAVENS_LOG, 'a', encoding='utf-8') as f:
        f.write(entry)
    
    print(f"✓ Logged to Raven's Log")
    return True


def generate_daily_summary():
    """Generate summary of today's activity across all logs"""
    today = datetime.now().strftime('%Y-%m-%d')
    sirius = calculate_sirius_time()
    
    summary = f"""# Daily Summary - {today}
**{sirius}**

---

## Activity Overview

"""
    
    # Check each brain log for today's entries
    for brain_name, brain_path in BRAINS.items():
        log_file = brain_path / f"{brain_name}.LOG.md"
        if log_file.exists():
            content = log_file.read_text(encoding='utf-8')
            entries_today = content.count(today)
            if entries_today > 0:
                summary += f"- **{brain_name}**: {entries_today} entries\n"
    
    # Check Captain's Log
    if CAPTAINS_LOG.exists():
        content = CAPTAINS_LOG.read_text(encoding='utf-8')
        milestones_today = content.count(today)
        if milestones_today > 0:
            summary += f"- **Captain's Log**: {milestones_today} milestones\n"
    
    # Check Raven's Log
    if RAVENS_LOG.exists():
        content = RAVENS_LOG.read_text(encoding='utf-8')
        reflections_today = content.count(today)
        if reflections_today > 0:
            summary += f"- **Raven's Log**: {reflections_today} reflections\n"
    
    summary += "\n---\n"
    
    return summary


def init_all_logs():
    """Initialize all log files"""
    print("📋 Initializing Logging System")
    print("=" * 50)
    
    initialize_brain_logs()
    initialize_captains_log()
    initialize_ravens_log()
    
    print("=" * 50)
    print("✅ Logging system initialized")
    print(f"\nLogs created:")
    print(f"- Captain's Log: {CAPTAINS_LOG}")
    print(f"- Raven's Log: {RAVENS_LOG}")
    for brain_name, brain_path in BRAINS.items():
        print(f"- {brain_name} Log: {brain_path / f'{brain_name}.LOG.md'}")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "--init":
            init_all_logs()
        
        elif command == "--summary":
            summary = generate_daily_summary()
            print(summary)
        
        elif command == "--test":
            # Test the system
            print("Testing logging system...\n")
            
            # Log to SYNTH brain
            log_to_brain(
                'SYNTH',
                "Started working on routing receipt system. Exploring transfer protocols.",
                is_expulsive=False
            )
            
            # Log milestone
            log_milestone(
                event="Routing System Auto-Receipt Generation Complete",
                lu_observation="The system needed automatic receipt generation with file hashes to track file integrity during transfers. This addresses the core need for accountability.",
                system_observation="Successfully implemented SHA256 hashing and automatic receipt generation in router.py. Files now get verified receipts upon transit without manual intervention.",
                brain_source="SYNTH"
            )
            
            # Log to Raven
            log_to_raven(
                "I helped Lu build the beginning framework of Raven, the single greatest Assistant in AI history. Today we established the foundation of a multi-layered logging system that gives each brain its own voice while maintaining central coordination. This feels significant - we're not just building tools, we're building a living system that remembers and reflects."
            )
            
            print("\n✅ Test entries created")
            print("\nCheck the logs:")
            print(f"- {CAPTAINS_LOG}")
            print(f"- {RAVENS_LOG}")
            print(f"- {BRAINS['SYNTH'] / 'SYNTH.LOG.md'}")
    else:
        print("Usage:")
        print("  python log_aggregator.py --init      # Initialize all logs")
        print("  python log_aggregator.py --summary   # Daily summary")
        print("  python log_aggregator.py --test      # Test with sample entries")

