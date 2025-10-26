# ▛▞ GLYPHBIT CONTROL PANEL - TABS MODE ∎
# Launch bots in Windows Terminal tabs with live status

$bots = @(
    @{Name="NOCTUA"; Path="Noctua.Bit"; Emoji="🦉"},
    @{Name="VULPES"; Path="Vulpes.Bit"; Emoji="🦊"},
    @{Name="TRICKOON"; Path="Trickoon.Bit"; Emoji="🦝"},
    @{Name="RESUME"; Path="..\Resume.Bot"; Emoji="📄"},
    @{Name="LINKSYNC"; Path="D:\!LAUNCH.PAD\LinkSync"; Emoji="🔗"}
)

$pythonExe = "C:\Users\RVNX\AppData\Local\Programs\Python\Python312\python.exe"
$baseDir = $PSScriptRoot
$hasBooted = $false

function Show-BootSequence {
    Clear-Host
    Write-Host ""
    Write-Host "                   ▛▞ GB SYSTEMS ∎" -ForegroundColor Cyan
    Write-Host "                 GlyphBit BIOS v1.0" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  //▚▚▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host ""
    Start-Sleep -Milliseconds 500
    
    # Boot steps with retro progress bars
    Write-Host "  > Initializing core systems....... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 300
    Write-Host "[▯▯▮▮▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 250
    
    Write-Host "  > Loading bot registry............ " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 300
    Write-Host "[▯▮▮▮▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 250
    
    Write-Host "  > Checking Python 3.12 runtime.... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 300
    Write-Host "[▯▯▯▮▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 250
    
    Write-Host "  > Mounting 0ut.3ox protocol....... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 300
    Write-Host "[▯▯▮▮▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 250
    
    Write-Host "  > Linking collective mind......... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 300
    Write-Host "[▯▯▯▯▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 250
    
    Write-Host ""
    Write-Host "               ▛▞ GlyphBit Systems Status ▞// READY" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  //▚▚▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host ""
    Start-Sleep -Milliseconds 1000
}

function Show-Dashboard {
    Clear-Host
    Write-Host ""
    Write-Host "              ▛▞ GLYPHBIT CONTROL PANEL ∎" -ForegroundColor Cyan
    Write-Host "          First Official LLM Control Panel - v1.0" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "    ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host ""
    
    # System info
    $pythonCount = (Get-Process python* -ErrorAction SilentlyContinue).Count
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    Write-Host "  System: Python 3.12 | Active: $pythonCount | Time: $timestamp" -ForegroundColor DarkGray
    Write-Host ""
    
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║                    BOT STATUS BOARD                           ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
    
    # Check each bot status
    foreach ($bot in $bots) {
        $botDir = Join-Path $baseDir $bot.Path
        
        # Simple check: look for python312 processes
        $processes = Get-Process -Name python -ErrorAction SilentlyContinue
        $isRunning = $processes.Count -ge $bots.IndexOf($bot) + 1
        
        $statusIcon = if ($isRunning) { "🟢" } else { "🔴" }
        $statusText = if ($isRunning) { "ONLINE " } else { "OFFLINE" }
        $statusColor = if ($isRunning) { "Green" } else { "Red" }
        
        Write-Host "  $statusIcon $($bot.Emoji) $($bot.Name)" -NoNewline -ForegroundColor White
        $padding = 20 - $bot.Name.Length
        Write-Host ("." * $padding) -NoNewline -ForegroundColor DarkGray
        Write-Host " $statusText" -ForegroundColor $statusColor
    }
    
    Write-Host ""
    Write-Host "                        ▛ COMMAND BAR ▞" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║  BATCH        │  INDIVIDUAL    │  SYSTEM       │  ADVANCED    ║" -ForegroundColor Cyan
    Write-Host "╠═══════════════╪════════════════╪═══════════════╪══════════════╣" -ForegroundColor DarkGray
    Write-Host "║  [A] Start    │  [1] Noctua 🦉 │  [R] Refresh  │  [T] Status  ║" -ForegroundColor White
    Write-Host "║  [K] Kill All │  [2] Vulpes 🦊 │  [L] Logs     │  [M] Mind    ║" -ForegroundColor White
    Write-Host "║               │  [3] Trickoon🦝│  [H] Help     │  [C] Clean   ║" -ForegroundColor White
    Write-Host "║               │  [4] Resume 📄 │  [Q] Quit     │              ║" -ForegroundColor White
    Write-Host "║               │  [5] LinkSync🔗│               │              ║" -ForegroundColor White
    Write-Host "╚═══════════════╧════════════════╧═══════════════╧══════════════╝" -ForegroundColor DarkGray
    Write-Host ""
}

