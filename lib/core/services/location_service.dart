import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Dhaka, Bangladesh fallback.
  static const double fallbackLat = 23.8103;
  static const double fallbackLng = 90.4125;

  Future<(double lat, double lng)> getLatLngOrFallback() async {
    final permission = await Permission.location.request();
    if (!permission.isGranted) {
      return (fallbackLat, fallbackLng);
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return (fallbackLat, fallbackLng);
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return (fallbackLat, fallbackLng);
    }
  }

  Future<String> getLiveLocationName() async {
    final (lat, lng) = await getLatLngOrFallback();
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return 'Dhaka, Bangladesh';
      }
      final place = placemarks.first;
      final locality = (place.locality ?? '').trim();
      final subAdmin = (place.subAdministrativeArea ?? '').trim();
      final country = (place.country ?? '').trim();

      final primary = locality.isNotEmpty ? locality : subAdmin;
      if (primary.isEmpty && country.isEmpty) {
        return 'Dhaka, Bangladesh';
      }
      if (primary.isEmpty) return country;
      if (country.isEmpty) return primary;
      return '$primary, $country';
    } catch (_) {
      return 'Dhaka, Bangladesh';
    }
  }
}
