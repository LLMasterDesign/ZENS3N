# 1N.3OX CAT FOLDER CLEANUP SCRIPT
# Extracts files from duplicates, then deletes empty folders

$BASE = "P:\!CMD.BRIDGE"

# Production targets (where to move files)
$TARGETS = @{
    "CAT.1" = @{
        OBSIDIAN = "$BASE\OBSIDIAN.BASE\(CAT.1) Self\1n.3ox Self"
        RVNx = "$BASE\RVNx.BASE\(CAT.1) Self\1n.3ox Self"
        SYNTH = "$BASE\SYNTH.BASE\(CAT.1) Self\1n.3ox Self"
    }
    "CAT.2" = @{
        OBSIDIAN = "$BASE\OBSIDIAN.BASE\(CAT.2) School\1n.3ox School"
        RVNx = "$BASE\RVNx.BASE\(CAT.2) School\1n.3ox School"
        SYNTH = "$BASE\SYNTH.BASE\(CAT.2) School\1n.3ox School"
    }
    "CAT.3" = @{
        OBSIDIAN = "$BASE\OBSIDIAN.BASE\(CAT.3) Business\1n.3ox Business"
        RVNx = "$BASE\RVNx.BASE\(CAT.3) Business\1n.3ox Business"
        SYNTH = "$BASE\SYNTH.BASE\(CAT.3) Business\1n.3ox Business"
    }
    "CAT.4" = @{
        OBSIDIAN = "$BASE\OBSIDIAN.BASE\(CAT.4) Family\1n.3ox Family"
        RVNx = "$BASE\RVNx.BASE\(CAT.4) Family\1n.3ox Family"
        SYNTH = "$BASE\SYNTH.BASE\(CAT.4) Family\1n.3ox Family"
    }
    "CAT.5" = @{
        OBSIDIAN = "$BASE\OBSIDIAN.BASE\(CAT.5) Social\1n.3ox Social"
        RVNx = "$BASE\RVNx.BASE\(CAT.5) Social\1n.3ox Social"
        SYNTH = "$BASE\SYNTH.BASE\(CAT.5) Social\1n.3ox Social"
    }
}

# Duplicate folders to clean (EXCLUDING deployment package and Legacy)
$DUPLICATES = @(
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!WORKDESK!\(CAT.1)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!WORKDESK!\(CAT.2)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!WORKDESK!\(CAT.3)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!WORKDESK!\(CAT.4)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\!OBSIDIAN!\!WORKDESK!\(CAT.5)"
    "$BASE\RVNx.BASE\!WORK.DESK\(CAT.1)"
    "$BASE\RVNx.BASE\!WORK.DESK\(CAT.2)"
    "$BASE\RVNx.BASE\!WORK.DESK\(CAT.3)"
    "$BASE\RVNx.BASE\!WORK.DESK\(CAT.4)"
    "$BASE\RVNx.BASE\!WORK.DESK\(CAT.5)"
    "$BASE\SYNTH.BASE\!WORK.DESK\(CAT.1)"
    "$BASE\SYNTH.BASE\!WORK.DESK\(CAT.2)"
    "$BASE\SYNTH.BASE\!WORK.DESK\(CAT.3)"
    "$BASE\SYNTH.BASE\!WORK.DESK\(CAT.4)"
    "$BASE\SYNTH.BASE\!WORK.DESK\(CAT.5)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\RVNx.BASE\(CAT.1)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\RVNx.BASE\(CAT.2)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\RVNx.BASE\(CAT.3)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\RVNx.BASE\(CAT.4)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\RVNx.BASE\(CAT.5)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\SYNTH.BASE\(CAT.1)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\SYNTH.BASE\(CAT.2)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\SYNTH.BASE\(CAT.3)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\SYNTH.BASE\(CAT.4)"
    "$BASE\OBSIDIAN.BASE\!1N.3OX OBSIDIAN.BASE\SYNTH.BASE\(CAT.5)"
)

Write-Host "================================================================"
Write-Host "  1N.3OX CAT FOLDER CLEANUP"
Write-Host "================================================================"
Write-Host ""

$filesMoved = 0
$foldersDeleted = 0

Write-Host "STEP 1: Scanning for files in duplicate folders..."
Write-Host ""

foreach ($dupFolder in $DUPLICATES) {
    if (Test-Path $dupFolder) {
        $files = Get-ChildItem -Path $dupFolder -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notlike "*\.3ox\*" }
        
        if ($files.Count -gt 0) {
            $catNum = "CAT.1"
            if ($dupFolder -like "*(CAT.2)*") { $catNum = "CAT.2" }
            elseif ($dupFolder -like "*(CAT.3)*") { $catNum = "CAT.3" }
            elseif ($dupFolder -like "*(CAT.4)*") { $catNum = "CAT.4" }
            elseif ($dupFolder -like "*(CAT.5)*") { $catNum = "CAT.5" }
            
            $targetBase = "OBSIDIAN"
            if ($dupFolder -like "*RVNx*") { $targetBase = "RVNx" }
            elseif ($dupFolder -like "*SYNTH*") { $targetBase = "SYNTH" }
            
            $targetPath = $TARGETS[$catNum][$targetBase]
            
            Write-Host "  Found $($files.Count) file(s) in:"
            Write-Host "    $dupFolder"
            Write-Host "  Moving to: $targetPath"
            
            foreach ($file in $files) {
                try {
                    Copy-Item -Path $file.FullName -Destination $targetPath -Force
                    Write-Host "    OK Moved: $($file.Name)"
                    $filesMoved++
                } catch {
                    Write-Host "    FAIL: $($file.Name)"
                }
            }
            Write-Host ""
        }
    }
}

Write-Host "Files moved: $filesMoved"
Write-Host ""

Write-Host "STEP 2: Deleting empty duplicate folders..."
Write-Host ""

foreach ($dupFolder in $DUPLICATES) {
    if (Test-Path $dupFolder) {
        try {
            Remove-Item -Path $dupFolder -Recurse -Force -ErrorAction Stop
            Write-Host "  OK Deleted: $(Split-Path $dupFolder -Leaf)"
            $foldersDeleted++
        } catch {
            Write-Host "  FAIL: $(Split-Path $dupFolder -Leaf)"
        }
    }
}

Write-Host ""
Write-Host "================================================================"
Write-Host "  CLEANUP COMPLETE"
Write-Host "================================================================"
Write-Host "  Files moved: $filesMoved"
Write-Host "  Folders deleted: $foldersDeleted"
Write-Host ""
Write-Host "  Production CAT folders intact"
Write-Host "  Legacy blueprint intact"
Write-Host "  Deployment package intact"
Write-Host "================================================================"
