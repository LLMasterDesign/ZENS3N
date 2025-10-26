# How to Generate File Hash for Receipts
**⧗-25.61 | Quick Reference**

---

## 🎯 What is File Hash?

**A unique fingerprint for your file.**

- Same file = Same hash
- Change 1 letter = Completely different hash
- Used to verify file wasn't corrupted during transfer

---

## 🔧 Generate Hash (PowerShell)

### Quick Command:
```powershell
(Get-FileHash "filename.md" -Algorithm SHA256).Hash.Substring(0,16)
```

### Example:
```powershell
# For this file:
(Get-FileHash "SYSTEM.STATUS.REPORT.md" -Algorithm SHA256).Hash.Substring(0,16)

# Output:
8D3F6AE05FAD8530
```

---

## 📋 Use in Receipt

### When Creating Receipt:

1. **Generate hash:**
   ```powershell
   (Get-FileHash "my-report.md" -Algorithm SHA256).Hash.Substring(0,16)
   ```

2. **Get file size:**
   ```powershell
   (Get-Item "my-report.md").Length
   ```

3. **Add to receipt:**
   ```markdown
   FILE_HASH = 8D3F6AE05FAD8530
   FILE_SIZE = 4096
   ```

---

## ✅ Verify File at Destination

### Check if file is intact:

```powershell
# Generate hash of received file
(Get-FileHash "received-file.md" -Algorithm SHA256).Hash.Substring(0,16)

# Compare with hash in receipt
# If they match → File is good ✓
# If different → File corrupted ✗
```

---

## 🎨 Full Receipt Example with Hash

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
- quarterly-report.md

FILE_HASH = A1B2C3D4E5F6G7H8
FILE_SIZE = 8192

NOTES:
Review quarterly report and integrate findings.
Hash verification ensures file integrity during transfer.

RESPONDER = synth.admin
```

---

## 🚀 Quick Copy-Paste

```powershell
# Get both hash and size in one go:
$file = "filename.md"
$hash = (Get-FileHash $file -Algorithm SHA256).Hash.Substring(0,16)
$size = (Get-Item $file).Length
Write-Host "FILE_HASH = $hash"
Write-Host "FILE_SIZE = $size"
```

**Output:**
```
FILE_HASH = 8D3F6AE05FAD8530
FILE_SIZE = 1198
```

**Copy this into your receipt!**

---

## 💡 Why Use Hash?

✓ **Integrity Check** - Know if file got corrupted  
✓ **Audit Trail** - Prove file is original  
✓ **Troubleshooting** - If file behaves weird, check hash  
✓ **Peace of Mind** - Confirm transfer was clean

---

**Status:** Ready to Use ⧗-25.61  
**Compatible:** Windows PowerShell | PowerShell Core

