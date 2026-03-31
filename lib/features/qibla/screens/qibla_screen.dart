import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';
import '../../../core/models/app_enums.dart';
import '../../../core/services/location_service.dart';

class QiblaScreen extends StatefulWidget {
  final AppLanguage language;
  final LocationService locationService;

  const QiblaScreen({
    super.key,
    required this.language,
    required this.locationService,
  });

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _heading = 0;
  double _smoothedHeading = 0;

  // 🕋 Kaaba location
  final double kaabaLat = 21.4225;
  final double kaabaLng = 39.8262;

  // 📍 Example: Bangladesh (auto location later add করতে পারো)
  final double userLat = 23.8103;
  final double userLng = 90.4125;

  // 🔥 Smooth filter
  double smooth(double newVal) {
    double alpha = 0.1;
    _smoothedHeading = _smoothedHeading + alpha * (newVal - _smoothedHeading);
    return _smoothedHeading;
  }

  // 🧭 Qibla calculation
  double calculateQibla() {
    double lat1 = userLat * pi / 180;
    double lon1 = userLng * pi / 180;
    double lat2 = kaabaLat * pi / 180;
    double lon2 = kaabaLng * pi / 180;

    double dLon = lon2 - lon1;

    double y = sin(dLon);
    double x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLon);

    double bearing = atan2(y, x);

    return (bearing * 180 / pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    final qibla = calculateQibla();

    return Scaffold(
      appBar: AppBar(title: const Text("Qibla Compass")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Move phone in 8 shape for calibration",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              StreamBuilder<CompassEvent>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final rawHeading = snapshot.data!.heading ?? 0;
                  _heading = smooth(rawHeading);

                  // 🔥 final angle
                  final angle = (qibla - _heading + 360) % 360;

                  // 🔥 aligned check
                  final isAligned = angle < 5 || angle > 355;

                  if (isAligned) {
                    Vibration.vibrate(duration: 100);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Qibla: ${qibla.toStringAsFixed(1)}°",
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 20),
                      // 🧭 Compass UI
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green[50],
                          border: Border.all(
                            color:
                                isAligned ? Colors.greenAccent : Colors.green,
                            width: 3,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // center
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            ),

                            // 🔥 needle
                            Transform.rotate(
                              angle: angle * pi / 180,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 120,
                                    color: isAligned
                                        ? Colors.greenAccent
                                        : Colors.green,
                                  ),
                                  const Icon(Icons.arrow_drop_up, size: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        isAligned ? "✅ Aligned with Qibla" : "❌ Not aligned",
                        style: TextStyle(
                          color: isAligned ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
