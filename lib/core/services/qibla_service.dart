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
    
    // Get compass events
    final events = FlutterCompass.events;
    
    if (events == null) {
      // If compass is not available, return a stream that emits the bearing continuously
      return Stream.periodic(
        const Duration(milliseconds: 100),
        (_) => qiblaBearing,
      );
    }
    
    return events.map((event) {
      final heading = event.heading ?? 0.0;
      // Calculate the rotation needed - negate to get correct direction
      final rotation = (qiblaBearing - heading);
      return rotation;
    }).asBroadcastStream();
  }

  static double _toRad(double deg) => deg * (pi / 180.0);
  static double _toDeg(double rad) => rad * (180.0 / pi);
}

