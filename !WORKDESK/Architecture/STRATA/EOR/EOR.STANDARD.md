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

## Operation

- Station: the operational place or interface an Entity works through.
- Service: a specific capability or job that gets run through a Station or directly by its owning Entity.
- A Station may expose multiple Services.
- A Service keeps the ownership of whoever starts or owns its lifecycle.
- A Station may be shared by multiple Entities.
- When multiple Entities share a Base, sharing a Station is typical but not the default or a requirement.
- Service-to-Service execution is not a direct edge.
- A Service may call an Agent's Station to run a Service owned on that Agent's side.
- Operation calls remain top-down through the Station rather than Service directly invoking Service.

Confirmed example:

`TelePromptR [Station]` is the operational surface Raven can work through.

`Weekly Ops [Service]` is the recurring capability or job being run.

## Resource

- Base: where the work is situated or run.
- Model: the intelligence resource assigned to perform inference for that work.
- A Base may remain constant while the assigned Model changes.
- A Base may host multiple Entities.
- A Model may be shared by multiple Entities.
- Resource assignment is not inherently exclusive.

Confirmed example:

`Minsky [Base]` may host multiple Entities while `Ornith [Model]` may also serve multiple Entities.

`Minsky [Base]` may remain constant while `Ornith [Model]` is replaced temporarily by a larger RunPod-backed Model.

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

An Agent may read another Agent's permitted surface but may not execute that Agent or its Operations.

Write permission is tier-scoped rather than universal.

There are exactly two write tiers:

- `[USER]`
- `[CMD]`

`[USER]` is the default write tier.

If an Entity is explicitly assigned `[CMD]`, it may write to permitted surfaces within the `[CMD]` tier.

A write-tier grant does not imply execute permission.

Execution remains with the owning Agent unless a higher-authority Sidekik invokes it.

## State lifecycle

- `vec3/var` is temporary live state.
- `vec3/var/wrkdsk` is transient task work; it progresses work through states and is not the durable home.
- Confirmed STRATA/EOR information is promoted here so it persists across sessions.
- Citadel consumes promoted state toward its L0-L5 requirements.

## Change rule

Only confirmed EOR/STRATA semantics are promoted into this durable surface.
Unconfirmed refinements stay out of the standard until confirmed.
