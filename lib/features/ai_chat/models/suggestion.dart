class QuickSuggestion {
  final String id;
  final String text;
  final String emoji;
  final String category; // prayer, dua, hadith, etc.

  QuickSuggestion({
    required this.id,
    required this.text,
    required this.emoji,
    required this.category,
  });
}

final List<QuickSuggestion> defaultSuggestions = [
  QuickSuggestion(
    id: '1',
    text: 'Today\'s prayer times',
    emoji: '🕌',
    category: 'prayer',
  ),
  QuickSuggestion(
    id: '2',
    text: 'Random hadith',
    emoji: '📚',
    category: 'hadith',
  ),
  QuickSuggestion(
    id: '3',
    text: 'Daily dua',
    emoji: '🤲',
    category: 'dua',
  ),
  QuickSuggestion(
    id: '4',
    text: 'Islamic knowledge',
    emoji: '🧠',
    category: 'knowledge',
  ),
  QuickSuggestion(
    id: '5',
    text: 'Ramadan tips',
    emoji: '🌙',
    category: 'ramadan',
  ),
  QuickSuggestion(
    id: '6',
    text: 'Quran recitation',
    emoji: '📖',
    category: 'quran',
  ),
];
