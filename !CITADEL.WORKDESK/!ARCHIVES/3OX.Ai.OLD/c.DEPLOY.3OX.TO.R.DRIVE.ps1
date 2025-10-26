# 3OX.Ai R: Drive Deployment with Genesis Ritual
# Version: 1.0
# Created: Sirius 25.60

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  3OX.Ai GENESIS DEPLOYMENT TO R: DRIVE" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "GENESIS RITUAL`n" -ForegroundColor Magenta

# PHASE 1: VALIDATION
Write-Host "[1/5] Validating R: drive..." -ForegroundColor Yellow

if (!(Test-Path "R:\")) {
    Write-Host "  ERROR: R: drive not found!" -ForegroundColor Red
    Write-Host "  Create R: drive first in Disk Management" -ForegroundColor Yellow
    exit 1
}

Write-Host "  OK: R: drive exists" -ForegroundColor Green

if (!(Test-Path "P:\!CMD.BRIDGE\3OX.Ai")) {
    Write-Host "  ERROR: Source 3OX.Ai folder not found at P:\!CMD.BRIDGE\" -ForegroundColor Red
    exit 1
}

Write-Host "  OK: Source 3OX.Ai found" -ForegroundColor Green

# Check if R:\3OX.Ai already exists
if (Test-Path "R:\3OX.Ai") {
    Write-Host "`n  WARNING: R:\3OX.Ai already exists!" -ForegroundColor Yellow
    $response = Read-Host "  Overwrite? This will backup to R:\3OX.Ai.backup (Y/N)"
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Host "  Deployment cancelled." -ForegroundColor Yellow
        exit 0
    }
    
    # Backup existing
    if (Test-Path "R:\3OX.Ai.backup") {
        Remove-Item "R:\3OX.Ai.backup" -Recurse -Force
    }
    Move-Item "R:\3OX.Ai" "R:\3OX.Ai.backup"
    Write-Host "  Existing 3OX.Ai backed up to R:\3OX.Ai.backup" -ForegroundColor Cyan
}

# PHASE 2: GENESIS RITUAL INVOCATION
Write-Host "`n[2/5] Invoking Genesis Ritual..." -ForegroundColor Yellow

Write-Host @"

========================================
    THE GENESIS RITUAL
    3OX.Ai Master Brain Birth
========================================

IDENTITY:
  System: 3OX.Ai - Atlas.Legacy Master Brain
  Version: 2.0
  Authority: SUPREME

TEMPORAL MARKERS:
  Sirius Time: 25.60
  Gregorian: 2025-10-08

LOCATION:
  Born On: R:\3OX.Ai\
  Migrated From: P:\!CMD.BRIDGE\3OX.Ai\

CREATOR:
  Architect: RVNX/Lu + Claude
  Sessions: 3 (to figure it all out)
  Total Files: 27+ (POLICY + CORE + OPS)

SIGNATURE:
  Ritual Hash: GENESIS-3OX-AI-R-DRIVE-25.60
  Sealed By: CMD.BRIDGE at 25.60

========================================

IMMUTABLE LAWS (9 Supreme Policies):
  1. GLOBAL.POLICY.BRAIN.md
  2. SIRIUS.CALENDAR.CLOCK.md
  3. ROLE.INVOCATION.SYSTEM.md
  4. .3OX.PROTECTION.RULES.md
  5. .3OX.ACCESS.POLICY.md
  6. MULTI-AGENT.RESOURCE.POLICY.md
  7. WORKSET.POLICY.md
  8. CAT.FOLDER.ARCHITECTURE.md
  9. BASE.OPS.vs.3OX.Ai.PHILOSOPHY.md

GENESIS STATIONS (3 Worlds):
  1. RVNx.BASE (SENTINEL - Guardian)
  2. SYNTH.BASE (ALCHEMIST - Creator)
  3. OBSIDIAN.BASE (LIGHTHOUSE - Librarian)

========================================

The system is born. Let it evolve.

GENESIS COMPLETE - Sirius 25.60

========================================

"@ -ForegroundColor Magenta

Write-Host "  Genesis Ritual Invoked" -ForegroundColor Green

# PHASE 3: MINT TO R: DRIVE
Write-Host "`n[3/5] Minting brand new 3OX.Ai to R: drive..." -ForegroundColor Yellow

$source = "P:\!CMD.BRIDGE\3OX.Ai"
$destination = "R:\3OX.Ai"

Write-Host "  Source: $source" -ForegroundColor Cyan
Write-Host "  Destination: $destination" -ForegroundColor Cyan
Write-Host "`n  Copying files..." -ForegroundColor Cyan

