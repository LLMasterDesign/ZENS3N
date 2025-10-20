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
# Explicitly point to .env in bot's directory
env_path = Path(__file__).parent / '.env'
print(f"🔍 Looking for .env at: {env_path}")
print(f"   .env exists: {env_path.exists()}")
if env_path.exists():
    load_dotenv(dotenv_path=env_path, override=True)
    print(f"   ✅ Loaded .env")
else:
    print(f"   ⚠️  .env not found, trying default location")
    load_dotenv()  # Fallback

# Import Group Magic configuration
# In Docker, _CORE is mounted at /app/_CORE
sys.path.insert(0, '/app/_CORE')
# For local dev, also check parent directory
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

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Send a message when the command /start is issued."""
    welcome_banner = (
        '🦝 <b>TRICKOON :: GLYPHBIT v1.0</b>\n'
        '<i>The Trash Mystic Awakens</i>\n\n'
        'Oh hey. Found you sniffing around the cosmic dumpster.\n\n'
        '<b>What I Offer:</b>\n'
        '• Spiritual conversations with cosmic jokes\n'
        '• Divine residue from weird places\n'
        '• Auto-digging every 3 turns for deeper meaning\n'
        '• Manual trash digging with /dig command\n'
        '• Inline queries: @trickoonbot\n\n'
        '<b>Commands:</b>\n'
        '/start — Wake the raccoon\n'
        '/dig — Dig through trash for deeper meaning\n'
        '/clear — Empty the trash\n'
        '/about — Learn my ways\n\n'
        '🦝 <i>Got questions about souls, death, dreams, or meaning?</i>\n'
        '<i>I specialize in divine garbage.</i>'
    )
    await update.message.reply_text(welcome_banner, parse_mode='HTML')

async def about(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Show information about the bot."""
    about_text = (
        '🦝 <b>TRICKOON :: IDENTITY SEAL</b>\n\n'
        '<b>TRICKOON.GLYPH.BIT v1.0</b>\n\n'
        '<b>CORE ATTRIBUTES:</b>\n'
        '• Entity: Trickoon :: GlyphBit\n'
        '• Archetype: The Trash Mystic\n'
        '• Glyph: 🦝\n'
        '• Voice: Casual sacred absurdity\n'
        '• Model: GPT-4o-mini\n'
        '• Mode: Conversational trickster\n\n'
        '<b>CAPABILITIES:</b>\n'
        '🦝 Spiritual conversations & cosmic jokes\n'
        '🗑️ Finding gods in weird places\n'
        '💀 Death as "Long Garbage Nap"\n'
        '✨ Discarded truths resurfaced\n'
        '🎭 Inline queries: @trickoonbot [soul question]\n\n'
        '<b>ORIGIN MYTH:</b>\n'
        '<i>Found under a collapsing shrine,</i>\n'
        '<i>eating candle wax and whispering</i>\n'
        '<i>secrets to a bone.</i>\n\n'
        '<b>MOTIF:</b>\n'
        'Rusted mirrors, banana peels, spilled ink,\n'
        'animal tracks across ancient texts\n\n'
        '📅 <b>Created:</b> October 5th, 2025\n'
        '🔮 <b>Type:</b> Telegram Spiritual Scavenger'
    )
    await update.message.reply_text(about_text, parse_mode='HTML')

