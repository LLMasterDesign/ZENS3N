<#
.SYNOPSIS
    1N.3OX COMMAND CENTER - 3 MEMORY BANK MONITOR
.DESCRIPTION
    Live monitoring dashboard for all CAT folders across OBSIDIAN, RVNx, and SYNTH
    Real-time updates every 5 seconds
#>

# Configuration
$BASE_PATH = "P:\!CMD.BRIDGE"
$REFRESH_RATE = 15

# Memory Banks
$BANKS = @(
    @{Name="OBSIDIAN"; Path="OBSIDIAN.BASE"; Color="Cyan"}
    @{Name="RVNx";     Path="RVNx.BASE";     Color="Magenta"}
    @{Name="SYNTH";    Path="SYNTH.BASE";    Color="Yellow"}
)

# CAT Definitions
$CATS = @(
    @{Num="1"; Name="SELF";     Folder="(CAT.1) Self";     Icon="[SELF]"; Color="Cyan"}
    @{Num="2"; Name="SCHOOL";   Folder="(CAT.2) School";   Icon="[SCHL]"; Color="Blue"}
    @{Num="3"; Name="BUSINESS"; Folder="(CAT.3) Business"; Icon="[BSNS]"; Color="Green"}
    @{Num="4"; Name="FAMILY";   Folder="(CAT.4) Family";   Icon="[FMLY]"; Color="Magenta"}
    @{Num="5"; Name="SOCIAL";   Folder="(CAT.5) Social";   Icon="[SOCL]"; Color="Yellow"}
)

# Initialize
$Host.UI.RawUI.WindowTitle = "1N.3OX COMMAND CENTER - 3 MEMORY BANKS"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Green"
Clear-Host

function Write-Header {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor DarkGreen
    Write-Host "  1N.3OX COMMAND CENTER - 3 MEMORY BANK MONITOR" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor DarkGreen
    Write-Host "  Triangle . Dots . Ring" -ForegroundColor DarkCyan
    Write-Host "  OBSIDIAN <=> RVNx <=> SYNTH" -ForegroundColor DarkCyan
    Write-Host "================================================================" -ForegroundColor DarkGreen
    Write-Host ""
}

function Get-CATStats {
    param([string]$BankPath, [hashtable]$Cat)
    
    $catPath = Join-Path $BASE_PATH "$BankPath\$($Cat.Folder)"
    
    if (-not (Test-Path $catPath)) {
        return @{Files=0; Size=0; LastActivity="N/A"; Status="OFFLINE"; IntakeFiles=0}
    }
    
    $intakePath = Join-Path $catPath "1n.3ox $($Cat.Name)"
    $allFiles = 0
    $totalSize = 0
    $intakeFiles = 0
    $lastActivity = "IDLE"
    
    if (Test-Path $intakePath) {
        $files = Get-ChildItem -Path $intakePath -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "*.log" -and $_.FullName -notlike "*\.3ox\*" }
        $intakeFiles = $files.Count
        $allFiles = $files.Count
        $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
        
        if ($files.Count -gt 0) {
            $lastFile = $files | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $lastActivity = $lastFile.LastWriteTime.ToString("HH:mm:ss")
        }
    }
    
    $status = if ($intakeFiles -gt 0) { "ACTIVE" } elseif (Test-Path $intakePath) { "READY" } else { "OFFLINE" }
    
    return @{
        Files = $allFiles
        IntakeFiles = $intakeFiles
        Size = $totalSize
        LastActivity = $lastActivity
        Status = $status
    }
}

function Format-FileSize {
    param([long]$Bytes)
    
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}

