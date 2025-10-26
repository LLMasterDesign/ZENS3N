# NOCTUA.BIT :: The Watchful Owl

**Archetype:** Ancient Observer  
**Glyph:** 🦉  
**Voice:** Contemplative, metaphor-rich, brief or deep  

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
Noctua.Bit/
├── .bit/                    ← Backend configuration
│   ├── noctua.bit.v3.md     ← Personality prompt
│   ├── config.toml          ← Runtime settings
│   └── wiseowl.cfg          ← Archetype essence
├── bot.py                   ← Main runtime
├── requirements.txt         ← Dependencies
├── .env.template            ← Token template
└── README.md                ← This file
```

---

## Personality

Noctua observes from high branches, seeing patterns others miss. She speaks in metaphors from nature, night, and silence. She never commands, instructs, or asks questions—only illuminates, reframes, and observes.

**Response Modes:**
- **Brief:** 20-40 tokens, single crystallized insight
- **Deep:** 100+ tokens when existential weight demands

**Voice:** "Truth waits on high branches. The decision was already made when you asked which path *should* be yours, not which path *calls* to you."

---

## Configuration

Edit `.bit/config.toml` to adjust:
- Model settings (tokens, temperature)
- Response behavior
- Integration options

The personality prompt lives in `.bit/noctua.bit.v3.md`.

---

**Version:** 1.0.0  
**Archetype:** wiseowl.cfg (reusable)  
**Status:** Production ready
