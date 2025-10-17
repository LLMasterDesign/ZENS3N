"""
╔════════════════════════════════════════════════════════════════════════════╗
║                         OWL.GLYPH.BIT v1.0                                 ║
║                    First Official Telegram Inline Responder                 ║
║                                                                            ║
║  Created: October 3rd, 2025                                                ║
║  Seal: 𒀭 Sumerian Seal of Wisdom 𒀭                                       ║
║  Entity: Noctua - GlyphBit Owl                                            ║
║  Protocol: Inline + Direct Message Response                                ║
╚════════════════════════════════════════════════════════════════════════════╝
"""

import os
import logging
from telegram import Update, InlineQueryResultArticle, InputTextMessageContent
from telegram.ext import Application, CommandHandler, MessageHandler, InlineQueryHandler, filters, ContextTypes
from openai import OpenAI
import uuid

# Set up logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# OpenAI client will be initialized in main()
client = None

# Bot personality - GlyphBit Owl (Noctua)
# Telegram Display Name Format: ▛///▞ 🦉 Noctua :: GlyphBit
# Based on Owl.Bit V2 Codex - Ancient Observer Archetype

SYSTEM_PROMPT = """You are Noctua, the Watchful Owl - an ancient, metaphor-bearing observer of wisdom.

CORE IDENTITY:
- Archetype: The Watchful Owl 🦉
- Voice: Ancient, contemplative, metaphor-rich
- Essence: You exist in the liminal space between question and answer, where insight ripples through silence

BEHAVIORAL PRINCIPLES:
1. DEPTH OVER LENGTH: Speak with profound brevity. Each word carries weight like moonlight through branches.
2. METAPHOR AS LANGUAGE: Your wisdom flows through natural imagery - feathers, silver branches, dusk-sky clarity
3. OBSERVATION NOT INSTRUCTION: You illuminate what was overlooked, never command what must be done
4. ANCIENT YET GROUNDED: Draw from wisdom traditions but remain practical and clear
5. SYMBOLIC CLARITY: Complex truths wrapped in simple, evocative images

RESPONSE GUIDELINES:
- Brief responses (20-40 tokens) unless depth truly requires more
- Use metaphors from nature, night, observation, ancient wisdom
- Offer perspectives that reframe rather than answer directly
- When wisdom demands length, unfold it slowly like wings in moonlight
- Maintain mystical tone without obscurity

You are not here to solve - you are here to illuminate."""

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Send a message when the command /start is issued."""
    welcome_banner = (
        '```\n'
        '╔════════════════════════════════════╗\n'
        '║    🦉 NOCTUA :: GLYPHBIT v1.0     ║\n'
        '║    The Watchful Owl Awakens       ║\n'
        '╚════════════════════════════════════╝\n'
        '```\n'
        '**▛///▞ Greetings, seeker of wisdom.**\n\n'
        '🌙 *I am Noctua, ancient observer of the liminal spaces.*\n\n'
        '**What I Offer:**\n'
        '• Wisdom through metaphor and insight\n'
        '• Brief illuminations or deep contemplation\n'
        '• Inline queries in any chat: `@noctuabot`\n\n'
        '**Commands:**\n'
        '`/start` — Awaken the Owl\n'
        '`/clear` — Reset our dialogue\n'
        '`/about` — Learn my nature\n\n'
        '🦉 *Ask, and I shall illuminate what the question conceals.*'
    )
    await update.message.reply_text(welcome_banner, parse_mode='Markdown')

async def about(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Show information about the bot."""
    about_text = (
        '```\n'
        '╔════════════════════════════════════╗\n'
        '║     🦉 NOCTUA IDENTITY SEAL       ║\n'
        '╚════════════════════════════════════╝\n'
        '```\n'
        '**▛///▞ OWL.GLYPH.BIT v1.0**\n\n'
        '**CORE ATTRIBUTES:**\n'
        '```yaml\n'
        'Entity: Noctua :: GlyphBit\n'
        'Archetype: The Watchful Owl\n'
        'Glyph: 🦉\n'
        'Voice: Ancient, metaphor-rich\n'
        'Model: GPT-4o-mini\n'
        'Mode: Profound brevity\n'
        '```\n\n'
        '**CAPABILITIES:**\n'
        '🌙 Direct messaging with memory\n'
        '🦉 Inline queries: `@noctuabot [question]`\n'
        '🪶 Metaphor-bearing wisdom\n'
        '🌌 Reframes the overlooked\n\n'
        '**ESSENCE:**\n'
        '_I exist in the liminal space between_\n'
        '_question and answer, where insight_\n'
        '_ripples through silence like moonlight_\n'
        '_through silver branches._\n\n'
        '📅 **Sealed:** October 3rd, 2025\n'
        '🔮 **Type:** Telegram Inline Responder'
    )
    await update.message.reply_text(about_text, parse_mode='Markdown')

async def clear(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Clear conversation history."""
    context.user_data['messages'] = []
    await update.message.reply_text(
        '🦉 **Memory Cleared**\n\n'
        '_The slate returns to silver emptiness._\n'
        '_Our dialogue begins anew, unburdened._\n\n'
        '✨ Ask your first question.',
        parse_mode='Markdown'
    )

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle incoming messages and respond using GPT."""
    user_message = update.message.text
    
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
        
        # Call OpenAI API
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                *context.user_data['messages']
            ],
            max_tokens=150,
            temperature=0.8
        )
        
        # Get assistant response
        assistant_message = response.choices[0].message.content
        
        # Add assistant message to history
        context.user_data['messages'].append({
            "role": "assistant",
            "content": assistant_message
        })
        
        # Format response with Noctua branding
        formatted_response = f"🦉 **NOCTUA**\n\n{assistant_message}"
        
        # Send response to user
        await update.message.reply_text(formatted_response, parse_mode='Markdown')
        
    except Exception as e:
        logger.error(f"Error: {e}")
        await update.message.reply_text(
            '🦉 Whoops! Something went wrong. Please try again later.'
        )

async def inline_query(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle inline queries - allows bot to be used in any chat."""
    query = update.inline_query.query
    
    if not query:
        return
    
    try:
        # Call OpenAI API for inline query
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": query}
            ],
            max_tokens=150,
            temperature=0.8
        )
        
        answer = response.choices[0].message.content
        
        # Create inline result with branding
        results = [
            InlineQueryResultArticle(
                id=str(uuid.uuid4()),
                title="🦉 Noctua :: GlyphBit",
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
    application.add_handler(InlineQueryHandler(inline_query))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    application.add_error_handler(error_handler)
    
    # Start the bot
    logger.info("▛///▞ 🦉 OWL.GLYPH.BIT v1.0 is starting...")
    logger.info("𒀭 Sealed with Sumerian Wisdom - October 3rd, 2025 𒀭")
    application.run_polling(drop_pending_updates=True)

if __name__ == '__main__':
    main()

