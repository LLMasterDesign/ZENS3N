# 7HE STORE — what is left to wire

Code side is done and tested (⧗-26.391). Two beings behind one bot:
a topic with a card answers as RAV3N, a topic without one answers
as Ender. Only the Telegram side is missing.

1. Create the group, turn **Topics** on, add `@ender_zenbot`, make it
   admin. Topics: `general` · `store` · `course`.
2. Send one message in each topic. Read the ids from the log:
   `journalctl --user -u tpr -n 50 | grep "telegram update"`
   — the line prints `chat=<group id>`; the topic id is the
   `message_thread_id` of that message.
3. Paste them in:
   - `Threads/store/thread.id`  ← replace `PENDING-store`
   - `Threads/course/thread.id` ← replace `PENDING-course`
   - `group.id`                 ← the group `chat=` id (new file,
     only the desk herald reads it)
4. Say `/threads` in the chat — it re-walks the cards, no restart.

## Privacy — already off at Telegram, gated in code

`getMe` on @ender_zenbot says `can_read_all_group_messages: true`
(checked ⧗-26.392) — group privacy is **already disabled** in
BotFather, so Telegram delivers every group message to TPR. The
thing that ignores them is TPR's own gate at `run.py:1266`, which
answers only mentions, replies and `/commands`.

So there is **no BotFather change to make**. If you want RAV3N to
answer every message in `# store` without an `@`, that is a
scoped change to that gate — let a topic whose card names a being
take plain messages. Your call; it stays as-is until you say.

## Unprompted progress (optional, off)

`vec3/bin/raven-desk-herald.py` drops a Herald when RAV3N's `final/`
drawer gains a draft. Delivery is gated by TPR's LoopPolicy, which
ships **disabled**. Arming it means `PROACTIVE_LOOP_ENABLED=1` and
the group id in `PROACTIVE_LOOP_ALLOWLIST` on the tpr unit — that is
outbound messages without you asking, so it stays off until you say.

:: ∎
