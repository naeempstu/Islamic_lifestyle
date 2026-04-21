import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/app_enums.dart';
import '../../core/services/location_service.dart';
import '../../features/prayer/services/prayer_times_service.dart';
import '../../providers/home_provider.dart';
import '../../widgets/header_section.dart';
import '../../widgets/prayer_card.dart';
import '../../widgets/forbidden_time_card.dart';
import '../../widgets/quick_access_grid.dart';
import '../../widgets/checklist_section.dart';
import '../../features/home/data/gentle_messages.dart';

class HomeScreenNew extends StatefulWidget {
  final AppLanguage language;
  final PrayerCalculationMethod prayerCalculationMethod;
  final LocationService locationService;
  final PrayerTimesService prayerTimesService;
  final bool alarmEnabled;
  final ValueChanged<bool> onAlarmToggle;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenRamadan;

  const HomeScreenNew({
    super.key,
    required this.language,
    required this.prayerCalculationMethod,
    required this.locationService,
    required this.prayerTimesService,
    required this.alarmEnabled,
    required this.onAlarmToggle,
    required this.onOpenSettings,
    required this.onOpenRamadan,
  });

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  late HomeProvider _homeProvider;

  @override
  void initState() {
    super.initState();
    _homeProvider = HomeProvider(
      prayerTimesService: widget.prayerTimesService,
      locationService: widget.locationService,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeProvider.initialize(widget.prayerCalculationMethod);
    });
  }

  @override
  void dispose() {
    _homeProvider.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await _homeProvider.refreshData(widget.prayerCalculationMethod);
  }

  void _handleQuickAccess(QuickAccessAction action) {
    switch (action) {
      case QuickAccessAction.qibla:
        // Navigate to Qibla screen
        break;
      case QuickAccessAction.tasbih:
        // Navigate to Tasbih screen
        break;
      case QuickAccessAction.quran:
        // Navigate to Quran screen
        break;
      case QuickAccessAction.hadith:
        // Navigate to Hadith screen
        break;
      case QuickAccessAction.duas:
        // Navigate to Duas screen
        break;
      case QuickAccessAction.nearestMosque:
        _openNearestMosque();
        break;
      case QuickAccessAction.halal:
        // Navigate to Halal screen
        break;
      case QuickAccessAction.deen:
        // Navigate to Deen Education screen
        break;
    }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.language == AppLanguage.bn
                  ? 'গুগল ম্যাপ খোলা যায়নি'
                  : 'Could not open Google Maps',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final message = GentleMessages.dailyFor(widget.language, date: now);

    return ChangeNotifierProvider<HomeProvider>.value(
      value: _homeProvider,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Consumer<HomeProvider>(
            builder: (context, homeProvider, _) {
              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: HeaderSection(
                      language: widget.language,
                      onSettingsTap: widget.onOpenSettings,
                      onRamadanTap: widget.onOpenRamadan,
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
                          _LocationCard(
                            language: widget.language,
                            locationName: homeProvider.locationName,
                            latitude: homeProvider.latitude,
                            longitude: homeProvider.longitude,
                            isLoading: homeProvider.isLoading,
                          ),
                          const SizedBox(height: 16),

                          // Salat Alarm Card
                          _SalatAlarmCard(
                            language: widget.language,
                            alarmEnabled: widget.alarmEnabled,
                            onToggle: widget.onAlarmToggle,
                          ),
                          const SizedBox(height: 16),

                          // Prayer Times Section
                          if (homeProvider.prayerTimes != null) ...[
                            PrayerTimesCard(
                              language: widget.language,
                              times: homeProvider.prayerTimes!,
                            ),
                            const SizedBox(height: 16),
                            ForbiddenPrayerTimesCard(
                              language: widget.language,
                              fajr: homeProvider.prayerTimes!.fajr,
                              dhuhr: homeProvider.prayerTimes!.dhuhr,
                              maghrib: homeProvider.prayerTimes!.maghrib,
                            ),
                          ] else if (homeProvider.isLoading)
                            Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  isDark
                                      ? Colors.white
                                      : const Color(0xFF2563eb),
                                ),
                              ),
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
                                  color: const Color(0xFF9333ea)
                                      .withValues(alpha: 0.3),
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
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1a1a2e),
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
                    sliver: SliverToBoxAdapter(
                      child: QuickAccessGrid(
                        language: widget.language,
                        onActionTap: _handleQuickAccess,
                      ),
                    ),
                  ),

                  // Prayer Checklist
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
                      child: homeProvider.prayerTimes != null
                          ? ChecklistSection(
                              language: widget.language,
                              times: homeProvider.prayerTimes!,
                              completed: homeProvider.prayerCompleted,
                              onToggle: (key) =>
                                  homeProvider.togglePrayerCompletion(key),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: const SizedBox(height: 20),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final AppLanguage language;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final bool isLoading;

  const _LocationCard({
    required this.language,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.isLoading,
  });

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = locationName ?? '';
    final title = name.isEmpty
        ? (language == AppLanguage.bn ? 'লোড হচ্ছে...' : 'Loading...')
        : (language == AppLanguage.bn ? _locationNameToBengali(name) : name);
    final coords = latitude == null || longitude == null
        ? '—'
        : '${latitude!.toStringAsFixed(2)}°, ${longitude!.toStringAsFixed(2)}°';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1f2937).withValues(alpha: 0.9)
            : const Color(0xFFeff6ff).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : const Color(0xFF2563eb).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563eb).withValues(alpha: 0.1),
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
                      Color(0xFF0891b2),
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
                  language == AppLanguage.bn ? 'আমার অবস্থান' : 'My Location',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF4a4a5a),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      isDark ? Colors.white : const Color(0xFF2563eb),
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10b981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    language == AppLanguage.bn ? 'লাইভ' : 'Live',
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
                  color: isDark ? Colors.white : const Color(0xFF1a1a2e),
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
  }
}

class _SalatAlarmCard extends StatelessWidget {
  final AppLanguage language;
  final bool alarmEnabled;
  final ValueChanged<bool> onToggle;

  const _SalatAlarmCard({
    required this.language,
    required this.alarmEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              color: const Color(0xFFf59e0b).withValues(alpha: 0.15),
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
                  language == AppLanguage.bn
                      ? 'সালাত অ্যালার্ম'
                      : 'Salat Alarm',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1a1a2e),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alarmEnabled
                      ? (language == AppLanguage.bn ? 'চালু' : 'Enabled')
                      : (language == AppLanguage.bn ? 'বন্ধ' : 'Disabled'),
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
            value: alarmEnabled,
            activeColor: const Color(0xFFf59e0b),
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
