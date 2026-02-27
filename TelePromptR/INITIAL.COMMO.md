///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-YY.SSS // WORKBOOK :: [Initial Communication Setup for Cursor Agents] ▞▞

# Initial Communication Setup - Cursor Agents → Telegram

## Quick Start for Cursor Agents

Cursor agents can transmit to Telegram immediately using this simple setup.

### 1. **One-Time Setup**

```bash
cd '/root/!ZENS3N.CMD/!LAUNCHPAD/TelePromptR'
./setup.3ox.proto.sh
```

This creates:
- `.3ox/.vec3/var/relay/` directory structure
- `.3ox/vec3/lib/core/telegram.tpr.rb` helper module
- Registration and routing files

### 2. **In Your Cursor Agent Code**

```ruby
# Load the helper (works from any .3ox context)
require_relative '.3ox/vec3/lib/core/telegram.tpr'

# Send a message (that's it!)
TelegramTPR.send_message(
  agent_id: 'cursor_agent',  # Your agent identifier
  text: 'Hello from Cursor!',
  chat_id: -1001234567890,   # Your Telegram chat ID (optional, can auto-resolve)
  topic_thread_id: 123       # Topic/thread ID (optional)
)
```

### 3. **Minimal Example (No Helper)**

If you can't load the helper, write directly:

```ruby
require 'json'
require 'time'
require 'securerandom'
require 'fileutils'

# Define paths
relay_outbox = '.3ox/.vec3/var/relay/outbox'
FileUtils.mkdir_p(relay_outbox)

# Create envelope
envelope = {
  'agent_id' => 'cursor_agent',
  'text' => 'Hello from Cursor agent!',
  'timestamp' => Time.now.utc.iso8601,
  'trace_id' => SecureRandom.hex(8)
}

# Write to outbox
filename = "#{Time.now.to_i}_#{SecureRandom.hex(4)}.json"
File.write(File.join(relay_outbox, filename), JSON.pretty_generate(envelope))
```

### 4. **Agent Registration (One-Time)**

Register your agent so routing works:

```ruby
require_relative '.3ox/vec3/lib/core/telegram.tpr'

TelegramTPR.register_agent(
  agent_id: 'cursor_agent',
  chat_id: -1001234567890,      # Your Telegram chat ID
  topic_thread_id: 123,          # Optional: topic/thread
  metadata: {
    'name' => 'Cursor Agent',
    'type' => 'cursor',
    'version' => '1.0'
  }
)
```

### 5. **Start the Bridge**

The bridge must be running to process outbox messages:

```bash
cd '/root/!ZENS3N.CMD/!LAUNCHPAD/TelePromptR'
./tools/telepromptr_bridge.rb start
```

Or in background:
```bash
nohup ./tools/telepromptr_bridge.rb start > /tmp/tpr_bridge.log 2>&1 &
```

## Environment Variables

Set these if needed (defaults work for most cases):

```bash
export TPR_CMD_ROOT="/root/!ZENS3N.CMD/.3ox"
export TPR_RELAY_OUTBOX_DIR=".3ox/.vec3/var/relay/outbox"
export TELEGRAM_BOT_TOKEN="your_bot_token_here"
export TPR_POLL_INTERVAL_S=3.0  # Poll every 3 seconds (not 0.5s - runtime.init frowns on aggressive polling)
```

## Directory Structure

```
.3ox/.vec3/var/relay/
├── outbox/              # Write here (agents → Telegram)
│   ├── sent/            # Bridge moves successful sends here
│   └── denied/          # Bridge moves rejected sends here
├── inbox/               # TPR writes here (Telegram → agents)
│   └── processed/       # Move processed messages here
└── registrations.json   # Agent registrations
```

## Envelope Format

```json
{
  "agent_id": "cursor_agent",      // Required: identifies your agent
  "text": "Your message here",      // Required: message text
  "chat_id": -1001234567890,        // Optional: target chat (0 or omit = auto-resolve)
  "topic_thread_id": 123,           // Optional: target topic/thread (0 or omit = auto-resolve)
  "timestamp": "2026-02-27T12:00:00Z",  // Optional: RFC3339 timestamp
  "message_id": null,                // Optional: reply-to message ID
  "trace_id": "abc123def456"         // Optional: request trace ID
}
```

## Polling Interval

**Default: 3 seconds** (not 0.5s)

- `runtime.init` guidelines: aggressive polling is frowned upon
- Bridge polls `relay/outbox/` every 3 seconds by default
- Configurable via `TPR_POLL_INTERVAL_S` environment variable
- Bridge only sleeps when outbox is empty (processes immediately when files exist)

## Troubleshooting

**Message not sending?**
1. Check bridge is running: `ps aux | grep telepromptr_bridge`
2. Check outbox directory exists: `ls -la .3ox/.vec3/var/relay/outbox/`
3. Check envelope format: `cat .3ox/.vec3/var/relay/outbox/*.json`
4. Check denied folder: `ls -la .3ox/.vec3/var/relay/outbox/denied/`

**Bridge not finding outbox?**
- Set `TPR_CMD_ROOT` to your .3ox root
- Or set `TPR_RELAY_OUTBOX_DIR` to full path

**Agent not registered?**
- Run `TelegramTPR.register_agent()` once
- Or manually edit `.3ox/.vec3/var/relay/registrations.json`

## For Mac Pro Sync (ZENS3N.PRO)

All files are in `branch/TelePromptR`:

```bash
git checkout branch/TelePromptR
./setup.3ox.proto.sh
```

The helper module and examples will be created in your `.3ox` directory.

:: ∎
