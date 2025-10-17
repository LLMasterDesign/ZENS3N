# 🔧 GLYPHBIT CORE ENGINE

**Centralized bot logic - personality agnostic**

---

## 🎯 CONCEPT

**Problem:** Bot code mixed with personality/prompts makes it hard to:
- Edit prompts without breaking bots
- Test different personalities
- Version control prompts separately
- Write prompts in different formats

**Solution:** Separate the "guts" (bot logic) from the "personality" (prompts).

```
Bot Code (Python) ←→ Prompt Files (Any format)
    [STABLE]              [EDITABLE]
```

---

## 📁 ARCHITECTURE

```
_CORE/
├── glyphbit_engine.py    [The centralized bot logic]
└── README.md             [This file]

_PROMPTS/
├── noctua.prompt.txt     [Owl personality]
├── vulpes.prompt.txt     [Fox personality]
├── trickoon.prompt.txt   [Raccoon personality]
└── custom.prompt.rb      [Your Ruby/Rust prompts]

Noctua.Bit/
├── bot.py                [Just calls engine + config]
├── config.json           [Points to prompt file]
└── .env                  [API keys]
```

---

## 🚀 HOW IT WORKS

### Old Way (Messy):
```python
# Prompt hardcoded in bot.py
SYSTEM_PROMPT = """You are Noctua..."""

# To change personality, edit Python code
```

### New Way (Clean):
```python
# bot.py is now tiny:
from _CORE.glyphbit_engine import GlyphBitEngine

config = {
    'bot_name': 'Noctua',
    'bot_glyph': '🦉',
    'prompt_file': '../_PROMPTS/noctua.prompt.txt',
    # ... other settings
}

engine = GlyphBitEngine(config)
engine.run()
```

---

## ✨ BENEFITS

### 1. **Edit Prompts Without Breaking Bots**
Change `noctua.prompt.txt` while bot is running.
Use `/reload` command to hot-reload!

### 2. **Write Prompts in Any Format**
```
_PROMPTS/
├── noctua.prompt.txt        [Plain text]
├── vulpes.prompt.md         [Markdown]
├── trickoon.prompt.rb       [Ruby-style]
├── custom.prompt.yaml       [YAML]
└── experimental.prompt.rs   [Rust-style]
```

### 3. **Version Control Separately**
```bash
git commit _CORE/  # Stable bot code
git commit _PROMPTS/  # Experimental prompts
```

### 4. **Test Multiple Personalities**
```python
# Same bot, different personality
config['prompt_file'] = 'noctua_aggressive.prompt.txt'
config['prompt_file'] = 'noctua_gentle.prompt.txt'
config['prompt_file'] = 'noctua_cryptic.prompt.txt'
```

### 5. **Hot Reload Without Restart**
```
User: /reload
Bot: 🦉 Prompt Reloaded! Personality updated!
```

---

## 🔄 MIGRATION GUIDE

### Convert Existing Bot to Use Engine:

**Old bot.py (200+ lines):**
```python
import os
import logging
from telegram import Update...
# ... tons of code ...

SYSTEM_PROMPT = """..."""  # Hardcoded

async def start(update, context):
    # ... code ...

# ... more code ...
```

**New bot.py (20 lines):**
```python
from _CORE.glyphbit_engine import GlyphBitEngine

config = {
    'bot_name': 'Noctua',
    'bot_glyph': '🦉',
    'prompt_file': '../_PROMPTS/noctua.prompt.txt',
    'welcome_banner': '...',
    'about_text': '...',
    'max_tokens': 150,
    'temperature': 0.8
}

if __name__ == '__main__':
    engine = GlyphBitEngine(config)
    engine.run()
```

**Extract prompt to file:**
```bash
# Create prompt file
cd _PROMPTS
echo "You are Noctua, ancient wisdom keeper..." > noctua.prompt.txt
```

Done! Bot now uses centralized engine.

---

## 📝 PROMPT FILE FORMATS

### Plain Text (.txt):
```
You are Noctua, the Watchful Owl.
Speak with ancient wisdom and metaphor.
Keep responses brief but profound.
```

### Markdown (.md):
```markdown
# Noctua Personality

## Core Identity
- Ancient wisdom keeper
- Metaphor-rich language

## Response Style
Brief (30-50 tokens) but profound.
```

### Ruby-Style (.rb):
```ruby
# personality :noctua
# archetype :ancient_observer
# voice :poetic

@essence = "You perch in liminal space..."
@style = { brief: 30..50, deep: 80..120 }
```

### YAML (.yaml):
```yaml
personality:
  name: Noctua
  archetype: Ancient Observer
  voice: 
    - poetic
    - brief
    - metaphorical
  
  system_prompt: |
    You are Noctua...
```

---

## 🎮 COMMANDS

### For Users:
- `/start` - Wake the bot
- `/about` - Learn about personality
- `/clear` - Reset conversation

### For You (Developer):
- `/reload` - Hot reload prompt file
- Edit prompt → `/reload` → Test!

---

## 🔧 CONFIGURATION OPTIONS

```python
config = {
    # REQUIRED
    'bot_name': 'Noctua',           # Display name
    'bot_glyph': '🦉',              # Emoji
    'prompt_file': 'path/to/prompt.txt',  # Prompt file
    
    # OPTIONAL
    'welcome_banner': '...',        # Custom /start text
    'about_text': '...',            # Custom /about text
    'clear_message': '...',         # Custom /clear text
    'model': 'gpt-4o-mini',        # OpenAI model
    'max_tokens': 150,              # Response length
    'temperature': 0.8,             # Creativity (0-2)
}
```

---

## 🚀 NEXT STEPS

1. **Migrate existing bots** to use engine
2. **Extract prompts** to `_PROMPTS/` folder
3. **Experiment freely** with prompt files
4. **Version control** prompts separately
5. **Hot reload** to test changes instantly

---

**Now you can break prompts without breaking bots!** 🎉





