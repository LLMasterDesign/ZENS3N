///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-YY.SSS // WORKBOOK :: [How Agents Speak to TelePromptR] ▞▞

# How Agents Communicate with TelePromptR

## Communication Flow

### **Agents → TPR (Sending Messages)**

Agents write JSON envelope files to the relay outbox directory:

```ruby
# 1. Create envelope
envelope = {
  'agent_id' => 'my_agent',           # Required: identifies which agent
  'text' => 'Hello from agent!',      # Required: message text
  'chat_id' => -1001234567890,        # Optional: target chat (0 or nil = auto-resolve)
  'topic_thread_id' => 123,           # Optional: target topic/thread (0 or nil = auto-resolve)
  'timestamp' => Time.now.utc.iso8601, # Optional: RFC3339 timestamp
  'message_id' => nil,                 # Optional: reply-to message ID
  'trace_id' => SecureRandom.hex(8)    # Optional: request trace ID
}

# 2. Write to outbox
outbox_dir = '.3ox/.vec3/var/relay/outbox'
filename = "#{Time.now.to_i}_#{SecureRandom.hex(4)}.json"
File.write(File.join(outbox_dir, filename), JSON.pretty_generate(envelope))
```

**What happens next:**
1. `telepromptr_bridge.rb` polls the outbox directory (every 3s by default, configurable via `TPR_POLL_INTERVAL_S`)
2. Bridge reads envelope, validates `agent_id` and `text`
3. Bridge resolves routing (agent_id → chat_id/topic_thread_id via route map)
4. Bridge checks agent registration and permissions
5. Bridge calls Telegram API `sendMessage`
6. Bridge moves envelope to `outbox/sent/` (success) or `outbox/denied/` (failure)

### **TPR → Agents (Receiving Messages)**

TPR writes incoming Telegram messages to the relay inbox directory:

```ruby
# 1. Read from inbox
inbox_dir = '.3ox/.vec3/var/relay/inbox'
Dir.glob(File.join(inbox_dir, '*.json')).each do |path|
  envelope = JSON.parse(File.read(path))
  
  # 2. Process message
  text = envelope['text']
  from_user = envelope['from_user']
  from_chat_id = envelope['from_chat_id']
  from_thread_id = envelope['from_thread_id']
  routed_to = envelope['routed_to']  # Which agent should handle this
  
  # 3. Handle message (your agent logic here)
  handle_message(text, from_user, from_chat_id)
  
  # 4. Mark as processed
  FileUtils.mv(path, File.join(inbox_dir, 'processed', File.basename(path)))
end
```

**Inbox envelope structure:**
```json
{
  "message_id": "12345",
  "from_chat_id": -1001234567890,
  "from_thread_id": 123,
  "from_user": {
    "id": 123456789,
    "username": "user",
    "first_name": "User"
  },
  "text": "Hello agent!",
  "original_text": "Hello agent!",
  "raw_message": { /* full Telegram message */ },
  "routed_to": "my_agent",
  "route_reason": "mention",
  "routed_at": "2026-02-27T12:00:00Z",
  "sirius_time": "...",
  "normalized": true
}
```

## Using the Helper Module

The setup script creates `.3ox/vec3/lib/core/telegram.tpr.rb` with helper methods:

```ruby
require_relative '.3ox/vec3/lib/core/telegram.tpr'

# Send message
TelegramTPR.send_message(
  agent_id: 'my_agent',
  text: 'Hello from 3ox!',
  chat_id: -1001234567890,
  topic_thread_id: 123
)

# Read inbox
TelegramTPR.read_inbox.each do |envelope|
  puts "Received: #{envelope['text']}"
  TelegramTPR.mark_processed(envelope['_filepath'])
end

# Register agent
TelegramTPR.register_agent(
  agent_id: 'my_agent',
  chat_id: -1001234567890,
  topic_thread_id: 123,
  metadata: { 'name' => 'My Agent' }
)
```

## Starting the Bridge

The bridge must be running to process outbox messages:

```bash
cd TelePromptR
./tools/telepromptr_bridge.rb start
```

Or use forge:
```bash
cd TelePromptR
./_forge/forge.sh up  # Starts teleprompter (reads Telegram)
# Bridge runs separately or can be integrated
```

## VPS Status & Sync

**Current VPS:** `root@5.78.109.54:/root/!CMD.VPS/TelePromptR/`

**To check if TPR is running on VPS:**
```bash
ssh root@5.78.109.54 "ps aux | grep teleprompter | grep -v grep"
```

**To sync from VPS (pull latest runtime):**
```bash
# From VPS
scp root@5.78.109.54:/root/!CMD.VPS/TelePromptR/3ox.station/vec3/bin/teleprompter.rb \
   TelePromptR/runtime/vps/3ox.station/vec3/bin/teleprompter.rb

# Or use rsync for full sync
rsync -av root@5.78.109.54:/root/!CMD.VPS/TelePromptR/ \
          TelePromptR/runtime/vps/
```

**To check what's different:**
```bash
# Compare local vs VPS
diff <(ssh root@5.78.109.54 "cat /root/!CMD.VPS/TelePromptR/3ox.station/vec3/bin/teleprompter.rb") \
     TelePromptR/runtime/vps/3ox.station/vec3/bin/teleprompter.rb
```

**To push updates to VPS:**
```bash
# Push bridge and tools
scp TelePromptR/tools/telepromptr_bridge.rb \
    root@5.78.109.54:/root/!CMD.VPS/TelePromptR/tools/

# Or push entire branch
rsync -av TelePromptR/ root@5.78.109.54:/root/!CMD.VPS/TelePromptR/ \
          --exclude='.git' --exclude='_forge/runtime' --exclude='*.log'
```

## Directory Structure

```
.3ox/.vec3/var/relay/
├── inbox/                    # TPR writes here (Telegram → agents)
│   └── processed/            # Agents move processed messages here
├── outbox/                   # Agents write here (agents → Telegram)
│   ├── sent/                 # Bridge moves successful sends here
│   └── denied/               # Bridge moves rejected sends here
├── registrations.json        # Agent registrations (agent_id → config)
└── telegram_topics.json      # Topic/thread mappings
```

## Route Resolution

The bridge resolves routing in this order:

1. **Envelope fields** (`chat_id`, `topic_thread_id` from envelope)
2. **Route map** (`CyberDeck/TPR.ROUTE.MAP.json`)
3. **Agent registration** (`registrations.json`)
4. **Agent subkey** (`_forge/runtime/keys/*.tgsub.key`)

If `chat_id` is 0 or nil, bridge uses route map/registration to resolve.

## Security

- Agents must be registered in `registrations.json`
- Agent subkeys (`.tgsub.key` files) can restrict `allowed_chat_ids` and `subscribed_topics`
- Bridge validates all envelopes before sending
- Denied messages are logged in route audit file

:: ∎
