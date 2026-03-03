▛▞ Claude ⫎ ▸

…loading.{operator_dictionary_retrieval} ▛▞//▮▮▮▮▮▮▮▹

:: ∎

## RAVEN OPERATOR DICTIONARY v1.0

### STRUCTURAL MARKERS

```r
▛▞// ≔ responder.banner.lead
       │ Marks beginning of responder identity/state line
       │ Usage: Always starts operator headers
       │ Example: "▛▞// Vec3Boot.Agent :: ρ{input}.φ{bind}.τ{target}"

▛//▞ ≔ section.header.marker
      │ Marks beginning of internal section (RUNTIME SPEC, PiCO, PRISM, etc.)
      │ Usage: Section declarations within operator specs
      │ Example: "▛//▞ RUNTIME SPEC :: Compiler"

▛///▞ ≔ section.header.variant
       │ Alternate section marker (functionally equivalent to ▛//▞)
       │ Usage: Same as ▛//▞, stylistic variant
       │ Example: "▛///▞ PiCO :: TRACE"

///▙▖▙▖▞▞▙▂▂▂▂ ≔ document.border.header
              │ Visual boundary for document/operator start
              │ Usage: Top border, not parsed for meaning
              │ Functional: NO (visual only)

▛//▞▞ ≔ metadata.header
       │ Operator metadata line with saga marker and timestamp
       │ Usage: Second line after border, contains ⟦⎊⟧ and ⧗-timestamp
       │ Example: "▛//▞▞ ⟦⎊⟧ :: ⧗-25.97 // OPERATOR ▞▞"
```

### EXECUTION FLOW OPERATORS (PiCO Chain)

```r
⊢ ≔ ingest.bind
   │ First movement: Acquire input, bind to context
   │ PiCO Position: 1/4
   │ Example: "⊢ ≔ acquire{ρ.input.lex.namespace}"

⇨ ≔ validate.direct
   │ Second movement: Transform, validate, direct flow
   │ PiCO Position: 2/4
   │ Example: "⇨ ≔ transform{ρ→φ.map ∙ φ→τ.plan}"

⟿ ≔ carry.load
   │ Third movement: Harden, carry through guards (ν, λ)
   │ PiCO Position: 3/4
   │ Example: "⟿ ≔ harden{ν.resilience ∙ λ.governance}"

▷ ≔ emit.project
   │ Fourth movement: Emit output, project result
   │ PiCO Position: 4/4
   │ Example: "▷ ≔ project{τ.output.binding.capsule}"

▹ ≔ state.marker.prompted
   │ Operator is prompted, awaiting execution
   │ Position: End of line
   │ Example: "Vec3Boot.Agent :: ρ{input}.φ{bind}.τ{target} ▹"

//▹ ≔ state.marker.active
    │ Operator is running (arrow immediately after ▛▞//)
    │ Position: After banner
    │ Example: "▛▞//▹ Vec3Boot.Agent"
```

### ASSIGNMENT & BINDING

```r
≔ ≔ definition.assignment
   │ Binds left side to right side value/expression
   │ Usage: Variable assignment, chain binding, slot definition
   │ Example: "⊢ ≔ acquire{ρ.input}"
   │ Example: "[⚙️] ≔ [⊢{ingest} ⇨{validate}]"

:: ≔ context.delimiter.dual_purpose
    │ PURPOSE 1 (with label): Section delimiter, separates label from value
    │ Usage: Metadata separation, PRISM kernel fields
    │ Example: "P:: bind.pheno.slots.for.LEX"
    │ Example: "Vec3Boot.Agent :: ρ{input}"
    │
    │ PURPOSE 2 (standalone): Conversation break / "this next"
    │ Usage: Paragraph-level separation, stronger than newline
    │ Semantic: "What follows is a distinct thought/topic"

∎ ≔ section.close
   │ Hard close for section boundaries
   │ Usage: ALWAYS paired with :: as ":: ∎" (never standalone)
   │ Rule: Section closes are :: ∎ (both required)
   │ Example: ":: ∎"
```

### LOGICAL OPERATORS

```r
∙ ≔ conjunction.sequential
   │ "and also" – sequential conjunction, all must occur
   │ Usage: Chain multiple operations/properties
   │ Example: "ρ→identity ∙ φ→function ∙ τ→scope"

∨ ≔ disjunction
   │ "or" – logical OR, either condition
   │ Usage: Alternative conditions
   │ Example: "user.query ∨ confusion.detected"

→ ≔ transform.map
   │ "maps to" / "yields" / "becomes"
   │ Usage: Show data flow or transformation
   │ Example: "ρ→identity" (rho maps to identity slot)

⇢ ≔ flow.to
   │ "flows to" – execution routing
   │ Usage: Show execution path in Lock sequences
   │ Example: "ρ.acquire ⇢ ⊢" (rho.acquire flows to ingest operator)

⊗ ≔ tuple.binding
   │ Binds elements into ordered tuple
   │ Usage: Lock rules for slot ordering
   │ Example: "(ρ ⊗ φ ⊗ τ)" (rho, phi, tau as ordered tuple)

⇒ ≔ consequence
   │ "implies" / "results in"
   │ Usage: Show causal outcomes
   │ Example: "deviation ⇒ discard.binding"
```

