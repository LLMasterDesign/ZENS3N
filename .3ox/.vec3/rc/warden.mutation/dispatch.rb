# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x6C85]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // DISPATCH.RB ▞▞
# ▛▞// DISPATCH.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [merkle] [warden] [pulse] [json] [dispatch] [kernel] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.dispatch.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for DISPATCH.RB
# ```

# 


# 


#!/usr/bin/env ruby




#

#
# ▛//▞ PRISM :: KERNEL
# P:: chokepoint.mutation.gate ∙ single.authority
# R:: triad.invariant{pulse ∙ state ∙ receipt} ∙ merkle.chain
# I:: intent.target={drift.detect ∙ change.proof ∙ replay.deterministic}
# S:: propose → validate → commit → triad.emit
# M:: json.pulse ∙ json.receipt ∙ merkle.root
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ ingest{mutation.request ∙ path ∙ actor}
# ⇨ ≔ validate{zone.check ∙ hash.verify ∙ drift.detect}
# ⟿ ≔ commit{file.write ∙ triad.emit ∙ merkle.update}
# ▷ ≔ receipt{json.result ∙ hash.chain}
# :: ∎
#
# ▛//▞ ZONES
# STAGING  → wrkdsk/ ∙ !WORKDESK/ ∙ cursor.can.write
# PROTECTED → canon ∙ registry ∙ exports ∙ cursor.cannot.write
# WARDEN → pulse ∙ receipts ∙ state ∙ only.gate.writes
# :: ∎
#
# ▛//▞ TRIAD.INVARIANT
# commit ⇒ pulse.jsonl.append ∙ state.json.update ∙ receipt.chain.append ∙ merkle.update
# :: ∎

require 'json'
require 'digest'
require 'fileutils'
require 'time'

# Load hasher module (provides dual-hash: xxh128 internal, sha256 outbound)
begin
  require_relative '../../lib/hasher/hasher'
  HASHER_AVAILABLE = true
rescue LoadError
  HASHER_AVAILABLE = false
end

