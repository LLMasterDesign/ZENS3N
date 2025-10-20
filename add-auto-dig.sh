#!/bin/bash
# ════════════════════════════════════════════════════════════
# ADD AUTO-DIG FEATURE TO TRICKOON
# Every 3 turns, automatically dig through trash
# ════════════════════════════════════════════════════════════

echo "▛▞ ADDING AUTO-DIG FEATURE TO TRICKOON ▞//▮▯▯▯▯▯▯▹"
echo "Trickoon will now automatically dig through trash every 3 turns!"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found. Are you in the GlyphBit directory?"
    exit 1
fi

# Check if containers are running
print_status "Checking if GlyphBit containers are running..."
if ! docker-compose ps | grep -q "running"; then
    echo "❌ GlyphBit containers are not running. Start them first with: docker-compose up -d"
    exit 1
fi

print_success "Containers are running!"

# Restart the telegram container to apply the auto-dig feature
print_status "Restarting telegram container to add auto-digging..."
docker-compose restart glyphbit-telegram

if [ $? -eq 0 ]; then
    print_success "Trickoon now has auto-digging every 3 turns!"
    print_status "New features added:"
    print_status "  - Automatic trash digging every 3 conversation turns"
    print_status "  - Manual /dig command still available"
    print_status "  - Turn counter tracks conversation depth"
else
    echo "❌ Failed to restart container. Check logs with: docker-compose logs glyphbit-telegram"
    exit 1
fi

echo ""
echo "🦝 Trickoon Auto-Dig Features:"
echo "   - Automatically digs through trash every 3 turns"
echo "   - Finds deeper meaning without being asked"
echo "   - Proactive trash mystic behavior"
echo "   - Manual /dig command still works"
echo ""
echo "Test it out! Have a 3+ turn conversation with Trickoon and watch him auto-dig!"
echo ""
echo ":: ∎"