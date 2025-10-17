#!/usr/bin/env python3
"""
▛▞ WARDEN STATE READER ∎
Allows Trinity bots to check Warden's state for group modes and mute status
"""

import json
from pathlib import Path
from typing import Dict, List, Optional

# Warden's state file location (shared volume)
WARDEN_STATE_FILE = Path("/app/telegram-data/warden_state.json")

def load_warden_state() -> Dict:
    """Load Warden's state from file"""
    try:
        if WARDEN_STATE_FILE.exists():
            with open(WARDEN_STATE_FILE, 'r') as f:
                return json.load(f)
    except Exception:
        pass
    
    # Default state if file doesn't exist or can't be read
    return {
        "muted_bots": {},
        "chat_modes": {},
        "activity_log": []
    }

def get_chat_mode(chat_id: str) -> str:
    """
    Get the chat mode for a specific chat
    
    Returns:
        'group' (default), 'inline', or 'live'
    """
    state = load_warden_state()
    return state.get("chat_modes", {}).get(chat_id, "group")

def is_bot_muted(bot_name: str, chat_id: str) -> bool:
    """
    Check if a bot is muted in a specific chat
    
    Args:
        bot_name: Bot identifier (e.g., 'noctua', 'vulpes', 'trickoon')
        chat_id: The chat ID to check
    
    Returns:
        True if bot is muted, False otherwise
    """
    state = load_warden_state()
    muted_in_chat = state.get("muted_bots", {}).get(chat_id, [])
    return bot_name.lower() in muted_in_chat

def should_respond(
    bot_name: str,
    chat_id: str,
    chat_type: str,
    is_mentioned: bool = False
) -> bool:
    """
    Determine if bot should respond based on Warden's rules
    
    Args:
        bot_name: Bot identifier (e.g., 'noctua', 'vulpes', 'trickoon')
        chat_id: The chat ID
        chat_type: 'private' or 'group'/'supergroup'
        is_mentioned: Whether bot was explicitly mentioned
    
    Returns:
        True if bot should respond, False otherwise
    """
    # Always respond in private chats
    if chat_type == "private":
        return True
    
    # Check if muted
    if is_bot_muted(bot_name, chat_id):
        return False
    
    # Get chat mode
    mode = get_chat_mode(chat_id)
    
    # Apply mode logic
    if mode == "inline":
        # Only respond if mentioned
        return is_mentioned
    elif mode == "live":
        # Always respond (most active)
        return True
    else:  # mode == "group" (default)
        # Respond normally (current behavior)
        return True

