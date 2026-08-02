# ZENSEN local deployment rehearsal

Captured: **2026-08-02**

This is partial Battle Chapter 05 evidence using a temporary local root. It exercises the same immutable release archive, `current` symlink switch, rollback, and server restart mechanics used by the later VPS publisher. It does not test a real VPS, Nginx, DNS/TLS, dependency failure, soak, spike, alerting, or 10k capacity.

## Reproduce

```bash
bash deploy/rehearse-local.sh
```

The rehearsal is isolated under a `mktemp` directory, serves only on loopback port `7131` by default, and cleans up its temporary releases and server on exit. It verifies the canonical entry hash and `/healthz` after the initial release, candidate switch, rollback, and process restart.

## Acceptance

- [x] Immutable archive contains the canonical entry and runtime assets.
- [x] Initial release serves HTTP 200, the expected SHA-256, and `healthz=ok`.
- [x] Candidate release switches atomically through `current`.
- [x] Rollback restores the expected entry hash and health response.
- [x] Restart after rollback restores the expected entry hash and health response.
- [ ] VPS/Nginx/DNS/TLS deployment verified.
- [ ] Soak, spike, dependency-failure, alert, and restore drills verified.
