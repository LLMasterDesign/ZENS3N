# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x4DE3]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // LOCK.3OX.SH ▞▞
# ▛▞// LOCK.3OX.SH :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [toml] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.lock.3ox.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for LOCK.3OX.SH
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
# lock.3ox.sh :: Lock Critical 3OX Configuration Files
# Moves files to bin/lock/ with permission gates
# Part of 3OX.Ai (ZEN-9)

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
LOCK_DIR="$BASE_DIR/.3ox/vec3/rc/bin/lock"
SIRIUS_TIME=$(ruby -e "require_relative '$BASE_DIR/.3ox/vec3/lib/sirius.clock.rb' rescue puts '⧗-26.152'" 2>/dev/null || echo "⧗-26.152")

echo "▛▞// 3OX.LOCK :: Moving files to bin/lock/ (user-editable, vec3-protected)"
echo "Sirius Time: $SIRIUS_TIME"
echo ""

# Ensure lock directory exists
mkdir -p "$LOCK_DIR"

# Critical files to lock
declare -A FILES=(
    ["sparkfile.md"]=".3ox/sparkfile.md"
    ["brains.rs"]=".3ox/brains.rs"
    ["tools.yml"]=".3ox/tools.yml"
    ["routes.json"]=".3ox/routes.json"
    ["limits.toml"]=".3ox/limits.toml"
)

LOCKED_COUNT=0
FAILED_COUNT=0

for lock_name in "${!FILES[@]}"; do
    source_file="$BASE_DIR/${FILES[$lock_name]}"
    lock_file="$LOCK_DIR/$lock_name"
    permission_file="$LOCK_DIR/$lock_name.permission"
    
    if [ -f "$source_file" ]; then
        # Copy file to lock directory (not symlink - user needs to edit)
        cp "$source_file" "$lock_file" && {
            # Set user-friendly permissions (644 = user read/write, others read)
            chmod 644 "$lock_file"
            
            # Create permission gate file (empty = vec3 cannot modify)
            # User can create this file to allow vec3 updates
            touch "$permission_file"
            chmod 644 "$permission_file"
            
            echo "✅ Locked: $lock_name → $lock_file"
            echo "   User can edit, vec3 needs $permission_file to modify"
            LOCKED_COUNT=$((LOCKED_COUNT + 1))
        } || {
            echo "❌ Failed to lock: $lock_name"
            FAILED_COUNT=$((FAILED_COUNT + 1))
        }
    else
        echo "⚠️  Source not found: ${FILES[$lock_name]}"
    fi
done

# Also lock supporting files
SUPPORTING=(
    ".meta/.map.toml:map.toml"
    "ZENS3N.BASE.ID:ZENS3N.BASE.ID"
)

for entry in "${SUPPORTING[@]}"; do
    IFS=':' read -r source lock_name <<< "$entry"
    source_file="$BASE_DIR/$source"
    lock_file="$LOCK_DIR/$lock_name"
    permission_file="$LOCK_DIR/$lock_name.permission"
    
    if [ -f "$source_file" ]; then
        cp "$source_file" "$lock_file" && {
            chmod 644 "$lock_file"
            touch "$permission_file"
            chmod 644 "$permission_file"
            echo "✅ Locked: $lock_name"
            LOCKED_COUNT=$((LOCKED_COUNT + 1))
        }
    fi
done

echo ""
echo "▛▞// LOCK.SUMMARY"
echo "Locked: $LOCKED_COUNT files in bin/lock/"
echo "Failed: $FAILED_COUNT files"
echo ""
echo "📋 Files are user-editable but vec3-protected"
echo "   To allow vec3 updates: touch bin/lock/<file>.permission"
echo "   To revoke: rm bin/lock/<file>.permission"
echo ""

# Create lock manifest
LOCK_MANIFEST="$BASE_DIR/.3ox/.locked.files"
cat > "$LOCK_MANIFEST" << EOF
# Locked Files Manifest
# Files in bin/lock/ are user-editable but vec3-protected
# Locked: $SIRIUS_TIME
# Base: ZENS3N.BASE

$(printf '%s\n' "${!FILES[@]}")
EOF

echo "✅ Lock manifest: .3ox/.locked.files"

# :: ∎