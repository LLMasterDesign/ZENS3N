///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ⋮⋮[TPR]⋮⋮
▛//▞▞ ⟦⎊⟧ :: ⧗-26.394 // MODEL :: what TPR IS, so the door isn't superficial ▞▞

> Collected from the running relay (TPR.Gen/run.py), the routing cards
> (spec/routing/Groups), TPR.HUB, and station.spec. The door and the
> workspace must REFLECT this model — not invent a parallel list.

════════════════════════════════════════════════════════════
▛▞// THE NOUNS (and how they connect)
════════════════════════════════════════════════════════════

    Bot        @tpr_zenbot — one Telegram token, the single door.
               All agents route THROUGH it (Lucius's law: TPR
               decides who goes where).

    Member     a Telegram person. Login = their signature. (built)

    Group      a Telegram group TPR is added to. On join, the relay
               writes Pulse/tpr/Groups/<slug>/group.me + group.id.
               (relay handler built this session)

    Topic      a forum topic inside a group (message_thread_id).
               A topic CARD (thread.me) names a being + a tier.
               No card = the default being (Ender).

    Agent/     WHO answers a topic — Ender, RAV3N, … resolved by
    Being      _being_of(thread_id) from the topic card. Each has a
               persona (.ae/spark), a desk, and its own receipt lane.

    Tier       the METAL a being answers on: local 35B :8080 ·
               light 9B :8082 · raven · elders · qwen · orion.
               A topic card can pin one.

    Station    a TPR-shaped service on the rail (the relay itself
               :7090 face / :5090 brains; others per the decade law).

    Service    supporting infra a station leans on.

    Relay      message in a topic → being answers on its tier →
               reply back. The whole point.

    Receipt    every relayed turn emits ONE .gensL line (∀λᴳ ∃!τ).
               The Battle Log IS the rendered receipt stream:
               who asked → which agent → tokens in|out · ms →
               delivered ∎ or refused ⌁.

════════════════════════════════════════════════════════════
▛▞// THE CHAIN (one relayed message)
════════════════════════════════════════════════════════════

    Telegram → @tpr_zenbot → TPR relay (run.py)
      → which group? which topic? → topic card → being + tier
      → being answers on tier → reply to the topic
      → receipt on the bus → Battle Log card

════════════════════════════════════════════════════════════
▛▞// WHAT THE DOOR / WORKSPACE MUST SHOW (not a dead list)
════════════════════════════════════════════════════════════

    Open TPR (blue)  → USER PAGE
      who you are · your agents · quick glance

    Open TelePromptR (menu) → WORKSPACE (the tinkering)
      Groups     the groups TPR is in, live from the relay
      Topics     per group, each topic and the agent+tier it routes to
      Agents     Ender + others, their real status/tier/node
      Stations   the rail (:7090 face, :5090 brains, …) real health
      Services   supporting infra
      Relay Log  the Battle Log — real receipts, math closing

════════════════════════════════════════════════════════════
▛▞// THE BRIDGE (why "nothing connects" right now)
════════════════════════════════════════════════════════════

The relay (run.py, on en0/minsky) OWNS the routing truth:
Pulse/tpr/Groups cards + being resolution + the .gensL bus. The
Base44 door is a SEPARATE surface and cannot read en0's disk.

To make the workspace REAL, the routing must cross the gap:
  · relay → Base44 : the relay syncs its groups/topics/agents/
    receipts INTO Base44 entities (a sync push, or the door's
    connect fn writes cards the relay reads back).
  · door → relay  : a topic wired in the workspace writes the
    thread.me card the relay routes on.

Until that bridge exists, the door's lists are just names. THIS
is the next real build, and why the specs had to land first.
:: ∎ ::END_TPR.MODEL::
