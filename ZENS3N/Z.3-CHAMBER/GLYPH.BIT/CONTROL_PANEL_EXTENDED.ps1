# ▛▞ GLYPHBIT EXTENDED CONTROL PANEL ∎
# Scalable dashboard for 15+ bots across 3 sectors

$bots = @(
    # SECTOR 1: CORE TRINITY
    @{Name="NOCTUA"; Path="Noctua.Bit"; Emoji="🦉"; Sector="CORE"; Health="OK"},
    @{Name="VULPES"; Path="Vulpes.Bit"; Emoji="🦊"; Sector="CORE"; Health="OK"},
    @{Name="TRICKOON"; Path="Trickoon.Bit"; Emoji="🦝"; Sector="CORE"; Health="OK"},
    
    # SECTOR 2: UTILITY
    @{Name="RESUME"; Path="..\Resume.Bot"; Emoji="📄"; Sector="UTILITY"; Health="OK"},
    # Placeholder for future utility bots
    @{Name="TASK.MASTER"; Path="TaskMaster.Bit"; Emoji="📋"; Sector="UTILITY"; Health="--"},
    @{Name="CHRONO.KEEP"; Path="Chrono.Bit"; Emoji="📅"; Sector="UTILITY"; Health="--"},
    
    # SECTOR 3: SPECIALIZED
    @{Name="CRYPTO.SAGE"; Path="Crypto.Bit"; Emoji="💎"; Sector="SPECIAL"; Health="--"},
    @{Name="VOICE.CAST"; Path="Voice.Bit"; Emoji="📢"; Sector="SPECIAL"; Health="--"},
    @{Name="LYRIC.MUSE"; Path="Lyric.Bit"; Emoji="🎵"; Sector="SPECIAL"; Health="--"}
)

$pythonExe = "C:\Users\RVNX\AppData\Local\Programs\Python\Python312\python.exe"
$baseDir = $PSScriptRoot
$hasBooted = $false

function Get-BotHealth($botPath) {
    """
    Second status metric - Health/Activity
    Options: OK, WARN, ERROR, IDLE, BUSY, --
    """
    # Check if bot has responded recently (placeholder logic)
    # In production: check log files, API calls, response times, etc.
    return "OK"
}

function Show-BootSequence {
    Clear-Host
    Write-Host ""
    Write-Host "  ▚▚▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "                   ▛▞ GB SYSTEMS ∎" -ForegroundColor Cyan
    Write-Host "                 GlyphBit BIOS v1.0" -ForegroundColor DarkCyan
    Write-Host ""
    Start-Sleep -Milliseconds 400
    
    Write-Host "  > Initializing core........... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 250
    Write-Host "[▯▯▮▮▮▮▮▮▮▮]" -ForegroundColor Green
    
    Write-Host "  > Loading registry............ " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 250
    Write-Host "[▯▮▮▮▮▮▮▮▮▮]" -ForegroundColor Green
    
    Write-Host "  > Python 3.12 runtime......... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 250
    Write-Host "[▯▯▯▮▮▮▮▮▮▮]" -ForegroundColor Green
    
    Write-Host "  > 0ut.3ox protocol............ " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 250
    Write-Host "[▯▯▮▮▮▮▮▮▮▮]" -ForegroundColor Green
    
    Write-Host "  > Shared mind link............ " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 250
    Write-Host "[▯▯▯▯▮▮▮▮▮▮]" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "               ▛ GlyphBit Systems Status ▞// READY" -ForegroundColor Cyan
    Write-Host ""
    Start-Sleep -Milliseconds 800
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
    
    # Status board organized by SECTOR
    Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "║               BOT STATUS BOARD (Multi-Sector)                 ║" -ForegroundColor Cyan
    Write-Host "╠═══════════════════════════════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host "║  Bot Name           │  Online  │  Health  │  Sector          ║" -ForegroundColor Yellow
    Write-Host "╠═════════════════════╪══════════╪══════════╪══════════════════╣" -ForegroundColor DarkGray
    
    foreach ($bot in $bots) {
        $botDir = Join-Path $baseDir $bot.Path
        
        # Check online status
        $processes = Get-Process -Name python -ErrorAction SilentlyContinue
        $isOnline = (Test-Path $botDir) -and $processes.Count -ge 1
        
        $onlineIcon = if ($isOnline) { "🟢 ON " } else { "🔴 OFF" }
        $onlineColor = if ($isOnline) { "Green" } else { "Red" }
        
        # Health status (second metric)
        $health = $bot.Health
        $healthColor = switch ($health) {
            "OK" { "Green" }
            "WARN" { "Yellow" }
            "ERROR" { "Red" }
            default { "DarkGray" }
        }
        
        # Format row
        $namePadded = $bot.Emoji + " " + $bot.Name.PadRight(15)
        $sectorPadded = $bot.Sector.PadRight(15)
        
        Write-Host "║  " -NoNewline -ForegroundColor DarkGray
        Write-Host $namePadded -NoNewline -ForegroundColor White
        Write-Host " │  " -NoNewline -ForegroundColor DarkGray
        Write-Host $onlineIcon -NoNewline -ForegroundColor $onlineColor
        Write-Host "  │  " -NoNewline -ForegroundColor DarkGray
        Write-Host $health.PadRight(6) -NoNewline -ForegroundColor $healthColor
        Write-Host " │  " -NoNewline -ForegroundColor DarkGray
        Write-Host $sectorPadded -NoNewline -ForegroundColor Cyan
        Write-Host " ║" -ForegroundColor DarkGray
    }
    
    Write-Host "╚═════════════════════╧══════════╧══════════╧══════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
    
    # Legend
    Write-Host "  Legend: 🟢 Online | 🔴 Offline | Health: " -NoNewline -ForegroundColor DarkGray
    Write-Host "OK" -NoNewline -ForegroundColor Green
    Write-Host "/" -NoNewline -ForegroundColor DarkGray
    Write-Host "WARN" -NoNewline -ForegroundColor Yellow
    Write-Host "/" -NoNewline -ForegroundColor DarkGray
    Write-Host "ERROR" -NoNewline -ForegroundColor Red
    Write-Host "/" -NoNewline -ForegroundColor DarkGray
    Write-Host "--" -ForegroundColor DarkGray
    Write-Host ""
    
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
    Write-Host "╚═══════════════╧════════════════╧═══════════════╧══════════════╝" -ForegroundColor DarkGray
    Write-Host ""
}

# Copy all the other functions from CONTROL_PANEL_TABS.ps1...
# (Start-AllInTabs, Start-SingleBotTab, Kill-AllBots, etc.)




