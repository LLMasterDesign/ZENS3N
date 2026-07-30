# FABLE PASS :: AEGEN.PROOF.BAND :: F0 Audit

Date: 2026-07-30 · Reviewer: Fable (fresh session) · Scope: plan `federated-baking-gem.md` sections B1/B2 vs sources
Sources read: Zensen Market Analysis v3.0 · N13.PALANTIR.counter.position · 12.YC.APP.FINAL · proof-band.kdl
Not available: APPLE.MODEL.PROVIDER.ABSTRACTION.v0.1 (listed "user-provided inline" — not in the pulled set; Apple claims audited against public WWDC/Apple docs knowledge only)

---

## CORRECTIONS LIST

### B1 · Market.html

1. **Failure strip · "95% GenAI pilots zero P&L impact (MIT NANDA)" — replace or caveat.**
   Your own N13 verifier flagged this exact statistic as methodologically contested (small sample, criticized as hype) and *repaired invariant 3 specifically so it no longer hinges on it*. Putting it back as a headline stat re-introduces the weakness your verifier already removed. Swap for the corroborated pair: **IDC: 88% of agent POCs never reach production** (survived N13 refutation), or keep MIT NANDA but date it (Aug 2025) and pair it with IDC so the card doesn't stand on the contested number alone.

2. **Failure strip · "89% agent pilots never reach production — src=Gartner 2026" — attribution is soft.**
   The 89%/Gartner pairing appears only in N13's field notes; the *verified* Gartner artifact is the June 25, 2025 press release (>40% canceled by 2027, ~130 real vendors). The 89% figure sits one step from a primary source and is one point off IDC's verified 88%. Either keep 89% with a footnote link you can actually produce, or use IDC 88% which is already adversarially verified. On a public page, a smart friend who googles "Gartner 89%" and finds IDC instead costs you more than the 1% difference is worth.

3. **Failure strip · date every stat.** Gartner >40% and ~130 vendors are from June 2025 (13 months old); MIT NANDA is Aug 2025. The plan's own gate flags data older than 6 months. None of these need to be dropped — they're still the standard citations — but each card should carry its "as of" date. The fresh material (Palantir Q1 2026, Karp June 30/July 1 2026, Replit Mar 2026, Temporal Feb 2026) makes the old material look older if undated.

4. **Gap panel · Cursor "can't leave IDE" — soften.**
   Cursor has been shipping background/cloud agents and non-IDE surfaces; a flat "can't leave IDE" is refutable on sight by anyone who uses it. Soften to "IDE-centric — the harness lives where the developer already is" or similar. The valuation and ARR figures ($29.3B post-money Nov 2025, >$1B annualized) are correctly cited; date them.

5. **Gap panel · Apple "2B devices" — soften.**
   ~2.35B *active Apple devices* is real, but Apple Intelligence requires iPhone 15 Pro+/M-series — the actual Apple-Intelligence-capable base is a fraction of 2B. Say "2B+ active devices (Apple Intelligence on the newest fraction)" or drop the number. Also "no governance" is attackable (entitlements, App Intents scoping, PCC attestation *are* governance of a kind); the defensible phrasing is "no cross-app ontology, no receipts, no user-programmable authority" — those three are true and are your actual wedge. The provider-abstraction framing (On-Device / Private Cloud Compute / ChatGPT-extension, closed selector) does match public WWDC 2025 docs — that part holds. ⚠ Could not check against APPLE.MODEL.PROVIDER.ABSTRACTION.v0.1 itself; stage that file into refs/ before build.

6. **Gap panel · Palantir card — solid.** $1.633B Q1 2026 rev (+85% Y/Y, reported May 4 2026), $1M+ floor, "monetizes the dependency" all trace cleanly to N13's verified numbers and invariants. Add the Karp quote's date/venue (CNBC Squawk Box, July 1, 2026) wherever it appears — it's your freshest asset; timestamping it is free credibility.

7. **Comps table · time-align Replit.** "~$150M ARR / 40M users" is Sep 2025 data; "$9B" is Mar 2026. Fine to show both, but as one undated row it implies $9B *at* $150M ARR. Either date the cells or write "$150M ARR (Sep '25) → $9B (Mar '26)". Lovable ($17M ARR in ~3 months, Feb 2025; $6.6B Dec 2025), Cursor, Temporal rows check out against the market analysis.

