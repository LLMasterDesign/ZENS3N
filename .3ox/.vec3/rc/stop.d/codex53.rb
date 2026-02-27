#!/usr/bin/env ruby
# stop.d/codex53.rb - stops codex53 runner.

require 'fileutils'

SERVICE_ID = 'codex53'
VEC3_ROOT = File.realpath(File.join(__dir__, '../..'))
PID_FILE = File.join(VEC3_ROOT, 'var', 'state', "#{SERVICE_ID}.pid")


def pid_alive?(pid)
  Process.kill(0, pid)
  true
rescue Errno::ESRCH, Errno::EPERM
  false
end

unless File.exist?(PID_FILE)
  puts "#{SERVICE_ID} not running (pid file missing)"
  exit 0
end

pid = File.read(PID_FILE).to_i
if pid <= 0
  FileUtils.rm_f(PID_FILE)
  puts "#{SERVICE_ID} not running"
  exit 0
end

if pid_alive?(pid)
  begin
    Process.kill('TERM', pid)
  rescue Errno::ESRCH
  end

  30.times do
    break unless pid_alive?(pid)
    sleep 0.2
  end

  if pid_alive?(pid)
    begin
      Process.kill('KILL', pid)
    rescue Errno::ESRCH
    end
  end
end

FileUtils.rm_f(PID_FILE)
puts "#{SERVICE_ID} stopped"
