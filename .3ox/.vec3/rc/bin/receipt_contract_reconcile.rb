#!/usr/bin/env ruby
# Reconcile receipt contract bindings:
# - canonical store: .3ox/_meta/receipts/
# - pulse contract pointer: .3ox/(6)Pulse/receipts
# - ops pointer: !ZENS3N.OPS/receipts/receipts.canon

require 'fileutils'
require 'json'
require 'optparse'

opts = {
  adopt_legacy: false
}

OptionParser.new do |o|
  o.banner = 'Usage: receipt_contract_reconcile.rb [--adopt-legacy]'
  o.on('--adopt-legacy', 'Copy missing legacy pulse receipts into canonical _meta/receipts') do
    opts[:adopt_legacy] = true
  end
end.parse!

base_root = File.expand_path(ARGV[0] || Dir.pwd)
until base_root == '/'
  break if Dir.exist?(File.join(base_root, '.3ox')) && Dir.exist?(File.join(base_root, '!WORKDESK'))
  base_root = File.dirname(base_root)
end

if base_root == '/'
  puts JSON.pretty_generate({ error: 'Could not resolve base root' })
  exit 1
end

canonical = File.join(base_root, '.3ox', '_meta', 'receipts')
pulse_root = File.join(base_root, '.3ox', '(6)Pulse')
pulse_receipts = File.join(pulse_root, 'receipts')
ops_dir = File.join(base_root, '!ZENS3N.OPS', 'receipts')
ops_link = File.join(ops_dir, 'receipts.canon')
pulse_link = File.join(pulse_root, 'receipts.canon')

FileUtils.mkdir_p(canonical)
FileUtils.mkdir_p(ops_dir)
FileUtils.mkdir_p(pulse_root)

def ensure_link(link_path, target)
  if File.symlink?(link_path)
    current = File.realpath(link_path) rescue nil
    return :ok if current == File.realpath(target)
    FileUtils.rm_f(link_path)
  elsif File.exist?(link_path)
    return :skipped
  end
  FileUtils.ln_s(target, link_path)
  :created
rescue StandardError
  :error
end

ops_link_status = ensure_link(ops_link, canonical)
pulse_link_status = ensure_link(pulse_link, canonical)

legacy_adopted = 0
if opts[:adopt_legacy] && Dir.exist?(pulse_receipts) && !File.symlink?(pulse_receipts)
  Dir.glob(File.join(pulse_receipts, '*.json')).each do |src|
    dst = File.join(canonical, File.basename(src))
    next if File.exist?(dst)
    FileUtils.cp(src, dst)
    legacy_adopted += 1
  end
end

pulse_binding = 'unchanged'
if File.symlink?(pulse_receipts)
  pulse_binding = 'symlinked'
elsif Dir.exist?(pulse_receipts)
  entries = Dir.children(pulse_receipts).reject { |n| n.start_with?('.') }
  if entries.empty?
    FileUtils.rm_rf(pulse_receipts)
    FileUtils.ln_s(canonical, pulse_receipts)
    pulse_binding = 'symlinked'
  else
    pulse_binding = 'legacy_dir_kept'
  end
else
  FileUtils.ln_s(canonical, pulse_receipts)
  pulse_binding = 'symlinked'
end

contract_body = <<~TOML
  [receipts]
  canonical_store = ".3ox/_meta/receipts/"
  pulse_contract = ".3ox/(6)Pulse/receipts"
  ops_index = "!ZENS3N.OPS/receipts/lifecycle.receipts.jsonl"
  policy = "Pulse defines receipt contract; _meta owns receipt storage."
TOML
File.write(File.join(pulse_root, 'RECEIPTS.CONTRACT.toml'), contract_body)
File.write(File.join(ops_dir, 'RECEIPTS.CONTRACT.toml'), contract_body)

merkle_src = File.join(base_root, '.3ox', '.vec3', 'var', 'pulse', 'merkle.root')
merkle_dst = File.join(base_root, '.3ox', '_meta', 'merkle.root')
merkle_synced = false
if File.file?(merkle_src)
  raw = File.read(merkle_src).strip
  merkle = nil
  if (m = raw.match(/^\s*\{[\s\S]*^\s*\}/m))
    parsed = JSON.parse(m[0]) rescue nil
    merkle = parsed['root'].to_s if parsed.is_a?(Hash) && parsed['root']
  elsif raw.match?(/\Asha256:[0-9a-f]{64}\z/i)
    merkle = raw
  end
  if merkle && !merkle.empty?
    File.write(merkle_dst, merkle + "\n")
    merkle_synced = true
  end
end

puts JSON.pretty_generate({
  base_root: base_root,
  canonical_receipts: canonical,
  pulse_binding: pulse_binding,
  pulse_link_status: pulse_link_status,
  ops_link_status: ops_link_status,
  legacy_adopted: legacy_adopted,
  merkle_synced: merkle_synced
})
