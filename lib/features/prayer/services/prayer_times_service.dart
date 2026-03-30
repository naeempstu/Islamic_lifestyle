import 'package:adhan/adhan.dart';

import '../../../core/models/app_enums.dart';
import 'prayer_times.dart';

class PrayerTimesService {
  PrayerTimesService._();
  static final instance = PrayerTimesService._();

  PrayerTimesModel calculateFor({
    required double latitude,
    required double longitude,
    required PrayerCalculationMethod method,
    DateTime? date,
  }) {
    final coords = Coordinates(latitude, longitude);
    final params = method.toAdhan().getParameters();
    // Madhhab selection (Shafi/Hanafi) can be added later.
    // Keeping default madhhab for now to stay simple.

    final prayerTimes = PrayerTimes.today(coords, params);

    return PrayerTimesModel.fromAdhan(prayerTimes);
  }
}

