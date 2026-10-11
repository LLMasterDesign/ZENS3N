# Sidekik Six-Face Standard

Status: Active
Date: 2026-10-10
Home: `!WORKDESK/Architecture/STRATA/SIDEKIK/`

## Sidekik cube

A Sidekik is a full six-face cube.

The six Sidekik faces are locked as:

1. Threads
2. Runtime
3. Governance
4. Assembly
5. Registry
6. Witness

These names are higher abstractions than the corresponding Agent and Station faces. They are not aliases for the lower faces.

## Face semantics

### 1. Threads

Purpose: keep identity, intent, ongoing work, and handoff continuity connected across time.

Lower-face lift:
- Agent `Spark` -> Sidekik `Threads`
- Station `Lock` -> Sidekik `Threads`

Threads is about preserving the active thread, not provenance or persistence authority.

### 2. Runtime

Purpose: the executable intelligence environment available to the Sidekik.

Lower-face lift:
- Agent `Brains` -> Sidekik `Runtime`
- Station `Brain` -> Sidekik `Runtime`

Runtime is the higher abstraction over a single Brain/Brains implementation.

### 3. Governance

Purpose: the governing surface for what the Sidekik and its nested components may do.

Lower-face lift:
- Agent `Rules` -> Sidekik `Governance`
- Station `Rules` -> Sidekik `Governance`

Governance may nest Policy, Canon, and Law.

Authorization remains separate: EOR defines call relationships; en0 decides whether a call is authorized.

### 4. Assembly

Purpose: the composition surface where capability is put together into an implementable working whole.

Lower-face lift:
- Agent `Toolkit` -> Sidekik `Assembly`
- Station `Keys` -> Sidekik `Assembly`

GIS implementations may participate in Assembly, but GIS remains its own STRATA family rather than being renamed to Assembly.

### 5. Registry

Purpose: the Sidekik-level inventory and addressable relationship surface for what exists and where it can be reached.

Lower-face lift:
- Agent `Links` -> Sidekik `Registry`
- Station `Links` -> Sidekik `Registry`

Registry may reference nested Agents, Stations, Services, Bases, Models, and their routes without changing their EOR classes.

### 6. Witness

Purpose: the Sidekik-level account of what its governed world actually did.

Lower-face lift:
- Agent `Pulse` -> Sidekik `Witness`
- Station `Pulse` -> Sidekik `Witness`

Witness is a parent abstraction over Pulse. It does not replace receipt/proof authority, and it does not take lifecycle ownership from Supervisor.

## Nesting rule

- A Service may implement any number of faces from 1 through 6 as required.
- A Station has the full six-face Station shape.
- Structural levels above Station use a full six-face shape.
- A Sidekik can therefore nest lower Agent, Station, and Service structures without inventing a new taxonomy for each child.

## Cross-level map

| Sidekik | Agent | Station |
|---|---|---|
| Threads | Spark | Lock |
| Runtime | Brains | Brain |
| Governance | Rules | Rules |
| Assembly | Toolkit | Keys |
| Registry | Links | Links |
| Witness | Pulse | Pulse |

## Boundary

This standard locks the six Sidekik face names and their semantic relation to lower faces.

It does not yet lock the internal file layout of any face.
It does not rename the Agent six-face standard.
It does not rename the Station six-face standard.
It does not define the GIS STRATA standard.
