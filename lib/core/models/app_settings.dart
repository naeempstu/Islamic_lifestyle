import 'package:flutter/material.dart';

import 'app_enums.dart';

class AppSettings {
  final AppLanguage language;
  final bool darkMode;
  final PrayerCalculationMethod prayerCalculationMethod;
  final bool notificationsEnabled;
  final Map<PrayerName, bool> azanEnabled;
  final bool vibrationEnabled;

  const AppSettings({
    required this.language,
    required this.darkMode,
    required this.prayerCalculationMethod,
    required this.notificationsEnabled,
    required this.azanEnabled,
    required this.vibrationEnabled,
  });

  AppSettings copyWith({
    AppLanguage? language,
    bool? darkMode,
    PrayerCalculationMethod? prayerCalculationMethod,
    bool? notificationsEnabled,
    Map<PrayerName, bool>? azanEnabled,
    bool? vibrationEnabled,
  }) {
    return AppSettings(
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      prayerCalculationMethod:
          prayerCalculationMethod ?? this.prayerCalculationMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      azanEnabled: azanEnabled ?? this.azanEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Locale get locale => language.locale;

  static AppSettings defaults() => AppSettings(
        language: AppLanguage.en,
        darkMode: false,
        prayerCalculationMethod: PrayerCalculationMethod.karachi,
        notificationsEnabled: true,
        vibrationEnabled: true,
        azanEnabled: const {
          PrayerName.fajr: true,
          PrayerName.dhuhr: true,
          PrayerName.asr: true,
          PrayerName.maghrib: true,
          PrayerName.isha: true,
        },
      );
}

