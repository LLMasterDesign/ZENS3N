# 🚀 Quick GlyphBit Update Commands

**For when you have VPS access via SSH or terminal**

## Option 1: Automated Update (Recommended)
```bash
# Make script executable and run
chmod +x update-glyphbit.sh
./update-glyphbit.sh
```

## Option 2: Manual Step-by-Step

### 1. Navigate to GlyphBit Directory
```bash
cd /path/to/your/glyphbit/directory
```

### 2. Pull Latest Changes
```bash
git pull origin main
```

### 3. Stop Current Containers
```bash
docker-compose down
```

### 4. Rebuild with Latest Code
```bash
docker-compose build --no-cache
```

### 5. Start Updated Containers
```bash
docker-compose up -d
```

### 6. Verify Everything is Running
```bash
docker-compose ps
```

### 7. Check Logs (Optional)
```bash
docker-compose logs -f
```

## Option 3: Hot Update (If Volumes are Mounted)
```bash
# Pull changes
git pull origin main

# Restart just the telegram container
docker-compose restart glyphbit-telegram
```

## Verification Steps

### Check Container Status
```bash
docker-compose ps
```
**Expected output:**
```
glyphbit-core       running
glyphbit-telegram   running
```

### Test Bot Response
1. Send a message to any of your Telegram bots
2. Should receive a response within a few seconds
3. Try commands like `/start` or `/about`

### Check Logs for Errors
```bash
docker-compose logs glyphbit-telegram | tail -20
```

## Rollback (If Something Goes Wrong)

### Quick Rollback
```bash
# Stop current containers
docker-compose down

# Go back to previous commit
git reset --hard HEAD~1

# Rebuild and start
docker-compose build
docker-compose up -d
```

### Full Rollback
```bash
# If you have a backup directory
cd backup_YYYYMMDD_HHMMSS/
# Copy back your previous state
```

## Troubleshooting

### Bot Not Responding
```bash
# Check if containers are running
docker-compose ps

# Check logs for errors
docker-compose logs glyphbit-telegram

# Restart specific container
docker-compose restart glyphbit-telegram
```

### Environment Issues
```bash
# Check if .env file exists
ls -la .env

# Verify environment variables
docker-compose config
```

### Git Issues
```bash
# Check git status
git status

# Force pull if needed
git fetch origin
git reset --hard origin/main
```

## What's New in This Update

Based on recent commits, this update includes:
- ✅ **Group Magic Integration** - Warden mute/mode functionality
- ✅ **Inline Query Cleanup** - Better response formatting
- ✅ **Core Module Updates** - Improved group configuration
- ✅ **Bot Improvements** - Enhanced across all instances

---
**Remember:** Always test in a development environment first if possible!

:: ∎