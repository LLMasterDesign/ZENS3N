#!/bin/bash
# ════════════════════════════════════════════════════════════
# TRICKOON HOT RELOAD - Make Trickoon More Fun!
# ════════════════════════════════════════════════════════════

echo "▛▞ TRICKOON PERSONALITY HOT RELOAD ▞//▮▯▯▯▯▯▯▹"
echo "Making Trickoon more fun and less confrontational..."
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

# Since the personality file is mounted as a volume, changes should be live
print_status "Trickoon personality files have been updated!"
print_status "The changes should be live immediately since files are mounted as volumes."

# Restart just the telegram container to ensure changes take effect
print_status "Restarting telegram container to apply personality changes..."
docker-compose restart glyphbit-telegram

if [ $? -eq 0 ]; then
    print_success "Trickoon has been reloaded with the new fun personality!"
    print_status "Test by sending a message to Trickoon - he should be much more playful now!"
else
    echo "❌ Failed to restart container. Check logs with: docker-compose logs glyphbit-telegram"
    exit 1
fi

echo ""
echo "🦝 Trickoon is now more fun and less confrontational!"
echo "   - Changed from 'stinging questions' to 'curious questions'"
echo "   - More playful and wonder-filled responses"
echo "   - Less aggressive, more inviting personality"
echo ""
echo "Test it out! Send Trickoon a message about life, death, or purpose."
echo ""
echo ":: ∎"