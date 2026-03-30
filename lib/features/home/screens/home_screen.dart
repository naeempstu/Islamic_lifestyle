import 'package:flutter/material.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_enums.dart';
import '../../../core/services/location_service.dart';
import '../data/gentle_messages.dart';
import '../../prayer/services/prayer_times.dart';
import '../../prayer/services/prayer_times_service.dart';
import '../../routine/data/daily_routine_store.dart';

enum HomeQuickAction { qibla, quran, tasbih, halal }

class HomeScreen extends StatefulWidget {
  final AppLanguage language;
  final PrayerCalculationMethod prayerCalculationMethod;
  final LocationService locationService;
  final PrayerTimesService prayerTimesService;
  final DailyRoutineStore routineStore;
  final bool alarmEnabled;
  final ValueChanged<bool> onAlarmToggle;
  final ValueChanged<HomeQuickAction> onQuickAccessTap;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenRamadan;

  const HomeScreen({
    super.key,
    required this.language,
    required this.prayerCalculationMethod,
    required this.locationService,
    required this.prayerTimesService,
    required this.routineStore,
    required this.alarmEnabled,
    required this.onAlarmToggle,
    required this.onQuickAccessTap,
    required this.onOpenSettings,
    required this.onOpenRamadan,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<PrayerTimesModel> _prayerFuture;
  late Future<DailyRoutine> _routineFuture;
  late Future<_LocationSnapshot> _locationFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _prayerFuture = _loadTimes();
    _routineFuture = widget.routineStore.loadForDate(DateTime.now());
    _locationFuture = _loadLocation();
  }

  Future<void> _onRefresh() async {
    setState(_refreshData);
    await Future.wait([_prayerFuture, _routineFuture, _locationFuture]);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return widget.language == AppLanguage.bn ? 'শুভ সকাল' : 'Good Morning';
    }
    if (hour < 17) {
      return widget.language == AppLanguage.bn
          ? 'শুভ অপরাহ্ন'
          : 'Good Afternoon';
    }
    return widget.language == AppLanguage.bn ? 'শুভ সন্ধ্যা' : 'Good Evening';
  }

