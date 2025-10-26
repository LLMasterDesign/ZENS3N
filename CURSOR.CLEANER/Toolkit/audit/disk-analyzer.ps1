# Disk Analyzer - Comprehensive Space Analysis
# CURSOR.CLEANER Toolkit
# Scans drives for large files, duplicates, and cleanup opportunities

param(
    [switch]$AllDrives,
    [switch]$LargeFiles,
    [switch]$Duplicates,
    [switch]$TempFiles,
    [switch]$Json,
    [int]$MinSizeMB = 100
)

Write-Host "🔍 CURSOR.CLEANER Disk Analysis" -ForegroundColor Cyan
Write-Host "=" * 50

$analysis = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    drives = @{}
    large_files = @()
    duplicates = @()
    temp_files = @()
    recommendations = @()
    total_recoverable_gb = 0
}

# Get all drives
$drives = if ($AllDrives) { 
    Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
} else { 
    Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -and $_.DeviceID -eq "C:" }
}

foreach ($drive in $drives) {
    $driveLetter = $drive.DeviceID
    Write-Host "📊 Analyzing drive $driveLetter..." -ForegroundColor Yellow
    
    $driveInfo = @{
        letter = $driveLetter
        total_gb = [math]::Round($drive.Size / 1GB, 2)
        free_gb = [math]::Round($drive.FreeSpace / 1GB, 2)
        used_gb = [math]::Round(($drive.Size - $drive.FreeSpace) / 1GB, 2)
        usage_percent = [math]::Round((($drive.Size - $drive.FreeSpace) / $drive.Size) * 100, 2)
    }
    
    $analysis.drives[$driveLetter] = $driveInfo
    
    # Find large files
    if ($LargeFiles) {
        Write-Host "  🔍 Scanning for files > $MinSizeMB MB..."
        $largeFiles = Get-ChildItem -Path "$driveLetter\" -Recurse -File -ErrorAction SilentlyContinue | 
                      Where-Object { $_.Length -gt ($MinSizeMB * 1MB) } | 
                      Sort-Object Length -Descending | 
                      Select-Object -First 20
        
        foreach ($file in $largeFiles) {
            $analysis.large_files += @{
                path = $file.FullName
                size_mb = [math]::Round($file.Length / 1MB, 2)
                size_gb = [math]::Round($file.Length / 1GB, 2)
                last_accessed = $file.LastAccessTime
                drive = $driveLetter
            }
        }
    }
    
    # Find temp files
    if ($TempFiles) {
        Write-Host "  🗑️ Scanning temp directories..."
        $tempPaths = @(
            "$env:TEMP",
            "$env:LOCALAPPDATA\Temp",
            "$driveLetter\Windows\Temp",
            "$driveLetter\Windows\SoftwareDistribution\Download",
            "$driveLetter\Windows\Prefetch"
        )
        
        foreach ($tempPath in $tempPaths) {
            if (Test-Path $tempPath) {
                $tempFiles = Get-ChildItem -Path $tempPath -Recurse -File -ErrorAction SilentlyContinue
                $totalTempSize = ($tempFiles | Measure-Object -Property Length -Sum).Sum
                
                if ($totalTempSize -gt 0) {
                    $analysis.temp_files += @{
                        path = $tempPath
                        file_count = $tempFiles.Count
                        size_mb = [math]::Round($totalTempSize / 1MB, 2)
                        size_gb = [math]::Round($totalTempSize / 1GB, 2)
                        safe_to_delete = $true
                    }
                }
            }
        }
    }
}

# Find duplicate files (simplified - would use xxHash64 in real implementation)
if ($Duplicates) {
    Write-Host "🔍 Scanning for duplicate files..." -ForegroundColor Yellow
    
    # Group files by size first (quick filter)
    $allFiles = Get-ChildItem -Path "C:\" -Recurse -File -ErrorAction SilentlyContinue | 
                Where-Object { $_.Length -gt 1MB } | 
                Group-Object Length
    
    foreach ($sizeGroup in $allFiles) {
        if ($sizeGroup.Count -gt 1) {
            # Files with same size - potential duplicates
            $analysis.duplicates += @{
                size_mb = [math]::Round($sizeGroup.Name / 1MB, 2)
                count = $sizeGroup.Count
                potential_savings_mb = [math]::Round(($sizeGroup.Count - 1) * $sizeGroup.Name / 1MB, 2)
                files = $sizeGroup.Group | Select-Object -First 5 | ForEach-Object { $_.FullName }
            }
        }
    }
}

