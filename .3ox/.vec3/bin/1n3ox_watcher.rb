#!/usr/bin/env ruby
# 1n3ox watcher: move new drops into !WORKDESK/{Project}.Forge/1Ntake and emit wrkdsk files

require 'fileutils'
require 'json'
require 'time'

ROOT = '/root/!LAUNCHPAD'
SOURCE = File.join(ROOT, '!1N.3OX ZENS3N')
WORKDESK = File.join(ROOT, '!WORKDESK')
WRKDSK_1N3OX = File.join(ROOT, '.3ox', 'vec3', 'var', 'wrkdsk', '1n3ox')
WRKDSK_FORGE = File.join(ROOT, '.3ox', 'vec3', 'var', 'wrkdsk', 'forge')
LOG_PATH = File.join(ROOT, '.3ox', 'vec3', 'var', 'log', '1n3ox.log')
GENSING = '/mnt/r/!CORE.MEM/3OX.MASTER/!1N 3OX/gensing.rb'
POLICY_PATH = File.join(ROOT, '.3ox', 'Rules', '1n3ox.policy.json')

DEFAULT_PROJECT = 'INBOX' # fallback when no imprint found
BATCH_LIMIT = 500
MIN_AGE_SEC = 2
$dry_run = true
$policy = {}

FileUtils.mkdir_p(WRKDSK_1N3OX)
FileUtils.mkdir_p(WRKDSK_FORGE)
FileUtils.mkdir_p(File.dirname(LOG_PATH))

