#!/usr/bin/env ruby
# lifecycle_plan_event.rb
# Append plan event + update registry + refresh official tracker sections.

require 'json'
require 'time'
require 'optparse'

SCRIPT_DIR = File.expand_path(File.dirname(__FILE__))
BASE_ROOT = File.expand_path(File.join(SCRIPT_DIR, '..', '..', '..', '..'))
OPS_ROOT = File.join(BASE_ROOT, '!ZENS3N.OPS')
REGISTRY_PATH = File.join(OPS_ROOT, 'LIFECYCLE.PLAN.REGISTRY.json')
CHANGELOG_PATH = File.join(OPS_ROOT, 'LIFECYCLE.PLAN.CHANGELOG.jsonl')
TRACKER_PATH = File.join(OPS_ROOT, 'LIFECYCLE.PLAN.TRACKER.md')

opts = {
  status: 'active',
  note: '',
  from_step: 'unknown',
  to_step: 'unknown',
  event: 'plan.update'
}

parser = OptionParser.new do |o|
  o.banner = 'Usage: lifecycle_plan_event.rb --plan-id ID --tid TID --to-step Sxx [options]'
  o.on('--plan-id ID', String) { |v| opts[:plan_id] = v }
  o.on('--tid TID', String) { |v| opts[:tid] = v }
  o.on('--event EVENT', String) { |v| opts[:event] = v }
  o.on('--from-step STEP', String) { |v| opts[:from_step] = v }
  o.on('--to-step STEP', String) { |v| opts[:to_step] = v }
  o.on('--status STATUS', String) { |v| opts[:status] = v }
  o.on('--note NOTE', String) { |v| opts[:note] = v }
  o.on('--scratch PATH', String) { |v| opts[:scratch] = v }
end
parser.parse!

missing = %i[plan_id tid to_step].select { |k| opts[k].to_s.strip.empty? }
unless missing.empty?
  warn "Missing required options: #{missing.join(', ')}"
  warn parser.banner
  exit 1
end

now = Time.now.utc.iso8601(3)
default_scratch = ".3ox/.vec3/var/wrkdsk/#{opts[:tid]}/plan.md"

registry = if File.file?(REGISTRY_PATH)
  JSON.parse(File.read(REGISTRY_PATH))
else
  { 'updated_at_utc' => now, 'plans' => [] }
end

registry['plans'] ||= []
plan = registry['plans'].find { |p| p['plan_id'] == opts[:plan_id] }

if plan.nil?
  plan = {
    'plan_id' => opts[:plan_id],
    'tid' => opts[:tid],
    'status' => opts[:status],
    'active_step' => opts[:to_step],
    'started_utc' => now,
    'last_update_utc' => now,
    'scratch' => opts[:scratch].to_s.empty? ? default_scratch : opts[:scratch]
  }
  registry['plans'] << plan
else
  plan['tid'] = opts[:tid]
  plan['status'] = opts[:status]
  plan['active_step'] = opts[:to_step]
  plan['last_update_utc'] = now
  plan['scratch'] = opts[:scratch] unless opts[:scratch].to_s.empty?
end

registry['updated_at_utc'] = now
File.write(REGISTRY_PATH, JSON.pretty_generate(registry) + "\n")

event = {
  ts: now,
  plan_id: opts[:plan_id],
  tid: opts[:tid],
  event: opts[:event],
  from_step: opts[:from_step],
  to_step: opts[:to_step],
  status: opts[:status],
  note: opts[:note]
}
File.open(CHANGELOG_PATH, 'a') { |f| f.puts(JSON.generate(event)) }

def day(ts)
  return '' if ts.to_s.empty?
  ts[0, 10]
end

def build_registry_table(plans)
  rows = plans.sort_by { |p| p['last_update_utc'].to_s }.reverse
  out = []
  out << '| plan_id | tid | status | active_step | started | last_update | scratch |'
  out << '|---|---|---|---|---|---|---|'
  rows.each do |p|
    out << "| #{p['plan_id']} | #{p['tid']} | #{p['status']} | #{p['active_step']} | #{day(p['started_utc'])} | #{day(p['last_update_utc'])} | `#{p['scratch']}` |"
  end
  out.join("\n")
end

def build_recent_events(changelog_path, limit = 12)
  return "| ts | plan_id | event | step | status | note |\n|---|---|---|---|---|---|" unless File.file?(changelog_path)

  lines = File.readlines(changelog_path).map(&:strip).reject(&:empty?)
  parsed = lines.last(limit).map do |line|
    JSON.parse(line)
  rescue JSON::ParserError
    nil
  end.compact.reverse

  out = []
  out << '| ts | plan_id | event | step | status | note |'
  out << '|---|---|---|---|---|---|'
  parsed.each do |e|
    step = "#{e['from_step']} -> #{e['to_step']}"
    note = e['note'].to_s.gsub('|', '/')
    out << "| #{e['ts']} | #{e['plan_id']} | #{e['event']} | #{step} | #{e['status']} | #{note} |"
  end
  out.join("\n")
end

if File.file?(TRACKER_PATH)
  tracker = File.read(TRACKER_PATH)
  tracker = tracker.sub(/^last_updated_utc:.*$/, "last_updated_utc: #{now}")
  tracker = tracker.sub(/^- Plan: `.*`$/, "- Plan: `#{opts[:plan_id]}`")
  tracker = tracker.sub(/^- Active step: `.*`$/, "- Active step: `#{opts[:to_step]}`")

  registry_block = build_registry_table(registry['plans'])
  tracker = tracker.gsub(/<!-- PLAN_REGISTRY_START -->[\s\S]*<!-- PLAN_REGISTRY_END -->/, "<!-- PLAN_REGISTRY_START -->\n#{registry_block}\n<!-- PLAN_REGISTRY_END -->")

  events_block = build_recent_events(CHANGELOG_PATH)
  tracker = tracker.gsub(/<!-- RECENT_EVENTS_START -->[\s\S]*<!-- RECENT_EVENTS_END -->/, "<!-- RECENT_EVENTS_START -->\n#{events_block}\n<!-- RECENT_EVENTS_END -->")

  File.write(TRACKER_PATH, tracker)
end

puts JSON.pretty_generate({ ok: true, updated_at_utc: now, plan_id: opts[:plan_id], to_step: opts[:to_step] })
