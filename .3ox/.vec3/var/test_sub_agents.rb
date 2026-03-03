#!/usr/bin/env ruby
# test_sub_agents.rb :: Test sub-agent routing without Telegram
# Run: ruby .3ox/.vec3/var/test_sub_agents.rb

config_path = File.join(__dir__, 'sub_agents.toml')
unless File.exist?(config_path)
  puts "✗ sub_agents.toml not found at #{config_path}"
  exit 1
end

# Minimal TOML parse for sub_agents format (no toml-rb required)
def parse_sub_agents_toml(path)
  config = { 'default' => {}, 'by_topic' => {}, 'by_command' => {} }
  section = nil
  File.readlines(path).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    if line =~ /^\[([^\]]+)\]$/
      section = $1
      config[section] ||= {}
    elsif section && line =~ /^(\w+)\s*=\s*"([^"]*)"$/
      config[section][$1] = $2
    end
  end
  config
end

config = parse_sub_agents_toml(config_path)

def resolve(config, command:, topic_name: nil)
  default = config.dig('default', 'dispatch_agent') || 'think'
  return config['by_command'][command].to_s.strip if command && config.dig('by_command', command)
  return config['by_topic'][topic_name].to_s.strip if topic_name && config.dig('by_topic', topic_name)
  default
end

ok = 0
fail_count = 0
[
  [nil, nil, 'think'],
  ['ask', nil, 'think'],
  ['code', nil, 'codex53'],
  [nil, 'Code', 'think'],  # no by_topic entry for Code yet
  [nil, 'General', 'think']
].each do |cmd, topic, expected|
  got = resolve(config, command: cmd, topic_name: topic)
  if got == expected
    puts "✓ command=#{cmd.inspect} topic=#{topic.inspect} → #{got}"
    ok += 1
  else
    puts "✗ command=#{cmd.inspect} topic=#{topic.inspect} → #{got} (expected #{expected})"
    fail_count += 1
  end
end

puts ""
puts "▛▞ test_sub_agents: #{ok} pass, #{fail_count} fail"
exit fail_count > 0 ? 1 : 0
