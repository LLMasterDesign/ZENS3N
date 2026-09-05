///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂⋮⋮[TPR]⋮⋮
▛//▞▞ ⟦⎊⟧ :: ⧗-26.393 // RULES :: TPR v3 · the repeatable build ▞▞

# TPR.RULES — how this branch builds, every time

TPR v3 = OpenRouter for Telegram. One service, five ports.
NOT Ender. v1 (2025) and v2 (@ender_zenbot) are dumps and
scaffold — nothing here assumes them. These rules exist so
no work happens in an assumed sandbox chat project, ever.

## 1 · the branch is the truth
ZENS3N branch `TelePromptR` holds v3. Anything not committed
here does not exist. Ships as a lone repo when done — that
moment is Lucius's call, and only then does GitHub main-sync
become possible (Base44 two-way sync is MAIN-BRANCH ONLY —
it cannot target a branch; verified against their docs
⧗-26.393).
:: ∎

## 2 · one app, linked once
The Base44 app is named TelePromptR. It is created ONCE and
bound to a checkout of this branch with `base44 link`.
Iteration happens in that one linked app. A new chat-project
in Base44 is scatter — refuse it, return to the linked app.
:: ∎

## 3 · the CLI is the bridge, not GitHub sync
Code moves: Base44 ⇄ `base44` CLI ⇄ this branch. Pull the
app code into the checkout, read the diff, commit. No sync
robot writes here. When the lone-repo day comes, main-sync
can take over — not before.
:: ∎

## 4 · prompts are files, not chat
Every prompt that produces a Base44 change is saved under
`prompts/` in this branch BEFORE it runs, numbered. The
branch can replay the whole app from its prompts. A change
whose prompt is not filed did not happen.
:: ∎

## 5 · secrets never ride
Bot tokens and keys live in Base44 project secrets and in
the station vault. Never in this branch, never inside a
prompt file. The public repo stays clean enough to hand out.
:: ∎

## 6 · proof or it is not done
A change is done when: the commit is on this branch, the
diff was read, and the thing answers where it runs. The
commit hash is the receipt. No hash, not done.
:: ∎

## 7 · deploy is a pull, not a promise
The VPS serves what this branch holds — git pull, restart
the seat, health answers. Base44 hosting stays off; the
login and mini app it writes are code in this branch, served
from Lucius's metal.
:: ∎
