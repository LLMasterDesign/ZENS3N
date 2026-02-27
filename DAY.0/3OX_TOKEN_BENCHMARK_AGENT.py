#!/usr/bin/env python3
# 3OX Token Benchmark :: Agent systems (output, multi-turn, quality)
# Usage: OPENAI_API_KEY=sk-... python3 3OX_TOKEN_BENCHMARK_AGENT.py

import os
import json

# Shared base
BASE_SYSTEM = """You are ZENS3N.BASE, an authoritative business system.
State: meta_root=.3ox/_meta, wrkdsk_root=.3ox/.vec3/var/wrkdsk.
End data sections with :: ∎. End your reply with :: 𝜵."""

PROSE_OUTPUT_INSTR = """Respond in full conversational prose. Use complete sentences. End with: That concludes this section. Let me know if you need anything else."""

GENSING_OUTPUT_INSTR = """Respond in gensing format. Use :: ∎ to end data blocks. End your reply with :: 𝜵. Be compact."""

TASK = "List the 3 main system paths and their purpose. Be brief."


def call_api(messages: list, api_key: str, max_tokens: int = 200) -> dict:
    try:
        from openai import OpenAI
        client = OpenAI(api_key=api_key)
        r = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=messages,
            max_tokens=max_tokens,
        )
        return {
            "usage": {
                "prompt_tokens": r.usage.prompt_tokens,
                "completion_tokens": r.usage.completion_tokens,
                "total_tokens": r.usage.total_tokens,
            },
            "choices": [{"message": {"content": r.choices[0].message.content}}],
        }
    except ImportError:
        import urllib.request
        url = "https://api.openai.com/v1/chat/completions"
        body = json.dumps({
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": max_tokens,
        }).encode()
        req = urllib.request.Request(url, data=body, method="POST")
        req.add_header("Content-Type", "application/json")
        req.add_header("Authorization", f"Bearer {api_key}")
        with urllib.request.urlopen(req, timeout=60) as r:
            return json.loads(r.read().decode())


def bench_output_tokens(api_key: str) -> dict:
    """Compare completion_tokens when model outputs prose vs gensing."""
    print("\n▛▞// 1. OUTPUT TOKENS (completion_tokens)")
    print("═" * 50)

    # Prose output
    r_prose = call_api([
        {"role": "system", "content": BASE_SYSTEM + "\n\n" + PROSE_OUTPUT_INSTR},
        {"role": "user", "content": TASK},
    ], api_key)
    u_prose = r_prose["usage"]
    content_prose = r_prose["choices"][0]["message"]["content"]

    # Gensing output
    r_gensing = call_api([
        {"role": "system", "content": BASE_SYSTEM + "\n\n" + GENSING_OUTPUT_INSTR},
        {"role": "user", "content": TASK},
    ], api_key)
    u_gensing = r_gensing["usage"]
    content_gensing = r_gensing["choices"][0]["message"]["content"]

    comp_prose = u_prose["completion_tokens"]
    comp_gensing = u_gensing["completion_tokens"]
    sav = ((1 - comp_gensing / comp_prose) * 100) if comp_prose > 0 else 0

    print(f"  Prose completion:   {comp_prose} tokens")
    print(f"  Gensing completion: {comp_gensing} tokens")
    print(f"  Output savings:     {sav:.1f}%")
    print(f"\n  Prose sample:   {content_prose[:120]}...")
    print(f"  Gensing sample: {content_gensing[:120]}...")

    return {
        "output_prose": comp_prose,
        "output_gensing": comp_gensing,
        "output_savings_pct": sav,
        "content_prose": content_prose,
        "content_gensing": content_gensing,
    }


