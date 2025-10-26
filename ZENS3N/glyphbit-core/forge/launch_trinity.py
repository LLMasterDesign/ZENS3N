#!/usr/bin/env python3
"""
╔════════════════════════════════════════════════════════════════════════════╗
║                    GLYPHBIT TRINITY LAUNCHER                               ║
║              Auto-detect and launch all bots in parallel                   ║
╚════════════════════════════════════════════════════════════════════════════╝

Scans GLYPH.BIT/ for *.Bit folders and launches all bots simultaneously.
Scales from 3 bots to 100+ automatically.
"""

import os
import sys
import subprocess
import time
from pathlib import Path
from multiprocessing import Process

# ═══════════════════════════════════════════════════════════
# GLYPHBIT AUTO-DISCOVERY
# ═══════════════════════════════════════════════════════════

def discover_bots(base_dir=None):
    """
    Scan directory for *.Bit folders containing bot.py
    
    Returns: List of (bot_name, bot_path) tuples
    """
    if base_dir is None:
        base_dir = Path(__file__).parent
    else:
        base_dir = Path(base_dir)
    
    bots = []
    
    # Find all *.Bit directories
    for item in base_dir.iterdir():
        if item.is_dir() and item.name.endswith('.Bit'):
            bot_file = item / 'bot.py'
            if bot_file.exists():
                bot_name = item.name.replace('.Bit', '').lower()
                bots.append((bot_name, item))
                print(f"  ✅ Found: {item.name} ({bot_file})")
            else:
                print(f"  ⚠️  Skipping {item.name} (no bot.py)")
    
    return bots

# ═══════════════════════════════════════════════════════════
# BOT LAUNCHER
# ═══════════════════════════════════════════════════════════

def launch_bot(bot_name, bot_path):
    """
    Launch a single bot as a subprocess
    
    Args:
        bot_name: Name of the bot (e.g., 'noctua')
        bot_path: Path to the bot directory
    """
    print(f"\n🚀 Launching {bot_name.upper()}...")
    
    bot_file = bot_path / 'bot.py'
    
    # Change to bot directory and run
    try:
        # Run bot.py in its own directory
        process = subprocess.Popen(
            [sys.executable, 'bot.py'],
            cwd=str(bot_path),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        
        print(f"  ✅ {bot_name.upper()} started (PID: {process.pid})")
        
        # Stream output
        for line in process.stdout:
            print(f"  [{bot_name}] {line.rstrip()}")
        
    except Exception as e:
        print(f"  ❌ {bot_name.upper()} failed to start: {e}")

# ═══════════════════════════════════════════════════════════
# PARALLEL LAUNCHER
# ═══════════════════════════════════════════════════════════

def launch_all_bots(bots):
    """
    Launch all bots in parallel using multiprocessing
    
    Args:
        bots: List of (bot_name, bot_path) tuples
    """
    processes = []
    
    for bot_name, bot_path in bots:
        # Start each bot in its own process
        p = Process(target=launch_bot, args=(bot_name, bot_path))
        p.start()
        processes.append(p)
        time.sleep(1)  # Stagger starts slightly
    
    print(f"\n{'═'*60}")
    print(f"  {len(bots)} BOTS RUNNING IN PARALLEL")
    print(f"{'═'*60}\n")
    
    # Wait for all processes
    try:
        for p in processes:
            p.join()
    except KeyboardInterrupt:
        print("\n\n🛑 Shutdown signal received...")
        for p in processes:
            p.terminate()
        print("✅ All bots terminated")

# ═══════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════

def main():
    """Main launcher - discover and run all bots"""
    
    print("╔════════════════════════════════════════════════════════════╗")
    print("║         GLYPHBIT TRINITY LAUNCHER v1.0                     ║")
    print("║              Auto-Discovery Mode                           ║")
    print("╚════════════════════════════════════════════════════════════╝\n")
    
    print("🔍 Scanning for bots...\n")
    bots = discover_bots()
    
    if not bots:
        print("❌ No bots found! Ensure *.Bit folders contain bot.py")
        sys.exit(1)
    
    print(f"\n📊 Discovered {len(bots)} bot(s)")
    print("─" * 60)
    for name, path in bots:
        # Check for .bit folder
        bit_dir = path / '.bit'
        has_config = (bit_dir / 'config.toml').exists()
        has_personality = list(bit_dir.glob('*.bit.*.md'))
        
        status = "✅ READY" if has_config and has_personality else "⚠️  INCOMPLETE"
        print(f"  {name.upper():12} → {status}")
    
    print("─" * 60)
    
    # Launch all
    print("\n🚀 Launching Trinity...\n")
    launch_all_bots(bots)

if __name__ == '__main__':
    main()

