# TelePromptR Upgrade Backlog

## Track 0: Multi-Agent Telegram Routing Fabric

- [ ] Single Telegram API boundary (TelePromptR only component with Telegram API access).
- [ ] Support dozens of agents concurrently over shared ingress/egress bus.
- [ ] Deterministic routing policy: `agent_id -> chat_id + topic_thread_id + channel scope`.
- [ ] Per-agent identity prefixing and outbound routing receipts.
- [ ] Channel/topic allowlist enforcement per agent (no cross-topic leakage).
- [ ] Routing fallback strategy when topic mapping is missing (safe default + explicit alert).
- [ ] Load test profile for 24+ concurrent active agents with ordered delivery guarantees.

## Track 1: Runtime + Security

- [ ] Harden `_forge` as primary local/VPS control loop.
- [ ] Enforce explicit write allowlist (`wrkdsk`) for mutating actions.
- [ ] Add risk-profile gates (`low`, `medium`, `high`) for tool execution.
- [ ] Ensure API key never appears in logs or process list snapshots.
- [ ] Issue/rotate/revoke per-agent `tgsub.key` with audit timestamps.

## Track 2: Agentic Core

- [ ] Level-1 agentic loop with stable iteration cadence.
- [ ] Continuous reflection worker (memory boss).
- [ ] Markdown-native memory database with scoped retrieval.
- [ ] Self-awareness fields: source tree, harness, model, reasoning mode, tool map.
- [ ] No-reply-token mode for internal loop chatter suppression.

## Track 3: Human-like Interaction

- [ ] Personality layer with explicit boundaries.
- [ ] Community management playbooks (response style + escalation).
- [ ] Marketing support mode for website/community updates.
- [ ] Onboarding wizard for first-run setup and trust prompts.

## Track 4: Packaging + Platform

- [ ] `3ox.ai = linux2go` deployment shape.
- [ ] Docker packaging profile.
- [ ] npm package/domain integration surface.
- [ ] Artifact signing + reproducible release notes.

## Track 5: Observability + Governance

- [ ] Tool-call receipts and mutation evidence.
- [ ] Session-level risk summary export.
- [ ] Runtime health + backlog status reporting over TelePromptR uplink.
- [ ] Route-audit stream: inbound envelope, selected route, publish result, and delivery ack.

## Immediate Build Sequence

1. Stabilize `_forge` + secure key lifecycle.
2. Ship Track 0 routing fabric (shared Telegram API + agent/topic/channel routing).
3. Integrate existing Teleprompter entrypoint and validate restart loop.
4. Add reflection + markdown memory pipeline.
5. Layer personality/onboarding + risk profiling.
6. Package for VPS + linux2go and publish release checklist.
