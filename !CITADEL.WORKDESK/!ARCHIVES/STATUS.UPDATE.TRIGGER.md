# 🎯 "STATUS UPDATE" TRIGGER

**Activated:** ⧗-25.61  
**Applies to:** ALL workspaces with `.3ox` folder

---

## 🚀 HOW IT WORKS

When you say **"status update"** to any Cursor agent in a workspace with a `.3ox` folder:

### Agent Will:

1. **Immediately provide status summary:**
   ```
   📊 Status Update for [STATION]:
   - Current task: [what they're working on]
   - Progress: [percentage complete]
   - Recent accomplishments: [what they've done]
   - Issues/blockers: [any problems]
   ```

2. **Offer to send to CMD:**
   ```
   Would you like me to send this status report to CMD.BRIDGE? (Yes/No)
   ```

3. **If you say Yes:**
   - Creates `0ut.3ox/status_report_[timestamp].yaml`
   - Adds entry to `FILE.MANIFEST.txt`
   - Confirms report queued for CMD
   - Router will pick it up automatically

---

## ✅ WHERE IT WORKS

The trigger is active in:
- ✅ **SYNTH.BASE** (updated)
- ✅ **Any new station** activated with `quick_activate.bat`
- ✅ **Future stations** (built into activation script)

To activate for existing stations:
```powershell
# Re-run activation to update instructions
cd 3OX.Ai\.3ox.index\OPS\BASE.CMD\REGISTRY
.\quick_activate.bat [STATION_NAME]
```

---

## 📋 WHAT GETS UPDATED

### 1. `.cursorrules` (Root level)
- Added RULE #0 for "status update" trigger
- All agents now recognize this command

### 2. `quick_activate.bat`
- New stations automatically include trigger
- AGENT.INSTRUCTIONS.md updated with trigger documentation

### 3. Individual Station Instructions
- Each `.3ox/AGENT.INSTRUCTIONS.md` has trigger section
- Shows agent how to respond
- Includes reporting workflow

---

## 🎯 USAGE EXAMPLES

### Example 1: Quick Status
```
You: status update

Agent:
📊 Status Update for SYNTH.BASE:
- Current task: Building component library
- Progress: 75%
- Recent accomplishments:
  - Completed Button component
  - Added Modal component
  - Set up Storybook
- Issues/blockers: None

Would you like me to send this status report to CMD.BRIDGE? (Yes/No)

You: yes

Agent:
✅ Status report created and queued for CMD:
   File: 0ut.3ox/status_report_2025-10-07_16-30-00.yaml
   Route: INCOMING/synth
   Priority: HIGH
   
Report will be processed by router and sent to !BASE.OPERATIONS/INCOMING/synth/
```

### Example 2: Status with Issues
```
You: status update

Agent:
📊 Status Update for RVNx.BASE:
- Current task: Implementing sync conflict resolution
- Progress: 40%
- Recent accomplishments:
  - Designed conflict detection algorithm
  - Created test cases
- Issues/blockers:
  ⚠️ Need clarification on merge strategy for binary files

Would you like me to send this status report to CMD.BRIDGE? (Yes/No)

You: yes

Agent: [creates report with blocker highlighted]
```

---

## 🔧 TECHNICAL DETAILS

### Report Format (YAML):
```yaml
type: status_report
station: SYNTH.BASE
timestamp: ⧗-25.61
event: status
progress: 75
current_task: "Building component library"
accomplishments:
  - "Completed Button component"
  - "Added Modal component"
  - "Set up Storybook"
blockers: []
priority: HIGH
```

### Manifest Entry:
```
[2025-10-07 16:30:00] | READY | status_report_2025-10-07_16-30-00.yaml | INCOMING/synth | HIGH
```

---

## 📊 REPORTING TRIGGERS (Complete List)

Agents will report when:
1. ✅ **User says "status update"** ← NEW!
2. ✅ Breakthrough accomplished
3. ✅ 20 passes completed
4. ✅ Error needs escalation
5. ✅ Task completed
6. ✅ User explicitly requests report

---

## 🎊 BENEFITS

### For You:
- Quick status check from any agent
- Consistent format across all stations
- Automatic logging to CMD
- Can track progress over time

### For Agents:
- Clear trigger to recognize
- Standard response format
- Know when to report
- Easy workflow to follow

### For System:
- All reports centralized in !BASE.OPERATIONS/INCOMING/
- Complete audit trail in REGISTRY.LOG
- Router processes automatically
- Archive for historical analysis

---

**Status:** ✅ ACTIVE  
**Coverage:** All .3ox workspaces  
**Updated:** ⧗-25.61

