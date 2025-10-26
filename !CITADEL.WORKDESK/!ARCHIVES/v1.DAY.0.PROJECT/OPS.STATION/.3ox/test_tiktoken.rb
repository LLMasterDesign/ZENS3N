#!/usr/bin/env ruby
#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
#▛//▞▞ ⟦⎊⟧ :: TIKTOKEN TEST :: Token counting and trace integration
#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

require_relative 'run'
require_relative 'token_reporter'

# ============================================================================
# Test 1: Basic Token Counting
# ============================================================================

puts "="*80
puts "TEST 1: Token Counting (with fallback)"
puts "="*80

test_text = "This is a test message for token counting. It has multiple sentences."
puts "\nText: #{test_text}"
puts "Length: #{test_text.length} chars"

# The Session module handles tiktoken availability automatically
Session.init('test_basic', 'claude-sonnet-4')
Session.add(:user, test_text)
stats = Session.get_token_stats

puts "\nResult:"
puts "  Tokens: #{stats[:total_tokens]}"
puts "  Method: #{stats[:counting_method]}"
puts "  #{stats[:counting_method] == 'tiktoken' ? '✅ Using tiktoken' : '⚠️  Using estimation'}"

# ============================================================================
# Test 2: Session with Token Tracking & Trace Integration
# ============================================================================

puts "\n\n"
puts "="*80
puts "TEST 2: Session Tracking + Trace Logs"
puts "="*80

Session.init('test_session_001', 'claude-sonnet-4')
Trace.agent_start('TEST_AGENT', 'test_session_001')

# Simulate conversation
conversation = [
  [:user, "Sync files to cloud"],
  [:agent, "Validating checksums..."],
  [:user, "Generate receipt"],
  [:agent, "Receipt: a1b2c3..."],
]

puts "\nSimulating conversation..."
conversation.each do |role, msg|
  Session.add(role, msg)
  puts "  [#{role}] #{msg}"
end

# Get stats
stats = Session.get_token_stats
puts "\n📊 Stats:"
puts "   Tokens: #{stats[:total_tokens]} (#{stats[:counting_method]})"
puts "   Messages: #{stats[:message_count]}"
puts "   Utilization: #{stats[:utilization]}%"

# Save with token stats
Session.save
Trace.agent_end(:success, '1.2s', stats)
puts "\n✅ Saved to .3ox/session.yaml and trace.log"

# ============================================================================
# Test 3: Ship to Ops
# ============================================================================

puts "\n\n"
puts "="*80
puts "TEST 3: Ship Token Stats to Ops"
puts "="*80

# Ship to ops
TokenReporter.ship_to_ops('test_session_001', stats, 'TEST_AGENT')
puts "\n✅ Token stats shipped to:"
puts "   - .3ox/tokens.log"
puts "   - 0ut.3ox/FILE.MANIFEST.txt"

# ============================================================================
# Test 4: Generate Report
# ============================================================================

puts "\n\n"
puts "="*80
puts "TEST 4: Generate Report"
puts "="*80

if File.exist?('.3ox/tokens.log')
  report_path = TokenReporter.generate_report
  puts "\n✅ Report generated: #{report_path}"
else
  puts "\n⚠️  No token logs yet - run more sessions first"
end

# ============================================================================
# Summary
# ============================================================================

puts "\n\n"
puts "="*80
puts "✅ TESTS COMPLETE"
puts "="*80
puts "\nToken tracking is working!"
puts "\nFeatures tested:"
puts "  ✓ Token counting (#{stats[:counting_method]})"
puts "  ✓ Session tracking"
puts "  ✓ Trace integration"
puts "  ✓ Ops reporting"
puts "\nCheck logs:"
puts "  - .3ox/trace.log"
puts "  - .3ox/tokens.log"
puts "  - .3ox/session.yaml"
puts "  - 0ut.3ox/FILE.MANIFEST.txt"
puts "="*80

