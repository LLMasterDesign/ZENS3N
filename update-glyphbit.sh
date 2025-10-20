#!/bin/bash
# ════════════════════════════════════════════════════════════
# GLYPHBIT LIVE UPDATE SCRIPT
# Safe deployment for VPS instances
# ════════════════════════════════════════════════════════════

set -e  # Exit on any error

echo "▛▞ GLYPHBIT UPDATE INITIATED ▞//▮▯▯▯▯▯▯▹"
echo "Timestamp: $(date)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

print_status "Starting GlyphBit update process..."

# Step 1: Backup current state
print_status "Creating backup of current state..."
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup current containers
docker-compose ps > "$BACKUP_DIR/container_status_before.txt"
docker images | grep glyphbit > "$BACKUP_DIR/images_before.txt" || true

print_success "Backup created in $BACKUP_DIR"

# Step 2: Pull latest changes
print_status "Pulling latest changes from GitHub..."
git fetch origin
git pull origin main

if [ $? -eq 0 ]; then
    print_success "Code updated successfully"
else
    print_error "Failed to pull changes. Check your git configuration."
    exit 1
fi

# Step 3: Check for environment file
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Please ensure your environment variables are set."
    print_warning "You may need to create .env with your API keys and bot tokens."
fi

# Step 4: Stop containers gracefully
print_status "Stopping containers gracefully..."
docker-compose down

# Step 5: Rebuild containers
print_status "Rebuilding containers with latest code..."
docker-compose build --no-cache

if [ $? -eq 0 ]; then
    print_success "Containers rebuilt successfully"
else
    print_error "Failed to rebuild containers. Check the build logs above."
    exit 1
fi

# Step 6: Start containers
print_status "Starting updated containers..."
docker-compose up -d

if [ $? -eq 0 ]; then
    print_success "Containers started successfully"
else
    print_error "Failed to start containers. Check the logs above."
    exit 1
fi

# Step 7: Wait for containers to be ready
print_status "Waiting for containers to initialize..."
sleep 10

# Step 8: Verify containers are running
print_status "Verifying container status..."
docker-compose ps

# Check if all containers are running
RUNNING_CONTAINERS=$(docker-compose ps --services --filter "status=running" | wc -l)
TOTAL_CONTAINERS=$(docker-compose ps --services | wc -l)

if [ "$RUNNING_CONTAINERS" -eq "$TOTAL_CONTAINERS" ]; then
    print_success "All containers are running!"
else
    print_warning "Some containers may not be running. Check the status above."
fi

# Step 9: Show logs for verification
print_status "Recent logs (last 20 lines):"
echo "════════════════════════════════════════════════════════════"
docker-compose logs --tail=20

# Step 10: Final status
echo ""
echo "▛▞ UPDATE COMPLETE ▞//▮▯▯▯▯▯▯▹"
echo "Timestamp: $(date)"
echo ""
print_success "GlyphBit has been updated successfully!"
print_status "To monitor logs: docker-compose logs -f"
print_status "To check status: docker-compose ps"
print_status "Backup saved in: $BACKUP_DIR"

# Optional: Show bot status
print_status "Bot instances should be responding to Telegram messages now."
print_status "Test by sending a message to any of your configured bots."

echo ""
echo ":: ∎"