# Generate recommendations
$recommendations = @()

# Disk space recommendations
foreach ($drive in $analysis.drives.Values) {
    if ($drive.usage_percent -gt 85) {
        $recommendations += "🔴 Drive $($drive.letter) is $($drive.usage_percent)% full - immediate cleanup needed"
    } elseif ($drive.usage_percent -gt 75) {
        $recommendations += "🟡 Drive $($drive.letter) is $($drive.usage_percent)% full - cleanup recommended"
    }
}

# Large files recommendations
$analysis.large_files | Sort-Object size_mb -Descending | Select-Object -First 5 | ForEach-Object {
    if ($_.path -like "*Windows.old*" -or $_.path -like "*WinSxS*") {
        $recommendations += "🗑️ Remove $($_.path) - saves $($_.size_gb) GB"
        $analysis.total_recoverable_gb += $_.size_gb
    } elseif ($_.path -like "*node_modules*" -or $_.path -like "*__pycache__*") {
        $recommendations += "🧹 Clean $($_.path) - saves $($_.size_gb) GB"
        $analysis.total_recoverable_gb += $_.size_gb
    }
}

# Temp files recommendations
$analysis.temp_files | ForEach-Object {
    if ($_.safe_to_delete) {
        $recommendations += "🗑️ Clean $($_.path) - saves $($_.size_gb) GB"
        $analysis.total_recoverable_gb += $_.size_gb
    }
}

# Duplicates recommendations
$analysis.duplicates | Sort-Object potential_savings_mb -Descending | Select-Object -First 3 | ForEach-Object {
    $recommendations += "📋 Remove duplicate files - saves $($_.potential_savings_mb) MB"
    $analysis.total_recoverable_gb += ($_.potential_savings_mb / 1024)
}

$analysis.recommendations = $recommendations

# Display results
if ($Json) {
    $analysis | ConvertTo-Json -Depth 3
} else {
    Write-Host "`n📊 DRIVE ANALYSIS:" -ForegroundColor Yellow
    foreach ($drive in $analysis.drives.Values) {
        Write-Host "  $($drive.letter): $($drive.used_gb) GB used / $($drive.total_gb) GB total ($($drive.usage_percent)%)"
    }
    
    Write-Host "`n🔝 LARGEST FILES:" -ForegroundColor Yellow
    $analysis.large_files | Sort-Object size_gb -Descending | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $($_.size_gb) GB - $($_.path)"
    }
    
    Write-Host "`n🗑️ TEMP FILES:" -ForegroundColor Yellow
    $analysis.temp_files | Sort-Object size_gb -Descending | ForEach-Object {
        Write-Host "  $($_.size_gb) GB - $($_.path) ($($_.file_count) files)"
    }
    
    Write-Host "`n📋 DUPLICATE FILES:" -ForegroundColor Yellow
    $analysis.duplicates | Sort-Object potential_savings_mb -Descending | Select-Object -First 3 | ForEach-Object {
        Write-Host "  $($_.potential_savings_mb) MB recoverable - $($_.count) files of $($_.size_mb) MB each"
    }
    
    Write-Host "`n💡 RECOMMENDATIONS:" -ForegroundColor Cyan
    foreach ($rec in $recommendations) {
        Write-Host "  $rec"
    }
    
    Write-Host "`n🎯 TOTAL RECOVERABLE SPACE: $([math]::Round($analysis.total_recoverable_gb, 2)) GB" -ForegroundColor Green
}

# Save analysis
$outputDir = "!0UT.CLEANER\reports"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "$outputDir\disk_analysis_$timestamp.json"
$analysis | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Green





