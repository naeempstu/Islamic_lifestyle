# 🤖 AI Chat Screen Setup & Implementation Guide

## ✨ Features Implemented

### 1. **WhatsApp-like Chat Interface**
- Message bubbles with timestamps
- User messages aligned right (primary color)
- AI responses aligned left (secondary color)
- Smooth scrolling to latest messages

### 2. **Voice Input Capability**
- Microphone button to toggle speech recognition
- Real-time voice-to-text conversion
- Visual feedback when listening (changes to red)
- Speech recognition using `speech_to_text` package

### 3. **Quick Suggestions**
- 6 predefined suggestion buttons with emojis
- Categories: prayer, hadith, dua, knowledge, ramadan, quran
- Easy one-tap message sending

### 4. **Loading States**
- Loading spinner during AI response fetch
- Disabled input while processing
- Visual feedback for all interactions

---

## 📁 Project Structure

```
lib/features/ai_chat/
├── data/
│   └── ai_chat_service.dart          # Voice and AI services
├── models/
│   ├── message.dart                  # Message model (text, voice, suggestion)
│   └── suggestion.dart               # QuickSuggestion model
├── providers/
│   └── chat_provider.dart            # Riverpod state management
├── screens/
│   └── ai_chat_screen.dart           # Main chat UI
└── widgets/
    ├── message_bubble.dart           # Individual message display
    ├── chat_input_box.dart           # Input field + mic + send buttons
    └── quick_suggestions_widget.dart # Suggestion pills
```

---

## 🚀 Getting Started

### 1. **Dependencies Added**
```yaml
dependencies:
  speech_to_text: ^7.0.0      # Voice input
  flutter_tts: ^4.2.5         # Text-to-speech (for future use)
```

### 2. **Access the Feature**
- Navigate to the **AI Chat** tab in the bottom navigation bar
- The screen is now integrated into MainShell at index 5

---

## 🔌 API Integration (Important)

### Current Implementation
- Using **mock responses** for testing
- Responses are generated based on keywords in user messages
- Topics: prayer, hadith, dua, quran, ramadan

### To Connect Real AI API

**Step 1:** Update `ai_chat_service.dart`

```dart
static Future<String> getAIResponse(String userMessage) async {
  try {
    final response = await http.post(
      Uri.parse('YOUR_API_ENDPOINT/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': userMessage}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? 'Could not process your request';
    } else {
      throw Exception('Failed to get AI response');
    }
  } catch (e) {
    print('Error getting AI response: $e');
    return 'Sorry, I could not process your request. Please try again.';
  }
}
```

**Step 2:** Add required imports
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
```

---

## 🎤 Voice Input Setup

### Platform-Specific Configuration

#### **Android**
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### **iOS**
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to provide voice input for the AI chat.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to convert your voice to text.</string>
```

---

## 🧠 Models & Enums

### Message Model
```dart
class Message {
  final String id;
  final String content;
  final MessageSender sender;  // user or ai
  final DateTime timestamp;
  final MessageType type;       // text, voice, suggestion
}

enum MessageSender { user, ai }
enum MessageType { text, voice, suggestion }
```

### QuickSuggestion Model
```dart
class QuickSuggestion {
  final String id;
  final String text;
  final String emoji;
  final String category;
}
```

---

## 🎯 Riverpod State Management

### Providers

```dart
// Messages list
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<Message>>

// Current input text
final currentMessageProvider = StateProvider<String>

// Loading state
final aiLoadingProvider = StateProvider<bool>

// Voice listening state
final isListeningProvider = StateProvider<bool>

// Quick suggestions
final quickSuggestionsProvider = StateProvider<List<QuickSuggestion>>

// Voice service
final voiceServiceProvider = StateProvider<VoiceService>
```

---

## 🎨 UI Components

### 1. MessageBubble
- Displays individual messages
- Different styling for user vs AI
- Timestamps in HH:mm format
- Max width 75% of screen

### 2. ChatInputBox
- TextField with placeholder "Ask me anything..."
- Microphone button (toggle for listening)
- Send button with loading spinner
- Disabled when processing

### 3. QuickSuggestionsWidget
- Horizontal scrollable pills
- Icon emoji + text
- Lightweight border styling
- One-tap to submit

---

## 🔧 Customization

### Change Quick Suggestions
Edit `models/suggestion.dart`:
```dart
final List<QuickSuggestion> defaultSuggestions = [
  QuickSuggestion(
    id: '1',
    text: 'Your custom text',
    emoji: '👍',
    category: 'custom',
  ),
  // Add more...
];
```

### Change Colors
The screen uses `theme.primaryColor` and `theme.brightness` for theming.
Customize in your app's theme configuration.

### Add Text-to-Speech
```dart
import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();
await flutterTts.speak('AI response text');
```

---

## ✅ Testing Checklist

- [ ] Chat screen appears in bottom navigation
- [ ] Can type messages and send them
- [ ] Microphone button toggles on/off
- [ ] Quick suggestion buttons work
- [ ] Mock AI responses appear
- [ ] Messages have correct timestamps
- [ ] Loading spinner shows during processing
- [ ] Input is disabled while loading

---

## 📚 Future Enhancements

1. **Real AI Integration**: Connect to OpenAI, Google Bard, or custom backend
2. **Message History**: Save/load conversations
3. **Typing Indicators**: Show "AI is typing..."
4. **Message Delete/Edit**: Swipe or long-press actions
5. **Share Messages**: Export chat conversations
6. **Custom Personas**: Different AI response styles
7. **Multi-language Support**: Already uses app language setting
8. **Analytics**: Track popular questions

---

## 🐛 Troubleshooting

### Issues with Speech Recognition
1. Check microphone permissions
2. Ensure internet connection
3. Test on real device (not emulator)

### No Response from API
1. Check API endpoint URL
2. Verify network connectivity
3. Check response format matches expected JSON

### UI Not Updating
1. Ensure Riverpod providers are correctly watched
2. Check ConsumerWidget/ConsumerState usage

---

## 📝 Notes

- The `VoiceService` handles speech recognition initialization
- Messages are stored in `chatMessagesProvider`
- All async operations are handled with proper error handling
- The feature is fully localized with English/Bengali support

---

## 🔗 Related Files

- [Message Model](./models/message.dart)
- [Suggestion Model](./models/suggestion.dart)
- [AI Chat Service](./data/ai_chat_service.dart)
- [Chat Providers](./providers/chat_provider.dart)
- [AI Chat Screen](./screens/ai_chat_screen.dart)

---

**Last Updated**: April 4, 2026
**Feature Status**: ✅ Complete - Ready for API Integration
