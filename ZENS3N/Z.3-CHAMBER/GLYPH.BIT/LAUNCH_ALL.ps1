# ▛▞ GLYPHBIT TRINITY LAUNCHER ∎
# Launches all 3 bots in separate PowerShell tabs (Windows Terminal) or windows

param(
    [switch]$Tabs,    # Use Windows Terminal tabs
    [switch]$Single   # Run all in single window (background processes)
)

$ErrorActionPreference = "Stop"

Write-Host "▛▞ GLYPHBIT TRINITY LAUNCHER ∎" -ForegroundColor Cyan
Write-Host ""

# Set UTF-8 encoding
chcp 65001 > $null

$botPaths = @(
    @{Name="NOCTUA"; Path="D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit"; Emoji="🦉"},
    @{Name="VULPES"; Path="D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Vulpes.Bit"; Emoji="🦊"},
    @{Name="TRICKOON"; Path="D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Trickoon.Bit"; Emoji="🦝"}
)

# Check if .env files exist
Write-Host "Checking configuration..." -ForegroundColor Yellow
$allConfigured = $true
foreach ($bot in $botPaths) {
    $envFile = Join-Path $bot.Path ".env"
    if (-not (Test-Path $envFile)) {
        Write-Host "  ✗ $($bot.Emoji) $($bot.Name): Missing .env file" -ForegroundColor Red
        $allConfigured = $false
    } else {
        Write-Host "  ✓ $($bot.Emoji) $($bot.Name): Configured" -ForegroundColor Green
    }
}

if (-not $allConfigured) {
    Write-Host ""
    Write-Host "Please create .env files before launching." -ForegroundColor Red
    Write-Host "See env.template in each bot directory."
    exit 1
}

Write-Host ""

# OPTION 1: Windows Terminal with tabs (if available)
if ($Tabs) {
    Write-Host "Launching in Windows Terminal tabs..." -ForegroundColor Cyan
    
    # Check if Windows Terminal is available
    $wtPath = Get-Command wt.exe -ErrorAction SilentlyContinue
    if (-not $wtPath) {
        Write-Host "Windows Terminal (wt.exe) not found." -ForegroundColor Red
        Write-Host "Install from: https://aka.ms/terminal" -ForegroundColor Yellow
        Write-Host "Or run without -Tabs flag." -ForegroundColor Yellow
        exit 1
    }
    
    # Launch each bot in separate tabs with delays
    $isFirst = $true
    foreach ($bot in $botPaths) {
        if ($isFirst) {
            # First bot - create new window
            $wtArgs = @(
                "--title", "$($bot.Emoji) $($bot.Name)",
                "`"C:\Program Files\PowerShell\7-preview\pwsh.exe`"",
                "-NoExit", "-Command",
                "cd 'D:\'; cd '$($bot.Path)'; C:\Users\RVNX\AppData\Local\Programs\Python\Python312\python.exe bot.py"
            )
            Start-Process wt.exe -ArgumentList $wtArgs
            $isFirst = $false
        } else {
            # Subsequent bots - add new tabs with delay
            Start-Sleep -Seconds 2
            $wtArgs = @(
                "new-tab",
                "--title", "$($bot.Emoji) $($bot.Name)",
                "`"C:\Program Files\PowerShell\7-preview\pwsh.exe`"",
                "-NoExit", "-Command",
                "cd 'D:\'; cd '$($bot.Path)'; C:\Users\RVNX\AppData\Local\Programs\Python\Python312\python.exe bot.py"
            )
            Start-Process wt.exe -ArgumentList $wtArgs
        }
    }
    
    Write-Host "✓ All bots launched in Windows Terminal tabs" -ForegroundColor Green
    Write-Host "  Close tabs or press Ctrl+C in each to stop" -ForegroundColor Gray
}
# OPTION 2: Single window with background jobs
elseif ($Single) {
    Write-Host "Launching all bots in this window (background jobs)..." -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($bot in $botPaths) {
        $job = Start-Job -Name $bot.Name -ScriptBlock {
            param($path, $name, $emoji)
            Set-Location $path
            $env:PYTHONIOENCODING = "utf-8"
            Write-Host "$emoji $name starting..." -ForegroundColor Cyan
            C:\Users\RVNX\AppData\Local\Programs\Python\Python312\python.exe bot.py
        } -ArgumentList $bot.Path, $bot.Name, $bot.Emoji
        
        Write-Host "  ✓ $($bot.Emoji) $($bot.Name) started (Job ID: $($job.Id))" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "▛▞ All bots running as background jobs ∎" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  Get-Job              - List all jobs"
    Write-Host "  Receive-Job -Name NOCTUA -Keep  - View bot output"
    Write-Host "  Stop-Job -Name NOCTUA            - Stop a bot"
    Write-Host "  Stop-Job *                       - Stop all bots"
    Write-Host ""
    Write-Host "Press Ctrl+C to return to prompt (bots keep running)"
    Write-Host "Run 'Stop-Job *' to stop all bots"
    
    # Keep window open and show job status
    while ($true) {
        Start-Sleep -Seconds 5
        $jobs = Get-Job
        $running = ($jobs | Where-Object State -eq "Running").Count
        if ($running -eq 0) {
            Write-Host "All bots stopped." -ForegroundColor Red
            break
        }
    }
}
# OPTION 3: Separate windows (default)
else {
    Write-Host "Launching in separate windows..." -ForegroundColor Cyan
    
    foreach ($bot in $botPaths) {
        $batFile = Join-Path $bot.Path "RUN_BOT.bat"
        Start-Process -FilePath $batFile -WorkingDirectory $bot.Path
        Write-Host "  ✓ $($bot.Emoji) $($bot.Name) launched" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
    }
    
    Write-Host ""
    Write-Host "✓ All bots launched in separate windows" -ForegroundColor Green
    Write-Host "  Close windows or press Ctrl+C in each to stop" -ForegroundColor Gray
}

Write-Host ""
Write-Host "▛▞ TRINITY ONLINE ∎" -ForegroundColor Cyan
Write-Host ""