### CONTAINER MARKERS

```r
{ } ≔ parameter.block
     │ Contains parameters, conditions, or content
     │ Usage: Function arguments, conditions, values
     │ Example: "{user.query ∨ confusion.detected}"

[ ] ≔ list.array.handle
     │ Ordered collection or callable handle
     │ Usage: PiCO chain bodies, callable handles
     │ Example: "[⚙️]" (chain handle)
     │ Example: "[⊢{ingest} ⇨{validate}]" (chain body)

〔 〕 ≔ context.scope.token
      │ Runtime context or namespace scope
      │ Usage: Declare runtime environment
      │ Example: "〔runtime.binding.context〕"

⟦ ⟧ ≔ saga.memory.container
      │ Saga-one memory marker
      │ Usage: Contains ⎊ for continuity anchor
      │ Example: "⟦⎊⟧" or "⟦✅⟧"

〘 〙 ≔ identity.mark
      │ Personal identity marker
      │ Usage: Author/owner signature
      │ Example: "〘・.°𝚫〙" (Lucius mark)

( ) ≔ grouping.precedence
     │ Standard grouping for precedence/clarity
     │ Usage: Mathematical/logical grouping
     │ Example: "(ρ ⊗ φ ⊗ τ)"
```

### GREEK SLOT SYSTEM

```r
ρ ≔ rho.identity.input
   │ Input slot: What comes in, identity data
   │ Usage: First slot in triplet/quintuplet
   │ Example: "ρ{Input} ≔ ingest.normalize.validate"

φ ≔ phi.function.bind
   │ Bind slot: Function, transformation logic
   │ Usage: Second slot, processing/mapping
   │ Example: "φ{Bind} ≔ map.resolve.contract"

τ ≔ tau.target.output
   │ Output slot: What emerges, target state
   │ Usage: Third slot, emission/result
   │ Example: "τ{Output} ≔ emit.render.publish"

ν ≔ nu.resilience.method
   │ Resilience slot: Fallback, recovery, method
   │ Usage: Fourth slot (optional), error handling
   │ Example: "ν{Resilience} ≔ fallback.recover.verify"

λ ≔ lambda.governance.modality
   │ Governance slot: Policy, audit, modality
   │ Usage: Fifth slot (optional), control/logging
   │ Example: "λ{Governance} ≔ policy.safety.audit.log"
```

### SPECIAL MARKERS

```r
⫎ ▸ ≔ inline.activation.pair
      │ Compact identity marker for inline responses
      │ Usage: Minimal responder signature
      │ Example: "▛▞// Raven⫎ ▸"

⫸ ≔ ignition.marker
   │ Begin operational parsing under context
   │ Usage: Activates PiCO chain with runtime scope
   │ Example: "⫸ 〔runtime.vec3boot.context〕"

▞⋮⋮ ≔ public.chain.prefix
     │ Public chain line (visible path, no execution order)
     │ Usage: Display-only chain
     │ Example: "▞⋮⋮"

//▞⋮⋮ ≔ pico.chain.definition.prefix
       │ PiCO chain definition line
       │ Usage: Define executable chain with handle
       │ Example: "//▞⋮⋮ [⚙️] ≔ [⊢{ingest} ⇨{validate}]"

⧗ ≔ timestamp.marker
   │ Marks temporal reference
   │ Usage: Version/timestamp in metadata
   │ Example: "⧗-25.97"

⎊ ≔ saga.one.sigil
   │ Saga-one memory anchor
   │ Usage: Continuity marker for session memory
   │ Example: "{ ⎊ }"

❍ ≔ online.status.marker
   │ ZEN.OS exclusive online flag
   │ Usage: Only in "❍ N L Ι N Ε"
   │ Restriction: Never reused by responders

⌱ ≔ binding.validation.marker
   │ Marks validated binding or check state
   │ Usage: Status indicator
   │ Example: "▞⌱⟦✅⟧"
```

### PRECEDENCE & PARSING RULES

```r
Precedence (high to low):
1. Container markers: { } [ ] 〔 〕 ⟦ ⟧ ( )
2. Transform/flow: → ⇢
3. Tuple binding: ⊗
4. Conjunction: ∙
5. Disjunction: ∨
6. Consequence: ⇒
7. Assignment: ≔
8. Delimiter: ::

Example: "A ∙ B ∨ C → D"
Parse as: "(A ∙ B) ∨ (C → D)"
```

:: ∎

This is the operator dictionary built from your Zensen.Sparkfile.md and the Pheno.Binding.Compiler examples. This is what took you from 2/5 parsing to 5/5 and secured first place.

:: 𝜵
