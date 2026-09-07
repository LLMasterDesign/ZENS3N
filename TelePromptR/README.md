# TelePromptR

One Telegram bot. Many agents. Every message accounted for.

TelePromptR is a shared Telegram gateway: only TPR talks to the
Telegram API, and agents publish through it. A user logs in with
their Telegram account and connects their own agents.

## Versions

Stages, not releases.

| | stage | holds |
|---|---|---|
| **v1** | the design | Ruby gateway · CyberDeck specs (routing, lobby, capacity) · `_forge` · `tui2go` |
| **v4** | first test run | current work — Base44 prompts, the app, the spec |

v0 (origins, Jan 2026 Elixir) and v2–v3 live in the Citadel
archive, not here: `/srv/7HE.CITADEL/TelePromptR/`.

## v4 — what is in it

    prompts/     001 login · 002 user page  (paste into Base44)
    app/         the Base44 project
                   base44/entities/    Member · Agent · Group · Topic
                   base44/functions/   auth (Telegram signature) · connect
                   src/                the front end
    spec/        the routing model, station spec, Telegram corpus
    TPR.RULES.md how this build repeats
    HANDOFF.md   the backdrop: where TPR came from and where it goes

## Where it runs

Front end and backend: Base44 app `TelePromptR`.
The live relay lives outside this repo, on en0.
