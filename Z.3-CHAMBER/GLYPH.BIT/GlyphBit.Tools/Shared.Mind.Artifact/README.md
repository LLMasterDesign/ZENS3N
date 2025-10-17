# ▛▞ SHARED MIND ARTIFACT ▞//

**Collective Intelligence System for Bot Networks**

## 📦 Artifact Contents

```
Shared.Mind.Artifact/
├── shared_mind.py              # Core module
├── global_policy.json          # Quality standards
├── sample_memory.json          # Example data
├── DEPLOYMENT_GUIDE.md         # How to deploy
├── INTEGRATION_EXAMPLE.py      # Code examples
└── README.md                   # This file
```

## 🎯 What It Does

**Makes bots collectively smarter:**

When one bot learns something → All bots can reference it  
When a topic is explored deeply → All bots know to go deeper next time  
When patterns emerge → All bots recognize them  

**Result:** Bot network that gets wiser together.

## 🧠 The Concept

### Individual Bots (Before):
```
Bot A: Gives advice
Bot B: Gives advice (might repeat what A said)
Bot C: Gives advice (no awareness of A or B)
```

### Shared Mind (After):
```
Bot A: Gives insight → Stores in shared memory
Bot B: Reads A's insight → Builds on it, goes deeper
Bot C: References both A & B → Adds new angle

All three now share collective wisdom
```

## 🚀 Quick Start

**1. Copy files to your bot project:**
```bash
cp shared_mind.py your_bot/_CORE/
cp global_policy.json your_bot/_CORE/
```

**2. Add 3 lines to your bot:**
```python
# Import
from shared_mind import generate_depth_prompt, add_insight

# Before OpenAI call
depth_context = generate_depth_prompt(bot_name, chat_type, message_count)
full_prompt = SYSTEM_PROMPT + depth_context

# After response
add_insight(bot_name, assistant_message[:150])
```

**3. Done!**

Your bot now has collective intelligence.

## 📊 How Depth Works

### Automatic Escalation:
- **Message 1-2:** Surface answers
- **Message 3-6:** Medium depth
- **Message 7+:** Deep insight mode
- **Topic seen before:** Skip to deep automatically

### Example:

**First time asking about procrastination:**
→ Quick practical tip (surface)

**Third time asking:**
→ Full reframe about avoidance patterns (deep)

**Another bot gets same question:**
→ Sees topic explored 3 times → Goes deep immediately

## 🎛️ Customization

### Set Your Bot's Default Depth:
Edit `shared_mind.py`:
```python
depth_map = {
    "your_bot": "deep",     # Always profound
    "helper_bot": "medium", # Balanced
    "quick_bot": "surface"  # Fast answers
}
```

### Adjust Quality Gates:
Edit `global_policy.json`:
```json
{
  "quality_gates": {
    "min_token_count": 50,        # Require longer responses
    "require_substance": true,    # No generic advice
    "must_shift_perspective": true // Every response teaches something
  }
}
```

## 📂 Files Created

### On First Run:
`glyphbit_shared_memory.json` - Auto-created in _CORE/

Contains:
- All bot insights
- Topic exploration history
- Depth tracking data

### Persists Across:
- Bot restarts
- Different conversations
- All bots in the network

## 🔬 Testing

### Verify It's Working:

1. **Ask bot a question** → Get response
2. **Check shared memory:**
   ```bash
   cat _CORE/glyphbit_shared_memory.json
   ```
3. **See insight stored?** ✅ Working!
4. **Ask follow-up** → Should go deeper
5. **Ask another bot same thing** → Should reference first bot's insight

## 🎯 Tested With

✅ **GlyphBit Trinity** (Noctua, Vulpes, Trickoon)  
✅ **Multi-bot group chats**  
✅ **Individual DM conversations**  

## 📋 Deployment Checklist

- [ ] Copy `shared_mind.py` to `_CORE/`
- [ ] Copy `global_policy.json` to `_CORE/`
- [ ] Add imports to bot.py
- [ ] Integrate depth_prompt in message handler
- [ ] Add insight storage after response
- [ ] Test with multi-message conversation
- [ ] Verify `glyphbit_shared_memory.json` creates
- [ ] Test depth escalation (7+ messages)
- [ ] Deploy to all bots in network
- [ ] Monitor collective wisdom growth

## 🏷️ Artifact Metadata

```yaml
╔═══════════════════════════════════════════╗
║   GLYPHBIT ARTIFACT: SHARED MIND v1.0    ║
╚═══════════════════════════════════════════╝

Name: Shared Mind
Type: Collective Intelligence Module
Version: 1.0
Created: ⧗-251006
Deployment: Drop-in
Dependencies: json (stdlib)
Compatible: Telegram bots (python-telegram-bot)
Purpose: Give bot networks collective memory & depth
Status: Production-ready
```

---

## 🎁 Bonus Features

- Auto-cleanup (keeps last 50 insights)
- Thread-safe file operations
- Graceful degradation (works even if file missing)
- Zero external dependencies
- Lightweight (<5KB memory footprint)

---

**Package this artifact and drop it into any bot project to give it collective intelligence!**

Created: October 6th, 2025  
Packaged by: GlyphBit Forge  
Ready for: Immediate deployment




