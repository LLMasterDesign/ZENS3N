#!/usr/bin/env ruby
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.180 // 3OX.STARTUP :: Session Initialization ▞▞
# ▛▞// STARTUP.RB :: ρ{Command}.φ{Generate}.τ{Session} ▹
# //▞⋮⋮ ⟦🚀⟧ :: [startup] [gamertag] [tid] [persona] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.startup.context〕

require 'time'
require 'date'
require 'json'

PHENO_BORDER = '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::'
PHENO_META_START = '▛//▞▞ ⟦⎊⟧ ::'
PHENO_ID = '▛▞//'
PICO_CHAIN = '//▞⋮⋮'
IGNITION = '⫸'
CLOSE = ':: ∎'
SEAL = ':: 𝜵'

# Get Sirius time (⧗-YY.SSS format) from Sirius reset day (2025-08-08).
def sirius_time
  reset_date = Date.new(2025, 8, 8)
  today = Date.today
  days_since = [(today - reset_date).to_i, 0].max
  year = 26
  day = days_since.to_s.rjust(3, '0')
  { year: year.to_s, day: day, full: "⧗-#{year}.#{day}" }
end

# Generate gamertag
def generate_gamertag
  gamertags = [
    'ShadowVex', 'NeonPulse', 'QuantumShift', 'VoidRider', 'NexusFlow',
    'CipherWave', 'DataDrift', 'CodeStorm', 'BinaryPulse', 'MatrixCore',
    'PhantomByte', 'DigitalFlux', 'TechVortex', 'CyberNexus', 'LogicForge',
    'StreamEdge', 'CloudRider', 'DataStream', 'CodeForge', 'NexusPrime'
  ]
  gamertags.sample
end

def find_id_file(base_dir)
  id_files = [
    File.join(base_dir, 'ZENS3N.BASE.ID'),
    File.join(base_dir, '.3ox', 'ZENS3N.BASE.ID'),
    File.join(base_dir, '.ID')
  ]
  id_files.find { |f| File.exist?(f) }
end

# Load base letter from ID file.
def load_base_letter(base_dir)
  id_file = find_id_file(base_dir)
  return 'z' unless id_file

  content = File.read(id_file)

  baseid_match = content.match(/baseid\s*=\s*["']([^"']+)["']/i)
  return baseid_match[1][0].downcase if baseid_match

  meta_id_match = content.match(/\[meta\].*?id\s*=\s*["']([^"']+)["']/m)
  return meta_id_match[1][0].downcase if meta_id_match

  cube_match = content.match(/cube_id\s*=\s*["']([^"']+)["']/)
  return cube_match[1][0].downcase if cube_match

  name_match = content.match(/name\s*=\s*["']([^"']+)["']/)
  return name_match[1][0].downcase if name_match

  'z'
rescue StandardError
  'z'
end

def load_cube_id(base_dir)
  id_file = find_id_file(base_dir)
  return 'Z3N01' unless id_file

  content = File.read(id_file)
  cube_match = content.match(/cube_id\s*=\s*["']([^"']+)["']/)
  cube_match ? cube_match[1] : 'Z3N01'
rescue StandardError
  'Z3N01'
end

def normalize_base_name(raw)
  return nil unless raw

  candidate = raw.to_s.strip
  return nil if candidate.empty?

  candidate = candidate.sub(/\.base\z/i, '')
  candidate = candidate.split('.').first if candidate.include?('.')
  candidate = candidate.gsub(/\s+/, '')
  candidate = candidate.gsub(/\A[^A-Za-z0-9]+/, '')

  candidate.empty? ? nil : candidate
end

def load_base_name(base_dir)
  id_file = find_id_file(base_dir)
  if id_file
    content = File.read(id_file)
    id_candidates = [
      content.match(/baseid\s*=\s*["']([^"']+)["']/i)&.captures&.first,
      content.match(/\[meta\].*?id\s*=\s*["']([^"']+)["']/m)&.captures&.first,
      content.match(/\[identity\].*?canonical_name\s*=\s*["']([^"']+)["']/m)&.captures&.first,
      content.match(/\[identity\].*?name\s*=\s*["']([^"']+)["']/m)&.captures&.first,
      content.match(/name\s*=\s*["']([^"']+)["']/)&.captures&.first
    ]
    id_candidates.each do |value|
      normalized = normalize_base_name(value)
      return normalized if normalized
    end
  end

  whoami_path = File.join(base_dir, '.3ox', '_meta', 'WHOAMI.md')
  if File.exist?(whoami_path)
    whoami = File.read(whoami_path)
    whoami_base = whoami.match(/^\s*base\s*=\s*["']([^"']+)["']\s*$/)&.captures&.first
    normalized = normalize_base_name(whoami_base)
    return normalized if normalized
  end

  sparkfile_path = File.join(base_dir, '.3ox', '(1)Spark', 'Zens3n.sparkfile.md')
  if File.exist?(sparkfile_path)
    spark = File.read(sparkfile_path)
    spark_base = spark.match(/^\s*base:\s*["']([^"']+)["']\s*$/)&.captures&.first
    normalized = normalize_base_name(spark_base)
    return normalized if normalized
  end

  normalize_base_name(File.basename(base_dir)) || 'BASE'
