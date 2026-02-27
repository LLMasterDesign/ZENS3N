#!/usr/bin/env ruby
# codex53 runner: consumes .task.md files and runs codex exec in a dedicated worktree.

require 'fileutils'
require 'json'
require 'open3'
require 'time'

SERVICE_ID = 'codex53'
POLL_SECONDS = Integer(ENV.fetch('CODEX53_POLL_SECONDS', '2'))
TASK_TIMEOUT_SECONDS = Integer(ENV.fetch('CODEX53_TASK_TIMEOUT_SEC', '900'))

VEC3_ROOT = File.realpath(File.join(__dir__, '../..'))
BASE_3OX = File.realpath(File.join(VEC3_ROOT, '..'))
WORKSPACE_ROOT = File.realpath(File.join(BASE_3OX, '..'))
PULSE_ROOT = File.join(BASE_3OX, 'Pulse', SERVICE_ID)
INBOX_DIR = File.join(PULSE_ROOT, 'inbox')
OUTBOX_DIR = File.join(PULSE_ROOT, 'outbox')
ARCHIVE_DIR = File.join(PULSE_ROOT, 'archive')
FAILED_DIR = File.join(PULSE_ROOT, 'failed')
STATE_DIR = File.join(PULSE_ROOT, 'state')
WORKTREE_DIR = ENV.fetch('CODEX53_WORKTREE', File.join(WORKSPACE_ROOT, '!WORKDESK', 'codex53-work'))
PID_FILE = File.join(VEC3_ROOT, 'var', 'state', "#{SERVICE_ID}.pid")
HEARTBEAT_FILE = File.join(VEC3_ROOT, 'var', 'state', "#{SERVICE_ID}.heartbeat.json")
LOG_FILE = File.join(VEC3_ROOT, 'var', 'log', "#{SERVICE_ID}.log")

