# Scratch Plan

plan_id: PLAN.2026-02-14.001
tid: TID.PLAN.20260214.001
status: active
mode: one_step_at_a_time
owner: ZENS3N
last_updated_utc: 2026-02-14T00:00:00Z

## Mission

Migrate 1n3ox runtime and batch workflow to canonical layout and safe governed processing, without missing steps.

Canonical root:
`/root/!ZENS3N.CMD/!LAUNCHPAD/.3ox/.vec3/`

## Focus Rules

1. Only one step may be `in_progress` at any time.
2. Do not start next step until current step has evidence.
3. Every step change must update:
- this file
- `!ZENS3N.OPS/LIFECYCLE.PLAN.TRACKER.md`
- `!ZENS3N.OPS/LIFECYCLE.PLAN.CHANGELOG.jsonl`
4. No destructive operations.

## Step Board

| Step | Title | Status | Exit Evidence |
|---|---|---|---|
| S01 | Lock path authority and freeze drift | in_progress | confirmed canonical root references |
| S02 | Relocate unit to `_TRON/systemd/1n3ox/1n3ox.service` | pending | unit file exists and validates |
| S03 | Add launcher at `_TRON/systemd/1n3ox/cmd/1n3ox.watch` | pending | executable launches watcher |
| S04 | Normalize watcher paths to `/root/!ZENS3N.CMD/!LAUNCHPAD/.3ox/.vec3` | pending | no `/root/!LAUNCHPAD` refs remain |
| S05 | Add contract at `_TRON/systemd/1n3ox/proto/1n3ox.watch.proto` | pending | proto file committed and referenced |
| S06 | Add release layout `_TRON/systemd/1n3ox/release/{current,archive}` | pending | directories and README present |
| S07 | Register service in `services.index.toml` | pending | index entry for `1n3ox.watch` exists |
| S08 | Reimagine batch envelope v2 (phase-aware) | pending | spec approved and written |
| S09 | Implement batch runner integration with LifecycleWorkflow | pending | runner can process one TID end-to-end |
| S10 | Add 2-hour timer and one-shot service for batches | pending | timer fires and service runs once |
| S11 | Single-folder success test | pending | one old file processed then archived |
| S12 | Multi-plan tracker validation across plans | pending | tracker records at least 2 plans cleanly |

## Batch Envelope v2 Draft

Current contract dirs stay required:
- `inbox/`
- `work/`
- `outbox/`
- `receipts/`

Reimagined behavior:
- `inbox/`: raw intake references only
- `work/`: validation and relation checks
- `outbox/`: promotion candidates only
- `receipts/`: per-step proof receipts

Per-batch metadata additions in `.batch.toml`:
- `phase = open|validate|promote|archive`
- `window_start_utc`
- `window_end_utc`
- `source_roots[]`
- `active_plan_id`

Per-batch ledgers:
- `inbox/index.jsonl`
- `work/validated.jsonl`
- `work/rejected.jsonl`
- `outbox/promotions.jsonl`

## Step Journal

### 2026-02-14

- Created scratch plan and seeded full step list.
- Set S01 as the only active step.
