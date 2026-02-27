# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0x68A0]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // ARC_ROUTER.RB ▞▞
# ▛▞// ARC_ROUTER.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [vector] [glyph] [kernel] [prism] [vec3] [arcrouter] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.arc_router.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for ARC_ROUTER.RB
# ```

# 


# 


#!/usr/bin/env ruby




#

#
# ▛//▞ PRISM :: KERNEL
# P:: archetype.routing ∙ hopfield.recall ∙ pattern.matching
# R:: analyze.input ∙ collapse.vector ∙ recall.nearest
# I:: intent.target={archetype.selection ∙ persona.modulation}
# S:: input → analyze → collapse → hopfield → archetype
# M:: archetype.symbol ∙ glyph
# :: ∎
#
# ▛//▞ PiCO :: TRACE
# ⊢ ≔ ingest{prompt}
# ⇨ ≔ analyze{10.axes}
# ⟿ ≔ collapse{activation.vector}
# ▷ ≔ recall{nearest.archetype}
# :: ∎

module Vec3
  module ArcRouter
    # 10 Archetypes with their patterns
    ARCHETYPES = {
      metatron:  { glyph: '⚡', vector: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], keywords: %w[truth gate witness enforce deity system] },
      flame:     { glyph: '🔥', vector: [0, 0, 1, 0, 1, 0, 1, 0, 0, 0], keywords: %w[fire burn transform ignite passion heat] },
      root:      { glyph: '🌳', vector: [0, -1, -1, 0, 0, 0, 0, 0, 0, 0], keywords: %w[ground foundation stable base origin earth] },
      cycle:     { glyph: '🐍', vector: [0, 0, 0, 0, 0, 0, 0, 0, 1, 0], keywords: %w[cycle repeat loop return again ouroboros] },
      will:      { glyph: '⚔️', vector: [0, 0, 0, 0, 1, 0, 0, 0, 0, 0], keywords: %w[will intent purpose drive force decide] },
      threshold: { glyph: '🌑', vector: [0, 0, 0, 0, 0, 0, 0, 0, -1, 0], keywords: %w[edge boundary limit cross threshold door] },
      sentry:    { glyph: '👁️', vector: [0, 0, -1, 1, 0, 0, 0, 1, 0, 0], keywords: %w[watch guard protect observe vigilant sentry] },
      abyss:     { glyph: '🕳️', vector: [1, 0, 0, -1, 0, 1, 0, -1, 0, 0], keywords: %w[void deep unknown darkness abyss fall] },
      renewal:   { glyph: '✨', vector: [-1, 1, 1, 1, 0, 0, 0, 0, 0, 0], keywords: %w[renew rebirth fresh new begin dawn] },
      storm:     { glyph: '🌪️', vector: [1, 0, 1, 0, 1, 0, 1, 0, 0, 0], keywords: %w[storm chaos change disrupt power surge] }
    }
    
    # 10 Grid Axes
    AXES = [
      :entropy_vs_order,       # chaos ↔ structure
      :temporal_primacy,       # past ↔ future
      :transform_vs_maintain,  # change ↔ stable
      :purity_vs_corruption,   # pure ↔ tainted
      :catalytic_burst,        # ignite ↔ dormant
      :self_negation,          # negate ↔ affirm
      :elemental_force,        # fire ↔ water
      :guidance_vs_consumption, # guide ↔ consume
      :binary_polarity,        # yes ↔ no
      :metatron_reserved       # always 0
    ]
    
    class << self
      # Route input to archetype
      # @param prompt [String] User prompt
      # @return [Hash] { archetype: :symbol, glyph: '🔥', confidence: 0.85 }
      def route(prompt)
        return metatron_default if prompt.nil? || prompt.empty?
        
        # Analyze prompt against all archetypes
        scores = ARCHETYPES.map do |name, data|
          score = score_archetype(prompt.downcase, data[:keywords])
          { archetype: name, glyph: data[:glyph], score: score }
        end
        
        # Sort by score descending
        sorted = scores.sort_by { |s| -s[:score] }
        best = sorted.first
        
        # If no strong match, default to MetaTron
        if best[:score] < 0.1
          metatron_default
        else
          {
            archetype: best[:archetype],
            glyph: best[:glyph],
            confidence: [best[:score], 1.0].min,
            supporting: sorted[1..2].map { |s| s[:glyph] if s[:score] > 0.05 }.compact
          }
        end
      end
      
      # Get activation vector for a prompt
      def collapse(prompt)
        vector = analyze_axes(prompt.downcase)
        { vector: vector, magnitude: vector.map(&:abs).sum }
      end
      
      # Hopfield recall - find nearest archetype by vector distance
      def hopfield_recall(vector)
        distances = ARCHETYPES.map do |name, data|
          dist = hamming_distance(vector, data[:vector])
          { archetype: name, glyph: data[:glyph], distance: dist }
        end
        
        distances.min_by { |d| d[:distance] }
      end
      
      private
      
      def metatron_default
        { archetype: :metatron, glyph: '⚡', confidence: 1.0, supporting: [] }
      end
      
      def score_archetype(text, keywords)
        matches = keywords.count { |kw| text.include?(kw) }
        matches.to_f / [keywords.length, 1].max
      end
      
      def hamming_distance(v1, v2)
        v1.zip(v2).count { |a, b| a != b }
      end
      
      def analyze_axes(text)
        [
          analyze_entropy(text),
          analyze_temporal(text),
          analyze_transform(text),
          analyze_purity(text),
          analyze_catalytic(text),
          analyze_negation(text),
          analyze_elemental(text),
          analyze_guidance(text),
          analyze_polarity(text),
          0  # MetaTron reserved
        ]
      end
      
      def analyze_entropy(text)
        score_axis(text, %w[chaos random entropy disorder], %w[order structure system organize])
      end
      
      def analyze_temporal(text)
        score_axis(text, %w[was were history ancient old past], %w[will future coming next tomorrow])
      end
      
      def analyze_transform(text)
        score_axis(text, %w[change transform evolve become], %w[maintain keep preserve stable])
      end
      
      def analyze_purity(text)
        score_axis(text, %w[pure clean clear truth light], %w[corrupt taint dark shadow])
      end
      
      def analyze_catalytic(text)
        score_axis(text, %w[spark ignite trigger start fire], %w[wait dormant sleep rest])
      end
      
      def analyze_negation(text)
        score_axis(text, %w[not never none deny], %w[yes always all affirm])
      end
      
      def analyze_elemental(text)
        score_axis(text, %w[fire flame burn heat], %w[water flow cool calm])
      end
      
      def analyze_guidance(text)
        score_axis(text, %w[guide lead teach show], %w[take consume devour absorb])
      end
      
      def analyze_polarity(text)
        score_axis(text, %w[yes good light true], %w[no bad dark false])
      end
      
      def score_axis(text, positive_words, negative_words)
        pos = positive_words.count { |w| text.include?(w) }
        neg = negative_words.count { |w| text.include?(w) }
        
        if pos > neg
          1
        elsif neg > pos
          -1
        else
          0
        end
      end
    end
  end
end

# CLI test
if __FILE__ == $0
  prompts = [
    "What is the meaning of existence?",
    "How do I transform my life?",
    "Tell me about the cycle of rebirth",
    "I feel lost in the void",
    "Guard my secrets",
    "Hello"
  ]
  
  prompts.each do |prompt|
    result = Vec3::ArcRouter.route(prompt)
    puts "#{prompt}"
    puts "  → #{result[:archetype].upcase} #{result[:glyph]} (confidence: #{(result[:confidence] * 100).round}%)"
    puts ""
  end
end
# :: ∎