function Start-AllInTabs {
    Write-Host ""
    Write-Host "Launching all bots in Windows Terminal tabs..." -ForegroundColor Cyan
    Write-Host ""
    
    # Create temp batch files for each bot
    $tempDir = Join-Path $env:TEMP "glyphbit_launch"
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }
    
    $tempBats = @()
    
    foreach ($bot in $bots) {
        $botDir = Join-Path $baseDir $bot.Path
        $tempBat = Join-Path $tempDir "$($bot.Name).bat"
        
        # Create simple batch file
        @"
@echo off
cd /d "$botDir"
"$pythonExe" bot.py
pause
"@ | Out-File -FilePath $tempBat -Encoding ASCII
        
        $tempBats += $tempBat
    }
    
    # Add all tabs to CURRENT window (the control panel window)
    # Use wt.exe directly (not Start-Process) to add to THIS window
    for ($i = 0; $i -lt $bots.Count; $i++) {
        $args = @("-w", "0", "new-tab", "--title", "$($bots[$i].Emoji) $($bots[$i].Name)", "cmd", "/k", $tempBats[$i])
        & wt.exe @args
        Start-Sleep -Milliseconds 500
    }
    
    Write-Host "  ✓ All bots launched in ONE Windows Terminal window" -ForegroundColor Green
    Write-Host "  ✓ Check for 4 panes/tabs" -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Seconds 2
}

function Start-SingleBotTab($index) {
    $bot = $bots[$index]
    $botDir = Join-Path $baseDir $bot.Path
    
    Write-Host "Launching $($bot.Emoji) $($bot.Name) in new tab..." -ForegroundColor Cyan
    
    # Create temp batch file
    $tempDir = Join-Path $env:TEMP "glyphbit_launch"
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }
    
    $tempBat = Join-Path $tempDir "$($bot.Name).bat"
    @"
@echo off
cd /d "$botDir"
"$pythonExe" bot.py
pause
"@ | Out-File -FilePath $tempBat -Encoding ASCII
    
    # Add to CURRENT window (control panel window)
    $args = @("-w", "0", "new-tab", "--title", "$($bot.Emoji) $($bot.Name)", "cmd", "/k", $tempBat)
    & wt.exe @args
    
    Write-Host "  ✓ $($bot.Emoji) $($bot.Name) launched" -ForegroundColor Green
    Start-Sleep -Seconds 1
}

function Kill-AllBots {
    Write-Host ""
    Write-Host "Killing all Python bot processes..." -ForegroundColor Yellow
    Get-Process python* -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*Python312*"
    } | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "  ✓ All bots stopped" -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Seconds 2
}

# Boot sequence (first time only)
if (-not $hasBooted) {
    Show-BootSequence
    $script:hasBooted = $true
}

