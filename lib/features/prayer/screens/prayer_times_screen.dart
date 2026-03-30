import 'package:flutter/material.dart';

import '../../../core/models/app_enums.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/services/location_service.dart';
import '../services/prayer_times.dart';
import '../services/prayer_times_service.dart';

class PrayerTimesScreen extends StatelessWidget {
  final AppLanguage language;
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  final LocationService locationService;
  final PrayerTimesService prayerTimesService;

  const PrayerTimesScreen({
    super.key,
    required this.language,
    required this.settings,
    required this.onSettingsChanged,
    required this.locationService,
    required this.prayerTimesService,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(
                language == AppLanguage.bn ? 'নামাজের সময়' : 'Prayer Times',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0xFF1A1C30))),
                child: const Icon(Icons.explore_outlined, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FutureBuilder<PrayerTimesModel>(
            future: _loadTimes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final times = snapshot.data!;
              return _PrayerTimesCard(language: language, times: times);
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Text(language == AppLanguage.bn ? 'প্রেয়ার চেকলিস্ট' : 'Prayer Checklist', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: const Color(0xFFE3EFE8), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${settings.azanEnabled.values.where((v) => v).length}/5',
                    style: const TextStyle(color: Color(0xFF1E8C58), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }

  Future<PrayerTimesModel> _loadTimes() async {
    final (lat, lng) = await locationService.getLatLngOrFallback();
    return prayerTimesService.calculateFor(
      latitude: lat,
      longitude: lng,
      method: settings.prayerCalculationMethod,
    );
  }
}

class _PrayerTimesCard extends StatelessWidget {
  final AppLanguage language;
  final PrayerTimesModel times;

  const _PrayerTimesCard({required this.language, required this.times});

  @override
  Widget build(BuildContext context) {
    final items = [
      (prayer: PrayerName.fajr, time: times.fajr),
      (prayer: PrayerName.dhuhr, time: times.dhuhr),
      (prayer: PrayerName.asr, time: times.asr),
      (prayer: PrayerName.maghrib, time: times.maghrib),
      (prayer: PrayerName.isha, time: times.isha),
    ];

    String formatTime(DateTime dt) {
      // Use device locale.
      return MaterialLocalizations.of(context).formatTimeOfDay(
            TimeOfDay.fromDateTime(dt),
          );
    }

    final now = DateTime.now();
    final next = items.firstWhere((p) => p.time.isAfter(now), orElse: () => items.first);
    final left = next.time.difference(now);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF577DB5), Color(0xFF7196C9)]),
          ),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Next Prayer', style: TextStyle(color: Colors.white70)),
                    Text(next.prayer.labelEn(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26)),
                  ],
                ),
              ),
              Text(
                '${formatTime(next.time)}\n${left.inHours}h ${left.inMinutes.remainder(60)}m left',
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final item in items)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: item.prayer == next.prayer ? const Color(0xFF5D82BB) : Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: item.prayer == PrayerName.fajr
                        ? const Color(0xFFEDF2F9)
                        : item.prayer == PrayerName.dhuhr
                            ? const Color(0xFFC8A14D)
                            : item.prayer == PrayerName.asr
                                ? const Color(0xFFE5892F)
                                : item.prayer == PrayerName.maghrib
                                    ? const Color(0xFFC84E57)
                                    : const Color(0xFF2D457A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    language == AppLanguage.bn ? item.prayer.labelBn() : item.prayer.labelEn(),
                    style: TextStyle(
                      color: item.prayer == next.prayer ? Colors.white : const Color(0xFF303244),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  formatTime(item.time),
                  style: TextStyle(
                    color: item.prayer == next.prayer ? Colors.white : const Color(0xFF303244),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.circle_outlined, color: item.prayer == next.prayer ? Colors.white70 : const Color(0xFFC3C5CF)),
              ],
            ),
          ),
      ],
    );
  }
}

