"""
▛▞ GROUP MAGIC CONFIGURATION ∎
Chat-level settings + per-bot topic muting - Hybrid Mode
"""

import json
import os
import re

# ═══════════════════════════════════════════════════════════
# GLYPHBIT TRINITY MANIFEST
# ═══════════════════════════════════════════════════════════

GLYPHBIT_ROSTER = {
    "noctua": {
        "name": "NOCTUA",
        "emoji": "🦉",
        "archetype": "Watchful Owl",
        "essence": "Sees deeper patterns in reality, grounded wisdom, names what you're avoiding",
        "token_range": "35-72 (numerology: 9)",
        "aliases": ["noctua", "owl", "🦉"]
    },
    "vulpes": {
        "name": "VULPES",
        "emoji": "🦊",
        "archetype": "Cunning Fox",
        "essence": "Helpful answer + playful jab, goes deep after 3 cycles",
        "token_range": "45-99 (numerology: 9)",
        "aliases": ["vulpes", "fox", "🦊"]
    },
    "trickoon": {
        "name": "TRICKOON",
        "emoji": "🦝",
        "archetype": "Cosmic Trash Mystic",
        "essence": "Edgy spiritual scavenger, cosmic shit-talker, no softening",
        "token_range": "99-144 (numerology: 9)",
        "aliases": ["trickoon", "raccoon", "trash panda", "🦝"]
    }
}

# ═══════════════════════════════════════════════════════════
# CHAT MODES (set by group admin)
# ═══════════════════════════════════════════════════════════

CHAT_MODES = {
    "group": "All bots respond, aware of siblings (default for groups)",
    "inline": "Bots only respond to inline queries (@botname)",
    "live": "All bots respond everywhere, maximum engagement"
}

DEFAULT_CHAT_MODE = "group"

# ═══════════════════════════════════════════════════════════
# STORAGE & PERSISTENCE
# ═══════════════════════════════════════════════════════════

def get_shared_settings_path() -> str:
    """Get path to shared settings file (all bots read this)."""
    bot_dir = os.path.dirname(os.path.abspath(__file__))
    settings_file = os.path.join(bot_dir, "chat_settings.json")
    return settings_file


def load_chat_settings() -> dict:
    """Load all chat settings from shared file."""
    settings_path = get_shared_settings_path()
    try:
        if os.path.exists(settings_path):
            with open(settings_path, 'r') as f:
                return json.load(f)
    except Exception:
        pass
    return {}


def save_chat_settings(settings: dict) -> bool:
    """Save chat settings to shared file (fails gracefully if read-only)."""
    settings_path = get_shared_settings_path()
    try:
        with open(settings_path, 'w') as f:
            json.dump(settings, f, indent=2)
        return True
    except (OSError, IOError, Exception):
        # Silently fail if file system is read-only
        # Mutes will be in-memory only until we fix volume mounts
        return False


def get_chat_mode(chat_id: int) -> str:
    """Get mode for specific chat."""
    settings = load_chat_settings()
    chat_key = str(chat_id)
    return settings.get(chat_key, {}).get("mode", DEFAULT_CHAT_MODE)


def set_chat_mode(chat_id: int, mode: str) -> bool:
    """Set mode for specific chat."""
    if mode not in CHAT_MODES:
        return False
    
    settings = load_chat_settings()
    chat_key = str(chat_id)
    
    if chat_key not in settings:
        settings[chat_key] = {}
    
    settings[chat_key]["mode"] = mode
    return save_chat_settings(settings)


def is_bot_muted(bot_name: str, chat_id: int, topic_id: int = None) -> bool:
    """Check if bot is muted in specific chat/topic."""
    settings = load_chat_settings()
    chat_key = str(chat_id)
    
    if chat_key not in settings:
        return False
    
    mutes = settings[chat_key].get("mutes", {})
    
    # Check topic-specific mute
    if topic_id is not None:
        topic_key = str(topic_id)
        if topic_key in mutes and bot_name in mutes[topic_key]:
            return True
    
    # Check chat-wide mute
    if "all" in mutes and bot_name in mutes["all"]:
        return True
    
    return False


def mute_bot(bot_name: str, chat_id: int, topic_id: int = None) -> bool:
    """Mute bot in specific chat/topic."""
    settings = load_chat_settings()
    chat_key = str(chat_id)
    
    if chat_key not in settings:
        settings[chat_key] = {}
    
    if "mutes" not in settings[chat_key]:
        settings[chat_key]["mutes"] = {}
    
    topic_key = str(topic_id) if topic_id else "all"
    
    if topic_key not in settings[chat_key]["mutes"]:
        settings[chat_key]["mutes"][topic_key] = []
    
    if bot_name not in settings[chat_key]["mutes"][topic_key]:
        settings[chat_key]["mutes"][topic_key].append(bot_name)
    
    return save_chat_settings(settings)


def unmute_bot(bot_name: str, chat_id: int, topic_id: int = None) -> bool:
    """Unmute bot in specific chat/topic."""
    settings = load_chat_settings()
    chat_key = str(chat_id)
    
    if chat_key not in settings:
        return False
    
    mutes = settings[chat_key].get("mutes", {})
    topic_key = str(topic_id) if topic_id else "all"
    
    if topic_key in mutes and bot_name in mutes[topic_key]:
        mutes[topic_key].remove(bot_name)
        return save_chat_settings(settings)
    
    return False


