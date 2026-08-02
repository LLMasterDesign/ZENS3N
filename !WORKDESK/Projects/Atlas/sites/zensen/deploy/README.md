# ZENSEN production VPS pack

This pack is the execution companion to [LAUNCH-BASELINE.md](../LAUNCH-BASELINE.md). The current phase is local/Tailscale preproduction; no VPS or paid provider is required. The later VPS steps are approval-gated and do not assume a host, domain, provider, or credentials.

## Atlas launch-board updates

Update the committed Atlas board only with a receipt. Completion requires an existing, non-empty evidence file; a pending task may carry `partial_evidence` for work already proven. The 10k and public-cutover tasks additionally require an explicit approval reference before completion.

```sh
node deploy/update-launch-board.mjs \
  --task scale-1 \
  --state complete \
  --evidence LOAD-REHEARSAL.md \
  --note "Bounded local and Tailscale rehearsal receipts passed."
```

Use `--dry-run` to inspect the JSON before writing. Use `--state pending` to reopen a task when its evidence is no longer valid.

The armed 10k scenario must be launched through `load/run-10k-approved.sh`. Its preflight checks the target, arming flag, approval flag, approval reference, and k6 availability before invoking the 50-minute ramp/soak script.

## Phase A — local/Tailscale preproduction

The canonical source is served from the local host on `127.0.0.1:7120` and exposed for rehearsal at `https://corbato-en0.billfish-sirius.ts.net/zensen/`. Verify the entry hash, `/healthz`, critical assets, spec routes, mobile behavior, and no-secret boundary before creating a GitHub release.

```bash
export ZENSEN_URL='https://corbato-en0.billfish-sirius.ts.net/zensen/index.html'
export ZENSEN_HEALTH_URL='https://corbato-en0.billfish-sirius.ts.net/zensen/healthz'
export ZENSEN_EXPECTED_HASH='<canonical-index-sha256>'
bash deploy/verify-release.sh
```

The verifier checks the entry hash, `/healthz`, and a real unknown-route `404`. On the approved Nginx target, add `export ZENSEN_REQUIRE_SECURITY_HEADERS=yes` to require the configured browser-security headers. This proves the current source and ingress path; it does not prove production capacity.

## Phase B — GitHub release

Use [GITHUB-RELEASE.md](../GITHUB-RELEASE.md) to prepare and inspect the repository. Do not create a remote, push, or publish a paid deployment until the owner explicitly approves that move.

## Phase C — approved production deployment

## Target shape

- Nginx terminates HTTPS and serves `/srv/zensen/current`.
- Each release is immutable under `/srv/zensen/releases/<release-id>`.
- `current` is an atomic symlink switch; old releases remain available for rollback.
- The public page is static HTML/CSS/assets, with no secrets or application runtime on the public surface.
- `/healthz` returns `200 ok` and is used by monitoring and load checks.
- Unknown paths resolve through the themed `404.html` response; the Nginx recipe emits `nosniff`, frame, referrer, and permissions-policy headers.

## VPS foundation gate

Before publishing, record evidence for each item:

- [ ] Fresh supported OS image and automatic security updates.
- [ ] Non-root deploy user with SSH key-only access.
- [ ] Root login and password authentication disabled after access is tested.
- [ ] Firewall allows only SSH from the operator network, HTTP, and HTTPS.
- [ ] Nginx installed and configuration testable with `nginx -t`.
- [ ] `/srv/zensen` owned by the deploy user; no writable web root for Nginx.
- [ ] Off-host backup or provider snapshot and a timed restore procedure.
- [ ] DNS and TLS certificate target recorded.
- [ ] Monitoring, access logs, error logs, and alert destination recorded.

## Publish

Set the target explicitly, then run the publisher from this workspace:

```bash
export ZENSEN_TARGET='deploy-user@production-host'
export ZENSEN_REMOTE_ROOT='/srv/zensen'
bash deploy/publish.sh
```

The publisher refuses a missing target and only writes beneath `/srv/zensen`. It packages the canonical `Websites/zensensystems` entry and its local runtime assets, uploads an immutable release, switches `current` atomically, and prints the release hash.

Install `deploy/nginx/zensen.conf` as the site configuration, replace `server_name _;` when the public domain is confirmed, run `nginx -t`, and reload Nginx. TLS may be provider-managed or installed with the chosen certificate automation; record the actual method in the baseline.

## Verify

After DNS/TLS is live, verify status, health, and entry hash:

```bash
export ZENSEN_URL='https://your-domain.example/index.html'
export ZENSEN_EXPECTED_HASH='<canonical-index-sha256>'
bash deploy/verify-release.sh
```

The verifier fails on a non-2xx response, missing health endpoint, or hash mismatch. A successful check is a release receipt, not a capacity receipt.

## Rollback

On the VPS, select the previous immutable release and atomically repoint `current` after checking its manifest/hash. Then rerun `verify-release.sh` and record the elapsed time. Never edit files inside the live release directory.

## Capacity gate

The 10k test is intentionally armed. Run it only against an owned staging or production target during an agreed window:

```bash
export TARGET='https://your-domain.example/index.html'
export ARMED=yes
export APPROVED_TARGET=yes
export APPROVAL_REF='record-the-approved-test-window-here'
k6 run deploy/load/10k.js
```

The run requires both explicit gates (`ARMED=yes` and `APPROVED_TARGET=yes`) plus an `APPROVAL_REF` receipt. Do not claim 10,000-user readiness until ramp, soak, spike, error-rate, latency, recovery, and rollback evidence are attached to the baseline.
