///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-YY.SSS // WORKBOOK :: [TelePromptR Telegram Communication Protocol] ▞▞

# TelePromptR → Telegram Communication Protocol

## What TPR Needs to Change for Telegram Communication

### 1. **Proto Definition** (`specs/TPR.MSG.v1.proto`)

The proto already defines the message structure. Key fields:

```protobuf
message InboxEnvelope {
  string message_id = 1;
  int64 from_chat_id = 2;        // Telegram chat ID (can be negative for supergroups)
  int64 from_thread_id = 3;       // Topic/thread ID (0 when absent)
  google.protobuf.Struct from_user = 4;
  string text = 5;
  string original_text = 6;
  google.protobuf.Struct raw_message = 7;  // Full Telegram message object
  string routed_to = 8;          // Agent ID that should handle this
  string route_reason = 9;        // mention|subscription|autopost
  google.protobuf.Struct meta = 10;
  string routed_at = 11;          // RFC3339 timestamp
  string sirius_time = 12;       // Sirius clock time
  bool normalized = 13;
}

message OutboxEnvelope {
  TprMsg tpr = 1;                 // Internal TPR message format
  Route route = 2;                // Telegram routing info
  google.protobuf.Struct meta = 3;
}

message BusOutboxEnvelope {
  string agent_id = 1;            // Which agent is sending
  string text = 2;                 // Message text
  int64 chat_id = 3;              // Target chat (0 = resolve via route policy)
  int64 topic_thread_id = 4;      // Target topic/thread (0 = resolve via mapping)
  string timestamp = 5;            // RFC3339
  string message_id = 6;           // Optional reply-to message_id
  string trace_id = 7;             // Request trace ID
}
```

### 2. **Telegram API Integration Points**

**Inbound (Telegram → TPR):**
- `teleprompter.rb` polls `getUpdates` or receives webhooks
- Converts Telegram message → `InboxEnvelope` (JSON)
- Writes to `var/inbox/` directory
- Speaker mesh reads inbox and routes to agents

**Outbound (TPR → Telegram):**
- Agents write `BusOutboxEnvelope` to `var/relay/outbox/`
- `telepromptr_bridge.rb` drains outbox
- Resolves routing (agent_id → chat_id/topic_thread_id)
- Calls Telegram `sendMessage` API
- Moves processed files to `sent/` or `denied/`

### 3. **Required Changes for 3ox Integration**

#### A. **Proto Compilation**
```bash
# Generate Ruby/JSON bindings from proto
protoc --ruby_out=. specs/TPR.MSG.v1.proto
# Or use JSON schema validation (already provided)
```

#### B. **3ox System Integration Points**

**1. Agent Output → TPR Outbox:**
```ruby
# In .3ox agent code, when sending to Telegram:
envelope = {
  'agent_id' => 'agent_name',
  'text' => message_text,
  'chat_id' => chat_id,              # Optional, 0 to auto-resolve
  'topic_thread_id' => thread_id,    # Optional, 0 to auto-resolve
  'timestamp' => Time.now.utc.iso8601,
  'trace_id' => SecureRandom.hex(8)
}

outbox_path = File.join('.3ox', '.vec3', 'var', 'relay', 'outbox', "#{Time.now.to_i}_#{SecureRandom.hex(4)}.json")
File.write(outbox_path, JSON.pretty_generate(envelope))
```

**2. TPR Inbox → 3ox Agent Input:**
```ruby
# In .3ox agent code, read from TPR inbox:
inbox_dir = File.join('.3ox', '.vec3', 'var', 'relay', 'inbox')
Dir.glob(File.join(inbox_dir, '*.json')).each do |path|
  envelope = JSON.parse(File.read(path))
  # Process envelope['text'], envelope['from_user'], etc.
  # Move to processed/ after handling
end
```

**3. Route Map Configuration:**
```json
// CyberDeck/TPR.ROUTE.MAP.json
{
  "agent_id": {
    "chat_id": -1001234567890,
    "topic_thread_id": 123,
    "parse_mode": "Markdown"
  }
}
```

### 4. **Environment Variables**

```bash
# Required
TELEGRAM_BOT_TOKEN=your_bot_token_here

# Optional
TPR_CMD_ROOT=/root/!ZENS3N.CMD/.3ox
TPR_RELAY_OUTBOX_DIR=.3ox/.vec3/var/relay/outbox
TPR_RELAY_REG_PATH=.3ox/.vec3/var/relay/registrations.json
TPR_TOPICS_PATH=.3ox/.vec3/var/telegram_topics.json
TPR_ROUTE_MAP_PATH=CyberDeck/TPR.ROUTE.MAP.json
TPR_POLL_INTERVAL_S=0.5
```

### 5. **Directory Structure**

```
.3ox/
└── .vec3/
    └── var/
        └── relay/
            ├── inbox/          # TPR writes here (Telegram → agents)
            ├── outbox/         # Agents write here (agents → Telegram)
            │   ├── sent/       # Processed successfully
            │   └── denied/     # Rejected/invalid
            ├── registrations.json  # Agent registrations
            └── telegram_topics.json  # Topic/thread mappings
```

### 6. **Key Integration Points**

**For 3ox to use TPR:**

1. **Write outbox envelopes** when agents need to send Telegram messages
2. **Read inbox envelopes** when agents need to receive Telegram messages
3. **Register agents** in `registrations.json` for routing
4. **Configure route map** for agent → chat/topic mapping

**TPR handles:**
- Telegram API rate limiting
- Message routing (agent_id → chat_id/topic_thread_id)
- Thread/topic management
- Webhook/polling coordination
- Message normalization

### 7. **Testing the Integration**

```bash
# 1. Start TPR bridge (reads outbox, sends to Telegram)
cd TelePromptR
./tools/telepromptr_bridge.rb start

# 2. Write test envelope from 3ox
echo '{
  "agent_id": "test_agent",
  "text": "Hello from 3ox!",
  "chat_id": -1001234567890,
  "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
}' > .3ox/.vec3/var/relay/outbox/test_$(date +%s).json

# 3. Check bridge status
./tools/telepromptr_bridge.rb status
```

### 8. **What Needs to Change**

**Current State:**
- TPR proto defines message structure ✅
- TPR bridge reads outbox and sends to Telegram ✅
- TPR teleprompter reads Telegram and writes inbox ✅

**What 3ox Needs:**
- [ ] Write outbox envelopes when agents send messages
- [ ] Read inbox envelopes when agents receive messages
- [ ] Register agents in TPR registration system
- [ ] Configure route map for agent routing
- [ ] Handle proto message validation

**What TPR Needs (if any):**
- [ ] Ensure proto can be compiled/validated in 3ox environment
- [ ] Add 3ox-specific integration helpers
- [ ] Document 3ox agent registration process

:: ∎
