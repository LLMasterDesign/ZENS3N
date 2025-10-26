# PROTO V10SL - LINE ONE SPECIFICATION
## Banner Loader Definition (Public-Facing)

```
▛▞ ρ2 ▮▮▯▯▯ τ1 ν0 λ0 ▹
⊢ SPEC.DEFINE :: Banner loader grammar and validation
```

---

## PURPOSE

**Line One is the banner loader.** It's a visual boundary marker that signals "this file follows v10sl spec." The banner creates immediate context for both human readers and AI agents that this is a structured document with specific conventions.

**The Real Line One:**
```
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
```

### What It Accomplishes:
1. **File identity** - "This is a v10sl-formatted document"
2. **Visual boundary** - Clear separation from content
3. **Context anchor** - Scannable header for quick orientation
4. **Language-agnostic marker** - Works across Rust, Ruby, Markdown, TOML
5. **Comment compatibility** - Can be muted/commented per language needs

---

## GRAMMAR DEFINITION

```abnf
LINE-ONE         ::= COMMENT-PREFIX? BANNER-BODY
COMMENT-PREFIX   ::= "//" / "#" / (language-specific comment syntax)
BANNER-BODY      ::= SLASH-PREFIX OPENING-BLOCKS UNDERLINE-FILL

SLASH-PREFIX     ::= "/"
OPENING-BLOCKS   ::= "▙▖▙▖▞▞▙"
UNDERLINE-FILL   ::= "▂"+
```

**Base Pattern:**
```
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
```

**Character Breakdown:**
- `///` - Triple slash prefix (universal comment leader)
- `▙▖▙▖▞▞▙` - Opening block pattern (7 characters)
- `▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂` - Lower one-eighth block fill (20 characters)

**Total Length:** 30 characters

---

## SYMBOL REFERENCE

| Symbol | Name | Unicode | Purpose |
|--------|------|---------|---------|
| `/` | Solidus (slash) | U+002F | Comment prefix, universal |
| `▙` | Lower right quadrant | U+2599 | Opening block (left) |
| `▖` | Lower left quadrant | U+2596 | Opening block (accent) |
| `▞` | Upper right + lower left | U+259E | Opening block (pattern) |
| `▂` | Lower one-eighth block | U+2582 | Horizontal fill/underline |

---

## LANGUAGE-SPECIFIC IMPLEMENTATIONS

### Rust (Law Documents)

**Question:** Can banner stay as-is in Rust?

**Rust Comment Syntax:** `//` for single-line comments

**Option 1: Raw Banner (Proposed)**
```rust
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
// Legal document content begins here
```

**Option 2: Double-Slash Variant**
```rust
//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
// Legal document content begins here
```

**Consideration:** `///` in Rust is documentation comment syntax. Does this interfere with rustdoc generation? Or does it enhance discoverability?

**Research needed:**
- [ ] Does `///` banner break Rust compilation?
- [ ] Does it affect rustdoc output?
- [ ] Does it provide semantic benefit (doc marker)?

---

### Ruby (Code Documents)

**Question:** Does banner need to be muted in Ruby?

**Ruby Comment Syntax:** `#` for single-line comments

**Option 1: Hash-Prefixed Muted**
```ruby
#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
# Code begins here
```

**Option 2: Raw Banner (No Muting)**
```ruby
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
# Code begins here
```

**Consideration:** Ruby interpreter ignores non-code lines? Or does raw banner cause syntax error?

**Research needed:**
- [ ] Does raw banner break Ruby execution?
- [ ] Should it be muted with `#` prefix?
- [ ] Does muting reduce visual impact?

---

### Markdown (Documentation)

**Markdown Context:** No compilation, pure display

**Option 1: Raw Banner in Code Fence**
````markdown
```
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
```
# Document Title
````

**Option 2: Raw Banner (No Fence)**
```markdown
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

# Document Title
```

**Option 3: HTML Comment Wrapper**
```markdown
<!-- ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ -->

# Document Title
```

**Consideration:** Markdown is forgiving. Raw banner displays as text. Does it need special handling?

**Cursor Codex Fusion Context:**
- User notes Cursor's markdown codex is "clean for showcasing but missing v10 touch"
- How does banner integrate with code fence display?
- Should banner appear in rendered output or stay invisible?

---

### TOML (Receipt Files)

**TOML Comment Syntax:** `#` for comments

**Option 1: Hash-Prefixed**
```toml
#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

[receipt]
timestamp = "..."
```

**Option 2: Raw Banner**
```toml
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

[receipt]
timestamp = "..."
```

**Consideration:** TOML parsers are strict. Invalid lines cause parse errors.

**Research needed:**
- [ ] Does raw banner break TOML parsing?
- [ ] Must use `#` prefix for compatibility?

---

## USAGE PATTERNS

