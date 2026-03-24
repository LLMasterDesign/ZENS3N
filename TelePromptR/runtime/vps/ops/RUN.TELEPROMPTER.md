///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.160 // RUN :: Teleprompter Start ▞▞

# Run Command: Start Teleprompter

## Immediate Execution

```bash
cd /root/!CMD.BRIDGE/.3ox && ruby vec3/lib/providers/telegram.rb start
```

## Alternative (via 3ox.rc)

```bash
cd /root/!CMD.BRIDGE/.3ox && ruby vec3/rc/3ox.rc start telegram
```

## Prerequisites

1. **Environment Variable:**
   ```bash
   export TELEGRAM_BOT_TOKEN="your_bot_token_from_botfather"
   ```

2. **Verify Token:**
   ```bash
   cd /root/!CMD.BRIDGE/.3ox && ruby vec3/lib/providers/telegram.rb test
   ```

## Expected Output

```
▛▞ Teleprompter starting...
✓ Connected as @your_bot_username
```

## Verification

Once running, test in Telegram:
- `/help` - Show commands
- `/chatid` - Get chat ID for .3ox config
- `/status` - System status

## Background Execution

To run in background:
```bash
cd /root/!CMD.BRIDGE/.3ox && nohup ruby vec3/lib/providers/telegram.rb start > vec3/var/log/teleprompter.log 2>&1 &
```

## Stop Teleprompter

```bash
cd /root/!CMD.BRIDGE/.3ox && ruby vec3/rc/3ox.rc stop telegram
```

Or find PID and kill:
```bash
ps aux | grep telegram | grep -v grep
kill <PID>
```

## New Features Available

✅ `/chatid` - Get chat ID for .3ox configuration  
✅ `tgsub.key` management - Keys created in `.3ox/keys/{agent_id}.tgsub.key`  
✅ Bus registration - Agents sign on via TeleprompterClient  

:: ∎
