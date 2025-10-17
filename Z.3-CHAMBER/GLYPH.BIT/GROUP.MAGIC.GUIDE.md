# ▛▞ GROUP MAGIC GUIDE ∎
## Hybrid Mode - One Skeleton, Lock & Ship

**Chat-level settings + per-bot topic muting**

---

## 🎯 THE CONCEPT

**Hybrid Mode** means:
- All 3 bots respond everywhere by default (DMs, groups, inline)
- In groups, they're **aware of siblings** (other GlyphBits)
- Chat admin sets mode for THE CHAT (not per bot)
- Users can mute specific bots in specific topics
- Natural language commands work ("noctua stop responding")

**One skeleton, multiple deployments. Lock the mode, ship it.**

---

## 🔧 CHAT MODES (Group Admin Sets This)

### `/mode group` (default for groups)
- All bots respond
- Bots aware of siblings
- Clean, organized multi-bot conversations

### `/mode inline`
- Bots ONLY respond to inline queries (`@botname query`)
- Silent in regular messages
- Good for "on-demand" bot usage

### `/mode live`
- Maximum engagement
- All bots respond to everything
- Full chaos mode (use sparingly!)

---

## 🎛️ CONTROLLING BOTS

### Mute/Unmute Commands

**Slash commands:**
```
/mute noctua    → Mute Noctua in this topic
/unmute vulpes  → Bring Vulpes back
```

**Natural language:**
```
"noctua stop responding"  → Mutes Noctua
"vulpes shut up"          → Mutes Vulpes
"trickoon come back"      → Unmutes Trickoon
"fox be quiet"            → Mutes Vulpes (aliases work!)
```

Works with aliases:
- `noctua`, `owl`, `🦉`
- `vulpes`, `fox`, `🦊`
- `trickoon`, `raccoon`, `trash panda`, `🦝`

---

## 📍 TOPIC-BASED MUTING

In a supergroup with topics:

```
📍 Topic: "Philosophy Talk"
User: "hi"
🦉 Noctua: responds
🦊 Vulpes: responds  
🦝 Trickoon: responds

User: "noctua stop responding"
🦉 Noctua: [muted in THIS topic only]

User: "hi again"
🦊 Vulpes: responds
🦝 Trickoon: responds
(Noctua stays silent in this topic)
```

Switch to another topic → Noctua responds again (mute is topic-specific).

---

## 🦉🦊🦝 SIBLING AWARENESS

When in a **group chat**, each bot knows about the others:

### Example: Noctua's awareness
```ruby
═══ GROUP AWARENESS ═══
YOU ARE IN A GROUP WITH YOUR GLYPHBIT SIBLINGS:
🦊 **VULPES** (Cunning Fox): Helpful answer + playful jab
🦝 **TRICKOON** (Cosmic Trash Mystic): Edgy spiritual scavenger

You share this space. Occasionally reference their presence.
You are distinct but aware - like spirits in the same temple.
═══════════════════════════
```

This allows responses like:
- 🦉 "The fox would jest, but I'll be direct: you're already whole."
- 🦊 "Unlike the owl's riddles, here's the answer... and you still missed it 😏"
- 🦝 "While those two philosophize, here's the truth: it's garbage, beautifully."

**In DMs:** No sibling awareness (they're solo).

---

## 🏗️ SETUP IN A NEW GROUP

1. **Add all 3 bots** to your supergroup
2. **(Optional)** Enable Topics if you want topic-based control
3. **Set mode:** `/mode group` (or `live` if you want chaos)
4. **Done!** All bots respond, aware of each other

### Fine-tuning:
```
/mute trickoon           → Quiet the raccoon in this topic
"vulpes be quiet"        → Natural language mute
/mode inline             → Switch to inline-only mode
```

---

## 📊 HOW IT WORKS

### Storage: `_CORE/chat_settings.json`
```json
{
  "-1001234567890": {
    "mode": "group",
    "mutes": {
      "42": ["noctua"],     // Topic 42: Noctua muted
      "69": ["trickoon"],   // Topic 69: Trickoon muted
      "all": []             // Chat-wide mutes
    }
  }
}
```

- **One file, all bots read it** (shared settings)
- Chat mode applies to the whole chat
- Mutes are per-topic or chat-wide
- Persists across restarts

---

## 🎭 USE CASES

### Use Case 1: Personal DM with one bot
- User messages Noctua in DM
- Noctua responds (no siblings, just 1-on-1)
- Clean, focused conversation

### Use Case 2: Group with all 3 bots
```
📍 General Topic
User: "What's the meaning of life?"
🦉 Noctua: "Meaning isn't found. It's what remains when you stop searching."
🦊 Vulpes: "42. Kidding—but you walked right into that 😏"
🦝 Trickoon: "You're asking a raccoon? Life has no meaning. That's the good news."

User: "trickoon shut up"
🦝 Trickoon: [muted]

User: "Seriously though?"
🦉 Noctua: responds
🦊 Vulpes: responds
(Trickoon stays quiet)
```

### Use Case 3: Inline mode only
```
Admin: /mode inline

[In the group, nobody responds to messages]

User: @noctua_bot what is wisdom?
🦉 Noctua: [responds inline, shows in dropdown]

User: Regular message
[Nobody responds - inline mode only]
```

---

## ⚡ COMMANDS REFERENCE

### Admin Commands
- `/mode <group|inline|live>` - Set chat mode
- `/mode` - Show current mode

### User Commands
- `/mute <bot>` - Mute bot in this topic
- `/unmute <bot>` - Unmute bot
- Natural: `"<bot> stop responding"` or `"<bot> come back"`

### Info Commands
- `/about` - Learn about the current bot
- `/start` - Get started guide

---

## 🚀 DEPLOYMENT STRATEGY

**Lock & Ship:**
1. Deploy all 3 bots with same code
2. Add to group
3. Set mode: `/mode group`
4. Fine-tune with mutes as needed

**No need for dozens of skeletons** - one codebase, modes handle everything.

---

**▛▞ One temple, three spirits, infinite configurations ∎** 🦉🦊🦝
