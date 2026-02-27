#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'optparse'
require 'securerandom'
require 'time'

options = {
  agents: 24,
  messages: 2,
  chat_id: nil,
  topic: nil
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby tools/loadtest_bus.rb [options]'

  opts.on('--agents N', Integer, 'Number of agents to simulate (default: 24)') do |v|
    options[:agents] = v
  end

  opts.on('--messages N', Integer, 'Messages per agent (default: 2)') do |v|
    options[:messages] = v
  end

  opts.on('--chat-id ID', 'Override chat_id for all generated messages') do |v|
    options[:chat_id] = v
  end

  opts.on('--topic TOPIC', 'Override topic_thread_id/topic name for all messages') do |v|
    options[:topic] = v
  end
end.parse!(ARGV)

repo_root = File.expand_path('..', __dir__)
default_cmd_root = ENV['TPR_CMD_ROOT'].to_s.strip
if default_cmd_root.empty?
  default_cmd_root = '/root/!ZENS3N.CMD/.3ox'
end

outbox_dir = ENV['TPR_BUS_OUTBOX_DIR'].to_s.strip
if outbox_dir.empty?
  outbox_dir = File.join(default_cmd_root, '.vec3', 'var', 'telegram_bus', 'outbox')
end

reg_path = ENV['TPR_BUS_REG_PATH'].to_s.strip
if reg_path.empty?
  reg_path = File.join(default_cmd_root, '.vec3', 'var', 'telegram_bus', 'registrations.json')
end

route_map_path = ENV['TPR_ROUTE_MAP_PATH'].to_s.strip
if route_map_path.empty?
  route_map_path = File.join(repo_root, 'CyberDeck', 'TPR.ROUTE.MAP.json')
end

FileUtils.mkdir_p(outbox_dir)
FileUtils.mkdir_p(File.dirname(reg_path))

route_map = {}
if File.exist?(route_map_path)
  begin
    route_map = JSON.parse(File.read(route_map_path))
  rescue StandardError => e
    warn "loadtest: failed to parse route map #{route_map_path}: #{e.message}"
    route_map = {}
  end
end

default_route = route_map['default']
default_route = {} unless default_route.is_a?(Hash)
agents_route = route_map['agents']
agents_route = {} unless agents_route.is_a?(Hash)

registrations = {}
if File.exist?(reg_path)
  begin
    payload = JSON.parse(File.read(reg_path))
    registrations = payload if payload.is_a?(Hash)
  rescue StandardError => e
    warn "loadtest: failed to parse registrations #{reg_path}: #{e.message}"
    registrations = {}
  end
end

if options[:agents] <= 0 || options[:messages] <= 0
  warn 'loadtest: --agents and --messages must be > 0'
  exit(2)
end

created = 0
agents = (1..options[:agents]).map { |i| format('agent_%02d', i) }

agents.each do |agent_id|
  route_entry = default_route.dup
  specific = agents_route[agent_id]
  route_entry.merge!(specific) if specific.is_a?(Hash)

  chat_id = options[:chat_id] || route_entry['chat_id']
  topic = options[:topic]
  topic = route_entry['default_topic'] if topic.nil? || topic.to_s.strip.empty?

  registrations[agent_id] = {
    'agent_id' => agent_id,
    'agent_name' => route_entry['agent_name'] || agent_id,
    'agent_type' => route_entry['agent_type'] || 'agent',
    'pico_glyph' => route_entry['pico_glyph'] || 'AI',
    'status' => 'active',
    'last_seen' => Time.now.utc.iso8601
  }

  options[:messages].times do |idx|
    payload = {
      'agent_id' => agent_id,
      'chat_id' => chat_id,
      'topic_thread_id' => topic,
      'text' => "loadtest msg #{idx + 1}/#{options[:messages]} from #{agent_id}",
      'timestamp' => Time.now.utc.iso8601,
      'message_id' => "load_#{agent_id}_#{idx + 1}_#{SecureRandom.hex(4)}",
      'trace_id' => "trace_#{SecureRandom.hex(8)}"
    }

    ts = Time.now.utc.strftime('%Y%m%dT%H%M%S%L')
    out_file = File.join(outbox_dir, "#{ts}_#{agent_id}_#{idx + 1}.json")
    File.write(out_file, JSON.pretty_generate(payload))
    created += 1
  end
end

File.write(reg_path, JSON.pretty_generate(registrations))

puts "loadtest: queued=#{created} agents=#{options[:agents]} msgs_per_agent=#{options[:messages]}"
puts "loadtest: outbox_dir=#{outbox_dir}"
puts "loadtest: registrations=#{reg_path}"
puts "loadtest: route_map=#{route_map_path}"
