#!/bin/bash
# ▛//▞▞ TELEPROMPTR → 3OX PROTO SETUP ▞▞
# Reads TelePromptR branch and sets up proto for 3ox communication

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPR_ROOT="$SCRIPT_DIR"
CMD_ROOT="${TPR_CMD_ROOT:-/root/!ZENS3N.CMD/.3ox}"
VEC3_VAR="${CMD_ROOT}/.vec3/var"
RELAY_DIR="${VEC3_VAR}/relay"

echo "▛//▞▞ TELEPROMPTR → 3OX PROTO SETUP ▞▞"
echo "TPR_ROOT: $TPR_ROOT"
echo "CMD_ROOT: $CMD_ROOT"
echo ""

# Check if we're on the TelePromptR branch
current_branch=$(git -C "$TPR_ROOT" branch --show-current 2>/dev/null || echo "")
if [[ "$current_branch" != "branch/TelePromptR" ]] && [[ "$current_branch" != *"TelePromptR"* ]]; then
  echo "⚠️  Warning: Not on TelePromptR branch (current: $current_branch)"
  echo "   Run: git checkout branch/TelePromptR"
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "${RELAY_DIR}/inbox"
mkdir -p "${RELAY_DIR}/outbox/sent"
mkdir -p "${RELAY_DIR}/outbox/denied"

# Copy proto and schema files to 3ox for reference
echo "📋 Copying proto definitions..."
mkdir -p "${CMD_ROOT}/.3ox/specs/tpr"
cp -v "${TPR_ROOT}/specs/TPR.MSG.v1.proto" "${CMD_ROOT}/.3ox/specs/tpr/" 2>/dev/null || true
cp -v "${TPR_ROOT}/specs/"*.json "${CMD_ROOT}/.3ox/specs/tpr/" 2>/dev/null || true

# Create registration file if it doesn't exist
REG_FILE="${RELAY_DIR}/registrations.json"
if [[ ! -f "$REG_FILE" ]]; then
  echo "📝 Creating agent registration file..."
  cat > "$REG_FILE" <<'EOF'
{
  "agents": {},
  "last_updated": null
}
EOF
  chmod 644 "$REG_FILE"
fi

# Create topics file if it doesn't exist
TOPICS_FILE="${VEC3_VAR}/telegram_topics.json"
if [[ ! -f "$TOPICS_FILE" ]]; then
  echo "📝 Creating topics mapping file..."
  cat > "$TOPICS_FILE" <<'EOF'
{
  "topics": {},
  "last_updated": null
}
EOF
  chmod 644 "$TOPICS_FILE"
fi

# Create route map if it doesn't exist
ROUTE_MAP="${TPR_ROOT}/CyberDeck/TPR.ROUTE.MAP.json"
if [[ ! -f "$ROUTE_MAP" ]]; then
  echo "📝 Creating route map..."
  mkdir -p "$(dirname "$ROUTE_MAP")"
  cat > "$ROUTE_MAP" <<'EOF'
{
  "routes": {},
  "default_chat_id": null,
  "default_topic_thread_id": null
}
EOF
  chmod 644 "$ROUTE_MAP"
fi

# Create 3ox integration helper script
HELPER_SCRIPT="${CMD_ROOT}/.3ox/vec3/lib/core/telegram.tpr.rb"
if [[ ! -f "$HELPER_SCRIPT" ]]; then
  echo "📝 Creating 3ox TPR integration helper..."
  mkdir -p "$(dirname "$HELPER_SCRIPT")"
  cat > "$HELPER_SCRIPT" <<'RUBYEOF'
#!/usr/bin/env ruby
# frozen_string_literal: true

# ▛//▞▞ 3OX → TELEPROMPTR INTEGRATION HELPER ▞▞
# Helper methods for 3ox agents to communicate via TelePromptR

require 'json'
require 'time'
require 'securerandom'
require 'fileutils'

