#!/usr/bin/env ruby
# Create/inspect staging batch folders under .3ox/.vec3/var/wrkdsk/TID.<id>/

require 'fileutils'
require 'json'
require 'rbconfig'
require 'time'

module TidBatch
  class << self
    def run(argv)
      action = argv.shift || 'open'
      case action
      when 'open'
        open_batch(argv)
      when 'status'
        status_batch(argv)
      else
        puts JSON.pretty_generate({ ok: false, error: "Unknown action: #{action}" })
        exit 1
      end
    end

    def find_base_root(start_path)
      path = File.expand_path(start_path.to_s)
      loop do
        return path if Dir.exist?(File.join(path, '.3ox'))
        parent = File.dirname(path)
        return nil if parent == path
        path = parent
      end
    end

    def parse_tid(argv)
      raw = argv.shift
      raise 'Usage: tid.batch open <TID>' if raw.nil? || raw.strip.empty?
      normalize_tid(raw)
    end

    def normalize_tid(raw)
      tid = raw.to_s.strip
      tid = tid.sub(/\ATID\./i, '')
      tid
    end

    def open_batch(argv)
      tid = parse_tid(argv)
      base = find_base_root(Dir.pwd)
      raise "Could not resolve base root from #{Dir.pwd}" if base.nil?

      root = File.join(base, '.3ox', '.vec3', 'var', 'wrkdsk')
      batch = File.join(root, "TID.#{tid}")
      %w[inbox work outbox receipts].each { |d| FileUtils.mkdir_p(File.join(batch, d)) }

      meta = File.join(batch, '.batch.toml')
      File.write(meta, <<~TOML)
        [batch]
        tid = "#{tid}"
        created_at = "#{Time.now.utc.iso8601(3)}"
        root = ".3ox/.vec3/var/wrkdsk/TID.#{tid}/"
        state = "open"
      TOML

      append_ledger(root, tid, batch)
      write_meta_change(base, tid, batch)

      puts JSON.pretty_generate({
        ok: true,
        tid: tid,
        batch_root: batch,
        meta: meta
      })
    rescue StandardError => e
      puts JSON.pretty_generate({ ok: false, error: e.message })
      exit 1
    end

    def status_batch(argv)
      tid = parse_tid(argv)
      base = find_base_root(Dir.pwd)
      raise "Could not resolve base root from #{Dir.pwd}" if base.nil?

      batch = File.join(base, '.3ox', '.vec3', 'var', 'wrkdsk', "TID.#{tid}")
      puts JSON.pretty_generate({
        ok: true,
        tid: tid,
        exists: Dir.exist?(batch),
        batch_root: batch
      })
    rescue StandardError => e
      puts JSON.pretty_generate({ ok: false, error: e.message })
      exit 1
    end

    def write_meta_change(base, tid, batch)
      whoami_cmd = File.join(base, '.3ox', '.vec3', 'dev', 'ops', 'meta', 'whoami.rb')
      return unless File.file?(whoami_cmd)
      system(
        RbConfig.ruby, whoami_cmd, 'add',
        '--section', 'workflow',
        '--event', 'staging.tid_open',
        '--summary', "Opened wrkdsk batch TID.#{tid}",
        '--actor', 'meta.cmd',
        '--status', 'ok',
        '--evidence', relative_to_base(base, batch),
        chdir: base,
        out: File::NULL,
        err: File::NULL
      )
    rescue StandardError
      nil
    end

    def relative_to_base(base, path)
      path.sub(%r{\A#{Regexp.escape(base)}/?}, '')
    end

    def append_ledger(root, tid, batch)
      ledger = File.join(root, 'ledger.jsonl')
      entry = {
        ts: Time.now.utc.iso8601(3),
        event: 'wrkdsk.batch.open',
        tid: "TID.#{tid}",
        batch_root: batch
      }
      File.open(ledger, 'a') { |f| f.puts(JSON.generate(entry)) }
    rescue StandardError
      nil
    end
  end
end

TidBatch.run(ARGV)
