#!/usr/bin/env ruby
# tool.scanner.rb :: Discover vec3 runtime tools and build tools.yml registry.

require 'yaml'
require 'digest'
require 'optparse'
require 'fileutils'
require 'time'

module ToolScanner
  SCANNER_VERSION = '2.0.0'

  class << self
    def run(argv)
      opts = parse_args(argv)
      base = find_base_root(Dir.pwd)
      raise "Could not resolve base root from #{Dir.pwd}" if base.nil?

      vec3_root = File.join(base, '.3ox', '.vec3')
      roots = scan_roots(vec3_root)
      discovered = discover_tools(base, roots)

      registry_path = File.expand_path(opts[:registry], base)
      write_registry(registry_path, roots, discovered)

      puts({
        ok: true,
        scanner_version: SCANNER_VERSION,
        registry: registry_path,
        discovered: discovered.length,
        roots: roots.map { |r| relative(base, r[:path]) }
      }.to_yaml)
    rescue StandardError => e
      warn({ ok: false, error: e.message }.to_yaml)
      exit 1
    end

    def parse_args(argv)
      opts = {
        registry: '.3ox/(4)Toolkit/Tools/tools.yml'
      }
      OptionParser.new do |o|
        o.banner = 'Usage: tool.scanner.rb [--registry PATH]'
        o.on('--registry PATH', 'Registry output path (default: .3ox/(4)Toolkit/Tools/tools.yml)') { |v| opts[:registry] = v }
      end.parse!(argv)
      opts
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

    def scan_roots(vec3_root)
      [
        { kind: 'ops', path: File.join(vec3_root, 'dev', 'ops') },
        { kind: 'io', path: File.join(vec3_root, 'dev', 'io') },
        { kind: 'cli', path: File.join(vec3_root, 'rc', 'bin') },
        { kind: 'service', path: File.join(vec3_root, 'rc', 'services') }
      ]
    end

    def discover_tools(base, roots)
      results = []
      roots.each do |root|
        next unless Dir.exist?(root[:path])
        Dir.glob(File.join(root[:path], '**', '*')).sort.each do |f|
          next unless File.file?(f)
          next if File.basename(f).start_with?('.')
          next if File.basename(f).match?(/\.backup\./)
          next if File.basename(f).match?(/\.bak(\.|$)/)
          next unless tool_file?(f)
          next if f.include?('/lib/deps/')
          next if f.include?('/_build/')
          next if f.include?('/_archive/')

          entry = build_entry(base, f, root[:kind])
          results << entry if entry
        end
      end
      dedupe(results)
    end

    def tool_file?(path)
      ext = File.extname(path)
      return true if %w[.rb .sh .ex .exs .py .rc].include?(ext)
      return false unless ext.empty? && File.executable?(path)
      first = File.foreach(path).first.to_s
      first.start_with?('#!')
    rescue StandardError
      false
    end

    def build_entry(base, path, kind)
      content = File.read(path, mode: 'r:bom|utf-8')
      first = content.lines.first.to_s.strip
      summary = extract_summary(content)

      {
        'id' => tool_id(path),
        'kind' => kind,
        'path' => relative(base, path),
        'ext' => File.extname(path).sub('.', ''),
        'executable' => File.executable?(path),
        'shebang' => first.start_with?('#!') ? first : nil,
        'summary' => summary,
        'auto_discovered' => true,
        'hash' => Digest::SHA256.hexdigest(content)[0, 16],
        'discovered_at' => Time.now.utc.iso8601(3)
      }.reject { |_k, v| v.nil? || v == '' }
    rescue StandardError
      nil
    end

    def tool_id(path)
      name = File.basename(path, File.extname(path))
      name.gsub(/[^a-zA-Z0-9._]+/, '.').downcase
    end

    def extract_summary(content)
      line = content.lines.find do |l|
        s = l.strip
        next false unless s.start_with?('#') && !s.start_with?('#!')
        next false if s.include?('///▙') || s.include?('⫸') || s.include?('::[0x')
        true
      end
      return '' if line.nil?
      line.sub(/^\s*#\s?/, '').strip[0, 140]
    end

    def dedupe(entries)
      by_id = {}
      entries.each do |e|
        existing = by_id[e['id']]
        if existing.nil? || rank(e['kind']) > rank(existing['kind'])
          by_id[e['id']] = e
        end
      end
      by_id.values.sort_by { |e| e['id'] }
    end

    def rank(kind)
      { 'cli' => 4, 'ops' => 3, 'io' => 2, 'service' => 1 }.fetch(kind, 0)
    end

    def write_registry(path, roots, discovered)
      existing = load_registry(path)
      manual = {}
      (existing['tools'] || {}).each do |id, tool|
        next if tool['auto_discovered']
        manual[id] = tool
      end

      merged = manual.dup
      discovered.each { |tool| merged[tool['id']] = tool }

      payload = {
        'meta' => {
          'id' => 'VEC3.TOOL.REGISTRY',
          'version' => SCANNER_VERSION,
          'updated_at' => Time.now.utc.iso8601(3),
          'sources' => roots.map { |r| { 'kind' => r[:kind], 'path' => relative(find_base_root(Dir.pwd), r[:path]) } }
        },
        'tools' => merged
      }

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, payload.to_yaml)
    end

    def load_registry(path)
      return {} unless File.file?(path)
      YAML.safe_load(File.read(path), permitted_classes: [Time], aliases: true) || {}
    rescue StandardError
      {}
    end

    def relative(base, path)
      path.sub(%r{\A#{Regexp.escape(base)}/?}, '')
    end
  end
end

ToolScanner.run(ARGV)
