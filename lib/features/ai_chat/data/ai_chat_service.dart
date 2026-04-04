import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<void> initialize() async {
    _speechToText = stt.SpeechToText();
    await _speechToText.initialize(
      onError: (error) {
        // Handle error silently
      },
      onStatus: (status) {
        // Handle status silently
      },
    );
  }

  Future<void> startListening(
    Function(String) onResult,
  ) async {
    if (!_speechToText.isAvailable) {
      return;
    }

    if (_isListening) return;

    _isListening = true;
    _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
  }

  void dispose() {
    _speechToText.cancel();
  }
}

class AIChatService {
  /// Send message to AI and get response
  /// For now, returns mock responses based on message content
  static Future<String> getAIResponse(String userMessage) async {
    try {
      // Remove this and uncomment the actual API call when you have an API
      return _getMockAIResponse(userMessage);

      /*
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Could not process your request';
      } else {
        throw Exception('Failed to get AI response');
      }
      */
    } catch (e) {
      return 'Sorry, I could not process your request. Please try again.';
    }
  }

  /// Mock responses for testing
  static String _getMockAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('prayer') || message.contains('salah')) {
      return 'The five daily prayers (Salah) are the foundation of Islamic worship. They are performed at:\n'
          '• Fajr (dawn)\n'
          '• Dhuhr (midday)\n'
          '• Asr (afternoon)\n'
          '• Maghrib (sunset)\n'
          '• Isha (night)\n\n'
          'Each prayer takes about 5 minutes. Would you like to set prayer reminders?';
    }

    if (message.contains('hadith')) {
      return '"The best of you are those who have the best character." - Prophet Muhammad (PBUH)\n\n'
          'This hadith emphasizes the importance of good character (Akhlaq) in Islam.';
    }

    if (message.contains('dua') || message.contains('supplication')) {
      return 'Here is a beautiful dua:\n\n'
          'اللَّهُمَّ أَنتَ السَّلَامُ وَمِنكَ السَّلَامُ\n'
          '"O Allah, You are the source of peace, and from You comes peace."\n\n'
          'This dua brings tranquility and peace to the heart.';
    }

    if (message.contains('quran')) {
      return 'The Quran is the word of Allah revealed to Prophet Muhammad (PBUH) over 23 years. '
          'It contains 114 chapters (Surahs) and 6,236 verses (Ayahs). '
          'Would you like to start reading the Quran?';
    }

    if (message.contains('ramadan')) {
      return 'Ramadan is the ninth month of the Islamic calendar, when Prophet Muhammad (PBUH) first received the revelation of the Quran. '
          'Muslims fast from dawn to sunset during this holy month.';
    }

    return 'That\'s a great question! I\'m here to help you learn about Islam and maintain your spiritual journey. '
        'Feel free to ask about prayer times, Quranic verses, hadiths, or any Islamic topic!';
  }
}
