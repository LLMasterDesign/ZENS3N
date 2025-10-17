# GLYPHBIT FORGE :: Bot Factory

**The generation and deployment tools for GlyphBit system**

---

## What's Here

```
forge/
├── launch_trinity.py       ← Auto-discovery launcher (Python)
├── LAUNCH_TRINITY.bat      ← Windows launcher
├── launch_trinity.sh       ← Linux/Mac launcher
└── README.md               ← This file
```

---

## Auto-Discovery Launcher

`launch_trinity.py` scans for all `*.Bit/` folders and launches them in parallel.

### Usage

```bash
# From GLYPH.BIT/ or glyphbit-telegram/
python ../glyphbit-core/forge/launch_trinity.py

# Or from forge/
python launch_trinity.py ../../../glyphbit-telegram/
```

### What It Does

1. **Scans** for `*.Bit/` folders
2. **Validates** each has bot.py and .bit/ config
3. **Launches** all in parallel
4. **Monitors** and logs output

### Output Example

```
╔════════════════════════════════════════════════════════════╗
║         GLYPHBIT TRINITY LAUNCHER v1.0                     ║
╚════════════════════════════════════════════════════════════╝

🔍 Scanning for bots...
  ✅ Found: Noctua.Bit
  ✅ Found: Vulpes.Bit
  ✅ Found: Trickoon.Bit
  ✅ Found: Raven.Bit

📊 Discovered 4 bot(s)
────────────────────────────────────────────────────────────
  NOCTUA       → ✅ READY
  VULPES       → ✅ READY
  TRICKOON     → ✅ READY
  RAVEN        → ✅ READY

🚀 Launching 4 bots in parallel...
```

---

## Future Forge Tools

When fully built, the forge will include:

- **Bot Generator** - Create new bots from templates
- **Archetype Manager** - Manage reusable .cfg files
- **Config Validator** - Check .bit/ folders before deploy
- **Mass Updater** - Update all bots simultaneously
- **Analytics** - Track bot performance

---

**Version:** 1.0.0  
**Status:** Auto-launcher ready  
**Capacity:** Scales to 100+ bots

