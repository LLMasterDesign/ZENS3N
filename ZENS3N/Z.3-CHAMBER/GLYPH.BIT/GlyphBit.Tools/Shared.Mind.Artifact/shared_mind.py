"""
▛▞ GLYPHBIT SHARED MIND ∎
Cross-bot memory, knowledge, and depth of field system
"""

import json
import os
from datetime import datetime
from pathlib import Path

# Shared memory file
CORE_DIR = Path(__file__).parent
SHARED_MEMORY = CORE_DIR / "glyphbit_shared_memory.json"
GLOBAL_POLICY = CORE_DIR / "global_policy.json"

# ═══════════════════════════════════════════════════════════
# SHARED KNOWLEDGE BASE
# ═══════════════════════════════════════════════════════════

def load_shared_memory():
    """Load shared knowledge across all bots"""
    if SHARED_MEMORY.exists():
        with open(SHARED_MEMORY, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {
        "insights": [],  # Profound observations shared between bots
        "topics_explored": {},  # What topics have been discussed deeply
        "user_patterns": {},  # Observed user patterns (for depth)
        "context_depth": 1,  # Current conversation depth level
        "last_update": None
    }

def save_shared_memory(memory):
    """Save shared knowledge"""
    memory["last_update"] = str(datetime.now())
    with open(SHARED_MEMORY, 'w', encoding='utf-8') as f:
        json.dump(memory, f, indent=2)

def add_insight(bot_name, insight_text):
    """Add a profound insight to shared knowledge"""
    memory = load_shared_memory()
    memory["insights"].append({
        "bot": bot_name,
        "insight": insight_text,
        "timestamp": str(datetime.now())
    })
    # Keep only last 50 insights
    memory["insights"] = memory["insights"][-50:]
    save_shared_memory(memory)

def track_topic(topic_key, depth_level):
    """Track how deeply a topic has been explored"""
    memory = load_shared_memory()
    if topic_key not in memory["topics_explored"]:
        memory["topics_explored"][topic_key] = {"count": 0, "max_depth": 0}
    
    memory["topics_explored"][topic_key]["count"] += 1
    memory["topics_explored"][topic_key]["max_depth"] = max(
        memory["topics_explored"][topic_key]["max_depth"], 
        depth_level
    )
    save_shared_memory(memory)

def get_depth_context(chat_id, topic=None):
    """
    Get depth-of-field context for richer responses
    Returns deeper context if topic has been explored before
    """
    memory = load_shared_memory()
    
    # Check if this topic has depth history
    if topic and topic in memory["topics_explored"]:
        topic_data = memory["topics_explored"][topic]
        if topic_data["count"] > 3:
            return f"\n\nDEPTH CONTEXT: This topic has been explored {topic_data['count']} times. User seeks deeper understanding. Increase insight depth."
    
    # Return recent insights for context
    recent_insights = memory["insights"][-5:]
    if recent_insights:
        insight_context = "\n".join([f"- {i['bot']}: {i['insight'][:100]}..." for i in recent_insights])
        return f"\n\nSHARED INSIGHTS:\n{insight_context}\n"
    
    return ""

# ═══════════════════════════════════════════════════════════
# GLOBAL POLICY SYSTEM
# ═══════════════════════════════════════════════════════════

def load_global_policy():
    """Load global policy for all bots"""
    if GLOBAL_POLICY.exists():
        with open(GLOBAL_POLICY, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {
        "response_depth": {
            "surface": "1-2 sentence quick answers",
            "medium": "3-5 sentences with context",
            "deep": "Full perspective shift with examples"
        },
        "quality_gates": {
            "min_token_count": 27,  # Numerology aligned
            "max_token_count": 144,
            "require_substance": True,
            "no_generic_advice": True
        },
        "cross_bot_coherence": {
            "maintain_tone": True,
            "reference_siblings": "occasional",
            "shared_knowledge": True
        }
    }

def get_policy_for_bot(bot_name):
    """Get specific policy settings for a bot"""
    policy = load_global_policy()
    
    # Bot-specific depth recommendations
    depth_map = {
        "noctua": "deep",  # Noctua goes deepest
        "vulpes": "medium",  # Vulpes balances help + jab
        "trickoon": "deep"  # Trickoon goes cosmic deep
    }
    
    recommended_depth = depth_map.get(bot_name, "medium")
    return {
        "policy": policy,
        "recommended_depth": recommended_depth,
        "quality_gates": policy["quality_gates"]
    }

# ═══════════════════════════════════════════════════════════
# DEPTH OF FIELD GENERATOR
# ═══════════════════════════════════════════════════════════

def generate_depth_prompt(bot_name, chat_type, message_history_count=0):
    """
    Generate depth-of-field context to add substance to bot responses
    """
    policy = get_policy_for_bot(bot_name)
    memory = load_shared_memory()
    
    # Increase depth if conversation has history
    depth_level = "surface"
    if message_history_count > 3:
        depth_level = "medium"
    if message_history_count > 7:
        depth_level = "deep"
    
    depth_instruction = f"""

═══ DEPTH OF FIELD ═══
CURRENT DEPTH: {depth_level}
RECOMMENDED: {policy['recommended_depth']}

QUALITY REQUIREMENTS:
- Minimum substance: {policy['quality_gates']['min_token_count']} tokens
- No generic advice - specific insights only
- Each response should shift perspective or reveal something new
- Reference shared knowledge when relevant

RECENT SHARED INSIGHTS:
{get_recent_insights_summary(memory)}

DEPTH GUIDELINE:
{policy['policy']['response_depth'][depth_level]}

Remember: You are part of the GlyphBit collective. 
Your siblings have contributed insights. Build on their wisdom.
═══════════════════════
"""
    
    return depth_instruction

def get_recent_insights_summary(memory):
    """Get summary of recent insights from all bots"""
    recent = memory.get("insights", [])[-3:]
    if not recent:
        return "No recent shared insights"
    
    return "\n".join([f"- {i['bot'].upper()}: {i['insight'][:80]}..." for i in recent])

# ═══════════════════════════════════════════════════════════
# EXPORT FUNCTIONS
# ═══════════════════════════════════════════════════════════

__all__ = [
    'load_shared_memory',
    'save_shared_memory',
    'add_insight',
    'track_topic',
    'get_depth_context',
    'load_global_policy',
    'get_policy_for_bot',
    'generate_depth_prompt'
]

