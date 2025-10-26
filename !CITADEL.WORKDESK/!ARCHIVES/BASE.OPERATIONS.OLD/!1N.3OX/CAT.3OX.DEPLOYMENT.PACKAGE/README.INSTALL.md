# 🎁 THE CITADEL - CAT.3OX SYSTEM

**Welcome to your new command center.**

---

## 📦 WHAT YOU JUST BOUGHT

You now own **The Citadel** - a complete AI-assisted file organization and automation system designed for creative professionals managing multiple projects across different life categories.

**System Name:** CAT.3OX (Category Organization System)  
**Version:** V1.0  
**Date Purchased:** ⧗-25.61 (Oct 8, 2025)  
**Previous Owner:** RVNX Systems  

---

## 🎯 WHAT THIS SYSTEM DOES

### **In Plain English:**

This system automatically:
- **Organizes your files** into 7 life categories (Self, School, Business, Family, Social, Operations, Knowledge)
- **Routes files** between 3 workspaces (Obsidian, RVNx, Synth)
- **Backs up to cloud** (GitHub for code, pCloud for files)
- **Tracks everything** with receipts and logs
- **Works with AI** (Cursor/Claude) to help you manage it all

Think of it as a **personal file butler** that knows where everything should go.

---

## 🏗️ THE ARCHITECTURE (SIMPLE VERSION)

```
Your Computer:
├── R: Drive (The Citadel) ← Where you WORK
│   └── Everything active and alive
│
├── P: Drive (The Lighthouse) ← Where you STORE
│   └── Cloud backup (pCloud mounted)
│
└── X: Drive (Your Files) ← Where your LIFE is
    └── Personal documents and projects
```

### **The 7 Categories (CATs):**

```
CAT.1 = Self (health, personal growth, identity)
CAT.2 = School (education, learning, courses)
CAT.3 = Business (work, income, projects)
CAT.4 = Family (relationships, home stuff)
CAT.5 = Social (friends, community, hobbies)
CAT.6 = Operations (the system itself - this!)
CAT.7 = Lighthouse (knowledge vault, AI outputs)
```

### **The 3 Stations:**

```
OBSIDIAN.BASE = Your note-taking and knowledge workspace
RVNx.BASE = Your coding and development workspace
SYNTH.BASE = Your creative and synthesis workspace
```

---

## 🚀 INSTALLATION GUIDE

### **Step 1: Check What You Have**

Open PowerShell and run:
```powershell
Get-PSDrive | Where-Object {$_.Name -match '[P-Z]'}
```

**You should see:**
- ✅ P: drive (pCloud - cloud storage)
- ✅ R: drive (The Citadel - NEW!)
- ✅ X: drive (your personal files)

**If R: drive doesn't exist:** Stop here. Read `DISK.SETUP.GUIDE.md` first.

---

### **Step 2: Validate R: Drive**

Run the validation script:
```powershell
cd P:\!CMD.BRIDGE\!BASE.OPERATIONS
.\c.validate_R_drive.ps1
```

**Expected output:**
```
[OK] R: drive is mounted
[OK] NTFS confirmed
[OK] Sufficient space
[YES] R: drive is ready for .3ox system
```

If you see errors, fix them before continuing.

---

### **Step 3: Understand What Will Happen**

The installation will:

1. **Move CMD.BRIDGE** from P: → R:
   - All system files
   - Git repository
   - Automation scripts

2. **Create folder structure** on R:
   - !CMD.BRIDGE
   - 3OX.Ai (intelligence)
   - !LAUNCH.PAD (your control panel)
   - OBSIDIAN.BASE, RVNx.BASE, SYNTH.BASE

3. **Set up connections:**
   - GitHub (code backup)
   - pCloud (file backup)
   - Routing between stations

