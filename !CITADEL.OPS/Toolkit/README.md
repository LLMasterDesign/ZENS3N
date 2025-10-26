# CITADEL Toolkit

**Operational tools for 7HE.CITADEL system**

---

## Available Tools

### File Operation Tools

**1n3ox-scan.py**
```bash
python 1n3ox-scan.py [inbox_path] [output_json]
```
- Scans inbox folders for new files
- Generates proposals.json with file metadata
- Includes hash, size, path for each file
- No files moved (scan only)

**1n3ox-apply.py**
```bash
python 1n3ox-apply.py decisions.json
```
- Applies approved file movement decisions
- Moves files based on decisions.json
- Logs operations to central log
- Works with label_*.toml system

### Category Management Tools

**cat-router.rb**
```bash
cd "(CAT.0) ADMIN/.3ox"
ruby cat-router.rb dashboard
```
- Dashboard view of all category activity
- Shows file counts, recent operations
- Category health monitoring

**cat-trace.rb**
```bash
cd "(CAT.0) ADMIN/.3ox"
ruby cat-trace.rb report
```
- Activity tracking across categories
- Operation timeline
- File movement history

---

## Usage Examples

### Scan for new files
```bash
python 1n3ox-scan.py "../!1N.3OX CITADEL.CMD" "proposals.json"
```

### Review and approve
Edit `decisions.json` to approve/reject proposals

### Apply movements
```bash
python 1n3ox-apply.py decisions.json
```

### Check system health
```bash
cd "R:\!LAUNCH.PAD\!CITADEL.WORKDESK\(CAT.0) ADMIN\.3ox"
ruby cat-router.rb dashboard
```

---

## Tool Dependencies

- Python 3.11+ (for scan/apply tools)
- Ruby 3.0+ (for router/trace tools)
- xxhash gem (`gem install xxhash`)

---

**Updated:** 2025-10-20  
**Version:** 1.0



