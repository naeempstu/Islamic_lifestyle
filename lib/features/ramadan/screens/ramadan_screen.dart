import 'package:flutter/material.dart';
import 'package:hijri_calendar/hijri_calendar.dart';

import '../../../core/models/app_enums.dart';
import '../../../core/services/location_service.dart';
import '../../prayer/services/prayer_times.dart';
import '../../prayer/services/prayer_times_service.dart';

class RamadanScreen extends StatefulWidget {
  final AppLanguage language;
  final LocationService locationService;
  final PrayerTimesService prayerTimesService;
  final PrayerCalculationMethod prayerCalculationMethod;

  const RamadanScreen({
    super.key,
    required this.language,
    required this.locationService,
    required this.prayerTimesService,
    required this.prayerCalculationMethod,
  });

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  late Future<PrayerTimesModel> _timesFuture;

  @override
  void initState() {
    super.initState();
    _timesFuture = _loadTimes();
  }

  Future<PrayerTimesModel> _loadTimes() async {
    final (lat, lng) = await widget.locationService.getLatLngOrFallback();
    return widget.prayerTimesService.calculateFor(
      latitude: lat,
      longitude: lng,
      method: widget.prayerCalculationMethod,
    );
  }

  bool _isRamadanNow() {
    final hijri = HijriCalendarConfig.now();
    final list = hijri.toList();
    final month = list[1] ?? -1;
    return month == 9;
  }

  @override
  Widget build(BuildContext context) {
    final isRamadan = _isRamadanNow();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == AppLanguage.bn ? 'রমজান মোড' : 'Ramadan mode',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.language == AppLanguage.bn
                          ? 'শান্ত লক্ষ্য, ছোট ধারাবাহিকতা'
                          : 'Calm goals, small consistency',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRamadan
                          ? (widget.language == AppLanguage.bn
                                ? 'আজ রমজান। আল্লাহ সহজ করুন।'
                                : 'Today is Ramadan. May Allah make it easy.')
                          : (widget.language == AppLanguage.bn
                                ? 'এখন রমজান নয়। তবুও রুটিন চালিয়ে যান।'
                                : 'Not Ramadan right now. Keep your routine anyway.'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _RamadanFeatureGrid(language: widget.language),
            const SizedBox(height: 12),
            if (isRamadan)
              FutureBuilder<PrayerTimesModel>(
                future: _timesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final times = snapshot.data!;
                  return _RamadanTimingsCard(
                    language: widget.language,
                    times: times,
                  );
                },
              ),
            const SizedBox(height: 12),
            if (isRamadan) _RamadanChecklist(language: widget.language),
          ],
        ),
      ),
    );
  }
}

class _RamadanTimingsCard extends StatelessWidget {
  final AppLanguage language;
  final PrayerTimesModel times;

  const _RamadanTimingsCard({required this.language, required this.times});

  @override
  Widget build(BuildContext context) {
    final sehri = times.fajr.subtract(const Duration(minutes: 5));
    final iftar = times.maghrib;

    String sehriLabel = language == AppLanguage.bn
        ? 'সেহরি (আনুমানিক)'
        : 'Sehri (approx.)';
    String iftarLabel = language == AppLanguage.bn
        ? 'ইফতার (আনুমানিক)'
        : 'Iftar (approx.)';

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language == AppLanguage.bn ? 'আজকের টাইমিংস' : 'Today’s timings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _TimingRow(label: sehriLabel, time: sehri),
            _TimingRow(label: iftarLabel, time: iftar),
            const SizedBox(height: 10),
            Text(
              language == AppLanguage.bn
                  ? 'টিপ: অ্যাপ আপনার লোকেশন অনুযায়ী নামাজের সময় ব্যবহার করে।'
                  : 'Tip: This app uses your calculated prayer times for estimates.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimingRow extends StatelessWidget {
  final String label;
  final DateTime time;
  const _TimingRow({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    final formatted = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(time));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const Spacer(),
          Text(formatted, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _RamadanChecklist extends StatefulWidget {
  final AppLanguage language;
  const _RamadanChecklist({required this.language});

  @override
  State<_RamadanChecklist> createState() => _RamadanChecklistState();
}

class _RamadanChecklistState extends State<_RamadanChecklist> {
  bool _fasting = false;
  bool _quranGoal = false;
  bool _charityReminder = false;

  @override
  Widget build(BuildContext context) {
    final score = [
      _fasting,
      _quranGoal,
      _charityReminder,
    ].where((v) => v).length;
    final progress = score / 3;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.language == AppLanguage.bn
                  ? 'আজকের রমজান লক্ষ্য'
                  : 'Today’s Ramadan goals',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                color: const Color(0xFF1E8C58),
                backgroundColor: const Color(0xFFE4ECE7),
              ),
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: Text(
                widget.language == AppLanguage.bn
                    ? 'রোজা (যাদের ওপর প্রযোজ্য)'
                    : 'Fasting (for those who are able)',
              ),
              value: _fasting,
              onChanged: (v) => setState(() => _fasting = v ?? false),
            ),
            CheckboxListTile(
              title: Text(
                widget.language == AppLanguage.bn
                    ? 'কুরআন পড়া'
                    : 'Qur’an reading',
              ),
              value: _quranGoal,
              onChanged: (v) => setState(() => _quranGoal = v ?? false),
            ),
            CheckboxListTile(
              title: Text(
                widget.language == AppLanguage.bn
                    ? 'সাদাকাহ মনে রাখা'
                    : 'Sadaqah reminder',
              ),
              value: _charityReminder,
              onChanged: (v) => setState(() => _charityReminder = v ?? false),
            ),
            const SizedBox(height: 8),
            Text(
              widget.language == AppLanguage.bn
                  ? 'নিজেকে চাপ দেবেন না। আল্লাহ সহজ করে দেন।'
                  : 'No pressure. May Allah make it easy.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _RamadanFeatureGrid extends StatelessWidget {
  final AppLanguage language;

  const _RamadanFeatureGrid({required this.language});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Icons.nightlight_round,
        titleBn: 'ইবাদতের রাত',
        titleEn: 'Night Worship',
        color: const Color(0xFF3068B8),
      ),
      (
        icon: Icons.menu_book_outlined,
        titleBn: 'দৈনিক কুরআন',
        titleEn: 'Daily Qur\'an',
        color: const Color(0xFF1E8C58),
      ),
      (
        icon: Icons.favorite_outline,
        titleBn: 'সাদাকাহ',
        titleEn: 'Sadaqah',
        color: const Color(0xFFB56D2C),
      ),
      (
        icon: Icons.self_improvement_outlined,
        titleBn: 'যিকির সময়',
        titleEn: 'Dhikr Time',
        color: const Color(0xFF6B56AA),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth < 380 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: count == 2 ? 1.8 : 0.95,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 40)),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: item.color),
                  const SizedBox(height: 8),
                  Text(
                    language == AppLanguage.bn ? item.titleBn : item.titleEn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
