# OPS.STATION Directory Structure

## Folder Organization

```
R:\!CMD.BRIDGE\OPS.STATION\
│
├── .3ox/                          ← FRAMEWORK RUNTIME ONLY
│   ├── run.py                     ← Python runtime (core)
│   ├── run.rb                     ← Ruby runtime (core)
│   ├── brain.rs                   ← Agent configuration
│   ├── tools.rs                   ← Tool definitions
│   ├── config.toml                ← Framework config
│   ├── Cargo.toml / Gemfile       ← Dependencies
│   ├── token_reporter.rb          ← Runtime utility
│   ├── test_tiktoken.rb           ← Runtime tests
│   ├── trace.log                  ← Operation traces (generated)
│   ├── receipts.log               ← Cryptographic receipts (generated)
│   ├── session.json               ← Session state (generated)
│   └── README.md                  ← Runtime documentation
│
├── tools/                         ← OPERATIONAL TOOLS
│   ├── status_check.py            ← Station monitoring
│   ├── validate_outputs.py        ← Output validation
│   ├── consolidate_reports.py     ← Report consolidation
│   ├── fix_orphaned.py            ← Manifest utilities
│   └── README.md                  ← Tool documentation
│
├── 0ut.3ox/                       ← ALL OUTPUTS & REPORTS
│   ├── *.md                       ← Markdown reports
│   ├── *.json                     ← JSON data files
│   ├── FILE.MANIFEST.txt          ← Output tracking manifest
│   ├── OBS.BATCH/                 ← OBSIDIAN outputs (archived)
│   ├── SYNTH.BATCH/               ← SYNTH outputs (archived)
│   └── OPS.BATCH/                 ← OPS outputs (active)
│
├── prompt.book/                   ← PROMPTS & DOCUMENTATION
│   ├── !ATTN                      ← Framework primer
│   ├── 01_SIMPLE_FILE_MOVE.txt
│   ├── 02_IMPORT_MEDIUM.txt
│   ├── ...
│   └── mgmt/                      ← Management prompts
│       ├── 00_PRE_FLIGHT_CHECK.txt
│       ├── 01_STATUS_CHECK.txt
│       ├── 02_VALIDATE_OUTPUTS.txt
│       └── 03_CONSOLIDATE_REPORTS.txt
│
├── test_files/                    ← TEST DATA
│   └── ...
│
├── log.book/                      ← LOG STORAGE
│   └── ...
│
├── !ATTN                          ← Root framework primer
├── TEST_GUIDE.txt                 ← Testing guide
└── DIRECTORY_STRUCTURE.md         ← This file
```

## Folder Purposes

### `.3ox/` - Framework Runtime
**Rule**: Core runtime files ONLY  
**Contains**: Executable code, configuration, runtime data  
**Does NOT contain**: Operational tools, reports, outputs  

### `tools/` - Operational Tools
**Rule**: Reusable operational scripts  
**Contains**: Tools that USE the .3ox runtime  
**Purpose**: Status checks, validation, consolidation, utilities  

### `0ut.3ox/` - Outputs & Reports
**Rule**: ALL generated outputs go here  
**Contains**: Reports, logs, batch results, manifests  
**Purpose**: Central output collection point  

### `prompt.book/` - Documentation
**Rule**: Prompts, guides, documentation  
**Contains**: Test prompts, management tasks, framework primers  
**Purpose**: Instruction and documentation repository  

## Clean Separation

```
RUNTIME     → .3ox/       (what the framework IS)
TOOLS       → tools/      (what USES the framework)
OUTPUTS     → 0ut.3ox/    (what the framework PRODUCES)
DOCS        → prompt.book/ (what INSTRUCTS the framework)
```

## Import Patterns

Tools importing runtime:
```python
# From tools/
sys.path.insert(0, str(Path(__file__).parent.parent / '.3ox'))
from run import Session, Trace, Receipt, Manifest
```

## Maintenance

- Keep `.3ox/` minimal - runtime essentials only
- Tools go in `tools/`, NOT `.3ox/`
- All outputs go to `0ut.3ox/`, NOT root
- Documentation goes to `prompt.book/` or root docs

