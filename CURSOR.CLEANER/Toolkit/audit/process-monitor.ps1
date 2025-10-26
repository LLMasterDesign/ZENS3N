# Process Monitor - Real-time Resource Analysis
# CURSOR.CLEANER Toolkit
# Analyzes current process resource usage for optimization

param(
    [switch]$Top10,
    [switch]$Memory,
    [switch]$CPU,
    [switch]$Aggressive,
    [switch]$Json
)

# Get current processes sorted by memory usage
$processes = Get-Process | Sort-Object -Property WorkingSet -Descending

if ($Top10) {
    $processes = $processes | Select-Object -First 10
}

# Analyze resource usage
$analysis = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    total_processes = $processes.Count
    memory_analysis = @{}
    cpu_analysis = @{}
    optimization_targets = @()
    recommendations = @()
}

# Memory analysis
$totalMemory = ($processes | Measure-Object -Property WorkingSet -Sum).Sum / 1MB
$analysis.memory_analysis.total_memory_mb = [math]::Round($totalMemory, 2)

# Identify high memory consumers
$highMemoryProcesses = $processes | Where-Object { $_.WorkingSet -gt 100MB } | Select-Object -First 5
foreach ($proc in $highMemoryProcesses) {
    $analysis.memory_analysis.high_memory_processes += @{
        name = $proc.ProcessName
        memory_mb = [math]::Round($proc.WorkingSet / 1MB, 2)
        pid = $proc.Id
    }
}

# CPU analysis
$highCPUProcesses = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5
foreach ($proc in $highCPUProcesses) {
    $analysis.cpu_analysis.high_cpu_processes += @{
        name = $proc.ProcessName
        cpu_seconds = $proc.CPU
        pid = $proc.Id
    }
}

# Optimization recommendations based on process analysis
$recommendations = @()

# Check for common bloatware processes
$bloatwareProcesses = @(
    "XboxGameBar", "XboxApp", "XboxGipSvc", "XblAuthManager", "XblGameSave",
    "SkypeApp", "SkypeBackgroundHost", "SkypeBridge",
    "Cortana", "SearchUI", "SearchIndexer",
    "DiagTrack", "dmwappushservice", "WerSvc",
    "Fax", "PrintWorkflowUserSvc", "PrintSpooler"
)

foreach ($proc in $processes) {
    if ($bloatwareProcesses -contains $proc.ProcessName) {
        $analysis.optimization_targets += @{
            process_name = $proc.ProcessName
            memory_mb = [math]::Round($proc.WorkingSet / 1MB, 2)
            action = "disable_service"
            priority = "high"
        }
        $recommendations += "Disable $($proc.ProcessName) service - saves $([math]::Round($proc.WorkingSet / 1MB, 2))MB"
    }
}

# Check for multiple instances of same process
$processGroups = $processes | Group-Object -Property ProcessName | Where-Object { $_.Count -gt 1 }
foreach ($group in $processGroups) {
    $totalMemory = ($group.Group | Measure-Object -Property WorkingSet -Sum).Sum / 1MB
    if ($totalMemory -gt 200) {
        $analysis.optimization_targets += @{
            process_name = $group.Name
            instances = $group.Count
            total_memory_mb = [math]::Round($totalMemory, 2)
            action = "consolidate_instances"
            priority = "medium"
        }
        $recommendations += "Consolidate $($group.Count) instances of $($group.Name) - saves $([math]::Round($totalMemory, 2))MB"
    }
}

# Check for idle processes
$idleProcesses = $processes | Where-Object { $_.CPU -eq 0 -and $_.WorkingSet -gt 50MB }
foreach ($proc in $idleProcesses) {
    $analysis.optimization_targets += @{
        process_name = $proc.ProcessName
        memory_mb = [math]::Round($proc.WorkingSet / 1MB, 2)
        action = "kill_idle"
        priority = "low"
    }
}

$analysis.recommendations = $recommendations

# Output results
if ($Json) {
    $analysis | ConvertTo-Json -Depth 3
} else {
    Write-Host "🔍 PROCESS ANALYSIS REPORT" -ForegroundColor Cyan
    Write-Host "=" * 50
    Write-Host "Timestamp: $($analysis.timestamp)"
    Write-Host "Total Processes: $($analysis.total_processes)"
    Write-Host "Total Memory Usage: $($analysis.memory_analysis.total_memory_mb) MB"
    Write-Host ""
    
    Write-Host "📊 TOP MEMORY CONSUMERS:" -ForegroundColor Yellow
    foreach ($proc in $analysis.memory_analysis.high_memory_processes) {
        Write-Host "  $($proc.name): $($proc.memory_mb) MB (PID: $($proc.pid))"
    }
    Write-Host ""
    
    Write-Host "⚡ TOP CPU CONSUMERS:" -ForegroundColor Yellow
    foreach ($proc in $analysis.cpu_analysis.high_cpu_processes) {
        Write-Host "  $($proc.name): $($proc.cpu_seconds) seconds (PID: $($proc.pid))"
    }
    Write-Host ""
    
    Write-Host "🎯 OPTIMIZATION TARGETS:" -ForegroundColor Green
    foreach ($target in $analysis.optimization_targets) {
        $priority = switch ($target.priority) {
            "high" { "🔴" }
            "medium" { "🟡" }
            "low" { "🟢" }
        }
        Write-Host "  $priority $($target.process_name): $($target.action) - $($target.memory_mb) MB"
    }
    Write-Host ""
    
    Write-Host "💡 RECOMMENDATIONS:" -ForegroundColor Cyan
    foreach ($rec in $recommendations) {
        Write-Host "  • $rec"
    }
}

# Save analysis to file
$outputDir = "!0UT.CLEANER\reports"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "$outputDir\process_analysis_$timestamp.json"
$analysis | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "📄 Report saved: $reportFile" -ForegroundColor Green






