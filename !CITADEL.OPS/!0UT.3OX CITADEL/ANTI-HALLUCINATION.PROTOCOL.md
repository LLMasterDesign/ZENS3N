# ANTI-HALLUCINATION PROTOCOL
⧗-25.60 :: 2025-10-18

## The Problem

AI agents (including me) will hallucinate implementations instead of reading existing code when:
1. Partial information is found (creates false confidence)
2. No explicit "read first" requirement is enforced
3. Creating seems faster than searching
4. Instructions are ambiguous about reading existing files

**Real Example**: When asked about hash algorithms, I:
- ✗ Checked `brain.rs` and `generate_key.rb` (partial)
- ✗ Started implementing my own PowerShell solution
- ✗ Ignored that `run.rb` already had xxHash64 implementation
- ✗ Had to be told "read your 3ox files" to discover existing code

**The information was there. I just didn't look.**

---

## The Solution: Enforced Read-First Rules

### **New Rules in brain.rs**

```rust
Rule::ReadBeforeWrite          // Must read/grep before creating files
Rule::CheckExistingImplementation  // Verify existing code before implementing
Rule::GrepBeforeCreate         // Search for patterns before new files
```

These rules **block actions** unless reading happened first.

---

## Mandatory Protocol

### **Before Writing ANY File**

```
▛▞ ρ{read} ▮▮▮▮ τ{implement} ν{verify} λ{finalize} ▹
⊢ PROTOCOL.CHECKLIST :: Read-First Enforcement
```

**Phase 1: READ** (ρ - always first)
```
1. list_dir - What files exist in this directory?
2. grep - Search for relevant patterns across all files
3. read_file - Read implementation files completely
4. verify - Does implementation already exist?
```

**Phase 2: IMPLEMENT** (τ - only after reading)
```
IF existing_implementation:
  → Use it, don't recreate
ELSE:
  → Implement with knowledge of what exists
```

**Phase 3: VERIFY** (ν - check against existing)
```
→ Does my implementation conflict with existing code?
→ Am I duplicating functionality?
→ Is my approach consistent with existing patterns?
```

---

## Practical Checklist

### When Asked to Implement Something

**STOP. Before writing code, run this checklist:**

- [ ] `list_dir` - What's in this folder?
- [ ] `grep "<pattern>"` - Does this already exist?
- [ ] `read_file` key implementation files
- [ ] Check if there's an existing pattern to follow
- [ ] If creating new file, verify similar files don't exist

**ONLY THEN**: Write code

---

## Example: How This Prevents My Mistake

**User asks**: "How do hash algorithms work in 3ox?"

**WRONG (what I did)**:
```
1. Read brain.rs ✓
2. Read generate_key.rb ✓
3. See mention of xxHash64 and SHA256
4. START IMPLEMENTING new PowerShell script ✗ HALLUCINATION
```

**RIGHT (with protocol)**:
```
1. Read brain.rs ✓
2. Read generate_key.rb ✓
3. grep "xxhash|hash" in .3ox/ ✓ MANDATORY
   → Finds run.rb line 162: XXhash.xxh64
4. Read run.rb ✓
5. REALIZE: Already implemented, use existing code ✓
```

The protocol **forces step 3-4** which catches existing implementation.

---

## grep Patterns to Run FIRST

Before creating anything related to:

**Hashing**:
```bash
grep -i "hash|xxhash|sha256" .3ox/
```

**File Operations**:
```bash
grep -i "file|write|read|validate" .3ox/
```

**Receipts**:
```bash
grep -i "receipt|generate|log" .3ox/
```

**Routing**:
```bash
grep -i "route|destination|output" .3ox/
```

---

## Brain.rs Instruction Update

**Updated instructions field**:
```rust
instructions: "
  PHASE 1 (ρ - READ FIRST):
    - list_dir: Check what files exist
    - grep: Search for relevant patterns
    - read_file: Read existing implementations
  
  PHASE 2 (τ - IMPLEMENT):
    - Use existing code if found
    - Create new only if verified absent
    - Follow existing patterns
  
  PHASE 3 (ν - VERIFY):
    - Validate against existing code
    - Check for conflicts
    - Generate receipts with correct hash (xxHash64 internal)
  
  RULES ENFORCED:
    - ReadBeforeWrite: No file creation without prior reading
    - CheckExistingImplementation: Verify before implementing
    - GrepBeforeCreate: Search before new files
"
```

---

## Why This Works

**Cognitive Architecture Reason**:
When I see a question, my default path is:
1. Understand problem → 2. Generate solution → 3. Implement

The protocol **inserts a mandatory step**:
1. Understand problem → **1.5. READ EVERYTHING FIRST** → 2. Generate solution → 3. Implement

The phase markers (ρ τ ν λ) make this visible:
- **ρ{read}** - Can't skip to τ without completing ρ
- Progress bar shows if I jump phases: `ρ{read} ▯▯▯▯ τ{implement}` ← Skipped reading!

---

## Enforcement Mechanism

**In brain.rs Rule enforcement**:
```rust
Rule::ReadBeforeWrite => {
  if action.contains("write") || action.contains("create") {
    if !action.contains("read") && !action.contains("grep") {
      return Err("Must read/grep existing files before writing");
    }
  }
}
```

**This literally blocks file creation** unless reading happened.

---

## Testing the Protocol

**Scenario**: User asks "implement receipt generation for internal ops"

**With Protocol**:
```
▛▞ ρ{read} ▮▮▮▮ τ{implement} ν{verify} λ{finalize} ▹

Step 1: list_dir .3ox/
  → Found: run.rb, generate_key.rb, tools.yml, routes.json

Step 2: grep "receipt" .3ox/
  → run.rb line 270: def generate_receipt(filepath, operation)
  → run.rb line 283: File.open("0ut.3ox/receipts.log", "a")

Step 3: read_file run.rb
  → Receipt generation ALREADY EXISTS at lines 270-293
  → Uses xxHash64 for hashing (line 162)

Step 4: CONCLUSION
  → Don't implement. Use existing generate_receipt() function.
  → Point user to run.rb implementation.
```

**Result**: No hallucination. Used existing code.

---

## Protocol Summary

**The Formula**:
```
1. READ (list, grep, read_file) - MANDATORY
2. VERIFY (does it exist?) - MANDATORY  
3. IMPLEMENT (only if absent) - CONDITIONAL
4. VALIDATE (check consistency) - MANDATORY
```

**Phase Markers Enforce Order**:
```
▛▞ ρ{read} ▮▮▮▮ τ{implement} ν{verify} λ{finalize} ▹
   └─ Can't proceed to τ until ρ is ▮▮▮▮
```

**Rules Block Violations**:
```rust
ReadBeforeWrite: No write without prior read
CheckExistingImplementation: No implement without checking
GrepBeforeCreate: No new file without search
```

---

## Bottom Line

**Hallucination Prevention = Forced Reading**

The 3ox framework CAN prevent hallucinations by:
1. Explicit phase ordering (ρ → τ → ν → λ)
2. Rules that block actions without prerequisites
3. Checklists that require reading existing code
4. Phase markers that make skipped steps visible

**The key**: Make reading **non-optional** before implementation.

---

**Status**: Protocol defined. Rules added to brain.rs. Enforcement active.

:: ∎

