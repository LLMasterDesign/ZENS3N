#!/usr/bin/env ruby
# status.d/codex53.rb - prints codex53 runtime status.

require 'json'
require 'time'

SERVICE_ID = 'codex53'
VEC3_ROOT = File.realpath(File.join(__dir__, '../..'))
BASE_3OX = File.realpath(File.join(VEC3_ROOT, '..'))
PULSE_ROOT = File.join(BASE_3OX, 'Pulse', SERVICE_ID)
INBOX_DIR = File.join(PULSE_ROOT, 'inbox')
OUTBOX_DIR = File.join(PULSE_ROOT, 'outbox')
PID_FILE = File.join(VEC3_ROOT, 'var', 'state', "#{SERVICE_ID}.pid")
HEARTBEAT_FILE = File.join(VEC3_ROOT, 'var', 'state', "#{SERVICE_ID}.heartbeat.json")


def pid_alive?(pid)
  Process.kill(0, pid)
  true
rescue Errno::ESRCH, Errno::EPERM
  false
end

pid = File.exist?(PID_FILE) ? File.read(PID_FILE).to_i : nil
running = pid && pid > 0 && pid_alive?(pid)
heartbeat = File.exist?(HEARTBEAT_FILE) ? JSON.parse(File.read(HEARTBEAT_FILE)) : nil

payload = {
  service: SERVICE_ID,
  running: running,
  pid: running ? pid : nil,
  inbox: Dir.glob(File.join(INBOX_DIR, '*.task.md')).length,
  outbox_results: Dir.glob(File.join(OUTBOX_DIR, '*.result.md')).length,
  outbox_errors: Dir.glob(File.join(OUTBOX_DIR, '*.error.md')).length,
  heartbeat: heartbeat
}

if ARGV.include?('--json')
  puts JSON.pretty_generate(payload)
else
  state = running ? 'running' : 'stopped'
  puts "#{SERVICE_ID}: #{state}"
  puts "pid: #{payload[:pid] || 'n/a'}"
  puts "inbox: #{payload[:inbox]}"
  puts "outbox results: #{payload[:outbox_results]}"
  puts "outbox errors: #{payload[:outbox_errors]}"
  puts "heartbeat: #{heartbeat ? heartbeat['ts'] : 'n/a'}"
end
