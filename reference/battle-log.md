///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂⋮⋮[TPR]⋮⋮
▛//▞▞ ⟦⎊⟧ :: ⧗-26.393 // REFERENCE :: the Battle Log feel ▞▞

# TPR backend feels like Risk's Battle Log

Named baseline: `reference/battle-log.png` (Lucius, ⧗-26.393
— "TPR backend should feel just like this"). Study it before
touching any backend surface. Do not compose from memory.

## the three zones, mapped to TPR

LEFT · the shape — fixed facts of this session, label: value
rows, ID copyable at the top.
  Risk: Game ID · Player · Round · Map · every setting
  TPR:  Bot · Group · Topic · Agent (being) · Tier · Ports
        · webhook/polling · settings, all of them, no fog

RIGHT · the log — one card per event, newest first, every
number accounted so the math closes.
  Risk: who attacked whom · starting | lost | remaining ·
        Winner, stamped with the round
  TPR:  who asked → which agent answered · tokens in | out ·
        ms · tier · delivered ∎ or refused ⊘, stamped with
        the message number

TOP · the totals — the running scoreboard, always visible.
  Risk: Troops Killed 360 · Troops Lost 315
  TPR:  messages relayed · tokens spent · failures

## the law of the feel

Cards, not prose. Numbers carry the color. You read top to
bottom and know the whole game without asking anyone. The
.gensL bus already holds every card as a receipt line — the
backend RENDERS the bus, it does not invent a second truth.
:: ∎
