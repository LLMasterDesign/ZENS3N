# TPR Capacity Spec (20 / 50 / 100 msg bursts)

This spec is about answering: "Can TelePromptR handle bursts of 20, 50, 100 messages?"

## Architecture Notes (What Actually Scales)

TelePromptR is a queueing system:

- Inbound: Telegram -> `teleprompter.rb` -> writes JSON envelopes into `var/inbox/`.
- Thinking: `speaker_mesh.rb` drains `var/inbox/`, optionally calls an LLM, writes replies into `var/outbox/`.
- Outbound: `teleprompter.rb` drains `var/outbox/` and calls Telegram `sendMessage`.

Key scaling truth:

- Listen-only subscriptions do not call an LLM. They just create inbox envelopes + memory entries.
- Replies are expensive: every reply is at least 1 Telegram API call, and maybe 1 LLM call.

## Bottlenecks

1. Telegram Bot API rate limits (real world):
- The platform is typically the ceiling for outbound throughput.

2. Teleprompter internal limiter (configurable):
- `teleprompter.rb` has a global API call limiter.
- New knob: `TPR_TELEGRAM_MAX_CALLS_PER_MINUTE` (default stays conservative).

3. Fanout to subscribers:
- Each human message in a topic with `S` subscribed agents creates ~`S` inbox files.
- So `M` incoming messages becomes ~`M*S` inbox events.

4. LLM latency (if replies are enabled):
- If the mesh is running with an API key and is not listen-only, you become bound by model latency/TPM.

## How To Measure (No Telegram Needed)

Use the tools in `tools/` to run offline benchmarks that stress the same filesystem queues.

### A) Fanout write speed (teleprompter-like workload)

- Script: `tools/bench_fanout.rb`
- Measures: how fast we can write `messages * subscribers` inbox envelopes.

### B) Mesh drain speed (ingest-only workload)

- Scripts: `tools/loadtest_inbox.rb` + `tools/bench_mesh.rb`
- Measures: how fast the mesh can drain inbox and append memory.

### C) Bus bridge drain speed (many-agent outbound workload)

- Script: `tools/bench_bus_pipeline.rb`
- Measures: how fast bridge can drain outbox in dry-run mode (no Telegram).

## What "20/50/100 messages at any time" Means Here

Interpretation:

- "Burst size": number of queued envelopes waiting in `var/inbox/` or `var/outbox/`.
- The system is stable if it drains the burst to zero within an acceptable window and doesn't crash.

## Recommended Defaults (Stability First)

- Keep subscriptions listen-only (`meta.listen_only=true`), and force replies only on explicit @mentions.
- Keep autopilot off unless you want low-noise summaries, and keep the strict `<10%` ratio gate.
- Start by measuring:
  - fanout: `subscribers=24 messages=100`
  - mesh: `agents=1 messages=100` (then `agents=24 messages=100`)
