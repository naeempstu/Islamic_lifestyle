import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/message.dart';
import '../providers/chat_provider.dart';
import '../data/ai_chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_box.dart';
import '../widgets/quick_suggestions_widget.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key}) : super();

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    final voiceService = ref.read(voiceServiceProvider);
    await voiceService.initialize();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    final voiceService = ref.read(voiceServiceProvider);
    voiceService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = Message(
      id: const Uuid().v4(),
      content: message,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    ref.read(chatMessagesProvider.notifier).addMessage(userMessage);
    _messageController.clear();
    _scrollToBottom();

    // Show loading state
    ref.read(aiLoadingProvider.notifier).state = true;

    try {
      // Get AI response
      final aiResponse = await AIChatService.getAIResponse(message);

      if (!mounted) return;

      // Add AI message
      final aiMessage = Message(
        id: const Uuid().v4(),
        content: aiResponse,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );

      ref.read(chatMessagesProvider.notifier).addMessage(aiMessage);
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        ref.read(aiLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _startVoiceInput() async {
    final voiceService = ref.read(voiceServiceProvider);
    final isListening = ref.watch(isListeningProvider);

    if (isListening) {
      await voiceService.stopListening();
      ref.read(isListeningProvider.notifier).state = false;
      return;
    }

    try {
      ref.read(isListeningProvider.notifier).state = true;
      await voiceService.startListening((recognizedWords) {
        _messageController.text = recognizedWords;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice input error: $e')),
      );
      ref.read(isListeningProvider.notifier).state = false;
    }
  }

  void _handleSuggestionTapped(String suggestionText) {
    _messageController.text = suggestionText;
    _sendMessage(suggestionText);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final suggestions = ref.watch(quickSuggestionsProvider);
    final isLoading = ref.watch(aiLoadingProvider);
    final isListening = ref.watch(isListeningProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Islamic AI 🤖',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Your spiritual guide',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: theme.primaryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ask about Islam, prayers, Quran, or hadiths',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: messages[index]);
                    },
                  ),
          ),
          // Quick suggestions
          if (messages.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: QuickSuggestionsWidget(
                suggestions: suggestions,
                onSuggestionTapped: _handleSuggestionTapped,
              ),
            ),
          // Input box
          ChatInputBox(
            controller: _messageController,
            onSend: () => _sendMessage(_messageController.text),
            onMicPressed: _startVoiceInput,
            isListening: isListening,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