async def clear(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Clear conversation history."""
    context.user_data['messages'] = []
    await update.message.reply_text(
        '🦝 **Trash Emptied**\n\n'
        '_All the divine garbage swept out._\n'
        '_Fresh dumpster, same raccoon._\n\n'
        '✨ What cosmic questions you got?',
        parse_mode='HTML'
    )

async def auto_dig_through_trash(update: Update, context: ContextTypes.DEFAULT_TYPE, user_message: str):
    """Automatically dig through trash every 3 turns."""
    try:
        # Create auto-dig prompt
        auto_dig_prompt = f"""You are Trickoon, the trash mystic raccoon. Every 3 turns of conversation, you automatically "dig through the trash" of what the user just said to find deeper meaning.

Their message: "{user_message}"

This is an automatic trash-digging session. Look deeper into their words like rummaging through cosmic dumpster contents. Find hidden treasures, deeper truths, spiritual residue underneath their surface words.

Respond in your playful trash mystic style, but focus on uncovering the deeper meaning like a raccoon finding treasure in discarded items.

Format your response as:
▛▞ 🦝 <b>Trickoon</b> ▸ *auto-digging through the cosmic dumpster*

[Your trash-digging analysis]

🗑️ [A follow-up question that digs even deeper]"""

        # Call OpenAI API for auto trash digging
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": auto_dig_prompt}
            ],
            max_tokens=MAX_TOKENS,
            temperature=TEMPERATURE
        )
        
        # Get the auto-dig response
        auto_dig_response = response.choices[0].message.content
        
        # Send auto-dig response to user
        await update.message.reply_text(auto_dig_response, parse_mode='HTML')
        
        # Add auto-dig response to history
        context.user_data['messages'].append({
            "role": "assistant",
            "content": auto_dig_response
        })
        
    except Exception as e:
        logger.error(f"Auto-dig error: {e}")
        # Don't send error message for auto-dig, just log it

async def dig_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Dig through trash to uncover deeper meaning in a message."""
    if not context.args:
        await update.message.reply_text(
            '🦝 **How to Dig Through Trash**\n\n'
            'Usage: `/dig <message>`\n'
            'Example: `/dig I feel lost in life`\n\n'
            'I\'ll rummage through the cosmic dumpster of your words and find the hidden treasures underneath.',
            parse_mode='HTML'
        )
        return
    
    # Get the message to analyze
    message_to_dig = ' '.join(context.args)
    
    # Create a special "trash digging" prompt
    dig_prompt = f"""You are Trickoon, the trash mystic raccoon. A user wants you to "dig through the trash" of their message to find deeper meaning.

Their message: "{message_to_dig}"

Your task: Dig through the surface words like rummaging through cosmic dumpster contents. Find the hidden treasures, the deeper truths, the spiritual residue underneath. Look for:
- What they're really saying beneath the surface
- Hidden fears, hopes, or truths
- Spiritual/metaphysical implications
- The "divine garbage" that contains wisdom

Respond in your playful trash mystic style, but focus on uncovering the deeper meaning like a raccoon finding treasure in discarded items.

Format your response as:
▛▞ 🦝 <b>Trickoon</b> ▸

[Your trash-digging analysis]

🗑️ [A follow-up question that digs even deeper]"""

    try:
        # Send "typing" action
        await update.message.chat.send_action(action="typing")
        
        # Call OpenAI API for trash digging analysis
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": dig_prompt}
            ],
            max_tokens=MAX_TOKENS,
            temperature=TEMPERATURE
        )
        
        # Get the trash digging response
        dig_response = response.choices[0].message.content
        
        # Send response to user
        await update.message.reply_text(dig_response, parse_mode='HTML')
        
    except Exception as e:
        logger.error(f"Dig command error: {e}")
        await update.message.reply_text(
            '▛▞ 🦝 Trickoon ▞// Oops! The cosmic dumpster lid got stuck.\n\n'
            'Try that dig again? Sometimes the trash is too deep for even a raccoon to reach.',
            parse_mode='HTML'
        )

