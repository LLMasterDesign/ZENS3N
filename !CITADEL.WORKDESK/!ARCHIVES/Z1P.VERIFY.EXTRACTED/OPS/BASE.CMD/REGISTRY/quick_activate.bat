@echo off
REM Quick .3ox Folder Activation (Personal Use - No Python Required)
REM Usage: quick_activate.bat SYNTH.BASE

if "%1"=="" (
    echo Usage: quick_activate.bat ENTITY_NAME
    echo Example: quick_activate.bat SYNTH.BASE
    exit /b 1
)

set ENTITY=%1
set BASE_PATH=P:\!CMD.BRIDGE\%ENTITY%
set NOW=%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%
set NOW=%NOW: =0%

echo.
echo ============================================================
echo   ACTIVATING %ENTITY%
echo ============================================================
echo.

echo Creating folder structure...
mkdir "%BASE_PATH%\.3ox" 2>nul
mkdir "%BASE_PATH%\0ut.3ox" 2>nul
mkdir "%BASE_PATH%\0ut.3ox\.SENT" 2>nul
mkdir "%BASE_PATH%\1n.3ox" 2>nul

echo Creating FILE.MANIFEST.txt...
(
echo # FILE.MANIFEST.txt for %ENTITY%
echo # Format: [TIMESTAMP] ^| STATUS ^| FILEPATH ^| DESTINATION ^| PRIORITY
echo.
echo # Example:
echo # [2025-10-07 14:00:00] ^| READY ^| report.yaml ^| INCOMING/%ENTITY:~0,-5% ^| HIGH
echo.
echo # Add your files below:
) > "%BASE_PATH%\0ut.3ox\FILE.MANIFEST.txt"

echo Creating AGENT.INSTRUCTIONS.md...
(
echo # Cursor Agent Instructions for %ENTITY%
echo.
echo ## 🎯 TRIGGER: "status update"
echo.
echo **When user says "status update":**
echo 1. Immediately provide current status summary
echo 2. Offer to send report to CMD via 0ut.3ox
echo 3. If user approves, create and send report
echo.
echo **Example Response:**
echo ```
echo 📊 Status Update for %ENTITY%:
echo - Current task: [describe]
echo - Progress: [X%%]
echo - Recent accomplishments: [list]
echo - Issues/blockers: [if any]
echo.
echo Would you like me to send this status report to CMD.BRIDGE? (Yes/No^)
echo ```
echo.
echo ---
echo.
echo ## 📡 How to Send Reports to CMD
echo.
echo ### Quick Report:
echo.
echo ```bash
echo # 1. Create your report
echo cat ^> 0ut.3ox/status_report.yaml ^<^< 'EOF'
echo type: status_report
echo station: %ENTITY%
echo event: [breakthrough^|status^|error^|completion]
echo details: ^|
echo   [Describe what you accomplished]
echo EOF
echo.
echo # 2. Add to manifest
echo echo "[%%date%% %%time%%] ^| READY ^| status_report.yaml ^| INCOMING/%ENTITY:~0,-5% ^| HIGH" ^>^> 0ut.3ox/FILE.MANIFEST.txt
echo ```
echo.
echo ---
echo.
echo ## 🚨 Reporting Triggers
echo.
echo Send report to CMD when:
echo - ✅ User says "status update"
echo - ✅ Breakthrough accomplished
echo - ✅ 20 passes completed  
echo - ✅ Error needs escalation
echo - ✅ Task completed
echo - ✅ User requests report
echo.
echo ---
echo.
echo **Station:** %ENTITY%
echo **Status:** ACTIVE
echo **CMD Route:** INCOMING/%ENTITY:~0,-5%
) > "%BASE_PATH%\.3ox\AGENT.INSTRUCTIONS.md"

echo Creating identity marker...
(
echo Entity: %ENTITY%
echo Activated: %NOW%
echo Status: ACTIVE
echo Type: STATION
) > "%BASE_PATH%\.3ox\IDENTITY.txt"

echo.
echo ============================================================
echo   %ENTITY% ACTIVATED!
echo ============================================================
echo.
echo   Location: %BASE_PATH%
echo   Instructions: %BASE_PATH%\.3ox\AGENT.INSTRUCTIONS.md
echo.
echo Next Steps:
echo   1. Agents can send reports to 0ut.3ox/
echo   2. Add entries to FILE.MANIFEST.txt
echo   3. Router will process automatically
echo.
echo ============================================================

