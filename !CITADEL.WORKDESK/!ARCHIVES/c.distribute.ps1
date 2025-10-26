<#
.SYNOPSIS
  CMD.BRIDGE distribution center - Routes files to Lighthouse

.DESCRIPTION
  Receives files from station 0ut.3ox folders (via Git) and distributes to:
  - 7HE LIGHTHOUSE library
  - Appropriate station folders
  
  Validates receipts and creates distribution records.

.PARAMETER StationName
  Name of the station to pull from (e.g., "RVNx.BASE", "SYNTH.BASE")

.EXAMPLE
  .\c.distribute.ps1 -StationName "RVNx.BASE"

.NOTES
  Created by: AI (Cursor)
  Date: ⧗-25.61
  Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$StationName = ""
)

$SCRIPT_VERSION = "1.0"

# Paths
$CMD_ROOT = "P:\!CMD.BRIDGE"
$LIGHTHOUSE = "$CMD_ROOT\OBSIDIAN.BASE\(CAT.7) 7HE LIGHTHOUSE"
$LIGHTHOUSE_IN = "$LIGHTHOUSE\1n.0ut.3ox"
$LIGHTHOUSE_LIBRARY = "$LIGHTHOUSE\LIBRARY"

function Write-Header {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host "  📡 CMD DISTRIBUTION CENTER v$SCRIPT_VERSION" -ForegroundColor Magenta
    Write-Host "  Routing files to Lighthouse..." -ForegroundColor Magenta
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host ""
}

function Get-SiriusTime {
    $RESET = Get-Date "2025-08-08"
    $now = Get-Date
    $days = ($now - $RESET).Days
    $year = $now.Year % 100
    return "⧗-$year.$days"
}

function Get-AllStations {
    # Get all station folders that have 0ut.3ox
    $stations = Get-ChildItem -Path $CMD_ROOT -Directory | Where-Object {
        Test-Path "$($_.FullName)\0ut.3ox"
    }
    return $stations
}

function Process-StationFiles {
    param([string]$StationPath)
    
    $stationName = Split-Path $StationPath -Leaf
    $out3ox = "$StationPath\0ut.3ox"
    
    # Get all files (exclude .SENT and receipts)
    $files = Get-ChildItem -Path $out3ox -File | Where-Object {
        $_.Name -notlike "*.receipt.*" -and
        $_.Extension -ne ".bat" -and
        $_.Extension -ne ".ps1"
    }
    
    if ($files.Count -eq 0) {
        return 0
    }
    
    Write-Host "   📦 Processing $stationName..." -ForegroundColor Cyan
    
    $distributed = 0
    foreach ($file in $files) {
        # Check for receipt
        $receiptPath = "$out3ox\$($file.Name).receipt.yaml"
        $hasReceipt = Test-Path $receiptPath
        
        if (-not $hasReceipt) {
            Write-Host "   ⚠️  $($file.Name) - No receipt! Skipping." -ForegroundColor Yellow
            continue
        }
        
        # Read receipt to get hash
        $receiptContent = Get-Content $receiptPath -Raw
        $hash = if ($receiptContent -match 'sha256:\s*(.+)') { $matches[1].Trim() } else { "UNKNOWN" }
        
        # Verify hash
        $currentHash = (Get-FileHash $file.FullName -Algorithm SHA256).Hash
        if ($hash -ne $currentHash) {
            Write-Host "   ❌ $($file.Name) - Hash mismatch! File corrupted!" -ForegroundColor Red
            continue
        }
        
        # Determine destination
        $destFolder = "$LIGHTHOUSE_LIBRARY\FROM-$stationName"
        if (-not (Test-Path $destFolder)) {
            New-Item -ItemType Directory -Path $destFolder -Force | Out-Null
        }
        
        # Copy file to Lighthouse
        Copy-Item -Path $file.FullName -Destination $destFolder -Force
        
        # Create distribution receipt
        $distReceipt = @"
type: distribution_receipt
file: $($file.Name)
sha256: $currentHash
timestamp: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
sirius_time: $(Get-SiriusTime)
from_station: $stationName
to_location: LIGHTHOUSE/LIBRARY/FROM-$stationName
status: DISTRIBUTED
operator: c.distribute.ps1
"@
        $distReceipt | Out-File "$destFolder\$($file.Name).dist.receipt.yaml" -Encoding UTF8
        
        # Archive original
        $sentFolder = "$out3ox\.SENT"
        if (-not (Test-Path $sentFolder)) {
            New-Item -ItemType Directory -Path $sentFolder -Force | Out-Null
        }
        Move-Item -Path $file.FullName -Destination $sentFolder -Force
        Move-Item -Path $receiptPath -Destination $sentFolder -Force
        
        Write-Host "   ✅ $($file.Name) → LIGHTHOUSE" -ForegroundColor Green
        Write-Host "      Hash: $($currentHash.Substring(0,16))..." -ForegroundColor Gray
        
        $distributed++
    }
    
    return $distributed
}

# Main execution
try {
    Write-Header
    
    $totalDistributed = 0
    
    if ($StationName) {
        # Process specific station
        $stationPath = "$CMD_ROOT\$StationName"
        if (-not (Test-Path $stationPath)) {
            Write-Host "❌ Station not found: $StationName" -ForegroundColor Red
            exit 1
        }
        $totalDistributed = Process-StationFiles -StationPath $stationPath
    } else {
        # Process all stations
        Write-Host "🔍 Scanning all stations..." -ForegroundColor Cyan
        Write-Host ""
        
        $stations = Get-AllStations
        foreach ($station in $stations) {
            $count = Process-StationFiles -StationPath $station.FullName
            $totalDistributed += $count
        }
    }
    
    # Summary
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Magenta
    if ($totalDistributed -eq 0) {
        Write-Host "  📭 No files to distribute" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ DISTRIBUTION COMPLETE" -ForegroundColor Green
        Write-Host "  Files distributed: $totalDistributed" -ForegroundColor White
        Write-Host "  Location: 7HE LIGHTHOUSE/LIBRARY/" -ForegroundColor White
    }
    Write-Host "============================================================" -ForegroundColor Magenta
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}

