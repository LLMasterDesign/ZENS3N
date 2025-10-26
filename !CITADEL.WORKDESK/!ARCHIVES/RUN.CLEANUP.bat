@echo off
title 1N.3OX CAT CLEANUP
cd /d "%~dp0"
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║         1N.3OX CAT FOLDER CLEANUP                        ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo This will:
echo   1. Extract files from duplicate CAT folders
echo   2. Move them to production 1n.3ox folders
echo   3. Delete empty duplicates
echo.
echo Production folders will be PRESERVED:
echo   - OBSIDIAN.BASE\(CAT.1-5)
echo   - RVNx.BASE\(CAT.1-5)
echo   - SYNTH.BASE\(CAT.1-5)
echo   - Legacy blueprint
echo   - Deployment package
echo.
pause
powershell -ExecutionPolicy Bypass -NoProfile -File "CLEANUP.CAT.DUPLICATES.ps1"
pause

