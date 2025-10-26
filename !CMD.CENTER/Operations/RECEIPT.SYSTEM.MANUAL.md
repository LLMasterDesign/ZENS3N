# 📋 Transfer Receipt System - Captain's Manual
**⧗-25.61 | Simple Instructions**

---

## 🎯 What This System Does

**Simple version:** When you send a file from one station to another, include instructions for what to do with it.

**Like:** Handing someone a folder and saying "Review this and file it under Business Reports"

---

## 📤 How to Send a File with Instructions

### Step 1: Put File in Output Folder
```
RVNx.BASE/!RVNX.OPS/0ut.3ox/my-report.md
```

### Step 2: Create Receipt (Same Name + .receipt.md)
```
RVNx.BASE/!RVNX.OPS/0ut.3ox/my-report.md.receipt.md
```

### Step 3: Fill Out Receipt

**Copy this template:**

```markdown
# Transfer Receipt

FROM.OUT = RVNx.BASE/!RVNX.OPS/0ut.3ox/
TO.IN    = OBSIDIAN.BASE/in.3ox/
DATE     = 2025-10-07 14:23
STATUS   = PENDING

ACTION   = route_to_folder
TARGET   = (CAT.3) Business/Reports/
PRIORITY = high

FILES:
- my-report.md

NOTES:
Review this status report and integrate findings into weekly notes.
Next steps: Read → Create wiki links → Tag with #status #weekly

RESPONDER = synth.admin
```

### Step 4: Route It

**Option A - Manual:**
- Move both files to destination `in.3ox/` folder

**Option B - Automated:**
```powershell
python !BASE.OPERATIONS\router.py
```

---

## 📥 How to Receive Files with Instructions

### Step 1: Check Your Input Folder
```
OBSIDIAN.BASE/in.3ox/
```

### Step 2: Look for Receipt
```
my-report.md
my-report.md.receipt.md  ← Read this first!
```

### Step 3: Read NOTES Section
```
NOTES:
Review this status report and integrate findings into weekly notes.
Next steps: Read → Create wiki links → Tag with #status #weekly
```

**That's your task!** The receipt tells you exactly what to do.

### Step 4: Process the File
- Do what the NOTES say
- Move file to TARGET location
- Update STATUS in receipt to "DELIVERED"

---

## 📝 Receipt Fields Explained

### Required:
- **FROM.OUT** - Where file came from
- **TO.IN** - Where it's going
- **DATE** - When sent
- **STATUS** - Current state
- **NOTES** - What to do with it (MOST IMPORTANT)

### Optional:
- **ACTION** - Type of processing needed
- **TARGET** - Final destination path
- **PRIORITY** - How urgent (low/normal/high/urgent)
- **RESPONDER** - Who to alert if issues

---

## 🎯 Common Actions

```
route_to_folder → Move to specific folder
archive         → Store in archive
forward         → Pass to another station
hold            → Keep for review
scan_and_route  → AI decides where it goes
```

---

## ✨ Real Example

**Scenario:** You finish a business report in RVNx and want OBSIDIAN to file it

### File Location:
```
RVNx.BASE/!RVNX.OPS/0ut.3ox/Q4-revenue-report.md
```

### Receipt (Q4-revenue-report.md.receipt.md):
```markdown
# Transfer Receipt

FROM.OUT = RVNx.BASE/!RVNX.OPS/0ut.3ox/
TO.IN    = OBSIDIAN.BASE/in.3ox/
DATE     = 2025-10-07 16:45
STATUS   = PENDING

ACTION   = route_to_folder
TARGET   = (CAT.3) Business/Financial Reports/2025/Q4/
PRIORITY = high

FILES:
- Q4-revenue-report.md

NOTES:
This is the final Q4 revenue report. 
Next steps:
1. Review numbers for accuracy
2. Create summary note in daily log
3. Link to budget planning notes
4. Tag with #finance #q4 #2025

RESPONDER = synth.admin
```

### What Happens:
1. Both files get moved to `OBSIDIAN.BASE/in.3ox/`
2. AI (or you) in OBSIDIAN reads the receipt
3. Follows the 4 steps in NOTES
4. Moves to TARGET folder: `(CAT.3) Business/Financial Reports/2025/Q4/`
5. Updates STATUS to "DELIVERED"

