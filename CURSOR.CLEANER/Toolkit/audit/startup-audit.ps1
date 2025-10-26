# Startup Audit - Boot Optimization Analysis
# CURSOR.CLEANER Toolkit
# Analyzes startup programs and boot optimization opportunities

param(
    [switch]$Registry,
    [switch]$StartupFolder,
    [switch]$TaskScheduler,
    [switch]$Services,
    [switch]$Json
)

Write-Host "⚡ CURSOR.CLEANER Startup Audit" -ForegroundColor Cyan
Write-Host "=" * 50

$analysis = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    startup_programs = @()
    registry_entries = @()
    startup_folder_items = @()
    scheduled_tasks = @()
    auto_services = @()
    recommendations = @()
    estimated_boot_time_savings = 0
}

# Analyze Registry startup entries
if ($Registry) {
    Write-Host "🔍 Analyzing Registry startup entries..." -ForegroundColor Yellow
    
    $registryPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    
    foreach ($regPath in $registryPaths) {
        if (Test-Path $regPath) {
            $entries = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
            $entries.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object {
                $analysis.registry_entries += @{
                    path = $regPath
                    name = $_.Name
                    command = $_.Value
                    safe_to_disable = is_safe_to_disable($_.Name, $_.Value)
                    priority = get_startup_priority($_.Name, $_.Value)
                }
            }
        }
    }
}

# Analyze Startup folder
if ($StartupFolder) {
    Write-Host "🔍 Analyzing Startup folder..." -ForegroundColor Yellow
    
    $startupPaths = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Startup"
    )
    
    foreach ($startupPath in $startupPaths) {
        if (Test-Path $startupPath) {
            $items = Get-ChildItem -Path $startupPath -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                $analysis.startup_folder_items += @{
                    path = $item.FullName
                    name = $item.Name
                    safe_to_disable = is_safe_to_disable($item.Name, $item.FullName)
                    priority = get_startup_priority($item.Name, $item.FullName)
                }
            }
        }
    }
}

# Analyze Task Scheduler
if ($TaskScheduler) {
    Write-Host "🔍 Analyzing Task Scheduler..." -ForegroundColor Yellow
    
    $tasks = Get-ScheduledTask | Where-Object { $_.State -eq "Ready" -and $_.Settings.Enabled -eq $true }
    
    foreach ($task in $tasks) {
        $trigger = $task.Triggers | Where-Object { $_.Enabled -eq $true }
        if ($trigger -and $trigger.TriggerType -eq "AtStartup") {
            $analysis.scheduled_tasks += @{
                name = $task.TaskName
                path = $task.TaskPath
                command = $task.Actions.Execute
                safe_to_disable = is_safe_to_disable($task.TaskName, $task.Actions.Execute)
                priority = get_startup_priority($task.TaskName, $task.Actions.Execute)
            }
        }
    }
}

# Analyze Auto-start services
if ($Services) {
    Write-Host "🔍 Analyzing Auto-start services..." -ForegroundColor Yellow
    
    $autoServices = Get-Service | Where-Object { $_.StartType -eq "Automatic" }
    
    foreach ($service in $autoServices) {
        $analysis.auto_services += @{
            name = $service.Name
            display_name = $service.DisplayName
            status = $service.Status
            safe_to_disable = is_service_safe_to_disable($service.Name)
            priority = get_service_priority($service.Name)
        }
    }
}

# Generate recommendations
$recommendations = @()

# Registry recommendations
$analysis.registry_entries | Where-Object { $_.safe_to_disable -eq $true } | ForEach-Object {
    $recommendations += "🔴 Disable registry startup: $($_.name)"
    $analysis.estimated_boot_time_savings += 2
}

# Startup folder recommendations
$analysis.startup_folder_items | Where-Object { $_.safe_to_disable -eq $true } | ForEach-Object {
    $recommendations += "🔴 Remove from startup folder: $($_.name)"
    $analysis.estimated_boot_time_savings += 3
}

# Task Scheduler recommendations
$analysis.scheduled_tasks | Where-Object { $_.safe_to_disable -eq $true } | ForEach-Object {
    $recommendations += "🔴 Disable scheduled task: $($_.name)"
    $analysis.estimated_boot_time_savings += 1
}

