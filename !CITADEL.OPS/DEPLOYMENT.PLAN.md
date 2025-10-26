# Advanced Setup Deployment Plan

**Date:** 2025-10-20  
**Purpose:** Deploy brain configurations, local tools, and discovery systems to all operational locations  
**Base Template:** 7HE.CITADEL setup (CITADEL.OPS)

---

## ▛▞ DEPLOYMENT STATUS ::

### ✅ COMPLETE

| Location | Brain | Type | Tools | Discovery | Status |
|----------|-------|------|-------|-----------|--------|
| **!CITADEL.OPS** | 7HE.CITADEL | Citadel | ✓ 9 tools | ✓ Active | ✅ OPERATIONAL |
| **!CITADEL.WORKDESK/CAT.0** | CAT.ROUTER | Sentinel | ✓ 9 tools | ✓ Active | ✅ OPERATIONAL |
| **CAT.1 SELF** | CAT.1.SELF | Sentinel | ✓ 9 tools | ✓ Active | ✅ OPERATIONAL |
| **CAT.2 EDUCATION** | CAT.2.EDUCATION | Sentinel | ✓ 9 tools | ✓ Active | ✅ OPERATIONAL |
| **CAT.3 BUSINESS** | CAT.3.BUSINESS | Sentinel | ✓ 9 tools | ✓ Active | ✅ OPERATIONAL |
| **CAT.4 FAMILY** | CAT.4.FAMILY | Sentinel | ✓ 9 tools | ✓ Active | ✅ OPERATIONAL |
| **CAT.5 SOCIAL** | CAT.5.SOCIAL | Sentinel | ✓ 9 tools | ✓ Active | ✅ OPERATIONAL |
| **SPEC.WRITER** | SPEC.WRITER | Alchemist | ✓ 7 spec tools | N/A | ✅ OPERATIONAL |

### 🔄 NEEDS UPDATE

| Location | Current Brain | Target Brain | Type | Priority |
|----------|---------------|--------------|------|----------|
| **!CMD.CENTER** | GUARDIAN | CMD.HUB | Sentinel | HIGH |

### ⚠️ EVALUATION NEEDED

| Location | Has .3ox? | Purpose | Action |
|----------|-----------|---------|--------|
| **!ARCHIVES** | ❌ | Archive storage | Determine if needs runtime |
| **3OX.Ai** | ❓ | Unknown | Check structure |

:: ∎

---

## ▛▞ DEPLOYMENT COMPONENTS ::

### What Gets Deployed

**1. Brain Configuration**
- Updated `brain.rs` with proper identity
- Compiled `brain.exe`
- Appropriate BrainType (Citadel, Sentinel, Alchemist, Lighthouse)
- Clear instructions for agent role

**2. Tools Configuration**
- Updated `tools.yml` with relevant tools
- Local tools inventory
- External tools registry
- Dependencies documented

**3. Discovery System**
- Turn counter integration
- Discovery logging capability
- Changelog integration
- Auto-discovery triggers

**4. Local Tooling**
- File operation scripts (if needed)
- CAT management tools (if applicable)
- Discovery scripts (shared from !CMD.CENTER/Toolkit)
- Station-specific tools

**5. Documentation**
- Logbook/ directory
- Operational logs
- Station-specific README
- Integration points documented

:: ∎

---

## ▛▞ BRAIN TYPE GUIDELINES ::

### Citadel (Command-Orchestrator)
**Use for:** Central command authority, master orchestrators  
**Example:** 7HE.CITADEL  
**Traits:** Authoritative, coordinates all operations, validates everything

### Sentinel (Guardian-Synchronizer)
**Use for:** Routers, coordinators, multi-system integrators  
**Examples:** CAT.ROUTER, CMD.HUB  
**Traits:** Routes traffic, maintains connections, orchestrates flow

### Alchemist (Creator-Architect)
**Use for:** Specialized creation/transformation stations  
**Examples:** SPEC.WRITER, SYNTH bases  
**Traits:** Creates, transforms, builds, specializes

