# Temp Hunter - Aggressive Temp File Discovery
# CURSOR.CLEANER Toolkit
# Finds all temporary files and cache directories

param(
    [switch]$AllUsers,
    [switch]$SystemTemp,
    [switch]$BrowserCache,
    [switch]$DevCache,
    [switch]$Json,
    [int]$MinAgeDays = 1
)

Write-Host "🗑️ CURSOR.CLEANER Temp File Hunter" -ForegroundColor Cyan
Write-Host "=" * 50

$analysis = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    temp_locations = @()
    total_files = 0
    total_size_mb = 0
    total_size_gb = 0
    safe_to_delete = @()
    recommendations = @()
}

# Define temp locations to scan
$tempLocations = @()

if ($AllUsers) {
    $tempLocations += @(
        "$env:TEMP",
        "$env:LOCALAPPDATA\Temp",
        "C:\Windows\Temp",
        "C:\Windows\SoftwareDistribution\Download",
        "C:\Windows\Prefetch",
        "C:\Windows\Logs",
        "C:\Windows\Panther"
    )
} else {
    $tempLocations += @(
        "$env:TEMP",
        "$env:LOCALAPPDATA\Temp"
    )
}

if ($SystemTemp) {
    $tempLocations += @(
        "C:\Windows\Temp",
        "C:\Windows\SoftwareDistribution\Download",
        "C:\Windows\Prefetch",
        "C:\Windows\Logs",
        "C:\Windows\Panther"
    )
}

if ($BrowserCache) {
    $tempLocations += @(
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
        "$env:LOCALAPPDATA\Microsoft\Windows\WebCache",
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2"
    )
}

if ($DevCache) {
    $tempLocations += @(
        "$env:LOCALAPPDATA\npm-cache",
        "$env:LOCALAPPDATA\yarn-cache",
        "$env:LOCALAPPDATA\pip\cache",
        "$env:LOCALAPPDATA\gem\cache",
        "$env:LOCALAPPDATA\NuGet\cache"
    )
}

# Scan each location
foreach ($location in $tempLocations) {
    if (Test-Path $location) {
        Write-Host "🔍 Scanning: $location" -ForegroundColor Yellow
        
        try {
            $files = Get-ChildItem -Path $location -Recurse -File -ErrorAction SilentlyContinue | 
                     Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$MinAgeDays) }
            
            $fileCount = $files.Count
            $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
            $sizeMB = [math]::Round($totalSize / 1MB, 2)
            $sizeGB = [math]::Round($totalSize / 1GB, 2)
            
            $locationInfo = @{
                path = $location
                file_count = $fileCount
                size_mb = $sizeMB
                size_gb = $sizeGB
                safe_to_delete = $true
                last_modified = if ($files) { ($files | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime } else { $null }
            }
            
            $analysis.temp_locations += $locationInfo
            $analysis.total_files += $fileCount
            $analysis.total_size_mb += $sizeMB
            $analysis.total_size_gb += $sizeGB
            
            if ($sizeMB -gt 10) {
                $analysis.safe_to_delete += $locationInfo
            }
            
        } catch {
            Write-Host "  ⚠️ Error scanning $location : $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ Path not found: $location" -ForegroundColor Red
    }
}

# Generate recommendations
$recommendations = @()

foreach ($location in $analysis.safe_to_delete) {
    if ($location.size_gb -gt 1) {
        $recommendations += "🗑️ Clean $($location.path) - saves $($location.size_gb) GB ($($location.file_count) files)"
    } elseif ($location.size_mb -gt 100) {
        $recommendations += "🗑️ Clean $($location.path) - saves $($location.size_mb) MB ($($location.file_count) files)"
    }
}

# Add general recommendations
if ($analysis.total_size_gb -gt 5) {
    $recommendations += "⚡ Total cleanup potential: $([math]::Round($analysis.total_size_gb, 2)) GB"
}

if ($analysis.total_files -gt 10000) {
    $recommendations += "📊 Large number of temp files ($($analysis.total_files)) - consider regular cleanup"
}

$analysis.recommendations = $recommendations

# Display results
if ($Json) {
    $analysis | ConvertTo-Json -Depth 3
} else {
    Write-Host "`n📊 TEMP FILE ANALYSIS:" -ForegroundColor Yellow
    Write-Host "Total Files: $($analysis.total_files)"
    Write-Host "Total Size: $([math]::Round($analysis.total_size_gb, 2)) GB"
    
    Write-Host "`n🗑️ TEMP LOCATIONS:" -ForegroundColor Yellow
    foreach ($location in $analysis.temp_locations | Sort-Object size_gb -Descending) {
        if ($location.size_gb -gt 0.1) {
            Write-Host "  $($location.size_gb) GB - $($location.path) ($($location.file_count) files)"
        }
    }
    
    Write-Host "`n💡 RECOMMENDATIONS:" -ForegroundColor Cyan
    foreach ($rec in $recommendations) {
        Write-Host "  $rec"
    }
}

# Save analysis
$outputDir = "!0UT.CLEANER\reports"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "$outputDir\temp_analysis_$timestamp.json"
$analysis | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Green





