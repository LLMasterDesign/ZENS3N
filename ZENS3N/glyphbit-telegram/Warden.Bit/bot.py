#!/usr/bin/env python3
"""
▛▞ WARDEN :: THE GAME WARDEN ∎
Keeps the wildlife in check - Trinity state manager
"""

import os
import sys
import logging
import json
from pathlib import Path
from datetime import datetime
from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes
from telegram.constants import ChatType
from dotenv import load_dotenv

# Load environment variables
env_path = Path(__file__).parent / '.env'
if env_path.exists():
    load_dotenv(dotenv_path=env_path, override=True)
else:
    load_dotenv()

# Set up logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# ═══════════════════════════════════════════════════════════
# WARDEN'S JURISDICTION
# ═══════════════════════════════════════════════════════════

WILDLIFE = {
    "noctua": {
        "emoji": "🦉",
        "name": "Noctua",
        "species": "Owl",
        "aliases": ["noctua", "owl", "🦉"]
    },
    "vulpes": {
        "emoji": "🦊",
        "name": "Vulpes",
        "species": "Fox",
        "aliases": ["vulpes", "fox", "🦊"]
    },
    "trickoon": {
        "emoji": "🦝",
        "name": "Trickoon",
        "species": "Raccoon",
        "aliases": ["trickoon", "raccoon", "trash panda", "🦝"]
    }
}

def resolve_bot_name(alias: str) -> str:
    """Resolve bot name from alias (e.g., 'fox' -> 'vulpes')"""
    alias_lower = alias.lower().strip()
    for bot_id, info in WILDLIFE.items():
        if alias_lower in info["aliases"]:
            return bot_id
    return None

# Warden's state file (shared volume for Trinity to read)
# In Docker: /app/data (mounted telegram-data volume)
# Local dev: ./data fallback
STATE_DIR = Path("/app/data")
if not STATE_DIR.exists():
    # Fallback for local dev
    STATE_DIR = Path(__file__).parent / 'data'
STATE_DIR.mkdir(exist_ok=True)
STATE_FILE = STATE_DIR / 'warden_state.json'

# ═══════════════════════════════════════════════════════════
# STATE MANAGEMENT
# ═══════════════════════════════════════════════════════════

def load_state():
    """Load Warden's state from file"""
    try:
        if STATE_FILE.exists():
            with open(STATE_FILE, 'r') as f:
                return json.load(f)
    except Exception as e:
        logger.error(f"Error loading state: {e}")
    
    # Default state
    return {
        "muted_bots": {},  # {chat_id: [bot_names]}
        "chat_modes": {},  # {chat_id: mode}
        "activity_log": []
    }

def save_state(state):
    """Save Warden's state to file"""
    try:
        with open(STATE_FILE, 'w') as f:
            json.dump(state, f, indent=2)
        return True
    except Exception as e:
        logger.error(f"Error saving state: {e}")
        return False

def log_action(action, details):
    """Log Warden action"""
    state = load_state()
    state["activity_log"].append({
        "timestamp": datetime.now().isoformat(),
        "action": action,
        "details": details
    })
    # Keep last 100 logs
    state["activity_log"] = state["activity_log"][-100:]
    save_state(state)

# ═══════════════════════════════════════════════════════════
# ADMIN VERIFICATION
# ═══════════════════════════════════════════════════════════

async def is_admin(update: Update) -> bool:
    """Check if user is admin"""
    if update.message.chat.type == ChatType.PRIVATE:
        return True  # Allow in DMs
    
    try:
        member = await update.effective_chat.get_member(update.effective_user.id)
        return member.status in ["creator", "administrator"]
    except Exception:
        return False

