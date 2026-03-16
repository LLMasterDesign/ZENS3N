///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.076 // WORKBOOK :: VSO.AGENT Deployment ▞▞

# VSO.AGENT Deployment

## Prerequisites
- SSH key: `~/.ssh/id_zens3n_vps`
- VPS: root@5.78.109.54
- rsync (or scp fallback)

## Steps

1. **Sync to VPS**
   ```bash
   cd 3OX.Ai/agents/live/VSO.Agent
   bash sync-vps.sh
   ```

2. **On VPS: Generate TPR config**
   ```bash
   ssh -i ~/.ssh/id_zens3n_vps root@5.78.109.54
   cd '/root/!CMD.VPS/VSOAgent'
   ruby .3ox/\(6\)Pulse/run.rb teleprompt
   ```

3. **Register with TelePromptR** (in Telegram bot)
   - `/topic add VSO`
   - `/teleprompter subscribe [TID]`

4. **Merge TPR config** (if merge.sh exists on VPS)
   ```bash
   cd /root/!CMD.VPS/TelePromptR
   ./merge.sh  # or equivalent
   ```

5. **Restart speaker-mesh**
   ```bash
   systemctl restart speaker-mesh
   ```

6. **Verify** — Send message in Telegram topic "VSO"

## Telegram Topic
**VSO** — VA disability claim management agent

## VPS Path
`/root/!CMD.VPS/VSOAgent`

:: ∎
