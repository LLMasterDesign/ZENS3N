# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xB536]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // PULSE.RB ▞▞
# ▛▞// PULSE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [merkle] [pulse] [json] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.pulse.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for PULSE.RB
# ```

# 


# 


#!/usr/bin/env ruby




#

#
# ▛//▞ PRISM :: KERNEL
# P:: event.stream ∙ merkle.proof ∙ change.audit
# R:: event.append ∙ merkle.update ∙ chain.verify
# I:: intent.target={mutation.proof ∙ deterministic.replay}
# S:: receive → hash → chain → merkle → append
# M:: json.event ∙ merkle.root
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ receive{event ∙ action ∙ actor}
# ⇨ ≔ hash{sha256 ∙ prev_hash.link}
# ⟿ ≔ merkle{tree.compute ∙ root.save}
# ▷ ≔ append{pulse.log ∙ return.event}
# :: ∎

require 'json'
require 'digest'
require 'fileutils'
require 'time'

module Vec3
  module Pulse
    VEC3_ROOT = File.expand_path('../../..', __dir__)
    PULSE_DIR = File.join(VEC3_ROOT, 'var', 'pulse')
    PULSE_LOG = File.join(PULSE_DIR, 'pulse.jsonl')
    MERKLE_FILE = File.join(PULSE_DIR, 'merkle.root')
    META_MERKLE_FILE = File.join(VEC3_ROOT, '..', '_meta', 'merkle.root')
    
    class << self
      # ─────────────────────────────────────────────────────────────
      # Main API
      # ─────────────────────────────────────────────────────────────
      
      # Append an event to the pulse stream
      # @param event [Hash] the event to append
      # @return [Hash] the event with hash fields added
      def append_event(event)
        event = event.transform_keys(&:to_sym)
        
        event_id = generate_event_id
        ts = Time.now.utc.iso8601(3)
        
        event[:event_id] = event_id
        event[:ts] = ts
        event[:prev_hash] = chain_head
        
        # Compute event hash
        canonical = JSON.generate(event.sort.to_h)
        event_hash = hash_sha256(canonical)
        event[:event_hash] = event_hash
        
        # Append to pulse log
        ensure_dir
        File.open(PULSE_LOG, 'a') do |f|
          f.puts(JSON.generate(event))
          f.flush
        end
        
        # Update merkle root
        update_merkle_root(event_id, event_hash)
        
        event
      end
      
      # Get current merkle root
      def get_merkle_root
        return nil unless File.exist?(MERKLE_FILE)
        raw = File.read(MERKLE_FILE)
        json_match = raw.match(/^\s*\{[\s\S]*^\s*\}/m)
        return nil unless json_match
        JSON.parse(json_match[0], symbolize_names: true)
      rescue
        nil
      end
      
      # Get chain head (last event hash)
      def chain_head
        return nil unless File.exist?(PULSE_LOG)
        last_line = File.readlines(PULSE_LOG).last&.strip
        return nil if last_line.nil? || last_line.empty?
        
        last_event = JSON.parse(last_line, symbolize_names: true)
        last_event[:event_hash]
      rescue
        nil
      end
      
      # Read all events
      def read_all
        return [] unless File.exist?(PULSE_LOG)
        File.readlines(PULSE_LOG).map do |line|
          JSON.parse(line.strip, symbolize_names: true)
        rescue JSON::ParserError
          nil
        end.compact
      end
      
      # Read events with filter
      def read(action: nil, actor: nil, path: nil, limit: nil)
        events = read_all
        
        events = events.select { |e| e[:action] == action.to_s } if action
        events = events.select { |e| e[:actor] == actor.to_s } if actor
        events = events.select { |e| e[:path] == path.to_s } if path
        events = events.last(limit) if limit
        
        events
      end
      
      # Get pulse statistics
      def stats
        events = read_all
        merkle = get_merkle_root
        
        actions = events.group_by { |e| e[:action] }.transform_values(&:count)
        
        {
          total: events.length,
          actions: actions,
          first_event_id: events.first&.dig(:event_id),
          last_event_id: events.last&.dig(:event_id),
          chain_head: chain_head,
          merkle_root: merkle&.dig(:root)
        }
      end
      
      # Verify pulse chain integrity
      def verify
        events = read_all
        return { valid: true, count: 0, errors: [] } if events.empty?
        
        errors = []
        events.each_with_index do |event, idx|
          # Verify prev_hash chain (skip first)
          if idx > 0
            prev_event = events[idx - 1]
            if event[:prev_hash] != prev_event[:event_hash]
              errors << { index: idx, event_id: event[:event_id], error: 'chain_broken' }
            end
          end
        end
        
        {
          valid: errors.empty?,
          count: events.length,
          errors: errors
        }
      end
      
      private
      
      # ─────────────────────────────────────────────────────────────
      # Hashing
      # ─────────────────────────────────────────────────────────────
      
      def hash_sha256(data)
        "sha256:#{Digest::SHA256.hexdigest(data.to_s)}"
      end
      
      # ─────────────────────────────────────────────────────────────
      # Merkle Tree
      # ─────────────────────────────────────────────────────────────
      
      def update_merkle_root(event_id, event_hash)
        events = read_all
        hashes = events.map { |e| e[:event_hash] }
        
        root = compute_merkle_tree(hashes)
        
        first_event_id = events.first&.dig(:event_id) || event_id
        
        merkle = {
          root: root,
          algorithm: 'sha256',
          scope: 'pulse',
          event_range: {
            from: first_event_id,
            to: event_id
          },
          chain_head: event_hash,
          count: hashes.length,
          ts: Time.now.utc.iso8601(3)
        }
        
        File.write(MERKLE_FILE, JSON.pretty_generate(merkle))
        sync_meta_merkle_root(merkle[:root])
        
        merkle
      end
      
      def compute_merkle_tree(hashes)
        return hash_sha256('') if hashes.empty?
        return hashes.first if hashes.length == 1
        
        layer = hashes.dup
        
        while layer.length > 1
          next_layer = []
          layer.each_slice(2) do |pair|
            combined = if pair.length == 2
              "#{pair[0]}#{pair[1]}"
            else
              "#{pair[0]}#{pair[0]}"  # Duplicate odd node
            end
            next_layer << hash_sha256(combined)
          end
          layer = next_layer
        end
        
        layer.first
      end
      
      # ─────────────────────────────────────────────────────────────
      # Utilities
      # ─────────────────────────────────────────────────────────────
      
      def ensure_dir
        FileUtils.mkdir_p(PULSE_DIR) unless Dir.exist?(PULSE_DIR)
      end

      def sync_meta_merkle_root(root)
        return if root.nil? || root.to_s.empty?
        FileUtils.mkdir_p(File.dirname(META_MERKLE_FILE))
        File.write(META_MERKLE_FILE, root.to_s + "\n")
      rescue StandardError
        # Keep pulse append non-fatal even if meta mirror is unavailable.
        nil
      end
      
      def generate_event_id
        ts = Time.now
        day = ts.yday.to_s.rjust(3, '0')
        year = (ts.year % 100).to_s.rjust(2, '0')
        time = ts.strftime('%H%M%S')
        seq = rand(0xFFFF).to_s(16).rjust(4, '0')
        "evt_#{year}.#{day}.#{time}_#{seq}"
      end
    end
  end
