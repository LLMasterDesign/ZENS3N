# TPR Multi-Agent Routing Spec

## Objective

Operate TelePromptR as a shared Telegram gateway where many agents communicate through one Telegram API boundary while preserving secure, deterministic topic/channel routing.

## Core Rule

Only TelePromptR talks to Telegram API.
All agents publish envelopes to TelePromptR; TelePromptR resolves routing and emits to Telegram.

## Routing Contract

Envelope minimum fields:
- `agent_id`
- `chat_id` (or mapped default)
- `topic_thread_id` (optional, mapped when missing)
- `text`
- `trace_id`
- `ts`

Resolution order:
1. explicit envelope topic/channel
2. agent `tgsub.key` default topic
3. policy fallback topic (`Initializing` or configured safe topic)

## Security Contract

- Agent route scopes are allowlisted.
- `tgsub.key` ownership binds `agent_id` to allowed chat/topic scopes.
- Routing violations are denied with reason-coded audit events.
- API token is never printed in logs.

## Acceptance Criteria

- 24+ concurrent active agents can publish without route collision.
- Every outbound message has a route receipt with resolved destination.
- Misrouted or unauthorized route attempts are blocked and logged.
- Topic/channel mapping changes apply without full process rewrite.
- Service remains controllable through `_forge` restart/watch loops.

## Benchmarks

- UX target: conversational smoothness similar to WhatsApp-style bot interactions.
- Infrastructure target: one Telegram API boundary serving many internal agents.
