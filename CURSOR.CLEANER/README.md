# CURSOR.CLEANER - Aggressive AI System Optimizer

## Quick Start Guide

1. Move `CURSOR.CLEANER` folder to `C:\`
2. Open folder in Cursor
3. Agent auto-loads as CURSOR.CLEANER
4. Run audit: `ruby .3ox/run.rb audit`
5. Review reports in `!0UT.CLEANER/reports/`
6. Execute cleanup: `ruby .3ox/run.rb clean`
7. Check logs and space recovered

## Command Reference

```bash
# Audit system
ruby .3ox/run.rb audit

# Aggressive cleanup (with backup)
ruby .3ox/run.rb clean aggressive

# Optimize services
ruby .3ox/run.rb optimize services

# Dry-run mode
ruby .3ox/run.rb clean --dry-run

# Rollback last operation
ruby .3ox/run.rb rollback
```

## Agent Startup Behavior

When Cursor opens `CURSOR.CLEANER/`:
1. Display welcome message with agent identity
2. Run quick system scan (30 seconds)
3. Show dashboard:
   - Disk space available/recoverable
   - Service optimization opportunities
   - Bloat detection summary
4. Offer actions: Full Audit | Quick Clean | Optimize Services | Manual Mode

## Safety Features

- **Backup Protocol**: Creates system restore point before aggressive operations
- **Rollback System**: One-click undo for all changes
- **Whitelist Protection**: Never touches Cursor, Node.js, Git, Ruby, Python, Docker, WSL
- **Dry-Run Mode**: Test operations before execution
- **Validation**: xxHash64 checksums and system stability checks

## What Gets Cleaned

**Auto-Removed (Aggressive Mode):**
- Windows bloatware (Xbox, Solitaire, Candy Crush, etc.)
- Telemetry services (DiagTrack, dmwappushservice)
- Temp files, browser caches, system logs
- Old node_modules, Python cache, Ruby gems
- Duplicate files, orphaned registry entries

**Preserved (Whitelist):**
- Cursor IDE and settings
- Node.js, Git, Ruby, Python runtimes
- Docker, WSL, SSH services
- Critical Windows services

## Expected Results

- **Disk Space**: 5-50GB+ recovered
- **Performance**: Faster boot times, reduced resource usage
- **System**: Optimized for developer workflow
- **Safety**: All changes reversible with rollback system