# ═══════════════════════════════════════════════════════════
# COMMANDS
# ═══════════════════════════════════════════════════════════

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Welcome message"""
    banner = (
        '🦌 <b>WARDEN :: GAME WARDEN v1.0</b>\n'
        '<i>Wildlife Management System</i>\n\n'
        '<b>Warden reporting for duty.</b>\n\n'
        '<i>I keep the wildlife in check.</i>\n\n'
        '<b>Commands:</b>\n'
        '/warden mute &lt;bot&gt; — Cage a critter\n'
        '/warden unmute &lt;bot&gt; — Release a critter\n'
        '/warden unmute — Release ALL\n'
        '/warden status — Check wildlife\n'
        '/warden mode &lt;mode&gt; — Set chat mode\n'
        '/warden logs — Recent activity\n\n'
        '<b>Wildlife Under Management:</b>\n'
        '🦉 Noctua (Owl)\n'
        '🦊 Vulpes (Fox)\n'
        '🦝 Trickoon (Raccoon)\n\n'
        '🦌 <i>Admin only. Keep \'em orderly.</i>'
    )
    await update.message.reply_text(banner, parse_mode='HTML')

async def warden(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Main warden command handler"""
    if not await is_admin(update):
        await update.message.reply_text(
            "🦌 <b>Warden:</b> Admin credentials required.",
            parse_mode='HTML'
        )
        return
    
    if not context.args:
        await help_command(update, context)
        return
    
    subcommand = context.args[0].lower()
    chat_id = str(update.message.chat.id)
    
    # MUTE
    if subcommand == "mute" and len(context.args) > 1:
        bot_alias = context.args[1].lower()
        bot_name = resolve_bot_name(bot_alias)
        
        if not bot_name:
            await update.message.reply_text(
                f"🦌 <b>Warden:</b> Unknown critter. Try: owl, fox, raccoon",
                parse_mode='HTML'
            )
            return
        
        state = load_state()
        if chat_id not in state["muted_bots"]:
            state["muted_bots"][chat_id] = []
        
        if bot_name not in state["muted_bots"][chat_id]:
            state["muted_bots"][chat_id].append(bot_name)
            save_state(state)
            
            bot = WILDLIFE[bot_name]
            log_action("mute", f"{bot['name']} in chat {chat_id}")
            
            await update.message.reply_text(
                f"🦌 <b>Warden:</b> {bot['emoji']} {bot['name']} caged. Too rowdy.",
                parse_mode='HTML'
            )
        else:
            await update.message.reply_text(
                f"🦌 <b>Warden:</b> Already caged.",
                parse_mode='HTML'
            )
    
    # UNMUTE
    elif subcommand == "unmute" and len(context.args) > 1:
        bot_alias = context.args[1].lower()
        bot_name = resolve_bot_name(bot_alias)
        
        if not bot_name:
            await update.message.reply_text(
                f"🦌 <b>Warden:</b> Unknown critter. Try: owl, fox, raccoon",
                parse_mode='HTML'
            )
            return
        
        state = load_state()
        if chat_id in state["muted_bots"] and bot_name in state["muted_bots"][chat_id]:
            state["muted_bots"][chat_id].remove(bot_name)
            if not state["muted_bots"][chat_id]:
                del state["muted_bots"][chat_id]
            save_state(state)
            
            bot = WILDLIFE[bot_name]
            log_action("unmute", f"{bot['name']} in chat {chat_id}")
            
            await update.message.reply_text(
                f"🦌 <b>Warden:</b> {bot['emoji']} {bot['name']} released. Good behavior.",
                parse_mode='HTML'
            )
        else:
            await update.message.reply_text(
                f"🦌 <b>Warden:</b> That one's already loose.",
                parse_mode='HTML'
            )
    
    # UNMUTE ALL
    elif subcommand == "unmute" and len(context.args) == 1:
        state = load_state()
        if chat_id in state["muted_bots"] and state["muted_bots"][chat_id]:
            count = len(state["muted_bots"][chat_id])
            del state["muted_bots"][chat_id]
            save_state(state)
            log_action("unmute_all", f"Released all {count} bots in chat {chat_id}")
            
            await update.message.reply_text(
                f"🦌 <b>Warden:</b> All wildlife released. {count} critters freed.",
                parse_mode='HTML'
            )
        else:
            await update.message.reply_text(
                f"🦌 <b>Warden:</b> No one's caged here.",
                parse_mode='HTML'
            )
    
    # STATUS
    elif subcommand == "status":
        state = load_state()
        muted = state["muted_bots"].get(chat_id, [])
        
        status_lines = ["<b>🦌 Wildlife Status Report:</b>\n"]
        for bot_id, bot in WILDLIFE.items():
            if bot_id in muted:
                status_lines.append(f"{bot['emoji']} {bot['name']} — <b>CAGED</b> 🔒")
            else:
                status_lines.append(f"{bot['emoji']} {bot['name']} — <b>ACTIVE</b> ✅")
        
        mode = state["chat_modes"].get(chat_id, "group")
        status_lines.append(f"\n<b>Chat Mode:</b> {mode}")
        
        await update.message.reply_text(
            "\n".join(status_lines),
            parse_mode='HTML'
        )
    
    # MODE
    elif subcommand == "mode" and len(context.args) > 1:
        mode = context.args[1].lower()
        valid_modes = ["group", "inline", "live"]
        
        if mode not in valid_modes:
            await update.message.reply_text(
                f"🦌 <b>Warden:</b> Invalid mode. Use: group, inline, or live",
                parse_mode='HTML'
            )
            return
        
        state = load_state()
        state["chat_modes"][chat_id] = mode
        save_state(state)
        log_action("mode_change", f"Chat {chat_id} set to {mode}")
        
        await update.message.reply_text(
            f"🦌 <b>Warden:</b> Chat mode set to <b>{mode}</b>.",
            parse_mode='HTML'
        )
    
    # LOGS
    elif subcommand == "logs":
        state = load_state()
        recent_logs = state["activity_log"][-10:]
        
        if not recent_logs:
            await update.message.reply_text(
                "🦌 <b>Warden:</b> No recent activity.",
                parse_mode='HTML'
            )
            return
        
        log_lines = ["<b>🦌 Recent Activity:</b>\n"]
        for log in recent_logs:
            time = log["timestamp"].split("T")[1][:8]
            log_lines.append(f"<code>{time}</code> {log['action']}: {log['details']}")
        
        await update.message.reply_text(
            "\n".join(log_lines),
            parse_mode='HTML'
        )
    
    else:
        await help_command(update, context)

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Show help"""
    help_text = (
        "<b>🦌 Warden Commands:</b>\n\n"
        "/warden mute &lt;bot&gt; — Cage a critter\n"
        "/warden unmute &lt;bot&gt; — Release a critter\n"
        "/warden unmute — Release ALL critters\n"
        "/warden status — Check wildlife\n"
        "/warden mode &lt;group|inline|live&gt; — Set chat mode\n"
        "/warden logs — Recent activity\n\n"
        "<b>Bots:</b> owl, fox, raccoon"
    )
    await update.message.reply_text(help_text, parse_mode='HTML')

# ═══════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════

def main():
    """Start the Warden"""
    telegram_token = os.getenv('TELEGRAM_BOT_TOKEN')
    
    if not telegram_token:
        raise ValueError("Please set TELEGRAM_BOT_TOKEN in .env")
    
    # Create application
    application = Application.builder().token(telegram_token).build()
    
    # Register handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("warden", warden))
    application.add_handler(CommandHandler("help", help_command))
    
    # Start the bot
    logger.info("🦌 WARDEN.GLYPH.BIT v1.0 - Wildlife Management System starting...")
    logger.info("Game Warden on duty - Keeping the critters in check")
    application.run_polling(drop_pending_updates=True)

if __name__ == '__main__':
    main()

