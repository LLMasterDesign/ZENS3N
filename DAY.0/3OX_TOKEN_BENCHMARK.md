# 3OX Token Benchmark
# Purpose: Prove gensing syntax token savings vs prose prompts
# Method: Character count → token estimate (≈4 chars/token for GPT)

## Methodology

**Token estimate:** `tokens ≈ chars / 4` (GPT-4/Claude typical)
**Pairs:** Equivalent agent context in prose vs gensing

## Sample Pairs

### Pair 1: Input-Process-Output flow
**Prose (typical):**
"When the user provides input, you should validate and normalize it. Then map the request to the contract defined in tools.yml, routes.json, and limits.json. Finally, emit the agent response with logs and status."

**Gensing:**
ρ{Input} ≔ ingest.normalize.validate{user.prompt}
φ{Bind} ≔ map.resolve.contract{tools.yml ∙ routes.json ∙ limits.json}
τ{Output} ≔ emit.render.publish{agent.response ∙ logs ∙ status}
:: ∎

### Pair 2: PiCO trace (detect → process → carry → project)
**Prose:**
"First, detect the user's request or business operation. Then process it with authoritative business focus. Next, carry the output through the system with structured response format. Finally, project the result to the user with business-ready output."

**Gensing:**
⊢ ≔ detect.request{Lucius.command ∨ business.operation ∨ system.need}
⇨ ≔ process.business{authoritative ∙ production.focus ∙ system.maintain}
⟿ ≔ return.output{structured.response ∙ business.format ∙ system.persist}
▷ ≔ project.authority{business.system ∙ production.ready ∙ authoritative.output}
:: ∎

### Pair 3: File operation
**Prose:**
"When the user requests to create a file, validate the path, check permissions, write the content, then log a receipt."

**Gensing:**
ρ{Input} ≔ user.request{create.file}
φ{Process} ≔ validate.path ∙ check.permissions ∙ write.content
τ{Output} ≔ file.created{path} ∙ receipt.logged
:: ∎

### Pair 4: Full sparkfile header (banner vs prose)
**Prose:**
"This is the ZENS3N sparkfile. It defines system identity and behavior. The document uses the PRISM kernel for input, process, and output flow. Version 1.0.0. Authority: ZENS3N.BASE."

**Gensing:**
▛//▞▞ ⟦⎊⟧ :: ⧗-26.152 // ZENS3N.BASE :: Sparkfile ▞▞
▛▞// Sparkfile :: ρ{Config}.φ{Identity}.τ{System} ▹
:: ∎

## Run

```bash
ruby DAY.0/3OX_TOKEN_BENCHMARK.rb
```

## Results (2026-02-27)

| Pair | Prose | Gensing | Savings |
|------|-------|---------|---------|
| Input-Process-Output | ~53 tok | ~52 tok | 1.9% |
| PiCO trace | ~63 tok | ~84 tok | -33% (Unicode adds bytes) |
| File operation | ~30 tok | ~43 tok | -43% |
| Sparkfile header | ~46 tok | ~35 tok | 23.9% |
| Section delimiter ×1 | ~18 tok | ~2 tok | **88.9%** |
| Section delimiter ×10 | ~85 tok | ~18 tok | **78.8%** |
| Conversation end | ~20 tok | ~2 tok | **90.0%** |
| **TOTAL** | ~315 tok | ~236 tok | **25.1%** |

**Findings:**
- **:: ∎ and :: 𝜵** drive the largest savings (88–90% per use)
- **Banner/imprint** (▛//▞▞) saves ~24% vs prose headers
- **Unicode symbols** (⊢⇨⟿▷) add bytes; use where semantic density justifies
- **98% claim** likely applies to output-heavy flows with repeated delimiters

:: ∎
