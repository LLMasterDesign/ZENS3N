#!/usr/bin/env python3
# 3OX Token Benchmark :: tiktoken (cl100k_base / GPT-4) for exact counts
# No API key required — tiktoken runs locally

import tiktoken

PAIRS = [
    {
        "name": "Input-Process-Output flow",
        "prose": "When the user provides input, you should validate and normalize it. Then map the request to the contract defined in tools.yml, routes.json, and limits.json. Finally, emit the agent response with logs and status.",
        "gensing": "ρ{Input} ≔ ingest.normalize.validate{user.prompt}\nφ{Bind} ≔ map.resolve.contract{tools.yml ∙ routes.json ∙ limits.json}\nτ{Output} ≔ emit.render.publish{agent.response ∙ logs ∙ status}\n:: ∎",
    },
    {
        "name": "PiCO trace",
        "prose": "First, detect the user's request or business operation. Then process it with authoritative business focus. Next, carry the output through the system with structured response format. Finally, project the result to the user with business-ready output.",
        "gensing": "⊢ ≔ detect.request{Lucius.command ∨ business.operation ∨ system.need}\n⇨ ≔ process.business{authoritative ∙ production.focus ∙ system.maintain}\n⟿ ≔ return.output{structured.response ∙ business.format ∙ system.persist}\n▷ ≔ project.authority{business.system ∙ production.ready ∙ authoritative.output}\n:: ∎",
    },
    {
        "name": "File operation",
        "prose": "When the user requests to create a file, validate the path, check permissions, write the content, then log a receipt.",
        "gensing": "ρ{Input} ≔ user.request{create.file}\nφ{Process} ≔ validate.path ∙ check.permissions ∙ write.content\nτ{Output} ≔ file.created{path} ∙ receipt.logged\n:: ∎",
    },
    {
        "name": "Sparkfile header",
        "prose": "This is the ZENS3N sparkfile. It defines system identity and behavior. The document uses the PRISM kernel for input, process, and output flow. Version 1.0.0. Authority: ZENS3N.BASE.",
        "gensing": "▛//▞▞ ⟦⎊⟧ :: ⧗-26.152 // ZENS3N.BASE :: Sparkfile ▞▞\n▛▞// Sparkfile :: ρ{Config}.φ{Identity}.τ{System} ▹\n:: ∎",
    },
    {
        "name": "Section delimiter (×1)",
        "prose": "That concludes this data section. Let me know if you need anything else.",
        "gensing": ":: ∎",
    },
    {
        "name": "Section delimiter (×10 repeated)",
        "prose": "That concludes this data section. " * 10,
        "gensing": (":: ∎\n" * 10).strip(),
    },
    {
        "name": "Conversation end",
        "prose": "That's everything I have for now. Feel free to ask if you have more questions.",
        "gensing": ":: 𝜵",
    },
]


def main():
    enc = tiktoken.get_encoding("cl100k_base")

    def count(s):
        return len(enc.encode(s))

    print("▛▞// 3OX TOKEN BENCHMARK (tiktoken cl100k_base)")
    print("═" * 55)
    print("Method: tiktoken — exact GPT-4 token counts")
    print()

    total_prose = 0
    total_gensing = 0

    for i, pair in enumerate(PAIRS, 1):
        prose_t = count(pair["prose"])
        gensing_t = count(pair["gensing"])
        savings = ((1 - gensing_t / prose_t) * 100) if prose_t > 0 else 0

        total_prose += prose_t
        total_gensing += gensing_t

        print(f"[{i}] {pair['name']}")
        print(f"    Prose:   {prose_t} tokens")
        print(f"    Gensing: {gensing_t} tokens")
        print(f"    Savings: {savings:.1f}%")
        print()

    overall = ((1 - total_gensing / total_prose) * 100) if total_prose > 0 else 0
    print("═" * 55)
    print("TOTAL")
    print(f"  Prose:   {total_prose} tokens")
    print(f"  Gensing: {total_gensing} tokens")
    print(f"  Overall savings: {overall:.1f}%")
    print()
    print(":: ∎")


if __name__ == "__main__":
    main()
