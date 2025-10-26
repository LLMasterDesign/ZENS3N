# 🦉🦊🦝 GLYPHBIT TRINITY - SETUP GUIDE

**Quick setup guide for all three bots**

---

## 📋 PREREQUISITES

1. **Python 3.8+** installed
2. **Telegram account**
3. **OpenAI API key**

---

## 🤖 STEP 1: CREATE TELEGRAM BOTS

### Talk to @BotFather on Telegram:

**For Noctua (Owl):**
```
/newbot
Name: Noctua GlyphBit
Username: noctuabot (or your choice)
```

**For Vulpes (Fox):**
```
/newbot
Name: Vulpes GlyphBit
Username: vulpesbot (or your choice)
```

**For Trickoon (Raccoon):**
```
/newbot
Name: Trickoon GlyphBit
Username: trickoonbot (or your choice)
```

**Enable Inline Mode for Each:**
```
/setinline
[Select bot]
[Enter placeholder text like "Ask wisdom..." or "Get help..."]
```

**Save the bot tokens!** BotFather gives you a token like:
```
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

---

## 🔑 STEP 2: SET UP .ENV FILES

### For Each Bot Folder:

**Noctua.Bit:**
```bash
cd D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit
copy .env.example .env
notepad .env
```

**Vulpes.Bit:**
```bash
cd D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Vulpes.Bit
copy .env.example .env
notepad .env
```

**Trickoon.Bit:**
```bash
cd D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Trickoon.Bit
copy .env.example .env
notepad .env
```

### Edit Each .env File:
Replace the placeholder values with your actual keys:

```env
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxx
```

**⚠️ IMPORTANT:** 
- Each bot needs its **own Telegram token**
- All bots can share the **same OpenAI API key**
- Never commit `.env` files to git (they're in .gitignore)

---

## 📦 STEP 3: INSTALL DEPENDENCIES

### For Each Bot:

```bash
# Noctua
cd D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit
pip install -r requirements.txt

# Vulpes
cd D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Vulpes.Bit
pip install -r requirements.txt

# Trickoon
cd D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Trickoon.Bit
pip install -r requirements.txt
```

**Or install once globally:**
```bash
pip install python-telegram-bot>=21.0 openai>=1.30.0 python-dotenv==1.0.0
```

---

## 🚀 STEP 4: RUN THE BOTS

### Option A: Run All Three (Recommended)
Open 3 terminal windows:

**Terminal 1:**
```bash
D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit\RUN_BOT.bat
```

**Terminal 2:**
```bash
D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Vulpes.Bit\RUN_BOT.bat
```

**Terminal 3:**
```bash
D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Trickoon.Bit\RUN_BOT.bat
```

### Option B: Run One at a Time
Start with Noctua, test it, then add the others:
```bash
D:\!RUNTIME\TELE.PROMPTR\GLYPH.BIT\Noctua.Bit\RUN_BOT.bat
```

---

## ✅ STEP 5: TEST THE BOTS

### In Telegram:

**Test Direct Chat:**
1. Search for your bot (e.g., @noctuabot)
2. Send `/start`
3. Ask a question

**Test Inline Mode:**
1. In any chat, type `@noctuabot test question`
2. Select the result
3. Verify it posts

**Test Commands:**
- `/start` - Welcome message
- `/about` - Bot info
- `/clear` - Reset conversation

---

## 🎭 STEP 6: GROUP CHAT MAGIC (Optional)

### Create a Test Group:
1. Create a new Telegram group
2. Add all three bots as members
3. Give them permission to read messages

### Test Interactions:
```
You: How do I find my purpose?

[All three can respond!]
🦉 Noctua: Wisdom perspective
🦊 Vulpes: Helpful + playful jab
🦝 Trickoon: Spiritual cosmic joke
```

**Pro Tip:** They'll all respond by default. To control this, you can:
- Mention specific bots: "What do you think, @noctuabot?"
- Disable some bots in group settings
- Build smart routing (future enhancement)

---

## 🔧 TROUBLESHOOTING

### "Can't find .env file"
- Make sure you copied `.env.example` to `.env`
- Check you're in the right folder
- File must be named exactly `.env` (not `.env.txt`)

### "Invalid bot token"
- Check for extra spaces in `.env` file
- Verify token from BotFather
- Make sure you used the correct bot's token

### "OpenAI API error"
- Verify your API key is valid
- Check you have credits on OpenAI account
- Ensure no extra spaces in key

### "Module not found"
- Run `pip install -r requirements.txt`
- Check Python is in your PATH
- Try `python -m pip install -r requirements.txt`

### Bot doesn't respond
- Check the bot is running (terminal window open)
- Verify bot token is correct
- Make sure inline mode is enabled (for inline queries)
- Check console for error messages

---

## 📁 FILE STRUCTURE CHECK

Each bot folder should have:
```
BotName.Bit/
├── bot.py              [The code]
├── requirements.txt    [Dependencies]
├── RUN_BOT.bat        [Launch script]
├── .env.example       [Template]
└── .env               [Your keys - YOU CREATE THIS]
```

---

## 🎯 QUICK START CHECKLIST

- [ ] Created 3 bots with @BotFather
- [ ] Saved all 3 bot tokens
- [ ] Got OpenAI API key
- [ ] Copied `.env.example` to `.env` for each bot
- [ ] Filled in bot tokens in each `.env`
- [ ] Filled in OpenAI key in each `.env`
- [ ] Ran `pip install -r requirements.txt`
- [ ] Started Noctua with `RUN_BOT.bat`
- [ ] Tested `/start` command
- [ ] Tested inline mode
- [ ] (Optional) Started Vulpes
- [ ] (Optional) Started Trickoon
- [ ] (Optional) Created group with all three

---

## 💡 TIPS

**Security:**
- Never share your `.env` files
- Don't commit them to git
- Regenerate tokens if exposed

**Development:**
- Test bots one at a time first
- Keep terminal windows open to see logs
- Check for errors in console output

**Organization:**
- Use different Telegram accounts for testing if needed
- Name your bots clearly in BotFather
- Keep notes of which token belongs to which bot

---

## 🚀 YOU'RE READY!

Once all three are running, you have:
- 🦉 Wisdom when you need perspective
- 🦊 Help with a playful nudge
- 🦝 Spiritual exploration with cosmic jokes

**The Trinity is at your command!** ✨

---

**Need Help?** Check the console logs for specific errors or review TRINITY.READY.md for more details.





