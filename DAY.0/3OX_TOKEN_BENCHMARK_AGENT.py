#!/usr/bin/env python3
# 3OX Token Benchmark :: Agent systems (output, multi-turn, quality, + extended)
# Usage: OPENAI_API_KEY=sk-... python3 3OX_TOKEN_BENCHMARK_AGENT.py
# Optional: ANTHROPIC_API_KEY for Claude

import os
import json

# Shared base
BASE_SYSTEM = """You are ZENS3N.BASE, an authoritative business system.
State: meta_root=.3ox/_meta, wrkdsk_root=.3ox/.vec3/var/wrkdsk.
End data sections with :: ∎. End your reply with :: 𝜵."""

PROSE_OUTPUT_INSTR = """Respond in full conversational prose. Use complete sentences. End with: That concludes this section. Let me know if you need anything else."""

GENSING_OUTPUT_INSTR = """Respond in gensing format. Use :: ∎ to end data blocks. End your reply with :: 𝜵. Be compact."""

TASK = "List the 3 main system paths and their purpose. Be brief."

# SESSION.CHECKPOINT excerpt (gensing)
CHECKPOINT_GENSING = """[checkpoint]
id = "CKPT.2026-02-14.001"
meta_root = ".3ox/_meta"
wrkdsk_root = ".3ox/.vec3/var/wrkdsk"
:: ∎
[intent]
primary_goal = "Process files through governed agentic pipeline"
:: ∎"""

# Prose equivalent for session resume
CHECKPOINT_PROSE = """Session state: Checkpoint CKPT.2026-02-14.001. Meta root is .3ox/_meta. Workdisk root is .3ox/.vec3/var/wrkdsk. Primary goal is to process files through a governed agentic pipeline."""


