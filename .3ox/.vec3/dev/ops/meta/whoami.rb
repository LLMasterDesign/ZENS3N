#!/usr/bin/env ruby
# vec3 whoami command service
# - append structured changes into CHANGELOG.toml
# - rebuild WHOAMI.md from changelog + current state

require 'fileutils'
require 'optparse'
require 'time'
require 'json'
require 'toml-rb'

module MetaCmd
  class << self
    def run(argv)
      cmd = argv.shift
      case cmd
      when 'add'
        add_change(argv)
      when 'rebuild'
        rebuild(argv)
      when 'status'
        status(argv)
      else
        puts usage
        exit(cmd.nil? ? 0 : 1)
      end
    end

    def usage
      <<~TXT
        Usage:
          ruby .3ox/.vec3/dev/ops/meta/whoami.rb add --section <name> --event <id> --summary <text> [--actor <id>] [--status <ok|warn|error>] [--evidence <path>]...
          ruby .3ox/.vec3/dev/ops/meta/whoami.rb rebuild
          ruby .3ox/.vec3/dev/ops/meta/whoami.rb status
      TXT
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

    def meta_paths(start_path)
      base_root = find_base_root(start_path)
      raise "Could not resolve base root from: #{start_path}" if base_root.nil?

      meta_dir = File.join(base_root, '.3ox', '_meta')
      {
        base_root: base_root,
        meta_dir: meta_dir,
        changelog: File.join(meta_dir, 'CHANGELOG.toml'),
        whoami: File.join(meta_dir, 'WHOAMI.md'),
        tron_link: File.join(meta_dir, '_TRON.link'),
        merkle: File.join(meta_dir, 'merkle.root'),
        receipts: File.join(meta_dir, 'receipts'),
        write_policy: File.join(base_root, '.3ox', '(3)Rules', 'write_policy.toml')
      }
    end

    def now_utc
      Time.now.utc.iso8601(3)
    end

    def default_changelog
      {
        'meta' => {
          'id' => 'ZENS3N.BASE._meta.changelog',
          'version' => '1.0.0',
          'created_at' => now_utc,
          'updated_at' => now_utc
        },
        'sections' => {
          'identity' => 'Base identity and role',
          'runtime' => 'Runtime and service bindings',
          'policy' => 'Write/read policy changes',
          'workflow' => 'Lifecycle workflow and process changes',
          'receipts' => 'Receipt contract and integrity updates',
          'ops' => 'Operations tracking and management updates'
        },
        'entries' => []
      }
    end

    def load_changelog(path)
      return default_changelog unless File.file?(path)
      data = TomlRB.parse(File.read(path))
      data['meta'] ||= {}
      data['sections'] ||= default_changelog['sections']
      data['entries'] ||= []
      data
    rescue StandardError
      default_changelog
    end

    def write_changelog(path, data)
      data['meta'] ||= {}
      data['meta']['updated_at'] = now_utc
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, TomlRB.dump(data))
    end

    def add_change(argv)
      opts = {
        actor: 'meta.cmd',
        status: 'ok',
        evidence: [],
        notes: ''
      }

      parser = OptionParser.new do |o|
        o.on('--section SECTION') { |v| opts[:section] = v }
        o.on('--event EVENT') { |v| opts[:event] = v }
        o.on('--summary SUMMARY') { |v| opts[:summary] = v }
        o.on('--actor ACTOR') { |v| opts[:actor] = v }
        o.on('--status STATUS') { |v| opts[:status] = v }
        o.on('--evidence PATH') { |v| opts[:evidence] << v }
        o.on('--notes TEXT') { |v| opts[:notes] = v }
      end
      parser.parse!(argv)

      %i[section event summary].each do |k|
        raise "Missing required option --#{k}" if opts[k].nil? || opts[k].to_s.strip.empty?
      end

      p = meta_paths(Dir.pwd)
      changelog = load_changelog(p[:changelog])

      change = {
        'id' => "chg_#{Time.now.to_i}_#{rand(10000)}",
        'ts' => now_utc,
        'section' => opts[:section],
        'event' => opts[:event],
        'summary' => opts[:summary],
        'actor' => opts[:actor],
        'status' => opts[:status],
        'evidence' => opts[:evidence],
        'notes' => opts[:notes]
      }

      changelog['entries'] << change
      write_changelog(p[:changelog], changelog)
      build_whoami(p, changelog)

      puts JSON.pretty_generate({
        ok: true,
        change_id: change['id'],
        changelog: p[:changelog],
        whoami: p[:whoami]
      })
    rescue StandardError => e
      puts JSON.pretty_generate({ ok: false, error: e.message })
      exit 1
    end

    def rebuild(_argv)
      p = meta_paths(Dir.pwd)
      changelog = load_changelog(p[:changelog])
      write_changelog(p[:changelog], changelog)
      build_whoami(p, changelog)
      puts JSON.pretty_generate({ ok: true, changelog: p[:changelog], whoami: p[:whoami] })
    rescue StandardError => e
      puts JSON.pretty_generate({ ok: false, error: e.message })
      exit 1
    end

    def status(_argv)
      p = meta_paths(Dir.pwd)
      changelog = load_changelog(p[:changelog])
      entries = changelog['entries'] || []
      puts JSON.pretty_generate({
        ok: true,
        entries: entries.length,
        last_change: entries.last,
        changelog: p[:changelog],
        whoami: p[:whoami]
      })
    rescue StandardError => e
      puts JSON.pretty_generate({ ok: false, error: e.message })
      exit 1
    end

    def parse_tron_path(tron_link)
      return '' unless File.file?(tron_link)
      line = File.readlines(tron_link).find { |l| l.start_with?('TRON_PATH=') }
      return '' if line.nil?
      line.strip.split('=', 2).last.to_s
    end

    def load_write_policy(path)
      return {} unless File.file?(path)
      TomlRB.parse(File.read(path))
    rescue StandardError
      {}
    end

    def build_whoami(paths, changelog)
      entries = changelog['entries'] || []
      grouped = entries.group_by { |e| e['section'].to_s }

      receipts_count = Dir.exist?(paths[:receipts]) ? Dir.glob(File.join(paths[:receipts], '*.json')).size : 0
      merkle_root = File.file?(paths[:merkle]) ? File.read(paths[:merkle]).strip : ''
      tron_path = parse_tron_path(paths[:tron_link])
      write_policy = load_write_policy(paths[:write_policy])
      allowed = write_policy.dig('allowed_writes', 'paths') || []
      blocked = write_policy.dig('blocked_writes', 'paths') || []

      lines = []
      lines << '# ZENS3N.BASE WHOAMI'
      lines << ''
      lines << 'Single proof doc for current system behavior. Auto-generated from `_meta/CHANGELOG.toml` and live `_meta` state.'
      lines << ''

      lines << '## Identity'
      lines << '```toml'
      lines << %[generated_at = "#{now_utc}"]
      lines << %[base = "ZENS3N.BASE"]
      lines << %[meta_dir = ".3ox/_meta/"]
      lines << %[tron_path = "#{tron_path}"]
      lifecycle_service = File.join(tron_path.to_s, 'systemd', 'lifecycle', 'whoami.watch.service')
      lifecycle_cmd = File.join(tron_path.to_s, 'systemd', 'lifecycle', 'cmd', 'meta', 'whoami.watch')
      lines << %[lifecycle_service = "#{lifecycle_service}"]
      lines << %[lifecycle_cmd = "#{lifecycle_cmd}"]
      lines << %[lifecycle_service_present = #{File.file?(lifecycle_service)}]
      lines << %[lifecycle_cmd_present = #{File.file?(lifecycle_cmd)}]
      lines << %[naming_contract = ".3ox/_meta/NAMING.CONTRACT.toml"]
      lines << %[changelog = ".3ox/_meta/CHANGELOG.toml"]
      lines << %[whoami = ".3ox/_meta/WHOAMI.md"]
      lines << '```'
      lines << ':: ∎'
      lines << ''

      lines << '## Contract Snapshot'
      lines << '```toml'
      lines << %[receipts_canonical = ".3ox/_meta/receipts/"]
      lines << %[pulse_receipts_contract = ".3ox/(6)Pulse/receipts"]
      lines << %[ops_tracking = "!ZENS3N.OPS/receipts/lifecycle.receipts.jsonl"]
      lines << %[merkle_root_file = ".3ox/_meta/merkle.root"]
      lines << %[receipts_count = #{receipts_count}]
      lines << %[merkle_root = "#{merkle_root}"]
      lines << '```'
      lines << ':: ∎'
      lines << ''

      lines << '## Write Policy'
      lines << '```toml'
      allowed.each { |p| lines << %[allowed[] = "#{p}"] }
      blocked.each { |p| lines << %[blocked[] = "#{p}"] }
      lines << '```'
      lines << ':: ∎'
      lines << ''

      lines << '## Change Feed'
      lines << '```toml'
      %w[identity runtime policy workflow receipts ops].each do |section|
        section_entries = (grouped[section] || []).last(8)
        section_entries.each do |e|
          lines << '[[entry]]'
          lines << %[section = "#{e['section']}"]
          lines << %[id = "#{e['id']}"]
          lines << %[ts = "#{e['ts']}"]
          lines << %[event = "#{e['event']}"]
          lines << %[status = "#{e['status']}"]
          lines << %[summary = "#{e['summary'].to_s.gsub('"', '\"')}"]
          lines << %[actor = "#{e['actor']}"]
          (e['evidence'] || []).each { |ev| lines << %[evidence[] = "#{ev}"] }
        end
      end
      lines << '```'
      lines << ':: ∎'
      lines << ''

      FileUtils.mkdir_p(File.dirname(paths[:whoami]))
      File.write(paths[:whoami], lines.join("\n"))
    end
  end
end

MetaCmd.run(ARGV)
