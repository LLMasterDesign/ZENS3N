# ZENS3N.BASE WHOAMI

Single proof doc for current system behavior. Auto-generated from `_meta/CHANGELOG.toml` and live `_meta` state.

## Identity
```toml
# Aligned with SESSION.CHECKPOINT truth.paths (CKPT.2026-02-14.001)
generated_at = "2026-02-27T00:00:00Z"
base = "ZENS3N.BASE"
meta_root = ".3ox/_meta"
vec3_runtime_root = ".3ox/.vec3"
tron_root = "_TRON/systemd"
wrkdsk_root = ".3ox/.vec3/var/wrkdsk"
services_index = "_TRON/systemd/proto/services/services.index.toml"
canonical_model = "single_proto_authority"
naming_contract = ".3ox/_meta/NAMING.CONTRACT.toml"
changelog = ".3ox/_meta/CHANGELOG.toml"
whoami = ".3ox/_meta/WHOAMI.md"
```
:: ∎

## Contract Snapshot
```toml
receipts_canonical = ".3ox/_meta/receipts/"
pulse_receipts_contract = ".3ox/(6)Pulse/receipts"
ops_tracking = "!ZENS3N.OPS/receipts/lifecycle.receipts.jsonl"
merkle_root_file = ".3ox/_meta/merkle.root"
receipts_count = 7
merkle_root = "sha256:7274d7388f4e084f56c55ce6efa4a76bd81bf9eb50fa230aa2df951593e7f9f1"
```
:: ∎

## Write Policy
```toml
# Aligned with SESSION.CHECKPOINT truth.write_policy
allowed[] = "!WORKDESK"
allowed[] = "!ZENS3N.OPS/receipts"
allowed[] = ".3ox/_meta/receipts"
allowed[] = ".3ox/_meta/merkle.root"
allowed[] = ".3ox/.vec3/var/wrkdsk"
blocked[] = ".3ox/.vec3/var/wrksdsk"
blocked[] = ".3ox/.vec3/var/state"
```
:: ∎

## Change Feed
```toml
# Note: Canonical staging root is wrkdsk. Legacy wrksdsk refs in older entries are historical (pre-correction).
[[entry]]
section = "identity"
id = "chg_1771004191_837"
ts = "2026-02-13T17:36:31.843Z"
event = "service.bootstrap"
status = "ok"
summary = "_meta cmd service initialized for auto-proof docs"
actor = "meta.cmd"
evidence[] = ".3ox/_meta/cmd/meta_cmd.rb"
evidence[] = ".3ox/_meta/cmd/README.md"
[[entry]]
section = "policy"
id = "chg_1771006202_8306"
ts = "2026-02-13T18:10:02.229Z"
event = "naming.correction"
status = "ok"
summary = "Corrected staging typo: wrksdsk -> wrkdsk (wrksdsk remains compatibility alias)"
actor = "meta.cmd"
evidence[] = ".3ox/(3)Rules/write_policy.toml"
evidence[] = ".3ox/.vec3/var/wrkdsk/WRKDSK.CONTRACT.toml"
[[entry]]
section = "workflow"
id = "chg_1771004203_1463"
ts = "2026-02-13T17:36:43.892Z"
event = "receipt.track"
status = "ok"
summary = "TRACK inventory_count=6 scope=/root/!ZENS3N.CMD/!LAUNCHPAD/!WORKDESK/!FORGE/LifecycleWorkflow"
actor = "lifecycle.workflow"
evidence[] = ".3ox/_meta/receipts/receipt_1771004203_5518.json"
evidence[] = ".3ox/_meta/merkle.root"
[[entry]]
section = "workflow"
id = "chg_1771005200_513"
ts = "2026-02-13T17:53:20.354Z"
event = "staging.tid_open"
status = "ok"
summary = "Opened wrksdsk batch TID.TID.TEST.001"
actor = "meta.cmd"
evidence[] = ".3ox/.vec3/var/wrksdsk/TID.TID.TEST.001"
[[entry]]
section = "workflow"
id = "chg_1771005251_1262"
ts = "2026-02-13T17:54:11.020Z"
event = "staging.tid_open"
status = "ok"
summary = "Opened wrksdsk batch TID.TEST.001"
actor = "meta.cmd"
evidence[] = ".3ox/.vec3/var/wrksdsk/TID.TEST.001"
[[entry]]
section = "workflow"
id = "chg_1771006235_6225"
ts = "2026-02-13T18:10:35.427Z"
event = "staging.tid_open"
status = "ok"
summary = "Opened wrkdsk batch TID.TEST.002"
actor = "meta.cmd"
evidence[] = ".3ox/.vec3/var/wrkdsk/TID.TEST.002"
```
:: ∎