def bench_multiturn(api_key: str, turns: int = 5) -> dict:
    """Compare total tokens over N-turn conversation (prose vs gensing style)."""
    print("\n▛▞// 2. MULTI-TURN (5-turn conversation)")
    print("═" * 50)

    # Prose conversation
    msgs_prose = [
        {"role": "system", "content": BASE_SYSTEM + "\n\n" + PROSE_OUTPUT_INSTR},
        {"role": "user", "content": TASK},
    ]
    total_prose = 0
    for i in range(turns - 1):
        r = call_api(msgs_prose, api_key)
        u = r["usage"]
        total_prose += u["total_tokens"]
        content = r["choices"][0]["message"]["content"]
        msgs_prose.append({"role": "assistant", "content": content})
        msgs_prose.append({"role": "user", "content": f"Follow-up {i+2}: Add one more detail."})
    r = call_api(msgs_prose, api_key)
    total_prose += r["usage"]["total_tokens"]

    # Gensing conversation
    msgs_gensing = [
        {"role": "system", "content": BASE_SYSTEM + "\n\n" + GENSING_OUTPUT_INSTR},
        {"role": "user", "content": TASK},
    ]
    total_gensing = 0
    for i in range(turns - 1):
        r = call_api(msgs_gensing, api_key)
        u = r["usage"]
        total_gensing += u["total_tokens"]
        content = r["choices"][0]["message"]["content"]
        msgs_gensing.append({"role": "assistant", "content": content})
        msgs_gensing.append({"role": "user", "content": f"Follow-up {i+2}: Add one more detail."})
    r = call_api(msgs_gensing, api_key)
    total_gensing += r["usage"]["total_tokens"]

    sav = ((1 - total_gensing / total_prose) * 100) if total_prose > 0 else 0

    print(f"  Prose total ({turns} turns):   {total_prose} tokens")
    print(f"  Gensing total ({turns} turns): {total_gensing} tokens")
    print(f"  Multi-turn savings: {sav:.1f}%")

    return {
        "multiturn_prose": total_prose,
        "multiturn_gensing": total_gensing,
        "multiturn_savings_pct": sav,
    }


def bench_quality_capture(api_key: str, out_dir: str = "DAY.0/benchmark_outputs") -> dict:
    """Same task, capture both responses for quality review."""
    print("\n▛▞// 3. OUTPUT QUALITY (capture for review)")
    print("═" * 50)

    os.makedirs(out_dir, exist_ok=True)

    r_prose = call_api([
        {"role": "system", "content": BASE_SYSTEM + "\n\n" + PROSE_OUTPUT_INSTR},
        {"role": "user", "content": TASK},
    ], api_key)
    r_gensing = call_api([
        {"role": "system", "content": BASE_SYSTEM + "\n\n" + GENSING_OUTPUT_INSTR},
        {"role": "user", "content": TASK},
    ], api_key)

    content_prose = r_prose["choices"][0]["message"]["content"]
    content_gensing = r_gensing["choices"][0]["message"]["content"]

    report = {
        "task": TASK,
        "prose": {
            "content": content_prose,
            "prompt_tokens": r_prose["usage"]["prompt_tokens"],
            "completion_tokens": r_prose["usage"]["completion_tokens"],
        },
        "gensing": {
            "content": content_gensing,
            "prompt_tokens": r_gensing["usage"]["prompt_tokens"],
            "completion_tokens": r_gensing["usage"]["completion_tokens"],
        },
        "rubric": "Review: completeness, structure, clarity, usefulness. :: ∎",
    }

    path = f"{out_dir}/quality_capture.json"
    with open(path, "w") as f:
        json.dump(report, f, indent=2)

    print(f"  Saved to {path}")
    print(f"  Prose:   {r_prose['usage']['completion_tokens']} completion tokens")
    print(f"  Gensing: {r_gensing['usage']['completion_tokens']} completion tokens")
    print("  Review file for quality comparison.")

    return {"report_path": path}


def main():
    api_key = os.environ.get("OPENAI_API_KEY", "").strip()
    if not api_key:
        print("Set OPENAI_API_KEY and run again.")
        return 1

    print("▛▞// 3OX AGENT SYSTEM BENCHMARK")
    print("Model: gpt-4o-mini")
    print("Task:", TASK)

    out = bench_output_tokens(api_key)
    mt = bench_multiturn(api_key)
    bench_quality_capture(api_key)

    print("\n" + "═" * 50)
    print("SUMMARY")
    print(f"  Output tokens:  prose {out['output_prose']} → gensing {out['output_gensing']} ({out['output_savings_pct']:.1f}% savings)")
    print(f"  Multi-turn:     prose {mt['multiturn_prose']} → gensing {mt['multiturn_gensing']} ({mt['multiturn_savings_pct']:.1f}% savings)")
    print("\n:: ∎")
    return 0


if __name__ == "__main__":
    exit(main())
