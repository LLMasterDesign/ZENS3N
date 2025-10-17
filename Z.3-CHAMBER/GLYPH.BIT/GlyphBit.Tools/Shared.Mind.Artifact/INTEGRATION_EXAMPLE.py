"""
▛▞ Shared Mind Integration Example ▞//

Shows exactly how to integrate Shared Mind into any Telegram bot
"""

# ═══════════════════════════════════════════════════════════
# STEP 1: IMPORTS
# ═══════════════════════════════════════════════════════════

import os
import sys
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from openai import OpenAI

# Add _CORE to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '_CORE'))

# SHARED MIND IMPORTS
from shared_mind import (
    generate_depth_prompt,
    add_insight,
    track_topic,
    get_depth_context
)

# ═══════════════════════════════════════════════════════════
# STEP 2: BOT CONFIGURATION
# ═══════════════════════════════════════════════════════════

BOT_NAME = "example_bot"  # Your bot's identifier
client = None  # OpenAI client

SYSTEM_PROMPT = """You are Example Bot - a helpful assistant.

[Your bot's personality and rules here]
"""

# ═══════════════════════════════════════════════════════════
# STEP 3: MESSAGE HANDLER WITH SHARED MIND
# ═══════════════════════════════════════════════════════════

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle incoming messages with Shared Mind depth"""
    user_message = update.message.text
    
    # Initialize conversation history
    if 'messages' not in context.user_data:
        context.user_data['messages'] = []
    
    context.user_data['messages'].append({
        "role": "user",
        "content": user_message
    })
    
    try:
        await update.message.chat.send_action(action="typing")
        
        # ═══ SHARED MIND INTEGRATION START ═══
        
        # Get depth context based on conversation history
        message_count = len(context.user_data['messages'])
        chat_type = update.message.chat.type
        
        # Generate depth-of-field prompt
        depth_context = generate_depth_prompt(
            bot_name=BOT_NAME,
            chat_type=chat_type,
            message_history_count=message_count
        )
        
        # Combine all prompt parts
        full_prompt = SYSTEM_PROMPT + depth_context
        
        # ═══ SHARED MIND INTEGRATION END ═══
        
        # Call OpenAI with enhanced prompt
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": full_prompt},
                *context.user_data['messages']
            ],
            max_tokens=150,
            temperature=0.7
        )
        
        assistant_message = response.choices[0].message.content
        
        # ═══ SHARED MIND STORAGE START ═══
        
        # Store insights for other bots to learn from
        if len(assistant_message) > 100:
            # Extract key insight (usually first sentence or key point)
            key_insight = assistant_message.split('\n\n')[0][:150]
            add_insight(BOT_NAME, key_insight)
        
        # Track topic if identifiable
        # (Optional: extract topic from conversation)
        # track_topic("topic_name", depth_level=message_count // 3)
        
        # ═══ SHARED MIND STORAGE END ═══
        
        context.user_data['messages'].append({
            "role": "assistant",
            "content": assistant_message
        })
        
        await update.message.reply_text(assistant_message, parse_mode='Markdown')
        
    except Exception as e:
        await update.message.reply_text("Error occurred. Please try again.")

# ═══════════════════════════════════════════════════════════
# THAT'S IT! SHARED MIND IS NOW INTEGRATED
# ═══════════════════════════════════════════════════════════

# Your bot now:
# - Gets deeper context as conversations continue
# - Stores insights for sibling bots
# - Learns from other bots' wisdom
# - Automatically escalates depth when needed

def main():
    """Start the bot"""
    global client
    
    # Initialize OpenAI
    client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    
    # Create application
    application = Application.builder().token(os.getenv('TELEGRAM_BOT_TOKEN')).build()
    
    # Register handlers
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    # Start
    application.run_polling(drop_pending_updates=True)

if __name__ == '__main__':
    main()