### Pattern 1: Universal Banner (Language-Agnostic)
```
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
```
**When:** Markdown, text files, language-agnostic contexts  
**Why:** Maximum visual impact, no muting needed

### Pattern 2: Muted Banner (Language-Aware)
```
#///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
```
**When:** Ruby, Python, TOML, or other `#`-comment languages  
**Why:** Ensures syntax compatibility

### Pattern 3: Double-Slash Banner (C-Family)
```
//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
```
**When:** C, C++, Java, JavaScript, Rust (if `///` causes issues)  
**Why:** Standard comment syntax for these languages

---

## VALIDATION RULES

A valid Line One must:

1. ✅ Appear as Line 1 of the file (before any other content)
2. ✅ Contains opening block pattern: `▙▖▙▖▞▞▙`
3. ✅ Contains underline fill: minimum 10× `▂` characters
4. ✅ Uses appropriate comment prefix for language context (if needed)
5. ✅ Total length: 27-40 characters (flexible underline length)
6. ✅ No trailing content on same line

**Invalid Examples:**

❌ Missing opening blocks:
```
///▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
```

❌ Wrong underline character:
```
///▙▖▙▖▞▞▙--------------------
```

❌ Trailing content:
```
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ <- This is a banner
```

---

## ARCHITECTURAL NOTES

### Public vs. Backend Distinction

**PUBLIC SPEC (v10sl):**
- Banner loader (this document)
- Language-aware formatting
- Universal file marker
- **GitHub-ready for release**

**BACKEND (Phenochain - Private):**
- Phase tracking notation (ρ, τ, ν, λ)
- Progress indicators (▮▯)
- Internal state management
- **NOT for public release** (secret sauce)

**Fusion:**
- This workspace documents both separately
- Public spec = clean, minimal, language-aware
- Backend spec = power-user notation for internal use
- Research shows effectiveness of each independently

---

## WHY THIS WORKS

### Hypothesis:
Visual distinctiveness + Unicode symbols create stronger file identity than ASCII comments, improving context retention and file recognition.

### Observed Benefits:

1. **Immediate Visual Identity**
   - Banner stands out in any editor
   - Instantly recognizable across file types
   - Creates "brand" for v10sl-formatted files

2. **Cross-Language Consistency**
   - Same visual pattern works in Rust, Ruby, Markdown, TOML
   - Language-specific muting (when needed) preserves identity
   - Universal "this is a spec file" signal

3. **Editor/AI Recognition**
   - LLMs can anchor on distinctive Unicode pattern
   - Human readers scan for banner to identify file type
   - Reduces "what kind of file is this?" overhead

4. **Minimal Overhead**
   - Single line (30 characters)
   - No runtime cost (it's a comment)
   - Language-agnostic or easily adapted

### Research Questions:

- [ ] Does banner improve AI file recognition across context windows?
- [ ] What's optimal underline length (20 chars vs. 30 chars)?
- [ ] Does muting (`#///` vs `///`) reduce effectiveness?
- [ ] How does this compare to traditional ASCII art headers?
- [ ] Does Rust `///` syntax provide semantic benefit for law docs?
- [ ] Should Markdown render banner or hide it?

---

## IMPLEMENTATION CHECKLIST

To finalize Line One spec, we need to:

### Rust Law Documents:
- [ ] Test `///` banner in Rust compiler
- [ ] Check rustdoc output with banner present
- [ ] Determine if banner breaks compilation
- [ ] **Decision:** Raw `///` or muted `//`?

### Ruby Code Documents:
- [ ] Test raw banner in Ruby interpreter
- [ ] Check if syntax error occurs
- [ ] Test muted `#///` variant
- [ ] **Decision:** Raw or muted?

### Markdown Docs:
- [ ] Test banner rendering in Cursor
- [ ] Test banner in Obsidian
- [ ] Test in GitHub markdown preview
- [ ] **Decision:** Raw, code fence, or HTML comment?

### TOML Receipts:
- [ ] Test raw banner with TOML parser
- [ ] Confirm `#///` variant works
- [ ] **Decision:** Must use muted form?

### Universal Guidelines:
- [ ] Create language-specific templates
- [ ] Document when to use which variant
- [ ] Build validator that checks language context
- [ ] Generate examples for each file type

---

## NEXT STEPS

1. **Test banner in each language context** (Rust, Ruby, Markdown, TOML)
2. **Document results** - what breaks, what works, what's optimal
3. **Create validation rules** per language
4. **Build Line One validator** that checks language-appropriate format
5. **Move to Line Two** (Imprint specification)

---

**Spec Version:** proto.v10sl  
**Line Defined:** Line One (Banner Loader)  
**Status:** Draft - Requires language testing  
**Public/Private:** PUBLIC SPEC  
**Research Status:** Hypothesis requires validation  
**Timestamp:** ⧗-25.60

:: ∎
