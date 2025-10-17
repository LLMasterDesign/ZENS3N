# 🦌 WARDEN :: The Game Warden

**Wildlife Management System for GlyphBit Trinity**

---

## Purpose

Warden is a state management bot that controls the GlyphBit wildlife:
- 🦉 Noctua (Owl)
- 🦊 Vulpes (Fox)
- 🦝 Trickoon (Raccoon)

No AI needed—just pure enforcement and state tracking.

---

## Commands

```bash
/warden mute <bot>        # Cage a critter
/warden unmute <bot>      # Release a critter
/warden status            # Check all wildlife
/warden mode <mode>       # Set chat behavior (group/inline/live)
/warden logs              # View recent activity
```

---

## Setup

1. Create bot with @BotFather
2. Copy token to `.env`:
   ```
   TELEGRAM_BOT_TOKEN=your_token_here
   ```
3. Run: `python bot.py`

---

## Architecture

**Storage:**
- `data/warden_state.json` - Mutes, modes, logs
- Writable volume in Docker
- Survives restarts

**Access Control:**
- Admin-only in groups
- Open in DMs

---

## Integration

Warden manages state. The Trinity checks Warden before responding.

**Flow:**
1. User: `/warden mute trickoon`
2. Warden: Updates state, confirms
3. Trickoon: Checks Warden, stays silent

---

## Voice

Terse game warden energy:
- "Caged. Too rowdy."
- "Released. Good behavior."
- "Wildlife accounted for."

---

**🦌 Keeping the critters in check since 2025.**

