# GLYPHBIT-CORE :: Shared Logic & Forge

**Container 1 of 2** - The foundation layer for all GlyphBits

---

## Purpose

This container provides:
- **Shared modules** (_CORE folder - group_config, shared_mind)
- **Reusable archetypes** (.cfg files for bot families)
- **Common utilities** (logging, config parsing)
- **Future expansion** (Redis integration, AI tools, forge logic)

---

## Structure

```
glyphbit-core/
├── _CORE/                 ← Shared Python modules
│   ├── group_config.py    ← Group magic coordination
│   ├── shared_mind.py     ← Shared memory/context
│   └── global_policy.json ← Cross-bot policies
├── archetypes/            ← Reusable .cfg templates
│   ├── wiseowl.cfg
│   ├── slyfox.cfg
│   └── trashmystic.cfg
├── forge/                 ← Bot generation tools (future)
└── README.md              ← This file
```

---

## Integration

**glyphbit-telegram** container mounts this as a shared volume:
```yaml
volumes:
  - ./glyphbit-core/_CORE:/app/_CORE
  - ./glyphbit-core/archetypes:/app/archetypes
```

All bots can import shared modules:
```python
from _CORE.group_config import should_respond
from _CORE.shared_mind import add_insight
```

---

## Future Capabilities

When fully built, glyphbit-core will:
- **Generate new bots** from archetype templates
- **Manage shared memory** across all bots (via Redis)
- **Coordinate group behavior** (who speaks when)
- **Provide common tools** (logging, analytics, etc.)

---

**Version:** 1.0.0  
**Type:** Foundation layer  
**Status:** Production ready for 3-100+ bots

