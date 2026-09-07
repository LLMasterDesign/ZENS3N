///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ⋮⋮[TPR]⋮⋮
▛//▞▞ ⟦⎊⟧ :: ⧗-26.395 // HANDOFF :: TelePromptR · read this first ▞▞
▛// "all my agents can always talk to me in Telegram" ▞▞//▟

Told by Lucius ⧗-26.395, in his words. This is the backdrop the
next conversation opens with. Do not re-derive it. Do not ask him
to repeat it.

════════════════════════════════════════════════════════════
▛▞// WHERE TPR CAME FROM
The origin is glyphbits, and the problem that forced the design.

He built glyphbits — Naktua the owl, a fox, and Tricoon the
raccoon. Each runs on ONE prompt, nothing fancy: they respond,
they talk like their character. He gave each its own Telegram bot.

Then the problem: all three answered every message. One message
went to all three, no matter who he was talking to.

That is why WARDEN exists — a third party that decides who gets
to respond. Then each responder got its own channel: go to the
owl's channel to talk to the owl, or say @owl in the group chat
and only the owl answers.

Warden became Box AI. Box AI became the XYZ system he runs now —
SYSCOM, sysgen, ORION, OTP. All of it spawned from TelePromptR.

▛/// TPR is the origin of the whole stack
Not a side project. The router that everything else grew out of.
:: ∎

════════════════════════════════════════════════════════════
▛▞// WHAT HE IS SELLING
A digital service inside Telegram, where digital services are
king. TelePromptR is the product.

The user's path, as he described it:
    · buy it in a Telegram shop (digital goods)
    · get a key from Lucius
    · plug that key into the TelePromptR front end (Base44)
    · that key grants them access to use it
    · they add the TelePromptR bot to their group

▛/// The TPR bot SELLS the service — it is not the service
This is the part that is easy to get wrong. The TelePromptR bot
asks the user what THEIR bot should be named and walks them
through making it in BotFather. Their bot becomes their own
TelePromptR relay. Lucius owns none of their bots, keys, or
agents.
:: ∎

════════════════════════════════════════════════════════════
▛▞// WHY IT MATTERS TO HIM
Telegram is near and dear to him. This is not a feature request.

Built right, every agent he sets up anywhere can always reach him
in Telegram. He wants to talk to Claude there, to Ender there, to
everybody — one group chat, work getting done over time, WITHOUT
him having to press play every time. He is tired of being the
one who presses play.

He is explicit that Grok's bot makes people think this is solved.
It is not. The better parts already exist in his stack; they need
cleaning up and versioning.

RAVEN comes later: the TDLib Telegram sidekick that reads his
history and cleans his stuff up. That needs these layers first.
:: ∎

════════════════════════════════════════════════════════════
▛▞// THE VERSION LADDER — his exact definitions
Every file system he owns gets versioned this way, not just TPR.

    v0   ORIGINS · archive · whatever you find, throw it in v0
    v1   BASELINE · just the identity
    v2   THE PARTS
    v3   THE PROTOTYPE
    v4   THE FIRST TEST RUN     ← TPR is here
    v5   A CLEAN RUN · self-running · less Python,
         more Rust · Ruby · Elixir · gRPC · .gen folders

v5 is built FROM v0–v4. It is never fabricated. The goal across
the board is v5 everywhere; only then is it functional.
:: ∎

════════════════════════════════════════════════════════════
▛▞// WHAT MY JOB IS
Prompts for Base44. Base44 is the front end and he pays for it.

He writes nothing; he declares, and the system writes it down.
I make prompts he pastes into Base44, plus the backend Base44
cannot reach (relay, signature verification, routing, sync).
I do not hand-write the front end. That was the loop that cost
four days.
:: ∎

════════════════════════════════════════════════════════════
▛▞// WHERE THINGS ARE
    ZENSEN.CMD/!WORKDESK/TelePromptR/     the active folder
      prompts/001.login.md · 002.userpage.md
      spec/    routing model · station spec · TPR.HUB corpus
      app/     the Base44 project (app id 6a9d1c00…)
      archive/ → symlink to Citadel
    /srv/7HE.CITADEL/TelePromptR/v0–v4 + VERSIONS.md
    CENTRAL.CMD/Telegram/TelePromptR     the LIVE relay (run.py 132k)

Proven already: Telegram signature login works (real 200, forged
401, expired 401), Member row idempotent, @tpr_zenbot exists,
tpr.3ox.me CNAME is set (cert pending on Render's side).

⚑ The Zendex index is stale (Aug 12) — search the live filesystem,
  not the cache, or the January origins stay hidden.
:: ∎ ::END_TPR.HANDOFF::
