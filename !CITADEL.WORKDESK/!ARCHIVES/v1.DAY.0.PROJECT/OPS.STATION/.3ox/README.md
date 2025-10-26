# .3ox Framework Runtime

**Core runtime files only - No operational tools here!**

## What Belongs Here

✅ **Core Runtime**:
- `run.py` - Python framework runtime
- `run.rb` - Ruby framework runtime  
- `brain.rs` - Agent configuration
- `tools.rs` - Tool definitions
- `config.toml` - Framework configuration
- `Cargo.toml` / `Gemfile` - Dependencies

✅ **Runtime Utilities**:
- `token_reporter.rb` - Token tracking
- `test_tiktoken.rb` - Runtime tests

✅ **Runtime Data** (generated):
- `trace.log` - Operation traces
- `receipts.log` - Cryptographic receipts
- `session.json` - Session state

❌ **What Does NOT Belong Here**:
- Operational tools/scripts → Put in `tools/`
- Reports/outputs → Put in `0ut.3ox/`
- Batch files → Put in `0ut.3ox/[STATION].BATCH/`
- Documentation → Put in `prompt.book/` or root

## Directory Structure

```
.3ox/                    ← Framework runtime ONLY
tools/                   ← Operational tools (status_check, validate, etc.)
0ut.3ox/                 ← All outputs and reports
prompt.book/             ← Prompts and documentation
```

## Usage

Tools import the runtime:
```python
sys.path.insert(0, str(Path(__file__).parent.parent / '.3ox'))
from run import Session, Trace, Receipt, Manifest
```

**Keep this folder clean - runtime essentials only!**