---

## 🔄 Status Progression

```
PENDING     → File ready to send
IN_TRANSIT  → File moving
DELIVERED   → File arrived at destination
FAILED      → Something went wrong (alert RESPONDER)
```

---

## 📊 File Hash (Integrity Check)

**Optional but recommended:**

Add this to your receipt for verification:
```
FILE_HASH = abc123def456
FILE_SIZE = 4096
```

**Why?** Confirms file wasn't corrupted during transfer.

**How to generate:**
```powershell
# PowerShell
(Get-FileHash "filename.md" -Algorithm SHA256).Hash.Substring(0,16)
```

---

## 🎨 Obsidian Compatibility

**Yes!** Receipts are just `.md` files.

**In Obsidian:**
- Receipts show up as normal markdown notes
- You can read them in reading view
- Link to them from other notes
- Search them like any note

**Tip:** Add front matter for better organization:
```markdown
---
type: transfer-receipt
status: delivered
priority: high
---
# Transfer Receipt
...
```

---

## 🔧 For Non-Coders

**You don't need to code!**

### Manual Process (No Scripts):
1. Create receipt file (copy template)
2. Fill in the blanks
3. Copy both files to destination
4. Read receipt and do what it says

### Automated Process (With Scripts):
1. Create receipt file
2. Run: `python !BASE.OPERATIONS\router.py`
3. Script moves files and logs everything

**Both work!** Scripts just save time.

---

## 🚀 Quick Start Checklist

- [ ] Understand: Receipt = Instructions that travel with file
- [ ] Find your station's 0ut.3ox folder
- [ ] Copy receipt template
- [ ] Fill in FROM, TO, and NOTES (most important!)
- [ ] Put both file + receipt in 0ut.3ox
- [ ] Move to destination (manual or run router.py)
- [ ] Receiving station reads NOTES and does the task

---

## 📍 Where Things Live

```
3OX.Ai/.3ox.index/CORE/ROUTING/
├── transfer_receipt.rs          ← Rules (just for reference)
└── README.r                     ← Technical docs

SYNTH.BASE/!SYNTH.OPS/
├── .3OX.RECEIPT.TEMPLATE.md     ← Receipt template (use this!)
├── .3OX.RECEIPT.INSTRUCTIONS.md ← Detailed instructions
└── .3OX.TRANSFER.RECEIPT.md     ← Example receipt

!BASE.OPERATIONS/
├── router.py                    ← Script to move files
├── detector.py                  ← Script to detect arrivals
└── RECEIPT.SYSTEM.MANUAL.md     ← This file!

[STATION]/!{STATION}.OPS/
├── 0ut.3ox/                     ← Put files here to send
│   ├── file.md
│   └── file.md.receipt.md       ← Instructions travel with it
└── in.3ox/                      ← Files arrive here
```

---

## 🎯 Remember:

**The NOTES field is the magic** - that's where you say:
> "Do this or that next"

Everything else is just tracking and automation.

---

## 💡 Pro Tips

1. **Be specific in NOTES** - "Review report" vs "Read section 3, extract key metrics, add to dashboard"
2. **Use PRIORITY** - Helps receiving station know urgency
3. **Chain receipts** - For multi-hop transfers (RVNx → SYNTH → OBSIDIAN)
4. **Keep receipts** - Archive them for audit trail
5. **Add context** - Why this file matters, what decision it supports

---

## 🆘 Troubleshooting

**Q: File arrived but no receipt?**
A: Check if receipt traveled with it (same name + .receipt.md)

**Q: Receipt says FAILED?**
A: Contact RESPONDER listed in receipt

**Q: Don't know what to do with received file?**
A: Read the NOTES field - it tells you exactly

**Q: Need to send to multiple stations?**
A: Create separate receipts for each destination OR use ACTION=duplicate

---

**Status:** Ready to Use ⧗-25.61  
**Compatibility:** Obsidian ✓ | Manual Process ✓ | Automated ✓  
**Learning Curve:** 5 minutes to understand, copy template, go

---

**You're all set!** Start simple - send one file with a receipt, see how it feels.

