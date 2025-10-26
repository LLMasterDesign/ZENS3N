# File Watcher - Auto-Routing System
**⧗-25.61 | Step 2 Complete**

---

## 🎯 What It Does

**Automatically detects files in 0ut.3ox folders and triggers routing**

- Watches `FILE.MANIFEST.txt` for READY entries
- Auto-runs `router.py` when new files detected
- No manual intervention needed
- Background operation safe

---

## 🚀 How to Use

### Watch Mode (Continuous)
```powershell
# Watch every 10 seconds (default)
python !BASE.OPERATIONS\watcher.py --watch

# Watch every 5 seconds (faster)
python !BASE.OPERATIONS\watcher.py --watch 5

# Watch every 30 seconds (slower, less resource intensive)
python !BASE.OPERATIONS\watcher.py --watch 30
```

### Single Check (Testing)
```powershell
# Check once and exit
python !BASE.OPERATIONS\watcher.py --once
```

---

## 📊 What It Monitors

```
Stations:
- RVNx.BASE/!RVNX.OPS/0ut.3ox/FILE.MANIFEST.txt
- OBSIDIAN.BASE/!OBSIDIAN.OPS/0ut.3ox/FILE.MANIFEST.txt
- SYNTH.BASE/!SYNTH.OPS/0ut.3ox/FILE.MANIFEST.txt

Looks for: Lines with "| READY |" status
Triggers: router.py when count increases
```

---

## 🔄 Workflow

```
1. You drop file in 0ut.3ox/
2. You add entry to FILE.MANIFEST.txt with STATUS=READY
3. Watcher detects new READY entry (within interval)
4. Watcher auto-runs router.py
5. Router moves file + generates receipt
6. File arrives in BASE.OPS/INCOMING/
```

---

## 💡 Example Session

### Terminal Output:
```
👁️  File Watcher Started
==================================================
Monitor interval: 10 seconds
Watching: Station 0ut.3ox folders
Press Ctrl+C to stop

📡 Monitoring 3 station(s):
   - RVNx.BASE
   - OBSIDIAN.BASE
   - SYNTH.BASE

[14:23:15] ✓ Watching...
🆕 RVNx.BASE: 1 new file(s) detected
🚀 Triggering router...
--------------------------------------------------
🚀 3OX.Ai Transit Router
==================================================
📡 Found 3 enabled station(s)

🔍 Checking: RVNx.BASE
   Found 1 file(s) ready for transit
✓ Routed: my-report.md → rvnx/
  ↳ Receipt: my-report.md.receipt.md
  ↳ Archived to .SENT/2025-10-07/

==================================================
✅ Transit complete: 1 file(s) routed to BASE.OPS
--------------------------------------------------
✅ Router completed successfully

[14:23:30] ✓ Watching...
```

---

## 🛑 How to Stop

**Press `Ctrl+C`** in the terminal

Output:
```
✋ Watcher stopped by user
```

---

## ⚙️ Technical Details

### How It Works:
1. Loads station configs from `ROUTING.CONFIGS/`
2. Counts READY entries in each manifest
3. Tracks previous count vs current count
4. If count increased → new files detected
5. Triggers router.py via subprocess
6. Waits for interval, repeats

### State Tracking:
- Remembers last count for each station
- Only triggers on **increase** (not on first check)
- Resets state on watcher restart

### Resource Usage:
- **10 sec interval**: ~6 checks per minute
- **30 sec interval**: ~2 checks per minute
- Minimal CPU when idle (just file reads)

---

## 🎯 Integration with Current System

### Current Flow (Manual):
```
1. Drop file in 0ut.3ox/
2. Add to manifest
3. Run: python router.py
```

### With Watcher (Automatic):
```
1. Drop file in 0ut.3ox/
2. Add to manifest
3. Wait ~10 seconds
4. File automatically routed!
```

---

## 🔧 Deployment

### For Testing:
- Run from `!BASE.OPERATIONS/` (staging)
- Test with `--once` first
- Then try `--watch 30` (slow interval)

### For Production:
1. Test in BASE.OPERATIONS
2. Copy to `RVNx.BASE/!RVNX.OPS/!RUNTIME/`
3. RVNx runs it in background
4. Keep terminal open or use task scheduler

---

## 📋 Best Practices

### Recommended Intervals:
- **5 seconds**: If you need instant routing
- **10 seconds**: Good balance (default)
- **30 seconds**: Lower resource usage
- **60 seconds**: Very light background process

### When to Use:
- ✅ Active work sessions (lots of file movement)
- ✅ Automated workflows
- ✅ Multi-station coordination

### When NOT to Use:
- ❌ If no files moving (just run router manually)
- ❌ If testing routing changes (manual better)

---

## 🐛 Troubleshooting

**Watcher not detecting files?**
- Check manifest has `| READY |` status
- Verify station configs are enabled
- Try `--once` to see current state

**Router not triggering?**
- Check router.py exists in BASE.OPERATIONS
- Verify Python can run router
- Check terminal for error messages

**Too many triggers?**
- Increase interval: `--watch 30`
- Check manifest for duplicate entries

---

## 🔮 Future Enhancements

**Potential additions:**
- Watch for actual files (not just manifest)
- Email/notification on routing
- Web dashboard showing activity
- Scheduled routing windows
- Priority queue handling

---

## ✅ Step 2 Status: READY FOR TESTING

**Next:**
1. Test watcher with `--once`
2. Test watcher with `--watch 30`
3. Drop test file and see if it auto-routes
4. Deploy to RVNx runtime when ready

---

**Status:** Ready for Testing ⧗-25.61  
**Location:** !BASE.OPERATIONS/watcher.py (staging)  
**Integration:** Works with router.py (Step 1)

