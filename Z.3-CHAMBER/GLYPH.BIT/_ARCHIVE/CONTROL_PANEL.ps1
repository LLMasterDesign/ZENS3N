# ▛▞ GLYPHBIT CONTROL PANEL ∎
# Interactive bot launcher with status monitoring

param(
    [switch]$AutoStart  # Automatically start all bots on launch
)

$ErrorActionPreference = "SilentlyContinue"

# Set UTF-8
chcp 65001 > $null
$Host.UI.RawUI.WindowTitle = "GlyphBit Control Panel"

# Bot configuration
$bots = @(
    @{Name="NOCTUA"; Path="D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit"; Emoji="🦉"; Job=$null; Status="Offline"},
    @{Name="VULPES"; Path="D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Vulpes.Bit"; Emoji="🦊"; Job=$null; Status="Offline"},
    @{Name="TRICKOON"; Path="D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Trickoon.Bit"; Emoji="🦝"; Job=$null; Status="Offline"},
    @{Name="RESUME"; Path="D:\!RUNTIME\TELE.PROMPTR\Resume.Bot"; Emoji="📄"; Job=$null; Status="Offline"}
)

$pythonPath = "C:\Users\RVNX\AppData\Local\Programs\Python\Python312\python.exe"

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "▛▞ GLYPHBIT CONTROL PANEL ∎" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Status {
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║                    BOT STATUS BOARD                           ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
    
    foreach ($bot in $bots) {
        $statusColor = if ($bot.Status -eq "Online") { "Green" } else { "Red" }
        $statusIcon = if ($bot.Status -eq "Online") { "🟢" } else { "🔴" }
        
        Write-Host "  $statusIcon $($bot.Emoji) $($bot.Name)" -NoNewline -ForegroundColor White
        Write-Host " " -NoNewline
        $padding = 20 - $bot.Name.Length
        Write-Host ("." * $padding) -NoNewline -ForegroundColor DarkGray
        Write-Host " $($bot.Status.ToUpper())" -ForegroundColor $statusColor
    }
    
    Write-Host ""
}

function Show-Commands {
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║                    CONTROL COMMANDS                           ║" -ForegroundColor Yellow
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ▛ ALL BOTS ▞" -ForegroundColor Cyan
    Write-Host "    [S] Start All    [R] Restart All    [X] Stop All" -ForegroundColor White
    Write-Host ""
    Write-Host "  ▛ INDIVIDUAL ▞" -ForegroundColor Cyan
    Write-Host "    [1] Noctua 🦉   [2] Vulpes 🦊   [3] Trickoon 🦝   [4] Resume 📄" -ForegroundColor White
    Write-Host ""
    Write-Host "  ▛ SYSTEM ▞" -ForegroundColor Cyan
    Write-Host "    [U] Update Status    [H] Help    [Q] Quit" -ForegroundColor White
    Write-Host ""
    Write-Host "▛▞ ════════════════════════════════════════════════════════ ∎" -ForegroundColor DarkGray
    Write-Host ""
}

function Start-Bot($botIndex) {
    $bot = $bots[$botIndex]
    
    # Stop if already running
    if ($bot.Job) {
        Stop-Job -Job $bot.Job -ErrorAction SilentlyContinue
        Remove-Job -Job $bot.Job -ErrorAction SilentlyContinue
    }
    
    # Start as background job (not separate window)
    $bot.Job = Start-Job -ScriptBlock {
        param($path, $pythonPath)
        Set-Location $path
        & $pythonPath bot.py 2>&1
    } -ArgumentList $bot.Path, $pythonPath
    
    $bot.Status = "Online"
    Write-Host "✅ $($bot.Emoji) $($bot.Name) started (background)" -ForegroundColor Green
    Start-Sleep -Milliseconds 300
}

