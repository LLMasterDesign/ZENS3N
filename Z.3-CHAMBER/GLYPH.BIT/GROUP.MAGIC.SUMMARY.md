# ▛▞ GROUP MAGIC - IMPLEMENTATION SUMMARY ∎

## ✅ WHAT WE BUILT

**Hybrid Mode System** - chat-level settings with topic-based muting

---

## 🏗️ ARCHITECTURE

### 1. Shared Configuration (`_CORE/group_config.py`)
```python
GLYPHBIT_ROSTER = {
    "noctua": {...},
    "vulpes": {...},
    "trickoon": {...}
}

# All bots read from: _CORE/chat_settings.json
# Format:
{
  "chat_id": {
    "mode": "group|inline|live",
    "mutes": {
      "topic_id": ["bot_name", ...],
      "all": [...]
    }
  }
}
```

### 2. Response Logic
```python
should_respond(bot_name, update):
    1. Check if muted in this chat/topic → False
    2. Check chat mode
    3. Return True/False
```

### 3. Sibling Awareness
```python
get_sibling_awareness(current_bot, chat_type):
    # In groups → inject sibling info into system prompt
    # In DMs → no siblings, solo mode
```

---

## 🎯 KEY FEATURES

### ✓ Chat-Level Modes
- `/mode group` → Default, all respond, sibling aware
- `/mode inline` → Only @botname inline queries
- `/mode live` → Maximum engagement everywhere

### ✓ Topic-Based Muting
- `/mute noctua` → Mutes in THIS topic only
- Other topics → Noctua still responds
- Natural language works: `"vulpes shut up"`

### ✓ Natural Language Commands
```python
detect_mute_command(text):
    "noctua stop responding" → ("noctua", "mute")
    "fox come back"          → ("vulpes", "unmute")
```

### ✓ Sibling Awareness (Groups Only)
- Bots know about each other
- Can reference siblings in responses
- Only in groups, not DMs

### ✓ Hybrid Behavior
- Respond everywhere by default
- Context-aware (knows if in group vs DM)
- Respects mutes and chat modes

---

## 📁 FILE STRUCTURE

```
GLYPH.BIT/
├── _CORE/
│   ├── group_config.py        ← Shared logic
│   └── chat_settings.json     ← Shared storage (created on first use)
├── Noctua.Bit/
│   └── bot.py                 ← Imports group_config
├── Vulpes.Bit/
│   └── bot.py                 ← Imports group_config
├── Trickoon.Bit/
│   └── bot.py                 ← Imports group_config
├── GROUP.MAGIC.GUIDE.md       ← User guide
└── GROUP.MAGIC.SUMMARY.md     ← This file
```

---

## 🔌 INTEGRATION (Next Step)

### Update each bot.py:

```python
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '_CORE'))
from group_config import (
    should_respond,
    get_sibling_awareness,
    detect_mute_command,
    mute_bot,
    unmute_bot,
    set_chat_mode,
    format_mode_info
)

BOT_NAME = "noctua"  # or "vulpes" or "trickoon"

# In message handler:
async def handle_message(update, context):
    # Check if should respond
    if not should_respond(BOT_NAME, update):
        return  # Muted or wrong mode
    
    # Check for mute commands
    text = update.message.text
    bot_target, action = detect_mute_command(text)
    if bot_target:
        chat_id = update.message.chat.id
        topic_id = getattr(update.message, 'message_thread_id', None)
        
        if action == "mute":
            mute_bot(bot_target, chat_id, topic_id)
            await update.message.reply_text(f"▛▞ {bot_target.upper()} muted in this space ∎")
        elif action == "unmute":
            unmute_bot(bot_target, chat_id, topic_id)
            await update.message.reply_text(f"▛▞ {bot_target.upper()} returns ∎")
        return
    
    # Add sibling awareness to prompt
    chat_type = update.message.chat.type
    sibling_context = get_sibling_awareness(BOT_NAME, chat_type)
    full_prompt = SYSTEM_PROMPT + sibling_context
    
    # ... rest of response logic
```

### Add commands:

```python
async def mode_command(update, context):
    """Handle /mode command."""
    chat_id = update.message.chat.id
    
    # Check if admin
    member = await update.effective_chat.get_member(update.effective_user.id)
    if member.status not in ["creator", "administrator"]:
        await update.message.reply_text("Admin only command.")
        return
    
    # Get mode argument
    if context.args:
        new_mode = context.args[0].lower()
        if set_chat_mode(chat_id, new_mode):
            await update.message.reply_text(f"▛▞ Chat mode set to: {new_mode} ∎")
        else:
            await update.message.reply_text("Invalid mode. Use: group, inline, or live")
    else:
        # Show current mode
        info = format_mode_info(chat_id)
        await update.message.reply_text(info, parse_mode='Markdown')

async def mute_command(update, context):
    """Handle /mute command."""
    if not context.args:
        await update.message.reply_text("Usage: /mute <bot_name>")
        return
    
    bot_target = context.args[0].lower()
    chat_id = update.message.chat.id
    topic_id = getattr(update.message, 'message_thread_id', None)
    
    if mute_bot(bot_target, chat_id, topic_id):
        await update.message.reply_text(f"▛▞ {bot_target.upper()} muted ∎")
    else:
        await update.message.reply_text("Unknown bot.")

# Register handlers:
app.add_handler(CommandHandler("mode", mode_command))
app.add_handler(CommandHandler("mute", mute_command))
app.add_handler(CommandHandler("unmute", unmute_command))
```

---

## 🧪 TEST SCENARIOS

### Scenario 1: All 3 in a group
1. Add all 3 bots to group
2. Say "hi" → all 3 respond
3. `/mode group` (default) → all respond, sibling aware
4. `/mute noctua` → owl stops, fox and raccoon continue
5. `"noctua come back"` → owl returns

### Scenario 2: Topic-based control
1. Create supergroup with topics
2. Add all 3 bots
3. In Topic A: `/mute vulpes` → fox silent in A
4. In Topic B: vulpes still responds (mute was topic-specific)

### Scenario 3: Inline only
1. `/mode inline` in group
2. Regular messages → nobody responds
3. `@noctua_bot wisdom` → Noctua responds inline
4. `/mode group` → back to normal

---

## 📊 BENEFITS

✓ **One skeleton** - same code for all bots  
✓ **Lock & ship** - set mode, deploy  
✓ **Flexible** - per-chat and per-topic control  
✓ **Natural** - conversational mute/unmute  
✓ **Sibling aware** - bots know about each other  
✓ **Scalable** - no need for dozens of configs  

---

## 🚀 NEXT STEPS

1. ✅ Core logic built (`group_config.py`)
2. ⏳ Integrate into each bot (`bot.py` updates)
3. ⏳ Test in real group
4. ⏳ Document edge cases
5. ⏳ Add `/mode` and `/mute` commands

---

**▛▞ Architecture complete, ready for integration ∎** 🦉🦊🦝





