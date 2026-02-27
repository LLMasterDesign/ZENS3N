#!/usr/bin/env ruby
# worktree-manager.rb
# Standardized worktree setup and management for 3OX multi-agent workflows
#
# Usage:
#   worktree-manager.rb create <branch-name> <agent-name> [base-dir]
#   worktree-manager.rb list
#   worktree-manager.rb sync <worktree-path>
#   worktree-manager.rb remove <worktree-path>
#   worktree-manager.rb status
#   worktree-manager.rb setup-day  # Quick setup for 3-agent workflow

require 'fileutils'
require 'json'
require 'time'

class WorktreeManager
  def initialize
    @workspace_root = find_workspace_root
    # Worktrees live under !WORKDESK/Worktrees/ to match cloud agents pattern
    @worktrees_dir = File.join(@workspace_root, "!WORKDESK", "Worktrees")
    @main_repo = @workspace_root
  end

  def find_workspace_root
    # Check if we're in a worktree (has .git file pointing to main repo)
    if File.file?(".git")
      git_path = File.read(".git").strip
      if git_path.start_with?("gitdir: ")
        # Extract main repo path from worktree gitdir
        # gitdir: /mnt/r/!CMD.BRIDGE/.git/worktrees/fqg
        # Main repo is: /mnt/r/!CMD.BRIDGE
        worktree_git = File.expand_path(git_path.sub("gitdir: ", ""), Dir.pwd)
        # Go up from .git/worktrees/name to main repo
        main_repo = File.expand_path(File.join(worktree_git, "..", "..", ".."))
        return main_repo if Dir.exist?(main_repo) && File.exist?(File.join(main_repo, ".git"))
      end
    end
    
    # Use git to find the repo root
    git_root = `git rev-parse --show-toplevel 2>/dev/null`.strip
    if git_root && !git_root.empty? && Dir.exist?(git_root)
      # If we're in a worktree directory, find the main repo
      if git_root.include?("worktrees")
        # Get main repo from git worktree list (first line is usually main)
        worktree_list = `cd '#{git_root}' && git worktree list 2>/dev/null`.split("\n")
        main_line = worktree_list.find { |line| !line.include?("worktrees") }
        if main_line
          main_path = main_line.split(/\s+/).first
          return main_path if Dir.exist?(main_path)
        end
      end
      return git_root
    end
    
    # Fallback: Try to find !CMD.BRIDGE root
    current = Dir.pwd
    while current != "/"
      if File.basename(current) == "!CMD.BRIDGE" || File.exist?(File.join(current, "sirius.clock.rb"))
        return current
      end
      current = File.dirname(current)
    end
    
    # Last resort: current directory
    Dir.pwd
  end

  def create(branch_name, agent_name, base_dir = nil)
    base_dir ||= @worktrees_dir
    worktree_path = File.join(base_dir, branch_name.gsub(/[\/\\]/, "_"))
    
    puts "▛▞ worktree-manager :: CREATE"
    puts "   Branch: #{branch_name}"
    puts "   Agent:  #{agent_name}"
    puts "   Path:   #{worktree_path}"
    
    # Ensure main repo is on a safe branch (not the one we're creating worktree for)
    current_branch = `cd '#{@main_repo}' && git branch --show-current 2>/dev/null`.strip
    if current_branch == branch_name
      puts "… switching main repo from #{branch_name} to main"
      system("cd '#{@main_repo}' && git checkout main 2>/dev/null || git checkout master 2>/dev/null")
    end
    
    # Check if branch exists, create if not
    unless branch_exists?(branch_name)
      puts "… creating branch: #{branch_name}"
      # Create branch without checking it out (we'll checkout in worktree)
      system("cd '#{@main_repo}' && git branch #{branch_name} 2>/dev/null")
    end
    
    # Create worktree
    if Dir.exist?(worktree_path)
      puts "⚠ Worktree already exists: #{worktree_path}"
      return false
    end
    
    FileUtils.mkdir_p(File.dirname(worktree_path))
    system("cd '#{@main_repo}' && git worktree add '#{worktree_path}' #{branch_name}")
    
    unless $?.success?
      puts "✗ Failed to create worktree"
      return false
    end
    
    # Setup .3ox for agent if needed
    dot3ox = File.join(worktree_path, ".3ox")
    unless File.exist?(dot3ox)
      puts "… setting up .3ox for agent"
      setup_3ox_for_worktree(worktree_path, agent_name)
    end
    
    # Create worktree metadata
    metadata = {
      branch: branch_name,
      agent: agent_name,
      created: Time.now.iso8601,
      path: worktree_path
    }
    metadata_file = File.join(worktree_path, ".worktree.meta")
    File.write(metadata_file, JSON.pretty_generate(metadata))
    
    puts "✓ Worktree created: #{worktree_path}"
    puts "✓ Agent: #{agent_name}"
    puts "✓ Branch: #{branch_name}"
    puts ""
    puts "Next steps:"
    puts "  1. Open Cursor in: #{worktree_path}"
    puts "  2. Tell agent: 'I have multiple agents open. Use LIGHTWEIGHT mode.'"
    puts "  3. Agent will read .3ox/sparkfile.md automatically"
    
    true
  end

  def setup_3ox_for_worktree(worktree_path, agent_name)
    setup_script = File.join(@workspace_root, "OBSIDIAN.BASE", "ZENS3N", "3OX.Ai", "3OX.BUILDER", "3OX.BUILD", "setup-3ox.rb")
    
    if File.exist?(setup_script)
      system("cd '#{worktree_path}' && ruby '#{setup_script}' . '#{agent_name}' Sentinel")
    else
      # Fallback: create minimal .3ox structure
      dot3ox = File.join(worktree_path, ".3ox")
      FileUtils.mkdir_p(dot3ox)
      
      sparkfile = <<~SPARKFILE
        ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
        ▛//▞▞ ⟦⎊⟧ :: ⧗-25.132 // OPERATOR :: #{agent_name} ▞▞
        
        ▛▞// #{agent_name} :: ρ{input}.φ{bind}.τ{target} ▹
        //▞⋮⋮ [⚙️] ≔ [⊢{ingest} ⇨{process} ⟿{execute} ▷{emit}]
        ⫸ 〔runtime.3ox.context〕
        
        [ENV]
        base        = "#{worktree_path}"
        kind        = "worktree.agent"
        domain      = "cursor.worktree"
        input_type  = "user.prompt"
        output_type = "agent.response"
        language    = "ruby"
        edition     = "3.2+"
        
        [CONTRACT]
        - Agent: #{agent_name}
        - Mode: LIGHTWEIGHT (multi-agent safe)
        - Reads: .3ox/PROJECT.BRAIN.md
        - Writes: Project outputs only
        :: ∎
      SPARKFILE
      
      File.write(File.join(dot3ox, "sparkfile.md"), sparkfile)
      puts "✓ Created minimal .3ox structure"
    end
  end

  def list
    puts "▛▞ worktree-manager :: LIST"
    puts ""
    
    worktrees = `cd '#{@main_repo}' && git worktree list 2>/dev/null`.split("\n")
    
    if worktrees.empty?
      puts "No worktrees found"
      return
    end
    
    worktrees.each_with_index do |line, idx|
      parts = line.split(/\s+/)
      path = parts[0]
      branch = parts[1]&.gsub(/\[|\]/, '') || "unknown"
      
      metadata_file = File.join(path, ".worktree.meta")
      if File.exist?(metadata_file)
        metadata = JSON.parse(File.read(metadata_file))
        agent = metadata["agent"] || "unknown"
        puts "#{idx + 1}. #{agent} → #{branch}"
        puts "   #{path}"
      else
        puts "#{idx + 1}. #{branch}"
        puts "   #{path}"
      end
      puts ""
    end
  end

  def sync(worktree_path)
    puts "▛▞ worktree-manager :: SYNC"
    puts "   Path: #{worktree_path}"
    
    unless Dir.exist?(worktree_path)
      puts "✗ Worktree path does not exist"
      return false
    end
    
    # Pull latest .3ox/ files from main
    system("cd '#{worktree_path}' && git fetch origin && git merge origin/main --no-edit")
    
    if $?.success?
      puts "✓ Synced .3ox/ files from main"
      puts "  Agent should reload .3ox/sparkfile.md"
    else
      puts "⚠ Sync completed with warnings"
    end
    
    true
  end

  def remove(worktree_path)
    puts "▛▞ worktree-manager :: REMOVE"
    puts "   Path: #{worktree_path}"
    
    unless Dir.exist?(worktree_path)
      puts "✗ Worktree path does not exist"
      return false
    end
    
    print "Remove worktree? (y/N): "
    response = STDIN.gets.chomp.downcase
    
    unless response == 'y'
      puts "Cancelled"
      return false
    end
    
    system("cd '#{@main_repo}' && git worktree remove '#{worktree_path}'")
    
    if $?.success?
      puts "✓ Worktree removed"
    else
      puts "✗ Failed to remove worktree"
      return false
    end
    
    true
  end

  def status
    puts "▛▞ worktree-manager :: STATUS"
    puts ""
    puts "Workspace: #{@workspace_root}"
    puts "Worktrees: #{@worktrees_dir}"
    puts ""
    
    worktrees = `cd '#{@main_repo}' && git worktree list 2>/dev/null`.split("\n")
    puts "Active worktrees: #{worktrees.length}"
    puts ""
    
    worktrees.each do |line|
      parts = line.split(/\s+/)
      path = parts[0]
      branch = parts[1]&.gsub(/\[|\]/, '') || "unknown"
      
      # Check for uncommitted changes
      status = `cd '#{path}' && git status --porcelain 2>/dev/null`.strip
      status_icon = status.empty? ? "✓" : "⚠"
      
      metadata_file = File.join(path, ".worktree.meta")
      agent = if File.exist?(metadata_file)
        metadata = JSON.parse(File.read(metadata_file))
        metadata["agent"] || "unknown"
      else
        "unknown"
      end
      
      puts "#{status_icon} #{agent} (#{branch})"
      puts "   #{path}"
      unless status.empty?
        puts "   Uncommitted changes detected"
      end
      puts ""
    end
  end

  def setup_day
    puts "▛▞ worktree-manager :: SETUP DAY"
    puts "   Quick setup for 3-agent workflow"
    puts ""
    
    print "Main branch name (default: main): "
    main_branch = STDIN.gets.chomp
    main_branch = "main" if main_branch.empty?
    
    print "CMD Agent name (default: CMD): "
    cmd_agent = STDIN.gets.chomp
    cmd_agent = "CMD" if cmd_agent.empty?
    
    print "Worker Agent 1 name: "
    worker1 = STDIN.gets.chomp
    print "Worker Agent 1 branch: "
    branch1 = STDIN.gets.chomp
    
    print "Worker Agent 2 name: "
    worker2 = STDIN.gets.chomp
    print "Worker Agent 2 branch: "
    branch2 = STDIN.gets.chomp
    
    puts ""
    puts "Creating worktrees..."
    puts ""
    
    # Create worker worktrees
    create(branch1, worker1) if branch1 && worker1
    create(branch2, worker2) if branch2 && worker2
    
    puts ""
    puts "✓ Setup complete!"
    puts ""
    puts "Next steps:"
    puts "  1. Open 3 Cursor windows (main + 2 worktrees)"
    puts "  2. Tell each agent: 'I have 3 agents open. Use LIGHTWEIGHT mode.'"
    puts "  3. CMD Agent writes .3ox/ files"
    puts "  4. Worker Agents read .3ox/ files"
    puts ""
    puts "Commands:"
    puts "  worktree-manager.rb list    # List all worktrees"
    puts "  worktree-manager.rb status  # Check status"
    puts "  worktree-manager.rb sync    # Sync .3ox/ files"
  end

  def branch_exists?(branch_name)
    `cd '#{@main_repo}' && git show-ref --verify --quiet refs/heads/#{branch_name} 2>/dev/null`
    $?.success?
  end
