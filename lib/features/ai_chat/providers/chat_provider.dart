import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/suggestion.dart';
import '../data/ai_chat_service.dart';

// Voice service provider
final voiceServiceProvider = StateProvider<VoiceService>((ref) {
  return VoiceService();
});

// Chat messages provider
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<Message>>((ref) {
  return ChatMessagesNotifier();
});

// Current message being typed provider
final currentMessageProvider = StateProvider<String>((ref) => '');

// IsLoading provider for AI response
final aiLoadingProvider = StateProvider<bool>((ref) => false);

// Quick suggestions provider
final quickSuggestionsProvider = StateProvider<List<QuickSuggestion>>((ref) {
  return defaultSuggestions;
});

// Voice listening state provider
final isListeningProvider = StateProvider<bool>((ref) => false);

class ChatMessagesNotifier extends StateNotifier<List<Message>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(Message message) {
    state = [...state, message];
  }

  void addMessages(List<Message> messages) {
    state = [...state, ...messages];
  }

  void clearMessages() {
    state = [];
  }

  void removeMessage(String id) {
    state = state.where((msg) => msg.id != id).toList();
  }
}

// Send message and get AI response
final sendMessageProvider =
    FutureProvider.family<String, String>((ref, userMessage) async {
  return await AIChatService.getAIResponse(userMessage);
});