def detect_mute_command(text: str) -> tuple:
    """
    Detect natural language mute commands.
    Returns: (bot_name, action) or (None, None)
    
    Examples:
    - "noctua stop responding" → ("noctua", "mute")
    - "vulpes be quiet" → ("vulpes", "mute")
    - "trickoon come back" → ("trickoon", "unmute")
    """
    text_lower = text.lower()
    
    # Mute patterns
    mute_patterns = [
        r"(noctua|vulpes|trickoon|owl|fox|raccoon)\s+(stop|shut up|quiet|silence|mute|shh|hush)",
        r"(stop|mute|silence)\s+(noctua|vulpes|trickoon|owl|fox|raccoon)",
    ]
    
    # Unmute patterns
    unmute_patterns = [
        r"(noctua|vulpes|trickoon|owl|fox|raccoon)\s+(come back|return|speak|unmute|wake up)",
        r"(unmute|bring back)\s+(noctua|vulpes|trickoon|owl|fox|raccoon)",
    ]
    
    for pattern in mute_patterns:
        match = re.search(pattern, text_lower)
        if match:
            bot_identifier = match.group(1) if match.group(1) in ["noctua", "vulpes", "trickoon", "owl", "fox", "raccoon"] else match.group(2)
            bot_name = resolve_bot_name(bot_identifier)
            if bot_name:
                return (bot_name, "mute")
    
    for pattern in unmute_patterns:
        match = re.search(pattern, text_lower)
        if match:
            bot_identifier = match.group(1) if match.group(1) in ["noctua", "vulpes", "trickoon", "owl", "fox", "raccoon"] else match.group(2)
            bot_name = resolve_bot_name(bot_identifier)
            if bot_name:
                return (bot_name, "unmute")
    
    return (None, None)


def resolve_bot_name(alias: str) -> str:
    """Resolve bot name from alias."""
    alias_lower = alias.lower()
    for bot_id, info in GLYPHBIT_ROSTER.items():
        if alias_lower in info["aliases"]:
            return bot_id
    return None


# ═══════════════════════════════════════════════════════════
# RESPONSE LOGIC
# ═══════════════════════════════════════════════════════════

def should_respond(bot_name: str, update) -> bool:
    """
    HYBRID MODE: Determine if bot should respond.
    
    Logic:
    1. Check if bot is muted in this chat/topic → return False
    2. Check chat mode (group/inline/live)
    3. Respond accordingly with context awareness
    """
    # Handle inline queries first
    if hasattr(update, 'inline_query') and update.inline_query is not None:
        return True  # Always respond to inline queries
    
    # Handle messages
    if not update.message:
        return False
    
    chat_id = update.message.chat.id
    chat_type = update.message.chat.type
    topic_id = getattr(update.message, 'message_thread_id', None)
    
    # Check if muted
    if is_bot_muted(bot_name, chat_id, topic_id):
        return False
    
    # Get chat mode
    mode = get_chat_mode(chat_id) if chat_type in ["group", "supergroup"] else "live"
    
    # Inline mode - don't respond to regular messages
    if mode == "inline":
        return False
    
    # Group mode - respond in groups, DMs, everywhere (unless muted)
    if mode == "group" or mode == "live":
        return True
    
    return True  # Default: respond


def get_sibling_awareness(current_bot: str, chat_type: str) -> str:
    """
    Generate sibling awareness for system prompt.
    Siblings = other GlyphBits in the same chat.
    """
    # Only add sibling awareness in groups
    if chat_type not in ["group", "supergroup"]:
        return ""
    
    siblings = []
    for bot_id, info in GLYPHBIT_ROSTER.items():
        if bot_id != current_bot:
            siblings.append(f"{info['emoji']} **{info['name']}** ({info['archetype']}): {info['essence']}")
    
    if not siblings:
        return ""
    
    return f"""

═══ GROUP AWARENESS ═══
YOU ARE IN A GROUP WITH YOUR GLYPHBIT SIBLINGS:
{chr(10).join(siblings)}

You share this space. Occasionally reference their presence or energy.
You are distinct but aware - like spirits in the same temple.
═══════════════════════════
"""


def format_mode_info(chat_id: int) -> str:
    """Format current chat mode for display."""
    current_mode = get_chat_mode(chat_id)
    
    modes_display = []
    for mode, description in CHAT_MODES.items():
        indicator = "✓" if mode == current_mode else "○"
        modes_display.append(f"{indicator} **{mode}**: {description}")
    
    return f"""
▛▞ CHAT MODE ∎

**Current:** {current_mode}

{chr(10).join(modes_display)}

**Commands:**
• `/mode <mode>` - Change chat mode (admin only)
• `/mute <bot>` - Mute bot in this topic
• `/unmute <bot>` - Unmute bot
• Natural: "noctua stop responding" or "vulpes come back"

**Example:** `/mode live`
"""

