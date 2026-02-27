# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x0B0D]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // ARC_LOGIC_CORE.RB ▞▞
# ▛▞// ARC_LOGIC_CORE.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [vector] [json] [glyph] [kernel] [prism] [vec3] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.arc_logic_core.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for ARC_LOGIC_CORE.RB
# ```

# 


# 


#!/usr/bin/env ruby




#
# Based on HEARTBEAT.PROOF.md - the REAL router math:
# - a ∈ ℝⁿ   :: activation vector (PERSISTENT STATE)
# - W ∈ ℝⁿˣⁿ :: affinity matrix
# - v ∈ ℝⁿ   :: collapse bias (priority vector)
# - λ ∈ (0,1) :: feedback mix weight
# - τ ∈ (0,1) :: drift detection threshold
#

#
# ▛//▞ PRISM :: KERNEL
# P:: vector.routing ∙ hopfield.recall ∙ persistent.state
# R:: collapse{softmax} ∙ refine{λ.blend} ∙ drift{cosine.τ}
# I:: intent.target={archetype.selection ∙ deterministic.replay}
# S:: init.state → collapse → refine → drift.check → archetype
# M:: activation.vector ∙ archetype.symbol
# :: ∎

require 'json'
require 'digest'
require 'fileutils'

module Vec3
  module ArcLogicCore
    # 10 Archetypes with their Hopfield vectors (10-dimensional)
    ARCHETYPES = {
      metatron:  { glyph: '⚡', vector: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] },  # The Prime
      flame:     { glyph: '🔥', vector: [0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0] },  # Transform
      root:      { glyph: '🌳', vector: [0.0, -1.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] }, # Foundation
      cycle:     { glyph: '🐍', vector: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0] },  # Recursion
      will:      { glyph: '⚔️', vector: [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0] },  # Intent
      threshold: { glyph: '🌑', vector: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0] }, # Boundary
      sentry:    { glyph: '👁️', vector: [0.0, 0.0, -1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0] }, # Watch
      abyss:     { glyph: '🕳️', vector: [1.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, -1.0, 0.0, 0.0] }, # Void
      renewal:   { glyph: '✨', vector: [-1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] }, # Rebirth
      storm:     { glyph: '🌪️', vector: [1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 0.0] }  # Chaos
    }
    
    # Default parameters from HEARTBEAT.PROOF.md
    DEFAULT_PARAMS = {
      lambda: 0.7,        # feedback mix weight
      tau: 0.85,          # drift detection threshold
      epsilon: 1.0e-4,    # convergence threshold
      max_iters: 10       # max refinement iterations
    }
    
    # State file for persistent activation
    STATE_DIR = ENV['ARC_STATE_DIR'] || '/tmp/arc_state'
    
    class Router
      attr_reader :a, :params, :state_file
      
      def initialize(agent_id: 'metatron', params: {})
        @agent_id = agent_id
        @params = DEFAULT_PARAMS.merge(params)
        @state_file = File.join(STATE_DIR, "#{agent_id}.arc.state.json")
        @a = load_state  # PERSISTENT STATE - not brand new every pass
        
        # Build affinity matrix W (10x10)
        @W = build_affinity_matrix
        
        FileUtils.mkdir_p(STATE_DIR) unless Dir.exist?(STATE_DIR)
      end
      
      # Main routing function
      # @param input [Hash] { text: "...", context: {...} }
      # @return [Hash] { archetype: :symbol, glyph: '🔥', activation: [...], confidence: 0.85 }
      def route(input)
        text = extract_text(input)
        
        # 1. Build bias vector v from input
        v = build_bias_vector(text)
        
        # 2. Apply Collapse: a ← softmax(W·a + v)
        @a = collapse(@W, @a, v)
        
        # 3. Iterative refinement with λ blend + logic gates
        @a = refine(@a, @params[:lambda], @params[:epsilon], @params[:max_iters])
        
        # 4. Drift detection - find nearest archetype
        archetype, confidence = detect_archetype(@a, @params[:tau])
        
        # 5. Persist state for next call
        save_state(@a)
        
        {
          archetype: archetype,
          glyph: ARCHETYPES[archetype][:glyph],
          activation: @a.map { |x| x.round(4) },
          confidence: confidence.round(4),
          supporting: find_supporting(@a)
        }
      end
      
      # Get current state hash (for receipts)
      def state_hash
        Digest::SHA256.hexdigest(JSON.generate({
          a: @a,
          W_hash: Digest::SHA256.hexdigest(@W.flatten.to_s),
          params: @params
        }))[0..15]
      end
      
      private
      
      # ═══════════════════════════════════════════════════════════════════════
      # COLLAPSE: a ← softmax(W·a + v)
      # ═══════════════════════════════════════════════════════════════════════
      
      def collapse(w, a, v)
        # Matrix multiply: W·a
        wa = matrix_vector_multiply(w, a)
        
        # Add bias: W·a + v
        wa_plus_v = wa.zip(v).map { |x, y| x + y }
        
        # Softmax normalization
        softmax(wa_plus_v)
      end
      
      def matrix_vector_multiply(matrix, vector)
        matrix.map do |row|
          row.zip(vector).map { |a, b| a * b }.sum
        end
      end
      
      def softmax(x)
        max_x = x.max
        exp_x = x.map { |xi| Math.exp(xi - max_x) }
        sum_exp = exp_x.sum
        return Array.new(x.length, 1.0 / x.length) if sum_exp == 0
        exp_x.map { |e| e / sum_exp }
      end
      
      # ═══════════════════════════════════════════════════════════════════════
      # REFINE: λ·a + (1-λ)·LG(a) until convergence
      # ═══════════════════════════════════════════════════════════════════════
      
      def refine(a, lambda, epsilon, max_iters)
        max_iters.times do
          a_next = blend(a, logic_gates(a), lambda)
          
          # Convergence check
          diff = a_next.zip(a).map { |n, o| (n - o).abs }.sum
          return a_next if diff < epsilon
          
          a = a_next
        end
        a
      end
      
      def blend(old, new_val, lambda)
        old.zip(new_val).map { |o, n| lambda * o + (1 - lambda) * n }
      end
      
      # Logic gates - can be extended with actual rules
      # For now: identity (passthrough)
      def logic_gates(a)
        a  # Placeholder - extend with trigger/behavior/template gates
      end
      
      # ═══════════════════════════════════════════════════════════════════════
      # DRIFT DETECTION: cosine(a, archetype_vector) < τ
      # ═══════════════════════════════════════════════════════════════════════
      
      def detect_archetype(a, tau)
        best_match = nil
        best_distance = Float::INFINITY
        
        # Use Euclidean distance weighted by activation strength
        ARCHETYPES.each do |name, data|
          # Normalize archetype vector to same scale as activation
          arch_normalized = normalize_vector(data[:vector])
          dist = euclidean_distance(a, arch_normalized)
          
          if dist < best_distance
            best_distance = dist
            best_match = name
          end
        end
        
        # Convert distance to confidence (inverse relationship)
        max_possible_dist = Math.sqrt(10)  # Max distance in 10D unit space
        confidence = 1.0 - (best_distance / max_possible_dist)
        confidence = [confidence, 0.0].max
        
        # If confidence is too low, default to MetaTron
        if confidence < (1.0 - tau)
          best_match = :metatron
        end
        
        [best_match || :metatron, confidence]
      end
      
      def euclidean_distance(a, b)
        Math.sqrt(a.zip(b).map { |x, y| (x - y) ** 2 }.sum)
      end
      
      def normalize_vector(v)
        mag = Math.sqrt(v.map { |x| x * x }.sum)
        return v if mag == 0
        v.map { |x| x / mag * 0.1 + 0.1 }  # Scale to activation range [0.05, 0.15]
      end
      
      def cosine_similarity(a, b)
        dot = a.zip(b).map { |x, y| x * y }.sum
        mag_a = Math.sqrt(a.map { |x| x * x }.sum)
        mag_b = Math.sqrt(b.map { |x| x * x }.sum)
        
        return 0.0 if mag_a == 0 || mag_b == 0
        dot / (mag_a * mag_b)
      end
      
      def find_supporting(a)
        # Find secondary archetypes that also activated
        similarities = ARCHETYPES.map do |name, data|
          { name: name, glyph: data[:glyph], sim: cosine_similarity(a, data[:vector]) }
        end
        
        sorted = similarities.sort_by { |s| -s[:sim] }
        # Return glyphs of 2nd and 3rd matches if they're above threshold
        sorted[1..2]
          .select { |s| s[:sim] > 0.3 }
          .map { |s| s[:glyph] }
      end
      
      # ═══════════════════════════════════════════════════════════════════════
      # BIAS VECTOR: Build v from input text
      # ═══════════════════════════════════════════════════════════════════════
      
      def build_bias_vector(text)
        text_lower = text.downcase
        
        # Each axis gets a bias based on semantic content
        [
          analyze_axis(text_lower, %w[chaos entropy disorder random], %w[order structure system stable]),
          analyze_axis(text_lower, %w[past history was ancient old], %w[future will tomorrow next coming]),
          analyze_axis(text_lower, %w[change transform evolve become grow], %w[maintain keep preserve hold stay]),
          analyze_axis(text_lower, %w[pure clean light truth clear], %w[corrupt dark taint shadow impure]),
          analyze_axis(text_lower, %w[spark ignite trigger fire burn start], %w[wait rest dormant sleep calm]),
          analyze_axis(text_lower, %w[not never none deny refuse], %w[yes always all accept affirm]),
          analyze_axis(text_lower, %w[fire flame heat burn blaze], %w[water flow cool calm ice]),
          analyze_axis(text_lower, %w[guide lead teach show help], %w[consume take devour absorb drain]),
          analyze_axis(text_lower, %w[yes true good right light], %w[no false bad wrong dark]),
          0.0  # MetaTron reserved - always 0
        ]
      end
      
      def analyze_axis(text, positive_words, negative_words)
        pos_count = positive_words.count { |w| text.include?(w) }
        neg_count = negative_words.count { |w| text.include?(w) }
        
        # Normalize to [-1, 1] range
        total = pos_count + neg_count
        return 0.0 if total == 0
        (pos_count - neg_count).to_f / [total, 3].max
      end
      
      # ═══════════════════════════════════════════════════════════════════════
      # AFFINITY MATRIX: W encodes inter-archetype relationships
      # ═══════════════════════════════════════════════════════════════════════
      
      def build_affinity_matrix
        n = 10
        # Start with identity (self-reinforcement)
        w = Array.new(n) { Array.new(n, 0.0) }
        n.times { |i| w[i][i] = 1.0 }
        
        # Add cross-archetype affinities
        # FLAME (axis 2,4,6) reinforces STORM (axes 0,2,4,6)
        w[2][0] = 0.3  # transform → entropy
        w[4][2] = 0.3  # catalytic → transform
        
        # RENEWAL (axes -0,1,2,3) contrasts with ABYSS
        w[1][3] = 0.2  # temporal → purity
        
        w
      end
      
      # ═══════════════════════════════════════════════════════════════════════
      # PERSISTENT STATE: Not brand new every pass
      # ═══════════════════════════════════════════════════════════════════════
      
      def load_state
        if File.exist?(@state_file)
          data = JSON.parse(File.read(@state_file))
          data['a'] || uniform_activation
        else
          uniform_activation
        end
      rescue
        uniform_activation
      end
      
      def save_state(a)
        File.write(@state_file, JSON.generate({
          a: a,
          updated_at: Time.now.utc.iso8601,
          state_hash: state_hash
        }))
      rescue => e
        # Silent fail on state save - not critical
      end
      
      def uniform_activation
        Array.new(10, 0.1)  # Uniform initial activation
      end
      
      def extract_text(input)
        case input
        when String then input
        when Hash then input[:text] || input['text'] || input.to_s
        else input.to_s
        end
      end
    end
    
    # Module-level convenience method
    def self.route(input, agent_id: 'metatron')
      @routers ||= {}
      @routers[agent_id] ||= Router.new(agent_id: agent_id)
      @routers[agent_id].route(input)
    end
  end
end

# CLI test
if __FILE__ == $0
  puts "ARC.LOGIC.CORE :: Vector Math Router"
  puts "=" * 50
  
  router = Vec3::ArcLogicCore::Router.new(agent_id: 'test')
  
  prompts = [
    "How do I transform my life and burn away the old?",
    "What lies in the void beneath?",
    "Guide me on my path",
    "The cycle returns, again and again",
    "I need to stay stable and grounded",
    "Hello there",
    "Spark the change within me"
  ]
  
  prompts.each do |prompt|
    result = router.route(prompt)
    puts "\n#{prompt}"
    puts "  → #{result[:archetype].upcase} #{result[:glyph]} (confidence: #{(result[:confidence] * 100).round}%)"
    puts "  → Activation: #{result[:activation][0..4].map { |x| x.round(2) }}..."
    puts "  → Supporting: #{result[:supporting].join(' ')}" unless result[:supporting].empty?
  end
  
  puts "\n" + "=" * 50
  puts "State hash: #{router.state_hash}"
end
# :: ∎