import 'package:adhan/adhan.dart';

class PrayerTimesModel {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  // End times
  final DateTime fajrEnd;
  final DateTime dhuhrEnd;
  final DateTime asrEnd;
  final DateTime maghribEnd;
  final DateTime ishaEnd;

  const PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.fajrEnd,
    required this.dhuhrEnd,
    required this.asrEnd,
    required this.maghribEnd,
    required this.ishaEnd,
  });

  static PrayerTimesModel fromAdhan(PrayerTimes times) {
    return PrayerTimesModel(
      fajr: times.fajr,
      sunrise: times.sunrise,
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
      // End times are the start of next prayer
      fajrEnd: times.dhuhr,
      dhuhrEnd: times.asr,
      asrEnd: times.maghrib,
      maghribEnd: times.isha,
      // Isha ends at next day Fajr
      ishaEnd: times.fajr.add(const Duration(days: 1)),
    );
  }
}
