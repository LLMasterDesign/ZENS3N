#!/bin/bash
# ════════════════════════════════════════════════════════════
#  GLYPHBIT TRINITY LAUNCHER (Linux/Mac/Docker)
#  Auto-discovers and launches all bots
# ════════════════════════════════════════════════════════════

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         GLYPHBIT TRINITY LAUNCHER                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found! Install Python 3.11+"
    exit 1
fi

# Launch all bots
python3 launch_trinity.py

