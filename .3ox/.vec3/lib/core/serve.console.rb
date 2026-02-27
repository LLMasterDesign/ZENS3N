# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xE355]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // SERVE.CONSOLE.RB ▞▞
# ▛▞// SERVE.CONSOLE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [telegram] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.serve.console.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for SERVE.CONSOLE.RB
# ```

# 


# 


# ▛//▞ PRISM :: KERNEL
# P:: identity.matrix ∙ context.anchor ∙ execution.flow
# R:: load.context ∙ execute.logic ∙ emit.result
# I:: intent.target={system.stability ∙ function.execution}
# S:: init → process → terminate
# M:: std.io ∙ file.sys ∙ mem.state
# :: ∎

#!/usr/bin/env ruby
# frozen_string_literal: true

module Z3N
  SPEC = {
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // SERVE.CONSOLE ▞▞',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    PiCO: '//▞⋮⋮ [🔧] ≔ [serve_console] [system] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    CTX: '⫸ 〔runtime.script.context〕'
  }
end
#```elixir
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2025.12.31
##/// Last Updated: 2025.12.31 | Trace.ID: serve.console.v1.0
##/// Purpose: !/usr/bin/env ruby
##///          (Add second line of purpose here)
##///          (Add third line of purpose here)
#```
#
#▛//▞ TOOLSET ::
#(Add toolset commands here)
#/command1 = description1
#/command2 = description2

#
# Simple web server to serve the 3OX Job Console UI
# Binds to 0.0.0.0:8080 for network access (Telegram sharing)
# Console connects to REST API at 127.0.0.1:7777
#
# Usage: ruby serve.console.rb
# Access: http://localhost:8080 or http://YOUR_IP:8080

require 'webrick'
require 'pathname'

# Determine paths
SCRIPT_DIR = Pathname.new(__FILE__).dirname.realpath
VEC3_ROOT = SCRIPT_DIR.parent
CONSOLE_PATH = VEC3_ROOT / 'share' / 'ui' / 'console.html'

unless CONSOLE_PATH.exist?
  puts "❌ ERROR: Console not found at #{CONSOLE_PATH}"
  exit 1
end

puts "▛▞ 3OX Console Server"
puts "━" * 50
puts "Console: #{CONSOLE_PATH}"
puts "Binding: 0.0.0.0:8080"
puts "API:     127.0.0.1:7777"
puts "━" * 50
puts ""
puts "Access locally:  http://localhost:8080"
puts "Share to device: http://YOUR_IP_HERE:8080"
puts ""
puts "Press Ctrl+C to stop"
puts ""

server = WEBrick::HTTPServer.new(
  Port: 8080,
  BindAddress: '0.0.0.0',  # Allow network access
  DocumentRoot: (VEC3_ROOT / 'share' / 'ui').to_s,
  DirectoryIndex: ['console.html'],
  Logger: WEBrick::Log.new($stdout, WEBrick::Log::INFO),
  AccessLog: [[
    $stdout,
    WEBrick::AccessLog::COMMON_LOG_FORMAT
  ]]
)

trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }

server.start

# :: ∎