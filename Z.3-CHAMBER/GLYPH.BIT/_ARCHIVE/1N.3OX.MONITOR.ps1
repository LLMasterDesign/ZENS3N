# ▛▞ 1N.3OX GLYPHBIT MONITOR ∎
# Real-time monitoring dashboard for all 3 bots with power controls

param(
    [switch]$AutoStart    # Auto-start all bots on launch
)

$ErrorActionPreference = "SilentlyContinue"

# Bot configurations
$bots = @{
    "NOCTUA" = @{
        Name = "🦉 NOCTUA"
        Path = "D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit"
        Job = $null
        LastActivity = $null
        Status = "OFFLINE"
        Working = $false
        Process = $null
    }
    "VULPES" = @{
        Name = "🦊 VULPES" 
        Path = "D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Vulpes.Bit"
        Job = $null
        LastActivity = $null
        Status = "OFFLINE"
        Working = $false
        Process = $null
    }
    "TRICKOON" = @{
        Name = "🦝 TRICKOON"
        Path = "D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Trickoon.Bit"
        Job = $null
        LastActivity = $null
        Status = "OFFLINE"
        Working = $false
        Process = $null
    }
}

function Show-Banner {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                         1N.3OX GLYPHBIT MONITOR                           ║" -ForegroundColor Cyan
    Write-Host "║                        Real-time Bot Status Dashboard                     ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Get-BotStatus {
    foreach ($botName in $bots.Keys) {
        $bot = $bots[$botName]
        
        # Check if bot process is running
        $processes = Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object {
            $_.MainWindowTitle -like "*$botName*" -or 
            $_.CommandLine -like "*$($bot.Path)*"
        }
        
        if ($processes) {
            $bot.Status = "ONLINE"
            $bot.Process = $processes[0]
            $bot.LastActivity = Get-Date
            
            # Check if bot is actively working (has recent CPU usage)
            $bot.Working = $true  # Simplified - could be enhanced with actual activity detection
        } else {
            $bot.Status = "OFFLINE"
            $bot.Process = $null
            $bot.Working = $false
        }
    }
}

function Show-Status {
    Write-Host "┌────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Gray
    Write-Host "│                            BOT STATUS DASHBOARD                            │" -ForegroundColor Gray
    Write-Host "├────────────────────────────────────────────────────────────────────────────┤" -ForegroundColor Gray
    
    foreach ($botName in $bots.Keys) {
        $bot = $bots[$botName]
        
        # Status color
        $statusColor = switch ($bot.Status) {
            "ONLINE" { "Green" }
            "OFFLINE" { "Red" }
            default { "Yellow" }
        }
        
        # Working indicator
        $workingIndicator = if ($bot.Working) { "⚡ WORKING" } else { "⏸️ IDLE" }
        $workingColor = if ($bot.Working) { "Yellow" } else { "Gray" }
        
        # Last activity
        $lastActivity = if ($bot.LastActivity) { 
            $bot.LastActivity.ToString("HH:mm:ss") 
        } else { 
            "Never" 
        }
        
        Write-Host "│ $($bot.Name.PadRight(15)) │ " -NoNewline -ForegroundColor White
        Write-Host "$($bot.Status.PadRight(7))" -NoNewline -ForegroundColor $statusColor
        Write-Host " │ " -NoNewline -ForegroundColor Gray
        Write-Host "$workingIndicator" -NoNewline -ForegroundColor $workingColor
        Write-Host " │ $($lastActivity.PadLeft(8)) │" -ForegroundColor Gray
    }
    
    Write-Host "└────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Gray
    Write-Host ""
}

function Show-Controls {
    Write-Host "┌────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "│                              POWER CONTROLS                               │" -ForegroundColor DarkCyan
    Write-Host "├────────────────────────────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan
    Write-Host "│  [1] Start NOCTUA    [2] Start VULPES    [3] Start TRICKOON             │" -ForegroundColor DarkCyan
    Write-Host "│  [4] Stop NOCTUA     [5] Stop VULPES     [6] Stop TRICKOON              │" -ForegroundColor DarkCyan
    Write-Host "│  [A] Start All       [S] Stop All        [R] Refresh Status              │" -ForegroundColor DarkCyan
    Write-Host "│  [Q] Quit Monitor                                                         │" -ForegroundColor DarkCyan
    Write-Host "└────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""
}

