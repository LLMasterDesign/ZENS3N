#!/usr/bin/env ruby
# start.d/brains.rb - Default startup flow for `3ox start` (main brains only).

RC_DIR = File.realpath(File.dirname(__FILE__))
VEC3_ROOT = File.realpath(File.join(RC_DIR, '../..'))
WORKSPACE_ROOT = File.realpath(File.join(VEC3_ROOT, '../..'))
STARTUP_SCRIPT_PATH = File.join(WORKSPACE_ROOT, '.3ox', '.vec3', 'rc', 'startup.rb')

unless File.exist?(STARTUP_SCRIPT_PATH)
  puts "Missing startup script: #{STARTUP_SCRIPT_PATH}"
  exit 1
end

ok = system('ruby', STARTUP_SCRIPT_PATH, 'brains')
exit(1) unless ok

# :: ∎
