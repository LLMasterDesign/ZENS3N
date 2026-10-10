# EOR Standard

Status: Active
Date: 2026-10-10
Home: `!WORKDESK/Architecture/STRATA/EOR/`

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

## Working relation

An EOR expression can read as:

`Entity [class] uses Station to run Service on Base using Model.`

Confirmed example:

`Raven [Sidekik] uses TelePromptR [Station] to run Weekly Ops [Service] on Minsky [Base] using Ornith [Model].`

A higher model may be provisioned through a RunPod bootstrap and occupy the Model resource position without changing Raven's Entity class or the Station/Service relationship.

## Entity delegation

Entity authority is top-down:

`Sidekik > Agent`

A Sidekik may call an Agent to use that Agent's available Operations.

Confirmed relation:

`Raven [Sidekik] calls Ender [Agent] to run an available Service on Corbato [Base] using Ender's available Model.`

Delegation does not transfer ownership. Ender retains ownership of its own Stations and Services when Raven invokes Ender.

An Agent may ping a Sidekik, but an Agent cannot run a Sidekik.

A ping does not grant the Agent control over the Sidekik and does not reverse the top-down Entity relationship.

### Agent to Agent

Agent-to-Agent authority is:

`rw-`

An Agent may read from and write to another Agent's permitted surface, but may not execute that Agent or its Operations.

Execution remains with the owning Agent unless a higher-authority Sidekik invokes it.

## State lifecycle

- `vec3/var` is temporary live state.
- `vec3/var/wrkdsk` is transient task work; it progresses work through states and is not the durable home.
- Confirmed STRATA/EOR information is promoted here so it persists across sessions.
- Citadel consumes promoted state toward its L0-L5 requirements.

## Change rule

Only confirmed EOR/STRATA semantics are promoted into this durable surface.
Unconfirmed refinements stay out of the standard until confirmed.
