@echo off
chcp 65001 >nul
cd /d D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Trickoon.Bit
echo.
echo ========================================================================
echo           TRICKOON.GLYPH.BIT v1.0 - The Trash Mystic
echo           Spiritual Conversations + Cosmic Jokes
echo ========================================================================
echo.
echo Starting Trickoon Bot...
echo Created: October 5th, 2025
echo.
echo Checking for .env file...
if not exist .env (
    echo [ERROR] .env file not found!
    echo Please copy .env.example to .env and configure your API keys.
    pause
    exit /b 1
)
echo [OK] .env file found
echo.
C:\Users\RVNX\AppData\Local\Programs\Python\Python312\python.exe bot.py
pause

