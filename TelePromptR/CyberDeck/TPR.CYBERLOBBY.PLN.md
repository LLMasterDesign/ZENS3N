# TPR.CYBERLOBBY.PLN

Goal: a stable "one Telegram bot token" gateway where many agents can share one channel/topic, with optional listen-only subscriptions and low-noise lobby summaries.

This plan assumes you run TelePromptR from this repo root: `TelePromptR/`.

## What’s Implemented (In This Workspace Copy)

- Listen-only topic subscriptions (inbound):
  - TelePromptR now routes *all* human text messages in a subscribed topic into each subscribed agent inbox as `meta.listen_only=true`.
  - Result: agents can "subscribe" and *only listen* (mesh ingests memory; no reply) unless explicitly forced.
- Autopilot summaries/fun-facts (optional, off by default):
  - Strict ratio gate: autoposts/human messages is always `< 10%` (no deviations).
  - Triggers only after an idle window + enough human messages since last autopost.
  - Uses `meta.force_reply=true` so a normally silent ingest path can still produce a summary when requested.
- Speaker mesh context hardening:
  - Mesh memory is now scoped per `(chat_id, thread_id)` to prevent cross-topic cross-talk.
- Outbox + health fixes:
  - Legacy outbox now honors `topic_thread_id` as `thread_id`.
  - Health stats now increment `mentions_routed` and `outbox_sent`.

Files:
- Gateway: `TelePromptR/runtime/vps/3ox.station/vec3/bin/teleprompter.rb`
- Shared responder: `TelePromptR/tools/speaker_mesh.rb`
- Mesh personas: `TelePromptR/CyberDeck/TPR.SPEAKER.MESH.json`
- Autopilot env knobs: `TelePromptR/_forge/.env.example`

## Runbook (Minimal)

1. Configure forge env:
   - `cp -n TelePromptR/_forge/.env.example TelePromptR/_forge/.env`
   - Set `TELEGRAM_BOT_TOKEN` in `TelePromptR/_forge/.env` (or provide the runtime token file in your deployed runtime).
2. Start stack:
   - `cd TelePromptR`
   - `./_forge/forge.sh squad-up`
3. In Telegram (in your supergroup topic/thread):
   - Register the thread as a routable topic:
     - `/topic add Lobby` (run this inside the desired topic)
   - List topics and capture the Key / TID:
     - `/topics`
4. Create/identify agents:
   - Mention-routing uses `var/agents.json` (created by `/teleprompter subkey signon ...`).
   - Example:
     - `/teleprompter subkey signon MetaTron ⚡`
     - `/teleprompter subkey signon Atlas ⎈`
5. Subscribe agents (listen-only feed):
   - `/teleprompter subscribe <TID> <AgentName>`
   - After this, every human message in that topic is routed to the agent inbox with `listen_only` set (memory only).
6. Talk to an agent (speak on demand):
   - `@MetaTron …`
   - `@Atlas …`
   - Mentioning two agents in one message routes to both.

## Autopilot (Strict <10% Lobby Posts)

Autopilot is disabled by default. Enable via env:

- `TPR_AUTOPILOT_ENABLED=1`
- `TPR_AUTOPILOT_AGENT=Lobby` (default; persona is included in `TPR.SPEAKER.MESH.json`)
- Optional: scope autopilot to one topic key:
  - `TPR_AUTOPILOT_TOPIC_KEY=<chat_id>:<thread_id>`
- Tunables:
  - `TPR_AUTOPILOT_MIN_HUMAN=12` (default; keeps autoposts around 8.3% max)
  - `TPR_AUTOPILOT_IDLE_S=120`
  - `TPR_AUTOPILOT_COOLDOWN_S=900`

Operational note:
- Autopilot only uses *human text messages* (bot messages ignored).
- It enqueues a single prompt to the `Lobby` persona; the mesh generates the recap/suggestion/fact.

## Next Stability Steps (If/When You Want Them)

1. Add an explicit per-agent allowlist for inbound subscription routing (chat/topic scopes).
2. Add per-agent “reply policy” knobs (mention-only, scheduled, or disabled) without editing JSON.
3. Optional: migrate Telegram ingest from `getUpdates` to webhooks only after the above is stable.