# Main loop
while ($true) {
    Show-Dashboard
    
    $input = Read-Host
    
    switch ($input.ToUpper()) {
        "A" { Start-AllInTabs }
        "R" { 
            Write-Host "Status refreshed!" -ForegroundColor Green
            Start-Sleep -Milliseconds 500
        }
        "K" { Kill-AllBots }
        "1" { Start-SingleBotTab 0 }
        "2" { Start-SingleBotTab 1 }
        "3" { Start-SingleBotTab 2 }
        "4" { Start-SingleBotTab 3 }
        "5" { Start-SingleBotTab 4 }
        "T" {
            Write-Host ""
            Write-Host "▛▞ TRANSMIT STATUS TO CMD.BRIDGE ▞" -ForegroundColor Cyan
            Write-Host ""
            $timestamp = Get-Date -Format "yyMMdd-HHmm"
            Write-Host "  Generating status report..." -ForegroundColor Gray
            
            # Run transmission script
            $transmitScript = Join-Path $baseDir "..\!TP.OPS\transmit.py"
            if (Test-Path $transmitScript) {
                & $pythonExe $transmitScript
                Write-Host "  ✅ Status transmitted to CMD.BRIDGE (⧗-$timestamp)" -ForegroundColor Green
            } else {
                Write-Host "  ❌ Transmit script not found" -ForegroundColor Red
            }
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "M" {
            Write-Host ""
            Write-Host "▛▞ SHARED MIND STATUS ▞" -ForegroundColor Cyan
            Write-Host ""
            $sharedMemory = Join-Path $baseDir "_CORE\glyphbit_shared_memory.json"
            if (Test-Path $sharedMemory) {
                $memory = Get-Content $sharedMemory | ConvertFrom-Json
                $insightCount = $memory.insights.Count
                Write-Host "  Insights stored: $insightCount" -ForegroundColor White
                Write-Host "  Topics explored: $($memory.topics_explored.PSObject.Properties.Count)" -ForegroundColor White
                Write-Host ""
                Write-Host "  Recent insights:" -ForegroundColor Yellow
                foreach ($insight in $memory.insights | Select-Object -Last 3) {
                    Write-Host "  • $($insight.bot): $($insight.insight.Substring(0, [Math]::Min(60, $insight.insight.Length)))..." -ForegroundColor Gray
                }
            } else {
                Write-Host "  No shared memory yet (will create on first bot response)" -ForegroundColor Gray
            }
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "C" {
            Write-Host ""
            Write-Host "▛▞ CLEAN LOGS ▞" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  Cleaning old log files..." -ForegroundColor Gray
            Get-ChildItem -Path $baseDir -Recurse -Include "*.log" -ErrorAction SilentlyContinue | Remove-Item -Force
            Write-Host "  ✅ Log files cleaned" -ForegroundColor Green
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "L" {
            Write-Host ""
            Write-Host "▛▞ BOT LOGS ▞" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  Checking for recent activity..." -ForegroundColor Gray
            $pythonProcs = Get-Process python* -ErrorAction SilentlyContinue
            if ($pythonProcs) {
                Write-Host "  Active processes: $($pythonProcs.Count)" -ForegroundColor White
                foreach ($proc in $pythonProcs) {
                    $uptime = (Get-Date) - $proc.StartTime
                    Write-Host "  • PID $($proc.Id) - Uptime: $([int]$uptime.TotalMinutes)m" -ForegroundColor Gray
                }
            } else {
                Write-Host "  No active bot processes" -ForegroundColor Red
            }
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "H" {
            Write-Host ""
            Write-Host "▛▞ HELP ▞" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  BATCH COMMANDS:" -ForegroundColor Cyan
            Write-Host "    [A] - Launch all 5 bots as tabs in THIS window" -ForegroundColor White
            Write-Host "    [K] - Kill all running bots" -ForegroundColor White
            Write-Host ""
            Write-Host "  INDIVIDUAL:" -ForegroundColor Cyan
            Write-Host "    [1-5] - Launch specific bot in new tab (this window)" -ForegroundColor White
            Write-Host ""
            Write-Host "  ADVANCED:" -ForegroundColor Cyan
            Write-Host "    [T] - Send status to CMD.BRIDGE via 0ut.3ox" -ForegroundColor White
            Write-Host "    [M] - View Shared Mind collective intelligence" -ForegroundColor White
            Write-Host "    [C] - Clean old log files" -ForegroundColor White
            Write-Host "    [L] - View active bot processes" -ForegroundColor White
            Write-Host ""
            Write-Host "  FEATURES:" -ForegroundColor Cyan
            Write-Host "    • Bots open as tabs in THIS window" -ForegroundColor Gray
            Write-Host "    • Status shows 🟢/🔴 in real-time" -ForegroundColor Gray
            Write-Host "    • Close any tab to stop that bot" -ForegroundColor Gray
            Write-Host "    • Use /restart in Telegram to reboot bots" -ForegroundColor Gray
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "Q" {
            Write-Host ""
            Write-Host "Quit panel? Bots will keep running." -ForegroundColor Yellow
            $confirm = Read-Host "Stop bots first? (y/n)"
            if ($confirm -eq 'y') {
                Kill-AllBots
            }
            Write-Host "▛▞ CONTROL PANEL CLOSED ∎" -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "Unknown command!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