### Lighthouse (Librarian-Weaver)
**Use for:** Knowledge bases, documentation systems  
**Examples:** OBSIDIAN bases, libraries  
**Traits:** Organizes knowledge, maintains connections, weaves context

:: ∎

---

## ▛▞ !CMD.CENTER DEPLOYMENT PLAN ::

### Current State
```json
{
  "name": "GUARDIAN",
  "type": "Sentinel",
  "status": "Outdated"
}
```

### Target State
```json
{
  "name": "CMD.HUB",
  "type": "Sentinel",
  "purpose": "Central coordination hub connecting all operational bases",
  "responsibilities": [
    "Route operations between bases",
    "Coordinate cross-base workflows",
    "Aggregate logs and reports",
    "Manage external integrations (GitHub, etc)",
    "Orchestrate discovery system",
    "Maintain toolkit registry"
  ]
}
```

### Deployment Steps

**Phase 1: Brain Update**
- [ ] Update brain.rs → CMD.HUB (Sentinel)
- [ ] Add Citadel to BrainType enum
- [ ] Update instructions for coordination role
- [ ] Compile brain.exe
- [ ] Test runtime

**Phase 2: Tools Update**
- [ ] Update tools.yml with coordination tools
- [ ] Add external base connectors
- [ ] Document GitHub integration tools
- [ ] Add log aggregation tools
- [ ] Update dependencies

**Phase 3: Discovery Integration**
- [ ] Ensure discovery scripts accessible
- [ ] Test turn counter
- [ ] Verify log_discovery.rb works
- [ ] Check changelog integration
- [ ] Test auto-discovery triggers

**Phase 4: Documentation**
- [ ] Create Logbook/ if missing
- [ ] Initialize CMD.HUB.log
- [ ] Document base connections
- [ ] Update README
- [ ] Document routing rules

**Phase 5: Validation**
- [ ] Run brain.exe config
- [ ] Test ruby run.rb
- [ ] Verify tools loaded
- [ ] Check output routing
- [ ] Validate discovery logging

:: ∎

---

## ▛▞ ADDITIONAL LOCATIONS ::

### To Investigate

**3OX.Ai/**
- Check if operational or archived
- Determine if needs .3ox runtime
- Identify purpose in current architecture

**Other Bases (mentioned in routing)**
- OBSIDIAN.BASE
- RVNx.BASE  
- SYNTH.BASE
- Determine locations and .3ox status

### Deployment Order (After CMD.CENTER)

1. **High Priority** - Active operational bases
2. **Medium Priority** - Specialized stations
3. **Low Priority** - Archive/reference locations
4. **Evaluation** - Determine if .3ox needed

:: ∎

---

## ▛▞ SUCCESS CRITERIA ::

### Per-Location Checklist

- [ ] Brain compiled and identifies correctly
- [ ] Runtime test passes (ruby run.rb)
- [ ] Tools load successfully
- [ ] Output routing works
- [ ] Discovery logging operational
- [ ] Logbook initialized
- [ ] Integration with CMD.CENTER verified
- [ ] Documented in Citadel.log

### System-Wide Validation

- [ ] All brains report correct identities
- [ ] Discovery system works across all locations
- [ ] Output routing goes to correct destinations
- [ ] CMD.CENTER can coordinate all bases
- [ ] Local tooling reduces API overhead
- [ ] Logs aggregate properly

:: ∎

---

## ▛▞ NEXT ACTIONS ::

**Immediate:**
1. Deploy to !CMD.CENTER (HIGH priority)
2. Test coordination between CITADEL.OPS ↔ CMD.CENTER
3. Verify log pickup from !0UT.3OX

**Following:**
1. Investigate 3OX.Ai structure
2. Locate and assess external bases
3. Create deployment packages for each
4. Systematic rollout

**Continuous:**
- Update Citadel.log after each deployment
- Test integration at each step
- Verify API optimization maintained
- Document learnings in discovery system

:: ∎

---

**Deployment Protocol:** ADVANCED.SETUP.ROLLOUT v1.0.0  
**Template Source:** 7HE.CITADEL (CITADEL.OPS)  
**Coordinator:** 7HE.CITADEL (Command Authority)

:: ∎



