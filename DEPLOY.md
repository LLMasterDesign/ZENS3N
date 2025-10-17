# ZANS3N.SILO :: GlyphBit Production Deployment

**State of total awareness after action.**

This is the production deployment structure for GlyphBit bots. Upload this entire folder to your Docker host.

---

## 🏗️ Production Architecture

```
╔════════════════════════════════════════════════════════════╗
║                    ZANS3N.SILO                             ║
║          Docker Container Deployment Platform              ║
╚════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────┐
│  Container 1: GLYPHBIT-CORE                             │
│  ├─ _CORE/ (shared modules)                             │
│  ├─ archetypes/ (reusable .cfg templates)              │
│  └─ forge/ (bot generation & launchers)                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Container 2: GLYPHBIT-TELEGRAM                         │
│  ├─ Noctua.Bit/ 🦉                                      │
│  ├─ Vulpes.Bit/ 🦊                                      │
│  ├─ Trickoon.Bit/ 🦝                                    │
│  └─ [Add unlimited bots here]                           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  FUTURE: Container 3: MUNINN (Redis)                    │
│  └─ Shared memory when you're ready                     │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Deploy

### 1. Configure Environment

```bash
cp .env.example .env
# Edit .env with your tokens:
# - OPENAI_API_KEY
# - TELEGRAM_BOT_TOKEN_NOCTUA
# - TELEGRAM_BOT_TOKEN_VULPES
# - TELEGRAM_BOT_TOKEN_TRICKOON
```

### 2. Launch Containers

```bash
docker-compose up -d
```

### 3. Verify Running

```bash
docker-compose ps
```

Expected output:
```
glyphbit-core       running
glyphbit-telegram   running (3 bots inside)
```

### 4. View Logs

```bash
# All bots
docker-compose logs -f glyphbit-telegram

# Specific container
docker-compose logs -f glyphbit-core
```

---

## 📦 Folder Structure

```
ZANS3N.SILO/                      ← Upload this entire folder
├── docker-compose.yml            ← Orchestration
├── .env.example                  ← Token template
├── .env                          ← Your actual tokens (create this)
│
├── Dockerfiles/
│   ├── Dockerfile.core           ← Core container build
│   └── Dockerfile.telegram       ← Telegram container build
│
├── glyphbit-core/                ← Container 1 files
│   ├── _CORE/                    ← Shared modules
│   ├── archetypes/               ← Reusable archetypes
│   │   ├── wiseowl.cfg
│   │   ├── slyfox.cfg
│   │   └── trashmystic.cfg
│   ├── forge/                    ← Bot factory
│   │   ├── launch_trinity.py
│   │   ├── LAUNCH_TRINITY.bat
│   │   └── launch_trinity.sh
│   └── README.md
│
├── glyphbit-telegram/            ← Container 2 files
│   ├── Noctua.Bit/
│   │   ├── .bit/
│   │   │   ├── noctua.bit.v3.md
│   │   │   ├── config.toml
│   │   │   └── wiseowl.cfg
│   │   ├── bot.py
│   │   └── requirements.txt
│   ├── Vulpes.Bit/
│   ├── Trickoon.Bit/
│   └── README.md
│
└── Z.3-CHAMBER/                  ← STAGING (don't deploy)
    └── GLYPH.BIT/                ← Work in progress
```

---

## ➕ Adding New Bots (Scales to 100+)

### Step 1: Build in Chamber
```
Z.3-CHAMBER/GLYPH.BIT/
└── NewBot.Bit/            ← Build and test here
    ├── .bit/
    │   ├── newbot.bit.v1.md
    │   ├── config.toml
    │   └── [archetype].cfg
    └── bot.py
```

### Step 2: Promote to Production
```bash
# When ready, copy to production
cp -r Z.3-CHAMBER/GLYPH.BIT/NewBot.Bit glyphbit-telegram/
```

### Step 3: Add Token to .env
```env
TELEGRAM_BOT_TOKEN_NEWBOT=your-token-here
```

### Step 4: Rebuild
```bash
docker-compose build glyphbit-telegram
docker-compose up -d
```

**The auto-launcher discovers and runs it automatically.** No code changes needed.

---

## 🔧 Container Management

### Start
```bash
docker-compose up -d
```

### Stop
```bash
docker-compose down
```

### Restart After Changes
```bash
docker-compose restart glyphbit-telegram
```

### Rebuild (after code changes)
```bash
docker-compose build
docker-compose up -d
```

### View Logs Live
```bash
docker-compose logs -f
```

### Shell Access
```bash
# Access telegram container
docker exec -it glyphbit-telegram /bin/bash

# Access core container
docker exec -it glyphbit-core /bin/bash
```

---

## 🦉🦊🦝 Current Bots

| Bot | Archetype | Glyph | Voice | Token Var |
|-----|-----------|-------|-------|-----------|
| **Noctua** | Wise Owl | 🦉 | Contemplative metaphors | `TELEGRAM_BOT_TOKEN_NOCTUA` |
| **Vulpes** | Sly Fox | 🦊 | Quick quips <100 chars | `TELEGRAM_BOT_TOKEN_VULPES` |
| **Trickoon** | Trash Mystic | 🦝 | Sacred absurdity | `TELEGRAM_BOT_TOKEN_TRICKOON` |

---

## 🔮 Scaling Strategy

### 3 → 10 Bots
Just add folders to `glyphbit-telegram/`

### 10 → 50 Bots
Same container, auto-launcher handles it

### 50 → 100+ Bots
Consider horizontal scaling:
```yaml
# docker-compose.yml
glyphbit-telegram:
  deploy:
    replicas: 3  # Run 3 instances
```

Or split into multiple telegram containers by bot family.

---

## 🐛 Troubleshooting

### Bots won't start
1. Check `.env` has all tokens
2. Verify `.bit/` folders have all 3 files
3. Check logs: `docker-compose logs glyphbit-telegram`

### Bot not responding
1. Verify token in `.env`
2. Check bot.py loaded personality: look for "✅ Loaded personality" in logs
3. Test OpenAI key is valid

### Can't find _CORE modules
1. Ensure glyphbit-core is running first
2. Check volume mounts in docker-compose.yml
3. Verify _CORE/ exists in glyphbit-core/

---

## ✅ Pre-Flight Checklist

Before `docker-compose up`:

- [ ] `.env` file created with all tokens
- [ ] Each bot has `.bit/` folder with 3 files
- [ ] Each bot has `.env` or uses container env vars
- [ ] `_CORE/` folder exists in glyphbit-core
- [ ] Archetypes copied to glyphbit-core/archetypes/

---

**Built with precision. Launched with purpose. Scales to infinity.**

🚀 ZANS3N