# Service recommendations
$analysis.auto_services | Where-Object { $_.safe_to_disable -eq $true } | ForEach-Object {
    $recommendations += "🟡 Set service to manual: $($_.name)"
    $analysis.estimated_boot_time_savings += 1
}

# General recommendations
if ($analysis.estimated_boot_time_savings -gt 10) {
    $recommendations += "⚡ High boot optimization potential: $($analysis.estimated_boot_time_savings) seconds"
}

$analysis.recommendations = $recommendations

# Helper functions
function is_safe_to_disable($name, $command) {
    $unsafePatterns = @(
        "cursor", "node", "git", "docker", "wsl", "ssh",
        "windows defender", "windefend", "windows update", "wuauserv",
        "windows firewall", "mpsvc", "security", "antivirus"
    )
    
    $nameLower = $name.ToLower()
    $commandLower = $command.ToLower()
    
    return -not ($unsafePatterns | Where-Object { $nameLower.Contains($_) -or $commandLower.Contains($_) })
}

function get_startup_priority($name, $command) {
    $highPriorityPatterns = @(
        "adobe", "java", "skype", "spotify", "steam", "discord",
        "slack", "zoom", "teams", "onedrive", "dropbox", "googledrive"
    )
    
    $nameLower = $name.ToLower()
    $commandLower = $command.ToLower()
    
    if ($highPriorityPatterns | Where-Object { $nameLower.Contains($_) -or $commandLower.Contains($_) }) {
        return "high"
    } else {
        return "medium"
    }
}

function is_service_safe_to_disable($serviceName) {
    $unsafeServices = @(
        "WinDefend", "wuauserv", "MpsSvc", "SecurityHealthService",
        "Docker Desktop Service", "com.docker.service", "ssh-agent",
        "WslService", "LxssManager"
    )
    
    return -not ($unsafeServices | Where-Object { $serviceName.Contains($_) })
}

function get_service_priority($serviceName) {
    $bloatwareServices = @(
        "XblAuthManager", "XblGameSave", "XboxGipSvc", "XboxNetApiSvc",
        "DiagTrack", "dmwappushservice", "WerSvc", "Fax", "PrintSpooler",
        "SkypeApp", "SkypeBackgroundHost", "SkypeBridge", "Cortana"
    )
    
    if ($bloatwareServices | Where-Object { $serviceName.Contains($_) }) {
        return "high"
    } else {
        return "medium"
    }
}

# Display results
if ($Json) {
    $analysis | ConvertTo-Json -Depth 3
} else {
    Write-Host "`n📊 STARTUP ANALYSIS:" -ForegroundColor Yellow
    Write-Host "Registry Entries: $($analysis.registry_entries.Count)"
    Write-Host "Startup Folder Items: $($analysis.startup_folder_items.Count)"
    Write-Host "Scheduled Tasks: $($analysis.scheduled_tasks.Count)"
    Write-Host "Auto Services: $($analysis.auto_services.Count)"
    
    Write-Host "`n🔴 HIGH PRIORITY DISABLES:" -ForegroundColor Red
    $analysis.registry_entries | Where-Object { $_.priority -eq "high" -and $_.safe_to_disable -eq $true } | ForEach-Object {
        Write-Host "  Registry: $($_.name)"
    }
    $analysis.startup_folder_items | Where-Object { $_.priority -eq "high" -and $_.safe_to_disable -eq $true } | ForEach-Object {
        Write-Host "  Startup: $($_.name)"
    }
    $analysis.auto_services | Where-Object { $_.priority -eq "high" -and $_.safe_to_disable -eq $true } | ForEach-Object {
        Write-Host "  Service: $($_.name)"
    }
    
    Write-Host "`n💡 RECOMMENDATIONS:" -ForegroundColor Cyan
    foreach ($rec in $recommendations) {
        Write-Host "  $rec"
    }
    
    Write-Host "`n⚡ ESTIMATED BOOT TIME SAVINGS: $($analysis.estimated_boot_time_savings) seconds" -ForegroundColor Green
}

# Save analysis
$outputDir = "!0UT.CLEANER\reports"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = "$outputDir\startup_analysis_$timestamp.json"
$analysis | ConvertTo-Json -Depth 3 | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "`n📄 Report saved: $reportFile" -ForegroundColor Green





