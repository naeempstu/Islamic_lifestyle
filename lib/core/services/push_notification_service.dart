import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();

  Future<void> init() async {
    FirebaseMessaging messaging;
    try {
      messaging = FirebaseMessaging.instance;
    } catch (_) {
      // Firebase is not ready/configured; skip push setup.
      return;
    }

    // Request permission for iOS/macOS; Android typically handled via notification permission.
    await messaging.requestPermission();

    final token = await messaging.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    }

    FirebaseMessaging.onMessage.listen((message) async {
      // When app is in foreground, show a gentle local notification.
      final title = message.notification?.title ?? 'Reminder';
      final body = message.notification?.body ?? '';
      if (body.isEmpty) return;

      await NotificationService.instance.showImmediate(
        id: DateTime.now().millisecondsSinceEpoch % 1000000,
        title: title,
        body: body,
      );
    });
  }
}

