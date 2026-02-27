#!/usr/bin/env ruby
# start.d/codex53.rb - starts codex53 runner on dedicated worktree.

require 'fileutils'

SERVICE_ID = 'codex53'
BRANCH_NAME = ENV.fetch('CODEX53_BRANCH', 'codex53-work')
VEC3_ROOT = File.realpath(File.join(__dir__, '../..'))
BASE_3OX = File.realpath(File.join(VEC3_ROOT, '..'))
WORKSPACE_ROOT = File.realpath(File.join(BASE_3OX, '..'))
WORKTREE_DIR = ENV.fetch('CODEX53_WORKTREE', File.join(WORKSPACE_ROOT, '!WORKDESK', 'codex53-work'))
RUNNER_PATH = File.join(VEC3_ROOT, 'rc', 'services', 'codex53.runner.rb')
PID_FILE = File.join(VEC3_ROOT, 'var', 'state', "#{SERVICE_ID}.pid")
LOG_FILE = File.join(VEC3_ROOT, 'var', 'log', "#{SERVICE_ID}.log")


def pid_alive?(pid)
  Process.kill(0, pid)
  true
rescue Errno::ESRCH, Errno::EPERM
  false
end

def ensure_worktree!
  return if Dir.exist?(WORKTREE_DIR)

  FileUtils.mkdir_p(File.dirname(WORKTREE_DIR))
  Dir.chdir(WORKSPACE_ROOT) do
    branch_exists = system('git', 'show-ref', '--verify', '--quiet', "refs/heads/#{BRANCH_NAME}")
    ok = if branch_exists
      system('git', 'worktree', 'add', WORKTREE_DIR, BRANCH_NAME)
    else
      system('git', 'worktree', 'add', '-b', BRANCH_NAME, WORKTREE_DIR, 'HEAD')
    end
    abort("Failed to create worktree at #{WORKTREE_DIR}") unless ok
  end
end

if File.exist?(PID_FILE)
  pid = File.read(PID_FILE).to_i
  if pid > 0 && pid_alive?(pid)
    puts "#{SERVICE_ID} already running (pid #{pid})"
    exit 0
  end
  FileUtils.rm_f(PID_FILE)
end

ensure_worktree!
puts "starting #{SERVICE_ID} (worktree: #{WORKTREE_DIR})"
FileUtils.mkdir_p(File.dirname(LOG_FILE))
pid = Process.spawn(
  'ruby', RUNNER_PATH,
  chdir: WORKSPACE_ROOT,
  pgroup: true,
  out: [LOG_FILE, 'a'],
  err: [LOG_FILE, 'a']
)
Process.detach(pid)
puts "#{SERVICE_ID} launch requested (pid #{pid})"
