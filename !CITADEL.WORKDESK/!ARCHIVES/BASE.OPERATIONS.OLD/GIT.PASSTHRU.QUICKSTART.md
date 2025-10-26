# 🚀 GIT PASSTHRU QUICKSTART

**Clear storage + Get receipts + Use GitHub as transit layer**

---

## ⚡ START NOW (5 minutes)

### Step 1: Test Push from SYNTH.BASE

```powershell
# Create a test file
cd P:\!CMD.BRIDGE\SYNTH.BASE\0ut.3ox
echo "type: test`nstation: SYNTH.BASE`nevent: git_passthru_test" > test.yaml

# Push to GitHub (creates receipt)
.\push_to_git.bat
```

**What happens:**
- Initializes Git in 0ut.3ox (first time only)
- Commits file with timestamp
- Pushes to GitHub branch `synth-out`
- Creates receipt with Git commit hash
- Moves file to `.SENT/` (frees local space)

---

### Step 2: Pull to BASE.OPERATIONS

```powershell
cd P:\!CMD.BRIDGE\!BASE.OPERATIONS

# Pull from GitHub
.\pull_from_git.bat
```

**What happens:**
- Clones GIT.BASE repo (first time only)
- Fetches from all station branches
- Copies files to `INCOMING/synth/`
- Logs receipt to `REGISTRY.LOG`
- Cleans up GitHub branch

---

### Step 3: Verify It Worked

```powershell
# Check if file arrived
dir INCOMING\synth\test.yaml

# Check receipt log
cat INCOMING\REGISTRY.LOG

# View receipt on GitHub
start https://github.com/LLarzMasterD/GIT.BASE/tree/synth-out
```

---

## 🔄 ONGOING USAGE

### From Any Station:

```powershell
# 1. Files accumulate in 0ut.3ox/
# 2. Push when ready:
cd SYNTH.BASE\0ut.3ox
.\push_to_git.bat

# Works even offline! Files commit locally, push when online
```

### From CMD.BRIDGE:

```powershell
# Pull periodically (or on-demand):
cd !BASE.OPERATIONS
.\pull_from_git.bat

# Can run this hourly, daily, or whenever you want
```

---

## 💾 STORAGE BENEFITS

### Before Git Passthru:
```
P:\!CMD.BRIDGE\
├── SYNTH.BASE\0ut.3ox\
│   ├── report1.yaml (2MB)
│   ├── report2.yaml (2MB)
│   └── report3.yaml (2MB)  ← All sitting here
└── !BASE.OPERATIONS\INCOMING\synth\
    └── (empty - waiting for manual move)

Total on P: drive: 6MB
```

### After Git Passthru:
```
P:\!CMD.BRIDGE\
├── SYNTH.BASE\0ut.3ox\
│   └── .SENT\              ← Can delete old receipts
│       ├── receipt_*.txt (1KB each)
│       └── (old files archived, can delete)
└── !BASE.OPERATIONS\INCOMING\synth\
    ├── report1.yaml (pulled when needed)
    └── ...

GitHub (unlimited):
└── synth-out branch
    ├── All files preserved
    └── Full Git history

Total on P: drive: Minimal (just receipts)
```

**Savings:** Files moved to GitHub, local drive freed!

---

## 🧾 RECEIPT SYSTEM

Every push creates a receipt:

```
Transmission Receipt
====================
Receipt Hash: a1b2c3d4e5f6789012345678901234567890abcd
Station: SYNTH.BASE
Branch: synth-out
Timestamp: 2025-10-07_16-45-30
GitHub URL: https://github.com/LLarzMasterD/GIT.BASE/commit/a1b2c3d

Files:
  test.yaml
  status_report.yaml
```

**View receipt:**
```powershell
cat SYNTH.BASE\0ut.3ox\.SENT\receipt_2025-10-07_16-45-30.txt
```

**Verify on GitHub:**
- Click the GitHub URL in receipt
- See exact commit with all files
- View full history

---

## 🎯 SETUP OTHER STATIONS

Copy scripts to each station:

```powershell
# For RVNx.BASE
copy SYNTH.BASE\0ut.3ox\push_to_git.bat RVNx.BASE\0ut.3ox\
# Edit: Change STATION=SYNTH.BASE to STATION=RVNx.BASE
# Edit: Change BRANCH=synth-out to BRANCH=rvnx-out

# For OBSIDIAN.BASE
copy SYNTH.BASE\0ut.3ox\push_to_git.bat OBSIDIAN.BASE\0ut.3ox\
# Edit: Change to STATION=OBSIDIAN.BASE, BRANCH=obsidian-out
```

Then pull handles all stations automatically!

---

## 🚨 TROUBLESHOOTING

### "Git not found"
Install Git: https://git-scm.com/download/win

### "Push failed - will retry later"
**This is OK!** Files are committed locally with receipt.
- Run script again when online
- Or commit manually: `git push github synth-out`

### "Authentication failed"
Set up GitHub credentials:
```powershell
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

For HTTPS, use Personal Access Token when prompted.

---

## ⏱️ AUTOMATED SCHEDULING (Optional)

### Auto-push every hour:
```powershell
# Windows Task Scheduler
schtasks /create /tn "SYNTH Push" /tr "P:\!CMD.BRIDGE\SYNTH.BASE\0ut.3ox\push_to_git.bat" /sc hourly
```

### Auto-pull every hour:
```powershell
schtasks /create /tn "BASE OPS Pull" /tr "P:\!CMD.BRIDGE\!BASE.OPERATIONS\pull_from_git.bat" /sc hourly
```

---

## 📊 ADVANTAGES

| Feature | Old System | Git Passthru |
|---------|-----------|--------------|
| **Storage** | Local P: drive | GitHub (unlimited) |
| **Receipts** | Manual tracking | Git commit hashes |
| **Audit Trail** | FILE.MANIFEST | Git log (permanent) |
| **Offline Work** | Blocked | Commit locally, push later |
| **Recovery** | .SENT archives | Full Git history |
| **Dependencies** | Python, router.py | Just Git |

---

## 🎊 YOU'RE READY!

**Test it now:**
1. Create file in `SYNTH.BASE/0ut.3ox/test.yaml`
2. Run `push_to_git.bat`
3. Check GitHub for commit
4. Run `pull_from_git.bat` from BASE.OPS
5. Verify file in `INCOMING/synth/`

**Storage cleared + Receipt generated + System working! 🚀**

---

**Last Updated:** ⧗-25.61  
**Status:** READY TO USE

