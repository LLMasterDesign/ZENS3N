# ▛▞ GLYPH.BIT Folder Structure ▞//

**Clean, organized bot network**

## 📂 Current Structure

```
GLYPH.BIT/
│
├── ▛ ACTIVE BOTS ▞
│   ├── Noctua.Bit/          🦉 Grounded observer with depth
│   ├── Vulpes.Bit/          🦊 Helpful mocker  
│   ├── Trickoon.Bit/        🦝 Trash mystic
│   └── ../Resume.Bot/       📄 Resume builder (outside GLYPH.BIT)
│
├── ▛ CORE SYSTEMS ▞
│   ├── _CORE/               Shared intelligence & group config
│   │   ├── group_config.py
│   │   ├── shared_mind.py
│   │   ├── global_policy.json
│   │   └── glyphbit_shared_memory.json (auto-created)
│   │
│   └── _PROMPTS/            Bot personality prompts
│
├── ▛ TOOLS & REUSABLES ▞
│   └── GlyphBit.Tools/      Packaged artifacts for redeployment
│       └── Shared.Mind.Artifact/  (Boxed collective intelligence)
│
├── ▛ CONTROL & LAUNCH ▞
│   ├── CONTROL_PANEL_TABS.ps1     Interactive dashboard
│   ├── LAUNCH_CONTROL_PANEL.bat   Quick launcher
│   └── LAUNCH_ALL.ps1             Alternative batch launcher
│
├── ▛ DOCUMENTATION ▞
│   ├── README.md
│   ├── GLYPHBIT.TRINITY.SPEC.md
│   ├── GROUP.MAGIC.GUIDE.md
│   ├── SETUP.GUIDE.md
│   ├── FOLDER_STRUCTURE.md (this file)
│   └── [other guides...]
│
└── ▛ ARCHIVED ▞
    └── _ARCHIVE/            Old/obsolete files (safe to ignore)
        ├── gyphbit-noctua/  (old version)
        ├── CONTROL_PANEL.ps1 (superseded)
        └── [old files...]
```

## 🎯 What's What

### Active Bots
**Production bots** that are ready to run.
- Each has: `bot.py`, `RUN_BOT.bat`, `.env`, `requirements.txt`
- Launch via: Control Panel or individual RUN_BOT.bat

### _CORE
**Shared systems** used by all bots:
- `group_config.py` - Group chat management, muting, sibling awareness
- `shared_mind.py` - Collective intelligence, depth escalation
- `global_policy.json` - Quality standards for all bots

### GlyphBit.Tools
**Reusable artifacts** packaged for deployment:
- Drop-in enhancements
- Fully documented
- Ready to deploy to new bots

### Control Panel
**Mission control** for the bot network:
- Launch all bots as tabs in one window
- Monitor status (🟢/🔴)
- Advanced features (transmit, logs, shared mind)

### _ARCHIVE
**Old/obsolete files** moved out of the way:
- Safe to delete eventually
- Kept for reference
- Not part of active system

## ✅ Clean & Ready

After cleanup:
- ✅ Active files only in main folder
- ✅ Old versions archived
- ✅ Clear structure
- ✅ Easy to navigate
- ✅ Ready for future expansions

## 🚀 Adding New Bots

1. Create `NewBot.Bit/` folder
2. Add `bot.py`, `RUN_BOT.bat`, `.env`
3. Update `CONTROL_PANEL_TABS.ps1` $bots array
4. Integrate shared_mind.py for collective intelligence
5. Launch from control panel!

---

**Last Updated:** October 6th, 2025  
**Status:** Clean & production-ready  
**Maintained by:** GlyphBit Forge




