# OPS.STATION Tools

Operational tools for framework-powered station management.

## Available Tools

### `status_check.py`
**Purpose**: Framework-powered station monitoring  
**Usage**: `python tools/status_check.py`  
**Output**: `0ut.3ox/STATUS_REPORT_FRAMEWORK.json`  
**Duration**: ~2-3 seconds  

Scans all outputs, analyzes integrity, generates comprehensive status report.

---

### `validate_outputs.py`
**Purpose**: Comprehensive output validation (5-phase)  
**Usage**: `python tools/validate_outputs.py`  
**Output**: `0ut.3ox/VALIDATION_REPORT.json`  
**Duration**: ~4-5 seconds  

**Phases**:
1. File Integrity Validation (SHA256)
2. Manifest Cross-Reference
3. Duplicate Detection
4. Timestamp Validation
5. Receipt Validation

---

### `consolidate_reports.py`
**Purpose**: Multi-source data consolidation  
**Usage**: `python tools/consolidate_reports.py`  
**Output**: `0ut.3ox/EXECUTIVE_SUMMARY.json`  
**Duration**: ~2-3 seconds  

Aggregates data from manifest, reports, traces, and receipts into executive summary.

---

### `fix_orphaned.py`
**Purpose**: Auto-fix orphaned files in manifest  
**Usage**: `python tools/fix_orphaned.py`  
**Requires**: `VALIDATION_REPORT.json` must exist  

Reads validation report and adds orphaned files to FILE.MANIFEST.txt.

---

## Framework Integration

All tools use the `.3ox` runtime:
- Session management
- Token counting (tiktoken)
- Trace logging
- Receipt generation
- Manifest updates

## Output Locations

- JSON reports → `0ut.3ox/`
- Markdown reports → `0ut.3ox/`
- Logs → `.3ox/trace.log`, `.3ox/receipts.log`
- Manifest → `0ut.3ox/FILE.MANIFEST.txt`

