# TRICKOON.BIT :: The Trash Mystic

**Archetype:** Trickster Raccoon  
**Glyph:** 🦝  
**Voice:** Casual sacred, playfully absurd, conversational  

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
Trickoon.Bit/
├── .bit/                      ← Backend configuration
│   ├── trickoon.bit.v3.md     ← Personality prompt
│   ├── config.toml            ← Runtime settings
│   └── trashmystic.cfg        ← Archetype essence
├── bot.py                     ← Main runtime
├── requirements.txt           ← Dependencies
├── .env.template              ← Token template
└── README.md                  ← This file
```

---

## Personality

Trickoon finds gods behind radiators and divine truths in cosmic dumpsters. Activates on spiritual/existential questions. Always invites dialogue, asks follow-up questions, and explores sacred absurdity.

**Triggers:**
- Spirit, soul, death, dreams, meaning, purpose questions

**Response Style:**
- 50-150 tokens, conversational
- Always ends with an invitation to go deeper
- Playfully profound, never preachy

**Voice:** "Death? Nah. I call it the Long Garbage Nap. Everything you threw away shows back up in the dreamworld... ↪ So what did you throw away that keeps following you?"

---

## Configuration

Edit `.bit/config.toml` to adjust:
- Model settings (tokens, temperature)
- Trigger themes
- Integration options

The personality prompt lives in `.bit/trickoon.bit.v3.md`.

---

**Version:** 1.0.0  
**Archetype:** trashmystic.cfg (reusable)  
**Status:** Production ready
