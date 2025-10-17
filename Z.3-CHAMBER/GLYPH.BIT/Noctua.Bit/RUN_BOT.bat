@echo off
chcp 65001 >nul
cd /d D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit
echo.
echo ========================================================================
echo              OWL.GLYPH.BIT v1.0 - Noctua GlyphBit
echo              First Official Telegram Inline Responder
echo ========================================================================
echo.
echo Starting Noctua Bot...
echo Created: October 3rd, 2025
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

