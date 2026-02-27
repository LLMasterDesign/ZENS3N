# TPR Languages Sheet (Router + Agents)

TelePromptR today is mostly Ruby + JSON + filesystem queues. This sheet is for adding Go/Elixir/Rust/Perl components without breaking routing.

## Canonical Message Contract

Before rewriting anything, target the schemas in `specs/`:

- Inbox: `specs/TPR.INBOX.ENVELOPE.v1.schema.json`
- Outbox: `specs/TPR.OUTBOX.TPRMSG.v1.schema.json`
- Bus outbox: `specs/TPR.BUS.OUTBOX.v1.schema.json`

Rule: producers SHOULD validate before write; consumers MUST validate and quarantine bad envelopes.

## Ruby (current)

- Strengths: fastest iteration, already implemented.
- JSON: stdlib `json`
- HTTP: stdlib `net/http`
- File queue: stdlib `FileUtils` + atomic write/rename pattern
- Optional JSON Schema validation (if you want it): `json_schemer` gem (or `json-schema`).

## Go (recommended add-on)

- Strengths: simple deploy, excellent concurrency, great for bridges/daemons that must not crash.
- JSON: `encoding/json`
- JSON Schema validation:
  - `github.com/santhosh-tekuri/jsonschema/v5` (fast, good DX)
  - `github.com/xeipuuv/gojsonschema` (widely used)
- File watch (optional): `github.com/fsnotify/fsnotify`
- Telegram bots: `github.com/go-telegram-bot-api/telegram-bot-api/v5`
- Discord/Slack/Teams: official REST clients or simple HTTP wrappers.

## Elixir (Erlang/BEAM)

- Strengths: massive concurrency, resilient supervision trees, ideal for multi-agent message routing at scale.
- JSON: `Jason`
- JSON Schema validation: `ex_json_schema`
- File watch (optional): `file_system`
- Telegram bots:
  - `nadia` (simple)
  - `telegex` (more featureful)
- Pattern recommendation: OTP `GenServer` + supervision; isolate per-chat/topic throttles as separate processes.

## Rust

- Strengths: performance + safety; best when you need strict correctness and predictable latency.
- JSON: `serde_json`
- JSON Schema validation: `jsonschema` crate
- File watch: `notify` crate
- Telegram bots: `teloxide`

## Perl

- Strengths: glue for ops, legacy automation; fine for adapters if you keep it small and well-tested.
- JSON: `JSON::MaybeXS` or `Cpanel::JSON::XS`
- JSON Schema validation: `JSON::Validator`
- File watch: `Linux::Inotify2`
- Telegram bots: `Telegram::BotAPI`

## Practical Guidance

- If you want 24+ agents with stable uptime: Go bridge(s) or Elixir router(s) are the lowest-risk upgrades.
- Keep Telegram API boundary in exactly one service (TPR gateway/bridge) to prevent race conditions.
- Use the schemas as the contract; don't rely on "it looks right" JSON.
