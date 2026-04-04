import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/islamic_lifestyle_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Optimize: Initialize Firebase in background
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).ignore(); // Don't wait for completion

  runApp(const ProviderScope(child: IslamicLifestyleApp()));
}
