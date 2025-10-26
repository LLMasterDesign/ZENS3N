# ▛▞ SIMPLE GLYPHBIT MONITOR ∎
# Just works - no fancy Windows Terminal stuff

param(
    [switch]$AutoStart    # Auto-start all bots on launch
)

Clear-Host
Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                        SIMPLE GLYPHBIT MONITOR                            ║" -ForegroundColor Cyan
Write-Host "║                          No Fancy Stuff - Just Works                      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Bot paths
$bots = @{
    "NOCTUA" = "D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit"
    "VULPES" = "D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Vulpes.Bit" 
    "TRICKOON" = "D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Trickoon.Bit"
}

function Show-Status {
    Write-Host "┌────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Gray
    Write-Host "│                            BOT STATUS DASHBOARD                            │" -ForegroundColor Gray
    Write-Host "├────────────────────────────────────────────────────────────────────────────┤" -ForegroundColor Gray
    
    foreach ($botName in $bots.Keys) {
        $botPath = $bots[$botName]
        
        # Check if bot is running - look for python processes in the bot directory
        $processes = Get-Process -Name "python" -ErrorAction SilentlyContinue
        $isRunning = $false
        foreach ($proc in $processes) {
            try {
                $cmdLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
                if ($cmdLine -and $cmdLine.Contains($botPath)) {
                    $isRunning = $true
                    break
                }
            } catch {
                # If we can't get command line, just assume it's running if we find python
                $isRunning = $true
                break
            }
        }
        
        if ($isRunning) {
            Write-Host "│ 🟢 $($botName.PadRight(15)) │ ONLINE  │ Running in separate window              │" -ForegroundColor Green
        } else {
            Write-Host "│ 🔴 $($botName.PadRight(15)) │ OFFLINE │ Not running                            │" -ForegroundColor Red
        }
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
    
    $botPath = $bots[$botName]
    $emoji = @{"NOCTUA"="🦉"; "VULPES"="🦊"; "TRICKOON"="🦝"}[$botName]
    
    Write-Host "Starting $emoji $botName..." -ForegroundColor Cyan
    
    # Simple approach - use the existing RUN_BOT.bat file
    $batFile = "$botPath\RUN_BOT.bat"
    if (Test-Path $batFile) {
        Start-Process -FilePath $batFile -WorkingDirectory $botPath
        Write-Host "$emoji $botName started!" -ForegroundColor Green
    } else {
        Write-Host "❌ RUN_BOT.bat not found for $botName" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 2
}

function Stop-Bot {
    param($botName)
    
    $botPath = $bots[$botName]
    $emoji = @{"NOCTUA"="🦉"; "VULPES"="🦊"; "TRICKOON"="🦝"}[$botName]
    
    Write-Host "Stopping $emoji $botName..." -ForegroundColor Cyan
    
    # Find and kill Python processes for this bot
    $processes = Get-Process -Name "python" -ErrorAction SilentlyContinue
    $botProcesses = @()
    foreach ($proc in $processes) {
        try {
            $cmdLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
            if ($cmdLine -and $cmdLine.Contains($botPath)) {
                $botProcesses += $proc
            }
        } catch {
            # If we can't get command line, skip this process
        }
    }
    
    if ($botProcesses.Count -gt 0) {
        $botProcesses | Stop-Process -Force
        Write-Host "$emoji $botName stopped!" -ForegroundColor Green
    } else {
        Write-Host "$emoji $botName was not running" -ForegroundColor Yellow
    }
}

function Start-AllBots {
    Write-Host "Starting all bots..." -ForegroundColor Cyan
    foreach ($botName in $bots.Keys) {
        Start-Bot $botName
    }
}

function Stop-AllBots {
    Write-Host "Stopping all bots..." -ForegroundColor Cyan
    foreach ($botName in $bots.Keys) {
        Stop-Bot $botName
    }
}

# Main loop
if ($AutoStart) {
    Start-AllBots
    Start-Sleep -Seconds 3
}

while ($true) {
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
        'R' { continue }  # Refresh
        'Q' { 
            Write-Host "Shutting down..." -ForegroundColor Red
            exit 
        }
        default { 
            Write-Host "Invalid command!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
    
    Start-Sleep -Milliseconds 500
}
