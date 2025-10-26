# R: Drive Validation Script
# Validates R: drive is ready for .3ox system without migrating data
# Created: 2024-10-08

Write-Host "`n=== R: DRIVE VALIDATION ===" -ForegroundColor Cyan
Write-Host "=" * 50

# Test 1: Check if R: exists
Write-Host "`n[1/6] Checking if R: drive exists..." -ForegroundColor Yellow
if (Test-Path "R:\") {
    Write-Host "  [OK] R: drive is mounted" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] R: drive NOT found" -ForegroundColor Red
    Write-Host "  >> Create R: drive first in Disk Management" -ForegroundColor Yellow
    exit 1
}

# Test 2: Check file system
Write-Host "`n[2/6] Checking file system..." -ForegroundColor Yellow
$volume = Get-Volume -DriveLetter R -ErrorAction SilentlyContinue
if ($volume) {
    Write-Host "  File System: $($volume.FileSystem)" -ForegroundColor Cyan
    Write-Host "  Label: $($volume.FileSystemLabel)" -ForegroundColor Cyan
    Write-Host "  Health: $($volume.HealthStatus)" -ForegroundColor Cyan
    
    if ($volume.FileSystem -eq "NTFS") {
        Write-Host "  [OK] NTFS confirmed (correct format)" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Not NTFS - recommend reformatting" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [FAIL] Cannot read volume information" -ForegroundColor Red
    exit 1
}

# Test 3: Check space
Write-Host "`n[3/6] Checking available space..." -ForegroundColor Yellow
$totalGB = [math]::Round($volume.Size / 1GB, 2)
$freeGB = [math]::Round($volume.SizeRemaining / 1GB, 2)
$usedGB = [math]::Round(($volume.Size - $volume.SizeRemaining) / 1GB, 2)

Write-Host "  Total: $totalGB GB" -ForegroundColor Cyan
Write-Host "  Used: $usedGB GB" -ForegroundColor Cyan
Write-Host "  Free: $freeGB GB" -ForegroundColor Cyan

if ($freeGB -gt 10) {
    Write-Host "  [OK] Sufficient space for .3ox system" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Low space - may need larger drive" -ForegroundColor Yellow
}

# Test 4: Test write permissions
Write-Host "`n[4/6] Testing write permissions..." -ForegroundColor Yellow
try {
    $testFile = "R:\.3ox_validation_test.tmp"
    "3OX System Test" | Out-File -FilePath $testFile -ErrorAction Stop
    
    if (Test-Path $testFile) {
        Remove-Item $testFile -ErrorAction SilentlyContinue
        Write-Host "  [OK] Write permissions OK" -ForegroundColor Green
    }
} catch {
    Write-Host "  [FAIL] Cannot write to R: drive" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 5: Check BitLocker status
Write-Host "`n[5/6] Checking BitLocker status..." -ForegroundColor Yellow
try {
    $bitlocker = Get-BitLockerVolume -MountPoint "R:" -ErrorAction SilentlyContinue
    if ($bitlocker) {
        Write-Host "  Protection: $($bitlocker.ProtectionStatus)" -ForegroundColor Cyan
        Write-Host "  Encryption: $($bitlocker.VolumeStatus)" -ForegroundColor Cyan
        
        if ($bitlocker.ProtectionStatus -eq "On") {
            Write-Host "  [OK] BitLocker enabled" -ForegroundColor Green
        } else {
            Write-Host "  [INFO] BitLocker not enabled (can enable later)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "  [INFO] BitLocker not enabled (optional)" -ForegroundColor White
}

# Test 6: Calculate CMD.BRIDGE migration size
Write-Host "`n[6/6] Checking CMD.BRIDGE size..." -ForegroundColor Yellow
if (Test-Path "P:\!CMD.BRIDGE") {
    $cmdSize = (Get-ChildItem "P:\!CMD.BRIDGE" -Recurse -ErrorAction SilentlyContinue | 
                Measure-Object -Property Length -Sum).Sum / 1GB
    $cmdSizeGB = [math]::Round($cmdSize, 2)
    
    Write-Host "  P:\!CMD.BRIDGE size: $cmdSizeGB GB" -ForegroundColor Cyan
    
    if ($cmdSizeGB -lt $freeGB) {
        Write-Host "  [OK] R: has enough space for migration" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Not enough space on R:" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n" + ("=" * 50)
Write-Host "=== VALIDATION SUMMARY ===" -ForegroundColor Cyan
Write-Host ("=" * 50)

Write-Host "`nR: Drive Status:" -ForegroundColor White
Write-Host "  Drive: R:\" -ForegroundColor Cyan
Write-Host "  Format: $($volume.FileSystem)" -ForegroundColor Cyan
Write-Host "  Label: $($volume.FileSystemLabel)" -ForegroundColor Cyan
Write-Host "  Capacity: $totalGB GB" -ForegroundColor Cyan
Write-Host "  Available: $freeGB GB" -ForegroundColor Cyan
Write-Host "  Health: $($volume.HealthStatus)" -ForegroundColor Cyan

Write-Host "`nReady for Migration:" -ForegroundColor White
if ($volume.FileSystem -eq "NTFS" -and $freeGB -gt 10 -and $volume.HealthStatus -eq "Healthy") {
    Write-Host "  [YES] R: drive is ready for .3ox system" -ForegroundColor Green
    Write-Host "`n  Next steps:" -ForegroundColor Yellow
    Write-Host "    1. Review this validation" -ForegroundColor White
    Write-Host "    2. When ready, run migration script" -ForegroundColor White
    Write-Host "    3. Update routing configs" -ForegroundColor White
} else {
    Write-Host "  [WARN] Review issues above before migrating" -ForegroundColor Yellow
}

Write-Host "`n*** Validation complete - NO data was moved ***`n" -ForegroundColor Green
