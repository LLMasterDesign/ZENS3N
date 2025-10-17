# ▛▞ GlyphBit Control Panel ▞//

**Interactive Bot Launcher & Status Monitor**

## 🎮 Quick Start

Double-click: `LAUNCH_CONTROL_PANEL.bat`

Or run:
```powershell
.\CONTROL_PANEL.ps1
```

Auto-start all bots:
```powershell
.\CONTROL_PANEL.ps1 -AutoStart
```

## 📊 Interface

```
╔════════════════════════════════════════════════════════════╗
║          GLYPHBIT CONTROL PANEL v1.0                      ║
║          Bot Launcher & Status Monitor                    ║
╚════════════════════════════════════════════════════════════╝

BOT STATUS:
─────────────────────────────────────────────────────────────
  🟢 🦉 NOCTUA        [Online]
  🟢 🦊 VULPES        [Online]
  🟢 🦝 TRICKOON      [Online]
  🔴 📄 RESUME        [Offline]

COMMANDS:
─────────────────────────────────────────────────────────────
  [S]  Start All Bots
  [R]  Restart All Bots
  [X]  Stop All Bots
  [1]  Start/Restart Noctua 🦉
  [2]  Start/Restart Vulpes 🦊
  [3]  Start/Restart Trickoon 🦝
  [4]  Start/Restart Resume Bot 📄
  [U]  Update Status
  [H]  Show Help
  [Q]  Quit (stops all bots)

Enter command: _
```

## 🎯 Features

✅ **Real-time Status** - Green/red indicators  
✅ **Individual Control** - Start/stop any bot  
✅ **Batch Operations** - Control all bots at once  
✅ **Always Open** - Keep panel running, control from Telegram  
✅ **Quick Refresh** - Type R to restart all  
✅ **Visual Feedback** - Emojis + colors

## 🔄 Telegram + Control Panel

### In Control Panel:
- Press `S` to start all bots
- Monitor status with green 🟢 / red 🔴

### In Telegram:
- `/restart` - Reboot individual bot
- Bot reboots, control panel updates automatically

### Best Workflow:
1. Launch control panel → Keep it open
2. Press `S` to start all bots
3. Use Telegram for individual bot `/restart` commands
4. Control panel shows status in real-time
5. Never need to touch individual RUN_BOT.bat files again!

## ⚠️ Requirements

- **Python 3.12** (already configured in all scripts)
- All bots have `.env` files configured

## 🎨 Visual Features

- **Green 🟢** = Bot online and running
- **Red 🔴** = Bot offline
- **Emoji indicators** = Quick visual reference
- **Color-coded commands** = Easy to read
- **Frame border** = Classic GlyphBit style

---

**Created:** October 6th, 2025  
**Purpose:** Centralized bot management & monitoring  
**Style:** Interactive status dashboard




