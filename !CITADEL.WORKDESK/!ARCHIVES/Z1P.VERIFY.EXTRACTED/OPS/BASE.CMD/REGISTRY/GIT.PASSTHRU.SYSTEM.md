///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // GIT.PASSTHRU.SYSTEM ▞▞
▞//▞ Git.Transit :: ρ{git.transport}.φ{OPS}.τ{System}.λ{passthru} ⫸
▙⌱[🔄] ≔ [⊢{0ut.3ox}⇨{git.push}⟿{receipt}▷{1n.3ox}]
〔git.based.file.transit.with.receipts〕 :: ∎

# 🔄 GIT PASSTHRU SYSTEM

**Purpose:** Use Git as transit layer between stations and BASE.OPS  
**Receipts:** Every commit = transaction receipt with hash  
**Storage:** Offload to GitHub, pull on demand

---

## 🎯 CONCEPT

```
SYNTH.BASE/0ut.3ox/
    ↓
Git Push → GitHub Repo (GIT.BASE)
    ↓ (Git commit hash = receipt)
Git Pull ← BASE.OPERATIONS/INCOMING/synth/
    ↓
Processed & Archived
```

**Every transaction gets:**
- Git commit hash (unique receipt)
- Timestamp (commit date)
- Author (station name)
- Message (what was sent)
- Full history (Git log)

---

## 🏗️ ARCHITECTURE

### GitHub Repos:

1. **GIT.BASE (Main Transit Hub)**
   - URL: `https://github.com/LLarzMasterD/GIT.BASE.git`
   - Branches:
     - `synth-out` ← SYNTH.BASE/0ut.3ox pushes here
     - `rvnx-out` ← RVNx.BASE/0ut.3ox pushes here
     - `obsidian-out` ← OBSIDIAN.BASE/0ut.3ox pushes here
     - `main` ← BASE.OPERATIONS pulls from here

2. **1N.3OX.Ai (Documentation)**
   - URL: `https://github.com/LLarzMasterD/1N.3OX.Ai.git`
   - Branch: `main`
   - Content: Documentation, templates, structure (public)

---

## 📤 0UT.3OX → GIT PUSH

### Setup (Per Station):

```powershell
# Initialize Git in 0ut.3ox folder
cd SYNTH.BASE\0ut.3ox
git init
git remote add github https://github.com/LLarzMasterD/GIT.BASE.git

# Create branch for this station
git checkout -b synth-out

# Add .gitignore for .SENT folder
echo ".SENT/" > .gitignore
echo "FILE.MANIFEST.txt" >> .gitignore
```

### Auto-Push Script (per station):

**`SYNTH.BASE/0ut.3ox/push_to_git.bat`:**
```batch
@echo off
REM Auto-push 0ut.3ox files to GitHub with receipt

cd /d "%~dp0"
set STATION=SYNTH.BASE
set BRANCH=synth-out

REM Check for new files
git add *.yaml *.md *.json *.txt 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo No new files to push
    exit /b 0
)

REM Create commit with timestamp
set TIMESTAMP=%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

git commit -m "[%STATION%] Transmission %TIMESTAMP%"

REM Push to GitHub
git push github %BRANCH%

REM Get commit hash (receipt)
for /f "tokens=*" %%a in ('git rev-parse HEAD') do set RECEIPT=%%a

REM Save receipt
echo Transmission Receipt: %RECEIPT% > .SENT\receipt_%TIMESTAMP%.txt
echo Station: %STATION% >> .SENT\receipt_%TIMESTAMP%.txt
echo Branch: %BRANCH% >> .SENT\receipt_%TIMESTAMP%.txt
echo Timestamp: %TIMESTAMP% >> .SENT\receipt_%TIMESTAMP%.txt

REM Move processed files to .SENT
for %%f in (*.yaml *.md *.json) do (
    move "%%f" ".SENT\%%f" 2>nul
)

echo ✅ Pushed to GitHub
echo    Receipt: %RECEIPT%
echo    Branch: %BRANCH%
echo    Files archived to .SENT/
```

---

## 📥 GIT PULL → 1N.3OX (BASE.OPS)

### Setup:

```powershell
# Clone GIT.BASE to BASE.OPERATIONS
cd !BASE.OPERATIONS
git clone https://github.com/LLarzMasterD/GIT.BASE.git GIT.PASSTHRU

# Set up tracking for all station branches
cd GIT.PASSTHRU
git fetch --all
git checkout -b synth-out origin/synth-out
git checkout -b rvnx-out origin/rvnx-out
git checkout -b obsidian-out origin/obsidian-out
git checkout main
```

### Auto-Pull Script:

**`!BASE.OPERATIONS/pull_from_git.bat`:**
```batch
@echo off
REM Pull from all station branches and distribute to INCOMING/

cd /d "P:\!CMD.BRIDGE\!BASE.OPERATIONS\GIT.PASSTHRU"

REM Fetch all updates
git fetch --all

REM Process each station branch
for %%s in (synth rvnx obsidian) do (
    echo.
    echo Processing %%s-out branch...
    
    REM Checkout branch
    git checkout %%s-out
    git pull origin %%s-out
    
    REM Copy new files to INCOMING
    if exist *.yaml (
        copy *.yaml "..\INCOMING\%%s\" 2>nul
        echo ✅ Files copied to INCOMING\%%s\
        
        REM Log receipt
        for /f "tokens=*" %%h in ('git rev-parse HEAD') do (
            echo [%DATE% %TIME%] ^| %%s ^| Receipt: %%h >> ..\INCOMING\REGISTRY.LOG
        )
        
        REM Delete from Git branch (cleanup)
        del *.yaml *.md *.json 2>nul
        git add -A
        git commit -m "Cleanup: Files processed by BASE.OPS"
        git push origin %%s-out
    ) else (
        echo No new files from %%s
    )
)

git checkout main
echo.
echo ✅ Pull complete - check INCOMING/ for new files
```

