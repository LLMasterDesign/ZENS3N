#!/usr/bin/env ruby
# ops.indexer.rb — Build OPS Index/live.json from INDEX.md and Logbook/STRUCTURE.LIST.md
# Script lives in vec3/bin; OPS holds only commands and instructions. Output: Index/live.json under CMD.OPS.
# Usage: ruby ops.indexer.rb [path/to/!CMD.OPS]
#   Or set CMD_OPS_ROOT. Writes Index/live.json under that OPS root.

require 'json'
require 'fileutils'
require 'time'

OPS_INDEX = 'Index/INDEX.md'
STRUCTURE_LIST = 'Logbook/STRUCTURE.LIST.md'

def ops_root
  return ENV['CMD_OPS_ROOT'] if ENV['CMD_OPS_ROOT'] && File.directory?(ENV['CMD_OPS_ROOT'])
  if ARGV[0] && !ARGV[0].start_with?('--') && File.directory?(ARGV[0])
    return File.expand_path(ARGV[0])
  end
  # From vec3/bin: vec3 -> .3ox -> workspace
  vec3_bin = File.expand_path(__dir__)
  workspace = File.expand_path(File.join(vec3_bin, '../../..'))
  [
    '!1N.3OX ZENS3N/!CMD.CENTER/!CMD.OPS',
    '!CMD.CENTER/!CMD.OPS'
  ].each do |rel|
    candidate = File.join(workspace, rel)
    return candidate if File.directory?(candidate)
  end
  nil
end

def read(path)
  full = File.join(ops_root, path)
  return '' unless File.file?(full)
  File.read(full, encoding: 'UTF-8')
end

TABLE_HEADER_WORDS = %w[Where Path Use Area Contents What Location].freeze

def parse_table(lines)
  rows = []
  in_table = false
  lines.each do |line|
    if line.strip.start_with?('|') && line.include?('|')
      in_table = true
      raw = line.split('|').map(&:strip).reject(&:empty?)
      next if raw.size < 2
      next if raw.all? { |c| c.gsub(/-/, '').empty? }
      next if raw[0] && TABLE_HEADER_WORDS.include?(raw[0].strip)
      rows << raw
    elsif in_table
      break
    end
  end
  rows
end

def strip_bold(s)
  s.to_s.gsub(/\*\*(.+?)\*\*/, '\1').strip
end

def tables_from_index(content)
  out = { entry_points: [], ops_structure: [], outside_ops: [] }
  lines = content.each_line.to_a
  %i[entry_points ops_structure outside_ops].each do |sec|
    i = lines.index { |l| l.include?(sec.to_s.upcase.tr('_', ' ')) }
    next unless i
    tbl = parse_table(lines[i..-1])
    out[sec] = tbl.map { |r| { label: strip_bold(r[0]), path: r[1], use: r[2] } }
    out[sec].each { |h| h.delete(:use) if h[:use].to_s.empty? }
  end
  out
end

def where_to_find_from_structure(content)
  lines = content.each_line.to_a
  start = lines.index { |l| l.include?('## Where to Find') }
  return [] unless start
  tbl = parse_table(lines[start..-1])
  tbl.map { |r| { what: strip_bold(r[0]), location: r[1] } }
end

def build_live
  index_content = read(OPS_INDEX)
  structure_content = read(STRUCTURE_LIST)
  from_index = tables_from_index(index_content)
  where_to_find = where_to_find_from_structure(structure_content)
  {
    generated_at: Time.now.utc.iso8601,
    ops_root: ops_root,
    entry_points: from_index[:entry_points],
    ops_structure: from_index[:ops_structure],
    outside_ops: from_index[:outside_ops],
    where_to_find: where_to_find
  }
end

def main
  root = ops_root
  unless root
    warn "ops.indexer: CMD.OPS root not found. Set CMD_OPS_ROOT or pass path (e.g. ruby ops.indexer.rb '/path/to/!CMD.OPS')."
    exit 1
  end
  out_path = ARGV.include?('--output') ? ARGV[ARGV.index('--output') + 1] : File.join(root, 'Index', 'live.json')
  live = build_live
  dir = File.dirname(out_path)
  FileUtils.mkdir_p(dir) if dir && !File.directory?(dir)
  File.write(out_path, JSON.pretty_generate(live), encoding: 'UTF-8')
  puts "Index/live.json written (#{live[:entry_points].size} entry points, #{live[:where_to_find].size} where_to_find)"
end

main
