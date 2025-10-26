# CITADEL Toolkit Index

**Quick reference for all operational tools**

Updated: 2025-10-20

---

## 📁 File Operation Tools (Python)

### 1n3ox-scan.py
**Purpose:** Scan inbox for new files  
**Usage:** `python 1n3ox-scan.py [inbox_path] [output_json]`  
**Output:** proposals.json with file metadata  
**When:** Before moving files, to review what's available

### 1n3ox-apply.py
**Purpose:** Apply approved file movements  
**Usage:** `python 1n3ox-apply.py decisions.json`  
**Output:** Moves files, writes receipts  
**When:** After reviewing proposals and creating decisions.json

---

## 🎭 Category Management Tools (Ruby)

### cat-router.rb
**Purpose:** Dashboard for all CAT categories  
**Usage:** `ruby cat-router.rb dashboard`  
**Output:** Activity overview across CAT.0-5  
**When:** Need system overview

### cat-trace.rb
**Purpose:** Activity tracking and reporting  
**Usage:** `ruby cat-trace.rb report`  
**Output:** Timeline of operations  
**When:** Need audit trail or debugging

---

## 🔧 Typical Workflows

### Workflow 1: Process New Files

```bash
# Step 1: Scan inbox
cd "R:\!LAUNCH.PAD\!CITADEL.OPS\Toolkit"
python 1n3ox-scan.py "../!1N.3OX CITADEL.CMD" proposals.json

# Step 2: Review proposals.json
# Edit to create decisions.json

# Step 3: Apply approved movements
python 1n3ox-apply.py decisions.json

# Step 4: Verify
cd "R:\!LAUNCH.PAD\!CITADEL.WORKDESK\(CAT.0) ADMIN\.3ox"
ruby cat-router.rb dashboard
```

### Workflow 2: Check System Health

```bash
cd "R:\!LAUNCH.PAD\!CITADEL.WORKDESK\(CAT.0) ADMIN\.3ox"
ruby cat-router.rb dashboard
ruby cat-trace.rb report
```

---

## 📝 JSON Contracts

### proposals.json (from 1n3ox-scan.py)
```json
{
  "generated_at": "2025-10-20T18:30:00Z",
  "inbox": "/path/to/inbox",
  "items": [
    {
      "file": "document.pdf",
      "path": "/full/path/to/document.pdf",
      "size_bytes": 12345,
      "hash": "a3f8d9e2c1b5"
    }
  ]
}
```

### decisions.json (input to 1n3ox-apply.py)
```json
{
  "inbox": "/path/to/inbox",
  "decisions": [
    {
      "file": "document.pdf",
      "approve": true,
      "dest_cat": "(CAT.3) Business"
    }
  ]
}
```

---

## 🔗 Related Documentation

- **Calibration:** `!CITADEL.OPS/Promptbook/CURSOR.AGENT.CALIBRATION.md`
- **Tools Config:** `.3ox/tools.yml` (in any .3ox folder)
- **Brain Config:** `.3ox/brain.rs` (agent personality)
- **Routing:** `.3ox/routes.json` (output destinations)

---

**Toolkit Version:** 1.0.0  
**Dependencies:** Python 3.11+, Ruby 3.0+, xxhash gem



