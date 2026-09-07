#!/bin/bash
# ▛//▞▞ TELEPROMPTR VPS SYNC ▞▞
# Check and sync TelePromptR between local and VPS

set -euo pipefail

VPS_HOST="root@5.78.109.54"
VPS_TPR_PATH="/root/!CMD.VPS/TelePromptR"
VPS_3OX_PATH="/root/!CMD.BRIDGE/.3ox"
LOCAL_TPR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_RUNTIME="${LOCAL_TPR_PATH}/runtime/vps"

echo "▛//▞▞ TELEPROMPTR VPS SYNC ▞▞"
echo "VPS: ${VPS_HOST}"
echo "VPS TPR: ${VPS_TPR_PATH}"
echo "VPS 3OX: ${VPS_3OX_PATH}"
echo "Local: ${LOCAL_TPR_PATH}"
echo ""

# Check if TPR is running on VPS
echo "📡 Checking VPS status..."
if ssh "${VPS_HOST}" "ps aux | grep -E 'teleprompter|telegram' | grep -v grep" 2>/dev/null; then
  echo "✅ TPR is running on VPS"
else
  echo "⚠️  TPR does not appear to be running on VPS"
fi
echo ""

# Check VPS file structure
echo "📁 Checking VPS file structure..."
if ssh "${VPS_HOST}" "test -f ${VPS_TPR_PATH}/3ox.station/vec3/bin/teleprompter.rb" 2>/dev/null; then
  echo "✅ Found: ${VPS_TPR_PATH}/3ox.station/vec3/bin/teleprompter.rb"
  VPS_VERSION=$(ssh "${VPS_HOST}" "head -10 ${VPS_TPR_PATH}/3ox.station/vec3/bin/teleprompter.rb | grep -i version || echo 'unknown'")
  echo "   Version: ${VPS_VERSION}"
else
  echo "⚠️  Not found: ${VPS_TPR_PATH}/3ox.station/vec3/bin/teleprompter.rb"
fi

if ssh "${VPS_HOST}" "test -f ${VPS_3OX_PATH}/vec3/lib/providers/telegram.rb" 2>/dev/null; then
  echo "✅ Found: ${VPS_3OX_PATH}/vec3/lib/providers/telegram.rb (legacy 3ox provider)"
fi
echo ""

# Compare file sizes/dates
echo "📊 Comparing local vs VPS..."
if [[ -f "${LOCAL_RUNTIME}/3ox.station/vec3/bin/teleprompter.rb" ]]; then
  LOCAL_SIZE=$(stat -f%z "${LOCAL_RUNTIME}/3ox.station/vec3/bin/teleprompter.rb" 2>/dev/null || stat -c%s "${LOCAL_RUNTIME}/3ox.station/vec3/bin/teleprompter.rb" 2>/dev/null || echo "0")
  VPS_SIZE=$(ssh "${VPS_HOST}" "stat -f%z ${VPS_TPR_PATH}/3ox.station/vec3/bin/teleprompter.rb 2>/dev/null || stat -c%s ${VPS_TPR_PATH}/3ox.station/vec3/bin/teleprompter.rb 2>/dev/null || echo '0'")
  
  if [[ "$LOCAL_SIZE" != "$VPS_SIZE" ]]; then
    echo "⚠️  File sizes differ:"
    echo "   Local: ${LOCAL_SIZE} bytes"
    echo "   VPS: ${VPS_SIZE} bytes"
    echo "   → Files may be out of sync"
  else
    echo "✅ File sizes match (${LOCAL_SIZE} bytes)"
  fi
fi
echo ""

# Menu
echo "Options:"
echo "1. Pull from VPS (update local from VPS)"
echo "2. Push to VPS (update VPS from local)"
echo "3. Show diff (compare files)"
echo "4. Check VPS process status"
echo "5. Exit"
echo ""
read -p "Choose option [1-5]: " choice

case "$choice" in
  1)
    echo "📥 Pulling from VPS..."
    mkdir -p "${LOCAL_RUNTIME}/3ox.station/vec3/bin"
    mkdir -p "${LOCAL_RUNTIME}/3ox.station/vec3/var"
    
    # Pull main teleprompter
    scp "${VPS_HOST}:${VPS_TPR_PATH}/3ox.station/vec3/bin/teleprompter.rb" \
        "${LOCAL_RUNTIME}/3ox.station/vec3/bin/teleprompter.rb"
    echo "✅ Pulled teleprompter.rb"
    
    # Pull ID files
    scp "${VPS_HOST}:${VPS_TPR_PATH}/STATION.ID" \
        "${LOCAL_RUNTIME}/../STATION.ID" 2>/dev/null || true
    scp "${VPS_HOST}:${VPS_TPR_PATH}/TELEPROMPTER.ID" \
        "${LOCAL_RUNTIME}/../TELEPROMPTER.ID" 2>/dev/null || true
    
    echo "✅ Pull complete"
    ;;
  2)
    echo "📤 Pushing to VPS..."
    read -p "This will overwrite VPS files. Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Cancelled"
      exit 0
    fi
    
    # Push bridge and tools
    ssh "${VPS_HOST}" "mkdir -p ${VPS_TPR_PATH}/tools" 2>/dev/null || true
    scp "${LOCAL_TPR_PATH}/tools/telepromptr_bridge.rb" \
        "${VPS_HOST}:${VPS_TPR_PATH}/tools/" 2>/dev/null || true
    
    # Push updated runtime (if you want to update VPS runtime)
    read -p "Update VPS runtime teleprompter.rb? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      ssh "${VPS_HOST}" "mkdir -p ${VPS_TPR_PATH}/3ox.station/vec3/bin" 2>/dev/null || true
      scp "${LOCAL_RUNTIME}/3ox.station/vec3/bin/teleprompter.rb" \
          "${VPS_HOST}:${VPS_TPR_PATH}/3ox.station/vec3/bin/teleprompter.rb"
      echo "✅ Pushed teleprompter.rb"
    fi
    
    echo "✅ Push complete"
    ;;
  3)
    echo "📋 Showing diff..."
    if [[ -f "${LOCAL_RUNTIME}/3ox.station/vec3/bin/teleprompter.rb" ]]; then
      ssh "${VPS_HOST}" "cat ${VPS_TPR_PATH}/3ox.station/vec3/bin/teleprompter.rb" 2>/dev/null | \
        diff -u "${LOCAL_RUNTIME}/3ox.station/vec3/bin/teleprompter.rb" - || true
    else
      echo "⚠️  Local file not found"
    fi
    ;;
  4)
    echo "🔍 VPS Process Status:"
    ssh "${VPS_HOST}" "ps aux | grep -E 'teleprompter|telegram|bridge' | grep -v grep || echo 'No TPR processes found'"
    echo ""
    echo "📁 VPS TPR Directory:"
    ssh "${VPS_HOST}" "ls -lah ${VPS_TPR_PATH}/ 2>/dev/null || echo 'Directory not found'"
    ;;
  5)
    echo "Exiting"
    exit 0
    ;;
  *)
    echo "Invalid option"
    exit 1
    ;;
esac
