# ▛▞ GLYPHBIT CONTROL PANEL - SIMPLE MODE ∎
# Live status monitoring with manual refresh

$bots = @(
    @{Name="NOCTUA"; Path="Noctua.Bit"; Emoji="🦉"},
    @{Name="VULPES"; Path="Vulpes.Bit"; Emoji="🦊"},
    @{Name="TRICKOON"; Path="Trickoon.Bit"; Emoji="🦝"},
    @{Name="RESUME"; Path="..\Resume.Bot"; Emoji="📄"}
)

$pythonPath = "C:\Users\RVNX\AppData\Local\Programs\Python\Python312\python.exe"

function Show-Dashboard {
    Clear-Host
    Write-Host ""
    Write-Host "▛▞ GLYPHBIT CONTROL PANEL ∎" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║                    BOT STATUS BOARD                           ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
    
    # Check each bot
    foreach ($bot in $bots) {
        $fullPath = Join-Path $PSScriptRoot $bot.Path
        
        # Check if python process running from this path
        $processes = Get-Process python* -ErrorAction SilentlyContinue | Where-Object {
            $_.Path -like "*Python312*"
        }
        
        # Simple check: count python processes (rough but works)
        $isRunning = $processes.Count -gt 0
        
        $statusIcon = if ($isRunning) { "🟢" } else { "🔴" }
        $statusText = if ($isRunning) { "ONLINE " } else { "OFFLINE" }
        $statusColor = if ($isRunning) { "Green" } else { "Red" }
        
        Write-Host "  $statusIcon $($bot.Emoji) $($bot.Name)" -NoNewline -ForegroundColor White
        $padding = 20 - $bot.Name.Length
        Write-Host ("." * $padding) -NoNewline -ForegroundColor DarkGray
        Write-Host " $statusText" -ForegroundColor $statusColor
    }
    
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║                    CONTROL COMMANDS                           ║" -ForegroundColor Yellow
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ▛ BATCH ▞" -ForegroundColor Cyan
    Write-Host "    [A] Start All    [R] Refresh Status    [K] Kill All" -ForegroundColor White
    Write-Host ""
    Write-Host "  ▛ INDIVIDUAL ▞" -ForegroundColor Cyan
    Write-Host "    [1] Noctua 🦉   [2] Vulpes 🦊   [3] Trickoon 🦝   [4] Resume 📄" -ForegroundColor White
    Write-Host ""
    Write-Host "  ▛ SYSTEM ▞" -ForegroundColor Cyan
    Write-Host "    [L] View Logs    [H] Help    [Q] Quit" -ForegroundColor White
    Write-Host ""
    Write-Host "▛▞ ════════════════════════════════════════════════════════ ∎" -ForegroundColor DarkGray
    Write-Host ""
}

function Start-AllBots {
    Write-Host "Starting all bots in background..." -ForegroundColor Cyan
    
    foreach ($bot in $bots) {
        $fullPath = Join-Path $PSScriptRoot $bot.Path
        Start-Process -FilePath $pythonPath -ArgumentList "bot.py" -WorkingDirectory $fullPath -WindowStyle Hidden
        Write-Host "  ✓ $($bot.Emoji) $($bot.Name) launched" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
    }
    
    Write-Host ""
    Write-Host "✅ All bots started!" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

function Start-SingleBot($index) {
    $bot = $bots[$index]
    $fullPath = Join-Path $PSScriptRoot $bot.Path
    Start-Process -FilePath $pythonPath -ArgumentList "bot.py" -WorkingDirectory $fullPath -WindowStyle Hidden
    Write-Host "✅ $($bot.Emoji) $($bot.Name) started" -ForegroundColor Green
    Start-Sleep -Seconds 1
}

function Kill-AllBots {
    Write-Host "Stopping all Python bots..." -ForegroundColor Yellow
    Get-Process python* -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -like "*Python312*"
    } | Stop-Process -Force
    Write-Host "✅ All bots stopped" -ForegroundColor Green
    Start-Sleep -Seconds 2
}

# Main loop
while ($true) {
    Show-Dashboard
    
    $input = Read-Host "Command"
    
    switch ($input.ToUpper()) {
        "A" { Start-AllBots }
        "R" { Write-Host "Refreshing..." -ForegroundColor Cyan; Start-Sleep -Milliseconds 300 }
        "K" { Kill-AllBots }
        "1" { Start-SingleBot 0 }
        "2" { Start-SingleBot 1 }
        "3" { Start-SingleBot 2 }
        "4" { Start-SingleBot 3 }
        "L" {
            Write-Host ""
            Write-Host "▛▞ BOT LOGS ▞" -ForegroundColor Yellow
            Write-Host "Logs are managed by each bot internally" -ForegroundColor Gray
            Write-Host "Check individual bot folders for log files" -ForegroundColor Gray
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "H" {
            Write-Host ""
            Write-Host "▛▞ HELP ▞" -ForegroundColor Yellow
            Write-Host "  This panel runs bots in background (no windows)" -ForegroundColor Gray
            Write-Host "  Status updates when you press R or enter any command" -ForegroundColor Gray
            Write-Host "  Use Telegram /restart to reboot individual bots" -ForegroundColor Gray
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
        "Q" {
            Write-Host ""
            Write-Host "Shutting down..." -ForegroundColor Yellow
            Kill-AllBots
            exit
        }
        default {
            Write-Host "Unknown command. Press Enter..." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

