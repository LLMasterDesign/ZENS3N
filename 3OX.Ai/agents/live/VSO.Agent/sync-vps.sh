#!/usr/bin/env bash
# sync-vps.sh :: Deploy VSO.AGENT to CMD.VPS
# Usage: bash sync-vps.sh
# SSH: root@5.78.109.54 (key: ~/.ssh/id_zens3n_vps)

set -e
VPS="root@5.78.109.54"
REMOTE_PATH="/root/!CMD.VPS/VSOAgent"
SRC="$(cd "$(dirname "$0")" && pwd)"
SSH_OPTS="-i ${HOME}/.ssh/id_zens3n_vps"

if command -v rsync &>/dev/null; then
  rsync -avz --delete -e "ssh $SSH_OPTS" \
    --exclude '.git' --exclude '3ox.log' --exclude '*.key' \
    "$SRC/" "$VPS:$REMOTE_PATH/"
else
  ssh $SSH_OPTS "$VPS" "mkdir -p '$REMOTE_PATH'"
  scp -r $SSH_OPTS "$SRC"/* "$VPS:$REMOTE_PATH/"
fi

echo "Synced to $VPS:$REMOTE_PATH"
echo "On VPS run: cd '$REMOTE_PATH' && ruby .3ox/.vec3/rc/run.rb teleprompt"