rescue StandardError
  normalize_base_name(File.basename(base_dir)) || 'BASE'
end

# Generate TID (ca:SSB##)
# SS = Sirius day last 2 digits
# B = Base location letter
# ## = Random 2 digits
def generate_tid(sirius_day, base_letter)
  ss = sirius_day[-2..-1]
  random = rand(10..99).to_s
  "ca:#{ss}#{base_letter}#{random}"
end

# Load persona from brains.rs [persona] section without external TOML gems.
def load_persona(brains_path)
  return nil unless File.exist?(brains_path)

  content = File.read(brains_path)
  section_match = content.match(/\[persona\](.*?)(?=^\[|\z)/m)
  return nil unless section_match

  section = section_match[1]
  parsed = {}
  section.scan(/^\s*([A-Za-z0-9_.-]+)\s*=\s*["']([^"']+)["']\s*$/).each do |key, value|
    parsed[key] = value
  end
  parsed.empty? ? nil : parsed
rescue StandardError
  nil
end

def startup_process_for(command)
  case command.to_s.downcase
  when 'codex'
    'read.sparkfile ∙ read.codex.agents ∙ run.startup ∙ emit.session.identity'
  when 'cursor'
    'read.cursor.rules ∙ read.sparkfile ∙ run.startup ∙ emit.session.identity'
  else
    'read.brains.profile ∙ run.startup ∙ emit.session.identity'
  end
end

def pheno_fill(payload)
  command = payload[:command].to_s.downcase
  rho = case command
        when 'codex' then 'startup.codex'
        when 'cursor' then 'startup.cursor'
        else 'startup.brains'
        end
  phi = case command
        when 'codex' then 'spark→agents→startup'
        when 'cursor' then 'rules→spark→startup'
        else 'brains→startup'
        end
  tau = "tid=#{payload[:tid]} ∙ tag=#{payload[:gamertag]}"
  { rho: rho, phi: phi, tau: tau }
end

def pheno_glyph(command)
  command.to_s.downcase == 'codex' ? '▛ ▞ //' : PHENO_ID
end

def print_startup_banner(sirius_full, command)
  puts PHENO_BORDER
  puts "#{PHENO_META_START} #{sirius_full} // 3OX.STARTUP :: #{command.to_s.upcase} ▞▞"
  puts "#{pheno_glyph(command)} STARTUP.RB :: ρ{Command}.φ{Generate}.τ{Session} ▹"
  puts "#{PICO_CHAIN} ⟦🚀⟧ :: [startup] [gamertag] [tid] [persona] [⊢ ⇨ ⟿ ▷]"
  puts "#{IGNITION} 〔vec3.startup.context〕"
  puts
end

def print_loading_bar(command)
  puts "#{pheno_glyph(command)} LOADING :: [██████████] 100%"
  puts
end

def output_payload(payload, json: false)
  if json
    puts JSON.pretty_generate(payload)
    return
  end

  codex_mode = payload[:command].to_s.downcase == 'codex'
  pheno = pheno_glyph(payload[:command])
  fill = pheno_fill(payload)

  unless codex_mode
    print_startup_banner(payload[:sirius], payload[:command])
    print_loading_bar(payload[:command])
  end
  puts "#{pheno} RESPONDER.OUTPUT :: ρ{#{fill[:rho]}}.φ{#{fill[:phi]}}.τ{#{fill[:tau]}} ▹"
  puts "GAMERTAG: #{payload[:gamertag]}"
  puts "TID: #{payload[:tid]}"
  puts "CUBE_ID: #{payload[:cube_id]}"
  puts "PERSONA: #{payload[:persona]}"
  puts "SIRIUS: #{payload[:sirius]}"
  puts "BASE: #{payload[:base]}"
  puts CLOSE
  puts

  if codex_mode
    puts "▛ ▞ // #{payload[:gamertag]} ⫎  ▸"
    puts "startup.behavior.aligned{pheno.standard ∙ chain.mutable ∙ tid=#{payload[:tid]}}"
  else
    puts "#{PHENO_ID} #{payload[:gamertag]} ⫎ ▸"
    puts "startup.sequence.ready{#{payload[:command]}}"
  end
  puts "[#{payload[:tid]}] #{SEAL}"
end

# Main execution
def main(command = 'brains', json: false)
  script_dir = File.expand_path(File.dirname(__FILE__))
  base_dir = File.expand_path('../../..', script_dir)
  brains_path = File.join(base_dir, '.3ox', '(2)Brains', 'brains.rs')

  base_letter = load_base_letter(base_dir)
  sirius = sirius_time
  gamertag = generate_gamertag
  tid = generate_tid(sirius[:day], base_letter)
  persona = load_persona(brains_path)
  persona_name = persona ? persona['name'] || 'DEFAULT' : 'DEFAULT'
  cube_id = load_cube_id(base_dir)
  base_name = load_base_name(base_dir)

  payload = {
    command: command,
    gamertag: gamertag,
    tid: tid,
    cube_id: cube_id,
    persona: persona_name,
    sirius: sirius[:full],
    base: base_name
  }

  output_payload(payload, json: json)
  payload
end

if __FILE__ == $0
  command = ARGV.find { |arg| !arg.start_with?('--') } || 'brains'
  main(command, json: ARGV.include?('--json'))
end

# :: ∎
