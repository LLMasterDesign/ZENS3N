# GitHub SSH Setup Script
# Generates SSH keys and configures Git for GitHub
# Created: 2024-10-08

Write-Host "`n=== GITHUB SSH SETUP ===" -ForegroundColor Cyan
Write-Host "=" * 50

# Step 1: Check for existing keys
Write-Host "`n[1/5] Checking for existing SSH keys..." -ForegroundColor Yellow

$sshDir = "$env:USERPROFILE\.ssh"
$keyPath = "$sshDir\id_ed25519"
$pubKeyPath = "$keyPath.pub"

if (Test-Path $pubKeyPath) {
    Write-Host "  [INFO] SSH key already exists!" -ForegroundColor Yellow
    Write-Host "  Location: $pubKeyPath" -ForegroundColor Cyan
    
    $response = Read-Host "`n  Use existing key? (Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        Write-Host "  [OK] Using existing key" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] Backing up old key..." -ForegroundColor Yellow
        Copy-Item $keyPath "$keyPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $pubKeyPath "$pubKeyPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Remove-Item $keyPath, $pubKeyPath
        $generateNew = $true
    }
} else {
    $generateNew = $true
}

# Step 2: Generate new key if needed
if ($generateNew) {
    Write-Host "`n[2/5] Generating new SSH key..." -ForegroundColor Yellow
    
    # Ensure .ssh directory exists
    if (!(Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }
    
    Write-Host "  Creating ED25519 key (modern & secure)..." -ForegroundColor Cyan
    Write-Host "  [INFO] When prompted for passphrase, press ENTER for no passphrase" -ForegroundColor Yellow
    Write-Host "         (or enter one for extra security)" -ForegroundColor Yellow
    
    # Use cmd to run ssh-keygen (handles interactive prompts better)
    $email = "RVNX-CMD-BRIDGE"
    cmd /c "ssh-keygen -t ed25519 -C `"$email`" -f `"$keyPath`""
    
    if (Test-Path $pubKeyPath) {
        Write-Host "  [OK] SSH key generated successfully!" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Key generation failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n[2/5] Skipping key generation (using existing)" -ForegroundColor Yellow
}

# Step 3: Display public key
Write-Host "`n[3/5] Your PUBLIC SSH Key:" -ForegroundColor Yellow
Write-Host "=" * 50 -ForegroundColor Cyan

$publicKey = Get-Content $pubKeyPath -Raw
Write-Host $publicKey -ForegroundColor Green

Write-Host "=" * 50 -ForegroundColor Cyan

# Step 4: Copy to clipboard
Write-Host "`n[4/5] Copying key to clipboard..." -ForegroundColor Yellow
try {
    $publicKey | Set-Clipboard
    Write-Host "  [OK] Public key copied to clipboard!" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] Could not copy to clipboard (manual copy needed)" -ForegroundColor Yellow
}

# Step 5: Instructions for GitHub
Write-Host "`n[5/5] Next Steps - Add Key to GitHub:" -ForegroundColor Yellow
Write-Host "=" * 50

Write-Host "`n  1. Go to: https://github.com/settings/keys" -ForegroundColor White
Write-Host "  2. Click: 'New SSH key'" -ForegroundColor White
Write-Host "  3. Title: 'CMD.BRIDGE PC' (or whatever you want)" -ForegroundColor White
Write-Host "  4. Key type: 'Authentication Key'" -ForegroundColor White
Write-Host "  5. Paste the key from clipboard (already copied!)" -ForegroundColor White
Write-Host "  6. Click: 'Add SSH key'" -ForegroundColor White

Write-Host "`n  [IMPORTANT] The key is still in your clipboard!" -ForegroundColor Yellow
Write-Host "              Just press CTRL+V on GitHub to paste it" -ForegroundColor Yellow

Write-Host "`n" + ("=" * 50)
Write-Host "Press ENTER after you've added the key to GitHub..." -ForegroundColor Cyan
Read-Host

# Step 6: Test connection
Write-Host "`n[6/6] Testing GitHub connection..." -ForegroundColor Yellow

# Start ssh-agent if not running
$sshAgent = Get-Service ssh-agent -ErrorAction SilentlyContinue
if ($sshAgent -and $sshAgent.Status -ne 'Running') {
    Write-Host "  Starting ssh-agent..." -ForegroundColor Cyan
    Start-Service ssh-agent
}

# Add key to agent
Write-Host "  Adding key to ssh-agent..." -ForegroundColor Cyan
ssh-add $keyPath 2>&1 | Out-Null

Write-Host "  Testing connection to GitHub..." -ForegroundColor Cyan
$testResult = ssh -T git@github.com 2>&1

if ($testResult -match "successfully authenticated" -or $testResult -match "Hi ") {
    Write-Host "  [OK] Successfully connected to GitHub!" -ForegroundColor Green
    Write-Host "`n$testResult" -ForegroundColor Cyan
} else {
    Write-Host "  [WARN] Connection test returned:" -ForegroundColor Yellow
    Write-Host "$testResult" -ForegroundColor White
}

# Summary
Write-Host "`n" + ("=" * 50)
Write-Host "=== SETUP COMPLETE ===" -ForegroundColor Green
Write-Host ("=" * 50)

Write-Host "`nSSH Key Location:" -ForegroundColor White
Write-Host "  Private: $keyPath" -ForegroundColor Cyan
Write-Host "  Public:  $pubKeyPath" -ForegroundColor Cyan

Write-Host "`nNext: Configure CMD.BRIDGE repository" -ForegroundColor Yellow
Write-Host "  Run: git remote add origin git@github.com:YOUR_USERNAME/CMD.BRIDGE.git" -ForegroundColor White

Write-Host "`n[REMINDER] NEVER share your private key (id_ed25519)" -ForegroundColor Red
Write-Host "           Only share the public key (id_ed25519.pub)" -ForegroundColor Yellow
Write-Host ""