function Stop-Bot($botIndex) {
    $bot = $bots[$botIndex]
    
    if ($bot.Job) {
        Stop-Job -Job $bot.Job -ErrorAction SilentlyContinue
        Remove-Job -Job $bot.Job -ErrorAction SilentlyContinue
        $bot.Job = $null
        $bot.Status = "Offline"
        Write-Host "⏹️  $($bot.Emoji) $($bot.Name) stopped" -ForegroundColor Yellow
    }
}

function Update-BotStatus {
    foreach ($bot in $bots) {
        # Check if bot process is actually running (not just job)
        $botProcessName = "python*"
        $botPath = $bot.Path
        
        # Look for python process running bot.py from this path
        $running = Get-Process -Name $botProcessName -ErrorAction SilentlyContinue | Where-Object {
            $_.CommandLine -like "*$($botPath)*bot.py*"
        }
        
        if ($running) {
            $bot.Status = "Online"
        } elseif ($bot.Job) {
            # Fallback to job check
            $jobState = (Get-Job -Id $bot.Job.Id -ErrorAction SilentlyContinue).State
            if ($jobState -eq "Running") {
                $bot.Status = "Online"
            } else {
                $bot.Status = "Offline"
                $bot.Job = $null
            }
        } else {
            $bot.Status = "Offline"
        }
    }
}

function Start-AllBots {
    Write-Host "Starting all bots..." -ForegroundColor Cyan
    for ($i = 0; $i -lt $bots.Count; $i++) {
        Start-Bot $i
        Start-Sleep -Milliseconds 500
    }
}

function Stop-AllBots {
    Write-Host "Stopping all bots..." -ForegroundColor Yellow
    for ($i = 0; $i -lt $bots.Count; $i++) {
        Stop-Bot $i
    }
}

# Auto-start if flag set
if ($AutoStart) {
    Start-AllBots
    Start-Sleep -Seconds 2
}

# Main control loop with live updates
while ($true) {
    Update-BotStatus
    Show-Header
    Show-Status
    Show-Commands
    
    Write-Host "Command [Auto-refresh 2s]: " -NoNewline -ForegroundColor Cyan
    
    # Wait for input with timeout (auto-refresh)
    $startTime = Get-Date
    $userInput = $null
    
    while ((Get-Date) -lt $startTime.AddSeconds(2)) {
        if ($Host.UI.RawUI.KeyAvailable) {
            $userInput = Read-Host
            break
        }
        Start-Sleep -Milliseconds 100
    }
    
    if (-not $userInput) {
        # Auto-refresh (no input received in 2 seconds)
        continue
    }
    
    $input = $userInput
    
    switch ($input.ToUpper()) {
        "S" { 
            Start-AllBots
            Start-Sleep -Seconds 1
        }
        "R" { 
            Stop-AllBots
            Start-Sleep -Seconds 1
            Start-AllBots
            Start-Sleep -Seconds 1
        }
        "X" { 
            Stop-AllBots
            Start-Sleep -Seconds 1
        }
        "1" { Start-Bot 0 }
        "2" { Start-Bot 1 }
        "3" { Start-Bot 2 }
        "4" { Start-Bot 3 }
        "U" { 
            Write-Host "Updating status..." -ForegroundColor Cyan
            Start-Sleep -Milliseconds 500
        }
        "H" {
            Write-Host ""
            Write-Host "HELP:" -ForegroundColor Yellow
            Write-Host "  This control panel manages all GlyphBit bots" -ForegroundColor Gray
            Write-Host "  Start individual bots or all at once" -ForegroundColor Gray
            Write-Host "  Monitor online/offline status in real-time" -ForegroundColor Gray
            Write-Host "  Use /restart in Telegram to reboot individual bots" -ForegroundColor Gray
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "Q" { 
            Write-Host ""
            Write-Host "Shutting down control panel..." -ForegroundColor Yellow
            Stop-AllBots
            Write-Host "✓ All bots stopped" -ForegroundColor Green
            Write-Host ""
            exit
        }
        default {
            Write-Host "Invalid command. Press any key..." -ForegroundColor Red
            Read-Host
        }
    }
}

