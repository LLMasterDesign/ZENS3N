# ▛▞ SHARED MIND ARTIFACT - DEPLOYMENT GUIDE ▞//

**Collective Intelligence System for Telegram Bots**

## 📦 What's In The Box

```
Shared.Mind.Artifact/
├── shared_mind.py          # Core collective intelligence module
├── global_policy.json      # Quality standards & depth rules
├── DEPLOYMENT_GUIDE.md     # This file
├── INTEGRATION_EXAMPLE.py  # Sample bot integration
└── sample_memory.json      # Example shared memory structure
```

## 🎯 What This Artifact Does

**Gives your bots:**
- ✅ **Collective memory** - Bots learn from each other's insights
- ✅ **Depth escalation** - Automatically go deeper on explored topics
- ✅ **Quality control** - Global policy enforces substance
- ✅ **Cross-bot coherence** - Shared knowledge base
- ✅ **Pattern recognition** - Track what topics need depth

**Result:** Bots that get smarter together, not individually.

## 🚀 Quick Deploy (3 Steps)

### Step 1: Copy Files
```bash
# Copy to your bot's _CORE folder
cp shared_mind.py /your/bot/project/_CORE/
cp global_policy.json /your/bot/project/_CORE/
```

### Step 2: Add Import to Bot
```python
# In your bot.py, add to imports:
from shared_mind import (
    generate_depth_prompt,
    add_insight,
    track_topic
)
```

### Step 3: Integrate in Message Handler
```python
# In your handle_message function:

# BEFORE calling OpenAI:
message_count = len(context.user_data.get('messages', []))
depth_context = generate_depth_prompt(
    bot_name="your_bot_name", 
    chat_type=update.message.chat.type,
    message_history_count=message_count
)
full_prompt = SYSTEM_PROMPT + sibling_context + depth_context

# AFTER getting response:
if len(assistant_message) > 100:
    key_insight = assistant_message.split('\n')[0][:150]
    add_insight("your_bot_name", key_insight)
```

## 📋 Full Integration Example

See `INTEGRATION_EXAMPLE.py` for complete working example.

## 🧠 How Collective Intelligence Works

### Scenario: Three bots, one topic

**Day 1 - Vulpes responds to "I'm procrastinating":**
```
Response: "Stop researching productivity systems. Just start."
→ Stores insight: "Procrastination = avoidance, not lack of system"
```

**Day 2 - User asks Noctua about procrastination:**
```
Noctua loads shared memory
Sees: Vulpes already addressed this
Topic count: 2 times explored
Depth level: Go DEEPER

Response: "You're not procrastinating because you don't know what to do. 
You're procrastinating because starting means committing, and committing 
means you might fail. Name what you're actually afraid of."
```

**Day 3 - User asks Trickoon:**
```
Trickoon loads shared memory
Sees: Topic explored 3+ times by siblings
Auto-depth trigger: MAXIMUM

Response: Goes cosmic-deep about avoiding soul work
```

### The Magic:
- ✅ Each bot makes others smarter
- ✅ No redundant answers
- ✅ Automatic depth escalation
- ✅ Collective wisdom accumulates

## 🎛️ Configuration

### Customize Depth Levels
Edit `global_policy.json`:

```json
{
  "response_depth": {
    "surface": "1-2 sentences",
    "medium": "3-5 sentences with context",
    "deep": "Full perspective shift with examples"
  },
  "quality_gates": {
    "min_token_count": 27,
    "require_substance": true,
    "no_generic_advice": true
  }
}
```

### Set Bot-Specific Depth
In `shared_mind.py`, configure:

```python
depth_map = {
    "your_bot": "deep",    # Always go deep
    "helper_bot": "medium", # Balanced
    "quick_bot": "surface"  # Fast answers
}
```

## 📊 Shared Memory Structure

Auto-generated: `glyphbit_shared_memory.json`

```json
{
  "insights": [
    {
      "bot": "noctua",
      "insight": "People treat decisions like tests with wrong answers",
      "timestamp": "2025-10-06 11:30:00"
    }
  ],
  "topics_explored": {
    "decision_making": {
      "count": 5,
      "max_depth": 3
    }
  },
  "context_depth": 2,
  "last_update": "2025-10-06 11:30:00"
}
```

## ⚠️ Requirements

- Python 3.12+ (for bot compatibility)
- `json` module (standard library)
- File write permissions in _CORE folder

## 🔄 Maintenance

### Clear Old Insights
Shared memory auto-keeps last 50 insights.  
To manually clear:
```python
from shared_mind import load_shared_memory, save_shared_memory

memory = load_shared_memory()
memory["insights"] = []
save_shared_memory(memory)
```

### View Current Wisdom
```python
from shared_mind import load_shared_memory

memory = load_shared_memory()
for insight in memory["insights"]:
    print(f"{insight['bot']}: {insight['insight']}")
```

## 🎯 Use Cases

### Multi-Bot Systems
- Group chats with multiple bots
- Bot ensembles that share context
- Teaching/tutoring bot networks

### Knowledge Accumulation
- Bots learn from past conversations
- Build expertise over time
- Reference previous insights

### Depth Management
- Simple questions get quick answers
- Complex topics get deep treatment
- Auto-escalate based on history

## 📝 Integration Checklist

- [ ] Copy `shared_mind.py` to `_CORE/`
- [ ] Copy `global_policy.json` to `_CORE/`
- [ ] Add imports to bot.py
- [ ] Integrate depth context in message handler
- [ ] Store insights after responses
- [ ] Test with multi-message conversations
- [ ] Verify shared memory file creates
- [ ] Check depth escalation works

## 🏷️ Artifact Metadata

```yaml
name: "Shared Mind Artifact"
version: "1.0"
type: "collective_intelligence"
deployment: "drop-in"
dependencies: ["json (stdlib)"]
compatibility: "Any Telegram bot using python-telegram-bot"
created: "⧗-251006"
tested_with: ["GlyphBit Trinity", "Resume Bot"]
```

---

**Created:** October 6th, 2025  
**Type:** Reusable GlyphBit Tool  
**Purpose:** Give bots collective intelligence & depth  
**Deploy Time:** ~5 minutes




