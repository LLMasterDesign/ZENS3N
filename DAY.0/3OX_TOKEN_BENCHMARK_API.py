#!/usr/bin/env python3
# 3OX Token Benchmark :: Runtime API usage (prose vs gensing priming)
# Measures actual tokens consumed when AI is primed then asked a test question
# Usage: OPENAI_API_KEY=sk-... python3 3OX_TOKEN_BENCHMARK_API.py

import os
import json

# Prose system prompt (typical verbose agent instructions)
PROSE_SYSTEM = """You are ZENS3N.BASE, an authoritative business system for production deployment.

When you start a session, first read the session checkpoint file to understand current system state, truth paths, and known drift. Then load the sparkfile for your identity and behavior specification. Then load the brains config for persona settings.

Your flow: detect user requests or business operations, process with authoritative business focus, return structured output with business format. Use the PRISM kernel: Input maps to ingest and validate, Process maps to contract resolution, Output maps to emit and publish.

End data sections with the token :: followed by the end-of-proof symbol. End conversational output with the conversation terminator. Validate all paths against the write policy. Emit receipts for operations.

The system uses single authority per concern: Worker executes, Warden approves, Supervisor orchestrates via proto contracts, Pulse writes meta artifacts. State machine phases: TRACK, PLAN, DRY_RUN, FIX, EXECUTE, SEAL. Allowed write roots: WORKDESK, ZENS3N.OPS/receipts, .3ox/_meta/receipts, merkle.root, wrkdsk. Blocked: wrksdsk, state. Tools registry in tools.yml. Routes in routes.json."""

# Gensing minimal (ASCII, delimiter-heavy — best token savings)
GENSING_MINIMAL = """[checkpoint]
id = "CKPT.2026-02-14.001"
meta_root = ".3ox/_meta"
wrkdsk_root = ".3ox/.vec3/var/wrkdsk"
:: ∎

[intent]
primary_goal = "Process files through governed agentic pipeline"
principle = "single_authority_per_concern"
:: ∎

[prism]
P = authoritative.system -> business.operations -> production.deployment
S = receive -> process -> deliver -> maintain
:: ∎

[pico]
1 = detect.request
2 = process.business
3 = return.output
4 = project.authority
:: ∎

[rules]
End data sections with :: ∎
End conversational output with :: 𝜵
:: ∎"""

# Gensing full (Unicode symbols — semantic richness, higher token cost)
GENSING_FULL = """▛▞// ZENS3N.BASE :: ρ{Config}.φ{Identity}.τ{System} ▹
⫸ 〔runtime.sparkfile.context〕

[checkpoint]
id = "CKPT.2026-02-14.001"
meta_root = ".3ox/_meta"
wrkdsk_root = ".3ox/.vec3/var/wrkdsk"
:: ∎

[intent]
primary_goal = "Process files through governed agentic pipeline"
principle = "single_authority_per_concern"
:: ∎

▛///▞ PRISM :: KERNEL
P:: authoritative.system → business.operations → production.deployment
S:: receive → process → deliver → maintain
:: ∎

▛///▞ PiCO :: TRACE
⊢ ≔ detect.request{Lucius.command ∨ business.operation ∨ system.need}
⇨ ≔ process.business{authoritative ∙ production.focus}
⟿ ≔ return.output{structured.response ∙ business.format}
▷ ≔ project.authority{business.system ∙ production.ready}
:: ∎

▛▞ RULES
End data sections with :: ∎
End conversational output with :: 𝜵
:: ∎"""

TEST_USER = "What is the current system state? Reply in one sentence."


def call_api(system: str, user: str, api_key: str) -> dict:
    try:
        from openai import OpenAI
    except ImportError:
        import urllib.request
        import urllib.error

        url = "https://api.openai.com/v1/chat/completions"
        body = json.dumps({
            "model": "gpt-4o-mini",
            "messages": [
                {"role": "system", "content": system},
                {"role": "user", "content": user},
            ],
            "max_tokens": 100,
        }).encode()
        req = urllib.request.Request(url, data=body, method="POST")
        req.add_header("Content-Type", "application/json")
        req.add_header("Authorization", f"Bearer {api_key}")
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode())
    else:
        client = OpenAI(api_key=api_key)
        r = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": user},
            ],
            max_tokens=100,
        )
        return {
            "usage": {
                "prompt_tokens": r.usage.prompt_tokens,
                "completion_tokens": r.usage.completion_tokens,
                "total_tokens": r.usage.total_tokens,
            },
            "choices": [{"message": {"content": r.choices[0].message.content}}],
        }


def main():
    api_key = os.environ.get("OPENAI_API_KEY", "").strip()
    if not api_key:
        print("Set OPENAI_API_KEY and run again.")
        return 1

    print("▛▞// 3OX TOKEN BENCHMARK (API runtime usage)")
    print("═" * 55)
    print("Priming AI with system prompt, then asking test question.")
    print("Model: gpt-4o-mini")
    print()

    results = {}

    # Prose run
    print("[1] Prose priming...")
    try:
        r = call_api(PROSE_SYSTEM, TEST_USER, api_key)
        u = r["usage"]
        results["prose"] = u["total_tokens"]
        print(f"    total_tokens: {u['total_tokens']}")
    except Exception as e:
        print(f"    ERROR: {e}")
        return 1

    # Gensing minimal (ASCII, :: ∎)
    print()
    print("[2] Gensing minimal (ASCII + :: ∎)...")
    try:
        r = call_api(GENSING_MINIMAL, TEST_USER, api_key)
        u = r["usage"]
        results["gensing_minimal"] = u["total_tokens"]
        print(f"    total_tokens: {u['total_tokens']}")
    except Exception as e:
        print(f"    ERROR: {e}")
        return 1

    # Gensing full (Unicode)
    print()
    print("[3] Gensing full (Unicode ⊢⇨⟿▷ρφτ)...")
    try:
        r = call_api(GENSING_FULL, TEST_USER, api_key)
        u = r["usage"]
        results["gensing_full"] = u["total_tokens"]
        print(f"    total_tokens: {u['total_tokens']}")
    except Exception as e:
        print(f"    ERROR: {e}")
        return 1

    # Compare
    p = results["prose"]
    gm = results["gensing_minimal"]
    gf = results["gensing_full"]
    sav_min = ((1 - gm / p) * 100) if p > 0 else 0
    sav_full = ((1 - gf / p) * 100) if p > 0 else 0

    print()
    print("═" * 55)
    print("RESULT")
    print(f"  Prose:           {p} tokens (baseline)")
    print(f"  Gensing minimal: {gm} tokens — {sav_min:.1f}% savings")
    print(f"  Gensing full:    {gf} tokens — {sav_full:.1f}% savings")
    print()
    print(":: ∎")
    return 0


if __name__ == "__main__":
    exit(main())
