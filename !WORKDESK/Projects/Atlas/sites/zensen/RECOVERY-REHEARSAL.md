# ZENSEN recovery rehearsal

Captured: **2026-08-02**  
Environment: **isolated local temporary root**  
Result: **partial Battle Chapter 05 evidence**

## Receipt

```text
recovery rehearsal passed: archive restore, exact hash, and healthz=ok; restore_ms=12
coverage boundary: alert delivery, production backup, VPS restore, and incident paging remain unverified
```

The rehearsal created an immutable release archive from the canonical source, restored it into a clean temporary directory, compared the restored entry SHA-256 to the canonical hash, and verified `healthz=ok`. Temporary files were removed on exit.

## Reproduce

```bash
bash deploy/rehearse-recovery.sh
```

This receipt does not complete `battle-2`. Production backup/restore, alert delivery, incident paging, and a timed real-target recovery drill still require an approved target and operational tooling.