  String _hijriDate() {
    final hijri = HijriCalendarConfig.now();
    final day = hijri.hDay;
    final year = hijri.hYear;
    const monthsEn = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha’ban',
      'Ramadan',
      'Shawwal',
      'Dhul Qa’dah',
      'Dhul Hijjah',
    ];
    final month = monthsEn[(hijri.hMonth - 1).clamp(0, 11)];
    return '$day $month $year AH';
  }

  Future<PrayerTimesModel> _loadTimes() async {
    final (lat, lng) = await widget.locationService.getLatLngOrFallback();
    return widget.prayerTimesService.calculateFor(
      latitude: lat,
      longitude: lng,
      method: widget.prayerCalculationMethod,
    );
  }

  Future<_LocationSnapshot> _loadLocation() async {
    final fetchedAt = DateTime.now();
    final (lat, lng) = await widget.locationService.getLatLngOrFallback();
    final name = await widget.locationService.getLiveLocationName();
    final isFallback =
        lat == LocationService.fallbackLat &&
        lng == LocationService.fallbackLng;
    return _LocationSnapshot(
      name: name,
      lat: lat,
      lng: lng,
      isFallback: isFallback,
      fetchedAt: fetchedAt,
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final message = GentleMessages.dailyFor(widget.language, date: now);
    final dateLabel = DateFormat('EEEE, d MMM y').format(now);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330F2027),
                    blurRadius: 22,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.language == AppLanguage.bn
                                  ? 'আসসালামু আলাইকুম'
                                  : 'Assalamu Alaikum',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              dateLabel,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _hijriDate(),
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Material(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: widget.onOpenRamadan,
                              borderRadius: BorderRadius.circular(14),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.nightlight_round,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Material(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: widget.onOpenSettings,
                              borderRadius: BorderRadius.circular(14),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FutureBuilder<_LocationSnapshot>(
                    future: _locationFuture,
                    builder: (context, snapshot) {
                      final data = snapshot.data;
                      final loading = !snapshot.hasData;
                      final title =
                          data?.name ??
                          (widget.language == AppLanguage.bn
                              ? 'লাইভ লোকেশন লোড হচ্ছে...'
                              : 'Loading live location...');
                      final coords = data == null
                          ? '—'
                          : '${data.lat.toStringAsFixed(4)}, ${data.lng.toStringAsFixed(4)}';
                      final status = data == null
                          ? (widget.language == AppLanguage.bn
                                ? 'রিয়েলটাইম অবস্থান আনছি'
                                : 'Fetching live coordinates')
                          : data.isFallback
                          ? (widget.language == AppLanguage.bn
                                ? 'ডিফল্ট ঢাকা, বাংলাদেশ'
                                : 'Fallback: Dhaka, Bangladesh')
                          : (widget.language == AppLanguage.bn
                                ? 'লাইভ আপডেট ' + _relativeTime(data.fetchedAt)
                                : 'Live update ' +
                                      _relativeTime(data.fetchedAt));

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFA0F1D1),
                                        Color(0xFF37C978),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.gps_fixed,
                                    color: Color(0xFF0F2027),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        coords,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 250),
                                  opacity: loading ? 0.5 : 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.wifi_tethering,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          loading
                                              ? (widget.language ==
                                                        AppLanguage.bn
                                                    ? 'সিঙ্ক হচ্ছে'
                                                    : 'Syncing')
                                              : (widget.language ==
                                                        AppLanguage.bn
                                                    ? 'লাইভ'
                                                    : 'Live'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_active_outlined,
                              color: Color(0xFFA0F1D1),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.language == AppLanguage.bn
                                  ? 'সালাত অ্যালার্ম'
                                  : 'Salat Alarm',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: widget.alarmEnabled,
                        activeTrackColor: const Color(0xFFA0F1D1),
                        activeColor: const Color(0xFF1A1C30),
                        inactiveTrackColor: Colors.white24,
                        onChanged: widget.onAlarmToggle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF22925D),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            FutureBuilder<PrayerTimesModel>(
              future: _prayerFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final times = snapshot.data!;
                return _PrayerTimesCard(
                  language: widget.language,
                  times: times,
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Quick Access',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width < 380 ? 2 : 4;
                final ratio = crossAxisCount == 2 ? 1.85 : 0.95;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: ratio,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _QuickItem(
                      icon: Icons.explore_outlined,
                      label: 'Qibla\nDirection',
                      bg: const Color(0xFFE3ECE6),
                      fg: const Color(0xFF1D7E53),
                      onTap: () =>
                          widget.onQuickAccessTap(HomeQuickAction.qibla),
                    ),
                    _QuickItem(
                      icon: Icons.menu_book_outlined,
                      label: 'Qur\'an',
                      bg: const Color(0xFFF7F0DD),
                      fg: const Color(0xFFC7A452),
                      onTap: () =>
                          widget.onQuickAccessTap(HomeQuickAction.quran),
                    ),
                    _QuickItem(
                      icon: Icons.self_improvement_outlined,
                      label: 'Tasbih',
                      bg: const Color(0xFFE9E9EE),
                      fg: const Color(0xFF1A1C30),
                      onTap: () =>
                          widget.onQuickAccessTap(HomeQuickAction.tasbih),
                    ),
                    _QuickItem(
                      icon: Icons.restaurant_menu_outlined,
                      label: 'Halal\nGuide',
                      bg: const Color(0xFFE3ECE6),
                      fg: const Color(0xFF1D7E53),
                      onTap: () =>
                          widget.onQuickAccessTap(HomeQuickAction.halal),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Prayer Checklist',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  'View All',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1D7E53),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<DailyRoutine>(
              future: _routineFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final routine = snapshot.data!;
                final done = [
                  routine.salahCompleted,
                  routine.quranDone,
                  routine.dhikrDone,
                  routine.duaDone,
                  routine.goodDeedDone,
                ].where((v) => v).length;
                return Text(
                  '$done/5',
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowTile(
    IconData icon,
    String title,
    Color color, {
    String? subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2A2E47),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF8E8F9A)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationSnapshot {
  final String name;
  final double lat;
  final double lng;
  final bool isFallback;
  final DateTime fetchedAt;

  const _LocationSnapshot({
    required this.name,
    required this.lat,
    required this.lng,
    required this.isFallback,
    required this.fetchedAt,
  });
}

class _PrayerTimesCard extends StatelessWidget {
  final AppLanguage language;
  final PrayerTimesModel times;

  const _PrayerTimesCard({required this.language, required this.times});

  String _format(DateTime dt) => DateFormat.jm().format(dt);

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Fajr', bn: 'ফজর', time: times.fajr),
      (label: 'Zuhr', bn: 'যোহর', time: times.dhuhr),
      (label: 'Asr', bn: 'আসর', time: times.asr),
      (label: 'Maghrib', bn: 'মাগরিব', time: times.maghrib),
      (label: 'Isha', bn: 'এশা', time: times.isha),
    ];
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(minutes: 1), (x) => x),
      builder: (context, _) {
        final now = DateTime.now();
        final next = items.firstWhere(
          (p) => p.time.isAfter(now),
          orElse: () => items.first,
        );
        final left = next.time.difference(now);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF143368), Color(0xFF3B5E97)],
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.wb_twilight_rounded,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language == AppLanguage.bn
                          ? 'পরবর্তী নামাজ'
                          : 'Next Prayer',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      next.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 36,
                      ),
                    ),
                    Text(
                      _format(next.time),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${left.inHours}h ${left.inMinutes.remainder(60)}m\n${language == AppLanguage.bn ? 'বাকি' : 'remaining'}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  const _QuickItem({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  State<_QuickItem> createState() => _QuickItemState();
}

class _QuickItemState extends State<_QuickItem> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovered || _pressed;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _pressed ? 0.96 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color.lerp(
                widget.bg,
                widget.fg.withValues(alpha: 0.16),
                active ? 1 : 0,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: widget.fg.withValues(alpha: active ? 0.25 : 0.08),
                  blurRadius: active ? 18 : 10,
                  offset: Offset(0, active ? 8 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(18),
                splashColor: widget.fg.withValues(alpha: 0.18),
                highlightColor: widget.fg.withValues(alpha: 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      scale: active ? 1.08 : 1,
                      child: Icon(widget.icon, color: widget.fg, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Intentionally empty: HomeScreen gets its prayer method from app settings.
