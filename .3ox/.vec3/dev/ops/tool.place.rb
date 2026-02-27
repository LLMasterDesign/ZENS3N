#!/usr/bin/env ruby
# tool.place.rb :: Place tool files/directories into canonical vec3 locations.

require 'fileutils'
require 'optparse'
require 'rbconfig'

module ToolPlace
  class << self
    def run(argv)
      opts = parse_args(argv)
      source = argv.shift
      raise 'Usage: tool.place.rb [options] <source_path>' if source.nil? || source.strip.empty?

      base = find_base_root(Dir.pwd)
      raise "Could not resolve base root from #{Dir.pwd}" if base.nil?

      src = File.expand_path(source, base)
      raise "Source not found: #{src}" unless File.exist?(src)

      dest_root = destination_root(base, opts)
      FileUtils.mkdir_p(dest_root)

      moved = place(src, dest_root, opts)
      run_scanner(base)

      puts({ ok: true, source: src, destination_root: dest_root, moved: moved }.to_yaml)
    rescue StandardError => e
      warn({ ok: false, error: e.message }.to_yaml)
      exit 1
    end

    def parse_args(argv)
      opts = { kind: 'ops', io_channel: 'misc', copy: false }
      OptionParser.new do |o|
        o.banner = 'Usage: tool.place.rb --kind KIND [--io-channel NAME] [--copy] <source_path>'
        o.on('--kind KIND', 'ops|io|cli|service') { |v| opts[:kind] = v }
        o.on('--io-channel NAME', 'io channel folder (default: misc)') { |v| opts[:io_channel] = v }
        o.on('--copy', 'Copy instead of move') { opts[:copy] = true }
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

    def destination_root(base, opts)
      vec3 = File.join(base, '.3ox', '.vec3')
      case opts[:kind]
      when 'ops'
        File.join(vec3, 'dev', 'ops')
      when 'io'
        File.join(vec3, 'dev', 'io', opts[:io_channel].to_s)
      when 'cli'
        File.join(vec3, 'rc', 'bin')
      when 'service'
        File.join(vec3, 'rc', 'services')
      else
        raise "Unknown kind: #{opts[:kind]}"
      end
    end

    def place(src, dest_root, opts)
      if File.directory?(src)
        dest = File.join(dest_root, File.basename(src))
        transfer(src, dest, opts[:copy])
        return [dest]
      end

      moved = []
      base = File.basename(src, File.extname(src))
      dir = File.dirname(src)
      candidates = [src]

      Dir.glob(File.join(dir, "#{base}.*")).each do |f|
        next if f == src
        ext = File.extname(f).downcase
        next unless %w[.md .toml .yaml .yml .json .txt].include?(ext)
        candidates << f
      end

      candidates.uniq.each do |f|
        dest = File.join(dest_root, File.basename(f))
        transfer(f, dest, opts[:copy])
        moved << dest
      end
      moved
    end

    def transfer(src, dest, copy)
      FileUtils.mkdir_p(File.dirname(dest))
      if copy
        FileUtils.cp_r(src, dest)
      else
        FileUtils.mv(src, dest)
      end
    end

    def run_scanner(base)
      scanner = File.join(base, '.3ox', '.vec3', 'dev', 'ops', 'tool.scanner.rb')
      return unless File.file?(scanner)
      system(RbConfig.ruby, scanner, chdir: base)
    end
  end
end

ToolPlace.run(ARGV)
