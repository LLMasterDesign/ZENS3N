# ▛▞ GLYPHBIT LAUNCHER OPTIONS ∎

## 🚀 THREE WAYS TO LAUNCH

### Option 1: Windows Terminal with Tabs (RECOMMENDED)
```powershell
cd D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT
.\LAUNCH_ALL.ps1 -Tabs
```

**Result:**
- Opens Windows Terminal
- 3 tabs (Noctua, Vulpes, Trickoon)
- Each bot in its own tab
- Easy to switch between them
- Close tab or Ctrl+C to stop individual bot

**Requires:** Windows Terminal ([Download here](https://aka.ms/terminal))

---

### Option 2: Single Window (Background Jobs)
```powershell
cd D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT
.\LAUNCH_ALL.ps1 -Single
```

**Result:**
- All 3 bots run as PowerShell background jobs
- One window, less clutter
- Use commands to manage:
  - `Get-Job` - List all bots
  - `Receive-Job -Name NOCTUA -Keep` - View bot output
  - `Stop-Job -Name VULPES` - Stop one bot
  - `Stop-Job *` - Stop all bots

**Good for:** Keeping desktop clean, running in background

---

### Option 3: Separate Windows (Classic)
```powershell
cd D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT
.\LAUNCH_ALL.ps1
```

**Result:**
- 3 separate console windows
- Traditional approach
- Each window shows its bot's output
- Close window or Ctrl+C to stop

**Good for:** Monitoring all three at once

---

## 📋 QUICK REFERENCE

### Launch Commands
```powershell
# Tabs (best)
.\LAUNCH_ALL.ps1 -Tabs

# Single window
.\LAUNCH_ALL.ps1 -Single

# Separate windows
.\LAUNCH_ALL.ps1
```

### Managing Background Jobs
```powershell
# List all running bots
Get-Job

# View output of a specific bot
Receive-Job -Name NOCTUA -Keep

# Stop one bot
Stop-Job -Name VULPES

# Stop all bots
Stop-Job *

# Remove completed jobs
Remove-Job *
```

---

## 🛠️ TROUBLESHOOTING

### "Cannot be loaded because running scripts is disabled"
```powershell
# Run this ONCE as admin:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Windows Terminal not found"
- Install from: https://aka.ms/terminal
- Or use `-Single` or no flag instead of `-Tabs`

### Check if bots are configured
The launcher automatically checks for `.env` files and reports any missing.

---

## 🎯 RECOMMENDED WORKFLOW

**Daily use:**
```powershell
# Start all 3 in tabs
.\LAUNCH_ALL.ps1 -Tabs

# Work with your bots...

# Stop: Close tabs or Ctrl+C in each
```

**Development/Testing:**
```powershell
# Launch one bot manually for testing
cd Noctua.Bit
python bot.py

# Or use the batch file
.\RUN_BOT.bat
```

---

**▛▞ One command, three spirits ∎** 🦉🦊🦝

