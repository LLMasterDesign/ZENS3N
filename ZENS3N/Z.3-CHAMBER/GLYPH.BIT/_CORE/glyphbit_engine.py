"""
╔════════════════════════════════════════════════════════════════════════════╗
║                      GLYPHBIT CORE ENGINE v1.0                             ║
║                    Centralized Bot Logic - Prompt Agnostic                 ║
╚════════════════════════════════════════════════════════════════════════════╝

This engine handles all bot functionality.
Personalities are loaded from external prompt files.
"""

import os
import logging
from pathlib import Path
from telegram import Update, InlineQueryResultArticle, InputTextMessageContent
from telegram.ext import Application, CommandHandler, MessageHandler, InlineQueryHandler, filters, ContextTypes
from openai import OpenAI
import uuid
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class GlyphBitEngine:
    """
    Core engine for all GlyphBit bots.
    Personality is defined by external prompt files.
    """
    
    def __init__(self, config):
        """
        Initialize the GlyphBit engine.
        
        Args:
            config (dict): Configuration with:
                - bot_name: Display name (e.g., "Noctua")
                - bot_glyph: Emoji (e.g., "🦉")
                - prompt_file: Path to system prompt file
                - welcome_banner: Custom welcome message
                - about_text: Custom about text
                - model: OpenAI model (default: gpt-4o-mini)
                - max_tokens: Max response length (default: 150)
                - temperature: Creativity (default: 0.8)
        """
        self.config = config
        self.bot_name = config['bot_name']
        self.bot_glyph = config['bot_glyph']
        self.model = config.get('model', 'gpt-4o-mini')
        self.max_tokens = config.get('max_tokens', 150)
        self.temperature = config.get('temperature', 0.8)
        
        # Load system prompt from file
        self.system_prompt = self._load_prompt(config['prompt_file'])
        
        # Initialize OpenAI client
        self.client = None
        
        # Set up logging
        logging.basicConfig(
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            level=logging.INFO
        )
        self.logger = logging.getLogger(f"{self.bot_name}Bot")
    
    def _load_prompt(self, prompt_file):
        """Load system prompt from external file."""
        prompt_path = Path(prompt_file)
        
        if not prompt_path.exists():
            raise FileNotFoundError(f"Prompt file not found: {prompt_file}")
        
        with open(prompt_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        self.logger.info(f"Loaded prompt from: {prompt_file}")
        return content
    
    def reload_prompt(self):
        """Hot-reload the prompt file without restarting bot."""
        self.system_prompt = self._load_prompt(self.config['prompt_file'])
        self.logger.info("Prompt reloaded!")
    
    async def start_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /start command."""
        welcome = self.config.get('welcome_banner', 
            f"{self.bot_glyph} **{self.bot_name}** is ready!\n\nType a message to begin.")
        await update.message.reply_text(welcome, parse_mode='Markdown')
    
    async def about_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /about command."""
        about = self.config.get('about_text',
            f"{self.bot_glyph} **{self.bot_name}**\n\nA GlyphBit personality.")
        await update.message.reply_text(about, parse_mode='Markdown')
    
    async def clear_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /clear command."""
        context.user_data['messages'] = []
        clear_msg = self.config.get('clear_message',
            f"{self.bot_glyph} **Memory Cleared**\n\nFresh start!")
        await update.message.reply_text(clear_msg, parse_mode='Markdown')
    
    async def reload_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle /reload command - hot reload prompt."""
        try:
            self.reload_prompt()
            await update.message.reply_text(
                f"{self.bot_glyph} **Prompt Reloaded**\n\nPersonality updated!",
                parse_mode='Markdown'
            )
        except Exception as e:
            await update.message.reply_text(f"Error reloading prompt: {e}")
    
    async def handle_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle incoming messages."""
        user_message = update.message.text
        
        # Initialize conversation history
        if 'messages' not in context.user_data:
            context.user_data['messages'] = []
        
        # Add user message to history
        context.user_data['messages'].append({
            "role": "user",
            "content": user_message
        })
        
        try:
            # Send typing action
            await update.message.chat.send_action(action="typing")
            
            # Call OpenAI API
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    *context.user_data['messages']
                ],
                max_tokens=self.max_tokens,
                temperature=self.temperature
            )
            
            # Get assistant response
            assistant_message = response.choices[0].message.content
            
            # Add to history
            context.user_data['messages'].append({
                "role": "assistant",
                "content": assistant_message
            })
            
            # Send response
            await update.message.reply_text(assistant_message, parse_mode='Markdown')
            
        except Exception as e:
            self.logger.error(f"Error: {e}")
            await update.message.reply_text(
                f"{self.bot_glyph} Something went wrong. Try again?"
            )
    
    async def inline_query(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Handle inline queries."""
        query = update.inline_query.query
        
        if not query:
            return
        
        try:
            # Call OpenAI API
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    {"role": "user", "content": query}
                ],
                max_tokens=self.max_tokens,
                temperature=self.temperature
            )
            
            answer = response.choices[0].message.content
            
            # Create inline result
            results = [
                InlineQueryResultArticle(
                    id=str(uuid.uuid4()),
                    title=f"{self.bot_glyph} {self.bot_name}",
                    input_message_content=InputTextMessageContent(answer),
                    description=answer[:100] + "..." if len(answer) > 100 else answer
                )
            ]
            
            await update.inline_query.answer(results, cache_time=10)
            
        except Exception as e:
            self.logger.error(f"Inline query error: {e}")
    
    async def error_handler(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Log errors."""
        self.logger.error(f'Update {update} caused error {context.error}')
    
    def run(self):
        """Start the bot."""
        # Get tokens
        telegram_token = os.getenv('TELEGRAM_BOT_TOKEN')
        openai_key = os.getenv('OPENAI_API_KEY')
        
        if not telegram_token:
            raise ValueError("TELEGRAM_BOT_TOKEN not found in environment")
        
        if not openai_key:
            raise ValueError("OPENAI_API_KEY not found in environment")
        
        # Initialize OpenAI client
        self.client = OpenAI(api_key=openai_key)
        
        # Create application
        application = Application.builder().token(telegram_token).build()
        
        # Register handlers
        application.add_handler(CommandHandler("start", self.start_command))
        application.add_handler(CommandHandler("about", self.about_command))
        application.add_handler(CommandHandler("clear", self.clear_command))
        application.add_handler(CommandHandler("reload", self.reload_command))
        application.add_handler(InlineQueryHandler(self.inline_query))
        application.add_handler(MessageHandler(
            filters.TEXT & ~filters.COMMAND, 
            self.handle_message
        ))
        application.add_error_handler(self.error_handler)
        
        # Start the bot
        self.logger.info(f"{self.bot_glyph} {self.bot_name} starting...")
        application.run_polling(drop_pending_updates=True)


def create_bot_from_config_file(config_file):
    """
    Helper function to create and run a bot from a config file.
    
    Args:
        config_file: Path to JSON or YAML config file
    """
    import json
    
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    engine = GlyphBitEngine(config)
    engine.run()





