import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_enums.dart';
import '../../features/prayer/services/prayer_times.dart';

class ChecklistSection extends StatelessWidget {
  final AppLanguage language;
  final PrayerTimesModel times;
  final Map<String, bool> completed;
  final ValueChanged<String> onToggle;

  const ChecklistSection({
    super.key,
    required this.language,
    required this.times,
    required this.completed,
    required this.onToggle,
  });

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  List<Map<String, dynamic>> _getPrayers() {
    return [
      {
        'label': 'Fajr',
        'bn': 'ফজর',
        'key': 'fajr',
        'time': times.fajr,
      },
      {
        'label': 'Zuhr',
        'bn': 'যোহর',
        'key': 'zuhr',
        'time': times.dhuhr,
      },
      {
        'label': 'Asr',
        'bn': 'আসর',
        'key': 'asr',
        'time': times.asr,
      },
      {
        'label': 'Maghrib',
        'bn': 'মাগরিব',
        'key': 'maghrib',
        'time': times.maghrib,
      },
      {
        'label': 'Isha',
        'bn': 'এশা',
        'key': 'isha',
        'time': times.isha,
      },
    ];
  }

  String _getNextPrayerKey() {
    final now = DateTime.now();
    final prayers = _getPrayers();

    final next = prayers.firstWhere(
      (p) => (p['time'] as DateTime).isAfter(now),
      orElse: () => prayers.first,
    );

    return next['key'] as String;
  }

  int get _completedCount => completed.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayers = _getPrayers();
    final nextPrayerKey = _getNextPrayerKey();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language == AppLanguage.bn
                  ? 'আজকের নামাজ চেকলিস্ট'
                  : 'Today\'s Prayer Checklist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1a1a2e),
                letterSpacing: 0.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10b981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_completedCount/5',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: prayers.map(
            (prayer) {
              final key = prayer['key'] as String;
              final isCompleted = completed[key] ?? false;
              final isNext = key == nextPrayerKey;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _PrayerChecklistItem(
                  language: language,
                  label: language == AppLanguage.bn
                      ? prayer['bn'] as String
                      : prayer['label'] as String,
                  time: _formatTime(prayer['time'] as DateTime),
                  isCompleted: isCompleted,
                  isNext: isNext,
                  onToggle: () => onToggle(key),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class _PrayerChecklistItem extends StatelessWidget {
  final AppLanguage language;
  final String label;
  final String time;
  final bool isCompleted;
  final bool isNext;
  final VoidCallback onToggle;

  const _PrayerChecklistItem({
    required this.language,
    required this.label,
    required this.time,
    required this.isCompleted,
    required this.isNext,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted
            ? (isDark
                ? const Color(0xFF1e3a8a).withValues(alpha: 0.5)
                : const Color(0xFFdbeafe).withValues(alpha: 0.6))
            : (isNext
                ? (isDark
                    ? const Color(0xFF064e3b).withValues(alpha: 0.5)
                    : const Color(0xFFd1fae5).withValues(alpha: 0.8))
                : (isDark
                    ? const Color(0xFF1f2937).withValues(alpha: 0.9)
                    : const Color(0xFFf3f4f6).withValues(alpha: 0.8))),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF2563eb).withValues(alpha: 0.5)
              : (isNext
                  ? const Color(0xFF10b981).withValues(alpha: 0.6)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFF2563eb).withValues(alpha: 0.1))),
          width: isNext ? 2 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10b981).withValues(alpha: 0.2)
                  : (isNext
                      ? const Color(0xFF10b981).withValues(alpha: 0.25)
                      : const Color(0xFF2563eb).withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle
                  : (isNext ? Icons.schedule : Icons.done),
              color: isCompleted
                  ? const Color(0xFF10b981)
                  : (isNext
                      ? const Color(0xFF10b981)
                      : const Color(0xFF2563eb)),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF1a1a2e),
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (isNext)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10b981),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            language == AppLanguage.bn ? 'পরবর্তী' : 'Next',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF6b7280),
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: isCompleted,
            onChanged: (_) => onToggle(),
            activeColor: const Color(0xFF10b981),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