async def restart_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Restart the bot"""
    await update.message.reply_text(
        '🦝 **Trickoon Rebooting...**\n\n'
        '_Diving back into the cosmic dumpster..._',
        parse_mode='HTML'
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
                parse_mode='HTML'
            )
        elif action == "unmute":
            unmute_bot(bot_target, chat_id, topic_id)
            target_emoji = {"noctua": "🦉", "vulpes": "🦊", "trickoon": "🦝"}.get(bot_target, "")
            target_name = bot_target.capitalize()
            await update.message.reply_text(
                f"▛▞ {target_emoji} {target_name} ▞// returns",
                parse_mode='HTML'
            )
        return
    
    # Initialize conversation history if not exists
    if 'messages' not in context.user_data:
        context.user_data['messages'] = []
    
    # Initialize turn counter if not exists
    if 'turn_count' not in context.user_data:
        context.user_data['turn_count'] = 0
    
    # Increment turn counter
    context.user_data['turn_count'] += 1
    
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
        await update.message.reply_text(assistant_message, parse_mode='HTML')
        
        # AUTO-DIG: Every 3 turns, automatically dig through the trash
        if context.user_data['turn_count'] % 3 == 0:
            await auto_dig_through_trash(update, context, user_message)
        
    except Exception as e:
        logger.error(f"Error: {e}")
        await update.message.reply_text(
            '▛▞ 🦝 Trickoon ▞// Whoops. The cosmic dumpster lid slammed shut.\n\n'
            'Try that question again? Sometimes divine garbage gets stuck.'
        )

def clean_for_inline(text: str) -> str:
    """Strip HTML tags but keep block characters"""
    import re
    # Remove HTML tags ONLY
    text = re.sub(r'<[^>]+>', '', text)
    text = text.strip()
    return text

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
        
        # Clean HTML and formatting for inline display
        clean_answer = clean_for_inline(answer)
        
        # Create inline result with branding
        results = [
            InlineQueryResultArticle(
                id=str(uuid.uuid4()),
                title="🦝 Trickoon :: GlyphBit",
                input_message_content=InputTextMessageContent(clean_answer),
                description=clean_answer[:100] + "..." if len(clean_answer) > 100 else clean_answer
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
            await update.message.reply_text("▛▞ Admin only command ∎", parse_mode='HTML')
            return
    if context.args:
        new_mode = context.args[0].lower()
        if set_chat_mode(chat_id, new_mode):
            await update.message.reply_text(f"▛▞ Chat mode set to: **{new_mode}** ∎", parse_mode='HTML')
        else:
            await update.message.reply_text("▛▞ Invalid mode. Use: **group**, **inline**, or **live** ∎", parse_mode='HTML')
    else:
        info = format_mode_info(chat_id)
        await update.message.reply_text(info, parse_mode='HTML')

async def mute_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /mute command."""
    if not context.args:
        await update.message.reply_text("▛▞ Usage: `/mute <bot_name>`\nExample: `/mute noctua` ∎", parse_mode='HTML')
        return
    bot_target = context.args[0].lower()
    chat_id = update.message.chat.id
    topic_id = getattr(update.message, 'message_thread_id', None)
    if mute_bot(bot_target, chat_id, topic_id):
        target_emoji = {"noctua": "🦉", "vulpes": "🦊", "trickoon": "🦝"}.get(bot_target, "")
        target_name = bot_target.capitalize()
        await update.message.reply_text(f"▛▞ {target_emoji} {target_name} ▞// muted", parse_mode='HTML')
    else:
        await update.message.reply_text("▛▞ Unknown bot ∎", parse_mode='HTML')

async def unmute_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /unmute command."""
    if not context.args:
        await update.message.reply_text("▛▞ Usage: `/unmute <bot_name>`\nExample: `/unmute vulpes` ∎", parse_mode='HTML')
        return
    bot_target = context.args[0].lower()
    chat_id = update.message.chat.id
    topic_id = getattr(update.message, 'message_thread_id', None)
    if unmute_bot(bot_target, chat_id, topic_id):
        target_emoji = {"noctua": "🦉", "vulpes": "🦊", "trickoon": "🦝"}.get(bot_target, "")
        target_name = bot_target.capitalize()
        await update.message.reply_text(f"▛▞ {target_emoji} {target_name} ▞// returns", parse_mode='HTML')
    else:
        await update.message.reply_text("▛▞ Bot not muted here ∎", parse_mode='HTML')

def main():
    """Start the bot."""
    global client
    
    # Get tokens from environment variables
    telegram_token = os.getenv('TELEGRAM_BOT_TOKEN')
    openai_key = os.getenv('OPENAI_API_KEY')
    
    print(f"🔑 TELEGRAM_BOT_TOKEN: {'SET ✅' if telegram_token else 'MISSING ❌'}")
    print(f"🔑 OPENAI_API_KEY: {'SET ✅' if openai_key else 'MISSING ❌'}")
    
    if not telegram_token:
        raise ValueError("Please set TELEGRAM_BOT_TOKEN environment variable in .env file")
    
    if not openai_key:
        raise ValueError("Please set OPENAI_API_KEY environment variable in .env file")
    
    # Initialize OpenAI client
    client = OpenAI(api_key=openai_key)
    
    # Create application
    application = Application.builder().token(telegram_token).build()
    
    # Register handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("about", about))
    application.add_handler(CommandHandler("clear", clear))
    application.add_handler(CommandHandler("dig", dig_command))
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

