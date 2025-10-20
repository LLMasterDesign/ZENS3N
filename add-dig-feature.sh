#!/bin/bash
# ════════════════════════════════════════════════════════════
# ADD DIG FEATURE TO TRICKOON
# ════════════════════════════════════════════════════════════

echo "▛▞ ADDING DIG FEATURE TO TRICKOON ▞//▮▯▯▯▯▯▯▹"
echo "Adding trash-digging capability for deeper meaning analysis..."
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

# Restart the telegram container to apply the new dig command
print_status "Restarting telegram container to add the /dig command..."
docker-compose restart glyphbit-telegram

if [ $? -eq 0 ]; then
    print_success "Trickoon now has the /dig feature!"
    print_status "New command added: /dig <message>"
    print_status "This lets Trickoon dig through the trash of words to find deeper meaning!"
else
    echo "❌ Failed to restart container. Check logs with: docker-compose logs glyphbit-telegram"
    exit 1
fi

echo ""
echo "🦝 New Trickoon Features:"
echo "   - /dig <message> - Dig through trash for deeper meaning"
echo "   - Enhanced personality with trash-digging metaphors"
echo "   - Examples of how to use the dig feature"
echo ""
echo "Test it out! Try: /dig I feel lost in life"
echo ""
echo ":: ∎"