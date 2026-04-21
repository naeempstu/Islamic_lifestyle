import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../../../core/models/app_enums.dart';
import '../../../core/services/location_service.dart';
import '../data/gentle_messages.dart';
import '../../prayer/services/prayer_times.dart';
import '../../prayer/services/prayer_times_service.dart';
import '../../prayer/services/prayer_times_verification.dart';

enum HomeQuickAction {
  qibla,
  tasbih,
  halal,
  masjid,
  nearestMosque,
  deenShiksha,
  hadith,
  duas,
  dhikr,
  quran,
}

class HomeScreen extends StatefulWidget {
  final AppLanguage language;
  final PrayerCalculationMethod prayerCalculationMethod;
  final LocationService locationService;
  final PrayerTimesService prayerTimesService;
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
  late Future<_LocationSnapshot> _locationFuture;
  final Map<String, bool> _prayerCompleted = {
    'fajr': false,
    'zuhr': false,
    'asr': false,
    'maghrib': false,
    'isha': false,
  };
  Timer? _dailyRefreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _setupDailyRefresh();
  }

  void _setupDailyRefresh() {
    // Calculate time until midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    // Set up timer to refresh at midnight
    _dailyRefreshTimer = Timer(durationUntilMidnight, () {
      if (mounted) {
        setState(() {
          _refreshData();
          // Reset prayer checklist for new day
          _prayerCompleted.updateAll((key, value) => false);
        });
        // Reschedule for next midnight
        _setupDailyRefresh();
      }
    });
  }

  @override
  void dispose() {
    _dailyRefreshTimer?.cancel();
    super.dispose();
  }

  void _refreshData() {
    _prayerFuture = _loadTimes();
    _locationFuture = _loadLocation();
  }

  Future<void> _onRefresh() async {
    setState(_refreshData);
    await Future.wait([_prayerFuture, _locationFuture]);
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

  String _quickAccessLabel(String key) {
    const labels = {
      'qibla_en': 'Qibla\nDirection',
      'qibla_bn': 'কিবলা\nদিক',
      'tasbih_en': 'Tasbih',
      'tasbih_bn': 'তাসবিহ',
      'halal_en': 'Halal\nGuide',
      'halal_bn': 'হালাল\nগাইড',
      'masjid_en': 'Find\nMasjid',
      'masjid_bn': 'মসজিদ\nখুঁজুন',
      'nearestMosque_en': 'Nearest\nMosque',
      'nearestMosque_bn': 'নিকটস্থ\nমসজিদ',
      'deen_en': 'Deen\nEducation',
      'deen_bn': 'দীন\nশিক্ষা',
      'hadith_en': 'Hadith',
      'hadith_bn': 'হাদিস',
      'duas_en': 'Duas',
      'duas_bn': 'দোয়া',
      'dhikr_en': 'Dhikr',
      'dhikr_bn': 'যিকির',
      'quran_en': 'Quran',
      'quran_bn': 'কুরআন',
    };
    final langSuffix = widget.language == AppLanguage.bn ? '_bn' : '_en';
    return labels['$key$langSuffix'] ?? '';
  }

  String _formatBengaliDate(DateTime date) {
    const dayNamesBn = [
      'সোমবার',
      'মঙ্গলবার',
      'বুধবার',
      'বৃহস্পতিবার',
      'শুক্রবার',
      'শনিবার',
      'রবিবার',
    ];
    const monthNamesBn = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];

    final dayName = dayNamesBn[date.weekday - 1];
    final monthName = monthNamesBn[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  String _locationNameToBengali(String englishName) {
    final locationMap = {
      'Dhaka': 'ঢাকা',
      'Chittagong': 'চট্টগ্রাম',
      'Sylhet': 'সিলেট',
      'Khulna': 'খুলনা',
      'Rajshahi': 'রাজশাহী',
      'Barisal': 'বরিশাল',
      'Rangpur': 'রংপুর',
      'Mymensingh': 'ময়মনসিংহ',
      'Gazipur': 'গাজীপুর',
      'Narayanganj': 'নারায়ণগঞ্জ',
      'Tangail': 'টাঙ্গাইল',
      'Comilla': 'কুমিল্লা',
      'Jashore': 'যশোর',
      'Bogra': 'বগুড়া',
      'Dinajpur': 'দিনাজপুর',
      'Pabna': 'পাবনা',
      'Sirajganj': 'সিরাজগঞ্জ',
      'Natore': 'নাটোর',
      'Nawabganj': 'নবাবগঞ্জ',
      'Kushtia': 'কুষ্টিয়া',
      'Meherpur': 'মেহেরপুর',
      'Chuadanga': 'চুয়াডাঙ্গা',
      'Gopalganj': 'গোপালগঞ্জ',
      'Pirojpur': 'পিরোজপুর',
      'Jhalokathan': 'ঝালকাঠি',
      'Patuakhali': 'পটুয়াখালী',
      'Bhola': 'ভোলা',
      'Feni': 'ফেনী',
      'Noakhali': 'নোয়াখালী',
      'Habiganj': 'হবিগঞ্জ',
      'Moulvibazar': 'মৌলভীবাজার',
      'Sunamganj': 'সুনামগঞ্জ',
      'Nilphamari': 'নীলফামারী',
      'Kurigram': 'কুড়িগ্রাম',
      'Lalmonirhat': 'লালমনিরহাট',
      'Thakurgaon': 'ঠাকুরগাঁও',
      'Panchagarh': 'পঞ্চগড়',
      'Jaypurhat': 'জয়পুরহাট',
      'Sherpur': 'শেরপুর',
    };

    return locationMap[englishName] ?? englishName;
  }

  Future<PrayerTimesModel> _loadTimes() async {
    final (lat, lng) = await widget.locationService.getLatLngOrFallback();

    try {
      // Try to fetch from API first
      final apiMethod = PrayerTimesVerification.getApiMethodCode(
        widget.prayerCalculationMethod.key,
      );
      return await PrayerTimesVerification.fetchFromApi(
        latitude: lat,
        longitude: lng,
        method: apiMethod,
      );
    } catch (e) {
      // Fallback to local calculation if API fails
      print('API fetch failed, using local calculation: $e');
      return widget.prayerTimesService.calculateFor(
        latitude: lat,
        longitude: lng,
        method: widget.prayerCalculationMethod,
      );
    }
  }

  Future<_LocationSnapshot> _loadLocation() async {
    final fetchedAt = DateTime.now();
    final (lat, lng) = await widget.locationService.getLatLngOrFallback();
    final name = await widget.locationService.getLiveLocationName();
    final isFallback = lat == LocationService.fallbackLat &&
        lng == LocationService.fallbackLng;
    return _LocationSnapshot(
      name: name,
      lat: lat,
      lng: lng,
      isFallback: isFallback,
      fetchedAt: fetchedAt,
    );
  }

  Future<void> _openNearestMosque() async {
    try {
      final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=mosque+near+me',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Fallback or error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.language == AppLanguage.bn
                ? 'গুগল ম্যাপ খোলা যায়নি'
                : 'Could not open Google Maps'),
          ),
        );
      }
    }
  }

  void _showRamadanCalendar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RamadanCalendarSheet(
        language: widget.language,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final message = GentleMessages.dailyFor(widget.language, date: now);

    // Format date in Bengali or English based on language
    final dateLabel = widget.language == AppLanguage.bn
        ? _formatBengaliDate(now)
        : DateFormat('EEEE, d MMM y').format(now);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Modern Header
            SliverToBoxAdapter(
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                            Color(0xFF1e3a8a),
                            Color(0xFF1e40af),
                            Color(0xFF1d4ed8),
                          ]
                        : const [
                            Color(0xFF2563eb),
                            Color(0xFF1d4ed8),
                            Color(0xFF1e40af),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    MediaQuery.of(context).padding.top + 24,
                    24,
                    24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Salam greeting + icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Salam Greeting
                          Expanded(
                            child: Text(
                              widget.language == AppLanguage.bn
                                  ? 'আসসালামু আলাইকুম'
                                  : 'Assalamu Alaikum',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Icons
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: widget.onOpenSettings,
                                  child: const Icon(
                                    Icons.settings_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: widget.onOpenRamadan,
                                  child: const Icon(
                                    Icons.nightlight_round,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.language == AppLanguage.bn
                                ? 'আপনার ইসলামিক যাত্রা'
                                : 'Your Islamic Journey',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showRamadanCalendar,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            dateLabel,
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.8),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            color: Colors.white
                                                .withValues(alpha: 0.7),
                                            size: 13,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _hijriDate(),
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.65),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Card
                    FutureBuilder<_LocationSnapshot>(
                      future: _locationFuture,
                      builder: (context, snapshot) {
                        final data = snapshot.data;
                        final loading = !snapshot.hasData;
                        final locationName = data?.name ?? '';
                        final title = (locationName.isEmpty)
                            ? (widget.language == AppLanguage.bn
                                ? 'লোড হচ্ছে...'
                                : 'Loading...')
                            : (widget.language == AppLanguage.bn
                                ? _locationNameToBengali(locationName)
                                : locationName);
                        final coords = data == null
                            ? '—'
                            : '${data.lat.toStringAsFixed(2)}°, ${data.lng.toStringAsFixed(2)}°';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1f2937).withValues(alpha: 0.9)
                                : const Color(0xFFeff6ff)
                                    .withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : const Color(0xFF2563eb)
                                      .withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563eb)
                                    .withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF06b6d4),
                                          Color(0xFF0891b2)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.language == AppLanguage.bn
                                          ? 'আমার অবস্থান'
                                          : 'My Location',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : const Color(0xFF4a4a5a),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  if (loading)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          isDark
                                              ? Colors.white
                                              : const Color(0xFF2563eb),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10b981)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.language == AppLanguage.bn
                                            ? 'লাইভ'
                                            : 'Live',
                                        style: const TextStyle(
                                          color: Color(0xFF10b981),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1a1a2e),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    coords,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : const Color(0xFF4a4a5a),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Salat Alarm Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1f2937).withValues(alpha: 0.9)
                            : const Color(0xFFfef3c7).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : const Color(0xFFfbbf24).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFf59e0b)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              color: Color(0xFFf59e0b),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.language == AppLanguage.bn
                                      ? 'সালাত অ্যালার্ম'
                                      : 'Salat Alarm',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1a1a2e),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.alarmEnabled
                                      ? (widget.language == AppLanguage.bn
                                          ? 'চালু'
                                          : 'Enabled')
                                      : (widget.language == AppLanguage.bn
                                          ? 'বন্ধ'
                                          : 'Disabled'),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : const Color(0xFF4a4a5a),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: widget.alarmEnabled,
                            activeColor: const Color(0xFFf59e0b),
                            onChanged: widget.onAlarmToggle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Prayer Times Card
                    FutureBuilder<PrayerTimesModel>(
                      future: _prayerFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                isDark ? Colors.white : const Color(0xFF2563eb),
                              ),
                            ),
                          );
                        }
                        final times = snapshot.data!;

                        // Calculate current/next prayer
                        final now = DateTime.now();

                        // Get tomorrow's Fajr for Isha end time calculation
                        final tomorrowFajr =
                            times.fajr.add(const Duration(days: 1));

                        final prayers = [
                          (
                            label: 'Fajr',
                            bn: 'ফজর',
                            start: times.fajr,
                            end: times.dhuhr
                          ),
                          (
                            label: 'Zuhr',
                            bn: 'যোহর',
                            start: times.dhuhr,
                            end: times.asr
                          ),
                          (
                            label: 'Asr',
                            bn: 'আসর',
                            start: times.asr,
                            end: times.maghrib
                          ),
                          (
                            label: 'Maghrib',
                            bn: 'মাগরিব',
                            start: times.maghrib,
                            end: times.isha
                          ),
                          (
                            label: 'Isha',
                            bn: 'এশা',
                            start: times.isha,
                            end: tomorrowFajr
                          ),
                        ];

                        final currentPrayer = prayers.firstWhere(
                          (p) => now.isAfter(p.start) && now.isBefore(p.end),
                          orElse: () => prayers.firstWhere(
                            (p) => p.label == 'Isha',
                            orElse: () => prayers.first,
                          ),
                        );

                        return Column(
                          children: [
                            // Current Prayer Time Window Card
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: const [
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
                                    color: const Color(0xFF8b5cf6)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.language == AppLanguage.bn
                                                  ? 'বর্তমান নামাজের সময়'
                                                  : 'Current Prayer Time',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.8),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.language == AppLanguage.bn
                                                  ? currentPrayer.bn
                                                  : currentPrayer.label,
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
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.language == AppLanguage.bn
                                                  ? 'শুরু'
                                                  : 'Start',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.7),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatTime(currentPrayer.start),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.language == AppLanguage.bn
                                                  ? 'শেষ'
                                                  : 'End',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.7),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatTime(currentPrayer.end),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PrayerTimesCard(
                              language: widget.language,
                              times: times,
                            ),
                            const SizedBox(height: 16),

                            _ForbiddenPrayerTimesCard(
                              language: widget.language,
                              fajr: times.fajr,
                              dhuhr: times.dhuhr,
                              maghrib: times.maghrib,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Motivational Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: const [
                            Color(0xFF9333ea),
                            Color(0xFF7e22ce),
                            Color(0xFF6b21a8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF9333ea).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Access Header
                    Text(
                      widget.language == AppLanguage.bn
                          ? 'দ্রুত অ্যাক্সেস'
                          : 'Quick Access',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1a1a2e),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Quick Access Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  _QuickAccessButton(
                    icon: Icons.explore_outlined,
                    label: _quickAccessLabel('qibla'),
                    gradient: const [Color(0xFF06b6d4), Color(0xFF0891b2)],
                    onTap: () => widget.onQuickAccessTap(HomeQuickAction.qibla),
                  ),
                  _QuickAccessButton(
                    icon: Icons.self_improvement_outlined,
                    label: _quickAccessLabel('tasbih'),
                    gradient: const [Color(0xFF8b5cf6), Color(0xFF7c3aed)],
                    onTap: () =>
                        widget.onQuickAccessTap(HomeQuickAction.tasbih),
                  ),
                  _QuickAccessButton(
                    icon: Icons.restaurant_menu_outlined,
                    label: _quickAccessLabel('halal'),
                    gradient: const [Color(0xFFec4899), Color(0xFFdb2777)],
                    onTap: () => widget.onQuickAccessTap(HomeQuickAction.halal),
                  ),
                  _QuickAccessButton(
                    icon: Icons.map_outlined,
                    label: _quickAccessLabel('nearestMosque'),
                    gradient: const [Color(0xFFf59e0b), Color(0xFFd97706)],
                    onTap: _openNearestMosque,
                  ),
                  _QuickAccessButton(
                    icon: Icons.school_outlined,
                    label: _quickAccessLabel('deen'),
                    gradient: const [Color(0xFF06b6d4), Color(0xFF0d9488)],
                    onTap: () =>
                        widget.onQuickAccessTap(HomeQuickAction.deenShiksha),
                  ),
                  _QuickAccessButton(
                    icon: Icons.book_outlined,
                    label: _quickAccessLabel('hadith'),
                    gradient: const [Color(0xFF10b981), Color(0xFF059669)],
                    onTap: () =>
                        widget.onQuickAccessTap(HomeQuickAction.hadith),
                  ),
                  _QuickAccessButton(
                    icon: Icons.favorite_outline,
                    label: _quickAccessLabel('duas'),
                    gradient: const [Color(0xFFef4444), Color(0xFFdc2626)],
                    onTap: () => widget.onQuickAccessTap(HomeQuickAction.duas),
                  ),
                  _QuickAccessButton(
                    icon: Icons.handshake_outlined,
                    label: _quickAccessLabel('dhikr'),
                    gradient: const [Color(0xFF14b8a6), Color(0xFF0d9488)],
                    onTap: () => widget.onQuickAccessTap(HomeQuickAction.dhikr),
                  ),
                  _QuickAccessButton(
                    icon: Icons.menu_book_outlined,
                    label: _quickAccessLabel('quran'),
                    gradient: const [Color(0xFF2563eb), Color(0xFF1d4ed8)],
                    onTap: () => widget.onQuickAccessTap(HomeQuickAction.quran),
                  ),
                ]),
              ),
            ),

            // Prayer Checklist at bottom
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.language == AppLanguage.bn
                              ? 'আজকের নামাজ চেকলিস্ট'
                              : 'Today\'s Prayer Checklist',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1a1a2e),
                            letterSpacing: 0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10b981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_prayerCompleted.values.where((v) => v).length}/5',
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
                    FutureBuilder<PrayerTimesModel>(
                      future: _prayerFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                isDark ? Colors.white : const Color(0xFF2563eb),
                              ),
                            ),
                          );
                        }
                        final times = snapshot.data!;
                        final prayers = [
                          (
                            label: 'Fajr',
                            bn: 'ফজর',
                            key: 'fajr',
                            time: times.fajr
                          ),
                          (
                            label: 'Zuhr',
                            bn: 'যোহর',
                            key: 'zuhr',
                            time: times.dhuhr
                          ),
                          (
                            label: 'Asr',
                            bn: 'আসর',
                            key: 'asr',
                            time: times.asr
                          ),
                          (
                            label: 'Maghrib',
                            bn: 'মাগরিব',
                            key: 'maghrib',
                            time: times.maghrib
                          ),
                          (
                            label: 'Isha',
                            bn: 'এশা',
                            key: 'isha',
                            time: times.isha
                          ),
                        ];

                        // Determine next prayer
                        final now = DateTime.now();
                        final nextPrayer = prayers.firstWhere(
                          (p) => p.time.isAfter(now),
                          orElse: () => prayers.first,
                        );

                        return Column(
                          children: prayers.map(
                            (prayer) {
                              final isNextPrayer = prayer.key == nextPrayer.key;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _prayerCompleted[prayer.key]!
                                        ? (isDark
                                            ? const Color(0xFF1e3a8a)
                                                .withValues(alpha: 0.5)
                                            : const Color(0xFFdbeafe)
                                                .withValues(alpha: 0.6))
                                        : (isNextPrayer
                                            ? (isDark
                                                ? const Color(0xFF064e3b)
                                                    .withValues(alpha: 0.5)
                                                : const Color(0xFFd1fae5)
                                                    .withValues(alpha: 0.8))
                                            : (isDark
                                                ? const Color(0xFF1f2937)
                                                    .withValues(alpha: 0.9)
                                                : const Color(0xFFf3f4f6)
                                                    .withValues(alpha: 0.8))),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _prayerCompleted[prayer.key]!
                                          ? const Color(0xFF2563eb)
                                              .withValues(alpha: 0.5)
                                          : (isNextPrayer
                                              ? const Color(0xFF10b981)
                                                  .withValues(alpha: 0.6)
                                              : (isDark
                                                  ? Colors.white
                                                      .withValues(alpha: 0.1)
                                                  : const Color(0xFF2563eb)
                                                      .withValues(alpha: 0.1))),
                                      width: isNextPrayer ? 2 : 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _prayerCompleted[prayer.key]!
                                              ? const Color(0xFF10b981)
                                                  .withValues(alpha: 0.2)
                                              : (isNextPrayer
                                                  ? const Color(0xFF10b981)
                                                      .withValues(alpha: 0.25)
                                                  : const Color(0xFF2563eb)
                                                      .withValues(alpha: 0.15)),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          _prayerCompleted[prayer.key]!
                                              ? Icons.check_circle
                                              : (isNextPrayer
                                                  ? Icons.schedule
                                                  : Icons.done),
                                          color: _prayerCompleted[prayer.key]!
                                              ? const Color(0xFF10b981)
                                              : (isNextPrayer
                                                  ? const Color(0xFF10b981)
                                                  : const Color(0xFF2563eb)),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  widget.language ==
                                                          AppLanguage.bn
                                                      ? prayer.bn
                                                      : prayer.label,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF1a1a2e),
                                                    decoration:
                                                        _prayerCompleted[
                                                                prayer.key]!
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : null,
                                                  ),
                                                ),
                                                if (isNextPrayer)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFF10b981),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        widget.language ==
                                                                AppLanguage.bn
                                                            ? 'পরবর্তী'
                                                            : 'Next',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              DateFormat('h:mm a')
                                                  .format(prayer.time),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.white70
                                                    : const Color(0xFF6b7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Checkbox(
                                        value: _prayerCompleted[prayer.key]!,
                                        onChanged: (val) {
                                          setState(() {
                                            _prayerCompleted[prayer.key] =
                                                val ?? false;
                                          });
                                        },
                                        activeColor: const Color(0xFF10b981),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: const SizedBox(height: 20),
            ),
          ],
        ),
      ),
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

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'Fajr', bn: 'ফজর', start: times.fajr),
      (label: 'Zuhr', bn: 'যোহর', start: times.dhuhr),
      (label: 'Asr', bn: 'আসর', start: times.asr),
      (label: 'Maghrib', bn: 'মাগরিব', start: times.maghrib),
      (label: 'Isha', bn: 'এশা', start: times.isha),
    ];

    final now = DateTime.now();
    final next = items.firstWhere(
      (p) => p.start.isAfter(now),
      orElse: () => items.first,
    );
    final left = next.start.difference(now);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [
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
                      language == AppLanguage.bn ? next.bn : next.label,
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
                    '${left.inHours}h',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${left.inMinutes.remainder(60)}m',
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: items
                  .map(
                    (prayer) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            language == AppLanguage.bn
                                ? prayer.bn
                                : prayer.label,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(prayer.start),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
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
          scale: _pressed ? 0.94 : (active ? 1.02 : 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.fg.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.fg.withValues(alpha: active ? 0.3 : 0.12),
                  blurRadius: active ? 20 : 12,
                  offset: Offset(0, active ? 10 : 6),
                  spreadRadius: active ? 1 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(20),
                splashColor: widget.fg.withValues(alpha: 0.15),
                highlightColor: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      scale: active ? 1.12 : 1,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.fg.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.fg,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: widget.fg,
                        fontSize: 13,
                        height: 1.3,
                      ),
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

class _ForbiddenPrayerTimesCard extends StatefulWidget {
  final AppLanguage language;
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime maghrib;

  const _ForbiddenPrayerTimesCard({
    required this.language,
    required this.fajr,
    required this.dhuhr,
    required this.maghrib,
  });

  @override
  State<_ForbiddenPrayerTimesCard> createState() =>
      _ForbiddenPrayerTimesCardState();
}

class _ForbiddenPrayerTimesCardState extends State<_ForbiddenPrayerTimesCard> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Calculate the three forbidden prayer times (nisiddo times)
    // 1. Ishraq (After Sunrise): 15-20 minutes after Fajr starts
    final ishraqStart = widget.fajr.add(const Duration(minutes: 15));
    final ishraqEnd = widget.fajr.add(const Duration(minutes: 20));

    // 2. Zawal (Sun at Zenith/Midday): 5-10 minutes before Dhuhr
    final zawalStart = widget.dhuhr.subtract(const Duration(minutes: 10));
    final zawalEnd = widget.dhuhr;

    // 3. Ghuruub (During Sunset): From Maghrib start until 15-20 minutes after
    final ghuruubStart = widget.maghrib;
    final ghuruubEnd = widget.maghrib.add(const Duration(minutes: 20));

    // Check if currently in any forbidden time
    final inIshraq = now.isAfter(ishraqStart) && now.isBefore(ishraqEnd);
    final inZawal = now.isAfter(zawalStart) && now.isBefore(zawalEnd);
    final inGhuruub = now.isAfter(ghuruubStart) && now.isBefore(ghuruubEnd);
    final inForbiddenTime = inIshraq || inZawal || inGhuruub;

    String forbiddenLabel = '';
    if (inIshraq) {
      forbiddenLabel =
          widget.language == AppLanguage.bn ? 'ইশরাক' : 'Ishraq (Sunrise)';
    } else if (inZawal) {
      forbiddenLabel =
          widget.language == AppLanguage.bn ? 'যোহরের সময়' : 'Zawal (Midday)';
    } else if (inGhuruub) {
      forbiddenLabel = widget.language == AppLanguage.bn
          ? 'সূর্যাস্তের সময়'
          : 'Ghuruub (Sunset)';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: inForbiddenTime
              ? const [Color(0xFFEF5350), Color(0xFFE53935)]
              : const [Color(0xFF6B4C9A), Color(0xFF9B6FA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: inForbiddenTime
                ? const Color(0xFFEF5350).withValues(alpha: 0.4)
                : const Color(0xFF6B4C9A).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: inForbiddenTime ? 4 : 2,
          ),
        ],
        border:
            inForbiddenTime ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.block_outlined,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.language == AppLanguage.bn
                          ? 'নামাজ নিষিদ্ধ সময় (নিসিদ্ধ)'
                          : 'Forbidden Prayer Times (Nisiddo)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(now),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              if (inForbiddenTime)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    forbiddenLabel,
                    style: const TextStyle(
                      color: Color(0xFFEF5350),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Ishraq (After Sunrise)
          _ForbiddenTimeRow(
            language: widget.language,
            label: widget.language == AppLanguage.bn
                ? 'ইশরাক'
                : 'Ishraq (Sunrise)',
            start: _formatTime(ishraqStart),
            end: _formatTime(ishraqEnd),
            isActive: inIshraq,
          ),
          const SizedBox(height: 8),
          // Zawal
          _ForbiddenTimeRow(
            language: widget.language,
            label: widget.language == AppLanguage.bn
                ? 'যোহরের সময়'
                : 'Zawal (Midday)',
            start: _formatTime(zawalStart),
            end: _formatTime(zawalEnd),
            isActive: inZawal,
          ),
          const SizedBox(height: 8),
          // Ghuruub (During Sunset)
          _ForbiddenTimeRow(
            language: widget.language,
            label: widget.language == AppLanguage.bn
                ? 'সূর্যাস্তের সময়'
                : 'Ghuruub (Sunset)',
            start: _formatTime(ghuruubStart),
            end: _formatTime(ghuruubEnd),
            isActive: inGhuruub,
          ),
          const SizedBox(height: 10),
          Text(
            widget.language == AppLanguage.bn
                ? 'ইসলামী নিয়মে এই সময়গুলিতে নামাজ নিষিদ্ধ'
                : 'Prayer is discouraged during these times in Islam',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForbiddenTimeRow extends StatelessWidget {
  final AppLanguage language;
  final String label;
  final String start;
  final String end;
  final bool isActive;

  const _ForbiddenTimeRow({
    required this.language,
    required this.label,
    required this.start,
    required this.end,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Text(
            '$start - $end',
            style: TextStyle(
              color: isActive ? const Color(0xFFEF5350) : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// Ramadan Calendar Sheet Widget
class RamadanCalendarSheet extends StatefulWidget {
  final AppLanguage language;
  const RamadanCalendarSheet({super.key, required this.language});

  @override
  State<RamadanCalendarSheet> createState() => _RamadanCalendarSheetState();
}

class _RamadanCalendarSheetState extends State<RamadanCalendarSheet> {
  late int _ramadanYear;

  @override
  void initState() {
    super.initState();
    final hijri = HijriCalendarConfig.now();
    _ramadanYear = hijri.hYear;
  }

  String _monthName(int month) {
    const monthsEn = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhul Qa\'dah',
      'Dhul Hijjah',
    ];
    const monthsBn = [
      'মুহাররম',
      'সফর',
      'রবিউল আউয়াল',
      'রবিউল থানি',
      'জুমাদা উল আউয়াল',
      'জুমাদা উল থানি',
      'রজব',
      'শা\'বান',
      'রমজান',
      'শাওয়াল',
      'ধুল-কা\'দাহ',
      'ধুল-হিজ্জাহ',
    ];

    if (widget.language == AppLanguage.bn) {
      return monthsBn[(month - 1).clamp(0, 11)];
    }
    return monthsEn[(month - 1).clamp(0, 11)];
  }

  String _dayName(int dayNo) {
    const daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const daysBn = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি'];

    if (widget.language == AppLanguage.bn) {
      return daysBn[dayNo];
    }
    return daysEn[dayNo];
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendarConfig.now();
    final isRamadan = hijri.hMonth == 9;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 1,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.language == AppLanguage.bn
                            ? 'ইসলামিক ক্যালেন্ডার'
                            : 'Islamic Calendar',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Material(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.close),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hijri Date Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8B2635),
                          Color(0xFFC23B57),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.language == AppLanguage.bn
                              ? 'আজকের হিজরি তারিখ'
                              : 'Today\'s Hijri Date',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${hijri.hDay} ${_monthName(hijri.hMonth)} ${hijri.hYear} AH',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (isRamadan)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.nightlight_round,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.language == AppLanguage.bn
                                          ? 'রমজান চলছে'
                                          : 'Ramadan is here',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ramadan Calendar Year
                  Text(
                    widget.language == AppLanguage.bn
                        ? 'রমজানের দিন (${_ramadanYear}H)'
                        : 'Days of Ramadan (${_ramadanYear}H)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weekday Headers
                  Row(
                    children: List.generate(
                      7,
                      (index) => Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _dayName(index),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Calendar Grid
                  Column(
                    children: [
                      for (int week = 0; week < 6; week++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: List.generate(
                              7,
                              (dayIndex) {
                                final cellIndex = week * 7 + dayIndex;
                                final day = cellIndex < 7
                                    ? null
                                    : (cellIndex - 7 < 30
                                        ? cellIndex - 6
                                        : null);

                                if (day == null) {
                                  return Expanded(
                                    child: Container(),
                                  );
                                }

                                final isToday = hijri.hDay == day &&
                                    hijri.hMonth == 9 &&
                                    hijri.hYear == _ramadanYear;

                                return Expanded(
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? const Color(0xFF8B2635)
                                          : (day == 1 || day == 27 || day == 30
                                              ? Colors.orange[100]
                                              : Colors.grey[100]),
                                      borderRadius: BorderRadius.circular(12),
                                      border: isToday
                                          ? Border.all(
                                              color: const Color(0xFFC23B57),
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          // Handle day tap if needed
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '$day',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                  color: isToday
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              if (day == 1)
                                                Text(
                                                  widget.language ==
                                                          AppLanguage.bn
                                                      ? 'শুরু'
                                                      : 'Start',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              if (day == 27)
                                                Text(
                                                  widget.language ==
                                                          AppLanguage.bn
                                                      ? 'লাইল'
                                                      : 'Lail',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              if (day == 30)
                                                Text(
                                                  widget.language ==
                                                          AppLanguage.bn
                                                      ? 'শেষ'
                                                      : 'End',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Legend
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.language == AppLanguage.bn
                              ? 'গুরুত্বপূর্ণ দিন'
                              : 'Important Days',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _LegendItem(
                          language: widget.language,
                          color: Colors.orange,
                          label: widget.language == AppLanguage.bn
                              ? 'বিশেষ দিন (শুরু, লাইলাতুল কদর, শেষ)'
                              : 'Special Days (Start, Lailat al-Qadr, End)',
                        ),
                        const SizedBox(height: 8),
                        _LegendItem(
                          language: widget.language,
                          color: const Color(0xFF8B2635),
                          label: widget.language == AppLanguage.bn
                              ? 'আজকের দিন'
                              : 'Today',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final AppLanguage language;
  final Color color;
  final String label;

  const _LegendItem({
    required this.language,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// New Modern Quick Access Button
class _QuickAccessButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_QuickAccessButton> createState() => _QuickAccessButtonState();
}

class _QuickAccessButtonState extends State<_QuickAccessButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: widget.gradient[1].withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Intentionally empty: HomeScreen gets its prayer method from app settings.
