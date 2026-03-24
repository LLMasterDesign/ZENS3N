# TPR CyberDesk Index

This is the "book of rules + specs" for TelePromptR.

## Core Plans / Specs

- `CyberDeck/TPR.CYBERLOBBY.PLN.md`
- `CyberDeck/TPR.MULTI_AGENT.ROUTING.SPEC.md`
- `CyberDeck/TPR.CAPACITY.SPEC.md`
- `CyberDeck/TPR.LANGUAGES.SHEET.md`
- `CyberDeck/TPR.RESEARCH.PACK.md`

## Formal Schemas

All canonical schemas live in `specs/`:

- `specs/README.md`
- `specs/TPR.INBOX.ENVELOPE.v1.schema.json`
- `specs/TPR.OUTBOX.TPRMSG.v1.schema.json`
- `specs/TPR.BUS.OUTBOX.v1.schema.json`
- `specs/TPR.MSG.v1.proto`

## Tools (Bench / Load)

- `tools/loadtest_inbox.rb`
- `tools/bench_mesh.rb`
- `tools/bench_fanout.rb`
- `tools/bench_bus_pipeline.rb`

