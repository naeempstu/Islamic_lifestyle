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
    final targetDate = date ?? DateTime.now();

    // Bangladesh prayer schedules typically follow Hanafi Asr.
    params.madhab = Madhab.hanafi;

    final prayerTimes =
        PrayerTimes(coords, DateComponents.from(targetDate), params);

    return PrayerTimesModel.fromAdhan(prayerTimes);
  }
}

