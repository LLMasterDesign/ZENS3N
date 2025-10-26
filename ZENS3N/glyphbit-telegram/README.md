# GLYPHBIT-TELEGRAM :: Bot Deployment Layer

**Container 2 of 2** - Where the bots actually run

---

## Purpose

This container runs all Telegram bot instances:
- **Bot processes** (Noctua, Vulpes, Trickoon, ...)
- **Telegram API connections**
- **Message handling**
- **Scales to 100+ bots**

---

## Structure

```
glyphbit-telegram/
├── bots/                      ← All bot instances
│   ├── Noctua.Bit/
│   │   ├── .bit/              ← Backend config
│   │   │   ├── noctua.bit.v3.md
│   │   │   ├── config.toml
│   │   │   └── wiseowl.cfg
│   │   ├── bot.py
│   │   ├── requirements.txt
│   │   └── .env
│   ├── Vulpes.Bit/
│   ├── Trickoon.Bit/
│   └── [NewBot.Bit]/ ← Add more here
├── launch_trinity.py          ← Auto-launcher
├── .env.global                ← Shared tokens
└── README.md                  ← This file
```

---

## How It Works

### Auto-Discovery
The launcher scans for `*.Bit/` folders:
```bash
python launch_trinity.py
```

Output:
```
🔍 Scanning for bots...
  ✅ Found: Noctua.Bit
  ✅ Found: Vulpes.Bit
  ✅ Found: Trickoon.Bit

🚀 Launching 3 bots in parallel...
```

### Adding New Bots

1. Create `NewBot.Bit/` folder
2. Add `.bit/` config (personality + config.toml + archetype.cfg)
3. Copy `bot.py` template
4. Add token to `.env`
5. Restart container

**The launcher auto-detects and runs it.** No code changes needed.

---

## Scaling

```
3 bots → 10 bots → 50 bots → 100 bots
```

Each bot:
- ✅ Shares _CORE modules (no duplication)
- ✅ Reuses archetypes
- ✅ Runs independently
- ✅ Lightweight footprint

**One container, infinite bots.**

---

## Environment Variables

Each bot needs:
```env
# In bot's .env file:
TELEGRAM_BOT_TOKEN=bot-token-here
OPENAI_API_KEY=openai-key-here
```

Or use `.env.global` for shared credentials.

---

## Commands

```bash
# Launch all bots
python launch_trinity.py

# Launch on Windows
LAUNCH_TRINITY.bat

# Launch on Linux/Mac
./launch_trinity.sh

# Launch in Docker
docker-compose up glyphbit-telegram
```

---

**Version:** 1.0.0  
**Type:** Bot deployment layer  
**Status:** Production ready  
**Capacity:** 3-100+ bots