end

# CLI interface
if __FILE__ == $0
  case ARGV[0]
  when 'stats'
    puts JSON.pretty_generate(Vec3::Pulse.stats)
  when 'merkle'
    merkle = Vec3::Pulse.get_merkle_root
    puts merkle ? JSON.pretty_generate(merkle) : 'No merkle root yet'
  when 'verify'
    result = Vec3::Pulse.verify
    puts JSON.pretty_generate(result)
    exit(result[:valid] ? 0 : 1)
  when 'read'
    opts = {}
    opts[:action] = ARGV[1] if ARGV[1]
    opts[:limit] = ARGV[2].to_i if ARGV[2]
    Vec3::Pulse.read(**opts).each { |e| puts JSON.generate(e) }
  when 'tail'
    n = (ARGV[1] || 10).to_i
    Vec3::Pulse.read(limit: n).each { |e| puts JSON.generate(e) }
  when 'append'
    # Test append
    event = Vec3::Pulse.append_event({
      action: ARGV[1] || 'test',
      actor: ARGV[2] || 'cli',
      path: ARGV[3]
    })
    puts JSON.pretty_generate(event)
  else
    puts "Usage: ruby pulse.rb <stats|merkle|verify|read [action] [limit]|tail [n]|append [action] [actor] [path]>"
  end
end
# :: ∎
