#!/usr/bin/env ruby
# start.d/codex.rb - Codex startup sequence entrypoint for `3ox start codex`.

RC_DIR = File.realpath(File.dirname(__FILE__))
VEC3_ROOT = File.realpath(File.join(RC_DIR, '../..'))
WORKSPACE_ROOT = File.realpath(File.join(VEC3_ROOT, '../..'))

SPARKFILE_PATH = File.join(WORKSPACE_ROOT, '.3ox', '(1)Spark', 'Zens3n.sparkfile.md')
STARTUP_DOC_PATH = File.join(WORKSPACE_ROOT, '.3ox', '(1)Spark', 'docs', 'CODEX.STARTUP.SEQUENCE.md')
AGENTS_DOC_PATH = begin
  candidates = [
    File.join(WORKSPACE_ROOT, '.3ox', '(1)Spark', 'codex', 'AGENTS.md'),
    File.join(WORKSPACE_ROOT, '.3ox', '(1)Spark', 'codex', 'agents.md')
  ]
  candidates.find { |p| File.exist?(p) } || candidates.first
end
STARTUP_SCRIPT_PATH = File.join(WORKSPACE_ROOT, '.3ox', '.vec3', 'rc', 'startup.rb')

def ensure_readable!(path)
  unless File.exist?(path)
    warn "Missing startup artifact: #{path}"
    exit 1
  end

  File.read(path)
rescue StandardError => e
  warn "Unreadable startup artifact: #{path} (#{e.class})"
  exit 1
end

ensure_readable!(SPARKFILE_PATH)
ensure_readable!(AGENTS_DOC_PATH)
ensure_readable!(STARTUP_DOC_PATH)
ensure_readable!(STARTUP_SCRIPT_PATH)

ok = system('ruby', STARTUP_SCRIPT_PATH, 'codex')
exit(1) unless ok

# :: ∎
