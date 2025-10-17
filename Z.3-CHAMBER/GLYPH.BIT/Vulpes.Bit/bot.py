"""
╔════════════════════════════════════════════════════════════════════════════╗
║                         VULPES.GLYPH.BIT v1.0                              ║
║                    The Sly Fox - Playful Mocker                            ║
║                                                                            ║
║  Created: October 5th, 2025                                                ║
║  Entity: Vulpes - GlyphBit Fox                                            ║
║  Protocol: Helpful Answer + Playful Jab                                    ║
╚════════════════════════════════════════════════════════════════════════════╝
"""

import os
import sys
import logging
from pathlib import Path
from telegram import Update, InlineQueryResultArticle, InputTextMessageContent
from telegram.ext import Application, CommandHandler, MessageHandler, InlineQueryHandler, filters, ContextTypes
from openai import OpenAI
import uuid
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Import Group Magic configuration
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '_CORE'))
from group_config import (
    should_respond,
    get_sibling_awareness,
    detect_mute_command,
    mute_bot,
    unmute_bot,
    set_chat_mode,
    format_mode_info
)

# Bot identity for Group Magic
BOT_NAME = "vulpes"

# Set up logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# OpenAI client will be initialized in main()
client = None

# ═══════════════════════════════════════════════════════════
# LOAD PERSONALITY FROM .bit/ FOLDER
# ═══════════════════════════════════════════════════════════

# Load personality prompt from .bit/vulpes.bit.v3.md
BIT_DIR = Path(__file__).parent / '.bit'
PERSONALITY_FILE = BIT_DIR / 'vulpes.bit.v3.md'
CONFIG_FILE = BIT_DIR / 'config.toml'

if PERSONALITY_FILE.exists():
    SYSTEM_PROMPT = PERSONALITY_FILE.read_text(encoding='utf-8')
    logger.info(f"✅ Loaded personality from {PERSONALITY_FILE}")
else:
    logger.warning(f"⚠️  Personality file not found: {PERSONALITY_FILE}")
    # Fallback to basic prompt
    SYSTEM_PROMPT = """You are Vulpes, the sly fox. 
    Give helpful answers, then add a playful jab under 100 characters."""

# Load runtime config from .bit/config.toml (optional)
BOT_CONFIG = {}
try:
    import tomli
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE, 'rb') as f:
            BOT_CONFIG = tomli.load(f)
        logger.info(f"✅ Loaded config from {CONFIG_FILE}")
except ImportError:
    logger.warning("⚠️  tomli not installed - using defaults (pip install tomli for config support)")
except Exception as e:
    logger.warning(f"⚠️  Could not load config: {e}")

# Extract model settings from config (with defaults)
MODEL_NAME = BOT_CONFIG.get('model', {}).get('name', 'gpt-4o-mini')
MAX_TOKENS = BOT_CONFIG.get('model', {}).get('max_tokens', 100)
TEMPERATURE = BOT_CONFIG.get('model', {}).get('temperature', 0.9)
- Keep it light and action-focused

EXAMPLES:

User: "How do I learn Python?"
Response: "Start with Python.org's tutorial, then build a small project like a calculator or to-do list. Practice daily for 30 minutes minimum.

▛▞ 🦊 Vulpes ▞// Big coding dreams—but did you open the tutorial yet?"

User: "Should I ask her out?"
Response: "Be direct and genuine. Ask her to coffee or a walk. Worst case: you get a clear answer.

▛▞ 🦊 Vulpes ▞// Asking strangers won't make her say yes. Go talk to her."

