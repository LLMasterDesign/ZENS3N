# TPR Research Pack (Chat Services as AI Interfaces)

Purpose: "proof" references that chat platforms are a valid interface for automation + AI agents, plus hard constraints (rate limits, event delivery rules).

This pack focuses on practical, implementation-relevant sources: official platform docs, plus a few high-signal papers/surveys.

## 1) ChatOps (Ops + Automation via Chat)

- O'Reilly report/book: ChatOps (Jason Hand, 2016)
  - https://www.oreilly.com/library/view/chatops/9781492042891/
  - Content preview example: "Common Uses and Tasks" / "Existing Technology"
    - https://www.oreilly.com/library/view/chatops/9781492042891/ch05.html
    - https://www.oreilly.com/library/view/chatops/9781492042891/ch06.html
- GitHub: Hubot (commissioned by GitHub; automating the company chat room)
  - https://hubot.github.com/
- GitHub: Using ChatOps to help Actions on-call engineers (Hubot + incident workflows)
  - https://github.blog/engineering/infrastructure/using-chatops-to-help-actions-on-call-engineers/
- GitHub: Orchestrator at GitHub (ChatOps integration example)
  - https://github.blog/engineering/infrastructure/orchestrator-github/
- StackStorm: ChatOps overview + architecture (queue/audit/workflows; hubot integrations)
  - https://docs.stackstorm.com/chatops/index.html
  - https://docs.stackstorm.com/chatops/chatops.html
- Atlassian: ChatOps for incident management (chat as operational interface, transcripts, security)
  - https://www.atlassian.com/incident-management/devops/chatops

## 2) Multi-User Conversational Interfaces (Research)

These papers are directly relevant to "one channel, many agents" and multi-party dialogue in chat rooms.

- Wagner et al. (2025): "A Survey on Multi-User Conversational Interfaces"
  - https://www.mdpi.com/2076-3417/15/13/7267
  - DOI: https://doi.org/10.3390/app15137267
- Elsevier / King Saud University (2022): "A survey on near-human conversational agents"
  - https://www.sciencedirect.com/science/article/pii/S1319157821003001
  - DOI: https://doi.org/10.1016/j.jksuci.2021.10.013
- IBM Research (CSCW 2017 workshop listing): "Talking with conversational agents in collaborative action"
  - https://research.ibm.com/publications/talking-with-conversational-agents-in-collaborative-action

## 3) Chat Platform Docs (Specs + Limits + Delivery Guarantees)

### Telegram

- Telegram Bot API (method contract: getUpdates, sendMessage, etc.)
  - https://core.telegram.org/bots/api
- Telegram Bot platform FAQ (practical limits guidance)
  - https://core.telegram.org/bots/faq
  - Key excerpts (verify current wording):
    - Avoid >1 msg/sec in a single chat; short bursts may be allowed, but 429 will happen.
    - In a group, bots are limited (example: 20 messages/minute guidance).
    - Global broadcast guideline ~30 msg/sec unless paid broadcasts enabled.

### Slack

- Events API: delivery rules (respond within 3 seconds; retries; "queue it" best practice)
  - https://docs.slack.dev/apis/events-api/
  - Also: https://api.slack.com/apis/events-api
- Slack Web API rate limits (posting messages guidance; per-channel limits; headers)
  - https://docs.slack.dev/apis/web-api/rate-limits/
  - Also: https://api.slack.com/apis/rate-limits

### Discord

Discord's HTTP rate limit page is JS-heavy; treat official guidance as "respect headers, don't hardcode limits".

- Support doc: "My Bot Is Being Rate Limited!" (mentions 429, global rate limit figure, invalid request limits)
  - https://support-dev.discord.com/hc/en-us/articles/6223003921559-My-Bot-Is-Being-Rate-Limited
- Gateway rate limiting (120 gateway events per connection per 60 seconds)
  - https://docs.discord.com/developers/docs/topics/gateway
- Discord Social SDK communication features (dev/testing caps; application-level limits)
  - https://docs.discord.com/developers/discord-social-sdk/core-concepts/communication-features

### Microsoft Teams

- Teams bot rate limiting guidance + concrete tables (subject to change; implement backoff on 429)
  - https://learn.microsoft.com/microsoftteams/platform/bots/how-to/rate-limit

### Matrix (event-driven, bridge/appservice model)

- Matrix Specification: Application Service API (push events over HTTP; namespace control)
  - https://spec.matrix.org/v1.16/application-service-api/

### Zulip

- Zulip API rate limiting headers + default limits (server-configurable; don't hardcode)
  - https://zulip.com/api/http-headers

## 4) Services/Frameworks That Prove This Pattern in Production

- Hubot: scripts-as-chat-commands pattern (GitHub origin)
  - https://hubot.github.com/
- StackStorm ChatOps: production ChatOps framework (aliases + workflows + audit trails)
  - https://docs.stackstorm.com/chatops/index.html
- Nautobot ChatOps app: multi-platform ChatOps framework (Slack/Teams/Mattermost/Webex)
  - https://github.com/nautobot/nautobot-app-chatops

## 5) How This Maps To TelePromptR

The key design lessons in the sources above align with TPR's direction:

- Decouple receiving from processing:
  - Slack explicitly recommends immediate 2xx + queue processing later.
- Constrain outbound throughput:
  - Telegram/Slack/Teams all enforce "per chat/thread" limits and global throttles.
- Keep a strict message contract:
  - TPR schemas live in `specs/` and can be validated by Go/Elixir/Rust/Perl implementations.
