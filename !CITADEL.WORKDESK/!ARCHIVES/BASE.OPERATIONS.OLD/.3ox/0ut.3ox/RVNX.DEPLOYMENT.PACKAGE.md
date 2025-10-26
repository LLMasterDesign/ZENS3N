# RVNx Deployment Package
**⧗-25.61 | Ready for !RUNTIME**

---

## 📦 Scripts to Deploy

Copy these to `RVNx.BASE/!RVNX.OPS/!RUNTIME/`:

```
!BASE.OPERATIONS/
├── router.py              → Auto-receipt routing
├── watcher.py             → File detection
├── detector.py            → Arrival detection
├── cross_bank_router.py   → Multi-drive routing
├── log_aggregator.py      → Multi-layer logging
└── notify_external.py     → External notifications
```

---

## 🚀 How to Deploy

### Option 1: Manual Copy
```powershell
# From P:\!CMD.BRIDGE
Copy-Item "!BASE.OPERATIONS\*.py" -Destination "RVNx.BASE\!RVNX.OPS\!RUNTIME\"
```

### Option 2: Use This Script
```powershell
# Create deploy.ps1 in RVNx
$scripts = @(
    'router.py',
    'watcher.py',
    'detector.py',
    'cross_bank_router.py',
    'log_aggregator.py',
    'notify_external.py'
)

foreach ($script in $scripts) {
    Copy-Item "P:\!CMD.BRIDGE\!BASE.OPERATIONS\$script" `
              -Destination "P:\!CMD.BRIDGE\RVNx.BASE\!RVNX.OPS\!RUNTIME\$script"
}
```

---

## ⚙️ After Deployment

### 1. Test Each Script
```powershell
cd RVNx.BASE\!RVNX.OPS\!RUNTIME

# Test router
python router.py

# Test watcher (once)
python watcher.py --once

# Test detector
python detector.py

# Test notifications
python notify_external.py --test

# Test logging
python log_aggregator.py --test
```

### 2. Start Watcher (Background)
```powershell
# Run in background terminal
python watcher.py --watch 10
```

### 3. Configure Notifications
```powershell
python notify_external.py --init
# Then edit: !BASE.OPERATIONS/.3ox/notify_config.json
```

---

## 📋 Production Checklist

- [ ] Scripts copied to !RUNTIME
- [ ] Each script tested individually
- [ ] Watcher running in background
- [ ] Notification config set up
- [ ] Logs initialized
- [ ] First routing test successful

---

**Status:** Ready for Deployment  
**Target:** RVNx.BASE/!RVNX.OPS/!RUNTIME/  
**Authority:** BASE.OPERATIONS Relay

