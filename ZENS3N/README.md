# ZANS3N.SILO :: GlyphBit Trinity Deployment

**State of total awareness after action.**

This is the Docker deployment platform for the GlyphBit system - where containerized agents launch from the gantry.

---

## 🏗️ Architecture

```
╔════════════════════════════════════════════════════════════╗
║                      ZANS3N.SILO                           ║
║               Docker Container Platform                    ║
╚════════════════════════════════════════════════════════════╝

Container 1: MUNINN (Redis)
           └─> Memory & State Storage
           
Container 2: GLYPHBIT-CORE
           └─> Forge, Shared Mind, Core Logic
           
Container 3: GLYPHBIT-TELEGRAM
           ├─> 🦉 Noctua.Bit
           ├─> 🦊 Vulpes.Bit
           └─> 🦝 Trickoon.Bit
```

---

## 🚀 Quick Start

### Prerequisites
- Docker installed
- Docker Compose installed
- Telegram bot tokens (from @BotFather)
- OpenAI API key

### Setup

1. **Configure Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your tokens and API keys
   ```

2. **Launch the Trinity**
   ```bash
   docker-compose up -d
   ```

3. **View Logs**
   ```bash
   # All containers
   docker-compose logs -f
   
   # Specific bot
   docker-compose logs -f glyphbit-telegram
   ```

4. **Check Status**
   ```bash
   docker-compose ps
   ```

---

## 📦 Container Management

### Start All Services
```bash
docker-compose up -d
```

### Stop All Services
```bash
docker-compose down
```

### Restart a Specific Service
```bash
docker-compose restart glyphbit-telegram
```

### Rebuild After Code Changes
```bash
docker-compose build
docker-compose up -d
```

### View Live Logs
```bash
docker-compose logs -f glyphbit-telegram
```

---

## 🦉🦊🦝 The Trinity

### Noctua - The Watchful Owl
- **Role:** Ancient Observer, Wisdom-keeper
- **Response:** Brief wisdom or deep contemplation
- **Trigger:** All topics (direct chat/inline)

### Vulpes - The Sly Fox
- **Role:** Cunning Mocker, Action-oriented
- **Response:** Single-line quips (<100 chars)
- **Trigger:** Helpful answer + playful jab

### Trickoon - The Trash Mystic
- **Role:** Trickster Raccoon, Sacred Absurdity
- **Response:** Conversational, spiritually playful
- **Trigger:** Spirit/soul/existential questions

---

## 🔧 Configuration

### Environment Variables
Set in `.env` file:

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | Your OpenAI API key |
| `TELEGRAM_BOT_TOKEN_NOCTUA` | Noctua bot token |
| `TELEGRAM_BOT_TOKEN_VULPES` | Vulpes bot token |
| `TELEGRAM_BOT_TOKEN_TRICKOON` | Trickoon bot token |

### Volumes
- `muninn-data` - Redis persistent storage
- `core-data` - Core engine data
- `telegram-data` - Bot conversation logs

---

## 🛠️ Development

### Project Structure
```
ZANS3N.SILO/
├── docker-compose.yml       # Container orchestration
├── Dockerfiles/
│   ├── Dockerfile.core      # Core engine container
│   └── Dockerfile.telegram  # Telegram bots container
├── Z.3-CHAMBER/             # Testing/development zone
│   └── GLYPH.BIT/           # Bot source code
│       ├── _CORE/           # Shared modules
│       ├── _PROMPTS/        # Personality prompts
│       ├── Noctua.Bit/      # Owl bot
│       ├── Vulpes.Bit/      # Fox bot
│       └── Trickoon.Bit/    # Raccoon bot
└── README.md
```

### Adding a New Bot
1. Create new bot folder in `GLYPH.BIT/`
2. Follow Trinity structure (bot.py, requirements.txt)
3. Add token to `.env`
4. Update `launch_trinity.sh` in Dockerfile.telegram
5. Rebuild: `docker-compose build`

---

## 📊 Monitoring

### Check Container Health
```bash
docker ps
```

### Access Redis (Muninn)
```bash
docker exec -it muninn-memory redis-cli
```

### Debug a Container
```bash
docker exec -it glyphbit-telegram /bin/bash
```

---

## 🐛 Troubleshooting

### Bots won't start
- Check `.env` file has correct tokens
- Verify OpenAI API key is valid
- Check logs: `docker-compose logs glyphbit-telegram`

### Redis connection issues
- Ensure muninn container is running: `docker ps`
- Check network: `docker network ls`

### Code changes not reflected
- Rebuild containers: `docker-compose build --no-cache`

---

## 🎯 Next Steps

- [ ] Add Raven (high-level guide agent)
- [ ] Expand beyond Telegram (Discord, Slack)
- [ ] Implement GlyphBit Forge (auto-generate new bots)
- [ ] Scale horizontally (multiple instances)

---

**Built with precision at the gantry. Launched with purpose into the void.**

🚀 ZANS3N

