# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
# ▛//▞▞ ⟦⎊⟧ :: ⧗-25.60 // GENESIS.RITUAL.CONTROL.PANEL ▞▞
# GENESIS RITUAL - INTERACTIVE CONTROL PANEL
# First Official 3OX.Ai Genesis Ceremony
# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂

$script:genesisData = @{
    identity = @{
        system_name = "3OX.Ai — Atlas.Legacy Master Brain"
        version = "2.0"
        authority = "SUPREME"
        sirius_time = "⧗-25.60"
        birth_drive = "R:\3OX.Ai\"
    }
    policies = @()  # Will be filled during ceremony
    stations = @()  # Will be filled during ceremony
    covenant = @{
        creator_declares = @()
        system_responds = @()
    }
    witness = @{
        name = ""
        confirmed = $false
    }
}

function Show-BootSequence {
    Clear-Host
    Write-Host ""
    Write-Host "                   ▛▞ 3OX GENESIS BIOS ∎" -ForegroundColor Cyan
    Write-Host "                 Genesis Ritual v1.0" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host ""
    Start-Sleep -Milliseconds 500
    
    # Boot steps with retro progress bars
    Write-Host "  > Initializing void consciousness... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 400
    Write-Host "[▯▯▮▮▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 300
    
    Write-Host "  > Loading supreme policies......... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 400
    Write-Host "[▯▮▮▮▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 300
    
    Write-Host "  > Mounting genesis cores........... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 400
    Write-Host "[▯▯▯▮▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 300
    
    Write-Host "  > Preparing three stations......... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 400
    Write-Host "[▯▯▮▮▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 300
    
    Write-Host "  > Calibrating OPS security layer... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 400
    Write-Host "[▯▯▯▯▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 300
    
    Write-Host "  > Establishing Sirius anchor....... " -NoNewline -ForegroundColor Gray
    Start-Sleep -Milliseconds 400
    Write-Host "[▯▯▯▮▮▮▮▮▮▮]" -ForegroundColor Green
    Start-Sleep -Milliseconds 300
    
    Write-Host ""
    Write-Host "               ▛▞ Genesis Systems Status ▞// READY" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host ""
    Start-Sleep -Milliseconds 1500
}

