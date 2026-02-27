#!/usr/bin/env ruby
# 3oxterm - CLI status + quick commands for vec3 runtime

require 'time'

ROOT = '/root/!LAUNCHPAD'
WRKDSK_1N3OX = File.join(ROOT, '.3ox', 'vec3', 'var', 'wrkdsk', '1n3ox')
WRKDSK_FORGE = File.join(ROOT, '.3ox', 'vec3', 'var', 'wrkdsk', 'forge')
LOG_1N3OX = File.join(ROOT, '.3ox', 'vec3', 'var', 'log', '1n3ox.log')
WORKDESK = File.join(ROOT, '!WORKDESK')

SERVICES = %w[vec3 1n3ox]

GLYPH = {
  banner: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂',
  meta:   '▛//▞▞ ⟦⎊⟧ ::',
  pheno:  '▛▞//',
  pico:   '//▞⋮⋮',
  seal:   ':: ∎',
  mark:   '⫸',
}

COLOR = {
  reset: "\e[0m",
  dim: "\e[2m",
  red: "\e[31m",
  green: "\e[32m",
  yellow: "\e[33m",
  cyan: "\e[36m",
  bold: "\e[1m"
}

MERKLE_PATHS = [
  File.join(ROOT, '.3ox', 'vec3', 'var', 'state', 'merkle.root'),
  File.join(ROOT, '.3ox', 'vec3', 'var', 'log', 'merkle.root'),
  File.join(ROOT, '.3ox', 'vec3', 'var', 'spool', 'merkle.root')
]

# ---------- helpers ----------

def run(cmd)
  out = `#{cmd} 2>/dev/null`
  out.strip
end


def section(title)
  puts "\n▛▞ #{COLOR[:cyan]}#{title}#{COLOR[:reset]}"
end

def box(title, lines, color: COLOR[:cyan])
  width = ([title.length] + lines.map(&:length)).max
  top = "+-#{title.ljust(width, '-')}--+"
  puts "#{color}#{top}#{COLOR[:reset]}"
  lines.each do |line|
    puts "#{color}| #{COLOR[:reset]}#{line.ljust(width)}#{color} |#{COLOR[:reset]}"
  end
  puts "#{color}+#{'-' * (width + 2)}+#{COLOR[:reset]}"
end


def count_files(path)
  return 0 unless Dir.exist?(path)
  Dir.children(path).count { |f| File.file?(File.join(path, f)) }
end


def list_recent_files(base, limit = 5)
  return [] unless Dir.exist?(base)
  files = Dir.glob(File.join(base, '**', '*')).select { |p| File.file?(p) }
  files.sort_by { |p| File.mtime(p) rescue Time.at(0) }.reverse.take(limit)
end


def tail_file(path, lines = 5)
  return [] unless File.exist?(path)
  data = []
  File.open(path, 'r') do |f|
    f.extend(File::Tail) if f.respond_to?(:extend)
  end
  # Simple tail
  File.readlines(path).last(lines)
rescue
  []
end

def header
  puts "#{GLYPH[:banner]} ::[0x3OXTERM]::"
  puts "#{GLYPH[:meta]} ⧗-26.?? // 3OXTERM ▞▞"
  puts "#{GLYPH[:pheno]} 3OXTERM :: ρ{Status}.φ{Signal}.τ{Guidance} ▹"
  puts "#{GLYPH[:pico]} [cli] [runtime] [status] [⊢ ⇨ ⟿ ▷]"
  puts "#{GLYPH[:mark]} 〔vec3.cli.context〕"
  puts GLYPH[:seal]
end

def quick_keys
  puts "\nCommands:"
  puts "  [1] status   [2] services   [3] logs   [4] 1ntake   [5] merkle   [6] tui   [7] help"
end

def help
  header
  section('Commands')
  puts "  status         Show full dashboard"
  puts "  tui            Live refresh (2s)"
  puts "  services       Show systemd status for vec3 + 1n3ox"
  puts "  1ntake         Show recent 1Ntake activity"
  puts "  intake         Show wrkdsk counts and recent jobs"
  puts "  logs           Tail 1n3ox log"
  puts "  workdesk       Show forge count + recent 1Ntake"
  puts "  merkle         Show merkle.root"
  puts "  help           Show this help"
  quick_keys
