import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_enums.dart';
import '../models/app_settings.dart';

class AppPrefs {
  static const _kOnboardingComplete = 'onboarding_complete';
  static const _kLanguage = 'language';
  static const _kDarkMode = 'dark_mode';
  static const _kPrayerMethod = 'prayer_method';
  static const _kNotificationsEnabled = 'notifications_enabled';
  static const _kVibrationEnabled = 'vibration_enabled';
  static const _kAzanEnabled = 'azan_enabled'; // JSON map

  static const _kGuestId = 'guest_id';

  final SharedPreferences _prefs;

  AppPrefs(this._prefs);

  static Future<AppPrefs> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPrefs(prefs);
  }

  bool get onboardingComplete => _prefs.getBool(_kOnboardingComplete) ?? false;

  String? get guestId => _prefs.getString(_kGuestId);

  Future<void> ensureGuestId() async {
    if (_prefs.getString(_kGuestId) != null) return;
    _prefs.setString(_kGuestId, DateTime.now().microsecondsSinceEpoch.toString());
  }

  Future<AppSettings> loadSettings() async {
    final languageKey = _prefs.getString(_kLanguage) ?? AppLanguage.en.code;
    final language = switch (languageKey) {
      'bn' => AppLanguage.bn,
      _ => AppLanguage.en,
    };

    final darkMode = _prefs.getBool(_kDarkMode) ?? false;
    final methodKey = _prefs.getString(_kPrayerMethod) ??
        PrayerCalculationMethod.karachi.key;
    final prayerMethod = PrayerCalculationMethodX.fromKey(methodKey);
    final notificationsEnabled = _prefs.getBool(_kNotificationsEnabled) ?? true;
    final vibrationEnabled = _prefs.getBool(_kVibrationEnabled) ?? true;

    final azanJson = _prefs.getString(_kAzanEnabled);
    final defaultAzan = AppSettings.defaults().azanEnabled;

    if (azanJson == null || azanJson.isEmpty) {
      return AppSettings.defaults().copyWith(
        language: language,
        darkMode: darkMode,
        prayerCalculationMethod: prayerMethod,
        notificationsEnabled: notificationsEnabled,
        vibrationEnabled: vibrationEnabled,
      );
    }

    final Map<String, dynamic> map = (jsonDecode(azanJson) as Map).cast<String, dynamic>();
    final parsedAzan = <PrayerName, bool>{};
    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value == true;
      parsedAzan[_fromAzanKey(key)] = value;
    }

    return AppSettings.defaults().copyWith(
      language: language,
      darkMode: darkMode,
      prayerCalculationMethod: prayerMethod,
      notificationsEnabled: notificationsEnabled,
      vibrationEnabled: vibrationEnabled,
      azanEnabled: parsedAzan.isEmpty ? defaultAzan : parsedAzan,
    );
  }

  PrayerName _fromAzanKey(String key) {
    return switch (key) {
      'fajr' => PrayerName.fajr,
      'dhuhr' => PrayerName.dhuhr,
      'asr' => PrayerName.asr,
      'maghrib' => PrayerName.maghrib,
      'isha' => PrayerName.isha,
      _ => PrayerName.fajr,
    };
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_kLanguage, settings.language.code);
    await _prefs.setBool(_kDarkMode, settings.darkMode);
    await _prefs.setString(_kPrayerMethod, settings.prayerCalculationMethod.key);
    await _prefs.setBool(_kNotificationsEnabled, settings.notificationsEnabled);
    await _prefs.setBool(_kVibrationEnabled, settings.vibrationEnabled);

    final azanMap = <String, bool>{};
    settings.azanEnabled.forEach((k, v) => azanMap[k.key] = v);
    await _prefs.setString(_kAzanEnabled, jsonEncode(azanMap));
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_kOnboardingComplete, value);
  }
}

