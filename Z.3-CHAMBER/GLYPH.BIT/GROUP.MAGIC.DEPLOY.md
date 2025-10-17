# ▛▞ GROUP MAGIC - DEPLOYMENT PLAN ∎

## 🎯 WHAT YOU NEED TO KNOW

### Q: How does `/mode` work?
**A: Chat-wide, all bots, all topics.**

When you run `/mode group` in a chat:
- It sets the mode for **THE ENTIRE CHAT**
- Applies to **ALL 3 BOTS** (Noctua, Vulpes, Trickoon)
- Applies to **ALL TOPICS** in that chat

**Example:**
```
In Group "Mystic Circle":
Admin: /mode group

Result:
- Noctua responds everywhere in this chat
- Vulpes responds everywhere in this chat
- Trickoon responds everywhere in this chat
- All 3 know about each other (sibling awareness)
```

---

### Q: What about per-topic control?
**A: Use `/mute` for individual bots in specific topics.**

The **chat mode is global**, but you can **mute individual bots per-topic**:

```
Chat mode: group (all bots respond)

In Topic "Philosophy":
User: /mute trickoon
→ Trickoon silent in THIS topic
→ Noctua and Vulpes still respond here

In Topic "Random":
→ All 3 bots still respond (mute was topic-specific)
```

---

### Q: What are the modes?

| Mode | Behavior |
|------|----------|
| `group` | All bots respond, sibling aware (default) |
| `inline` | Bots ONLY respond to `@botname query`, silent otherwise |
| `live` | Maximum engagement, all bots respond everywhere |

**Set once per chat:** `/mode <group|inline|live>`

---

## 🚀 DEPLOYMENT STEPS (Your End)

### CURRENT STATE:
- All 3 bots are live and running
- They respond to messages now
- No group magic features yet

### TO ADD GROUP MAGIC:

#### Step 1: Stop All Bots
```cmd
# In each bot's terminal window, press Ctrl+C
# Or close the terminal windows
```

You need to stop:
- Noctua.Bit
- Vulpes.Bit
- Trickoon.Bit

---

#### Step 2: Code Update (I'll do this)
I'll update all 3 `bot.py` files to:
1. Import `group_config` from `_CORE`
2. Add `should_respond()` check in message handler
3. Add sibling awareness to system prompts
4. Add new commands: `/mode`, `/mute`, `/unmute`
5. Add natural language detection for mute commands

**You don't need to do anything for this step.**

---

#### Step 3: Restart All Bots
```cmd
# Run each bot's RUN_BOT.bat
D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit\RUN_BOT.bat
D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Vulpes.Bit\RUN_BOT.bat
D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Trickoon.Bit\RUN_BOT.bat
```

---

#### Step 4: Test in Your Group
```
1. All 3 bots should already be in your group
2. Send "hi" → all 3 respond (default mode: group)
3. Try: /mode → shows current mode
4. Try: /mute noctua → Noctua goes silent in this topic
5. Try: "vulpes stop responding" → Vulpes muted
6. Try: /unmute vulpes → Vulpes returns
```

---

## 📊 BEHAVIOR BREAKDOWN

### Scenario 1: Fresh Group, No Config
```
[Add all 3 bots to new group]
Default behavior: "group" mode
→ All 3 respond
→ All 3 are sibling aware
```

### Scenario 2: Set Inline Mode
```
Admin: /mode inline
→ All 3 bots stop responding to regular messages
→ Only respond when used inline: @noctua_bot query
```

### Scenario 3: Mute One Bot in One Topic
```
Chat mode: group

In Topic "Quick Questions":
User: /mute noctua
→ Noctua silent HERE
→ Vulpes and Trickoon still respond HERE

In Topic "Deep Thoughts":
→ All 3 bots respond (mute doesn't carry over)
```

### Scenario 4: Mute Bot Everywhere in Chat
```
User: /mute noctua
(without a topic - in main chat or group without topics)
→ Noctua silent EVERYWHERE in this chat
→ Vulpes and Trickoon still active
```

---

## 🔄 WHAT CHANGES FOR YOU?

### BEFORE (Current):
- Bots respond to everything
- No awareness of each other
- No way to control them except removing from chat

### AFTER (Group Magic):
- Bots still respond to everything by default
- **NEW:** They know about siblings in groups
- **NEW:** `/mode` command to set chat behavior
- **NEW:** `/mute` / `/unmute` to control individual bots
- **NEW:** Natural language: "noctua stop" works

---

## 🎛️ COMMANDS YOU'LL HAVE

### Admin Commands (group creators/admins):
```
/mode                  → Show current mode
/mode group            → Set group mode (default)
/mode inline           → Set inline-only mode
/mode live             → Set live/max engagement mode
```

### User Commands (anyone):
```
/mute noctua           → Mute Noctua in this topic
/unmute vulpes         → Unmute Vulpes
/mute trickoon         → Mute Trickoon

Natural language:
"noctua stop responding"
"vulpes shut up"
"fox be quiet"
"trickoon come back"
```

---

## 📁 FILES THAT WILL BE UPDATED

```
GLYPH.BIT/
├── _CORE/
│   ├── group_config.py        ✅ Already created
│   └── chat_settings.json     (will be created automatically)
├── Noctua.Bit/
│   └── bot.py                 ⏳ Needs update
├── Vulpes.Bit/
│   └── bot.py                 ⏳ Needs update
└── Trickoon.Bit/
    └── bot.py                 ⏳ Needs update
```

**No new dependencies needed** - everything uses existing packages.

---

## ⚠️ IMPORTANT NOTES

### 1. Settings are Persistent
```
chat_settings.json stores:
- Chat modes (per chat)
- Mute states (per bot, per topic)

These survive bot restarts!
```

### 2. Shared Settings File
```
All 3 bots read from: _CORE/chat_settings.json
- Change mode once, all bots see it
- Mute in one bot's command, others respect it
```

### 3. Backwards Compatible
```
- Bots still work in DMs (1-on-1)
- Inline queries still work
- Nothing breaks existing functionality
- Just ADDS group features
```

---

## 🚦 READY TO PROCEED?

**On your end:**
1. ✅ Read this deployment plan
2. ⏳ When ready, stop all 3 bots
3. ⏳ Let me know when stopped
4. ⏳ I'll update the code
5. ⏳ You restart the bots
6. ✅ Test in your group

**Questions to confirm:**
- Is the group you want to test in already set up?
- Are all 3 bots already members of that group?
- Any topics created, or just one main chat?

---

**▛▞ Mode = chat-wide, Mutes = per-topic, Deploy = stop → update → restart ∎**





