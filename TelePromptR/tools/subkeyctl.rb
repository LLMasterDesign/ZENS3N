#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'securerandom'
require 'time'

def usage
  puts <<~USAGE
    Usage:
      ruby tools/subkeyctl.rb [--keys-dir PATH] create AGENT_ID
      ruby tools/subkeyctl.rb [--keys-dir PATH] rotate AGENT_ID
      ruby tools/subkeyctl.rb [--keys-dir PATH] revoke AGENT_ID
      ruby tools/subkeyctl.rb [--keys-dir PATH] list

    Notes:
      - AGENT_ID must match: [A-Za-z0-9_.-]+
      - Files are written as <agent_id>.tgsub.key (JSON)
      - Dir perms target 0700, file perms target 0600
  USAGE
end

def fail!(msg, code = 1)
  warn "subkeyctl: #{msg}"
  exit(code)
end

def parse_args(argv)
  args = argv.dup
  keys_dir = ENV['TPR_KEYS_DIR']

  if args[0] == '--keys-dir'
    keys_dir = args[1]
    args = args.drop(2)
  end

  keys_dir ||= File.expand_path('../_forge/runtime/keys', __dir__)
  [keys_dir, args]
end

def validate_agent_id!(agent_id)
  fail!('AGENT_ID is required') if agent_id.nil? || agent_id.strip.empty?
  return if agent_id.match?(/\A[A-Za-z0-9_.-]+\z/)

  fail!("invalid AGENT_ID '#{agent_id}' (allowed: A-Za-z0-9_.-)")
end

def ensure_secure_dir!(keys_dir)
  FileUtils.mkdir_p(keys_dir)
  File.chmod(0o700, keys_dir)
rescue StandardError
  # Best-effort on filesystems that do not support unix perms.
  nil
end

def key_path(keys_dir, agent_id)
  File.join(keys_dir, "#{agent_id}.tgsub.key")
end

def now_iso
  Time.now.utc.iso8601
end

def read_key_file(path)
  JSON.parse(File.read(path))
rescue StandardError
  nil
end

def masked_key(value)
  return 'none' if value.nil? || value.empty?
  return '*' * value.length if value.length <= 8

  "#{value[0, 4]}...#{value[-4, 4]}"
end

def write_key_file!(path, payload)
  tmp = "#{path}.tmp.#{$$}"
  File.write(tmp, JSON.pretty_generate(payload) + "\n")
  begin
    File.chmod(0o600, tmp)
  rescue StandardError
    nil
  end
  File.rename(tmp, path)
end

def create_or_rotate!(keys_dir, agent_id, rotate: false)
  validate_agent_id!(agent_id)
  ensure_secure_dir!(keys_dir)

  path = key_path(keys_dir, agent_id)
  previous = File.exist?(path) ? read_key_file(path) : nil

  if File.exist?(path) && !rotate
    fail!("key already exists for '#{agent_id}' (use rotate)")
  end

  key_value = SecureRandom.hex(32)
  payload = {
    'agent_id' => agent_id,
    'sub_key' => key_value,
    'status' => 'active',
    'issued_at' => previous&.fetch('issued_at', now_iso) || now_iso,
    'rotated_at' => rotate ? now_iso : nil,
    'last_seen' => previous&.fetch('last_seen', now_iso) || now_iso,
    'initialized' => previous&.fetch('initialized', false) || false,
    'agent_name' => previous&.fetch('agent_name', agent_id) || agent_id,
    'agent_type' => previous&.fetch('agent_type', 'agent') || 'agent',
    'pico_glyph' => previous&.fetch('pico_glyph', 'AI') || 'AI',
    'chat_id' => previous&.fetch('chat_id', nil),
    'default_topic' => previous&.fetch('default_topic', nil),
    'subscribed_topics' => previous&.fetch('subscribed_topics', []) || []
  }

  write_key_file!(path, payload)
  puts "agent=#{agent_id} file=#{path} key=#{key_value}"
end

def revoke!(keys_dir, agent_id)
  validate_agent_id!(agent_id)
  path = key_path(keys_dir, agent_id)

  unless File.exist?(path)
    fail!("no key found for '#{agent_id}'", 2)
  end

  File.delete(path)
  puts "revoked agent=#{agent_id} file=#{path}"
end

def list_keys(keys_dir)
  ensure_secure_dir!(keys_dir)
  files = Dir.glob(File.join(keys_dir, '*.tgsub.key')).sort

  if files.empty?
    puts 'no keys'
    return
  end

  files.each do |path|
    payload = read_key_file(path) || {}
    agent_id = File.basename(path, '.tgsub.key')
    status = payload['status'] || 'unknown'
    issued_at = payload['issued_at'] || 'unknown'
    last_seen = payload['last_seen'] || 'unknown'
    key_hint = masked_key(payload['sub_key'])

    puts [
      "agent=#{agent_id}",
      "status=#{status}",
      "issued_at=#{issued_at}",
      "last_seen=#{last_seen}",
      "sub_key=#{key_hint}",
      "file=#{path}"
    ].join(' ')
  end
end

keys_dir, args = parse_args(ARGV)
cmd = args[0]

if cmd.nil? || %w[help -h --help].include?(cmd)
  usage
  exit(0)
end

case cmd
when 'create'
  create_or_rotate!(keys_dir, args[1], rotate: false)
when 'rotate'
  create_or_rotate!(keys_dir, args[1], rotate: true)
when 'revoke'
  revoke!(keys_dir, args[1])
when 'list'
  list_keys(keys_dir)
else
  fail!("unknown command '#{cmd}'")
end
