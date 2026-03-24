#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'time'

options = {
  var_dir: nil,
  state_dir: nil,
  dry_run: true
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby tools/bench_mesh.rb [options]'

  opts.on('--var-dir PATH', 'TPR var dir (default: runtime/vps/3ox.station/vec3/var)') { |v| options[:var_dir] = v }
  opts.on('--state-dir PATH', 'Mesh state dir (default: _forge/runtime/bench/mesh/<ts>)') { |v| options[:state_dir] = v }
  opts.on('--dry-run BOOL', 'Disable LLM calls (default: true)') { |v| options[:dry_run] = %w[1 true yes y on].include?(v.to_s.strip.downcase) }
end.parse!(ARGV)

repo_root = File.expand_path('..', __dir__)

var_dir = options[:var_dir]
if var_dir.nil? || var_dir.to_s.strip.empty?
  var_dir = File.join(repo_root, 'runtime', 'vps', '3ox.station', 'vec3', 'var')
end

state_dir = options[:state_dir]
if state_dir.nil? || state_dir.to_s.strip.empty?
  stamp = Time.now.utc.strftime('%Y%m%dT%H%M%S')
  state_dir = File.join(repo_root, '_forge', 'runtime', 'bench', 'mesh', stamp)
end

ENV['TPR_VAR_DIR'] = var_dir
ENV['TPR_MESH_STATE_DIR'] = state_dir
ENV['TPR_MESH_DRY_RUN'] = options[:dry_run] ? '1' : '0'

require_relative 'speaker_mesh'

inbox_dir = File.join(var_dir, 'inbox')
outbox_dir = File.join(var_dir, 'outbox')

pending_before = Dir.exist?(inbox_dir) ? Dir.glob(File.join(inbox_dir, '*.json')).length : 0
start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

mesh = SpeakerMesh.new
processed = mesh.drain_once

elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
pending_after = Dir.exist?(inbox_dir) ? Dir.glob(File.join(inbox_dir, '*.json')).length : 0
outbox_count = Dir.exist?(outbox_dir) ? Dir.glob(File.join(outbox_dir, '*.json')).length : 0

rate = elapsed.positive? ? (processed / elapsed) : 0.0

puts "bench_mesh: processed=#{processed} seconds=#{format('%.4f', elapsed)} rate=#{format('%.2f', rate)} msg/s"
puts "bench_mesh: inbox_before=#{pending_before} inbox_after=#{pending_after} outbox=#{outbox_count}"
puts "bench_mesh: var_dir=#{var_dir}"
puts "bench_mesh: state_dir=#{state_dir}"
puts "bench_mesh: dry_run=#{options[:dry_run]}"