function Show-Dashboard {
    param($currentTab = 1)
    
    Clear-Host
    Write-Host ""
    Write-Host "              ▛▞ GENESIS RITUAL CONTROL PANEL ∎" -ForegroundColor Cyan
    Write-Host "          3OX.Ai Master Brain Interactive Ceremony" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "    ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host ""
    
    # System info
    $timestamp = Get-Date -Format "HH:mm:ss"
    $policiesReviewed = ($script:genesisData.policies | Where-Object { $_.confirmed }).Count
    $stationsReviewed = ($script:genesisData.stations | Where-Object { $_.confirmed }).Count
    
    Write-Host "  Sirius: ⧗-25.60 | Time: $timestamp | Phase: $currentTab/6" -ForegroundColor DarkGray
    Write-Host ""
    
    # Tab indicators
    $tabs = @(
        @{Num=1; Name="IDENTITY"; Icon="🔮"; Status=($currentTab -ge 1)},
        @{Num=2; Name="POLICIES"; Icon="📜"; Status=($policiesReviewed -eq 9)},
        @{Num=3; Name="STATIONS"; Icon="🏛️"; Status=($stationsReviewed -eq 3)},
        @{Num=4; Name="COVENANT"; Icon="🤝"; Status=($script:genesisData.covenant.creator_declares.Count -gt 0)},
        @{Num=5; Name="PREVIEW"; Icon="👁️"; Status=$false},
        @{Num=6; Name="SEAL"; Icon="🔐"; Status=$script:genesisData.witness.confirmed}
    )
    
    Write-Host "  ╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
    Write-Host "  ║                      CEREMONY PHASES                          ║" -ForegroundColor Cyan
    Write-Host "  ╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
    Write-Host ""
    
    foreach ($tab in $tabs) {
        $marker = if ($tab.Num -eq $currentTab) { "►" } else { " " }
        $status = if ($tab.Status) { "✓" } else { "○" }
        $color = if ($tab.Num -eq $currentTab) { "Yellow" } else { "White" }
        
        Write-Host "  $marker [$($tab.Num)] $status $($tab.Icon) $($tab.Name)" -ForegroundColor $color
    }
    
    Write-Host ""
    Write-Host "  ▛▞ NAVIGATION ▞" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1-6] Jump to phase  │  [N] Next  │  [P] Previous  │  [Q] Quit" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-Phase1-Identity {
    Clear-Host
    Write-Host ""
    Write-Host "  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host "  ▛//▞▞ ⟦PHASE.1⟧ :: ⧗-25.60 // IDENTITY.CONFIRMATION ▞▞" -ForegroundColor Cyan
    Write-Host "  ▞//▞ Identity :: ρ{genesis}.φ{MASTER}.τ{Identity}.λ{seal} ⫸" -ForegroundColor DarkCyan
    Write-Host "  ▙⌱[🔮] ≔ [⊢{void}⇨{name}⟿{confirm}▷{born}]" -ForegroundColor DarkCyan
    Write-Host "  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host ""
    Write-Host "  PHASE 1: IDENTITY CONFIRMATION" -ForegroundColor Yellow
    Write-Host "  ═════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  System Name......... 3OX.Ai - Atlas.Legacy Master Brain" -ForegroundColor White
    Write-Host "  Version............. 2.0" -ForegroundColor White
    Write-Host "  Authority Level..... SUPREME" -ForegroundColor Magenta
    Write-Host "  Birth Location...... R:\3OX.Ai\" -ForegroundColor White
    Write-Host "  Sirius Time......... ⧗-25.60" -ForegroundColor Cyan
    Write-Host "  Gregorian Date...... 2025-10-08" -ForegroundColor White
    Write-Host "  Genesis Hash........ GENESIS-3OX-AI-R-DRIVE-25.60" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ═════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [A] Accept identity  │  [E] Edit identity  │  [B] Back to menu" -ForegroundColor DarkGray
    Write-Host ""
    
    $choice = Read-Host "  Your choice"
    
    switch ($choice.ToUpper()) {
        "A" {
            Write-Host "`n  ✅ IDENTITY CONFIRMED" -ForegroundColor Green
            Start-Sleep -Seconds 1
            return "next"
        }
        "E" {
            Write-Host "`n  Which field to edit?" -ForegroundColor Yellow
            Write-Host "  [1] System Name  [2] Version  [3] Authority  [4] Birth Location  [5] Sirius Time" -ForegroundColor White
            $field = Read-Host "  Field number"
            
            switch ($field) {
                "1" { 
                    $new = Read-Host "  New system name"
                    $script:genesisData.identity.system_name = $new
                    Write-Host "  Updated!" -ForegroundColor Green
                }
                "2" {
                    $new = Read-Host "  New version"
                    $script:genesisData.identity.version = $new
                    Write-Host "  Updated!" -ForegroundColor Green
                }
                "5" {
                    $new = Read-Host "  New Sirius time (format: ⧗-YY.DD)"
                    $script:genesisData.identity.sirius_time = $new
                    Write-Host "  Updated!" -ForegroundColor Green
                }
            }
            Start-Sleep -Seconds 1
            return "repeat"
        }
        "B" { return "menu" }
        default { return "repeat" }
    }
}