def call_api(messages: list, api_key: str, max_tokens: int = 200, model: str = "gpt-4o-mini") -> dict:
    try:
        from openai import OpenAI
        client = OpenAI(api_key=api_key)
        r = client.chat.completions.create(
            model=model,
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
            "model": model,
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
    print(f"\n▛▞// 2. MULTI-TURN ({turns}-turn conversation)")
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


def bench_multiturn_long(api_key: str, turns: int = 15) -> dict:
    """Longer multi-turn to see context growth."""
    print(f"\n▛▞// 4. LONG MULTI-TURN ({turns} turns)")
    print("═" * 50)
    return bench_multiturn(api_key, turns=turns)


def bench_tool_flow(api_key: str) -> dict:
    """Structured output: JSON vs gensing format."""
    print("\n▛▞// 5. TOOL-CALL FLOW (JSON vs gensing output)")
    print("═" * 50)

    task = "Return the 3 system paths with purpose. Format as requested."

    # JSON format
    r_json = call_api([
        {"role": "system", "content": BASE_SYSTEM + "\n\nReturn data as JSON. Keys: paths (array of {name, purpose})."},
        {"role": "user", "content": task},
    ], api_key, max_tokens=150)
    u_json = r_json["usage"]

    # Gensing format
    r_gensing = call_api([
        {"role": "system", "content": BASE_SYSTEM + "\n\n" + GENSING_OUTPUT_INSTR},
        {"role": "user", "content": task},
    ], api_key, max_tokens=150)
    u_gensing = r_gensing["usage"]

    comp_json = u_json["completion_tokens"]
    comp_gens = u_gensing["completion_tokens"]
    sav = ((1 - comp_gens / comp_json) * 100) if comp_json > 0 else 0

    print(f"  JSON completion:    {comp_json} tokens")
    print(f"  Gensing completion: {comp_gens} tokens")
    print(f"  Savings:            {sav:.1f}%")

    return {"tool_json": comp_json, "tool_gensing": comp_gens, "tool_savings_pct": sav}


def bench_session_resume(api_key: str) -> dict:
    """Session resume: CHECKPOINT (gensing) vs prose recap."""
    print("\n▛▞// 6. SESSION RESUME (CHECKPOINT vs prose recap)")
    print("═" * 50)

    resume_question = "Given the session state above, what is the primary goal? One sentence."

    r_prose = call_api([
        {"role": "system", "content": BASE_SYSTEM},
        {"role": "user", "content": CHECKPOINT_PROSE + "\n\n" + resume_question},
    ], api_key)
    r_gensing = call_api([
        {"role": "system", "content": BASE_SYSTEM},
        {"role": "user", "content": CHECKPOINT_GENSING + "\n\n" + resume_question},
    ], api_key)

    # Prompt tokens = context size we're sending
    pt_prose = r_prose["usage"]["prompt_tokens"]
    pt_gensing = r_gensing["usage"]["prompt_tokens"]
    sav = ((1 - pt_gensing / pt_prose) * 100) if pt_prose > 0 else 0

    print(f"  Prose recap prompt:   {pt_prose} tokens")
    print(f"  CHECKPOINT prompt:   {pt_gensing} tokens")
    print(f"  Resume context savings: {sav:.1f}%")

    return {"resume_prose": pt_prose, "resume_gensing": pt_gensing, "resume_savings_pct": sav}


def bench_models(api_key: str) -> dict:
    """Same benchmark across models (gpt-4o-mini vs gpt-4o)."""
    print("\n▛▞// 7. DIFFERENT MODELS (gpt-4o-mini vs gpt-4o)")
    print("═" * 50)

    models = ["gpt-4o-mini", "gpt-4o"]
    results = {}

    for m in models:
        r_prose = call_api([
            {"role": "system", "content": BASE_SYSTEM + "\n\n" + PROSE_OUTPUT_INSTR},
            {"role": "user", "content": TASK},
        ], api_key, model=m)
        r_gensing = call_api([
            {"role": "system", "content": BASE_SYSTEM + "\n\n" + GENSING_OUTPUT_INSTR},
            {"role": "user", "content": TASK},
        ], api_key, model=m)
        cp = r_prose["usage"]["completion_tokens"]
        cg = r_gensing["usage"]["completion_tokens"]
        sav = ((1 - cg / cp) * 100) if cp > 0 else 0
        results[m] = {"prose": cp, "gensing": cg, "savings_pct": sav}
        print(f"  {m}: prose {cp} → gensing {cg} ({sav:.1f}% savings)")

    return results


def bench_traces_spec(out_dir: str = "DAY.0/benchmark_outputs") -> str:
    """Spec for real agent trace analysis (no API call)."""
    print("\n▛▞// 8. REAL AGENT TRACES (spec)")
    print("═" * 50)

    os.makedirs(out_dir, exist_ok=True)
    spec = {
        "purpose": "Analyze Cursor/Codex agent logs for prose vs gensing token usage",
        "capture": [
            "prompt_tokens per request",
            "completion_tokens per response",
            "cumulative context size over session",
        ],
        "compare": "Same task: agent with prose rules vs agent with gensing rules",
        "format": "JSONL: {ts, role, tokens, model}",
        "output": "traces_analysis.json",
    }
    path = f"{out_dir}/traces_spec.json"
    with open(path, "w") as f:
        json.dump(spec, f, indent=2)
    print(f"  Spec saved to {path}")
    print("  Run agent with prose config, capture logs. Run with gensing config, capture. Compare.")
    return path


def main():
    api_key = os.environ.get("OPENAI_API_KEY", "").strip()
    if not api_key:
        print("Set OPENAI_API_KEY and run again.")
        return 1

    print("▛▞// 3OX AGENT SYSTEM BENCHMARK (full list)")
    print("Model: gpt-4o-mini (default)")
    print("Task:", TASK)

    out = bench_output_tokens(api_key)
    mt5 = bench_multiturn(api_key, turns=5)
    bench_quality_capture(api_key)
    mt15 = bench_multiturn_long(api_key, turns=15)
    tool = bench_tool_flow(api_key)
    resume = bench_session_resume(api_key)
    models = bench_models(api_key)
    bench_traces_spec()

    print("\n" + "═" * 50)
    print("SUMMARY")
    print(f"  1. Output tokens:    prose {out['output_prose']} → gensing {out['output_gensing']} ({out['output_savings_pct']:.1f}%)")
    print(f"  2. Multi-turn 5:     prose {mt5['multiturn_prose']} → gensing {mt5['multiturn_gensing']} ({mt5['multiturn_savings_pct']:.1f}%)")
    print(f"  4. Multi-turn 15:    prose {mt15['multiturn_prose']} → gensing {mt15['multiturn_gensing']} ({mt15['multiturn_savings_pct']:.1f}%)")
    print(f"  5. Tool flow:        JSON {tool['tool_json']} → gensing {tool['tool_gensing']} ({tool['tool_savings_pct']:.1f}%)")
    print(f"  6. Session resume:  prose {resume['resume_prose']} → CHECKPOINT {resume['resume_gensing']} ({resume['resume_savings_pct']:.1f}%)")
    for m, d in models.items():
        print(f"  7. {m}: {d['savings_pct']:.1f}% output savings")
    print("\n:: ∎")
    return 0


if __name__ == "__main__":
    exit(main())