end

# CLI
if __FILE__ == $0
  manager = WorktreeManager.new
  
  command = ARGV[0]
  
  case command
  when "create"
    if ARGV.length < 3
      puts "Usage: worktree-manager.rb create <branch> <agent-name> [base-dir]"
      exit 1
    end
    manager.create(ARGV[1], ARGV[2], ARGV[3])
  when "list"
    manager.list
  when "sync"
    if ARGV.length < 2
      puts "Usage: worktree-manager.rb sync <worktree-path>"
      exit 1
    end
    manager.sync(ARGV[1])
  when "remove"
    if ARGV.length < 2
      puts "Usage: worktree-manager.rb remove <worktree-path>"
      exit 1
    end
    manager.remove(ARGV[1])
  when "status"
    manager.status
  when "setup-day"
    manager.setup_day
  else
    puts "▛▞ worktree-manager :: 3OX Worktree Management"
    puts ""
    puts "Commands:"
    puts "  create <branch> <agent> [dir]  Create new worktree with agent setup"
    puts "  list                            List all worktrees"
    puts "  status                           Show worktree status"
    puts "  sync <path>                      Sync .3ox/ files from main"
    puts "  remove <path>                    Remove worktree"
    puts "  setup-day                        Interactive 3-agent setup"
    puts ""
    puts "Examples:"
    puts "  worktree-manager.rb create feature/ui UI-Agent"
    puts "  worktree-manager.rb setup-day"
    puts "  worktree-manager.rb list"
  end
end