**Time required:** 30-60 minutes  
**Difficulty:** Intermediate (we'll walk you through it)

---

### **Step 4: Deploy The Structure**

Run the deployment script:
```powershell
cd P:\!CMD.BRIDGE\!BASE.OPERATIONS\!1N.3OX\CAT.3OX.DEPLOYMENT.PACKAGE
.\c.DEPLOY.CITADEL.ps1
```

**What it does:**
1. Creates all folders on R:
2. Copies placeholder files
3. Sets up .3ox intelligence files
4. Creates workspace files for Cursor
5. Does NOT move live data yet (that's next step)

**This is safe** - it only creates structure, doesn't move your files.

---

### **Step 5: Set Up GitHub Backup**

Your system needs to back up code to GitHub.

**Option A: You already have GitHub account**
```powershell
# Set up SSH keys
.\c.setup_github_ssh.ps1

# Follow prompts to add key to GitHub
# Then connect CMD.BRIDGE to GitHub
```

**Option B: You don't have GitHub account**
```
1. Go to github.com
2. Sign up (free)
3. Come back and run Option A
```

**Why this matters:** Without GitHub backup, if R: drive dies, you lose the system. GitHub is your insurance policy.

---

### **Step 6: Migrate Live System**

**⚠️ IMPORTANT: Backup first!**

Before running migration:
```powershell
# Backup current system to pCloud
# (It's probably already there, but check)
# P:\!CMD.BRIDGE should have everything
```

**Then run migration:**
```powershell
.\c.MIGRATE.TO.CITADEL.ps1
```

**What it does:**
1. Copies P:\!CMD.BRIDGE → R:\!CMD.BRIDGE
2. Verifies Git repository is intact
3. Updates all routing configs
4. Tests system operations
5. Creates restore point

**This takes 10-15 minutes** depending on how much data you have (~6GB).

---

### **Step 7: Configure pCloud Sync**

You want R: drive backed up to cloud, but not everything (avoid loops and bloat).

**Run sync configurator:**
```powershell
.\c.CONFIGURE.PCLOUD.SYNC.ps1
```

**What syncs:**
- ✅ !CMD.BRIDGE (system brain)
- ✅ 3OX.Ai (intelligence)
- ✅ Station !LAUNCH.PAD folders (work products)
- ❌ !WORK.DESK folders (temporary files)
- ❌ !OPS folders (logs only needed locally)

**Result:** ~8-10GB synced to cloud (not 50GB).

---

### **Step 8: Test Everything**

**Test 1: Open The Citadel**
```
1. Navigate to R:\!LAUNCH.PAD\
2. Open !LAUNCH.PAD.code-workspace
3. Cursor should load the entire system
```

**Test 2: Check Routing**
```powershell
# Create test file
echo "Test from Citadel" > R:\!CMD.BRIDGE\!BASE.OPERATIONS\INCOMING\test.txt

# Watch it get routed
python R:\!CMD.BRIDGE\!BASE.OPERATIONS\watcher.py
```

**Test 3: Check Git**
```powershell
cd R:\!CMD.BRIDGE
git status
# Should show clean or tracked changes
```

**Test 4: Check pCloud Sync**
```
1. Open pCloud app
2. Look for R:\ folder
3. Check that files are syncing
```

---

### **Step 9: Learn The System**

**Key files to read:**
```
R:\!CMD.BRIDGE\!BASE.OPERATIONS\c.R_DRIVE.CITADEL.BLUEPRINT.md
  → Complete architecture documentation

R:\!LAUNCH.PAD\CITADEL.OVERVIEW.md
  → User guide and navigation

R:\3OX.Ai\.3ox.index\CORE\GENESIS.SYSTEM.ARCHITECTURE.md
  → How the intelligence works
```

**Key folders to know:**
```
R:\!CMD.BRIDGE\!BASE.OPERATIONS\
  → System scripts and automation

R:\!LAUNCH.PAD\
  → Your command center (start here every time)

R:\!LAUNCH.PAD\(CAT.3) Business\
  → See all your business files across all stations
```

---

### **Step 10: Daily Usage**

**Morning routine:**
```
1. Open R:\!LAUNCH.PAD\!LAUNCH.PAD.code-workspace
2. Cursor loads your entire system
3. Navigate to the CAT you're working on today
4. Start working
```

**When you create files:**
```
They automatically route to the right place based on:
- Which station you're in (Obsidian/RVNx/Synth)
- Which CAT folder you save to
- The .3ox intelligence rules
```

**When you need something:**
```
R:\!LAUNCH.PAD\(CAT.X) → See all files in that category
All stations aggregated in one view
```

---

## 🆘 TROUBLESHOOTING

### **"R: drive is full"**
- Check R:\**\!WORK.DESK\ folders (delete temp files)
- Check R:\**\__pycache__\ folders (delete Python cache)
- Run cleanup: `.\c.CLEANUP.CAT.DUPLICATES.ps1`

### **"Git says 'no remote configured'"**
- You skipped Step 5 (GitHub setup)
- Run: `.\c.setup_github_ssh.ps1`
- Follow GitHub connection steps

### **"pCloud is syncing too much"**
- Check exclusion rules in pCloud app
- Run: `.\c.CONFIGURE.PCLOUD.SYNC.ps1` again
- Exclude !WORK.DESK and *OPS folders

### **"Watcher isn't routing files"**
- Check if watcher.py is running:
  ```powershell
  Get-Process | Where-Object {$_.Name -like "*python*"}
  ```
- Check routing configs:
  ```powershell
  ls R:\!CMD.BRIDGE\!BASE.OPERATIONS\ROUTING.CONFIGS\
  ```
- Restart watcher:
  ```powershell
  python R:\!CMD.BRIDGE\!BASE.OPERATIONS\watcher.py
  ```

### **"I broke something"**
- Restore from pCloud: P:\!CMD.BRIDGE is your backup
- Copy P:\!CMD.BRIDGE → R:\!CMD.BRIDGE
- Start over from Step 6

---

## 📚 LEARNING PATH

### **Week 1: Basics**
- Navigate R:\!LAUNCH.PAD\
- Understand the 7 CATs
- Use one station (probably Obsidian)
- Let files auto-route

### **Week 2: Intermediate**
- Open multiple station workspaces
- Customize .3ox intelligence files
- Understand routing configs
- Use Git for versioning

### **Week 3: Advanced**
- Customize automation scripts
- Add new routing rules
- Deploy to other computers
- Build your own integrations

---

## 🎯 WHAT SUCCESS LOOKS LIKE

**After 1 month, you should:**
- ✅ Know where any file is in 10 seconds
- ✅ Have zero "where did I save that?" moments
- ✅ Have automatic backups of everything
- ✅ Understand the CAT system intuitively
- ✅ Trust the system to route files correctly

**Your workflow becomes:**
```
Create → System routes it → You find it instantly → Backed up automatically
```

---

## 🔐 IMPORTANT SECURITY NOTES

**Never share:**
- ❌ Your SSH private key (C:\Users\YOU\.ssh\id_ed25519)
- ❌ GitHub personal access tokens
- ❌ pCloud passwords
- ❌ BitLocker recovery keys (but save them safely!)

**Always backup:**
- ✅ R:\!CMD.BRIDGE → GitHub (code)
- ✅ R:\ → pCloud (files)
- ✅ X:\ → pCloud (personal files)
- ✅ Recovery keys → 3 locations (Microsoft account, paper, password manager)

---

## 📞 SUPPORT

**Documentation:**
- Full blueprint: `c.R_DRIVE.CITADEL.BLUEPRINT.md`
- System specs: `V10SL.SPECIFICATION.md`
- Captain's log: `CAPTAINS.LOG.md`

**Community:**
- Previous owner documentation is thorough
- All scripts are commented
- .3ox files explain the intelligence

**If stuck:**
1. Read the error message carefully
2. Check CAPTAINS.LOG.md for similar issues
3. Review the blueprint for architecture questions
4. Check STATUS.REPORT.md for system health

---

## 🎁 EXTRAS INCLUDED

**Scripts in !BASE.OPERATIONS\!SCRIPTS\:**
- CLEANUP.CAT.DUPLICATES.ps1 (find duplicates)
- COMMAND_CENTER.ps1 (system dashboard)
- START_COMMAND_CENTER.bat (quick launch)

**Templates in 3OX.Ai\.3ox.index\CORE\TEMPLATES\:**
- AGENT.INSTRUCTIONS.template
- PROJECT.BRAIN.template
- STATION.RULES.template

**Guides:**
- GIT.PASSTHRU.QUICKSTART.md
- RECEIPT.SYSTEM.MANUAL.md
- WATCHER.README.md
- REMOTE.WORK.SETUP.md

---

## ✨ FINAL WORDS

You bought more than a file system. You bought:
- A methodology for organizing life
- An AI-assisted command center
- A framework that grows with you
- Peace of mind through automatic backups

**The previous owner (RVNX) spent months building this.**

Take your time learning it. Start simple (just use !LAUNCH.PAD and one CAT). Build up from there.

**Welcome to The Citadel. You're home now.**

---

**Installation Version:** V1.0  
**Last Updated:** ⧗-25.61  
**Status:** Ready for deployment  

**Questions?** Read CAPTAINS.LOG.md to see how this system evolved.

**Ready?** Start with Step 1 above. Good luck, Commander. 🚀

