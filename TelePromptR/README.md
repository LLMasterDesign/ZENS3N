# TelePromptR

One Telegram bot. Many agents. Every message accounted for.

Only TelePromptR talks to the Telegram API; agents publish through
it. A person logs in with their Telegram account and connects their
own agents.

## The directory

| | holds |
|---|---|
| `TelePromptR.ID` | the identity — what this station is, where it runs |
| `CyberDeck/` | the specs that govern: multi-agent routing, cyberlobby, capacity, speaker mesh, route map |
| `specs/` | the wire contracts — `TPR.MSG.v1.proto`, inbox envelope, outbox, bus schemas |
| `runtime/` | what runs — the station, `teleprompter.rb`, the VPS ops |
| `tools/` | `subkeyctl` · `speaker_mesh` · benchmarks and load tests |
| `tui2go/` | the terminal face |
| `v1/` … `v4/` | the version chunks, one per stage |

## Versions

Stages, not releases.

| | stage | what it is |
|---|---|---|
| v0 | origins | Jan 2026 · Elixir OTP (in Citadel) |
| v1 | the design | Ruby gateway era · the CyberDeck specs came from here |
| v2 | the parts | stations and stubs (in Citadel) |
| v3 | the prototype | first Python run (in Citadel) |
| v4 | first test run | current — Base44 prompts, the app, the spec |

v5 is a clean run: self-running, less Python, more Rust · Ruby ·
Elixir · gRPC. It gets built from v0–v4, never fabricated.
Citadel archive: `/srv/7HE.CITADEL/TelePromptR/`

## v4 — the current stage

    prompts/   001 login · 002 user page  (for Base44)
    app/       the Base44 project
                 base44/entities/   Member · Agent · Group · Topic
                 base44/functions/  auth (Telegram signature) · connect
                 src/               the front end
    spec/      routing model, station spec, Telegram corpus
