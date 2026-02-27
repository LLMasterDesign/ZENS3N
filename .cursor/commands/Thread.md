# /thread Command
▛//▞▞ ⟦⎊⟧ :: ⧗-26.160 // THREAD ▞▞

▛//▞ Purpose:: Create a spool from the current conversation and initialize thread system

▛▞ Usage::
- `/thread` - Create spool from current conversation (extract scope/output from context)
- `/thread {project_name}` - Create spool with explicit project name
- `/thread {project_name} {scope}` - Create spool with project and scope
- `/thread {project_name} {scope} {output_class}` - Create spool with all parameters

:: ∎

## Behavior

**For `/thread` (no parameters):**
1. **Capture Conversation Context:**
   - Extract last N messages from current chat session
   - Analyze conversation for scope and output_class
   - Use default project name if not determinable

2. **Create Spool:**
   - Tool: `ruby !CMD.CENTER/7HE.VAULT/Threads/tools/create_spool_from_conversation.rb`
   - Creates: `!WORKDESK/{project}.spool`
   - Generates: Spool ID (`spl_01J...`)
   - Creates: Early thread package structure

3. **Add Conversation Data:**
   - Research Turns: User questions and findings from conversation
   - LLM Conversation Turns: AI responses and discussions
   - Preserves full conversation context

4. **Initialize Gate 1:**
   - Creates evidence for Identity and Scope Lock gate
   - Sets scope from conversation or explicit parameter
   - Sets output_class from conversation or explicit parameter
   - Evidence file: `.3ox/vec3/var/evidence/{spool_id}_g1.json`

5. **Create Receipts:**
   - Intake receipt: `!1N.3OX/{spool_id}.intake.json`
   - Pulse event: `vec3/var/pulse.jsonl`
   - Spool state: `vec3/var/spool.state.json`

**For `/thread {project_name}`:**
- Uses provided project name
- Extracts scope and output_class from conversation
- Follows same process as above

**For `/thread {project_name} {scope}`:**
- Uses provided project name and scope
- Extracts output_class from conversation
- Follows same process as above

**For `/thread {project_name} {scope} {output_class}`:**
- Uses all provided parameters
- No extraction needed
- Follows same process as above

## What Gets Created

### Spool File
- **Location:** `!WORKDESK/{project}.spool`
- **Content:** 
  - Project metadata
  - Scope declaration
  - Research Turns (from conversation)
  - LLM Conversation Turns (from conversation)
  - Design Planning section
  - Artifact tracking

### Early Thread Package
- **Location:** `!CMD.CENTER/7HE.VAULT/Threads/{thread_id}/`
- **Structure:**
  - `{thread_id}.md` - Main thread document (grows as gates pass)
  - `progress.json` - Completion tracking (starts at ~14%)
  - `artifacts/current/` - Continuous artifact collection
  - `manifest.json` - Package manifest
  - `deps.meta.json` - Dependency tracking
  - `receipts/receipt.chain.jsonl` - Receipt chain

### Evidence Files
- **Gate 1 Evidence:** `.3ox/vec3/var/evidence/{spool_id}_g1.json`
- **Contains:**
  - Spool ID
  - Scope declaration
  - Output class specification
  - Conversation capture status
  - Message count

### Receipts
- **Intake Receipt:** `!1N.3OX/{spool_id}.intake.json`
- **Pulse Event:** `vec3/var/pulse.jsonl` (append-only)
- **Spool Receipts:** `vec3/var/spool.receipts.jsonl` (append-only)

## Conversation Capture

### Format
The tool captures conversation in this structure:
```json
{
  "messages": [
    {
      "role": "user",
      "content": "User message text",
      "timestamp": "2026-01-15T..."
    },
    {
      "role": "assistant",
      "content": "AI response text",
      "timestamp": "2026-01-15T..."
    }
  ],
  "session_id": "session_01J...",
  "captured_at": "2026-01-15T..."
}
```

### Extraction Logic
- **Scope:** Extracted from first user message or conversation summary (first 100 chars if not explicit)
- **Output Class:** Defaults to "implementation" if not determinable
- **Project Name:** Uses provided parameter or extracts from conversation context

## Integration

### With Thread System
- Spool created in `!WORKDESK/`
- Thread package created early in `!CMD.CENTER/7HE.VAULT/Threads/`
- Gate 1 initialized with conversation-derived evidence
- Ready for gate evaluation workflow

### With .3ox System
- Uses `vec3/var/` for state management
- Uses `!1N.3OX/` for intake receipts
- Integrates with pulse system for event tracking
- Follows 7-gate promotion protocol

### With Cursor Chat
- Command detected in chat interface
- Conversation context automatically captured
- Returns spool_id for continued work
- Progress tracked in thread package

## Next Steps After Creation

1. **Check Status:**
   ```bash
   ruby !CMD.CENTER/7HE.VAULT/Threads/tools/thread_status.rb "{spool_id}"
   ```

2. **Collect Artifacts:**
   - Artifacts automatically collected to `artifacts/current/`
   - Use `collect_artifacts.rb` for manual collection

3. **Evaluate Gates:**
   ```bash
   ruby !CMD.CENTER/7HE.VAULT/Threads/tools/evaluate_gate.rb "{spool_id}" "G1_IDENTITY" "evidence.json"
   ```

4. **Monitor Progress:**
   - Check `progress.json` in thread package
   - See completion percentage (starts ~14%, grows to 100%)
   - Checkpoint snapshots at each gate

5. **Fold Thread (When Mature):**
   ```bash
   ruby !CMD.CENTER/7HE.VAULT/Threads/tools/fold_thread.rb "{spool_id}"
   ```

## Example

**User types:** `/thread "TelegramBot" "Build Telegram Elixir commo station" "deployed_service"`

**System:**
1. Captures current conversation
2. Creates spool: `!WORKDESK/TelegramBot.spool`
3. Creates thread package: `!CMD.CENTER/7HE.VAULT/Threads/thr_01J.../`
4. Adds conversation turns to spool
5. Initializes Gate 1 with evidence
6. Returns: `spool_id: spl_01J...`

**User continues:**
- Work on project → artifacts collected
- Evaluate gates → progress increases
- Check status → see maturity level
- Fold when ready → sealed thread package

## Notes

- **Manual Trigger:** No auto-detection - user explicitly calls `/thread` when ready
- **Early Thread Package:** Thread structure created immediately, not just at fold time
- **Progress Tracking:** Real-time completion percentage in `progress.json`
- **Checkpoint Snapshots:** Artifacts snapshotted at each gate to `artifacts/checkpoint_{gate}/`
- **Conversation Preserved:** Full conversation context captured in spool
- **Gate 1 Ready:** Evidence created for immediate gate evaluation

:: ∎
