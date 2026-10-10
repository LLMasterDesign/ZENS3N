# EOR Standard

Status: Active
Date: 2026-10-10
Home: `!WORKDESK/Architecture/EOR/`

## EOR

EOR = Entity · Operation · Resource

EOR contains 3 types and 6 classes, exactly 2 classes per type.

| Type | Classes |
|---|---|
| Entity | Agent · Sidekik |
| Operation | Station · Service |
| Resource | Base · Model |

## Confirmed semantics

- Agent: standard top-level harness.
- Sidekik: higher-access top-level harness whose defined mission is continuity.
- Raven: first Sidekik harness.
- Agent and Sidekik can own Stations and Services.
- Base: location of work.
- Model: any LLM assigned to a mesh port.

## State lifecycle

- `vec3/var` is temporary live state.
- `vec3/var/wrkdsk` is transient task work; it progresses work through states and is not the durable home.
- Confirmed STRATA/EOR information is promoted here so it persists across sessions.
- Citadel consumes promoted state toward its L0-L5 requirements.

## Change rule

Only confirmed EOR/STRATA semantics are promoted into this durable surface.
Unconfirmed refinements stay out of the standard until confirmed.

