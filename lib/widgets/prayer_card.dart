import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_enums.dart';
import '../../features/prayer/services/prayer_times.dart';

class CurrentPrayerCard extends StatelessWidget {
  final AppLanguage language;
  final PrayerTimesModel times;

  const CurrentPrayerCard({
    super.key,
    required this.language,
    required this.times,
  });

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  Map<String, dynamic> _getCurrentPrayer() {
    final now = DateTime.now();
    final previousIsha = times.isha.subtract(const Duration(days: 1));

    if (now.isBefore(times.fajr)) {
      return {
        'label': 'Isha',
        'bn': '\u098f\u09b6\u09be',
        'start': previousIsha,
        'end': times.fajr,
      };
    }

    final tomorrowFajr = times.fajr.add(const Duration(days: 1));
    final prayers = [
      {
        'label': 'Fajr',
        'bn': '\u09ab\u099c\u09b0',
        'start': times.fajr,
        'end': times.sunrise,
      },
      {
        'label': 'Zuhr',
        'bn': '\u09af\u09cb\u09b9\u09b0',
        'start': times.dhuhr,
        'end': times.asr,
      },
      {
        'label': 'Asr',
        'bn': '\u0986\u09b8\u09b0',
        'start': times.asr,
        'end': times.maghrib,
      },
      {
        'label': 'Maghrib',
        'bn': '\u09ae\u09be\u0997\u09b0\u09bf\u09ac',
        'start': times.maghrib,
        'end': times.isha,
      },
      {
        'label': 'Isha',
        'bn': '\u098f\u09b6\u09be',
        'start': times.isha,
        'end': tomorrowFajr,
      },
    ];

    for (final prayer in prayers) {
      final start = prayer['start'] as DateTime;
      final end = prayer['end'] as DateTime;
      final startsNow = now.isAtSameMomentAs(start);
      if ((startsNow || now.isAfter(start)) && now.isBefore(end)) {
        return prayer;
      }
    }

    final nextPrayer = prayers.firstWhere(
      (prayer) => (prayer['start'] as DateTime).isAfter(now),
      orElse: () => prayers.last,
    );

    return nextPrayer;
  }

  @override
  Widget build(BuildContext context) {
    final currentPrayer = _getCurrentPrayer();
    final start = currentPrayer['start'] as DateTime;
    final end = currentPrayer['end'] as DateTime;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8b5cf6),
            Color(0xFF7c3aed),
            Color(0xFF6d28d9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8b5cf6).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == AppLanguage.bn
                          ? '\u09ac\u09b0\u09cd\u09a4\u09ae\u09be\u09a8 \u09a8\u09be\u09ae\u09be\u099c\u09c7\u09b0 \u09b8\u09ae\u09df'
                          : 'Current Prayer Time',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language == AppLanguage.bn
                          ? currentPrayer['bn'] as String
                          : currentPrayer['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PrayerWindowTime(
                  language: language,
                  label: 'Start',
                  labelBn: 'শুরু',
                  time: _formatTime(start),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _PrayerWindowTime(
                  language: language,
                  label: 'End',
                  labelBn: 'শেষ',
                  time: _formatTime(end),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PrayerTimesCard extends StatelessWidget {
  final AppLanguage language;
  final PrayerTimesModel times;

  const PrayerTimesCard({
    super.key,
    required this.language,
    required this.times,
  });

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  Map<String, dynamic> _getNextPrayer() {
    final now = DateTime.now();
    final prayers = [
      {'label': 'Fajr', 'bn': 'ফজর', 'time': times.fajr},
      {'label': 'Zuhr', 'bn': 'যোহর', 'time': times.dhuhr},
      {'label': 'Asr', 'bn': 'আসর', 'time': times.asr},
      {'label': 'Maghrib', 'bn': 'মাগরিব', 'time': times.maghrib},
      {'label': 'Isha', 'bn': 'এশা', 'time': times.isha},
    ];

    final next = prayers.firstWhere(
      (p) => (p['time'] as DateTime).isAfter(now),
      orElse: () => prayers.first,
    );

    final timeUntilNext = (next['time'] as DateTime).difference(now);
    return {
      ...next,
      'timeUntil': timeUntilNext,
    };
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = _getNextPrayer();
    final timeUntil = nextPrayer['timeUntil'] as Duration;
    final hours = timeUntil.inHours;
    final minutes = timeUntil.inMinutes.remainder(60);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF06b6d4),
            Color(0xFF0891b2),
            Color(0xFF0d9488),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06b6d4).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section: Prayer Name and Countdown
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == AppLanguage.bn
                          ? 'পরবর্তী সালাত'
                          : 'Next Prayer',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      language == AppLanguage.bn
                          ? nextPrayer['bn'] as String
                          : nextPrayer['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${hours}h',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${minutes}m',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 14),
          // All Prayer Times
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PrayerTimeItem(
                  language: language,
                  label: 'Fajr',
                  labelBn: 'ফজর',
                  time: _formatTime(times.fajr),
                ),
                const SizedBox(width: 16),
                _PrayerTimeItem(
                  language: language,
                  label: 'Zuhr',
                  labelBn: 'যোহর',
                  time: _formatTime(times.dhuhr),
                ),
                const SizedBox(width: 16),
                _PrayerTimeItem(
                  language: language,
                  label: 'Asr',
                  labelBn: 'আসর',
                  time: _formatTime(times.asr),
                ),
                const SizedBox(width: 16),
                _PrayerTimeItem(
                  language: language,
                  label: 'Maghrib',
                  labelBn: 'মাগরিব',
                  time: _formatTime(times.maghrib),
                ),
                const SizedBox(width: 16),
                _PrayerTimeItem(
                  language: language,
                  label: 'Isha',
                  labelBn: 'এশা',
                  time: _formatTime(times.isha),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimeItem extends StatelessWidget {
  final AppLanguage language;
  final String label;
  final String labelBn;
  final String time;

  const _PrayerTimeItem({
    required this.language,
    required this.label,
    required this.labelBn,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          language == AppLanguage.bn ? labelBn : label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PrayerWindowTime extends StatelessWidget {
  final AppLanguage language;
  final String label;
  final String labelBn;
  final String time;

  const _PrayerWindowTime({
    required this.language,
    required this.label,
    required this.labelBn,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language == AppLanguage.bn ? labelBn : label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
