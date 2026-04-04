import 'package:flutter/material.dart';
import '../models/suggestion.dart';

class QuickSuggestionsWidget extends StatelessWidget {
  final List<QuickSuggestion> suggestions;
  final Function(String) onSuggestionTapped;

  const QuickSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSuggestionTapped,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(
          suggestions.length,
          (index) {
            final suggestion = suggestions[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSuggestionTapped(suggestion.text),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(24),
                    color: theme.primaryColor.withValues(alpha: 0.08),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        suggestion.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        suggestion.text,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
