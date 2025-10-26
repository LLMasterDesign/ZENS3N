# 🚀 COMPLETE PIPELINE QUICKSTART

**The full file lifecycle from station → Lighthouse → production**

---

## 📋 THE COMPLETE PIPELINE

```
Station Work → 1n.3ox → WORKDESK → 0ut.3ox → Git → CMD → Lighthouse → VAULT
```

---

## 🎯 STEP-BY-STEP GUIDE

### **STEP 1: Receive Files** (At Station)
```powershell
cd RVNx.BASE\1n.3ox
powershell .\intake.ps1
```
**What happens:**
- ✅ File moved from `1n.3ox` → `WORKDESK/INBOX`
- ✅ SHA256 receipt generated
- ✅ File validated

---

### **STEP 2: Do Your Work** (At Station)
```powershell
cd ..\WORKDESK\INBOX
# Edit files, process them, refine them
# When done, move to COMPLETE/
move your_file.md ..\COMPLETE\
```
**Manual step:** Work on files in WORKDESK/INBOX, then move to COMPLETE/ when done.

---

### **STEP 3: Ship to Out** (At Station)
```powershell
cd ..\WORKDESK
powershell .\c.ship_to_out.ps1
```
**What happens:**
- ✅ Files moved from `COMPLETE/` → `0ut.3ox/`
- ✅ SHA256 receipt generated
- ✅ Manifest entry created
- ✅ Ready for Git transit

---

### **STEP 4: Push to Git** (At Station)
```powershell
cd ..\0ut.3ox
.\push_to_git.bat
```
**What happens:**
- ✅ Files committed to Git
- ✅ Pushed to GitHub
- ✅ Git commit hash = receipt
- ✅ Files archived to `.SENT/`

---

### **STEP 5: Distribute from CMD** (At CMD.BRIDGE)
```powershell
cd P:\!CMD.BRIDGE\!BASE.OPERATIONS
powershell .\c.distribute.ps1
```
**What happens:**
- ✅ Scans all station `0ut.3ox` folders
- ✅ Validates SHA256 receipts
- ✅ Copies files to Lighthouse `LIBRARY/FROM-[station]/`
- ✅ Creates distribution receipts
- ✅ Archives originals

---

### **STEP 6: Seal Documents** (At Lighthouse)
```powershell
cd "P:\!CMD.BRIDGE\OBSIDIAN.BASE\(CAT.7) 7HE LIGHTHOUSE"
powershell .\c.seal.ps1
```
**What happens:**
- ✅ Select file from LIBRARY
- ✅ Generate final SHA256 seal
- ✅ Create seal certificate
- ✅ Copy to VAULT/
- ✅ Mark as PRODUCTION READY

---

## 📁 FILE LOCATIONS AT EACH STAGE

```
Stage 1: 1n.3ox/
  └── incoming_file.md

Stage 2: WORKDESK/INBOX/
  └── incoming_file.md (+ receipt)

Stage 3: WORKDESK/COMPLETE/
  └── refined_file.md

Stage 4: 0ut.3ox/
  └── refined_file.md (+ receipt + manifest entry)

Stage 5: Git
  └── [GitHub repository with commit hash]

Stage 6: Lighthouse/LIBRARY/FROM-RVNx/
  └── refined_file.md (+ distribution receipt)

Stage 7: Lighthouse/VAULT/
  └── refined_file.md (+ SEAL certificate + seal.yaml)
```

---

## 🎬 COMPLETE EXAMPLE RUN

### Starting Point: File arrives at RVNx.BASE

```powershell
# 1. Receive the file
cd P:\!CMD.BRIDGE\RVNx.BASE\1n.3ox
echo "Hello 3OX System" > test_doc.md
powershell .\intake.ps1

# Output:
# ✅ 1N.3OX WORKS!
# Receipt: 6A10890B...
# File moved to WORKDESK/INBOX/

# 2. Work on the file
cd ..\WORKDESK\INBOX
notepad test_doc.md  # Edit and improve
move test_doc.md ..\COMPLETE\

# 3. Ship to out
cd ..\
powershell .\c.ship_to_out.ps1

# Output:
# ✅ SHIPMENT COMPLETE
# Files shipped: 1
# Next: Run push_to_git.bat

# 4. Push to Git
cd ..\0ut.3ox
.\push_to_git.bat

# Output:
# ✅ Pushed to GitHub
# Files archived to .SENT/

# 5. Switch to CMD and distribute
cd P:\!CMD.BRIDGE\!BASE.OPERATIONS
powershell .\c.distribute.ps1

# Output:
# ✅ DISTRIBUTION COMPLETE
# Files distributed: 1
# Location: 7HE LIGHTHOUSE/LIBRARY/

# 6. Seal at Lighthouse
cd "P:\!CMD.BRIDGE\OBSIDIAN.BASE\(CAT.7) 7HE LIGHTHOUSE"
powershell .\c.seal.ps1

# Output:
# [Select file from list]
# ✅ DOCUMENT SEALED
# Status: PRODUCTION READY ✅
```