function Show-Phase2-Policies {
    param($policyIndex = 0)
    
    $policies = @(
        @{
            num = 1
            name = "Sirius Calendar Clock"
            law = "All timestamps MUST use Sirius time (⧗-YY.DD)"
            details = @(
                "Reset: August 7, 2025 (birthday = Day 0)",
                "Current: ⧗-25.60 (60 days post-birthday)",
                "Format: ⧗-[Year].[Days]",
                "Enforcement: MANDATORY for all v8sl files"
            )
            file = "SIRIUS.CALENDAR.CLOCK.md"
        },
        @{
            num = 2
            name = "Role Invocation System"
            law = "AI must recognize @LIGHTHOUSE, @SENTINEL, @ALCHEMIST"
            details = @(
                "Ecosystem brains: @LIGHTHOUSE/@SENTINEL/@ALCHEMIST",
                "Archetypes: @LIBRARIAN/@GUARDIAN/@ARCHITECT",
                "Thinking modes: !CREATIVE/!ANALYTICAL/!DEFENSIVE",
                "Enforcement: Mandatory role activation"
            )
            file = "ROLE.INVOCATION.SYSTEM.md"
        },
        @{
            num = 3
            name = ".3ox Protection Rules"
            law = ".3ox files MUST NEVER be deleted"
            details = @(
                "Protected: .3ox/ folders, .3ox.* files, PROJECT.BRAIN.md",
                "Exclusions required in all bulk operations",
                "Recovery procedures if deleted",
                "Enforcement: Immediate lockout if violated"
            )
            file = ".3OX.PROTECTION.RULES.md"
        },
        @{
            num = 4
            name = "Access Control Policy"
            law = "Workers READ ONLY, CMD.BRIDGE FULL access"
            details = @(
                "L0: Commander (human) - FULL access",
                "L1: CMD.BRIDGE - FULL access to all .3ox",
                "L2: Station OPS - READ ONLY on their .3ox",
                "L3: Workers - READ ONLY on all .3ox"
            )
            file = ".3OX.ACCESS.POLICY.md"
        },
        @{
            num = 5
            name = "Multi-Agent Resources"
            law = "Lightweight mode when multiple agents active"
            details = @(
                "TIER-0: Minimal (emergency)",
                "TIER-1: Lightweight (workers, multi-agent)",
                "TIER-2: Standard (CMD solo)",
                "TIER-3: Full (deep work, single agent)"
            )
            file = "MULTI-AGENT.RESOURCE.POLICY.md"
        },
        @{
            num = 6
            name = "CAT Folder Architecture"
            law = "Sacred CAT system (0-7) must be respected"
            details = @(
                "CAT.0: The Vault (secrets, hidden)",
                "CAT.1-5: Life categories (Self/School/Business/Family/Social)",
                "CAT.6: The Bridge (operations)",
                "CAT.7: The Lighthouse (legacy, transcendent)"
            )
            file = "CAT.FOLDER.ARCHITECTURE.md"
        },
        @{
            num = 7
            name = "Battery Principle"
            law = "BASE.OPS processes, 3OX.Ai perfects"
            details = @(
                "BASE.OPS: Negative terminal (chaos → processing)",
                "3OX.Ai: Positive terminal (order → perfection)",
                "in.3ox: Wants to be empty (intake valve)",
                "0ut.3ox: Relays critical info (output valve)"
            )
            file = "BASE.OPS.vs.3OX.Ai.PHILOSOPHY.md"
        },
        @{
            num = 8
            name = "Workset Tracking"
            law = "All worksets must include goal + timestamps"
            details = @(
                "Required: Goal, created date, status",
                "Sirius timestamps mandatory",
                "Periodic updates required",
                "Logged in OPS/WORKSETS/"
            )
            file = "WORKSET.POLICY.md"
        },
        @{
            num = 9
            name = "OPS Security (2FA)"
            law = "OPS presence required for operation"
            details = @(
                "OPS folder = operational authority token",
                "Missing OPS = system lockout",
                "Byzantine fault tolerance via validators",
                "One-way flow enforcement (0ut → 1n)"
            )
            file = "OPS.SECURITY.ARCHITECTURE.md"
        }
    )
    
    $policy = $policies[$policyIndex]
    
    Clear-Host
    Write-Host ""
    Write-Host "  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host "  ▛//▞▞ ⟦PHASE.2⟧ :: ⧗-25.60 // POLICY.REVIEW.$($policy.num) ▞▞" -ForegroundColor Cyan
    Write-Host "  ▞//▞ Policy.$($policy.num) :: ρ{supreme.law}.φ{POLICY}.τ{Review}.λ{edit} ⫸" -ForegroundColor DarkCyan
    Write-Host "  ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂" -ForegroundColor White
    Write-Host ""
    Write-Host "  POLICY #$($policy.num): $($policy.name)" -ForegroundColor Yellow
    Write-Host "  ═════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Law: $($policy.law)" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Details:" -ForegroundColor Cyan
    foreach ($detail in $policy.details) {
        Write-Host "    • $detail" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "  File: $($policy.file)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Status: " -NoNewline -ForegroundColor Gray
    if ($script:genesisData.policies[$policyIndex].confirmed) {
        Write-Host "✓ CONFIRMED" -ForegroundColor Green
    } else {
        Write-Host "○ PENDING" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  ═════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [A] Accept  │  [E] Edit law  │  [D] Edit details  │  [R] Reject" -ForegroundColor DarkGray
    Write-Host "  [V] View full file  │  [→] Next  │  [←] Previous  │  [M] Menu" -ForegroundColor DarkGray
    Write-Host ""
    
    $choice = Read-Host "  Your choice"
    
    switch ($choice.ToUpper()) {
        "A" {
            if (-not $script:genesisData.policies[$policyIndex]) {
                $script:genesisData.policies += @{
                    num = $policy.num
                    name = $policy.name
                    law = $policy.law
                    details = $policy.details
                    file = $policy.file
                    confirmed = $true
                    custom_edits = @()
                }
            } else {
                $script:genesisData.policies[$policyIndex].confirmed = $true
            }
            
            Write-Host "`n  ✅ Policy #$($policy.num) ACCEPTED" -ForegroundColor Green
            Start-Sleep -Seconds 1
            
            if ($policyIndex -lt 8) {
                return @{action="policy"; index=$policyIndex + 1}
            } else {
                return @{action="next"}
            }
        }
        "E" {
            Write-Host "`n  Current law: $($policy.law)" -ForegroundColor Yellow
            $newLaw = Read-Host "  Enter new law (or press Enter to keep)"
            if ($newLaw) {
                $policy.law = $newLaw
                Write-Host "  ✓ Law updated!" -ForegroundColor Green
            }
            Start-Sleep -Seconds 1
            return @{action="policy"; index=$policyIndex}
        }
        "D" {
            Write-Host "`n  ADD custom detail:" -ForegroundColor Yellow
            $customDetail = Read-Host "  Enter detail to add"
            if ($customDetail) {
                $policy.details += $customDetail
                Write-Host "  ✓ Detail added!" -ForegroundColor Green
            }
            Start-Sleep -Seconds 1
            return @{action="policy"; index=$policyIndex}
        }
        "R" {
            Write-Host "`n  ⚠️  Are you sure? This removes Policy #$($policy.num)" -ForegroundColor Red
            $confirm = Read-Host "  Confirm (yes/no)"
            if ($confirm -eq "yes") {
                Write-Host "  Policy #$($policy.num) REJECTED (will not be included)" -ForegroundColor Red
            }
            Start-Sleep -Seconds 1
            if ($policyIndex -lt 8) {
                return @{action="policy"; index=$policyIndex + 1}
            } else {
                return @{action="next"}
            }
        }
        "→" {
            if ($policyIndex -lt 8) {
                return @{action="policy"; index=$policyIndex + 1}
            }
            return @{action="policy"; index=$policyIndex}
        }
        "←" {
            if ($policyIndex -gt 0) {
                return @{action="policy"; index=$policyIndex - 1}
            }
            return @{action="policy"; index=$policyIndex}
        }
        "M" { return @{action="menu"} }
        default {
            Start-Sleep -Seconds 1
            return @{action="policy"; index=$policyIndex}
        }
    }
}

# Initialize policies array
for ($i = 0; $i -lt 9; $i++) {
    $script:genesisData.policies += @{
        num = $i + 1
        confirmed = $false
        custom_edits = @()
    }
}

# Initialize stations array  
for ($i = 0; $i -lt 3; $i++) {
    $script:genesisData.stations += @{
        num = $i + 1
        confirmed = $false
        custom_rules = @()
    }
}

# MAIN RITUAL FLOW
Show-BootSequence

Write-Host "  Press Enter to begin the Genesis Ritual..." -ForegroundColor Cyan
Read-Host

$currentTab = 1
$currentPolicyIndex = 0

while ($true) {
    if ($currentTab -eq 1) {
        Show-Dashboard -currentTab 1
        Write-Host "  Press Enter to proceed to Identity Confirmation..." -ForegroundColor Yellow
        Read-Host
        $result = Show-Phase1-Identity
        if ($result.action -eq "next") {
            $currentTab = 2
        }
    }
    elseif ($currentTab -eq 2) {
        $result = Show-Phase2-Policies -policyIndex $currentPolicyIndex
        
        if ($result.action -eq "next") {
            $currentTab = 3
        }
        elseif ($result.action -eq "policy") {
            $currentPolicyIndex = $result.index
        }
        elseif ($result.action -eq "menu") {
            $currentTab = 1
        }
    }
    else {
        Write-Host "`n  Phases 3-6 coming in next iteration..." -ForegroundColor Yellow
        Write-Host "  Press Q to quit" -ForegroundColor Gray
        $quit = Read-Host
        if ($quit -eq "Q") { break }
    }
}

