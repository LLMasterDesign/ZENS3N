# Agent Six-Face Standard

Status: Active
Date: 2026-10-10
Home: `!WORKDESK/Architecture/HARNESS/AGENT/`

## Agent harness

An Agent is the standard top-level Entity harness in EOR. Agent has six numbered `.3ox` faces.

| Face | Name | Responsibility | Established artifact example |
|---|---|---|---|
| 1 | Spark | Identity, origin, mission, behavioral declaration | `sparkfile.md` |
| 2 | Brains | Cognition configuration and brain behavior | `brains.rs` |
| 3 | Rules | Constraints, limits, write policy | `limits.toml` |
| 4 | Toolkit | Declared tools, adapters, capabilities | `tools.yml` |
| 5 | Links | Connections, routes, destinations | `routes.json` |
| 6 | Pulse | Entrypoint, emission, operational visibility and receipt references | `run.rb` |

Numbered names are the stable Agent face vocabulary. Artifact names above reflect established implementations; this standard does not require an unreviewed file migration.

## Authority and relationships

- Both Agent and Sidekik can own Stations and Services.
- A Sidekik has higher call authority over an Agent: `Sidekik > Agent`.
- Sidekik invoking an Agent does not transfer that Agent's Operation ownership.
- Agent-to-Agent access is limited to permitted reading and tier-scoped writes; an Agent may not execute another Agent or its Operations.
- An Agent may ping a Sidekik; it may not run the Sidekik.
- EOR defines the valid call structure; en0 decides call authorization.

Write tiers in EOR are `[USER]` (default) and `[CMD]` (explicitly assigned). Tier assignment does not itself grant execution permission.

## Relationship to Sidekik faces

| Agent face | Higher Sidekik face |
|---|---|
| Spark | Threads |
| Brains | Runtime |
| Rules | Governance |
| Toolkit | Assembly |
| Links | Registry |
| Pulse | Witness |

These are cross-level semantic relationships, not instructions to move files into those Sidekik folders.

## Boundary

This standard defines the Agent harness's six face names and established responsibilities. It does not define instance-specific models, stations, services, base assignment, runtime deployment, port numbers, or nested directory layouts.

`_meta` remains a separate proof/metadata surface and `vec3` remains a separate substrate, not seventh or eighth `.3ox` faces.

Related standards:
- `!WORKDESK/Architecture/HARNESS/SIDEKIK/SIDEKIK.FACES.STANDARD.md`
- `!WORKDESK/Architecture/STRATA/EOR/EOR.STANDARD.md`
