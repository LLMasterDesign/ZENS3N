```r
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: CALIBRATION CHANGELOG ▞▞
//▞ Version History & Discovery Log :: track learnings and updates
▞⌱⟦📝⟧ :: [version.control] [discovery.log] [learning.capture]
〔runtime.3ox.context〕

# CALIBRATION CHANGELOG

**Current Version**: v1.0.0  
**Last Updated**: 2025-10-20  
**Format**: Semantic Versioning (MAJOR.MINOR.PATCH)

## ▛▞ VERSION HISTORY ::

### v1.0.0 - 2025-10-20
**Status**: CURRENT

**Changes**:
- Initial calibration prompt created
- Proper PiCO banner format (lines 1-5)
- Removed redundant `---` separators (using only `:: ∎`)
- Reduced unnecessary backticks (~40% reduction)
- Token count: ~2,554 tokens (cl100k_base)
- Added 13 major sections
- Implemented GUARDIAN Sentinel configuration

**Receipt**: calibration_prompt_cleaned  
**Hash**: 16c1e198dd9ad644

:: ∎

## ▛▞ DISCOVERY LOG ::

### What This Tracks

When agent discovers:
- New tool capabilities
- Better patterns/workflows
- Error resolutions
- Integration points
- Optimization techniques

These get logged here, then merged into calibration on version bump.

### Format

```yaml
discovery:
  date: YYYY-MM-DD HH:MM:SS
  type: [tool_call|pattern|integration|optimization|error_fix]
  description: "What was discovered"
  impact: [high|medium|low]
  merge_target: "Which section of calibration to update"
  receipt: "receipt_hash_if_applicable"
```

:: ∎

## ▛▞ PENDING DISCOVERIES ::

### Awaiting Merge to v1.1.0

None yet - fresh calibration.

:: ∎

## ▛▞ VERSIONING RULES ::

**MAJOR.MINOR.PATCH**

**MAJOR** (x.0.0):
- Complete restructure of calibration
- Breaking changes to agent behavior
- New brain type or fundamental role change

**MINOR** (1.x.0):
- New sections added
- New tool capabilities discovered
- Significant workflow improvements
- New integration points

**PATCH** (1.0.x):
- Bug fixes
- Clarifications
- Minor wording improvements
- Token optimizations

:: ∎

## ▛▞ MERGE PROTOCOL ::

### When to Version Bump

1. **Check discoveries**: Review PENDING DISCOVERIES section
2. **Assess impact**: Count high/medium impact items
3. **Version decision**:
   - 5+ high impact = MINOR bump
   - 10+ medium impact = MINOR bump
   - Any breaking change = MAJOR bump
   - Otherwise = PATCH bump
4. **Merge changes**: Update CURSOR.AGENT.CALIBRATION.md
5. **Document**: Move discoveries to VERSION HISTORY
6. **Receipt**: Generate receipt with new version hash

### How to Log Discovery

```ruby
# From agent session, when new pattern discovered:
ruby run.rb discovery_logged "[type]:[description]"

# Example:
ruby run.rb discovery_logged "tool_call:Found grep with multiline support"
ruby run.rb discovery_logged "pattern:Output routing can auto-create parent dirs"
ruby run.rb discovery_logged "optimization:Reduced token usage with inline lists"
```

### Merge Script

Location: `!CMD.CENTER/Toolkit/merge_discoveries.rb`
Usage: Reads this changelog, prompts for changes, updates calibration

:: ∎

```r
///▙ END :: CALIBRATION.CHANGELOG
▛//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙
```

:: ∎