function Start-Bot {
    param($botName)
    
    $bot = $bots[$botName]
    if ($bot.Status -eq "ONLINE") {
        Write-Host "$($bot.Name) is already running!" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Starting $($bot.Name)..." -ForegroundColor Cyan
    
    # Check if Windows Terminal is available
    $wtPath = Get-Command wt.exe -ErrorAction SilentlyContinue
    if ($wtPath) {
        # Use Windows Terminal tabs
        $wtArgs = @(
            "new-tab",
            "--title", $bot.Name,
            "powershell",
            "-NoExit", "-Command",
            "cd '$($bot.Path.Replace('\', '/'))'; python bot.py"
        )
        Start-Process wt.exe -ArgumentList $wtArgs
        Start-Sleep -Seconds 3
    } else {
        # Fallback to regular PowerShell window
        $cmd = "cd '$($bot.Path)'; python bot.py"
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd
    }
    
    Write-Host "$($bot.Name) started!" -ForegroundColor Green
}

function Stop-Bot {
    param($botName)
    
    $bot = $bots[$botName]
    if ($bot.Status -eq "OFFLINE") {
        Write-Host "$($bot.Name) is not running!" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Stopping $($bot.Name)..." -ForegroundColor Cyan
    
    if ($bot.Process) {
        $bot.Process.Kill()
        Write-Host "$($bot.Name) stopped!" -ForegroundColor Green
    }
}

function Start-AllBots {
    Write-Host "Starting all bots..." -ForegroundColor Cyan
    
    # Check if Windows Terminal is available
    $wtPath = Get-Command wt.exe -ErrorAction SilentlyContinue
    if ($wtPath) {
        # Use Windows Terminal with all bots in tabs
        $wtArgs = @()
        $isFirst = $true
        
        foreach ($botName in $bots.Keys) {
            $bot = $bots[$botName]
            
            if ($isFirst) {
                # First bot - create new window
                $wtArgs += "--title"
                $wtArgs += $bot.Name
                $wtArgs += "powershell"
                $wtArgs += "-NoExit"
                $wtArgs += "-Command"
                $wtArgs += "cd '$($bot.Path)'; python bot.py"
                $isFirst = $false
            } else {
                # Subsequent bots - add new tabs with delay
                $wtArgs += ";"
                $wtArgs += "new-tab"
                $wtArgs += "--title"
                $wtArgs += $bot.Name
                $wtArgs += "powershell"
                $wtArgs += "-NoExit"
                $wtArgs += "-Command"
                $wtArgs += "cd '$($bot.Path)'; python bot.py"
            }
        }
        
        Start-Process wt.exe -ArgumentList $wtArgs
    } else {
        # Fallback to individual windows
        foreach ($botName in $bots.Keys) {
            Start-Bot $botName
            Start-Sleep -Seconds 2
        }
    }
    
    Write-Host "All bots launched!" -ForegroundColor Green
}

function Stop-AllBots {
    Write-Host "Stopping all bots..." -ForegroundColor Cyan
    foreach ($botName in $bots.Keys) {
        Stop-Bot $botName
    }
}

function Main {
    Show-Banner
    
    if ($AutoStart) {
        Start-AllBots
        Start-Sleep -Seconds 3
    }
    
    while ($true) {
        Get-BotStatus
        Show-Status
        Show-Controls
        
        Write-Host "Command: " -NoNewline -ForegroundColor Yellow
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $char = $key.Character
        
        switch ($char) {
            '1' { Start-Bot "NOCTUA" }
            '2' { Start-Bot "VULPES" }
            '3' { Start-Bot "TRICKOON" }
            '4' { Stop-Bot "NOCTUA" }
            '5' { Stop-Bot "VULPES" }
            '6' { Stop-Bot "TRICKOON" }
            'A' { Start-AllBots }
            'S' { Stop-AllBots }
            'R' { continue }  # Refresh (loop will continue)
            'Q' { 
                Write-Host "Shutting down monitor..." -ForegroundColor Red
                exit 
            }
            default { 
                Write-Host "Invalid command!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
        
        Start-Sleep -Milliseconds 500
    }
}

# Run main function
Main
