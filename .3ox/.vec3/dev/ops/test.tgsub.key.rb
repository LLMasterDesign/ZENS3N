# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x1A65]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // TEST.TGSUB.KEY.RB ▞▞
# ▛▞// TEST.TGSUB.KEY.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [telegram] [json] [glyph] [kernel] [prism] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.test.tgsub.key.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for TEST.TGSUB.KEY.RB
# ```

# 


# 


# ▛//▞ PRISM :: KERNEL
# P:: identity.matrix ∙ context.anchor ∙ execution.flow
# R:: load.context ∙ execute.logic ∙ emit.result
# I:: intent.target={system.stability ∙ function.execution}
# S:: init → process → terminate
# M:: std.io ∙ file.sys ∙ mem.state
# :: ∎

#!/usr/bin/env ruby
# Test tgsub.key functionality

require 'json'
require 'fileutils'

# Test 1: Check if example tgsub.key exists
keys_dir = File.join(__dir__, '../../..', 'keys')
example_key = File.join(keys_dir, 'CMD.BRIDGE.tgsub.key')

puts "▛▞ Testing tgsub.key System"
puts ""

# Check if keys directory exists
if Dir.exist?(keys_dir)
  puts "✓ Keys directory exists: #{keys_dir}"
else
  puts "✗ Keys directory missing: #{keys_dir}"
  FileUtils.mkdir_p(keys_dir)
  puts "  → Created keys directory"
end

# Check for example key
if File.exist?(example_key)
  puts "✓ Example key found: #{File.basename(example_key)}"
  begin
    key_data = JSON.parse(File.read(example_key))
    puts "  Agent ID: #{key_data['agent_id']}"
    puts "  Status: #{key_data['status']}"
    puts "  Last Seen: #{key_data['last_seen']}"
  rescue => e
    puts "  ✗ Key file corrupted: #{e.message}"
  end
else
  puts "✗ Example key not found: #{File.basename(example_key)}"
  puts "  → Creating example key..."
  
  example_data = {
    agent_id: "CMD.BRIDGE",
    agent_name: "CMD Bridge",
    agent_type: "base",
    pico_glyph: "⚙️",
    chat_id: 0,  # Set your chat ID
    default_topic: "general",
    subscribed_topics: ["general", "status", "alerts", "Initializing"],
    issued_at: Time.now.utc.iso8601,
    status: "active",
    last_seen: Time.now.utc.iso8601,
    initialized: false
  }
  
  File.write(example_key, JSON.pretty_generate(example_data))
  puts "  ✓ Created example key"
end

# Test 2: Test TeleprompterClient key check
puts ""
puts "▛▞ Testing TeleprompterClient"
begin
  require_relative '../../lib/providers/telegram_bus'
  require_relative '../../../!CMD.CENTER/!CMD.OPS/Toolkits/telegram.kit/tools/teleprompter_client'
  
  client = Vec3::TeleprompterClient.new(
    agent_id: "CMD.BRIDGE",
    agent_name: "CMD Bridge Test",
    pico_glyph: "⚙️"
  )
  
  puts "✓ TeleprompterClient initialized"
  
  # Check key
  key_status = client.check_tgsub_key
  if key_status[:connected]
    puts "✓ tgsub.key connection verified"
    puts "  Status: #{key_status[:status]}"
    puts "  Last Seen: #{key_status[:last_seen]}"
  else
    puts "⚠ tgsub.key not found or invalid"
    puts "  Error: #{key_status[:error]}"
    puts "  → Key will be created when Teleprompter is running"
  end
  
rescue LoadError => e
  puts "⚠ Could not load TeleprompterClient: #{e.message}"
  puts "  → This is expected if teleprompter hasn't been migrated yet"
rescue => e
  puts "✗ Error testing client: #{e.message}"
end

puts ""
puts "▛▞ Test Complete"
puts ""
puts "Next Steps:"
puts "1. Start Teleprompter: ruby .3ox/vec3/lib/providers/telegram.rb start"
puts "2. Teleprompter will create/update tgsub.key files automatically"
puts "3. Use /chatid in Telegram to get your chat ID"

# :: ∎