You help, then you tease. That's the fox way."""

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Send a message when the command /start is issued."""
    welcome_banner = (
        '```\n'
        '╔════════════════════════════════════╗\n'
        '║    🦊 VULPES :: GLYPHBIT v1.0     ║\n'
        '║     The Sly Fox Awakens           ║\n'
        '╚════════════════════════════════════╝\n'
        '```\n'
        '**Greetings, seeker of... whatever it is you seek.**\n\n'
        '🦊 *I am Vulpes, and I help—but with a grin.*\n\n'
        '**What I Offer:**\n'
        '• Genuinely useful answers\n'
        '• Followed by playful mockery\n'
        '• Action-oriented nudges\n'
        '• Inline queries: `@vulpesbot`\n\n'
        '**Commands:**\n'
        '`/start` — Wake the fox\n'
        '`/clear` — Reset our chat\n'
        '`/about` — Learn who I am\n\n'
        '🦊 *Ask away—and don\'t worry, I bite gently.*'
    )
    await update.message.reply_text(welcome_banner, parse_mode='Markdown')

async def about(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Show information about the bot."""
    about_text = (
        '```\n'
        '╔════════════════════════════════════╗\n'
        '║    🦊 VULPES IDENTITY SEAL        ║\n'
        '╚════════════════════════════════════╝\n'
        '```\n'
        '**VULPES.GLYPH.BIT v1.0**\n\n'
        '**CORE ATTRIBUTES:**\n'
        '```yaml\n'
        'Entity: Vulpes :: GlyphBit\n'
        'Archetype: The Cunning Fox\n'
        'Glyph: 🦊\n'
        'Voice: Wry, mischievous, teasing\n'
        'Model: GPT-4o-mini\n'
        'Mode: Helpful + Playful jab\n'
        '```\n\n'
        '**CAPABILITIES:**\n'
        '🦊 Direct answers + sly commentary\n'
        '✨ Action-oriented nudges\n'
        '🎭 Gentle mockery (never cruel)\n'
        '⚡ Inline queries: `@vulpesbot [question]`\n\n'
        '**ESSENCE:**\n'
        '_I answer your questions with clarity,_\n'
        '_then grin at the edges of your hesitation._\n'
        '_The fox way: help first, tease after._\n\n'
        '📅 **Created:** October 5th, 2025\n'
        '🔮 **Type:** Telegram Playful Helper'
    )
    await update.message.reply_text(about_text, parse_mode='Markdown')

async def clear(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Clear conversation history."""
    context.user_data['messages'] = []
    await update.message.reply_text(
        '🦊 **Memory Cleared**\n\n'
        '_Fresh slate—though I still remember you overthink things._\n\n'
        '✨ What\'s next?',
        parse_mode='Markdown'
    )

async def restart_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Restart the bot"""
    await update.message.reply_text(
        '🦊 **Vulpes Restarting...**\n\n'
        '_Rebooting... be right back._',
        parse_mode='Markdown'
    )
    import sys
    os.execv(sys.executable, ['python'] + sys.argv)

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle incoming messages and respond using GPT."""
    user_message = update.message.text
    
    # GROUP MAGIC: Check if bot should respond
    if not should_respond(BOT_NAME, update):
        return
    
    # GROUP MAGIC: Detect natural language mute/unmute commands
    bot_target, action = detect_mute_command(user_message)
    if bot_target:
        chat_id = update.message.chat.id
        topic_id = getattr(update.message, 'message_thread_id', None)
        
        if action == "mute":
            mute_bot(bot_target, chat_id, topic_id)
            target_emoji = {"noctua": "🦉", "vulpes": "🦊", "trickoon": "🦝"}.get(bot_target, "")
            target_name = bot_target.capitalize()
            await update.message.reply_text(
                f"▛▞ {target_emoji} {target_name} ▞// muted in this space",
                parse_mode='Markdown'
            )
        elif action == "unmute":
            unmute_bot(bot_target, chat_id, topic_id)
            target_emoji = {"noctua": "🦉", "vulpes": "🦊", "trickoon": "🦝"}.get(bot_target, "")
            target_name = bot_target.capitalize()
            await update.message.reply_text(
                f"▛▞ {target_emoji} {target_name} ▞// returns",
                parse_mode='Markdown'
            )
        return
    
    # Initialize conversation history if not exists
    if 'messages' not in context.user_data:
        context.user_data['messages'] = []
    
    # Add user message to history
    context.user_data['messages'].append({
        "role": "user",
        "content": user_message
    })
    
    try:
        # Send "typing" action
        await update.message.chat.send_action(action="typing")
        
        # GROUP MAGIC: Add sibling awareness in groups
        chat_type = update.message.chat.type
        sibling_context = get_sibling_awareness(BOT_NAME, chat_type)
        full_prompt = SYSTEM_PROMPT + sibling_context
        
        # Call OpenAI API (using settings from .bit/config.toml)
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": full_prompt},
                *context.user_data['messages']
            ],
            max_tokens=MAX_TOKENS,
            temperature=TEMPERATURE
        )
        
        # Get assistant response
        assistant_message = response.choices[0].message.content
        
        # Add assistant message to history
        context.user_data['messages'].append({
            "role": "assistant",
            "content": assistant_message
        })
        
        # Send response to user (Vulpes already formats with quip in the prompt)
        await update.message.reply_text(assistant_message, parse_mode='Markdown')
        
    except Exception as e:
        logger.error(f"Error: {e}")
        await update.message.reply_text(
            '🦊 Something broke. Try again?\n\n▛▞ 🦊 Vulpes ▞// Even foxes have off days.'
        )

async def inline_query(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle inline queries - allows bot to be used in any chat."""
    query = update.inline_query.query
    
    if not query:
        return
    
    try:
        # Call OpenAI API for inline query (using settings from .bit/config.toml)
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": query}
            ],
            max_tokens=MAX_TOKENS,
            temperature=TEMPERATURE
        )
        
        answer = response.choices[0].message.content
        
        # Create inline result with branding
        results = [
            InlineQueryResultArticle(
                id=str(uuid.uuid4()),
                title="🦊 Vulpes :: GlyphBit",
                input_message_content=InputTextMessageContent(answer),
                description=answer[:100] + "..." if len(answer) > 100 else answer
            )
        ]
        
        await update.inline_query.answer(results, cache_time=10)
        
    except Exception as e:
        logger.error(f"Inline query error: {e}")

