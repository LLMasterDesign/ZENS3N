@echo off
REM ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
REM GENESIS RITUAL BOT LAUNCHER
REM ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

cd /d "%~dp0"

echo.
echo ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
echo ▛//▞▞ ⟦⎊⟧ :: ⧗-25.60 // GENESIS.RITUAL.LAUNCHER ▞▞
echo ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
echo.
echo Starting Genesis Ritual Bot...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python not found!
    echo Install Python 3.8+ to run the ritual.
    pause
    exit /b 1
)

REM Check if anthropic is installed (optional)
python -c "import anthropic" >nul 2>&1
if %errorlevel% neq 0 (
    echo Note: Anthropic SDK not installed - AI help will be unavailable
    echo To enable: pip install anthropic
    echo.
)

REM Run the ritual
python genesis_ritual_bot.py

pause

