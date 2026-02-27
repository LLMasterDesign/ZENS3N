#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'optparse'
require 'time'

options = {
  agents: 24,
  messages: 2,
  bench_root: nil
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby tools/bench_bus_pipeline.rb [options]'

  opts.on('--agents N', Integer, 'Number of agents to simulate (default: 24)') { |v| options[:agents] = v }
  opts.on('--messages N', Integer, 'Messages per agent (default: 2)') { |v| options[:messages] = v }
  opts.on('--bench-root PATH', 'Bench root dir (default: _forge/runtime/bench/bus/<ts>)') { |v| options[:bench_root] = v }
end.parse!(ARGV)

repo_root = File.expand_path('..', __dir__)
stamp = Time.now.utc.strftime('%Y%m%dT%H%M%S')
bench_root = options[:bench_root]
if bench_root.nil? || bench_root.to_s.strip.empty?
  bench_root = File.join(repo_root, '_forge', 'runtime', 'bench', 'bus', stamp)
end

outbox_dir = File.join(bench_root, 'outbox')
reg_path = File.join(bench_root, 'registrations.json')
keys_dir = File.join(bench_root, 'keys')
audit_path = File.join(bench_root, 'route_audit.jsonl')
route_map_path = File.join(repo_root, 'CyberDeck', 'TPR.ROUTE.MAP.json')

FileUtils.mkdir_p(outbox_dir)
FileUtils.mkdir_p(File.dirname(reg_path))
FileUtils.mkdir_p(keys_dir)

ENV['TPR_RELAY_OUTBOX_DIR'] = outbox_dir
ENV['TPR_RELAY_REG_PATH'] = reg_path
ENV['TPR_KEYS_DIR'] = keys_dir
ENV['TPR_ROUTE_MAP_PATH'] = route_map_path
ENV['TPR_ROUTE_AUDIT_PATH'] = audit_path

# Ensure dry-run (no Telegram).
ENV.delete('TELEGRAM_BOT_TOKEN')

cmd = [
  'ruby',
  File.join(repo_root, 'tools', 'loadtest_bus.rb'),
  '--agents',
  options[:agents].to_s,
  '--messages',
  options[:messages].to_s
]

ok = system(*cmd)
exit(2) unless ok

require_relative 'telepromptr_bridge'

bridge = TelePromptRBridge.new
start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
drained = bridge.drain_once
elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
rate = elapsed.positive? ? (drained / elapsed) : 0.0

puts "bench_bus: drained=#{drained} seconds=#{format('%.4f', elapsed)} rate=#{format('%.2f', rate)} envelopes/s"
puts "bench_bus: outbox_dir=#{outbox_dir}"
puts "bench_bus: reg_path=#{reg_path}"
puts "bench_bus: audit=#{audit_path}"
puts "bench_bus: route_map=#{route_map_path}"

