# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x8631]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // UNLOCK.3OX.SH ▞▞
# ▛▞// UNLOCK.3OX.SH :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [toml] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.unlock.3ox.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for UNLOCK.3OX.SH
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
# unlock.3ox.sh :: Sync Locked Files Back to .3ox
# Copies user edits from bin/lock/ back to .3ox/
# Part of 3OX.Ai (ZEN-9)

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
LOCK_DIR="$BASE_DIR/.3ox/vec3/rc/bin/lock"
SIRIUS_TIME=$(ruby -e "require_relative '$BASE_DIR/.3ox/vec3/lib/sirius.clock.rb' rescue puts '⧗-26.152'" 2>/dev/null || echo "⧗-26.152")

echo "▛▞// 3OX.UNLOCK :: Syncing bin/lock/ back to .3ox/"
echo "Sirius Time: $SIRIUS_TIME"
echo ""

# Critical files mapping
declare -A FILES=(
    ["sparkfile.md"]=".3ox/sparkfile.md"
    ["brains.rs"]=".3ox/brains.rs"
    ["tools.yml"]=".3ox/tools.yml"
    ["routes.json"]=".3ox/routes.json"
    ["limits.toml"]=".3ox/limits.toml"
)

SYNCED_COUNT=0
FAILED_COUNT=0

for lock_name in "${!FILES[@]}"; do
    lock_file="$LOCK_DIR/$lock_name"
    target_file="$BASE_DIR/${FILES[$lock_name]}"
    
    if [ -f "$lock_file" ]; then
        # Copy from lock directory back to .3ox
        cp "$lock_file" "$target_file" && {
            chmod 644 "$target_file"
            echo "✅ Synced: $lock_name → ${FILES[$lock_name]}"
            SYNCED_COUNT=$((SYNCED_COUNT + 1))
        } || {
            echo "❌ Failed to sync: $lock_name"
            FAILED_COUNT=$((FAILED_COUNT + 1))
        }
    else
        echo "⚠️  Not found in lock: $lock_name"
    fi
done

# Supporting files
SUPPORTING=(
    "map.toml:.meta/.map.toml"
    "ZENS3N.BASE.ID:ZENS3N.BASE.ID"
)

for entry in "${SUPPORTING[@]}"; do
    IFS=':' read -r lock_name target <<< "$entry"
    lock_file="$LOCK_DIR/$lock_name"
    target_file="$BASE_DIR/$target"
    
    if [ -f "$lock_file" ]; then
        cp "$lock_file" "$target_file" && {
            chmod 644 "$target_file"
            echo "✅ Synced: $lock_name"
            SYNCED_COUNT=$((SYNCED_COUNT + 1))
        }
    fi
done

echo ""
echo "▛▞// SYNC.SUMMARY"
echo "Synced: $SYNCED_COUNT files"
echo "Failed: $FAILED_COUNT files"
echo ""
echo "📋 Files synced from bin/lock/ to .3ox/"

# :: ∎