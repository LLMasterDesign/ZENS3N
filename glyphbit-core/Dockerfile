# ════════════════════════════════════════════════════════════
# GLYPHBIT-CORE :: Shared Foundation
# Contains: _CORE modules, archetypes, forge tools
# ════════════════════════════════════════════════════════════

FROM python:3.11-slim

LABEL maintainer="zans3n"
LABEL description="GlyphBit Core - Shared modules and forge"

WORKDIR /app/core

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    ruby \
    && rm -rf /var/lib/apt/lists/*

# Copy core structure
COPY . /app/core/

# Install Python dependencies if requirements exist
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Create data directory
RUN mkdir -p /app/data

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python3 -c "import sys; sys.exit(0)"

# Keep container running (provides shared modules)
CMD ["tail", "-f", "/dev/null"]
