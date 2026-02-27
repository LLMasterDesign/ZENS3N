# TelePromptR Specs

This folder is the canonical, language-agnostic contract for TelePromptR message routing.

If you want to implement a router/agent in Go/Elixir/Rust/Perl, target these schemas.

## Specs

- `specs/TPR.INBOX.ENVELOPE.v1.schema.json`
  - Teleprompter -> SpeakerMesh inbox envelope (file in `var/inbox/`).
- `specs/TPR.OUTBOX.TPRMSG.v1.schema.json`
  - SpeakerMesh -> Teleprompter outbox envelope ("TPR.MSG" JSON in `var/outbox/`).
- `specs/TPR.BUS.OUTBOX.v1.schema.json`
  - Bus outbox envelope for `tools/telepromptr_bridge.rb` (agent -> bridge -> Telegram).
- `specs/TPR.MSG.v1.proto`
  - Optional proto3 mirror of the above (useful for cross-language bindings).

## Versioning Rules

- Specs are append-only within a major version.
- Breaking changes require a new `vN` file.
- Producers SHOULD validate against the schema before writing.
- Consumers MUST validate and hard-drop invalid envelopes (log + quarantine).

