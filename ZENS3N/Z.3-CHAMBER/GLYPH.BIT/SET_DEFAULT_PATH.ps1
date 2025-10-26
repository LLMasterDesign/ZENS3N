# Set Windows Terminal to default to D: drive
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Backup current settings
if (Test-Path $settingsPath) {
    Copy-Item $settingsPath "$settingsPath.backup"
    Write-Host "Backed up current settings to $settingsPath.backup" -ForegroundColor Green
}

# Read current settings
if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath | ConvertFrom-Json
} else {
    $settings = @{}
}

# Set default starting directory to D:\
if (-not $settings.startup) {
    $settings | Add-Member -MemberType NoteProperty -Name "startup" -Value @{}
}
$settings.startup | Add-Member -MemberType NoteProperty -Name "startingDirectory" -Value "D:\" -Force

# Save settings
$settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
Write-Host "Windows Terminal will now default to D:\ drive" -ForegroundColor Green
Write-Host "Restart Windows Terminal for changes to take effect" -ForegroundColor Yellow


