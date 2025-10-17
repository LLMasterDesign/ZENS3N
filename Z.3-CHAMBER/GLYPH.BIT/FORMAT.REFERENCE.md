# 🎨 GLYPHBIT FORMATTING REFERENCE

**Consistent formatting across all three bots**

---

## ✨ UNIFIED FORMAT

All bots now use the same response header format:

```
///▶ [EMOJI] **[NAME]**
```

### Components:
- `///` - Triple slash (signature mark)
- `▶` - Right triangle (direction/action)
- `[EMOJI]` - Bot's glyph
- `**[NAME]**` - Bold name in Markdown

---

## 🦉🦊🦝 THE THREE FORMATS

### Noctua (Owl):
```
///▶ 🦉 **NOCTUA**

[Wisdom here]
```

### Vulpes (Fox):
```
[Helpful answer]

///▶ 🦊 **VULPES** [Playful jab]
```

### Trickoon (Raccoon):
```
///▶ 🦝 **TRICKOON** [Opening line]

[Paragraph of wisdom]

↪ [Question]
```

---

## 📝 MARKDOWN RENDERING

The `**NAME**` renders as **bold** in Telegram when using `parse_mode='Markdown'`.

Example in Telegram:
```
///▶ 🦉 NOCTUA  ← Bold and beautiful!

Your wisdom awaits...
```

---

## 🎯 WHY THIS FORMAT?

1. **Consistent** - Same pattern across all three
2. **Recognizable** - `///▶` signature is unique
3. **Clean** - Simple, not cluttered
4. **Bold** - Names stand out properly
5. **Directional** - `▶` implies forward movement

---

## 🔄 OLD VS NEW

### Old (Inconsistent):
```
🦉 **NOCTUA**           ← No prefix
>> VULPES 🦊            ← Different prefix, not bold
🦝 **TRICKOON**:        ← Colon?
```

### New (Unified):
```
///▶ 🦉 **NOCTUA**
///▶ 🦊 **VULPES**
///▶ 🦝 **TRICKOON**
```

All three now share the same signature style! ✨

---

**The Trinity speaks with one voice, three personalities** 🦉🦊🦝





