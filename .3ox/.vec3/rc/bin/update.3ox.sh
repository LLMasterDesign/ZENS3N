# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xB0B4]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // UPDATE.3OX.SH ▞▞
# ▛▞// UPDATE.3OX.SH :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.update.3ox.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for UPDATE.3OX.SH
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
# update.3ox.sh :: 3OX Configuration Update Script
# Updates .3ox files when changes occur, maintains headers and versions
# Part of 3OX.Ai (ZEN-9)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SIRIUS_TIME=$(ruby -e "require_relative '$BASE_DIR/.3ox/vec3/lib/sirius.clock.rb' rescue puts '⧗-26.152'" 2>/dev/null || echo "⧗-26.152")

echo "▛▞// 3OX.UPDATE :: Updating .3ox configuration files"
echo "Sirius Time: $SIRIUS_TIME"
echo ""

# Update sparkfile.md header if needed
if [ -f "$BASE_DIR/.3ox/sparkfile.md" ]; then
    if ! grep -q "⧗-" "$BASE_DIR/.3ox/sparkfile.md"; then
        echo "⚠️  sparkfile.md missing Sirius time header"
    fi
fi

# Update tools.yml timestamp
if [ -f "$BASE_DIR/.3ox/tools.yml" ]; then
    CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    sed -i "s/Last scan:.*/Last scan: $CURRENT_TIME/" "$BASE_DIR/.3ox/tools.yml" 2>/dev/null || true
    sed -i "s/Updated:.*/Updated: $CURRENT_TIME/" "$BASE_DIR/.3ox/tools.yml" 2>/dev/null || true
fi

# Update routes.json timestamp
if [ -f "$BASE_DIR/.3ox/routes.json" ]; then
    CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    # Update last_updated in routing_metadata if it exists
    python3 -c "
import json
import sys
from datetime import datetime
try:
    with open('$BASE_DIR/.3ox/routes.json', 'r') as f:
        data = json.load(f)
    if 'routing_metadata' in data:
        data['routing_metadata']['last_updated'] = '$CURRENT_TIME'
    with open('$BASE_DIR/.3ox/routes.json', 'w') as f:
        json.dump(data, f, indent=2)
except:
    pass
" 2>/dev/null || true
fi

echo "✅ Update complete"

# :: ∎