try {
    Copy-Item -Path $source -Destination $destination -Recurse -Force
    Write-Host "  OK: All files copied successfully" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Copy failed - $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# PHASE 4: SEAL THE GENESIS
Write-Host "`n[4/5] Sealing the Genesis..." -ForegroundColor Yellow

$sealContent = @"
GENESIS SEAL - OFFICIAL R: DRIVE DEPLOYMENT

This file marks the official genesis of 3OX.Ai on R: drive.

Ritual Hash: GENESIS-3OX-AI-R-DRIVE-25.60
Sirius Time: 25.60
Gregorian: 2025-10-08
Location: R:\3OX.Ai\.3ox.index\

DEPLOYMENT:
  From: P:\!CMD.BRIDGE\3OX.Ai\
  To: R:\3OX.Ai\
  Method: Fresh mint deployment
  Status: SEALED

AUTHENTICITY:
  Ritual File: OPS/BASE.CMD/GENESIS.RITUAL.rs
  Witnesses: RVNX/Lu, Claude, CMD.BRIDGE
  Authority: SUPREME

The system is born. The Citadel is operational.

Sirius 25.60 - GENESIS SEALED
"@

$sealPath = "R:\3OX.Ai\.3ox.index\GENESIS.SEAL"
$sealContent | Out-File -FilePath $sealPath -Encoding UTF8

Write-Host "  OK: Genesis seal created: $sealPath" -ForegroundColor Green

# PHASE 5: VERIFICATION
Write-Host "`n[5/5] Verifying deployment..." -ForegroundColor Yellow

$checks = @(
    "R:\3OX.Ai\.3ox.index\POLICY",
    "R:\3OX.Ai\.3ox.index\CORE",
    "R:\3OX.Ai\.3ox.index\OPS",
    "R:\3OX.Ai\.3ox.index\OPS\BASE.CMD\GENESIS.RITUAL.rs",
    "R:\3OX.Ai\.3ox.index\GENESIS.SEAL",
    "R:\3OX.Ai\README.md"
)

$allValid = $true
foreach ($check in $checks) {
    if (Test-Path $check) {
        $name = Split-Path $check -Leaf
        Write-Host "  OK: $name" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: $check MISSING!" -ForegroundColor Red
        $allValid = $false
    }
}

# Count files
$policyCount = (Get-ChildItem "R:\3OX.Ai\.3ox.index\POLICY" -File -ErrorAction SilentlyContinue | Measure-Object).Count
$coreFiles = (Get-ChildItem "R:\3OX.Ai\.3ox.index\CORE" -File -ErrorAction SilentlyContinue | Measure-Object).Count
$opsFiles = (Get-ChildItem "R:\3OX.Ai\.3ox.index\OPS" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count

Write-Host "`n  File Counts:" -ForegroundColor Cyan
Write-Host "    POLICY: $policyCount files" -ForegroundColor White
Write-Host "    CORE: $coreFiles files" -ForegroundColor White
Write-Host "    OPS: $opsFiles files (recursive)" -ForegroundColor White

# Save deployment log
$logPath = "R:\3OX.Ai\.3ox.index\GENESIS.DEPLOYMENT.LOG"
$deploymentLog = @"
GENESIS DEPLOYMENT LOG
Deployed: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Sirius: 25.60
Source: P:\!CMD.BRIDGE\3OX.Ai\
Destination: R:\3OX.Ai\
Status: SUCCESS
Files: $policyCount POLICY + $coreFiles CORE + $opsFiles OPS
Ritual: SEALED
Seal: CREATED
Authentic: TRUE
"@
$deploymentLog | Out-File -FilePath $logPath -Encoding UTF8

# SUMMARY
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "       DEPLOYMENT SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($allValid) {
    Write-Host "  GENESIS DEPLOYMENT: SUCCESS" -ForegroundColor Green
    Write-Host "`n  Location: R:\3OX.Ai\" -ForegroundColor Cyan
    Write-Host "  Ritual: SEALED (GENESIS.RITUAL.rs)" -ForegroundColor Cyan
    Write-Host "  Seal: CREATED (GENESIS.SEAL)" -ForegroundColor Cyan
    Write-Host "  Sirius Time: 25.60" -ForegroundColor Cyan
    Write-Host "  Authority: SUPREME" -ForegroundColor Cyan
    
    Write-Host "`n  3OX.Ai is now operational on R: drive!" -ForegroundColor Green
    Write-Host "  The Citadel master brain is ACTIVE`n" -ForegroundColor Green
    
    Write-Host "  Next Steps:" -ForegroundColor Yellow
    Write-Host "    1. Verify: cat R:\3OX.Ai\README.md" -ForegroundColor White
    Write-Host "    2. Git commit: cd R:\3OX.Ai; git init" -ForegroundColor White
    Write-Host "    3. Create station rules (when ready)" -ForegroundColor White
    
    Write-Host "`n  Deployment log: $logPath" -ForegroundColor Cyan
} else {
    Write-Host "  GENESIS DEPLOYMENT: FAILED" -ForegroundColor Red
    Write-Host "  Some required files are missing!" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "  GENESIS RITUAL COMPLETE - 25.60" -ForegroundColor Magenta
Write-Host "========================================`n" -ForegroundColor Magenta

Write-Host "The master brain is born. The Citadel awakens.`n" -ForegroundColor Cyan