---

## 🔐 RECEIPTS AT EACH STAGE

### 1. Intake Receipt
```yaml
type: intake_receipt
file: test_doc.md
sha256: 6A10890B...
status: VALIDATED
```

### 2. Work Complete Receipt
```yaml
type: work_complete_receipt
file: test_doc.md
sha256: 7B21901C...  # Changed after edits
status: READY_TO_SEND
from: WORKDESK/COMPLETE
to: 0ut.3ox
```

### 3. Git Receipt
```
Git commit: abc123def456...
GitHub URL: https://github.com/user/repo/commit/abc123def456
```

### 4. Distribution Receipt
```yaml
type: distribution_receipt
file: test_doc.md
sha256: 7B21901C...  # Verified match
from_station: RVNx.BASE
to_location: LIGHTHOUSE/LIBRARY/FROM-RVNx
status: DISTRIBUTED
```

### 5. Production Seal
```yaml
type: production_seal
file: test_doc.md
sha256: 7B21901C...  # Final immutable seal
sealed_by: 7HE_LIGHTHOUSE
status: PRODUCTION_READY
immutable: true
```

---

## ✅ VALIDATION CHAIN

Every file has **5 SHA256 validations:**

1. **Intake:** File enters system → Hash recorded
2. **Work Complete:** Edited file → New hash
3. **Git Transit:** Push → Commit hash
4. **Distribution:** Received → Hash verified
5. **Production Seal:** Final → Immutable hash

**If ANY hash mismatches = File corrupted or tampered!**

---

## 🎯 QUICK REFERENCE

| Script | Location | Purpose |
|--------|----------|---------|
| `intake.ps1` | `[Station]/1n.3ox/` | Receive files |
| `c.ship_to_out.ps1` | `[Station]/WORKDESK/` | Ship completed work |
| `push_to_git.bat` | `[Station]/0ut.3ox/` | Push to GitHub |
| `c.distribute.ps1` | `!BASE.OPERATIONS/` | Distribute from CMD |
| `c.seal.ps1` | `7HE LIGHTHOUSE/` | Seal for production |

---

## 🚨 TROUBLESHOOTING

### Problem: "No receipt found"
**Solution:** File skipped intake. Run `intake.ps1` first.

### Problem: "Hash mismatch"
**Solution:** File corrupted during transit. Re-send from source.

### Problem: "Git push failed"
**Solution:** Check Git credentials and network. Repository must exist.

### Problem: "COMPLETE folder empty"
**Solution:** Move finished files from INBOX to COMPLETE manually.

---

## 📊 MONITORING

### Check Pipeline Status:
```powershell
# See all transactions
cat P:\!CMD.BRIDGE\!BASE.OPERATIONS\LOGS\0ut.3ox.transactions.log

# See recent activity
cat P:\!CMD.BRIDGE\!BASE.OPERATIONS\LOGS\0ut.3ox.transactions.log | Select-Object -Last 10
```

### Check Station Status:
```powershell
# Files in transit
dir [Station]\0ut.3ox\

# Files in work
dir [Station]\WORKDESK\INBOX\
dir [Station]\WORKDESK\COMPLETE\

# Archived files
dir [Station]\0ut.3ox\.SENT\
```

### Check Lighthouse Status:
```powershell
# Received files
dir "OBSIDIAN.BASE\(CAT.7) 7HE LIGHTHOUSE\LIBRARY\" -Recurse

# Sealed documents
dir "OBSIDIAN.BASE\(CAT.7) 7HE LIGHTHOUSE\VAULT\"
```

---

## 🎓 BEST PRACTICES

1. **Always run intake first** - Never skip receipts
2. **One file at a time** - Easier to track
3. **Verify receipts** - Check hashes match
4. **Archive regularly** - Clean up .SENT folders
5. **Monitor logs** - Watch for errors
6. **Test with small files first** - Before processing large batches

---

## 🔄 AUTOMATION (Future)

**Not yet automated:**
- Moving files from INBOX → COMPLETE (manual review needed)
- Selecting files to seal (human decision)

**Already automated:**
- Receipt generation (SHA256)
- Manifest updates
- Git operations
- Hash validation
- Archive to .SENT

---

**Created:** ⧗-25.61  
**Version:** 1.0  
**Status:** Production Ready ✅

