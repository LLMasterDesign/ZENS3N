# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xC032]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // INSTALL.SH ▞▞
# ▛▞// INSTALL.SH :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [warden] [tape] [dispatch] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.install.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for INSTALL.SH
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
###▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂###

###▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂###

set -e

THREE_OX_HOME="${THREE_OX_HOME:-$HOME/.3ox}"
REPO_URL="${THREE_OX_REPO:-https://github.com/zens3n/3ox.git}"

echo ""
echo "▛▞ 3OX.Ai Installer"
echo "==================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# ═══════════════════════════════════════════════════════════════
# Detect OS
# ═══════════════════════════════════════════════════════════════

detect_os() {
    case "$(uname -s)" in
        Linux*)   OS=Linux;;
        Darwin*)  OS=Mac;;
        CYGWIN*|MINGW*|MSYS*) OS=Windows;;
        *)        OS=Unknown;;
    esac
    echo "▛▞ Detected: $OS"
}

# ═══════════════════════════════════════════════════════════════
# Install Dependencies
# ═══════════════════════════════════════════════════════════════

install_deps() {
    echo ""
    echo "▛▞ Installing dependencies..."
    
    # Ruby
    if command -v ruby &> /dev/null; then
        RUBY_VERSION=$(ruby -v | awk '{print $2}')
        success "Ruby $RUBY_VERSION"
    else
        warn "Ruby not found, installing..."
        if [ "$OS" = "Linux" ]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update -qq
                sudo apt-get install -y ruby ruby-dev
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y ruby ruby-devel
            elif command -v pacman &> /dev/null; then
                sudo pacman -S ruby
            fi
        elif [ "$OS" = "Mac" ]; then
            brew install ruby
        fi
        success "Ruby installed"
    fi
    
    # Redis
    if command -v redis-cli &> /dev/null; then
        success "Redis available"
    else
        warn "Redis not found, installing..."
        if [ "$OS" = "Linux" ]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get install -y redis-server
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y redis
            fi
        elif [ "$OS" = "Mac" ]; then
            brew install redis
        fi
        success "Redis installed"
    fi
    
    # Git
    if command -v git &> /dev/null; then
        success "Git available"
    else
        error "Git is required. Please install git first."
    fi
    
    # Rust (optional, for building from source)
    if command -v cargo &> /dev/null; then
        success "Rust available"
    else
        echo "▛▞ Rust not found. Install for building from source:"
        echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    fi
}

# ═══════════════════════════════════════════════════════════════
# Clone/Update Repo
# ═══════════════════════════════════════════════════════════════

clone_repo() {
    echo ""
    echo "▛▞ Setting up 3ox..."
    
    if [ -d "$THREE_OX_HOME/.git" ]; then
        echo "   Updating existing installation..."
        cd "$THREE_OX_HOME"
        git pull --quiet
        success "Updated to latest"
    else
        echo "   Cloning from $REPO_URL..."
        git clone --quiet "$REPO_URL" "$THREE_OX_HOME" 2>/dev/null || {
            # If repo doesn't exist yet, just create structure
            mkdir -p "$THREE_OX_HOME"
            warn "Repo not available, creating local structure"
        }
        success "Cloned to $THREE_OX_HOME"
    fi
}

# ═══════════════════════════════════════════════════════════════
# Create Directory Structure
# ═══════════════════════════════════════════════════════════════

create_structure() {
    echo ""
    echo "▛▞ Creating directory structure..."
    
    mkdir -p "$THREE_OX_HOME/vec3/bin"
    mkdir -p "$THREE_OX_HOME/vec3/rc/dispatch"
    mkdir -p "$THREE_OX_HOME/vec3/rc/run"
    mkdir -p "$THREE_OX_HOME/vec3/rc/tape"
    mkdir -p "$THREE_OX_HOME/vec3/rc/start.d"
    mkdir -p "$THREE_OX_HOME/vec3/rc/stop.d"
    mkdir -p "$THREE_OX_HOME/vec3/rc/status.d"
    mkdir -p "$THREE_OX_HOME/vec3/core"
    mkdir -p "$THREE_OX_HOME/vec3/lib"
    mkdir -p "$THREE_OX_HOME/vec3/var/log"
    mkdir -p "$THREE_OX_HOME/vec3/var/state"
    mkdir -p "$THREE_OX_HOME/vec3/var/queue"
    mkdir -p "$THREE_OX_HOME/vec3/var/receipts"
    mkdir -p "$THREE_OX_HOME/templates"
    mkdir -p "$THREE_OX_HOME/registry"
    mkdir -p "$THREE_OX_HOME/keys"
    
    success "Directory structure created"
}

# ═══════════════════════════════════════════════════════════════
# Build Rust Binary (if source available)
# ═══════════════════════════════════════════════════════════════

build_rust() {
    if [ -d "$THREE_OX_HOME/vec3/bin/brains_rs" ] && command -v cargo &> /dev/null; then
        echo ""
        echo "▛▞ Building Rust binary..."
        cd "$THREE_OX_HOME/vec3/bin/brains_rs"
        cargo build --release --quiet 2>/dev/null && {
            cp target/release/3ox "$THREE_OX_HOME/vec3/bin/3ox.exe"
            success "Built 3ox.exe"
        } || warn "Rust build skipped (optional)"
    fi
}

# ═══════════════════════════════════════════════════════════════
# Setup PATH
# ═══════════════════════════════════════════════════════════════

setup_path() {
    echo ""
    echo "▛▞ Setting up PATH..."
    
    BIN_PATH="$THREE_OX_HOME/vec3/bin"
    
    # Bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "3ox" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# 3OX.Ai" >> "$HOME/.bashrc"
            echo "export PATH=\"$BIN_PATH:\$PATH\"" >> "$HOME/.bashrc"
            success "Added to ~/.bashrc"
        else
            success "Already in ~/.bashrc"
        fi
    fi
    
    # Zsh
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "3ox" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# 3OX.Ai" >> "$HOME/.zshrc"
            echo "export PATH=\"$BIN_PATH:\$PATH\"" >> "$HOME/.zshrc"
            success "Added to ~/.zshrc"
        else
            success "Already in ~/.zshrc"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# Print Summary
# ═══════════════════════════════════════════════════════════════

print_summary() {
    echo ""
    echo "▛▞ Installation Complete!"
    echo "========================="
    echo ""
    echo "   Location: $THREE_OX_HOME"
    echo ""
    echo "▛▞ Next steps:"
    echo ""
    echo "   1. Reload your shell:"
    echo "      source ~/.bashrc  # or ~/.zshrc"
    echo ""
    echo "   2. Verify installation:"
    echo "      3ox --help"
    echo ""
    echo "   3. Initialize a new base:"
    echo "      cd /path/to/project"
    echo "      3ox init MyBase"
    echo ""
    echo "   4. Start services:"
    echo "      3ox start warden"
    echo ""
    echo ":: ∎"
}

# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

main() {
    detect_os
    install_deps
    clone_repo
    create_structure
    build_rust
    setup_path
    print_summary
}

main "$@"

# :: ∎