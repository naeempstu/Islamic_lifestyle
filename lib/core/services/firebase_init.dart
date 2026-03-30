import 'package:firebase_core/firebase_core.dart';

class FirebaseInit {
  FirebaseInit._();

  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp();
      return true;
    } catch (_) {
      // If Firebase isn't configured yet, the app can still run in guest mode.
      return Firebase.apps.isNotEmpty;
    }
  }
}

