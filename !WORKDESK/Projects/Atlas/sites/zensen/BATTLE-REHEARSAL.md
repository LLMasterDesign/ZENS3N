# ZENSEN local battle rehearsal

Captured: **2026-08-03**  
Status: **Partial Battle Chapter 05 evidence**

`deploy/rehearse-battle.sh` exercises the failure paths that can be proven safely before a real VPS exists:

- bounded local soak: up to 1,000 requests / 50 workers;
- bounded local spike: 250 requests / 50 workers;
- candidate release missing `healthz` is rejected;
- atomic rollback returns the baseline hash and health response;
- a stopped local process is observed as unavailable;
- restart restores the baseline hash and health response.

The rehearsal is isolated under a temporary loopback-only root. It does not claim VPS, Nginx, DNS/TLS, production backup, alert delivery, incident paging, or 10,000-user capacity.

## Reproduce

```bash
bash deploy/rehearse-battle.sh
```

## Receipt

The timestamped command output belongs with this document when the rehearsal is run. Atlas may attach this file as partial evidence for `battle-1`; it must not promote `battle-1` to complete until a real deployment, operational alert path, and approved target evidence exist.
