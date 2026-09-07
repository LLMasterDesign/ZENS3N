///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
▛//▞▞ ⟦⎊⟧ :: ⧗-26.392 // RULES :: 3OX station shape ▞▞

# 3OX STATION — the reusable shape

A **cube** is a being: six numbered faces, 1-Spark → 6-Pulse.
A **station** is a door: it does one job, for one protocol, and
is replaceable without touching the being behind it. TPR is a
station. ORION is a station. A station is not a small cube.

Six named faces, but only four are MUST. Reuse this shape dozens
of times; the names never change, the contents always do.

| face | name | MUST | holds |
|------|------|------|-------|
| 0 | **Gen**   | may  | `init.gen` — the start button. Absent = defaults. |
| 1 | **Lock**  | MUST | `lock.kdl` — the ONE truth: port, runtime, identity, key name, tiers, limits, law. If a claim is not here, it is not a claim. |
| 2 | **Brain** | MUST | what actually runs. One entrypoint. Compiled where it can be (`brains-build` pattern), interpreted where it must be. |
| 3 | **Rules** | —    | SHARED. Not owned by the station. This file plus its `.proto`. |
| 4 | **Keys**  | may  | `vec3/lib/keys/<NAME>` — walled. Only if the station opens secrets. Never a doc, never git, never a unit file. |
| 5 | **Links** | MUST | its decade (below) and the edge routes that reach it. |
| 6 | **Pulse** | MUST | `proc/<port>` slot · log · `.gensL` receipts. What it emitted is how you know it ran. |

## Port law · two bands, one decade number

A station is two things wearing one name:

```
  50x0   BRAINS   the engine. Machine only. No human types it.
  70x0   FACE     the door. What Lucius types. Where a webhook lands.
```

Same decade digits both sides, so the pair is obvious at a glance:
TPR brains `:5090`, TPR face `:7090`. The face calls the brains.
The brains never answers a human directly.

## Then, inside each decade · 5 used · 5 reserved

A station takes a decade starting on a zero. The ones-digit is
the CISA rail, so the decade IS the station's anatomy:

```
  x0  Observe   the door · health · readiness · inbound     ┐
  x1  Relate    the gen · the relay itself                  │ 5
  x2  Infer     model reach                                 │ USED
  x3  Weigh     routing · resolution · which being answers   │
  x4  Remember  spool · history · state                     ┘
  x5  Act       tools · hands                                ┐
  x6  Pulse     tape · receipts                              │ 5
  x7  Telemetry TUI · views                                  │ RESERVED
  x8  VIA       face · web · mini app                        │
  x9  Sandbox   proving · throwaway                         ┘
```

Reserved is not free: it belongs to the same occupant. A second
station may not squat x5–x9 of a decade it does not own.

Assigned (WORK plane, <8080):
```
  7070-7079   [CMD]
  7080-7089   STORE.CC
  7090-7099   TPR
  7100-7109   train.view
```
Grandfathered trespass, to be corrected when each next moves:
`:7088` breakdown and `:7089` TPR both sit inside STORE's decade.
`:7078` and `:7099` are undeclared `python3 -m http.server`.

## Lifecycle · the only five verbs a station owes

Every station answers these, whatever the transport. BEAM today,
gRPC tomorrow, HTTP in between — the contract does not move.

```
  SHAPE      what I am        → the lock, verbatim
  HEALTH     am I up          → cheap, no probe, never blocks
  READINESS  can I work       → probe-backed, TTL'd, says WHY not
  PULSE      what I emitted   → stream of .gensL receipts
  DELIVER    do one unit      → one envelope in, one ack out
```

Law:
- HEALTH must not call anything that can hang. READINESS may.
- READINESS returning "unknown" is an answer. Silence is not.
- DELIVER is idempotent by envelope id, or it is broken.
- Every DELIVER emits exactly one receipt: ∀λᴳ ∃!τ.
- A station that cannot say SHAPE cannot be trusted about the
  rest — three registries claiming three homes is the disease
  this face cures.

Transport binding lives in `station.proto` (package
`box.station.v1`). ORION's BEAM→gRPC move implements that file;
it does not invent a second contract.

:: ∎
