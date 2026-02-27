# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xADEF]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // SETUP.SH ▞▞
# ▛▞// SETUP.SH :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [warden] [tape] [pulse] [service] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.setup.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for SETUP.SH
# ```

# 


# 


# ▛//▞ PRISM :: KERNEL
# P:: identity.matrix ∙ context.anchor ∙ execution.flow
# R:: load.context ∙ execute.logic ∙ emit.result
# I:: intent.target={system.stability ∙ function.execution}
# S:: init → process → terminate
# M:: std.io ∙ file.sys ∙ mem.state
# :: ∎

#!/bin/bash


#
# Usage: sudo ./setup.sh [--build-only|--install-only]

set -e

VEC3_USER="vec3"
VEC3_GROUP="vec3"
VEC3_HOME="/opt/vec3"
VEC3_DATA="/var/lib/vec3"
VEC3_LOG="/var/log/vec3"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ─────────────────────────────────────────────────────────────
# Check prerequisites
# ─────────────────────────────────────────────────────────────

check_prereqs() {
    info "Checking prerequisites..."
    
    command -v elixir >/dev/null 2>&1 || error "Elixir not found. Install Elixir 1.17+"
    command -v mix >/dev/null 2>&1 || error "Mix not found"
    
    ELIXIR_VERSION=$(elixir --version | grep "Elixir" | awk '{print $2}')
    info "Found Elixir $ELIXIR_VERSION"
    
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)"
    fi
}

# ─────────────────────────────────────────────────────────────
# Create user and directories
# ─────────────────────────────────────────────────────────────

create_user() {
    info "Creating vec3 user..."
    
    if id "$VEC3_USER" &>/dev/null; then
        info "User $VEC3_USER already exists"
    else
        useradd -r -s /bin/false "$VEC3_USER"
        info "Created user $VEC3_USER"
    fi
}

create_dirs() {
    info "Creating directories..."
    
    mkdir -p "$VEC3_HOME"
    mkdir -p "$VEC3_DATA/tape"
    mkdir -p "$VEC3_DATA/pulse"
    mkdir -p "$VEC3_DATA/state"
    mkdir -p "$VEC3_LOG"
    
    chown -R "$VEC3_USER:$VEC3_GROUP" "$VEC3_DATA"
    chown -R "$VEC3_USER:$VEC3_GROUP" "$VEC3_LOG"
    
    info "Created $VEC3_HOME, $VEC3_DATA, $VEC3_LOG"
}

# ─────────────────────────────────────────────────────────────
# Build release
# ─────────────────────────────────────────────────────────────

build_release() {
    info "Building release..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    VEC3_SRC="$(dirname "$SCRIPT_DIR")"
    
    cd "$VEC3_SRC"
    
    info "Getting dependencies..."
    MIX_ENV=prod mix deps.get --only prod
    
    info "Compiling..."
    MIX_ENV=prod mix compile
    
    info "Building release..."
    MIX_ENV=prod mix release --overwrite
    
    info "Copying release to $VEC3_HOME..."
    cp -r _build/prod/rel/vec3/* "$VEC3_HOME/"
    chown -R "$VEC3_USER:$VEC3_GROUP" "$VEC3_HOME"
    
    info "Release built successfully"
}

# ─────────────────────────────────────────────────────────────
# Install systemd service
# ─────────────────────────────────────────────────────────────

install_service() {
    info "Installing systemd service..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    cp "$SCRIPT_DIR/vec3.service" /etc/systemd/system/
    systemctl daemon-reload
    
    info "Enabling service..."
    systemctl enable vec3
    
    info "Starting service..."
    systemctl start vec3
    
    sleep 2
    
    if systemctl is-active --quiet vec3; then
        info "Vec3 service is running!"
        systemctl status vec3 --no-pager
    else
        warn "Vec3 service failed to start. Check logs with: journalctl -u vec3"
    fi
}

# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

main() {
    echo "═══════════════════════════════════════════════════════════"
    echo "                    Vec3 Setup Script                       "
    echo "          3OX.Ai Core Services - Always On Deployment       "
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    case "${1:-}" in
        --build-only)
            check_prereqs
            build_release
            ;;
        --install-only)
            check_prereqs
            create_user
            create_dirs
            install_service
            ;;
        *)
            check_prereqs
            create_user
            create_dirs
            build_release
            install_service
            ;;
    esac
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    info "Setup complete!"
    echo ""
    echo "Commands:"
    echo "  sudo systemctl status vec3    # Check status"
    echo "  sudo journalctl -u vec3 -f    # View logs"
    echo "  ruby $VEC3_HOME/lib/gatekeeper/client.rb ping  # Test"
    echo "═══════════════════════════════════════════════════════════"
}

main "$@"

# :: ∎