module TelegramTPR
  class << self
    def outbox_dir
      @outbox_dir ||= begin
        cmd_root = ENV['TPR_CMD_ROOT'] || '/root/!ZENS3N.CMD/.3ox'
        File.join(cmd_root, '.vec3', 'var', 'relay', 'outbox')
      end
    end

    def inbox_dir
      @inbox_dir ||= begin
        cmd_root = ENV['TPR_CMD_ROOT'] || '/root/!ZENS3N.CMD/.3ox'
        File.join(cmd_root, '.vec3', 'var', 'relay', 'inbox')
      end
    end

    def registrations_file
      @registrations_file ||= begin
        cmd_root = ENV['TPR_CMD_ROOT'] || '/root/!ZENS3N.CMD/.3ox'
        File.join(cmd_root, '.vec3', 'var', 'relay', 'registrations.json')
      end
    end

    # Send a message via TelePromptR
    # @param agent_id [String] Agent identifier
    # @param text [String] Message text
    # @param chat_id [Integer, nil] Target chat ID (nil to auto-resolve)
    # @param topic_thread_id [Integer, nil] Target topic/thread ID (nil to auto-resolve)
    # @param message_id [String, nil] Reply-to message ID
    # @return [String] Path to created envelope file
    def send_message(agent_id:, text:, chat_id: nil, topic_thread_id: nil, message_id: nil)
      envelope = {
        'agent_id' => agent_id.to_s,
        'text' => text.to_s,
        'chat_id' => chat_id,
        'topic_thread_id' => topic_thread_id,
        'timestamp' => Time.now.utc.iso8601,
        'message_id' => message_id,
        'trace_id' => SecureRandom.hex(8)
      }

      # Remove nil values
      envelope.reject! { |_k, v| v.nil? }

      # Ensure outbox directory exists
      FileUtils.mkdir_p(outbox_dir)

      # Write envelope
      filename = "#{Time.now.to_i}_#{SecureRandom.hex(4)}.json"
      filepath = File.join(outbox_dir, filename)
      File.write(filepath, JSON.pretty_generate(envelope))
      filepath
    end

    # Read pending inbox messages
    # @return [Array<Hash>] Array of inbox envelopes
    def read_inbox
      return [] unless Dir.exist?(inbox_dir)

      envelopes = []
      Dir.glob(File.join(inbox_dir, '*.json')).each do |path|
        begin
          envelope = JSON.parse(File.read(path))
          envelopes << envelope.merge('_filepath' => path)
        rescue JSON::ParserError => e
          warn "Failed to parse inbox envelope #{path}: #{e.message}"
        end
      end
      envelopes
    end

    # Mark inbox message as processed (move to processed/)
    def mark_processed(filepath)
      processed_dir = File.join(inbox_dir, 'processed')
      FileUtils.mkdir_p(processed_dir)
      FileUtils.mv(filepath, File.join(processed_dir, File.basename(filepath)))
    end

    # Register an agent with TelePromptR
    def register_agent(agent_id:, chat_id: nil, topic_thread_id: nil, metadata: {})
      registrations = if File.exist?(registrations_file)
                        JSON.parse(File.read(registrations_file)) rescue { 'agents' => {} }
                      else
                        { 'agents' => {} }
                      end

      registrations['agents'] ||= {}
      registrations['agents'][agent_id.to_s] = {
        'chat_id' => chat_id,
        'topic_thread_id' => topic_thread_id,
        'metadata' => metadata,
        'registered_at' => Time.now.utc.iso8601
      }
      registrations['last_updated'] = Time.now.utc.iso8601

      FileUtils.mkdir_p(File.dirname(registrations_file))
      File.write(registrations_file, JSON.pretty_generate(registrations))
    end
  end
end
RUBYEOF
  chmod 755 "$HELPER_SCRIPT"
fi

# Create example usage file
EXAMPLE_FILE="${CMD_ROOT}/.3ox/examples/telegram.tpr.example.rb"
if [[ ! -f "$EXAMPLE_FILE" ]]; then
  echo "📝 Creating example usage file..."
  mkdir -p "$(dirname "$EXAMPLE_FILE")"
  cat > "$EXAMPLE_FILE" <<'RUBYEOF'
#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Using TelePromptR from 3ox agent

require_relative '../vec3/lib/core/telegram.tpr'

# Register agent
TelegramTPR.register_agent(
  agent_id: 'my_agent',
  chat_id: -1001234567890,
  topic_thread_id: 123,
  metadata: { 'name' => 'My Agent', 'version' => '1.0' }
)

# Send a message
TelegramTPR.send_message(
  agent_id: 'my_agent',
  text: 'Hello from 3ox via TelePromptR!',
  chat_id: -1001234567890,
  topic_thread_id: 123
)

# Read incoming messages
inbox = TelegramTPR.read_inbox
inbox.each do |envelope|
  puts "Received: #{envelope['text']}"
  puts "From: #{envelope['from_user']}"
  puts "Chat: #{envelope['from_chat_id']}"
  
  # Process message...
  
  # Mark as processed
  TelegramTPR.mark_processed(envelope['_filepath'])
end
RUBYEOF
  chmod 755 "$EXAMPLE_FILE"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Set TELEGRAM_BOT_TOKEN environment variable"
echo "2. Configure route map: ${ROUTE_MAP}"
echo "3. Register your agents using TelegramTPR.register_agent"
echo "4. Start TelePromptR bridge: cd ${TPR_ROOT} && ./tools/telepromptr_bridge.rb start"
echo "5. Use TelegramTPR.send_message from your 3ox agents"
echo ""
echo "See: ${TPR_ROOT}/COMMO.SNIP.md for integration details"
echo "See: ${EXAMPLE_FILE} for usage examples"
