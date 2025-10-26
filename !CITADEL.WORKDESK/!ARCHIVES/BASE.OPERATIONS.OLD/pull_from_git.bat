@echo off
REM Git Passthru: Pull from all station branches to INCOMING/
REM Processes: synth-out, rvnx-out, obsidian-out

cd /d "P:\!CMD.BRIDGE\!BASE.OPERATIONS"

echo.
echo ============================================================
echo   GIT PASSTHRU: Pulling from all stations
echo ============================================================
echo.

REM Check if GIT.PASSTHRU exists
if not exist "GIT.PASSTHRU" (
    echo Cloning GIT.BASE repository...
    git clone https://github.com/LLarzMasterD/GIT.BASE.git GIT.PASSTHRU
    
    cd GIT.PASSTHRU
    
    REM Set up tracking for all branches
    git fetch --all
    for %%b in (synth-out rvnx-out obsidian-out) do (
        git checkout -b %%b origin/%%b 2>nul
    )
    git checkout main
    
    cd ..
)

cd GIT.PASSTHRU

REM Fetch all updates
echo Fetching updates from GitHub...
git fetch --all --quiet

REM Process each station branch
for %%s in (synth rvnx obsidian) do (
    echo.
    echo ────────────────────────────────────────
    echo Processing %%s-out branch...
    echo ────────────────────────────────────────
    
    REM Checkout branch
    git checkout %%s-out --quiet
    git pull origin %%s-out --quiet
    
    REM Count files
    set COUNT=0
    for %%f in (*.yaml *.md *.json) do set /a COUNT+=1
    
    if %COUNT% GTR 0 (
        REM Create INCOMING folder if needed
        mkdir "..\INCOMING\%%s" 2>nul
        
        REM Copy files
        copy *.yaml "..\INCOMING\%%s\" >nul 2>&1
        copy *.md "..\INCOMING\%%s\" >nul 2>&1
        copy *.json "..\INCOMING\%%s\" >nul 2>&1
        
        echo ✅ Copied %COUNT% file(s) to INCOMING\%%s\
        
        REM Get receipt (commit hash)
        for /f "tokens=*" %%h in ('git rev-parse HEAD') do (
            echo [%DATE% %TIME%] ^| %%s ^| Receipt: %%h ^| Files: %COUNT% >> ..\INCOMING\REGISTRY.LOG
            echo    Receipt: %%h
        )
        
        REM List files
        echo    Files:
        for %%f in (*.yaml *.md *.json) do echo       - %%f
        
        REM Cleanup (delete from Git branch after copy)
        del *.yaml *.md *.json 2>nul
        git add -A
        git commit -m "Cleanup: Files processed by BASE.OPS %DATE% %TIME%" --quiet
        git push origin %%s-out --quiet 2>&1
        
    ) else (
        echo No new files from %%s
    )
)

git checkout main --quiet

cd ..

echo.
echo ============================================================
echo   ✅ Pull complete
echo ============================================================
echo.
echo Check INCOMING/ folders for new files:
echo   - INCOMING\synth\
echo   - INCOMING\rvnx\
echo   - INCOMING\obsidian\
echo.
echo View transaction log: INCOMING\REGISTRY.LOG
echo.