---

## 🧾 RECEIPT SYSTEM

### Receipt Format:

Every push creates a receipt file in `.SENT/`:

```
Transmission Receipt: a1b2c3d4e5f6789012345678901234567890abcd
Station: SYNTH.BASE
Branch: synth-out
Timestamp: 2025-10-07_16-45-30
Files:
  - status_report_2025-10-07.yaml
  - breakthrough_alert.yaml
GitHub URL: https://github.com/LLarzMasterD/GIT.BASE/commit/a1b2c3d4
```

### View Receipts:

```powershell
# View all receipts
dir SYNTH.BASE\0ut.3ox\.SENT\receipt_*.txt

# View specific receipt
cat SYNTH.BASE\0ut.3ox\.SENT\receipt_2025-10-07_16-45-30.txt

# Verify on GitHub
start https://github.com/LLarzMasterD/GIT.BASE/commit/a1b2c3d4
```

---

## 🔄 COMPLETE WORKFLOW

### Station Side (SYNTH.BASE):

```powershell
# 1. Agent creates report
echo "type: status" > 0ut.3ox/report.yaml

# 2. Push to Git (creates receipt)
cd 0ut.3ox
.\push_to_git.bat

# Output:
# ✅ Pushed to GitHub
#    Receipt: a1b2c3d4e5f6789012345678901234567890abcd
#    Branch: synth-out
#    Files archived to .SENT/
```

### CMD Side (BASE.OPERATIONS):

```powershell
# 1. Pull from Git
cd !BASE.OPERATIONS
.\pull_from_git.bat

# Output:
# Processing synth-out branch...
# ✅ Files copied to INCOMING\synth\
# [2025-10-07 16:45:30] | synth | Receipt: a1b2c3d4...

# 2. Process files
cd INCOMING\synth
# Files are now here, ready to process
```

---

## 📊 BENEFITS

### Storage Management:
- ✅ Files go to GitHub (unlimited storage)
- ✅ Local copies archived to .SENT (can delete old ones)
- ✅ Pull only what you need from Git
- ✅ Reduces P: drive pressure

### Receipts & Audit:
- ✅ Every transaction has Git commit hash
- ✅ Full history in Git log
- ✅ Can verify on GitHub
- ✅ Tamper-evident (Git integrity)

### Simplicity:
- ✅ No Python dependencies
- ✅ Just batch scripts + Git
- ✅ Works with upload lag (push when ready)
- ✅ Pull on demand

### Reliability:
- ✅ Git handles transfer
- ✅ Automatic conflict resolution
- ✅ Can re-pull if needed
- ✅ GitHub is the backup

---

## 🚀 SETUP CHECKLIST

### For Each Station:

- [ ] Initialize Git in `0ut.3ox/`
- [ ] Add GitHub remote
- [ ] Create station branch (`synth-out`, `rvnx-out`, etc.)
- [ ] Create `push_to_git.bat` script
- [ ] Test push with dummy file
- [ ] Verify receipt created

### For BASE.OPERATIONS:

- [ ] Clone GIT.BASE to `GIT.PASSTHRU/`
- [ ] Track all station branches
- [ ] Create `pull_from_git.bat` script
- [ ] Test pull from one station
- [ ] Verify files in `INCOMING/`

### For Documentation:

- [ ] Clone 1N.3OX.Ai repo
- [ ] Create sync script
- [ ] Push documentation
- [ ] Verify on GitHub

---

## 🔧 MAINTENANCE

### Cleanup Old Receipts:

```powershell
# Delete receipts older than 30 days
Get-ChildItem -Path "SYNTH.BASE\0ut.3ox\.SENT\receipt_*.txt" |
    Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)} |
    Remove-Item
```

### View Transaction History:

```powershell
# See all commits from SYNTH.BASE
cd !BASE.OPERATIONS\GIT.PASSTHRU
git checkout synth-out
git log --oneline --all

# See specific transaction
git show a1b2c3d4
```

### Archive Old Files from GitHub:

```powershell
# After files processed, they're deleted from branch
# But Git history preserves them forever
# To reduce repo size, periodically:
cd GIT.PASSTHRU
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

---

## 📋 QUICK REFERENCE

### Push from Station:
```powershell
cd SYNTH.BASE\0ut.3ox
.\push_to_git.bat
```

### Pull to BASE.OPS:
```powershell
cd !BASE.OPERATIONS
.\pull_from_git.bat
```

### Check Receipt:
```powershell
cat SYNTH.BASE\0ut.3ox\.SENT\receipt_[timestamp].txt
```

### View on GitHub:
```
https://github.com/LLarzMasterD/GIT.BASE/tree/synth-out
```

---

**System Status:** READY TO IMPLEMENT  
**Dependencies:** Git only  
**Storage Impact:** Offloads to GitHub  
**Receipt System:** Git commit hashes

//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙

