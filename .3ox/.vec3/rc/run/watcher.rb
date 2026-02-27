# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x61C8]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // WATCHER.RB ▞▞
# ▛▞// WATCHER.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [json] [dispatch] [kernel] [prism] [z3n] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.watcher.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for WATCHER.RB
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
#/command2 = description2
#/command1 = description1
#(Add toolset commands here)
#▛//▞ TOOLSET ::
#
#```
##///          (Add third line of purpose here)
##///          (Add second line of purpose here)
##/// Purpose: !/usr/bin/env ruby
##/// Last Updated: 2026.01.05 | Trace.ID: watcher.v1.0
##/// Status: [ACTIVE] | Cat: RUNTIME | Auth: SYSTEM | Created: 2026.01.05
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [watcher] [runtime] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // WATCHER ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
# vec3/rc/run/watcher.rb - File watcher for inbox triggers
# Part of 3OX.Ai (ZEN-7)
#
# Monitors directories and dispatches jobs when files appear

require 'json'
require 'fileutils'
require_relative '../../lib/core/trace'
require_relative '../../lib/core/registry'
require_relative '../dispatch/dispatch'
require_relative 'envelope'

module Vec3
  module Run
    class Watcher
      attr_reader :watch_dirs, :poll_interval, :running
      
      VEC3_ROOT = File.expand_path('../..', __dir__)
      DEFAULT_WATCH_DIRS = [
        File.join(VEC3_ROOT, '..', '..', '!1N.3OX'),  # Inbox
        File.join(VEC3_ROOT, 'var', 'wrkdsk', 'inbox')
      ].freeze
      
      def initialize(watch_dirs: nil, poll_interval: 2)
        @watch_dirs = watch_dirs || DEFAULT_WATCH_DIRS.select { |d| Dir.exist?(d) }
        @poll_interval = poll_interval
        @running = false
        @processed = {}
        @trace_id = Vec3::Trace.start(component: 'watcher', operation: 'init')
      end
      
      def start
        @running = true
        
        Vec3::Trace.info(component: 'watcher', event: 'start', data: { dirs: @watch_dirs })
        Vec3::Registry.register_service(id: 'watcher', name: 'File Watcher', command: 'ruby watcher.rb', status: :running, pid: Process.pid)
        
        puts "▛▞ File Watcher started"
        puts "Watching: #{@watch_dirs.join(', ')}"
        puts "Poll interval: #{@poll_interval}s"
        
        while @running
          check_directories
          sleep @poll_interval
        end
      end
      
      def stop
        @running = false
        Vec3::Registry.update_service('watcher', status: :stopped, pid: nil)
        Vec3::Trace.info(component: 'watcher', event: 'stop')
        puts "Watcher stopped"
      end
      
      private
      
      def check_directories
        @watch_dirs.each do |dir|
          next unless Dir.exist?(dir)
          
          Dir.glob(File.join(dir, '*')).each do |file|
            next if File.directory?(file)
            next if @processed[file]
            
            process_file(file)
            @processed[file] = Time.now
          end
        end
        
        # Cleanup old processed entries (older than 1 hour)
        cutoff = Time.now - 3600
        @processed.delete_if { |_, time| time < cutoff }
      end
      
      def process_file(file)
        Vec3::Trace.info(component: 'watcher', event: 'file.detected', data: { file: file })
        
        begin
          # Determine file type and create appropriate envelope
          ext = File.extname(file).downcase
          
          envelope = case ext
          when '.json'
            process_json_file(file)
          when '.md', '.txt'
            process_text_file(file)
          else
            process_generic_file(file)
          end
          
          # Dispatch the envelope
          receipt = Vec3::Dispatch.process(envelope)
          
          Vec3::Trace.info(
            component: 'watcher',
            event: 'file.processed',
            data: { file: file, receipt_id: receipt[:receipt_id], status: receipt[:status] }
          )
          
          puts "Processed: #{File.basename(file)} → #{receipt[:receipt_id]}"
          
          # Move to processed folder
          move_to_processed(file)
          
        rescue => e
          Vec3::Trace.error(component: 'watcher', event: 'file.error', data: { file: file, error: e.message })
          puts "Error processing #{file}: #{e.message}"
        end
      end
      
      def process_json_file(file)
        content = JSON.parse(File.read(file), symbolize_names: true)
        
        # Check if it's already an envelope
        if content[:kind] == 'envelope'
          content
        else
          # Wrap content as args
          Envelope.shape(
            op: 'file.process',
            args: { file: file, content: content },
            permissions: ['fs.read'],
            source: 'watcher'
          )
        end
      end
      
      def process_text_file(file)
        content = File.read(file)
        
        Envelope.shape(
          op: 'file.analyze',
          args: { file: file, content_preview: content[0..500] },
          permissions: ['fs.read'],
          source: 'watcher'
        )
      end
      
      def process_generic_file(file)
        Envelope.shape(
          op: 'file.ingest',
          args: { file: file, size: File.size(file), mtime: File.mtime(file).iso8601 },
          permissions: ['fs.read'],
          source: 'watcher'
        )
      end
      
      def move_to_processed(file)
        processed_dir = File.join(File.dirname(file), 'processed')
        FileUtils.mkdir_p(processed_dir)
        
        dest = File.join(processed_dir, File.basename(file))
        FileUtils.mv(file, dest)
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  case ARGV[0]
  when 'start', nil
    dirs = ARGV[1..].empty? ? nil : ARGV[1..]
    watcher = Vec3::Run::Watcher.new(watch_dirs: dirs)
    
    # Handle signals
    trap('INT') { watcher.stop; exit }
    trap('TERM') { watcher.stop; exit }
    
    watcher.start
  when 'stop'
    Vec3::Registry.update_service('watcher', status: :stopped)
    puts "Watcher stop signal sent"
  else
    puts "Usage: ruby watcher.rb [start|stop] [dirs...]"
  end
end

# :: ∎