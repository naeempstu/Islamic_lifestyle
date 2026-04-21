import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_enums.dart';
import '../../features/prayer/services/prayer_times.dart';

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
