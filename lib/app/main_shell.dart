import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/models/app_enums.dart';
import '../core/models/app_settings.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';
import '../features/dhikr/data/dhikr_repository.dart';
import '../features/duas/data/duas_repository.dart';
import '../features/halal/screens/halal_guide_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/prayer/screens/prayer_times_screen.dart';
import '../features/prayer/services/prayer_times_service.dart';
import '../features/quran/data/quran_repository.dart';
import '../features/quran/screens/quran_reader_screen.dart';
import '../features/qibla/screens/qibla_screen.dart';
import '../features/routine/data/daily_routine_store.dart';
import '../features/routine/screens/habits_screen.dart';
import '../features/ramadan/screens/ramadan_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/dhikr/screens/dhikr_screen.dart';
import '../features/tasbih/screens/tasbih_only_screen.dart';
import '../features/masjid/screens/masjid_locator_screen.dart';
import '../features/deen_shiksha/screens/deen_shiksha_screen.dart';
import '../features/hadith/data/hadith_repository.dart';
import '../features/hadith/screens/hadith_reader_screen.dart';

class MainShell extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  final LocationService locationService;
  final PrayerTimesService prayerTimesService;
  final DailyRoutineStore routineStore;

  final QuranRepository quranRepository;
  final DhikrRepository dhikrRepository;
  final DuasRepository duasRepository;
  final HadithRepository hadithRepository;

  const MainShell({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.locationService,
    required this.prayerTimesService,
    required this.routineStore,
    required this.quranRepository,
    required this.dhikrRepository,
    required this.duasRepository,
    required this.hadithRepository,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

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

  Future<void> _onHomeQuickAction(HomeQuickAction action) async {
    switch (action) {
      case HomeQuickAction.quran:
        setState(() => _index = 2);
        break;
      case HomeQuickAction.tasbih:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TasbihOnlyScreen(
              language: widget.settings.language,
              vibrationEnabled: widget.settings.vibrationEnabled,
            ),
          ),
        );
        break;
      case HomeQuickAction.halal:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                HalalGuideScreen(language: widget.settings.language),
          ),
        );
        break;
      case HomeQuickAction.qibla:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QiblaScreen(
              language: widget.settings.language,
              locationService: widget.locationService,
            ),
          ),
        );
        break;
      case HomeQuickAction.masjid:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MasjidLocatorScreen(
              language: widget.settings.language,
              locationService: widget.locationService,
            ),
          ),
        );
        break;
      case HomeQuickAction.deenShiksha:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                DeenShikshaScreen(language: widget.settings.language),
          ),
        );
        break;
      case HomeQuickAction.hadith:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HadithReaderScreen(
              language: widget.settings.language,
              hadithRepository: widget.hadithRepository,
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
                hadithRepository: widget.hadithRepository,
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              language: lang,
              prayerCalculationMethod: widget.settings.prayerCalculationMethod,
              locationService: widget.locationService,
              prayerTimesService: widget.prayerTimesService,
              alarmEnabled: widget.settings.notificationsEnabled,
              onAlarmToggle: _toggleAlarm,
              onQuickAccessTap: _onHomeQuickAction,
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
            PrayerTimesScreen(
              language: lang,
              settings: widget.settings,
              onSettingsChanged: (s) async {
                widget.onSettingsChanged(s);
                // Reschedule azan reminders when toggles change.
                await _reschedulePrayerNotifications();
              },
              locationService: widget.locationService,
              prayerTimesService: widget.prayerTimesService,
            ),
            QuranReaderScreen(
              language: lang,
              quranRepository: widget.quranRepository,
            ),
            DhikrScreen(
              language: lang,
              vibrationEnabled: widget.settings.vibrationEnabled,
              dhikrRepository: widget.dhikrRepository,
              duasRepository: widget.duasRepository,
            ),
            HabitsScreen(language: lang, routineStore: widget.routineStore),
          ],
        ),
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
            icon: const Icon(Icons.access_time_outlined),
            label: lang == AppLanguage.bn ? 'নামাজ' : 'Prayer',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            label: lang == AppLanguage.bn ? 'কুরআন' : "Qur'an",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.self_improvement_outlined),
            label: lang == AppLanguage.bn ? 'যিকির' : 'Dhikr',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checklist_outlined),
            label: lang == AppLanguage.bn ? 'হ্যাবিট' : 'Habits',
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
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                language == AppLanguage.bn
                    ? 'আল্লাহর পথে'
                    : 'On the path of peace',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
