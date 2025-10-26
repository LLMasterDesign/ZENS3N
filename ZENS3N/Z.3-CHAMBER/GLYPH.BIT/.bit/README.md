# .bit :: GlyphBit Backend Structure

The `.bit` folder contains everything a GlyphBit needs on the backend.

## Structure

```
[BotName].Bit/
  ├── .bit/                          ← Backend configuration
  │   ├── [botname].bit.v3.md        ← LLM personality prompt
  │   ├── config.toml                ← Runtime settings
  │   └── [archetype].cfg            ← Reusable archetype definition
  ├── bot.py
  ├── requirements.txt
  └── README.md
```

## The 3 Files

### 1. `[botname].bit.v3.md`
**What it is:** The personality prompt  
**Who reads it:** The LLM  
**Format:** Markdown, written like a prompt  
**Purpose:** Defines THIS specific bot's voice and behavior

Example: `noctua.bit.v3.md`, `strix.bit.v1.md`

### 2. `config.toml`
**What it is:** Runtime configuration  
**Who reads it:** Python  
**Format:** TOML  
**Purpose:** Model settings, tokens, temperature, flags

Always named `config.toml`.

### 3. `[archetype].cfg`
**What it is:** Archetype definition (REUSABLE)  
**Who reads it:** Humans + optional parsers  
**Format:** YAML-like with ZANS3N delimiters  
**Purpose:** Documents the archetype essence

Example: `wiseowl.cfg` (used by ALL owl bots)

## Archetype Reusability

The `.cfg` file is **generic** and can be shared:

```
Noctua.Bit/.bit/
  └── wiseowl.cfg    ← OWL archetype

Strix.Bit/.bit/
  └── wiseowl.cfg    ← SAME archetype, different personality

Vulpes.Bit/.bit/
  └── slyfox.cfg     ← FOX archetype

Trickoon.Bit/.bit/
  └── trashmystic.cfg ← RACCOON archetype
```

## Usage in Python

```python
import toml
from pathlib import Path

# Load runtime config
config = toml.load('.bit/config.toml')

# Load personality prompt
bot_name = config['bot']['name']
personality = Path(f'.bit/{bot_name}.bit.v3.md').read_text()

# Use in OpenAI call
response = client.chat.completions.create(
    model=config['model']['name'],
    messages=[
        {"role": "system", "content": personality},
        {"role": "user", "content": user_message}
    ],
    max_tokens=config['model']['max_tokens']
)
```

## File Naming Convention

- **Personality:** `[botname].bit.v[number].md`
- **Config:** `config.toml` (always)
- **Archetype:** `[archetype].cfg` (reusable across bots)

---

**Status:** Template structure for GlyphBit backend  
**Version:** 1.0.0  
**Pattern:** 3 files, reusable archetypes, ZANS3N signature
