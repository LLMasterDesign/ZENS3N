@echo off
title DEEP CLEANUP - ALL DUPLICATES
cd /d "%~dp0"
echo.
echo ================================================================
echo   DEEP CLEANUP - REMOVE ALL DUPLICATE CAT FOLDERS
echo ================================================================
echo.
echo WARNING: This will delete ~87 duplicate CAT folders!
echo.
echo KEEPS ONLY:
echo   - 15 production CAT folders (OBSIDIAN, RVNx, SYNTH)
echo   - 5 Legacy blueprint CAT folders
echo   - 5 Deployment package CAT folders
echo.
echo DELETES:
echo   - All other CAT folders everywhere else
echo   - Extracts files first before deleting
echo.
echo This should free up significant disk space!
echo.
pause
powershell -ExecutionPolicy Bypass -NoProfile -File "DEEP.CLEANUP.ALL.DUPLICATES.ps1"
pause

