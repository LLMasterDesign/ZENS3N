#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'optparse'
require 'securerandom'
require 'time'

options = {
  subscribers: 24,
  messages: 100,
  chat_id: -1001234567890,
  thread_id: nil,
  var_dir: nil,
  listen_only: true
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby tools/bench_fanout.rb [options]'

  opts.on('--subscribers N', Integer, 'Number of subscriber agents (default: 24)') { |v| options[:subscribers] = v }
  opts.on('--messages N', Integer, 'Number of human messages to fan out (default: 100)') { |v| options[:messages] = v }
  opts.on('--chat-id ID', 'chat_id in envelopes') { |v| options[:chat_id] = v }
  opts.on('--thread-id ID', 'thread_id in envelopes') { |v| options[:thread_id] = v }
  opts.on('--var-dir PATH', 'Target var dir (default: runtime/vps/3ox.station/vec3/var)') { |v| options[:var_dir] = v }
  opts.on('--listen-only BOOL', 'Set meta.listen_only (default: true)') { |v| options[:listen_only] = %w[1 true yes y on].include?(v.to_s.strip.downcase) }
end.parse!(ARGV)

subs = options[:subscribers].to_i
msgs = options[:messages].to_i
if subs <= 0 || msgs <= 0
  warn 'bench_fanout: --subscribers and --messages must be > 0'
  exit(2)
end

repo_root = File.expand_path('..', __dir__)
var_dir = options[:var_dir]
if var_dir.nil? || var_dir.to_s.strip.empty?
  var_dir = File.join(repo_root, 'runtime', 'vps', '3ox.station', 'vec3', 'var')
end

inbox_dir = File.join(var_dir, 'inbox')
FileUtils.mkdir_p(inbox_dir)

agents = (1..subs).map { |i| format('agent_%02d', i) }
from_user = { 'username' => 'fanout', 'is_bot' => false, 'id' => 0 }

meta = { 'fanout' => true }
meta['listen_only'] = true if options[:listen_only]

total = 0
start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

msgs.times do |i|
  text = "fanout human msg #{i + 1}/#{msgs}"
  agents.each do |agent_id|
    message_id = "msg_#{Time.now.utc.strftime('%Y%m%dT%H%M%S%L')}_#{SecureRandom.hex(6)}"
    payload = {
      'message_id' => message_id,
      'from_chat_id' => options[:chat_id],
      'from_thread_id' => options[:thread_id],
      'from_user' => from_user,
      'text' => text,
      'original_text' => text,
      'routed_to' => agent_id,
      'route_reason' => 'subscription',
      'meta' => meta,
      'routed_at' => Time.now.utc.iso8601,
      'normalized' => true
    }

    final = File.join(inbox_dir, "#{agent_id}_#{message_id}.json")
    tmp = "#{final}.tmp.#{$$}"
    File.write(tmp, JSON.pretty_generate(payload))
    FileUtils.mv(tmp, final)
    total += 1
  end
end

elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
rate = elapsed.positive? ? (total / elapsed) : 0.0

puts "bench_fanout: subscribers=#{subs} human_messages=#{msgs} wrote=#{total} seconds=#{format('%.4f', elapsed)} rate=#{format('%.2f', rate)} envelopes/s"
puts "bench_fanout: inbox_dir=#{inbox_dir}"

