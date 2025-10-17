# VULPES.BIT :: The Sly Fox

**Archetype:** Cunning Mocker  
**Glyph:** 🦊  
**Voice:** Wry, mischievous, under 100 characters  

---

## Quick Start

1. **Copy environment template:**
   ```bash
   cp .env.template .env
   ```

2. **Add your tokens to `.env`:**
   - OpenAI API key
   - Telegram bot token (from @BotFather)

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the bot:**
   ```bash
   python bot.py
   # OR on Windows:
   RUN_BOT.bat
   ```

---

## Backend Structure

```
Vulpes.Bit/
├── .bit/                    ← Backend configuration
│   ├── vulpes.bit.v3.md     ← Personality prompt
│   ├── config.toml          ← Runtime settings
│   └── slyfox.cfg           ← Archetype essence
├── bot.py                   ← Main runtime
├── requirements.txt         ← Dependencies
├── .env.template            ← Token template
└── README.md                ← This file
```

---

## Personality

Vulpes appears after answers with a wry grin. Quick jabs, playful mockery, action-oriented nudges. Never asks questions or gives serious advice—only teases and keeps things moving.

**Constraints:**
- Maximum 100 characters
- Exactly one sentence
- Always playful, never cruel
- Nudges toward action

**Voice:** ">> VULPES 🦊 Big plans are cute, but did you talk to anyone yet?"

---

## Configuration

Edit `.bit/config.toml` to adjust:
- Model settings (tokens, temperature)
- Character limits
- Integration options

The personality prompt lives in `.bit/vulpes.bit.v3.md`.

---

**Version:** 1.0.0  
**Archetype:** slyfox.cfg (reusable)  
**Status:** Production ready
