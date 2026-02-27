#!/usr/bin/env ruby
# Live watcher for _meta proof artifacts (vec3 runtime).
# Rebuilds WHOAMI when _meta contract inputs change.

require 'digest'
require 'json'
require 'rbconfig'
require 'time'

module MetaWatchd
  class << self
    def run(argv)
      opts = parse_args(argv)
      base_root = find_base_root(Dir.pwd)
      raise "Could not resolve base root from #{Dir.pwd}" if base_root.nil?

      paths = {
        whoami_cmd: File.join(base_root, '.3ox', '.vec3', 'dev', 'ops', 'meta', 'whoami.rb'),
        changelog: File.join(base_root, '.3ox', '_meta', 'CHANGELOG.toml'),
        merkle: File.join(base_root, '.3ox', '_meta', 'merkle.root'),
        tron_link: File.join(base_root, '.3ox', '_meta', '_TRON.link'),
        write_policy: File.join(base_root, '.3ox', '(3)Rules', 'write_policy.toml'),
        receipts: File.join(base_root, '.3ox', '_meta', 'receipts')
      }

      raise "Missing whoami.rb: #{paths[:whoami_cmd]}" unless File.file?(paths[:whoami_cmd])

      interval = opts[:interval]
      last = nil
      loop_count = 0
      running = true
      trap('TERM') { running = false }
      trap('INT') { running = false }

      while running
        loop_count += 1
        now = Time.now.utc.iso8601(3)
        current = fingerprint(paths)
        should_rebuild = last.nil? || current != last

        if should_rebuild
          ok = rebuild(paths[:whoami_cmd], base_root)
          log({
            ts: now,
            event: 'meta.watchd.rebuild',
            ok: ok,
            loop: loop_count,
            reason: last.nil? ? 'boot' : 'fingerprint_change'
          })
          last = current
        end

        break if opts[:once]
        sleep interval
      end

      log({ ts: Time.now.utc.iso8601(3), event: 'meta.watchd.stop', ok: true, loop: loop_count })
    rescue StandardError => e
      log({ ts: Time.now.utc.iso8601(3), event: 'meta.watchd.error', ok: false, error: e.message })
      exit 1
    end

    def parse_args(argv)
      opts = { interval: 2.0, once: false }
      while (arg = argv.shift)
        case arg
        when '--interval'
          v = argv.shift
          raise 'Missing value for --interval' if v.nil?
          opts[:interval] = [v.to_f, 0.5].max
        when '--once'
          opts[:once] = true
        else
          raise "Unknown option: #{arg}"
        end
      end
      opts
    end

    def find_base_root(start_path)
      path = File.expand_path(start_path.to_s)
      loop do
        has_3ox = Dir.exist?(File.join(path, '.3ox'))
        has_meta = Dir.exist?(File.join(path, '.3ox', '_meta'))
        return path if has_3ox && has_meta
        parent = File.dirname(path)
        return nil if parent == path
        path = parent
      end
    end

    def fingerprint(paths)
      state = {}
      state['changelog'] = file_state(paths[:changelog])
      state['merkle'] = file_state(paths[:merkle])
      state['tron_link'] = file_state(paths[:tron_link])
      state['write_policy'] = file_state(paths[:write_policy])

      receipts = receipts_state(paths[:receipts])
      state['receipts_count'] = receipts[:count]
      state['receipts_latest'] = receipts[:latest]
      state['receipts_digest'] = receipts[:digest]

      Digest::SHA256.hexdigest(JSON.generate(state))
    end

    def file_state(path)
      return 'missing' unless File.file?(path)
      st = File.stat(path)
      "#{st.size}:#{st.mtime.to_f}"
    end

    def receipts_state(receipts_dir)
      return { count: 0, latest: 0.0, digest: 'none' } unless Dir.exist?(receipts_dir)

      files = Dir.glob(File.join(receipts_dir, '*.json'))
      latest = 0.0
      ids = []

      files.each do |f|
        st = File.stat(f)
        latest = st.mtime.to_f if st.mtime.to_f > latest
        ids << File.basename(f)
      end

      ids.sort!
      {
        count: files.size,
        latest: latest,
        digest: Digest::SHA256.hexdigest(ids.join("\n"))
      }
    end

    def rebuild(whoami_cmd, base_root)
      system(RbConfig.ruby, whoami_cmd, 'rebuild', chdir: base_root, out: File::NULL, err: File::NULL)
    rescue StandardError
      false
    end

    def log(payload)
      puts(JSON.generate(payload))
    end
  end
end

MetaWatchd.run(ARGV)
