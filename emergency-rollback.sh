#!/bin/bash
# ════════════════════════════════════════════════════════════
# GLYPHBIT EMERGENCY ROLLBACK SCRIPT
# Use if update causes issues
# ════════════════════════════════════════════════════════════

set -e

echo "▛▞ GLYPHBIT EMERGENCY ROLLBACK ▞//▮▯▯▯▯▯▯▹"
echo "Timestamp: $(date)"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found. Are you in the GlyphBit directory?"
    exit 1
fi

print_warning "This will rollback to the previous commit!"
read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Rollback cancelled."
    exit 0
fi

# Step 1: Stop current containers
print_status "Stopping current containers..."
docker-compose down

# Step 2: Rollback to previous commit
print_status "Rolling back to previous commit..."
git reset --hard HEAD~1

if [ $? -eq 0 ]; then
    print_success "Code rolled back successfully"
else
    print_error "Failed to rollback code. Manual intervention required."
    exit 1
fi

# Step 3: Rebuild with previous code
print_status "Rebuilding containers with previous code..."
docker-compose build --no-cache

if [ $? -eq 0 ]; then
    print_success "Containers rebuilt successfully"
else
    print_error "Failed to rebuild containers."
    exit 1
fi

# Step 4: Start containers
print_status "Starting containers with previous version..."
docker-compose up -d

if [ $? -eq 0 ]; then
    print_success "Containers started successfully"
else
    print_error "Failed to start containers."
    exit 1
fi

# Step 5: Verify
print_status "Verifying rollback..."
sleep 5
docker-compose ps

print_success "Rollback completed successfully!"
print_status "Your GlyphBit should now be running the previous version."

echo ""
echo ":: ∎"