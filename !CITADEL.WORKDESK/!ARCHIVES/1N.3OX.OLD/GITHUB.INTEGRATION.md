# 🔗 GitHub Integration for 3OX.Ai

**Purpose:** Sync between local CMD.BRIDGE and GitHub repos  
**Repos:**
- `GIT.BASE` → Pull to `!BASE.OPERATIONS`
- `1N.3OX.Ai` → Push documentation/structure

---

## 📥 GIT.BASE → BASE.OPERATIONS Pull

### Setup:

```powershell
cd P:\!CMD.BRIDGE\!BASE.OPERATIONS

# Add GitHub remote
git init
git remote add github https://github.com/LLarzMasterD/GIT.BASE.git

# Pull from GitHub
git pull github main
```

### Automated Pull (run periodically):

```powershell
# Create pull script
cat > pull_from_github.bat << 'EOF'
@echo off
echo Pulling from GIT.BASE...
cd P:\!CMD.BRIDGE\!BASE.OPERATIONS
git pull github main
echo Done!
EOF
```

---

## 📤 1N.3OX.Ai Documentation Push

### What Goes There:
- ✅ Documentation (all .md files in 3OX.Ai/.3ox.index/)
- ✅ File structure (copyable templates)
- ✅ Lawful/public knowledge
- ❌ Private keys
- ❌ Sensitive data
- ❌ Work-in-progress files

### Setup:

```powershell
cd P:\!CMD.BRIDGE

# Clone 1N.3OX.Ai repo
git clone https://github.com/LLarzMasterD/1N.3OX.Ai.git

# Create sync script
cat > sync_documentation.bat << 'EOF'
@echo off
echo Syncing documentation to 1N.3OX.Ai...

REM Copy documentation
robocopy "3OX.Ai\.3ox.index" "1N.3OX.Ai\3OX.Ai" *.md /S /XD .git

REM Copy templates
robocopy "3OX.Ai\.3ox.index\CORE\TEMPLATES" "1N.3OX.Ai\TEMPLATES" *.* /S

REM Push to GitHub
cd 1N.3OX.Ai
git add .
git commit -m "Update documentation - %date% %time%"
git push origin main

echo Done!
EOF
```

---

## 🤖 Automated GitHub Sync (Manning the Updates)

### Create watcher script:

```powershell
# watch_and_sync.bat
@echo off
:loop

REM Pull from GIT.BASE
cd P:\!CMD.BRIDGE\!BASE.OPERATIONS
git pull github main --quiet

REM Push to 1N.3OX.Ai if changes detected
cd P:\!CMD.BRIDGE\3OX.Ai\.3ox.index
git diff --quiet || (
    cd P:\!CMD.BRIDGE
    call sync_documentation.bat
)

REM Wait 5 minutes
timeout /t 300 /nobreak
goto loop
```

### Run in background:
```powershell
start /min watch_and_sync.bat
```

---

## 📋 Manual Sync Commands

### Pull latest from GIT.BASE:
```powershell
cd !BASE.OPERATIONS
git pull github main
```

### Push docs to 1N.3OX.Ai:
```powershell
cd P:\!CMD.BRIDGE
.\sync_documentation.bat
```

---

**Status:** Ready to configure  
**Last Updated:** ⧗-25.61

