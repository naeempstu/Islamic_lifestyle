import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../core/models/app_enums.dart';
import '../core/models/app_settings.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/dhikr/data/dhikr_repository.dart';
import '../features/duas/data/duas_repository.dart';
import '../features/halal/screens/halal_guide_screen.dart';
import '../screens/home/home_screen_new.dart';

import '../features/prayer/services/prayer_times_service.dart';

import '../features/qibla/screens/qibla_screen.dart';
import '../features/routine/data/daily_routine_store.dart';
import '../features/routine/screens/habits_screen.dart';
import '../features/ramadan/screens/ramadan_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/tasbih/screens/tasbih_only_screen.dart';
import '../features/deen_shiksha/screens/deen_shiksha_screen.dart';
import '../features/dhikr/screens/dhikr_screen.dart';
import '../features/hadith/screens/hadith_reader_screen.dart';
import '../features/ai_chat/screens/ai_chat_screen.dart';
import '../features/duas/screens/duas_screen.dart';
import '../features/quran/screens/quran_list_screen.dart';
import '../widgets/quick_access_grid.dart';

class MainShell extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  final LocationService locationService;
  final PrayerTimesService prayerTimesService;
  final DailyRoutineStore routineStore;

  const MainShell({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.locationService,
    required this.prayerTimesService,
    required this.routineStore,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const SystemUiOverlayStyle _lightStatusBar =
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      );

  static const SystemUiOverlayStyle _darkStatusBar =
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      );

  @override
  void initState() {
    super.initState();
    _reschedulePrayerNotifications();
  }

  Future<void> _reschedulePrayerNotifications() async {
    if (!widget.settings.notificationsEnabled) {
      await NotificationService.instance.cancelPrayerNotifications();
      return;
    }
    final (lat, lng) = await widget.locationService.getLatLngOrFallback();
    final times = widget.prayerTimesService.calculateFor(
      latitude: lat,
      longitude: lng,
      method: widget.settings.prayerCalculationMethod,
    );
    await NotificationService.instance.cancelPrayerNotifications();
    await NotificationService.instance.schedulePrayerNotifications(
      times: times,
      enabled: widget.settings.azanEnabled,
    );
  }

  Future<void> _toggleAlarm(bool enabled) async {
    final next = widget.settings.copyWith(notificationsEnabled: enabled);
    widget.onSettingsChanged(next);
    await _reschedulePrayerNotifications();
  }

  Future<void> _handleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  Future<void> _onHomeQuickAccess(QuickAccessAction action) async {
    switch (action) {
      case QuickAccessAction.qibla:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QiblaScreen(
              language: widget.settings.language,
              locationService: widget.locationService,
            ),
          ),
        );
        break;
      case QuickAccessAction.tasbih:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TasbihOnlyScreen(
              language: widget.settings.language,
              vibrationEnabled: widget.settings.vibrationEnabled,
            ),
          ),
        );
        break;
      case QuickAccessAction.dhikr:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DhikrScreen(
              language: widget.settings.language,
              vibrationEnabled: widget.settings.vibrationEnabled,
              dhikrRepository: DhikrRepository(),
            ),
          ),
        );
        break;
      case QuickAccessAction.quran:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const QuranListScreen(),
          ),
        );
        break;
      case QuickAccessAction.hadith:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HadithReaderScreen(
              language: widget.settings.language,
            ),
          ),
        );
        break;
      case QuickAccessAction.duas:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DuasScreen(
              language: widget.settings.language,
              repository: DuasRepository(),
            ),
          ),
        );
        break;
      case QuickAccessAction.nearestMosque:
        break;
      case QuickAccessAction.halal:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HalalGuideScreen(
              language: widget.settings.language,
            ),
          ),
        );
        break;
      case QuickAccessAction.deen:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DeenShikshaScreen(
              language: widget.settings.language,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.settings.language;

    return Scaffold(
      drawer: _AppDrawer(
        language: lang,
        onOpenSettings: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                language: lang,
                settings: widget.settings,
                onSettingsChanged: (s) async {
                  widget.onSettingsChanged(s);
                  await _reschedulePrayerNotifications();
                },
                onSignOut: _handleSignOut,
              ),
            ),
          );
        },
        onOpenHalal: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => HalalGuideScreen(language: lang)),
          );
        },
        onOpenRamadan: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RamadanScreen(
                language: lang,
                locationService: widget.locationService,
                prayerTimesService: widget.prayerTimesService,
                prayerCalculationMethod:
                    widget.settings.prayerCalculationMethod,
              ),
            ),
          );
        },
        onOpenHadith: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HadithReaderScreen(
                language: lang,
              ),
            ),
          );
        },
      ),
      body: IndexedStack(
        index: _index,
        children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: _lightStatusBar,
            child: HomeScreenNew(
              language: lang,
              prayerCalculationMethod: widget.settings.prayerCalculationMethod,
              locationService: widget.locationService,
              prayerTimesService: widget.prayerTimesService,
              alarmEnabled: widget.settings.notificationsEnabled,
              onAlarmToggle: _toggleAlarm,
              onQuickAccessTap: _onHomeQuickAccess,
              onOpenCalendar: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CalendarScreen(
                      language: lang,
                    ),
                  ),
                );
              },
              onOpenRamadan: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RamadanScreen(
                      language: lang,
                      locationService: widget.locationService,
                      prayerTimesService: widget.prayerTimesService,
                      prayerCalculationMethod:
                          widget.settings.prayerCalculationMethod,
                    ),
                  ),
                );
              },
              onOpenSettings: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      language: lang,
                      settings: widget.settings,
                      onSettingsChanged: (s) async {
                        widget.onSettingsChanged(s);
                        await _reschedulePrayerNotifications();
                      },
                      onSignOut: _handleSignOut,
                    ),
                  ),
                );
              },
            ),
          ),
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: _darkStatusBar,
            child: SafeArea(child: QuranListScreen()),
          ),
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: _darkStatusBar,
            child: SafeArea(
              child: HabitsScreen(
                language: lang,
                routineStore: widget.routineStore,
              ),
            ),
          ),
          const AnnotatedRegion<SystemUiOverlayStyle>(
            value: _darkStatusBar,
            child: SafeArea(child: AIChatScreen()),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E8C58),
        unselectedItemColor: const Color(0xFF1F2033),
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: lang == AppLanguage.bn ? 'হোম' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            label: lang == AppLanguage.bn ? 'কুরআন' : "Qur'an",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checklist_outlined),
            label: lang == AppLanguage.bn ? 'হ্যাবিট' : 'Habits',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.smart_toy_outlined),
            label: lang == AppLanguage.bn ? 'এআই চ্যাট' : 'AI Chat',
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final AppLanguage language;
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onOpenHalal;
  final Future<void> Function() onOpenRamadan;
  final Future<void> Function() onOpenHadith;

  const _AppDrawer({
    required this.language,
    required this.onOpenSettings,
    required this.onOpenHalal,
    required this.onOpenRamadan,
    required this.onOpenHadith,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/picture/logo1.jpeg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  language == AppLanguage.bn
                      ? 'আল্লাহর পথে'
                      : 'On the path of peace',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.food_bank_outlined),
            title: Text(
              language == AppLanguage.bn ? 'হালাল গাইড' : 'Halal guide',
            ),
            onTap: () {
              Navigator.pop(context);
              onOpenHalal();
            },
          ),
          ListTile(
            leading: const Icon(Icons.nights_stay_outlined),
            title: Text(
              language == AppLanguage.bn ? 'রমজান মোড' : 'Ramadan mode',
            ),
            onTap: () {
              Navigator.pop(context);
              onOpenRamadan();
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: Text(
              language == AppLanguage.bn ? 'হাদিস' : 'Hadith',
            ),
            onTap: () {
              Navigator.pop(context);
              onOpenHadith();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(language == AppLanguage.bn ? 'সেটিংস' : 'Settings'),
            onTap: () {
              Navigator.pop(context);
              onOpenSettings();
            },
          ),
        ],
      ),
    );
  }
}
