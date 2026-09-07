#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'optparse'
require 'securerandom'
require 'time'

options = {
  agents: 24,
  agent_names: [],
  messages: 100,
  chat_id: -1001234567890,
  thread_id: nil,
  var_dir: nil,
  listen_only: true,
  force_reply: false
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby tools/loadtest_inbox.rb [options]'

  opts.on('--agents N', Integer, 'Number of agents to generate (default: 24)') { |v| options[:agents] = v }
  opts.on('--agent NAME', 'Explicit agent id (repeatable)') { |v| options[:agent_names] << v }
  opts.on('--messages N', Integer, 'Messages per agent (default: 100)') { |v| options[:messages] = v }
  opts.on('--chat-id ID', 'Override chat_id for all messages') { |v| options[:chat_id] = v }
  opts.on('--thread-id ID', 'Override thread_id for all messages') { |v| options[:thread_id] = v }
  opts.on('--var-dir PATH', 'Target var dir (default: runtime/vps/3ox.station/vec3/var)') { |v| options[:var_dir] = v }
  opts.on('--listen-only BOOL', 'Set meta.listen_only (default: true)') { |v| options[:listen_only] = %w[1 true yes y on].include?(v.to_s.strip.downcase) }
  opts.on('--force-reply BOOL', 'Set meta.force_reply (default: false)') { |v| options[:force_reply] = %w[1 true yes y on].include?(v.to_s.strip.downcase) }
end.parse!(ARGV)

repo_root = File.expand_path('..', __dir__)
var_dir = options[:var_dir]
if var_dir.nil? || var_dir.to_s.strip.empty?
  var_dir = File.join(repo_root, 'runtime', 'vps', '3ox.station', 'vec3', 'var')
end

inbox_dir = File.join(var_dir, 'inbox')
agents_path = File.join(var_dir, 'agents.json')

FileUtils.mkdir_p(inbox_dir)
FileUtils.mkdir_p(var_dir)

agent_names = options[:agent_names].map { |v| v.to_s.strip }.reject(&:empty?)
if agent_names.empty?
  count = options[:agents].to_i
  if count <= 0
    warn 'loadtest_inbox: --agents must be > 0 (or provide --agent NAME)'
    exit(2)
  end
  agent_names = (1..count).map { |i| format('agent_%02d', i) }
end

messages_per = options[:messages].to_i
if messages_per <= 0
  warn 'loadtest_inbox: --messages must be > 0'
  exit(2)
end

chat_id = options[:chat_id]
thread_id = options[:thread_id]

meta = {}
meta['listen_only'] = true if options[:listen_only]
meta['force_reply'] = true if options[:force_reply]
meta['loadtest'] = true

from_user = { 'username' => 'loadtest', 'is_bot' => false, 'id' => 0 }

# Best-effort agent registry so mesh can pick up glyphs/listen_only defaults if desired.
agent_registry = {}
agent_names.each do |agent_id|
  agent_registry[agent_id] = {
    'agent_id' => agent_id,
    'glyph' => 'AI',
    'status' => 'active',
    'last_seen' => Time.now.utc.iso8601
  }
end
File.write(agents_path, JSON.pretty_generate(agent_registry))

created = 0
agent_names.each do |agent_id|
  messages_per.times do |idx|
    message_id = "msg_#{Time.now.utc.strftime('%Y%m%dT%H%M%S%L')}_#{SecureRandom.hex(6)}"
    text = "loadtest inbound #{idx + 1}/#{messages_per} agent=#{agent_id}"

    payload = {
      'message_id' => message_id,
      'from_chat_id' => chat_id,
      'from_thread_id' => thread_id,
      'from_user' => from_user,
      'text' => text,
      'original_text' => text,
      'raw_message' => { 'loadtest' => true, 'idx' => idx + 1, 'agent' => agent_id },
      'routed_to' => agent_id,
      'route_reason' => 'loadtest',
      'meta' => meta,
      'routed_at' => Time.now.utc.iso8601,
      'sirius_time' => 'SIRIUS-loadtest',
      'normalized' => true
    }

    final = File.join(inbox_dir, "#{agent_id}_#{message_id}.json")
    tmp = "#{final}.tmp.#{$$}"
    File.write(tmp, JSON.pretty_generate(payload))
    FileUtils.mv(tmp, final)
    created += 1
  end
end

puts "loadtest_inbox: queued=#{created} agents=#{agent_names.length} msgs_per_agent=#{messages_per}"
puts "loadtest_inbox: var_dir=#{var_dir}"
puts "loadtest_inbox: inbox_dir=#{inbox_dir}"
puts "loadtest_inbox: agents_path=#{agents_path}"
