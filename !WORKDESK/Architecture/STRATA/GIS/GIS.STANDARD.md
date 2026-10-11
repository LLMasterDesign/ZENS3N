# GIS Standard

Status: Active
Date: 2026-10-10
Home: `!WORKDESK/Architecture/STRATA/GIS/`

## Name

GIS = Generative Implementation System.

GIS is a STRATA classification family alongside EOR, not a harness and not a replacement for EOR.

- EOR identifies the class of a thing: Entity, Operation, or Resource.
- GIS groups implementation surfaces: Runtime, System, Services.

The two families serve different questions. An EOR class does not automatically grant implementation ownership, execution authority, or a filesystem location.

## GIS grouping

| Group | Implementation concern | Currently evidenced in Marduk |
|---|---|---|
| Runtime | Agents and Models available as runtime implementations | `!LAUNCH/AE/GIS/Runtime/Agents/` and `Runtime/Models` |
| System | Station implementations and their system interfaces | `!LAUNCH/AE/GIS/Systems/Stations/` |
| Services | Service implementations or capabilities | `!LAUNCH/AE/GIS/Services/` |

The GIS group name `System` follows the named grouping. Marduk currently spells its physical directory `Systems/`; this standard does not rename it or decide the eventual canonical directory spelling.

Examples, not exhaustive coverage:
- Ender: EOR `Entity/Agent`; GIS `Runtime/Agents`
- Ornith: EOR `Resource/Model`; GIS `Runtime/Models`
- TelePromptR: EOR `Operation/Station`; GIS `System/Stations`
- Weekly Ops: EOR `Operation/Service`; GIS `Services`

A `Base` remains EOR `Resource/Base`. Its eventual GIS representation is not specified here.

## Scope boundary

This standard records the confirmed GIS name and three groupings. It does not prescribe generation algorithms, deploy layout, command interfaces, nested file contracts, or ownership transfers.

Executable calls are still constrained by EOR relations and authorized by en0.
The Agency / Sidekik harness specifications belong under `!WORKDESK/Architecture/HARNESS/`, not inside GIS.

## Source relation

Existing implementation grouping:
`LLMasterDesign/MARDUK/!LAUNCH/AE/GIS/`

Structural EOR counterpart:
`!WORKDESK/Architecture/STRATA/EOR/EOR.STANDARD.md`