class Codex53Runner
  def initialize
    @running = true
    trap('INT') { @running = false }
    trap('TERM') { @running = false }
  end

  def run
    ensure_paths
    File.write(PID_FILE, Process.pid.to_s)
    log("runner started pid=#{Process.pid} worktree=#{WORKTREE_DIR}")

    while @running
      processed = process_one_task
      write_heartbeat(processed)
      sleep(POLL_SECONDS) unless processed
    end
  ensure
    FileUtils.rm_f(PID_FILE)
    log('runner stopped')
  end

  private

  def ensure_paths
    [INBOX_DIR, OUTBOX_DIR, ARCHIVE_DIR, FAILED_DIR, STATE_DIR, File.dirname(PID_FILE), File.dirname(LOG_FILE)].each do |dir|
      FileUtils.mkdir_p(dir)
    end
  end

  def log(message)
    line = "[#{Time.now.utc.iso8601}] #{message}"
    File.open(LOG_FILE, 'a') { |f| f.puts(line) }
  end

  def write_heartbeat(processed)
    payload = {
      service: SERVICE_ID,
      pid: Process.pid,
      ts: Time.now.utc.iso8601,
      processed: processed,
      inbox: Dir.glob(File.join(INBOX_DIR, '*.task.md')).length,
      outbox: Dir.glob(File.join(OUTBOX_DIR, '*.result.md')).length
    }
    File.write(HEARTBEAT_FILE, JSON.pretty_generate(payload))
  end

  def process_one_task
    task_path = Dir.glob(File.join(INBOX_DIR, '*.task.md')).sort.first
    return false unless task_path

    processing_path = "#{task_path}.processing"
    begin
      File.rename(task_path, processing_path)
    rescue Errno::ENOENT, Errno::EACCES
      return false
    end

    task_id = File.basename(processing_path).sub(/\.task\.md\.processing\z/, '')
    started_at = Time.now.utc
    prompt = File.read(processing_path)

    codex = resolve_codex_bin
    unless codex
      write_failure(task_id, started_at, 'codex command not found in PATH', '', 127, false)
      FileUtils.mv(processing_path, File.join(FAILED_DIR, "#{task_id}.failed.task.md"))
      return true
    end

    if prompt.strip.empty?
      write_failure(task_id, started_at, 'task prompt is empty', '', 2, false)
      FileUtils.mv(processing_path, File.join(FAILED_DIR, "#{task_id}.failed.task.md"))
      return true
    end

    last_message_path = File.join(STATE_DIR, "#{task_id}.last_message.txt")
    codex_home = File.join(PULSE_ROOT, 'codex_home')
    FileUtils.mkdir_p(codex_home)
    cmd = [
      'env', "CODEX_HOME=#{codex_home}",
      'timeout', '--signal=TERM', "#{TASK_TIMEOUT_SECONDS}s",
      codex, 'exec',
      '--cd', WORKTREE_DIR,
      '--skip-git-repo-check',
      '--output-last-message', last_message_path,
      prompt
    ]

    stdout_text, stderr_text, status = Open3.capture3(*cmd)
    exit_code = status.exitstatus
    timed_out = (exit_code == 124)
    finished_at = Time.now.utc

    response_text = if File.exist?(last_message_path)
      File.read(last_message_path)
    else
      stdout_text
    end

    if status.success?
      write_success(task_id, started_at, finished_at, response_text, stdout_text, stderr_text, exit_code)
      FileUtils.mv(processing_path, File.join(ARCHIVE_DIR, "#{task_id}.done.task.md"))
      log("task=#{task_id} status=ok exit=#{exit_code}")
    else
      write_failure(task_id, started_at, stderr_text, stdout_text, exit_code, timed_out, finished_at)
      FileUtils.mv(processing_path, File.join(FAILED_DIR, "#{task_id}.failed.task.md"))
      log("task=#{task_id} status=error exit=#{exit_code} timeout=#{timed_out}")
    end

    FileUtils.rm_f(last_message_path)
    true
  rescue StandardError => e
    log("task processing error: #{e.class}: #{e.message}")
    FileUtils.mv(processing_path, File.join(FAILED_DIR, "#{task_id}.failed.task.md")) if defined?(processing_path) && File.exist?(processing_path)
    true
  end

  def write_success(task_id, started_at, finished_at, response_text, stdout_text, stderr_text, exit_code)
    result_path = File.join(OUTBOX_DIR, "#{task_id}.result.md")
    receipt_path = File.join(OUTBOX_DIR, "#{task_id}.receipt.json")

    body = []
    body << "# codex53 result: #{task_id}"
    body << ''
    body << "- status: ok"
    body << "- started_at: #{started_at.iso8601}"
    body << "- finished_at: #{finished_at.iso8601}"
    body << "- exit_code: #{exit_code}"
    body << "- worktree: #{WORKTREE_DIR}"
    body << ''
    body << '## response'
    body << ''
    body << response_text.to_s.strip
    body << ''
    File.write(result_path, body.join("\n"))

    receipt = {
      service: SERVICE_ID,
      task_id: task_id,
      status: 'ok',
      started_at: started_at.iso8601,
      finished_at: finished_at.iso8601,
      exit_code: exit_code,
      timed_out: false,
      worktree: WORKTREE_DIR,
      stdout_preview: stdout_text.to_s[-2000, 2000],
      stderr_preview: stderr_text.to_s[-2000, 2000],
      result_path: result_path
    }
    File.write(receipt_path, JSON.pretty_generate(receipt))
  end

  def write_failure(task_id, started_at, stderr_text, stdout_text, exit_code, timed_out, finished_at = Time.now.utc)
    result_path = File.join(OUTBOX_DIR, "#{task_id}.error.md")
    receipt_path = File.join(OUTBOX_DIR, "#{task_id}.receipt.json")

    body = []
    body << "# codex53 error: #{task_id}"
    body << ''
    body << "- status: error"
    body << "- started_at: #{started_at.iso8601}"
    body << "- finished_at: #{finished_at.iso8601}"
    body << "- exit_code: #{exit_code}"
    body << "- timed_out: #{timed_out}"
    body << "- worktree: #{WORKTREE_DIR}"
    body << ''
    body << '## stderr'
    body << ''
    body << stderr_text.to_s.strip
    body << ''
    body << '## stdout'
    body << ''
    body << stdout_text.to_s.strip
    body << ''
    File.write(result_path, body.join("\n"))

    receipt = {
      service: SERVICE_ID,
      task_id: task_id,
      status: 'error',
      started_at: started_at.iso8601,
      finished_at: finished_at.iso8601,
      exit_code: exit_code,
      timed_out: timed_out,
      worktree: WORKTREE_DIR,
      stdout_preview: stdout_text.to_s[-2000, 2000],
      stderr_preview: stderr_text.to_s[-2000, 2000],
      result_path: result_path
    }
    File.write(receipt_path, JSON.pretty_generate(receipt))
  end

  def resolve_codex_bin
    preferred = ENV['CODEX53_CODEX_BIN']
    return preferred if preferred && File.executable?(preferred)

    from_path = which('codex')
    return from_path if from_path

    [
      '/usr/local/bin/codex',
      '/root/.nvm/versions/node/v22.20.0/bin/codex'
    ].find { |path| File.executable?(path) }
  end

  def which(command)
    ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).each do |dir|
      candidate = File.join(dir, command)
      return candidate if File.executable?(candidate) && !File.directory?(candidate)
    end
    nil
  end
end

Codex53Runner.new.run
