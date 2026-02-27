# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x50E0]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // 3OX-CLI.RB ▞▞
# ▛▞// 3OX-CLI.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [yaml] [kernel] [prism] [z3n] [threeox_cli] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.3ox-cli.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for 3OX-CLI.RB
# ```

# 


# 


# ▛//▞ PRISM :: KERNEL
# P:: identity.matrix ∙ context.anchor ∙ execution.flow
# R:: load.context ∙ execute.logic ∙ emit.result
# I:: intent.target={system.stability ∙ function.execution}
# S:: init → process → terminate
# M:: std.io ∙ file.sys ∙ mem.state
# :: ∎

#!/usr/bin/env ruby
SEAL = ':: ∎'

# 3OX-CLI.RB :: Command Line Interface for 3OX.Ai System
# Provides mini LFM, agent spawning, versioning, and system management

require 'optparse'
require 'json'
require 'fileutils'
require 'yaml'
require 'find'
require 'time'
require 'digest'
require 'shellwords'

class ThreeOX_CLI
  VERSION = "0.1.0"
  CONFIG_DIR = File.join(Dir.home, '.3ox')
  AGENTS_DIR = File.join(CONFIG_DIR, 'agents')
  VERSIONS_DIR = File.join(CONFIG_DIR, 'versions')
  LFM_DIR = File.join(CONFIG_DIR, 'lfm')

  def initialize
    setup_directories
    @config = load_config
  end

  def setup_directories
    [CONFIG_DIR, AGENTS_DIR, VERSIONS_DIR, LFM_DIR].each do |dir|
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    end
  end

  def load_config
    config_file = File.join(CONFIG_DIR, 'config.yaml')
    if File.exist?(config_file)
      YAML.load_file(config_file)
    else
      default_config
    end
  end

  def default_config
    {
      'version' => VERSION,
      'agents' => {},
      'lfm' => {
        'enabled' => true,
        'port' => 3001,
        'host' => 'localhost'
      },
      'auto_spawn' => false,
      'max_agents' => 5
    }
  end

  def save_config
    config_file = File.join(CONFIG_DIR, 'config.yaml')
    File.write(config_file, @config.to_yaml)
  end

  # ============================================================================
  # LFM (Language File Manager) - Mini version
  # ============================================================================

  def start_lfm
    puts "🚀 Starting 3OX Mini LFM..."
    puts "📍 Host: #{@config['lfm']['host']}:#{@config['lfm']['port']}"

    # Simple file server for agent files
    lfm_config = {
      host: @config['lfm']['host'],
      port: @config['lfm']['port'],
      root: LFM_DIR,
      agents: AGENTS_DIR
    }

    File.write(File.join(LFM_DIR, 'config.json'), JSON.pretty_generate(lfm_config))
    puts "✅ LFM config saved to #{File.join(LFM_DIR, 'config.json')}"
    puts "🌐 LFM ready for agent file management"
  end

  # ============================================================================
  # AGENT MANAGEMENT
  # ============================================================================

  def install_agent(name, type = 'cursor')
    puts "📦 Installing agent: #{name} (#{type})"

    agent_dir = File.join(AGENTS_DIR, name)
    FileUtils.mkdir_p(agent_dir)

    agent_config = {
      name: name,
      type: type,
      installed_at: Time.now.iso8601,
      status: 'installed',
      config: {
        auto_start: false,
        max_instances: 3,
        timeout: 300
      }
    }

    config_file = File.join(agent_dir, 'agent.json')
    File.write(config_file, JSON.pretty_generate(agent_config))

    @config['agents'][name] = agent_config
    save_config

    puts "✅ Agent #{name} installed successfully"
    puts "📁 Location: #{agent_dir}"
  end

  def spawn_agent(name)
    puts "🧬 Spawning agent: #{name}"

    unless @config['agents'][name]
      puts "❌ Agent #{name} not found. Install it first with: 3ox install #{name}"
      return
    end

    agent_dir = File.join(AGENTS_DIR, name)
    spawn_script = File.join(agent_dir, 'spawn.rb')

    if File.exist?(spawn_script)
      puts "🚀 Executing spawn script..."
      system("ruby #{spawn_script}")
    else
      puts "📝 Creating default spawn script..."
      create_spawn_script(agent_dir, name)
      puts "✅ Spawn script created. Run again to spawn."
    end
  end

  def create_spawn_script(dir, name)
    script = <<~RUBY
      #!/usr/bin/env ruby
      # Auto-generated spawn script for agent: #{name}

      puts "🧬 Spawning 3OX Agent: #{name}"
      puts "⏰ Started at: #{Time.now}"

      # Agent logic goes here
      # This is where the agent would initialize and begin operation

      puts "✅ Agent #{name} spawned successfully"
      puts "🔄 Agent is now running..."

      # Keep alive loop
      loop do
        sleep 60
        puts "💓 Agent #{name} heartbeat - #{Time.now}"
      end
    RUBY

    File.write(File.join(dir, 'spawn.rb'), script)
    File.chmod(0755, File.join(dir, 'spawn.rb'))
  end

  def list_agents
    puts "🤖 Installed Agents:"
    puts "=" * 40

    if @config['agents'].empty?
      puts "No agents installed."
      puts "Install one with: 3ox install <name>"
      return
    end

    @config['agents'].each do |name, config|
      status = config['status'] || 'unknown'
      puts "• #{name} (#{config['type']}) - #{status}"
    end
  end

  # ============================================================================
  # VERSIONING SYSTEM
  # ============================================================================

  def create_version(tag, description = "")
    puts "🏷️  Creating version: #{tag}"

    version_dir = File.join(VERSIONS_DIR, tag)
    FileUtils.mkdir_p(version_dir)

    version_info = {
      tag: tag,
      created_at: Time.now.iso8601,
      description: description,
      cli_version: VERSION,
      config_snapshot: @config,
      agents_snapshot: Dir.glob("#{AGENTS_DIR}/*").map { |d| File.basename(d) }
    }

    version_file = File.join(version_dir, 'version.json')
    File.write(version_file, JSON.pretty_generate(version_info))

    puts "✅ Version #{tag} created"
    puts "📁 Location: #{version_dir}"
  end

  def list_versions
    puts "🏷️  Available Versions:"
    puts "=" * 40

    versions = Dir.glob("#{VERSIONS_DIR}/*").sort.reverse
    if versions.empty?
      puts "No versions created yet."
      puts "Create one with: 3ox version create <tag>"
      return
    end

    versions.first(5).each do |vdir|
      tag = File.basename(vdir)
      version_file = File.join(vdir, 'version.json')

      if File.exist?(version_file)
        info = JSON.parse(File.read(version_file))
        desc = info['description'] || 'No description'
        date = info['created_at']
        puts "• #{tag} - #{desc} (#{date})"
      else
        puts "• #{tag} - Version file missing"
      end
    end
  end

  # ============================================================================
  # SYSTEM STATUS
  # ============================================================================

  def status
    puts "🔍 3OX System Status"
    puts "=" * 40
    puts "Version: #{VERSION}"
    puts "Config: #{File.join(CONFIG_DIR, 'config.yaml')}"
    puts "Agents: #{AGENTS_DIR} (#{Dir.glob("#{AGENTS_DIR}/*").length} installed)"
    puts "Versions: #{VERSIONS_DIR} (#{Dir.glob("#{VERSIONS_DIR}/*").length} created)"
    puts "LFM: #{LFM_DIR} (#{@config['lfm']['enabled'] ? 'enabled' : 'disabled'})"
    puts ""
    puts "Recent Activity:"
    puts "• CLI initialized"
    puts "• Directories created"
    puts "• Configuration loaded"
  end

  # ============================================================================
  # FOLDER CLEAN / HEADER SCAN (PHENO/PiCO/CTX quick index)
  # ============================================================================

  def scan_headers(root_dirs, out_path: nil, max_lines: 48, limit: nil, ignore_dirs: nil, include_hidden: false, format: 'toml', hash_mode: 'none', hash_bytes: 65536)
    root_dirs = Array(root_dirs).compact
    root_dirs = root_dirs.reject { |d| d.to_s.strip.empty? }

    if root_dirs.empty?
      puts "Usage: 3ox scan-headers <folder...> [--out <path>] [--format toml|jsonl] [--hash none|head|full]"
      return 1
    end

    missing = root_dirs.reject { |d| Dir.exist?(d) }
    if missing.any?
      puts "Error: folder(s) do not exist:"
      missing.each { |m| puts "  - #{m}" }
      return 1
    end

    ignore_dirs ||= %w[
      .git node_modules deps _build .cache .venv venv dist build target tmp .tmp
    ]

    if out_path.nil?
      if root_dirs.length == 1
        out_path = File.join(root_dirs[0], format == 'jsonl' ? ".folder.scan.jsonl" : ".folder.scan.toml")
      else
        puts "Error: multiple roots provided; please supply --out <path> for a combined index."
        return 1
      end
    end

    entries = []
    scanned = 0

    root_dirs.each do |root_dir|
      Find.find(root_dir) do |path|
        begin
          if File.directory?(path)
            base = File.basename(path)
            if ignore_dirs.include?(base)
              Find.prune
            end
            if !include_hidden && base.start_with?('.') && path != root_dir
              Find.prune
            end
            next
          end

          next unless File.file?(path)
          next if !include_hidden && File.basename(path).start_with?('.')

          rel = path.sub(/^#{Regexp.escape(root_dir)}\/?/, '')
          info = parse_header_quick(path, max_lines: max_lines)

          stat = File.stat(path) rescue nil
          size = stat ? stat.size : nil
          mtime = stat ? stat.mtime.to_i : nil

          signature = build_signature(path, hash_mode: hash_mode, hash_bytes: hash_bytes)

          entries << info.merge({
            "root" => root_dir,
            "path" => rel,
            "path_abs" => path,
            "ext" => File.extname(path).sub(/^\./, ''),
            "size" => size,
            "mtime" => mtime
          }).merge(signature)

          scanned += 1
          if limit && scanned >= limit
            break
          end
        rescue => _e
          # Skip unreadable files silently; this is an index pass.
          next
        end
      end
      break if limit && scanned >= limit
    end

    if format == 'jsonl'
      write_scan_jsonl(
        root_dirs: root_dirs,
        out_path: out_path,
        max_lines: max_lines,
        ignore_dirs: ignore_dirs,
        scanned_count: scanned,
        hash_mode: hash_mode,
        hash_bytes: hash_bytes,
        entries: entries
      )
    else
      toml = build_scan_toml(
        root_dirs: root_dirs,
        out_path: out_path,
        max_lines: max_lines,
        ignore_dirs: ignore_dirs,
        scanned_count: scanned,
        hash_mode: hash_mode,
        hash_bytes: hash_bytes,
        entries: entries
      )
      File.write(out_path, toml)
    end

    puts "✓ Wrote: #{out_path}"
    puts "  Files indexed: #{scanned}"
    0
  end

  def build_signature(file_path, hash_mode:, hash_bytes:)
    case hash_mode
    when 'full'
      { "hash" => sha256_file(file_path), "hash_mode" => "sha256.full" }
    when 'head'
      { "hash" => sha256_head(file_path, hash_bytes), "hash_mode" => "sha256.head", "hash_bytes" => hash_bytes }
    when 'xxh3_128'
      { "hash" => xxh3_128_file(file_path), "hash_mode" => "xxh3_128.full" }
    else
      {}
    end
  end

  def sha256_head(file_path, bytes)
    h = Digest::SHA256.new
    File.open(file_path, 'rb') do |f|
      h.update(f.read(bytes) || "")
    end
    h.hexdigest
  rescue
    nil
  end

  def sha256_file(file_path)
    Digest::SHA256.file(file_path).hexdigest
  rescue
    nil
  end

  def xxh3_128_file(file_path)
    return nil unless File.exist?(file_path)
    xxhsum = '/usr/bin/xxhsum'
    return nil unless File.exist?(xxhsum)

    out = `#{xxhsum} -H2 #{Shellwords.escape(file_path)} 2>/dev/null`.strip
    hex = out.split(/\s+/)[0]
    return nil if hex.nil? || hex.empty?
    "xxh3_128:#{hex}"
  rescue
    nil
  end

  def parse_header_quick(file_path, max_lines: 48)
    schema = nil
    imprint = nil
    pheno = nil
    pico = nil
    ctx = nil
    sirius = nil

    lines = []
    File.open(file_path, 'rb') do |f|
      f.each_line do |raw|
        begin
          s = raw.encode('UTF-8', 'UTF-8', invalid: :replace, undef: :replace).rstrip
        rescue
          s = raw.to_s.rstrip
        end
        lines << s
        break if lines.length >= max_lines
      end
    end

    lines.each do |line|
      stripped = line.sub(/^\s*#\s?/, '').sub(/^\s*\/{2}\s?/, '').strip

      if schema.nil?
        m = stripped.match(/::\[(0x[0-9A-Fa-f]+)\]::/)
        schema = m[1] if m
      end

      if imprint.nil? && stripped.include?('▛//▞▞')
        imprint = stripped
        m = stripped.match(/(⧗-\d{2}\.\d{3})/)
        sirius = m[1] if m
      end

      if pheno.nil? && stripped.start_with?('▛▞//')
        pheno = stripped
      end

      if pico.nil? && stripped.start_with?('//▞⋮⋮')
        pico = stripped
      end

      if ctx.nil? && stripped.start_with?('⫸')
        ctx = stripped
      end

      break if imprint && pheno && pico && ctx && schema
    end

    {
      "schema" => schema,
      "sirius_time" => sirius,
      "imprint" => imprint,
      "pheno" => pheno,
      "pico" => pico,
      "ctx" => ctx
    }
  end

  def build_scan_toml(root_dirs:, out_path:, max_lines:, ignore_dirs:, scanned_count:, hash_mode:, hash_bytes:, entries:)
    now = Time.now.utc.iso8601

    toml = []
    toml << "# Auto-generated folder header index"
    toml << "# Purpose: quick scan for SXSL/PHENO headers (imprint/PHENO/PiCO/CTX)"
    toml << ""
    toml << "[scan]"
    toml << "roots = [#{root_dirs.map { |d| toml_str(d) }.join(', ')}]"
    toml << "written_to = #{toml_str(out_path)}"
    toml << "scanned_at_utc = #{toml_str(now)}"
    toml << "max_lines = #{max_lines}"
    toml << "files_indexed = #{scanned_count}"
    toml << "hash_mode = #{toml_str(hash_mode)}"
    toml << "hash_bytes = #{hash_bytes}" if hash_mode == 'head'
    toml << "ignore_dirs = [#{ignore_dirs.map { |d| toml_str(d) }.join(', ')}]"
    toml << ""

    entries.sort_by { |e| e["path"] }.each do |e|
      toml << "[[file]]"
      toml << "root = #{toml_str(e['root'])}" if e['root']
      toml << "path = #{toml_str(e['path'])}"
      toml << "path_abs = #{toml_str(e['path_abs'])}" if e['path_abs']
      toml << "ext = #{toml_str(e['ext'] || '')}"
      toml << "size = #{e['size']}" if e['size']
      toml << "mtime = #{e['mtime']}" if e['mtime']
      toml << "hash_mode = #{toml_str(e['hash_mode'])}" if e['hash_mode']
      toml << "hash_bytes = #{e['hash_bytes']}" if e['hash_bytes']
      toml << "hash = #{toml_str(e['hash'])}" if e['hash']
      toml << "schema = #{toml_str(e['schema'])}" if e['schema']
      toml << "sirius_time = #{toml_str(e['sirius_time'])}" if e['sirius_time']
      toml << "imprint = #{toml_str(e['imprint'])}" if e['imprint']
      toml << "pheno = #{toml_str(e['pheno'])}" if e['pheno']
      toml << "pico = #{toml_str(e['pico'])}" if e['pico']
      toml << "ctx = #{toml_str(e['ctx'])}" if e['ctx']
      toml << ""
    end

    toml.join("\n")
  end

  def write_scan_jsonl(root_dirs:, out_path:, max_lines:, ignore_dirs:, scanned_count:, hash_mode:, hash_bytes:, entries:)
    now = Time.now.utc.iso8601
    File.open(out_path, 'w') do |f|
      f.puts(JSON.generate({
        "type" => "folder.scan",
        "scan" => {
          "roots" => root_dirs,
          "written_to" => out_path,
          "scanned_at_utc" => now,
          "max_lines" => max_lines,
          "files_indexed" => scanned_count,
          "ignore_dirs" => ignore_dirs,
          "hash_mode" => hash_mode,
          "hash_bytes" => (hash_mode == 'head' ? hash_bytes : nil)
        }
      }))
      entries.each { |e| f.puts(JSON.generate(e)) }
    end
  end

  def toml_str(v)
    return "\"\"" if v.nil?
    s = v.to_s
    s = s.gsub("\\", "\\\\").gsub("\"", "\\\"")
    "\"#{s}\""
  end

  # ============================================================================
  # COMMAND LINE INTERFACE
  # ============================================================================

  def run(args)
    options = {}

    parser = OptionParser.new do |opts|
      opts.banner = "3OX Command Line Interface v#{VERSION}\n\nUsage: 3ox [command] [options]"

      opts.on("-h", "--help", "Show this help") do
        puts opts
        puts "\nCommands:"
        puts "  lfm start           Start Language File Manager"
        puts "  install <name>       Install a new agent"
        puts "  spawn <name>         Spawn/run an agent"
        puts "  list                 List installed agents"
        puts "  version create <tag> Create a new version"
        puts "  versions             List available versions"
        puts "  status               Show system status"
        puts "  scan-headers <dir>   Scan folder & write .folder.scan.toml (imprint/PHENO/PiCO/CTX)"
        puts ""
        puts "Examples:"
        puts "  3ox lfm start"
        puts "  3ox install cursor-agent"
        puts "  3ox spawn cursor-agent"
        puts "  3ox version create v1.0.0"
        puts "  3ox scan-headers /root/!LAUNCHPAD/!WORKDESK"
        exit
      end
    end

    # Use order! so subcommand-specific flags (e.g. scan-headers --limit)
    # don't raise as invalid options at the top-level parser.
    parser.order!(args)

    command = args.shift

    case command
    when 'lfm'
      subcommand = args.shift
      case subcommand
      when 'start'
        start_lfm
      else
        puts "Unknown LFM command: #{subcommand}"
        puts "Use: 3ox lfm start"
      end

    when 'install'
      name = args.shift
      if name
        type = args.shift || 'cursor'
        install_agent(name, type)
      else
        puts "Usage: 3ox install <name> [type]"
      end

    when 'spawn'
      name = args.shift
      if name
        spawn_agent(name)
      else
        puts "Usage: 3ox spawn <name>"
      end

    when 'list'
      list_agents

    when 'version'
      subcommand = args.shift
      case subcommand
      when 'create'
        tag = args.shift
        description = args.join(' ')
        if tag
          create_version(tag, description)
        else
          puts "Usage: 3ox version create <tag> [description]"
        end
      else
        puts "Unknown version command: #{subcommand}"
      end

    when 'versions'
      list_versions

    when 'status'
      status

    when 'scan-headers'
      roots = []
      while args[0] && !args[0].start_with?('-')
        roots << args.shift
      end
      out = nil
      max_lines = 48
      limit = nil
      include_hidden = false
      format = 'toml'
      hash_mode = 'none'
      hash_bytes = 65536

      opt = OptionParser.new do |o|
        o.on("--out PATH", "Output TOML path (default: <dir>/.folder.scan.toml)") { |v| out = v }
        o.on("--format FMT", "Output format: toml|jsonl (default: toml)") { |v| format = v }
        o.on("--max-lines N", Integer, "Max header lines to inspect per file (default: 48)") { |v| max_lines = v }
        o.on("--limit N", Integer, "Stop after indexing N files") { |v| limit = v }
        o.on("--hash MODE", "Hash mode: none|head|full|xxh3_128 (default: none)") { |v| hash_mode = v }
        o.on("--hash-bytes N", Integer, "Bytes for head hash (default: 65536)") { |v| hash_bytes = v }
        o.on("--include-hidden", "Include dotfiles/directories") { include_hidden = true }
      end
      opt.parse!(args) rescue nil

      scan_headers(roots, out_path: out, max_lines: max_lines, limit: limit, include_hidden: include_hidden, format: format, hash_mode: hash_mode, hash_bytes: hash_bytes)

    else
      puts "Unknown command: #{command}"
      puts "Use: 3ox --help for available commands"
    end
  end
end

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __FILE__ == $0
  cli = ThreeOX_CLI.new
  cli.run(ARGV)
end

# :: ∎