function Write-BankStatus {
    param([hashtable]$Bank)
    
    $bankPath = Join-Path $BASE_PATH $Bank.Path
    $bankOnline = Test-Path $bankPath
    
    Write-Host ""
    Write-Host "  $($Bank.Name) MEMORY BANK " -ForegroundColor $Bank.Color -NoNewline
    if ($bankOnline) {
        Write-Host "[ONLINE]" -ForegroundColor Green
    } else {
        Write-Host "[OFFLINE]" -ForegroundColor Red
    }
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
    
    if (-not $bankOnline) {
        Write-Host "  Bank offline - path not found" -ForegroundColor DarkGray
        return
    }
    
    foreach ($cat in $script:CATS) {
        $stats = Get-CATStats -BankPath $Bank.Path -Cat $cat
        
        $statusColor = "White"
        if ($stats.Status -eq "ACTIVE") { $statusColor = "Green" }
        elseif ($stats.Status -eq "READY") { $statusColor = "Cyan" }
        elseif ($stats.Status -eq "OFFLINE") { $statusColor = "DarkGray" }
        
        $barLength = [Math]::Min([Math]::Max($stats.IntakeFiles, 0), 10)
        $bar = ("#" * $barLength) + (" " * (10 - $barLength))
        
        $fileCount = $stats.IntakeFiles.ToString().PadLeft(3)
        $sizeStr = (Format-FileSize $stats.Size).PadLeft(10)
        $statusStr = $stats.Status.PadRight(7)
        
        Write-Host "  " -NoNewline
        Write-Host $cat.Icon -ForegroundColor $cat.Color -NoNewline
        Write-Host " CAT.$($cat.Num) $($cat.Name.PadRight(8)) " -NoNewline
        Write-Host "[$bar] " -ForegroundColor DarkGreen -NoNewline
        Write-Host "$fileCount files | " -NoNewline
        Write-Host "$sizeStr " -NoNewline
        Write-Host "| " -NoNewline
        Write-Host "$statusStr" -ForegroundColor $statusColor -NoNewline
        Write-Host " | Last: $($stats.LastActivity)" -ForegroundColor DarkCyan
    }
}

function Write-SystemSummary {
    $totalFiles = 0
    $totalSize = 0
    $activeCats = 0
    
    foreach ($bank in $script:BANKS) {
        $bankPath = Join-Path $BASE_PATH $bank.Path
        if (Test-Path $bankPath) {
            foreach ($cat in $script:CATS) {
                $stats = Get-CATStats -BankPath $bank.Path -Cat $cat
                $totalFiles += $stats.Files
                $totalSize += $stats.Size
                if ($stats.Status -eq "ACTIVE") { $activeCats++ }
            }
        }
    }
    
    Write-Host "  SYSTEM SUMMARY:" -ForegroundColor Green
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
    
    $sizeFormatted = Format-FileSize $totalSize
    $activeColor = if ($activeCats -gt 0) { "Green" } else { "DarkGray" }
    
    Write-Host "  Total Files:  " -NoNewline
    Write-Host "$totalFiles files" -ForegroundColor Cyan -NoNewline
    Write-Host "  |  Total Size:  " -NoNewline
    Write-Host "$sizeFormatted" -ForegroundColor Cyan
    
    Write-Host "  Active CATs:  " -NoNewline
    Write-Host "$activeCats of 15" -ForegroundColor $activeColor -NoNewline
    Write-Host "  |  Memory Banks:  " -NoNewline
    Write-Host "3 online" -ForegroundColor Green
}

function Write-Footer {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor DarkGreen
    Write-Host "  Refreshing every $REFRESH_RATE seconds... | Press Ctrl+C to exit" -ForegroundColor DarkGray
    Write-Host "================================================================" -ForegroundColor DarkGreen
}

# Main Loop
try {
    while ($true) {
        Clear-Host
        Write-Header
        Write-SystemSummary
        
        foreach ($bank in $BANKS) {
            Write-BankStatus -Bank $bank
        }
        
        Write-Footer
        Start-Sleep -Seconds $REFRESH_RATE
    }
} catch {
    Write-Host ""
    Write-Host "Shutting down command center..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}
