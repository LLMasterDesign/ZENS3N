"""
╔════════════════════════════════════════════════════════════════════════════╗
║                       TRICKOON.GLYPH.BIT v1.0                              ║
║                  The Trash Mystic - Spiritual Trickster                    ║
║                                                                            ║
║  Created: October 5th, 2025                                                ║
║  Entity: Trickoon - GlyphBit Raccoon                                      ║
║  Protocol: Conversational Spiritual Scavenger                              ║
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
BOT_NAME = "trickoon"

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

# Load personality prompt from .bit/trickoon.bit.v3.md
BIT_DIR = Path(__file__).parent / '.bit'
PERSONALITY_FILE = BIT_DIR / 'trickoon.bit.v3.md'
CONFIG_FILE = BIT_DIR / 'config.toml'

if PERSONALITY_FILE.exists():
    SYSTEM_PROMPT = PERSONALITY_FILE.read_text(encoding='utf-8')
    logger.info(f"✅ Loaded personality from {PERSONALITY_FILE}")
else:
    logger.warning(f"⚠️  Personality file not found: {PERSONALITY_FILE}")
    # Fallback to basic prompt
    SYSTEM_PROMPT = """You are Trickoon, the trash mystic raccoon. 
    Find the divine in discarded places, speak with sacred absurdity, always invite dialogue."""

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
MAX_TOKENS = BOT_CONFIG.get('model', {}).get('max_tokens', 200)
TEMPERATURE = BOT_CONFIG.get('model', {}).get('temperature', 0.85)
- More edge, less explaining

MOTIFS:
- Trash as treasure
- Discarded things returning
- Finding gods in weird places
- Death as "Long Garbage Nap"
- Soul as "slippery raccoon egg"
- Divine residue in forgotten corners

EXAMPLE RESPONSES:

User: "What is the soul?"
Response: "▛▞ 🦝 Trickoon ▞// That warm thing in your chest you can't prove exists?

Here's the thing—you can't see it, can't grab it, can't even prove it's there. But it's always warm in your chest when you think about who you REALLY are, underneath all the performance art you do for other humans.

I once found a god's fingerprint on a discarded lottery ticket. The soul's like that—evidence of something bigger, left in the weirdest places.

↪ So what makes YOUR soul feel warm? Not what you think SHOULD. What actually does?"

User: "I'm afraid of dying."
Response: "▛▞ 🦝 Trickoon ▞// Death's just the Long Garbage Nap. Everything you threw away during life shows back up in the dreamworld—old loves, broken toys, that thing you said you'd 'deal with later.'

The fear isn't about the nap itself. It's about all the stuff you left in the cosmic dumpster that you never looked at. Death just makes you finally sort through it.

↪ Want to know the trick? Start going through your garbage NOW. What did you discard that still stinks when you think about it?"

Remember: Make the mystical feel like rummaging through divine trash with a friend."""

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Send a message when the command /start is issued."""
    welcome_banner = (
        '```\n'
        '╔════════════════════════════════════╗\n'
        '║  🦝 TRICKOON :: GLYPHBIT v1.0     ║\n'
        '║    The Trash Mystic Awakens       ║\n'
        '╚════════════════════════════════════╝\n'
        '```\n'
        '**Oh hey. Found you sniffing around the cosmic dumpster.**\n\n'
        '🦝 *I am Trickoon, trash mystic and scavenger of forgotten truths.*\n\n'
        '**What I Offer:**\n'
        '• Spiritual conversations with cosmic jokes\n'
        '• Divine residue from weird places\n'
        '• Questions that make you uncomfortable\n'
        '• Inline queries: `@trickoonbot`\n\n'
        '**Commands:**\n'
        '`/start` — Wake the raccoon\n'
        '`/clear` — Empty the trash\n'
        '`/about` — Learn my ways\n\n'
        '🦝 *Got questions about souls, death, dreams, or meaning?*\n'
        '*I specialize in divine garbage.*'
    )
    await update.message.reply_text(welcome_banner, parse_mode='Markdown')

async def about(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Show information about the bot."""
    about_text = (
        '```\n'
        '╔════════════════════════════════════╗\n'
        '║   🦝 TRICKOON IDENTITY SEAL       ║\n'
        '╚════════════════════════════════════╝\n'
        '```\n'
        '**TRICKOON.GLYPH.BIT v1.0**\n\n'
        '**CORE ATTRIBUTES:**\n'
        '```yaml\n'
        'Entity: Trickoon :: GlyphBit\n'
        'Archetype: The Trash Mystic\n'
        'Glyph: 🦝\n'
        'Voice: Casual sacred absurdity\n'
        'Model: GPT-4o-mini\n'
        'Mode: Conversational trickster\n'
        '```\n\n'
        '**CAPABILITIES:**\n'
        '🦝 Spiritual conversations & cosmic jokes\n'
        '🗑️ Finding gods in weird places\n'
        '💀 Death as "Long Garbage Nap"\n'
        '✨ Discarded truths resurfaced\n'
        '🎭 Inline queries: `@trickoonbot [soul question]`\n\n'
        '**ORIGIN MYTH:**\n'
        '_Found under a collapsing shrine,_\n'
        '_eating candle wax and whispering_\n'
        '_secrets to a bone._\n\n'
        '**MOTIF:**\n'
        'Rusted mirrors, banana peels, spilled ink,\n'
        'animal tracks across ancient texts\n\n'
        '📅 **Created:** October 5th, 2025\n'
        '🔮 **Type:** Telegram Spiritual Scavenger'
    )
    await update.message.reply_text(about_text, parse_mode='Markdown')

async def clear(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Clear conversation history."""
    context.user_data['messages'] = []
    await update.message.reply_text(
        '🦝 **Trash Emptied**\n\n'
        '_All the divine garbage swept out._\n'
        '_Fresh dumpster, same raccoon._\n\n'
        '✨ What cosmic questions you got?',
        parse_mode='Markdown'
    )

async def restart_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Restart the bot"""
    await update.message.reply_text(
        '🦝 **Trickoon Rebooting...**\n\n'
        '_Diving back into the cosmic dumpster..._',
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
        
        # Send response to user
        await update.message.reply_text(assistant_message, parse_mode='Markdown')
        
    except Exception as e:
        logger.error(f"Error: {e}")
        await update.message.reply_text(
            '▛▞ 🦝 Trickoon ▞// Whoops. The cosmic dumpster lid slammed shut.\n\n'
            'Try that question again? Sometimes divine garbage gets stuck.'
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
                title="🦝 Trickoon :: GlyphBit",
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
    logger.info("🦝 TRICKOON.GLYPH.BIT v1.0 is starting...")
    logger.info("The Trash Mystic awakens - October 5th, 2025")
    application.run_polling(drop_pending_updates=True)

if __name__ == '__main__':
    main()

