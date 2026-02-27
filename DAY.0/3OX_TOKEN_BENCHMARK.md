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
# Ruby (chars/4 estimate)
ruby DAY.0/3OX_TOKEN_BENCHMARK.rb

# Python (tiktoken cl100k_base — exact GPT-4 counts)
python3 DAY.0/3OX_TOKEN_BENCHMARK.py
```

## Results (2026-02-27)

### tiktoken (exact GPT-4)

| Pair | Prose | Gensing | Savings |
|------|-------|---------|---------|
| Input-Process-Output | 43 tok | 56 tok | -30% |
| PiCO trace | 45 tok | 82 tok | -82% |
| File operation | 25 tok | 48 tok | -92% |
| Sparkfile header | 49 tok | 63 tok | -29% |
| Section delimiter ×1 | 15 tok | 3 tok | **80.0%** |
| Section delimiter ×10 | 61 tok | 39 tok | **36.1%** |
| Conversation end | 18 tok | 4 tok | **77.8%** |
| **TOTAL** | 256 tok | 295 tok | -15.2% |

### chars/4 (Ruby estimate)

| Pair | Savings |
|------|---------|
| Section delimiter ×1 | 88.9% |
| Conversation end | 90.0% |
| Section delimiter ×10 | 78.8% |
| Overall | 25.1% |

**Findings:**
- **:: ∎ and :: 𝜵** — 77–80% savings (tiktoken); use these for output
- **Unicode** (⊢⇨⟿▷ρφτ∙) — tokenize to 2–3 tokens each; avoid in high-frequency paths
- **98% claim** — applies to delimiter-only output, not full gensing flow
- **Recommendation:** Use delimiters (:: ∎, :: 𝜵) everywhere; use ρφτ/⊢⇨⟿▷ sparingly in config

### API runtime (priming + test question)

```bash
OPENAI_API_KEY=sk-... python3 DAY.0/3OX_TOKEN_BENCHMARK_API.py
```

| Variant | Total tokens | vs Prose |
|---------|--------------|----------|
| Prose | 311 | baseline |
| Gensing minimal (ASCII + :: ∎) | 210 | **32.5% savings** |
| Gensing full (Unicode) | 311 | 0% |

**Runtime finding:** ASCII gensing with :: ∎ delimiters saves ~32% when priming the model and asking a test question. Full Unicode gensing matches prose (no savings).

:: ∎
