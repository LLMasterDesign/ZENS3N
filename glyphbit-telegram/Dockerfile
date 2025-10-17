# ════════════════════════════════════════════════════════════
# GLYPHBIT-TELEGRAM :: Bot Deployment Layer
# Runs all bot instances (Noctua, Vulpes, Trickoon, ...)
# Auto-discovers and launches all *.Bit folders
# ════════════════════════════════════════════════════════════

FROM python:3.11-slim

LABEL maintainer="zans3n"
LABEL description="GlyphBit Telegram - Auto-scaling bot deployment"

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy all bot folders
COPY . /app/bots/

# Install dependencies from first bot (they all use same)
RUN if [ -f /app/bots/Noctua.Bit/requirements.txt ]; then \
    pip install --no-cache-dir -r /app/bots/Noctua.Bit/requirements.txt; \
    fi

# Create launcher script that auto-discovers all *.Bit folders
RUN echo '#!/bin/bash\n\
echo "╔════════════════════════════════════════════════════════════╗"\n\
echo "║           GLYPHBIT AUTO-LAUNCHER                          ║"\n\
echo "╚════════════════════════════════════════════════════════════╝"\n\
echo ""\n\
echo "🔍 Scanning for bots..."\n\
\n\
cd /app/bots\n\
\n\
# Find all *.Bit directories and launch their bot.py\n\
for bot_dir in *.Bit; do\n\
    if [ -f "$bot_dir/bot.py" ]; then\n\
        bot_name=$(echo $bot_dir | sed "s/.Bit//" | tr "[:upper:]" "[:lower:]")\n\
        echo "  ✅ Found: $bot_dir"\n\
        cd "$bot_dir"\n\
        python3 bot.py &\n\
        cd ..\n\
        sleep 1\n\
    fi\n\
done\n\
\n\
echo ""\n\
echo "🚀 All bots launched in background"\n\
echo ""\n\
\n\
# Wait for all background processes\n\
wait\n' > /app/launch_all.sh && chmod +x /app/launch_all.sh

# Health check - verify at least one bot process is running
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
  CMD pgrep -f "python.*bot.py" || exit 1

# Launch all bots
CMD ["/app/launch_all.sh"]
