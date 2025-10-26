# ▛▞ GLYPHBIT CLEANUP UTILITY ∎
# Archive old/obsolete files

Write-Host ""
Write-Host "▛▞ GLYPHBIT CLEANUP UTILITY ∎" -ForegroundColor Cyan
Write-Host ""

$baseDir = $PSScriptRoot
$archiveDir = Join-Path $baseDir "_ARCHIVE"

# Create archive if needed
if (-not (Test-Path $archiveDir)) {
    New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null
}

Write-Host "Archiving old files..." -ForegroundColor Yellow
Write-Host ""

# Old files to archive
$oldFiles = @(
    "gyphbit-noctua",           # Old Noctua version
    "GROUP.AGENT",               # Old group agent (replaced by shared mind)
    "CONTROL_PANEL.ps1",        # Old control panel
    "CONTROL_PANEL_SIMPLE.ps1", # Simple version
    "1N.3OX.MONITOR.ps1",       # Old monitor
    "SIMPLE.MONITOR.ps1",       # Simple monitor
    "GlyphBit Forge"            # TP.Gen stuff (moved to !1N.3OX TELE.PROMPTR)
)

$archivedCount = 0

foreach ($file in $oldFiles) {
    $sourcePath = Join-Path $baseDir $file
    if (Test-Path $sourcePath) {
        $destPath = Join-Path $archiveDir $file
        Move-Item -Path $sourcePath -Destination $destPath -Force -ErrorAction SilentlyContinue
        Write-Host "  ✓ Archived: $file" -ForegroundColor Green
        $archivedCount++
    }
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "║                    CLEANUP COMPLETE                           ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Files archived: $archivedCount" -ForegroundColor White
Write-Host "  Location: _ARCHIVE\" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ GLYPH.BIT folder is now clean!" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to continue"




