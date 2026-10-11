# HARNESS Standard

Status: Active
Date: 2026-10-10
Home: `!WORKDESK/Architecture/HARNESS/`

## Scope

HARNESS specifies the Entity harness classes defined by STRATA/EOR.

Exactly two Entity harness classes are currently confirmed:

| Harness class | Definition | Face specification |
|---|---|---|
| Agent | Standard top-level Entity harness | `AGENT/AGENT.FACES.STANDARD.md` |
| Sidekik | Higher-access top-level Entity harness; mission: continuity | `SIDEKIK/SIDEKIK.FACES.STANDARD.md` |

The six face names are specific to the harness class; they need not be the same between Agent and Sidekik.

## Distinctions

- EOR, under `Architecture/STRATA/EOR/`, establishes Entity, Operation, and Resource classes and their call relationships.
- GIS, under `Architecture/STRATA/GIS/`, groups implementation surfaces as Runtime, System, and Services.
- HARNESS, here, defines the structural faces of Entity harnesses.
- A Station and a Service are EOR Operations, not additional Entity harness classes. The Station's own face specification remains separately maintained.

This index does not instantiate any Agent or Sidekik, alter existing deployments, or assert that unconfirmed harness classes exist.

## Canonical sources

- `!WORKDESK/Architecture/STRATA/EOR/EOR.STANDARD.md`
- `!WORKDESK/Architecture/STRATA/GIS/GIS.STANDARD.md`
- `TelePromptR/v4/spec/station.spec`