8. **Missing from B1 — the orchestration-framework question.** The Gap panel triangulates Palantir × Cursor × Apple, but your own YC app names the *closest direct competitors* as LangGraph, Letta, OpenAI Agents SDK. A smart friend will ask "how is this not LangGraph?" before they ask about Palantir. One line in the wedge panel ("workflow graphs and SDKs orchestrate calls; none compile identity, authority, and receipts before execution") closes the hole cheaply.

### B2 · Product.html

9. **MVP definition strip — restore "separating authority."**
   Plan compresses the MVP to "preserving identity and authority"; the canonical MVP statement is "preserving identity, **separating** authority, and proving every transition." Preserved vs separated authority is not a nuance in this architecture — separation (proposer≠authorizer, builder≠activator) is the safety claim. Use the source wording.

10. **Day-1 card — frame as commitments, not metrics.**
    ">= 3 concurrent users, >= 100 closed-loop runs, 0 unauthorized effects, 100% receipt coverage" are the *Aug 8 proof-card thresholds*, not achieved results (the market analysis itself classifies these under PLANNED PROOF, and external customer/revenue evidence is explicitly absent from inspected packets). Label the card "Day 1 commitments · Aug 8, 2026" and it becomes a strength (a falsifiable public promise — same move the YC app makes); leave it unlabeled and it reads as claimed telemetry, which is the one thing that can sour a friend-investor later.

11. **Runtime panel — mark existence status once.**
    The actor cards mix verified components (ORION OTP app, ender_harness, BLAKE3 evidence tape, ζSENSE ingress), founder-attested pieces (HALO, Gensing speed claim), and partial paths (full signed return, cross-agent performance). The page doesn't need the full evidence taxonomy, but one honest line — "runtime live on sovereign hardware; public proof of the full loop lands Day 1" — keeps every card true without weakening any of them. `zendex .zdx/.gensL` details are founder-attested only; fine on the page, but don't cite them as shipped in any caption.

12. **Pricing panel — matches source exactly.** All six tiers trace verbatim to the market analysis pricing architecture. No changes. One suggestion, not a correction: a smart friend's next question after pricing is "what do I get on Day 1 for it" — a single line tying the paid compiler (`aegen -c`) to the Aug 8 activation path answers it.

13. **Both pages · missing "who."** Neither page spec mentions the founder. Pre-revenue, friends-first: the reader knows *you*; the pages omitting any human presence makes the band feel bigger and less accountable than the actual pitch ("solo founder, ~5,000 hours, on metal") — which is the YC app's strongest tonal asset. One footer line suffices.

### Cross-cutting

14. **Refs must exist before the pages go public.** C1's refs/ folder is the difference between "every number traceable" and "numbers on a dark page." Minimum set before funnel-public: Gartner June 2025 PR, Palantir Q1 2026 IR page, CNBC Karp July 1 2026, Lovable/Replit/Cursor/Temporal announcements, Apple FoundationModels + Shortcuts docs. All URLs already sit in the market analysis and N13 source lists — collection is an hour, not research.

---

## CONFIDENCE GRADES

| Page | Grade | Basis |
|---|---|---|
| Valuation.html (live) | **not audited** | Built page not in provided set; only its design tokens (kdl) were reviewed. If it shows the $11M/$35M lens numbers publicly, apply the same dating discipline as above. |
| Market.html (B1) | **SOFTEN** | Structure and wedge logic hold; corrections 1–8 are wording/dating/attribution, not rewrites. Ship after the failure strip swaps to verified stats and Apple/Cursor cards are softened. |
| Product.html (B2) | **SHIP** (with corrections 9–11) | Content is internal product truth matching sources nearly verbatim; the only real risk is future-tense targets reading as present-tense telemetry, fixed by labels. |

---

## STRONGEST + WEAKEST

The strongest thing about this band is that its wedge is *current and adversarially verified*: the Karp sovereignty manifesto (June 30) and CNBC quote (July 1) are four weeks old, Palantir Q1 2026 numbers are one quarter old, and the N13 invariants behind the positioning already survived a refutation pass — so the Palantir × Cursor × Apple triangulation isn't a framing exercise, it's a documented structural gap with the incumbent's own CEO supplying the copy. The weakest thing is the failure strip and its neighbors leaning on the band's *oldest and most contested* numbers (MIT NANDA's 95%, 13-month-old Gartner figures, an 89% stat one step from its source) while nothing on either page distinguishes what exists today from what ships August 8 — for a pre-revenue, pre-user, solo-founder company showing this to smart friends, the undated-stat/unlabeled-target combination is the single most likely credibility leak, and it's entirely fixable with dates and two labels, no rewrites.

:: ∎