# Best-effort project extraction from imprint in lines 2-5
PROJECT_REGEXES = [
  /project\s*[:=]\s*["']?([^"'\n]+)/i,
  /imprint\s*[:=]\s*["']?([^"'\n]+)/i,
  /▛▞\/\/\s*([^:]+?)\s*::/ , # BEAM.OTP line
  /▛\/\/▞▞.*\/\/\s*([^▞]+)\s*▞▞/ # title line in pheno header
]

# Optional remap (if needed later)
PROJECT_MAP = {
  # 'SOME_ALIAS' => 'CanonicalProject'
}

$argv_file = nil
$run_once = false

def log_line(msg)
  line = "[#{Time.now.utc.iso8601}] #{msg}"
  File.open(LOG_PATH, 'a') { |f| f.puts(line) }
end

def load_policy
  return {} unless File.exist?(POLICY_PATH)
  JSON.parse(File.read(POLICY_PATH))
rescue => e
  log_line("policy load error: #{e.message}")
  {}
end

def policy_value(key, default)
  return default unless $policy.is_a?(Hash)
  $policy.fetch(key, default)
end

ARGV.each_with_index do |arg, idx|
  if arg == '--file'
    $argv_file = ARGV[idx + 1]
  elsif arg == '--once'
    $run_once = true
  elsif arg == '--dry-run'
    $dry_run = true
  elsif arg == '--live'
    $dry_run = false
  end
end

log_line("dry_run=#{$dry_run}")
$policy = load_policy
log_line("policy_loaded=#{$policy.any?}")

# Extract project name from a file's first ~8 lines
# Returns sanitized project name or nil

def extract_project(file_path)
  return nil unless File.file?(file_path)
  lines = []
  File.open(file_path, 'r') do |f|
    8.times do
      line = f.gets
      break unless line
      lines << line
    end
  end

  lines.each do |line|
    PROJECT_REGEXES.each do |re|
      if (m = line.match(re))
        raw = m[1].strip
        return sanitize_project(raw) unless raw.empty?
      end
    end
  end

  nil
rescue => e
  log_line("extract_project error for #{file_path}: #{e.message}")
  nil
end

def read_header_lines(file_path, count = 33)
  lines = []
  File.open(file_path, 'r') do |f|
    count.times do
      line = f.gets
      break unless line
      lines << line
    end
  end
  lines
rescue
  []
end

def imprint_score(lines)
  checks = [
    lines.any? { |l| l.start_with?('///▙▖') },
    lines.any? { |l| l.include?('▛//▞▞') },
    lines.any? { |l| l.start_with?('▛▞//') },
    lines.any? { |l| l.include?('//▞⋮⋮') },
    lines.any? { |l| l.include?('⫸') },
    lines.any? { |l| l.include?('PRISM :: KERNEL') }
  ]
  checks.count(true).to_f / checks.size.to_f
end

def topic_confidence(lines)
  tag_line = lines.find { |l| l.include?('[') && l.include?(']') }
  return 0.0 unless tag_line
  tags = tag_line.scan(/\[[^\]]+\]/)
  # Cap influence at 7 tags
  [tags.size.to_f / 7.0, 1.0].min
end

def goal_for(project)
  # Default: base goal
  policy_value('default_goal', 'zens3n.improve')
end

def next_action_for(imprint, topic)
  imprint_threshold = policy_value('imprint_threshold', 0.7)
  topic_threshold = policy_value('topic_threshold', 0.6)
  return 'gensing' if imprint < imprint_threshold
  return 'route' if topic >= topic_threshold
  'search'
end

def sanitize_project(raw)
  mapped = PROJECT_MAP[raw] || raw
  # Keep letters, digits, dot, dash, underscore; collapse others to dots
  cleaned = mapped.gsub(/[^A-Za-z0-9._-]+/, '.').gsub(/\.+/, '.').gsub(/^\.|\.$/, '')
  cleaned.empty? ? nil : cleaned
end

# Move file safely, return destination path

def move_to_workdesk(file_path, project)
  project_name = project || DEFAULT_PROJECT
  dest_dir = File.join(WORKDESK, "#{project_name}.Forge", '1Ntake')
  FileUtils.mkdir_p(dest_dir)

  base = File.basename(file_path)
  dest = File.join(dest_dir, base)

  if File.exist?(dest)
    ts = Time.now.utc.strftime('%Y%m%d_%H%M%S')
    dest = File.join(dest_dir, "#{File.basename(base, '.*')}_#{ts}#{File.extname(base)}")
  end

  if $dry_run
    return dest
  end

  FileUtils.mv(file_path, dest)
  dest
end

# Emit wrkdsk file

def emit_wrkdsk(kind:, src:, dest:, project:, imprint:, topic:)
  kind_str = kind.to_s
  ts = Time.now.utc.strftime('%Y%m%d_%H%M%S')
  base = File.basename(dest)
  id = "#{ts}_#{base.gsub(/[^A-Za-z0-9._-]/, '_')}"
  wrkdsk_dir = kind_str == 'forge' ? WRKDSK_FORGE : WRKDSK_1N3OX
  FileUtils.mkdir_p(wrkdsk_dir)

  low_conf = topic < policy_value('topic_threshold', 0.6)
  payload = {
    id: id,
    kind: kind_str,
    project: project,
    intent: kind_str == 'forge' ? 'forge' : 'ingest',
    goal: goal_for(project),
    next_action: next_action_for(imprint, topic),
    search_boost: low_conf,
    src: src,
    dest: dest,
    ts: Time.now.utc.iso8601,
    base: base,
    size: File.exist?(dest) ? (File.size?(dest) || 0) : 0,
    imprint_score: imprint,
    topic_confidence: topic,
    dry_run: $dry_run
  }

  File.write(File.join(wrkdsk_dir, "#{id}.json"), JSON.pretty_generate(payload))
end

# Run gensing if available

def run_gensing(path)
  return unless File.exist?(GENSING)
  system('ruby', GENSING, path)
end

# Process a single file

def process_file(path)
  return unless File.file?(path)
  return if (Time.now - File.mtime(path)) < MIN_AGE_SEC

  header = read_header_lines(path)
  imprint = imprint_score(header)
  topic = topic_confidence(header)
  project = extract_project(path)
  project = DEFAULT_PROJECT if project.nil? || project.empty?

  dest = move_to_workdesk(path, project)
  emit_wrkdsk(kind: '1n3ox', src: path, dest: dest, project: project, imprint: imprint, topic: topic)
  emit_wrkdsk(kind: 'forge', src: path, dest: dest, project: project, imprint: imprint, topic: topic)
  log_line("moved #{path} -> #{dest} (project=#{project})")

  # Gensing is a separate workflow; do not run here.
end

# Batch sweep for backlog

def sweep_batch
  entries = Dir.glob(File.join(SOURCE, '**', '*')).select { |p| File.file?(p) }
  entries.sort_by! { |p| File.mtime(p) rescue Time.at(0) }

  processed = 0
  entries.each do |path|
    break if processed >= BATCH_LIMIT
    begin
      process_file(path)
      processed += 1
    rescue => e
      log_line("process error: #{path}: #{e.message}")
    end
  end
end

if $argv_file
  process_file($argv_file)
  exit 0
end

if $run_once
  sweep_batch
  exit 0
end

# Default behavior: continuous sweep (legacy)
log_line("1n3ox watcher starting; source=#{SOURCE}")
loop do
  begin
    sweep_batch
  rescue => e
    log_line("loop error: #{e.message}")
  end
  sleep 2
end