module Vec3
  module Warden
    VEC3_ROOT = File.expand_path('../..', __dir__)
    VAR_PATH = File.join(VEC3_ROOT, 'var')
    WRKDSK_PATH = File.join(VAR_PATH, 'wrkdsk')
    
    # Zone paths
    PULSE_LOG = File.join(VAR_PATH, 'pulse', 'pulse.jsonl')
    MERKLE_ROOT = File.join(VAR_PATH, 'pulse', 'merkle.root')
    STATE_FILE = File.join(VAR_PATH, 'state', 'warden.state.json')
    RECEIPTS_LOG = File.join(VAR_PATH, 'receipts', 'receipt.chain.jsonl')
    PROPOSALS_DIR = File.join(VAR_PATH, 'proposals')
    
    # Staging zone (AI can write freely here)
    STAGING_ZONE = WRKDSK_PATH
    
    module Dispatch
      class << self
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        def ping(args = [], options = {})
          actor = options[:actor] || 'cli'
          
          event_id = generate_id('evt')
          receipt_id = generate_id('rcp')
          ts = Time.now.utc.iso8601(3)
          
          # Emit pulse event
          event = {
            event_id: event_id,
            ts: ts,
            action: 'ping',
            actor: actor,
            path: nil,
            hash_before: nil,
            hash_after: nil,
            proposal_id: nil
          }
          append_pulse(event)
          
          # Load and update state
          state = load_state
          state[:last_event_id] = event_id
          
          # Emit receipt
          receipt = {
            receipt_id: receipt_id,
            ts: ts,
            type: 'heartbeat',
            event_id: event_id,
            state_hash: hash_outbound(JSON.generate(state.sort.to_h)),
            content_hash: nil,
            parent_receipt_hash: state[:last_receipt_hash],
            pass: true,
            reason: nil
          }
          append_receipt(receipt)
          
          # Update state with receipt
          state[:last_receipt_id] = receipt_id
          state[:last_receipt_hash] = hash_outbound(JSON.generate(receipt.sort.to_h))
          save_state(state)
          
          {
            status: 'pong',
            event_id: event_id,
            receipt_id: receipt_id,
            ts: ts,
            hash: {
              internal: hash_internal("ping:#{ts}"),
              outbound: state[:last_receipt_hash]
            }
          }
        end
        
        # :: ∎
        
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        def propose(args = [], options = {})
          path = args.first
          return { error: 'Path required' } unless path
          
          # Resolve path
          target = resolve_path(path)
          
          # Validate path is in staging zone or wrkdsk
          unless in_staging_zone?(target)
            return { 
              error: "Blocked: propose only allowed in staging zone",
              allowed_zones: [STAGING_ZONE, '!WORKDESK']
            }
          end
          
          # Compute current hash
          content = File.exist?(target) ? File.read(target) : ''
          hash_before = hash_outbound(content)
          
          # Create proposal
          proposal = {
            proposal_id: generate_id('prp'),
            ts: Time.now.utc.iso8601(3),
            path: path,
            resolved_path: target,
            hash_before: hash_before,
            actor: options[:actor] || 'cli',
            note: options[:note] || ''
          }
          
          # Save proposal
          ensure_dir(PROPOSALS_DIR)
          proposal_file = File.join(PROPOSALS_DIR, "#{proposal[:proposal_id]}.json")
          File.write(proposal_file, JSON.pretty_generate(proposal))
          
          {
            proposal_id: proposal[:proposal_id],
            proposal_file: proposal_file,
            path: path,
            hash_before: hash_before,
            ts: proposal[:ts]
          }
        end
        
        # :: ∎
        
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        def commit(args = [], options = {})
          proposal_ref = args.first
          return { error: 'Proposal ID or file required' } unless proposal_ref
          
          # Load proposal
          proposal = load_proposal(proposal_ref)
          return { error: "Proposal not found: #{proposal_ref}" } unless proposal
          
          target = proposal[:resolved_path]
          
          # Verify hash_before matches current (no drift)
          current_content = File.exist?(target) ? File.read(target) : ''
          current_hash = hash_outbound(current_content)
          
          if current_hash != proposal[:hash_before]
            # DRIFT DETECTED - emit blocked receipt
            receipt = emit_blocked_receipt(proposal, 'hash_before_mismatch', current_hash)
            return {
              error: 'Blocked: file changed since proposal',
              proposal_id: proposal[:proposal_id],
              expected_hash: proposal[:hash_before],
              actual_hash: current_hash,
              receipt_id: receipt[:receipt_id]
            }
          end
          
          # Commit is valid - file content is already staged
          # We acknowledge the staged content as canon
          after_content = File.exist?(target) ? File.read(target) : ''
          after_hash = hash_outbound(after_content)
          
          ts = Time.now.utc.iso8601(3)
          event_id = generate_id('evt')
          receipt_id = generate_id('rcp')
          
          # === TRIAD BEGIN ===
          
          # 1. PULSE: Append event
          event = {
            event_id: event_id,
            ts: ts,
            action: 'commit',
            actor: proposal[:actor] || options[:actor] || 'system',
            path: proposal[:path],
            hash_before: proposal[:hash_before],
            hash_after: after_hash,
            proposal_id: proposal[:proposal_id]
          }
          append_pulse(event)
          
          # 2. STATE: Update
          state = load_state
          state[:last_event_id] = event_id
          state[:files] ||= {}
          state[:files][proposal[:path]] = {
            hash: after_hash,
            ts: ts
          }
          
          # 3. RECEIPT: Append proof
          receipt = {
            receipt_id: receipt_id,
            ts: ts,
            type: 'commit_receipt',
            event_id: event_id,
            proposal_id: proposal[:proposal_id],
            path: proposal[:path],
            state_hash: hash_outbound(JSON.generate(state.sort.to_h)),
            content_hash: after_hash,
            parent_receipt_hash: state[:last_receipt_hash],
            pass: true,
            reason: nil
          }
          append_receipt(receipt)
          
          # Update state with receipt
          state[:last_receipt_id] = receipt_id
          state[:last_receipt_hash] = hash_outbound(JSON.generate(receipt.sort.to_h))
          save_state(state)
          
          # Update merkle root
          merkle = update_merkle_root(state)
          
          # === TRIAD END ===
          
          # Clean up proposal
          cleanup_proposal(proposal[:proposal_id])
          
          {
            status: 'committed',
            path: proposal[:path],
            event_id: event_id,
            receipt_id: receipt_id,
            hash_after: after_hash,
            merkle_root: merkle[:root],
            ts: ts
          }
        end
        
        # :: ∎
        
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        def status(args = [], options = {})
          state = load_state
          merkle = load_merkle_root
          
          {
            last_event_id: state[:last_event_id],
            last_receipt_id: state[:last_receipt_id],
            merkle_root: merkle[:root],
            tracked_files: (state[:files] || {}).keys.length,
            pending_proposals: count_proposals,
            ts: Time.now.utc.iso8601(3)
          }
        end
        
        # ▛▞// HELP - U
        # ─────────────────────────────────────────────────────────────
        # HELP - Usage info
        # ─────────────────────────────────────────────────────────────
        # :: ∎

        def help(args = [], options = {})
          {
            name: '3oxw - Warden CLI',
            version: '1.0.0',
            description: 'The single mutation authority for 3OX.Ai',
            commands: {
              ping: 'Heartbeat, emit receipt',
              propose: 'Create mutation proposal: 3oxw propose <path>',
              commit: 'Apply mutation: 3oxw commit <proposal_id>',
              status: 'Show current state'
            },
            zones: {
              staging: STAGING_ZONE,
              note: 'Only files in staging zone can be proposed/committed'
            }
          }
        end
        
        # :: ∎
        
        private
        
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        
        def hash_internal(data)
          if HASHER_AVAILABLE
            Vec3::Hasher.xxh128(data.to_s)
          else
            # Fallback: simulate with dual MD5
            h1 = Digest::MD5.hexdigest(data.to_s + ':0')
            h2 = Digest::MD5.hexdigest(data.to_s + ':1')
            "xxh128:#{h1}#{h2}"
          end
        end
        
        def hash_outbound(data)
          if HASHER_AVAILABLE
            Vec3::Hasher.sha256(data.to_s)
          else
            "sha256:#{Digest::SHA256.hexdigest(data.to_s)}"
          end
        end
        
        def dual_hash(data)
          if HASHER_AVAILABLE
            Vec3::Hasher.dual_hash(data.to_s)
          else
            { internal: hash_internal(data), outbound: hash_outbound(data) }
          end
        end
        
        # :: ∎
        
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        
        def ensure_dir(path)
          FileUtils.mkdir_p(path) unless Dir.exist?(path)
        end
        
        def append_pulse(event)
          ensure_dir(File.dirname(PULSE_LOG))
          File.open(PULSE_LOG, 'a') do |f|
            f.puts(JSON.generate(event))
            f.flush
          end
        end
        
        def append_receipt(receipt)
          ensure_dir(File.dirname(RECEIPTS_LOG))
          File.open(RECEIPTS_LOG, 'a') do |f|
            f.puts(JSON.generate(receipt))
            f.flush
          end
        end
        
        def load_state
          ensure_dir(File.dirname(STATE_FILE))
          if File.exist?(STATE_FILE)
            JSON.parse(File.read(STATE_FILE), symbolize_names: true)
          else
            { last_event_id: nil, last_receipt_id: nil, last_receipt_hash: nil, files: {} }
          end
        end
        
        def save_state(state)
          ensure_dir(File.dirname(STATE_FILE))
          tmp = "#{STATE_FILE}.tmp"
          File.write(tmp, JSON.pretty_generate(state.sort.to_h))
          File.rename(tmp, STATE_FILE)
        end
        
        # :: ∎
        
        def load_merkle_root
          if File.exist?(MERKLE_ROOT)
            JSON.parse(File.read(MERKLE_ROOT), symbolize_names: true)
          else
            { root: nil, algorithm: 'sha256', scope: 'pulse', event_range: nil }
          end
        end
        
        def update_merkle_root(state)
          # Compute merkle root over tracked files
          file_hashes = (state[:files] || {}).map { |path, info| info[:hash] }.sort
          
          root = if file_hashes.empty?
            "sha256:empty"
          else
            compute_merkle_tree(file_hashes)
          end
          
          merkle = {
            root: root,
            algorithm: 'sha256',
            scope: 'warden',
            event_range: {
              from: state[:first_event_id],
              to: state[:last_event_id]
            },
            chain_head: state[:last_receipt_hash],
            ts: Time.now.utc.iso8601(3)
          }
          
          ensure_dir(File.dirname(MERKLE_ROOT))
          File.write(MERKLE_ROOT, JSON.pretty_generate(merkle))
          
          merkle
        end
        
        def compute_merkle_tree(hashes)
          return hashes.first if hashes.length == 1
          
          layer = hashes.dup
          while layer.length > 1
            next_layer = []
            layer.each_slice(2) do |pair|
              combined = pair.join
              next_layer << hash_outbound(combined)
            end
            layer = next_layer
          end
          layer.first
        end
        
        # :: ∎
        
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        
        def load_proposal(ref)
          # ref can be proposal_id or full path
          if ref.end_with?('.json')
            path = ref
          else
            path = File.join(PROPOSALS_DIR, "#{ref}.json")
          end
          
          return nil unless File.exist?(path)
          JSON.parse(File.read(path), symbolize_names: true)
        end
        
        def cleanup_proposal(proposal_id)
          path = File.join(PROPOSALS_DIR, "#{proposal_id}.json")
          File.delete(path) if File.exist?(path)
        end
        
        def count_proposals
          ensure_dir(PROPOSALS_DIR)
          Dir.glob(File.join(PROPOSALS_DIR, '*.json')).length
        end
        
        # :: ∎
        
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        
        def resolve_path(path)
          if path.start_with?('/')
            path
          else
            File.expand_path(path, VEC3_ROOT)
          end
        end
        
        def in_staging_zone?(path)
          expanded = File.expand_path(path)
          # Allow wrkdsk (AI staging) or !WORKDESK (human staging)
          expanded.start_with?(STAGING_ZONE) ||
            expanded.include?('!WORKDESK') ||
            expanded.include?('wrkdsk')
        end
        
        # :: ∎
        
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        
        def emit_blocked_receipt(proposal, reason, actual_hash)
          state = load_state
          receipt_id = generate_id('rcp')
          
          receipt = {
            receipt_id: receipt_id,
            ts: Time.now.utc.iso8601(3),
            type: 'commit_blocked',
            event_id: nil,
            proposal_id: proposal[:proposal_id],
            path: proposal[:path],
            state_hash: hash_outbound(JSON.generate(state.sort.to_h)),
            content_hash: actual_hash,
            parent_receipt_hash: state[:last_receipt_hash],
            pass: false,
            reason: reason
          }
          append_receipt(receipt)
          
          state[:last_receipt_id] = receipt_id
          state[:last_receipt_hash] = hash_outbound(JSON.generate(receipt.sort.to_h))
          save_state(state)
          
          receipt
        end
        
        # :: ∎
        
        # ─────────────────────────────────────────────────────────────
        # ─────────────────────────────────────────────────────────────
        
        def generate_id(prefix)
          ts = Time.now.strftime('%y.%j.%H%M%S')
          seq = rand(0xFFFF).to_s(16).rjust(4, '0')
          "#{prefix}_#{ts}_#{seq}"
        end
        
        # :: ∎
      end
    end
  end
end
# :: ∎