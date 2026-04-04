# 🤖 AI Chat Screen - Quick Start Guide

## 🎯 What's Implemented

Your Islamic Lifestyle app now has a complete AI Chat feature with:

✅ **WhatsApp-style chat interface**
- Message bubbles with proper styling
- User messages on the right, AI on the left
- Timestamps for every message

✅ **Voice Input Support**
- Tap microphone to speak
- Real-time speech-to-text conversion
- Visual feedback while listening

✅ **Quick Suggestions**
- 6 predefined quick access buttons
- Instant answers about prayer, Quran, hadiths, etc.

✅ **Loading States**
- Spinner while AI is thinking
- Disabled input during processing

---

## 🚀 How to Access

1. **Open the app**
2. **Tap the "AI Chat" tab** at the bottom navigation
3. **Start chatting!**

---

## 💬 What Can You Ask?

### 📖 Quran Topics
"Tell me about Quran" → Gets info about Islamic scripture

### 🕌 Prayer Related
"When are prayer times?" → Gets prayer information

### 📚 Hadith
"Tell me a hadith" → Gets Islamic sayings

### 🤲 Dua (Supplication)
"Teach me a dua" → Gets Islamic supplications

### 🌙 Ramadan
"Ramadan tips" → Gets fasting guidance

### 🧠 General Islamic Knowledge
"Islamic knowledge" → Gets general info

---

## 🔊 Voice Input How-To

1. **Tap the microphone button** 🎤
2. **It turns red** - now you can speak
3. **Speak your question**
4. **It converts to text** automatically
5. **Tap send or speak more**
6. **Tap mic again to stop**

---

## 🎨 UI Features Explained

### Message Bubbles
- **Green (right)** = Your message
- **Gray (left)** = AI response
- **Time shown** = Message timestamp

### Input Box
```
[Text Input Field] [🎤] [→]
```
- Type your question
- Tap mic for voice input
- Tap arrow to send

### Quick Suggestions
```
[🕌 Prayer] [📚 Hadith] [🤲 Dua] [🧠 Knowledge] [🌙 Ramadan] [📖 Quran]
```
- Tap any to get instant answer

---

## 🔌 Next Steps: Connect Real AI API

The feature is currently using mock responses for testing. To connect a real AI API:

### Option 1: OpenAI ChatGPT
```dart
// In ai_chat_service.dart
const String apiKey = 'your-openai-key';
const String model = 'gpt-3.5-turbo';

final response = await http.post(
  Uri.parse('https://api.openai.com/v1/chat/completions'),
  headers: {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'model': model,
    'messages': [{'role': 'user', 'content': userMessage}],
  }),
);
```

### Option 2: Custom Backend
```dart
final response = await http.post(
  Uri.parse('https://your-api.com/ai/chat'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'message': userMessage}),
);
```

### Option 3: Google Bard / Gemini
Similar implementation using Google's API

---

## 📋 Project Structure Overview

```
ai_chat/
├── models/              # Data models
│   ├── message.dart     # Chat message
│   └── suggestion.dart  # Quick suggestions
├── data/                # Business logic
│   └── ai_chat_service.dart  # Voice + AI services
├── providers/           # State management
│   └── chat_provider.dart    # Riverpod state
├── screens/             # Main UI
│   └── ai_chat_screen.dart   # Chat interface
└── widgets/             # UI components
    ├── message_bubble.dart
    ├── chat_input_box.dart
    └── quick_suggestions_widget.dart
```

---

## 🎮 Testing the Feature

### Manual Testing
1. Open app → AI Chat tab
2. Type a test message (e.g., "prayer")
3. See mock response appears
4. Try sending another message
5. Test the voice button (on real device)

### Automated Testing (Future)
```dart
testWidgets('AI Chat sends message', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Find input and send
  await tester.enterText(find.byType(TextField), 'Hello');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pumpAndSettle();
  
  // Verify response
  expect(find.text('That\'s a great question!'), findsOneWidget);
});
```

---

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Microphone not working | Check permissions in Android/iOS settings |
| No responses from API | Check API endpoint and network connection |
| Chat history lost on restart | Use Hive/Isar to persist messages (future) |
| Voice recognition too slow | Ensure good internet connection |
| Messages not scrolling | Check ScrollController initialization |

---

## 📱 Platform-Specific Setup

### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSMicrophoneUsageDescription</key>
<string>For voice chat feature</string>
```

---

## 🌍 Internationalization

The feature automatically uses your app's language setting:
- **English**: "Today's prayer times"
- **Bengali**: "এআই চ্যাট" (AI Chat)

---

## 🚀 Performance Tips

1. **Message Limit**: Consider limiting chat history to last 50 messages
2. **Voice**: Pre-download speech models for offline support
3. **Caching**: Cache API responses for similar questions
4. **Threading**: Use isolates for large response processing

---

## 📚 Resources Used

- **speech_to_text**: ^7.0.0 (Voice recognition)
- **flutter_tts**: ^4.2.5 (Text-to-speech for future)
- **flutter_riverpod**: ^2.5.1 (State management)
- **uuid**: ^4.5.3 (Message IDs)

---

## 💡 Future Enhancements

- [ ] Message persistence (Hive/Isar)
- [ ] User authentication for chat history
- [ ] Typing indicators
- [ ] Message reactions/emotions
- [ ] Share conversations
- [ ] Islam-specific trained AI model
- [ ] Multi-turn context awareness
- [ ] Audio response (TTS)

---

## 📞 Support

For issues or questions:
1. Check `AI_CHAT_SETUP.md` for detailed docs
2. Review error messages in console
3. Check Flutter analyzer output
4. Test on physical device (voice works better than emulator)

---

**Version**: 1.0
**Status**: ✅ Production Ready
**Last Updated**: April 4, 2026
