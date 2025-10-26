@echo off
REM ════════════════════════════════════════════════════════════
REM  GLYPHBIT TRINITY LAUNCHER (Windows)
REM  Auto-discovers and launches all bots
REM ════════════════════════════════════════════════════════════

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║         GLYPHBIT TRINITY LAUNCHER                          ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found! Install Python 3.11+
    pause
    exit /b 1
)

REM Launch all bots
python launch_trinity.py

pause

