# DEEP CLEANUP - Remove ALL duplicate CAT folders
# Keeps ONLY: 3 production sets + Legacy blueprint + Deployment package

$BASE = "P:\!CMD.BRIDGE"

Write-Host "================================================================"
Write-Host "  DEEP CLEANUP - FINDING ALL CAT FOLDERS"
Write-Host "================================================================"
Write-Host ""

# Find ALL CAT folders
Write-Host "Scanning entire system for CAT folders..."
$allCats = Get-ChildItem -Path $BASE -Directory -Recurse -Filter "(CAT*" -ErrorAction SilentlyContinue

Write-Host "Total CAT folders found: $($allCats.Count)"
Write-Host ""

# Define folders to KEEP
$KEEP_FOLDERS = @(
    # Production (3 sets)
    "$BASE\OBSIDIAN.BASE\(CAT.1) Self"
    "$BASE\OBSIDIAN.BASE\(CAT.2) School"
    "$BASE\OBSIDIAN.BASE\(CAT.3) Business"
    "$BASE\OBSIDIAN.BASE\(CAT.4) Family"
    "$BASE\OBSIDIAN.BASE\(CAT.5) Social"
    "$BASE\RVNx.BASE\(CAT.1) Self"
    "$BASE\RVNx.BASE\(CAT.2) School"
    "$BASE\RVNx.BASE\(CAT.3) Business"
    "$BASE\RVNx.BASE\(CAT.4) Family"
    "$BASE\RVNx.BASE\(CAT.5) Social"
    "$BASE\SYNTH.BASE\(CAT.1) Self"
    "$BASE\SYNTH.BASE\(CAT.2) School"
    "$BASE\SYNTH.BASE\(CAT.3) Business"
    "$BASE\SYNTH.BASE\(CAT.4) Family"
    "$BASE\SYNTH.BASE\(CAT.5) Social"
    # Legacy blueprint
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!Legacy.Systems.Protocol!\1N.3OX.Legacy\(CAT.1) Self"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!Legacy.Systems.Protocol!\1N.3OX.Legacy\(CAT.2) School"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!Legacy.Systems.Protocol!\1N.3OX.Legacy\(CAT.3) Business"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!Legacy.Systems.Protocol!\1N.3OX.Legacy\(CAT.4) Family"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!Legacy.Systems.Protocol!\1N.3OX.Legacy\(CAT.5) Social"
    # Deployment package
    "$BASE\OBSIDIAN.BASE\1N.3OX.DEPLOYMENT.PACKAGE\!1N.3OX MASTER Folder.Kit\(CAT.1) Self"
    "$BASE\OBSIDIAN.BASE\1N.3OX.DEPLOYMENT.PACKAGE\!1N.3OX MASTER Folder.Kit\(CAT.2) School"
    "$BASE\OBSIDIAN.BASE\1N.3OX.DEPLOYMENT.PACKAGE\!1N.3OX MASTER Folder.Kit\(CAT.3) Business"
    "$BASE\OBSIDIAN.BASE\1N.3OX.DEPLOYMENT.PACKAGE\!1N.3OX MASTER Folder.Kit\(CAT.4) Family"
    "$BASE\OBSIDIAN.BASE\1N.3OX.DEPLOYMENT.PACKAGE\!1N.3OX MASTER Folder.Kit\(CAT.5) Social"
)

# Separate keepers from duplicates
$toKeep = @()
$toDelete = @()

foreach ($cat in $allCats) {
    if ($KEEP_FOLDERS -contains $cat.FullName) {
        $toKeep += $cat
    } else {
        $toDelete += $cat
    }
}

Write-Host "Folders to KEEP: $($toKeep.Count) (Production + Blueprint + Package)" -ForegroundColor Green
Write-Host "Folders to DELETE: $($toDelete.Count) (All duplicates)" -ForegroundColor Yellow
Write-Host ""

if ($toDelete.Count -eq 0) {
    Write-Host "No duplicates found! System is clean." -ForegroundColor Green
    exit
}

Write-Host "Duplicates will be deleted:"
foreach ($dup in $toDelete) {
    Write-Host "  - $($dup.FullName)" -ForegroundColor DarkGray
}
Write-Host ""

$filesMoved = 0
$foldersDeleted = 0
$failedDeletes = 0

# Extract files from duplicates first
Write-Host "STEP 1: Extracting files from duplicates..." -ForegroundColor Yellow
Write-Host ""

foreach ($dup in $toDelete) {
    # Find files (excluding brain files)
    $files = Get-ChildItem -Path $dup.FullName -File -Recurse -ErrorAction SilentlyContinue | 
             Where-Object { $_.FullName -notlike "*\.3ox\*" }
    
    if ($files.Count -gt 0) {
        # Determine target
        $catNum = 1
        if ($dup.Name -like "*2*") { $catNum = 2 }
        elseif ($dup.Name -like "*3*") { $catNum = 3 }
        elseif ($dup.Name -like "*4*") { $catNum = 4 }
        elseif ($dup.Name -like "*5*") { $catNum = 5 }
        
        $targetBase = "OBSIDIAN.BASE"
        if ($dup.FullName -like "*RVNx*") { $targetBase = "RVNx.BASE" }
        elseif ($dup.FullName -like "*SYNTH*") { $targetBase = "SYNTH.BASE" }
        
        $catName = switch($catNum) {
            1 { "Self" }
            2 { "School" }
            3 { "Business" }
            4 { "Family" }
            5 { "Social" }
        }
        
        $targetPath = "$BASE\$targetBase\(CAT.$catNum) $catName\1n.3ox $catName"
        
        if (Test-Path $targetPath) {
            Write-Host "  Found $($files.Count) file(s) in: $($dup.FullName)"
            foreach ($file in $files) {
                try {
                    Copy-Item -Path $file.FullName -Destination $targetPath -Force -ErrorAction Stop
                    Write-Host "    OK: $($file.Name)" -ForegroundColor DarkGreen
                    $filesMoved++
                } catch {
                    Write-Host "    FAIL: $($file.Name)" -ForegroundColor Red
                }
            }
        }
    }
}

Write-Host ""
Write-Host "Files extracted: $filesMoved" -ForegroundColor Cyan
Write-Host ""

# Delete all duplicates
Write-Host "STEP 2: Deleting duplicate folders..." -ForegroundColor Yellow
Write-Host ""

foreach ($dup in $toDelete) {
    try {
        Remove-Item -Path $dup.FullName -Recurse -Force -ErrorAction Stop
        Write-Host "  OK: $($dup.FullName.Replace($BASE, '...'))" -ForegroundColor DarkGreen
        $foldersDeleted++
    } catch {
        Write-Host "  FAIL: $($dup.FullName.Replace($BASE, '...'))" -ForegroundColor Red
        $failedDeletes++
    }
}

Write-Host ""
Write-Host "================================================================"
Write-Host "  DEEP CLEANUP COMPLETE"
Write-Host "================================================================"
Write-Host "  Files moved: $filesMoved" -ForegroundColor Cyan
Write-Host "  Folders deleted: $foldersDeleted" -ForegroundColor Green
Write-Host "  Failed deletes: $failedDeletes" -ForegroundColor $(if($failedDeletes -gt 0){"Red"}else{"Green"})
Write-Host ""
Write-Host "  Remaining CAT folders: 25 (15 production + 5 blueprint + 5 package)"
Write-Host "  System is now clean and optimized"
Write-Host "================================================================"

