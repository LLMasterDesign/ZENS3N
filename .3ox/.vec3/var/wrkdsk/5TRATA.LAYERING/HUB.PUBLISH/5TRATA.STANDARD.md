# 5TRATA Standard

Version: 1.1
Status: Active
Date: 2026-10-10

## Purpose
5TRATA defines a stable layering order so large file estates can be organized without structural drift.

## Layer Order
1. CMD
2. Base
3. Station
4. Service
5. Agent
6. Runtime

## EOR Lock

EOR = Entity · Operation · Resource

EOR contains 3 types and 6 classes, exactly 2 classes per type.

| Type | Classes |
|---|---|
| Entity | Agent · Sidekik |
| Operation | Station · Service |
| Resource | Base · Model |

### Confirmed class semantics

- Agent: standard top-level harness.
- Sidekik: higher-access top-level harness whose defined mission is continuity; Raven is the first Sidekik harness.
- Station: operation class; may be owned by Agent or Sidekik.
- Service: operation class; may be owned by Agent or Sidekik.
- Base: location of work.
- Model: any LLM assigned to a mesh port.

## Governance Rule
One layer is locked and verified before the next layer is changed.

## Current Program State
- Layers 0-4 are under active lock governance.
- Layer 5 (Runtime) is deferred until earlier layers remain stable.
