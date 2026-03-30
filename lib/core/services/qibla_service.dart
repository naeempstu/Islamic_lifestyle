import 'dart:math';

import 'package:flutter_compass/flutter_compass.dart';

class QiblaService {
  // Kaaba coordinates.
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  /// Initial bearing from (lat,lng) to the Kaaba, in degrees from true north.
  static double qiblaBearingDegrees(double lat, double lng) {
    final lat1 = _toRad(lat);
    final lat2 = _toRad(kaabaLat);
    final dLon = _toRad(kaabaLng - lng);

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final brng = atan2(y, x);

    return (_toDeg(brng) + 360) % 360;
  }

  /// Returns a stream of rotation degrees needed to point an arrow to Qibla.
  /// Assumes the arrow image points to the device's north at rotation=0.
  static Stream<double> qiblaRotationStream({
    required double latitude,
    required double longitude,
  }) {
    final qiblaBearing = qiblaBearingDegrees(latitude, longitude);
    return FlutterCompass.events!.map((event) {
      final heading = event.heading ?? 0.0;
      // Positive rotation rotates clockwise.
      return qiblaBearing - heading;
    });
  }

  static double _toRad(double deg) => deg * (pi / 180.0);
  static double _toDeg(double rad) => rad * (180.0 / pi);
}

