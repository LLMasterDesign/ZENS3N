# 🚀 3OX.Ai QUICK START (Personal Setup)

**For solo operator with Cursor agents**

---

## ⚡ FASTEST PATH TO WORKING SYSTEM

### 1. Activate Your First Station (2 minutes)

```powershell
cd P:\!CMD.BRIDGE\3OX.Ai\.3ox.index\OPS\BASE.CMD\REGISTRY
.\quick_activate.bat SYNTH.BASE
```

**What this does:**
- Creates `.3ox/` folder structure
- Sets up `0ut.3ox/` for agent reports
- Creates agent instructions
- Station is now ACTIVE

---

### 2. Test Agent Reporting (5 minutes)

**Open Cursor in SYNTH.BASE, then:**

```yaml
# Create test report
cat > 0ut.3ox/test_report.yaml << 'EOF'
type: status_report
station: SYNTH.BASE
event: test
details: Testing 1n/0ut system
EOF

# Add to manifest
echo "[2025-10-07 16:00:00] | READY | test_report.yaml | INCOMING/synth | HIGH" >> 0ut.3ox/FILE.MANIFEST.txt
```

---

### 3. Process the Report (1 minute)

**If you have Python:**
```powershell
cd P:\!CMD.BRIDGE\3OX.Ai\.3ox.index\CORE\ROUTING
python router.py
```

**If no Python, manual:**
```powershell
# Move file manually
move SYNTH.BASE\0ut.3ox\test_report.yaml !BASE.OPERATIONS\INCOMING\synth\

# Archive original
move SYNTH.BASE\0ut.3ox\test_report.yaml SYNTH.BASE\0ut.3ox\.SENT\
```

---

### 4. Verify It Worked

Check if file arrived:
```powershell
dir !BASE.OPERATIONS\INCOMING\synth\
```

You should see `test_report.yaml` ✅

---

## 🎯 NOW YOUR SYSTEM WORKS!

### For Cursor Agents:

When working in any station, tell them:

> "When you have a breakthrough or complete 20 passes, create a report in `0ut.3ox/` and add it to the manifest."

Agents will see instructions in each station's `.3ox/AGENT.INSTRUCTIONS.md`

---

## 🚀 ACTIVATE MORE STATIONS

Repeat step 1 for each:

```powershell
.\quick_activate.bat RVNx.BASE
.\quick_activate.bat OBSIDIAN.BASE
.\quick_activate.bat "OBSIDIAN.BASE/(CAT.2) The Bridge"
```

---

## 📋 FULL DEPLOYMENT

For complete setup, see: `DEPLOYMENT.CHECKLIST.md`

---

**Time to working system:** ~10 minutes  
**Complexity:** Low (batch scripts only)  
**Status:** Production-ready for personal use

