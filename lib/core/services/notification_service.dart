import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../models/app_enums.dart';
import '../../features/prayer/services/prayer_times.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    tzdata.initializeTimeZones();

    await _plugin.initialize(settings: initSettings);
  }

  Future<void> requestPermissions() async {
    // On Android 13+, runtime notification permission is required.
    // We'll rely on permission_handler in the UI and keep this simple here.
  }

  Future<void> _scheduleDailyPrayer({
    required int id,
    required PrayerName prayer,
    required DateTime time,
  }) async {
    final scheduled = tz.TZDateTime(
      tz.local,
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'It’s time for ${prayer.nameForNotification}',
      body: 'A moment of Salah brings peace. 🤍',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'azan_channel',
          'Azan reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> schedulePrayerNotifications({
    required PrayerTimesModel times,
    required Map<PrayerName, bool> enabled,
  }) async {
    for (final entry in enabled.entries) {
      if (!entry.value) continue;

      final prayer = entry.key;
      final DateTime time = switch (prayer) {
        PrayerName.fajr => times.fajr,
        PrayerName.dhuhr => times.dhuhr,
        PrayerName.asr => times.asr,
        PrayerName.maghrib => times.maghrib,
        PrayerName.isha => times.isha,
      };

      await _scheduleDailyPrayer(
        id: 1000 + prayer.index,
        prayer: prayer,
        time: time.isAfter(DateTime.now()) ? time : time.add(const Duration(days: 1)),
      );
    }
  }

  Future<void> cancelPrayerNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel',
          'General notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

extension PrayerNameNotificationX on PrayerName {
  String get nameForNotification => switch (this) {
        PrayerName.fajr => 'Fajr',
        PrayerName.dhuhr => 'Zuhr',
        PrayerName.asr => 'Asr',
        PrayerName.maghrib => 'Maghrib',
        PrayerName.isha => 'Isha',
      };

  int get index => switch (this) {
        PrayerName.fajr => 0,
        PrayerName.dhuhr => 1,
        PrayerName.asr => 2,
        PrayerName.maghrib => 3,
        PrayerName.isha => 4,
      };
}

