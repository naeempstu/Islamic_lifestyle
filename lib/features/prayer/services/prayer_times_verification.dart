import 'dart:convert';
import 'package:http/http.dart' as http;
import 'prayer_times.dart';

class PrayerTimesVerification {
  static const String _apiBaseUrl = 'http://api.aladhan.com/v1';

  /// Fetch prayer times from AlAdhan API for verification
  /// Returns PrayerTimesModel for the given latitude, longitude, and date
  static Future<PrayerTimesModel> fetchFromApi({
    required double latitude,
    required double longitude,
    required int
        method, // 2=Karachi, 1=Muslim World League, 5=Egyptian, 3=Umm Al-Qura, 8=North America
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = '${targetDate.day}-${targetDate.month}-${targetDate.year}';

    try {
      final response = await http
          .get(
            Uri.parse(
              '$_apiBaseUrl/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=$method',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = data['data']['timings'];

        // Parse times from the API response
        final fajr = _parseTime(timings['Fajr'], targetDate);
        final dhuhr = _parseTime(timings['Dhuhr'], targetDate);
        final asr = _parseTime(timings['Asr'], targetDate);
        final maghrib = _parseTime(timings['Maghrib'], targetDate);
        final isha = _parseTime(timings['Isha'], targetDate);

        return PrayerTimesModel(
          fajr: fajr,
          sunrise: _parseTime(timings['Sunrise'], targetDate),
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha,
          fajrEnd: dhuhr,
          dhuhrEnd: asr,
          asrEnd: maghrib,
          maghribEnd: isha,
          ishaEnd: fajr.add(const Duration(days: 1)),
        );
      } else {
        throw Exception('Failed to fetch prayer times: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching prayer times from API: $e');
    }
  }

  /// Parse time string from API (format: "05:42")
  static DateTime _parseTime(String timeStr, DateTime date) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Verify if calculated times match API times (within tolerance)
  static bool verifyTimes(
    PrayerTimesModel calculated,
    PrayerTimesModel apiTimes, {
    int toleranceMinutes = 2,
  }) {
    return _isWithinTolerance(
            calculated.fajr, apiTimes.fajr, toleranceMinutes) &&
        _isWithinTolerance(
            calculated.dhuhr, apiTimes.dhuhr, toleranceMinutes) &&
        _isWithinTolerance(calculated.asr, apiTimes.asr, toleranceMinutes) &&
        _isWithinTolerance(
            calculated.maghrib, apiTimes.maghrib, toleranceMinutes) &&
        _isWithinTolerance(calculated.isha, apiTimes.isha, toleranceMinutes);
  }

  static bool _isWithinTolerance(
    DateTime time1,
    DateTime time2,
    int toleranceMinutes,
  ) {
    final diff = time1.difference(time2).inMinutes.abs();
    return diff <= toleranceMinutes;
  }

  /// Get the method number for AlAdhan API
  /// 2=Karachi, 1=Muslim World League, 5=Egyptian, 3=Umm Al-Qura, 8=North America
  static int getApiMethodCode(String method) {
    return switch (method) {
      'karachi' => 2,
      'muslimWorldLeague' => 1,
      'egyptian' => 5,
      'ummAlQura' => 3,
      'northAmerica' => 8,
      _ => 2, // Default to Karachi
    };
  }
}
