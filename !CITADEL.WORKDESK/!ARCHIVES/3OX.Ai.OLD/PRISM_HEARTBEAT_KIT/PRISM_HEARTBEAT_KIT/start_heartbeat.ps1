# Create/Update a Windows Scheduled Task to run PRISM Heartbeat every 15 minutes
param(
  [string]$PythonExe = "python",
  [string]$WorkingDir = "$PSScriptRoot",
  [string]$TaskName = "PRISM-Heartbeat",
  [int]$Minutes = 15
)
$script = Join-Path $WorkingDir "heartbeat.py"
if (!(Test-Path $script)) {
  Write-Error "heartbeat.py not found in $WorkingDir"
  exit 1
}
$action = New-ScheduledTaskAction -Execute $PythonExe -Argument "`"$script`"" -WorkingDirectory $WorkingDir
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes $Minutes) -RepetitionDuration ([TimeSpan]::MaxValue)
$principal = New-ScheduledTaskPrincipal -UserId "$env:UserName" -LogonType S4U -RunLevel Highest
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable)

$s = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($s) { Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false }
Register-ScheduledTask -TaskName $TaskName -InputObject $task
Write-Host "Scheduled task '$TaskName' created/updated to run every $Minutes minutes."
