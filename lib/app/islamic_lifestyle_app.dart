import 'package:flutter/material.dart';

import '../core/models/app_settings.dart';
import '../core/services/firebase_init.dart';
import '../core/services/location_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/push_notification_service.dart';
import '../core/storage/app_prefs.dart';
import '../core/theme/app_theme.dart';
import '../features/dhikr/data/dhikr_repository.dart';
import '../features/duas/data/duas_repository.dart';
import '../features/prayer/services/prayer_times_service.dart';
import '../features/quran/data/quran_repository.dart';
import '../features/hadith/data/hadith_repository.dart';
import '../features/routine/data/daily_routine_store.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import 'main_shell.dart';

class IslamicLifestyleApp extends StatefulWidget {
  const IslamicLifestyleApp({super.key});

  @override
  State<IslamicLifestyleApp> createState() => _IslamicLifestyleAppState();
}

class _IslamicLifestyleAppState extends State<IslamicLifestyleApp> {
  bool _loading = true;
  AppPrefs? _prefs;
  AppSettings? _settings;
  bool _onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final prefs = await AppPrefs.init();
      final settings = await prefs.loadSettings();

      final firebaseReady = await FirebaseInit.initialize();
      await NotificationService.instance.init();
      if (firebaseReady) {
        await PushNotificationService.instance.init();
      }

      await prefs.ensureGuestId();

      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _settings = settings;
        _onboardingComplete = prefs.onboardingComplete;
        _loading = false;
      });
    } catch (e) {
      // Never block UI on bootstrap failures.
      final prefs = await AppPrefs.init();
      final fallbackSettings = await prefs.loadSettings();
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _settings = fallbackSettings;
        _onboardingComplete = prefs.onboardingComplete;
        _loading = false;
      });
    }
  }

  Future<void> _updateSettings(AppSettings settings) async {
    setState(() => _settings = settings);
    await _prefs?.saveSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _settings == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(darkMode: false),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final settings = _settings!;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      theme: AppTheme.light(darkMode: settings.darkMode),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: _onboardingComplete
          ? MainShell(
              settings: settings,
              onSettingsChanged: _updateSettings,
              locationService: LocationService(),
              prayerTimesService: PrayerTimesService.instance,
              routineStore: DailyRoutineStore(),
              quranRepository: QuranRepository(),
              dhikrRepository: DhikrRepository(),
              duasRepository: DuasRepository(),
              hadithRepository: HadithRepository(),
            )
          : OnboardingScreen(
              prefs: _prefs!,
              initialSettings: settings,
              onCompleted: (updated) async {
                await _updateSettings(updated);
                setState(() => _onboardingComplete = true);
              },
            ),
    );
  }
}