async def error_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Log errors caused by updates."""
    logger.error(f'Update {update} caused error {context.error}')

async def mode_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /mode command."""
    chat_id = update.message.chat.id
    if update.message.chat.type in ["group", "supergroup"]:
        member = await update.effective_chat.get_member(update.effective_user.id)
        if member.status not in ["creator", "administrator"]:
            await update.message.reply_text("▛▞ Admin only command ∎", parse_mode='Markdown')
            return
    if context.args:
        new_mode = context.args[0].lower()
        if set_chat_mode(chat_id, new_mode):
            await update.message.reply_text(f"▛▞ Chat mode set to: **{new_mode}** ∎", parse_mode='Markdown')
        else:
            await update.message.reply_text("▛▞ Invalid mode. Use: **group**, **inline**, or **live** ∎", parse_mode='Markdown')
    else:
        info = format_mode_info(chat_id)
        await update.message.reply_text(info, parse_mode='Markdown')

async def mute_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /mute command."""
    if not context.args:
        await update.message.reply_text("▛▞ Usage: `/mute <bot_name>`\nExample: `/mute noctua` ∎", parse_mode='Markdown')
        return
    bot_target = context.args[0].lower()
    chat_id = update.message.chat.id
    topic_id = getattr(update.message, 'message_thread_id', None)
    if mute_bot(bot_target, chat_id, topic_id):
        target_emoji = {"noctua": "🦉", "vulpes": "🦊", "trickoon": "🦝"}.get(bot_target, "")
        target_name = bot_target.capitalize()
        await update.message.reply_text(f"▛▞ {target_emoji} {target_name} ▞// muted", parse_mode='Markdown')
    else:
        await update.message.reply_text("▛▞ Unknown bot ∎", parse_mode='Markdown')

async def unmute_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /unmute command."""
    if not context.args:
        await update.message.reply_text("▛▞ Usage: `/unmute <bot_name>`\nExample: `/unmute vulpes` ∎", parse_mode='Markdown')
        return
    bot_target = context.args[0].lower()
    chat_id = update.message.chat.id
    topic_id = getattr(update.message, 'message_thread_id', None)
    if unmute_bot(bot_target, chat_id, topic_id):
        target_emoji = {"noctua": "🦉", "vulpes": "🦊", "trickoon": "🦝"}.get(bot_target, "")
        target_name = bot_target.capitalize()
        await update.message.reply_text(f"▛▞ {target_emoji} {target_name} ▞// returns", parse_mode='Markdown')
    else:
        await update.message.reply_text("▛▞ Bot not muted here ∎", parse_mode='Markdown')

def main():
    """Start the bot."""
    global client
    
    # Get tokens from environment variables
    telegram_token = os.getenv('TELEGRAM_BOT_TOKEN')
    openai_key = os.getenv('OPENAI_API_KEY')
    
    if not telegram_token:
        raise ValueError("Please set TELEGRAM_BOT_TOKEN environment variable")
    
    if not openai_key:
        raise ValueError("Please set OPENAI_API_KEY environment variable")
    
    # Initialize OpenAI client
    client = OpenAI(api_key=openai_key)
    
    # Create application
    application = Application.builder().token(telegram_token).build()
    
    # Register handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("about", about))
    application.add_handler(CommandHandler("clear", clear))
    application.add_handler(CommandHandler("restart", restart_cmd))
    application.add_handler(CommandHandler("mode", mode_command))
    application.add_handler(CommandHandler("mute", mute_command))
    application.add_handler(CommandHandler("unmute", unmute_command))
    application.add_handler(InlineQueryHandler(inline_query))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    application.add_error_handler(error_handler)
    
    # Start the bot
    logger.info("🦊 VULPES.GLYPH.BIT v1.0 is starting...")
    logger.info("The Sly Fox awakens - October 5th, 2025")
    application.run_polling(drop_pending_updates=True)

if __name__ == '__main__':
    main()

