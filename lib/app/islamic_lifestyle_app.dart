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
import '../features/hadith/data/hadith_repository.dart';
import '../features/quran/data/quran_repository.dart';
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

      // 🚀 Optimize: Run non-critical initialization in parallel
      //    Don't block the UI on these
      Future.microtask(() async {
        try {
          await FirebaseInit.initialize();
        } catch (e) {
          debugPrint('Firebase init error: $e');
        }
      });

      Future.microtask(() async {
        try {
          await NotificationService.instance.init();
        } catch (e) {
          debugPrint('Notification init error: $e');
        }
      });

      Future.microtask(() async {
        try {
          // Delay push notification init slightly to ensure Firebase is initialized
          await Future.delayed(const Duration(milliseconds: 500));
          await PushNotificationService.instance.init();
        } catch (e) {
          debugPrint('Push notification init error: $e');
        }
      });

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
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _settings?.language.toString() == 'AppLanguage.bn'
                      ? 'লোড হচ্ছে...'
                      : 'Loading...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
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
              dhikrRepository: DhikrRepository(),
              duasRepository: DuasRepository(),
              hadithRepository: HadithRepository(),
              quranRepository: QuranRepository(),
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