end

def dashboard
  header
  services
  workdesk
  logs
  one_take
  merkle
  intake
  quick_keys
end

def services
  lines = SERVICES.map do |svc|
    state = run("systemctl is-active #{svc}")
    since = run("systemctl show -p ActiveEnterTimestamp #{svc} | sed 's/ActiveEnterTimestamp=//'")
    label = state == 'active' ? "#{COLOR[:green]}ONLINE#{COLOR[:reset]}" : "#{COLOR[:red]}OFFLINE#{COLOR[:reset]}"
    "#{svc.ljust(8)}  #{label.ljust(16)}  #{COLOR[:dim]}#{since}#{COLOR[:reset]}"
  end
  box('Services', lines, color: COLOR[:cyan])
end

def intake
  lines = []
  lines << "wrkdsk/1n3ox: #{count_files(WRKDSK_1N3OX)} files"
  lines << "wrkdsk/forge : #{count_files(WRKDSK_FORGE)} files"

  recent_1n = list_recent_files(WRKDSK_1N3OX, 3)
  recent_fg = list_recent_files(WRKDSK_FORGE, 3)

  lines << "recent 1n3ox:"
  recent_1n.each { |p| lines << "  #{p.sub(ROOT + '/', '')}" }
  lines << "recent forge:"
  recent_fg.each { |p| lines << "  #{p.sub(ROOT + '/', '')}" }
  box('Intake', lines, color: COLOR[:cyan])
end

def logs
  lines = []
  if File.exist?(LOG_1N3OX)
    lines << "1n3ox.log (last 5):"
    tail_file(LOG_1N3OX, 5).each { |l| lines << "  #{l.strip}" }
    last = tail_file(LOG_1N3OX, 1).first
    lines << "last log: #{COLOR[:yellow]}#{last&.strip}#{COLOR[:reset]}" if last
  else
    lines << "1n3ox.log not found"
  end
  box('Logs', lines, color: COLOR[:cyan])
end

def workdesk
  forge_dirs = Dir.glob(File.join(WORKDESK, '*.Forge'))
  lines = []
  lines << "forge count: #{forge_dirs.size}"

  recent_take = list_recent_files(File.join(WORKDESK), 5).select { |p| p.include?('/1Ntake/') }
  lines << "recent 1Ntake:"
  recent_take.each { |p| lines << "  #{p.sub(ROOT + '/', '')}" }
  box('Workdesk', lines, color: COLOR[:cyan])
end

def one_take
  lines = []
  recent_take = list_recent_files(File.join(WORKDESK), 10).select { |p| p.include?('/1Ntake/') }
  if recent_take.empty?
    lines << "(none)"
  else
    recent_take.each { |p| lines << p.sub(ROOT + '/', '') }
  end
  box('1Ntake', lines, color: COLOR[:cyan])
end

def merkle
  lines = []
  path = MERKLE_PATHS.find { |p| File.exist?(p) }
  if path
    val = File.read(path).strip
    lines << "merkle.root: #{COLOR[:yellow]}#{val}#{COLOR[:reset]}"
    lines << "path: #{COLOR[:dim]}#{path}#{COLOR[:reset]}"
  else
    lines << "merkle.root: #{COLOR[:red]}not found#{COLOR[:reset]}"
  end
  box('Merkle', lines, color: COLOR[:cyan])
end

def watch
  loop do
    system('clear')
    dashboard
    sleep 2
  end
end

cmd = ARGV[0]
case cmd
when nil, 'status'
  dashboard
when 'services'
  header
  services
when 'intake'
  header
  intake
when '1ntake'
  header
  one_take
when 'logs'
  header
  logs
when 'workdesk'
  header
  workdesk
when 'merkle'
  header
  merkle
when 'watch', 'tui'
  watch
else
  help
end
