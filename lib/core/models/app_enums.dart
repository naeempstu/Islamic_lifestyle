import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';

enum AppLanguage {
  en,
  bn,
}

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
        AppLanguage.en => 'en',
        AppLanguage.bn => 'bn',
      };

  String get display => switch (this) {
        AppLanguage.en => 'English',
        AppLanguage.bn => 'বাংলা',
      };

  Locale get locale => Locale(code);
}

enum PrayerName {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

extension PrayerNameX on PrayerName {
  String get key => switch (this) {
        PrayerName.fajr => 'fajr',
        PrayerName.dhuhr => 'dhuhr',
        PrayerName.asr => 'asr',
        PrayerName.maghrib => 'maghrib',
        PrayerName.isha => 'isha',
      };

  String labelEn() => switch (this) {
        PrayerName.fajr => 'Fajr',
        PrayerName.dhuhr => 'Zuhr',
        PrayerName.asr => 'Asr',
        PrayerName.maghrib => 'Maghrib',
        PrayerName.isha => 'Isha',
      };

  String labelBn() => switch (this) {
        PrayerName.fajr => 'ফজর',
        PrayerName.dhuhr => 'যোহর',
        PrayerName.asr => 'আসর',
        PrayerName.maghrib => 'মাগরিব',
        PrayerName.isha => 'এশা',
      };
}

enum PrayerCalculationMethod {
  muslimWorldLeague,
  karachi,
  egyptian,
  ummAlQura,
  northAmerica,
}

extension PrayerCalculationMethodX on PrayerCalculationMethod {
  String get key => switch (this) {
        PrayerCalculationMethod.muslimWorldLeague => 'muslimWorldLeague',
        PrayerCalculationMethod.karachi => 'karachi',
        PrayerCalculationMethod.egyptian => 'egyptian',
        PrayerCalculationMethod.ummAlQura => 'ummAlQura',
        PrayerCalculationMethod.northAmerica => 'northAmerica',
      };

  String labelEn() => switch (this) {
        PrayerCalculationMethod.muslimWorldLeague => 'Muslim World League',
        PrayerCalculationMethod.karachi => 'Karachi',
        PrayerCalculationMethod.egyptian => 'Egypt',
        PrayerCalculationMethod.ummAlQura => 'Umm Al-Qura',
        PrayerCalculationMethod.northAmerica => 'North America',
      };

  String labelBn() => switch (this) {
        PrayerCalculationMethod.muslimWorldLeague => 'মুসলিম ওয়ার্ল্ড লীগ',
        PrayerCalculationMethod.karachi => 'করাচি',
        PrayerCalculationMethod.egyptian => 'মিশর',
        PrayerCalculationMethod.ummAlQura => 'উম্ম আল-কুরা',
        PrayerCalculationMethod.northAmerica => 'নর্থ আমেরিকা',
      };

  CalculationMethod toAdhan() {
    return switch (this) {
      PrayerCalculationMethod.muslimWorldLeague => CalculationMethod.muslim_world_league,
      PrayerCalculationMethod.karachi => CalculationMethod.karachi,
      PrayerCalculationMethod.egyptian => CalculationMethod.egyptian,
      PrayerCalculationMethod.ummAlQura => CalculationMethod.umm_al_qura,
      PrayerCalculationMethod.northAmerica => CalculationMethod.north_america,
    };
  }

  static PrayerCalculationMethod fromKey(String key) {
    return switch (key) {
      'muslimWorldLeague' => PrayerCalculationMethod.muslimWorldLeague,
      'karachi' => PrayerCalculationMethod.karachi,
      'egyptian' => PrayerCalculationMethod.egyptian,
      'ummAlQura' => PrayerCalculationMethod.ummAlQura,
      'northAmerica' => PrayerCalculationMethod.northAmerica,
      _ => PrayerCalculationMethod.karachi,
    };
  }
}

