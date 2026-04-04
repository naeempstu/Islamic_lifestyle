import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/mosque_model.dart';

class MosqueRepository {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const String _googlePlacesUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  // Set to true for testing when API returns no data
  static const bool _useTestData = true;

  /// Search for nearby mosques within a radius
  /// Uses Overpass API (OpenStreetMap) for reliable mosque data
  /// Radius is in meters, default 3000m (3km)
  Future<List<MosqueModel>> search({
    required double latitude,
    required double longitude,
    int radiusInMeters = 5000,
    String? googleApiKey,
  }) async {
    try {
      // Try Google Places API first if API key is provided
      if (googleApiKey != null && googleApiKey.isNotEmpty) {
        try {
          final googleMosques = await _searchGooglePlaces(
            latitude: latitude,
            longitude: longitude,
            radiusInMeters: radiusInMeters,
            apiKey: googleApiKey,
          );
          if (googleMosques.isNotEmpty) {
            return googleMosques;
          }
        } catch (e) {
          // Google Places API failed, will fallback to Overpass
        }
      }

      // Fallback to Overpass API (always available)
      final overpassMosques = await _searchOverpass(
        latitude: latitude,
        longitude: longitude,
        radiusInMeters: radiusInMeters,
      );

      // If no mosques found and testing mode is enabled, return test data
      if (overpassMosques.isEmpty && _useTestData) {
        return _generateTestMosques(latitude, longitude);
      }

      return overpassMosques;
    } catch (e) {
      // Error searching for mosques, return test data if enabled
      if (_useTestData) {
        return _generateTestMosques(latitude, longitude);
      }
      return [];
    }
  }

  /// Search using Google Places API
  Future<List<MosqueModel>> _searchGooglePlaces({
    required double latitude,
    required double longitude,
    required int radiusInMeters,
    required String apiKey,
  }) async {
    final url = Uri.parse(
      '$_googlePlacesUrl?location=$latitude,$longitude&radius=$radiusInMeters&type=mosque&keyword=mosque&key=$apiKey',
    );

    final response = await http.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Google Places API timeout'),
        );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> results = json['results'] ?? [];

      return results.map((place) {
        final mosque = MosqueModel.fromGooglePlaces(place);
        // Calculate distance
        return mosque.copyWith(
          distanceInKm: _calculateDistance(
            latitude,
            longitude,
            mosque.latitude,
            mosque.longitude,
          ),
        );
      }).toList()
        ..sort((a, b) => (a.distanceInKm ?? 0).compareTo(b.distanceInKm ?? 0));
    } else if (response.statusCode == 403) {
      throw Exception('Google Places API key invalid or billing not enabled');
    } else {
      throw Exception('Google Places API error: ${response.statusCode}');
    }
  }

  /// Search using Overpass API (OpenStreetMap data)
  /// This is free and doesn't require an API key
  Future<List<MosqueModel>> _searchOverpass({
    required double latitude,
    required double longitude,
    required int radiusInMeters,
  }) async {
    // First try with the specified radius, then expand if needed
    for (int attempt = 0; attempt < 2; attempt++) {
      final searchRadius = attempt == 0 ? radiusInMeters : radiusInMeters * 2;

      final query = '''
[out:json][timeout:30];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$searchRadius,$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$searchRadius,$latitude,$longitude);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$searchRadius,$latitude,$longitude);
);
out center;
''';

      final url = Uri.parse(_overpassUrl);

      try {
        final response = await http.post(
          url,
          body: query,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Overpass API timeout'),
        );

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final List<dynamic> elements = json['elements'] ?? [];

          if (elements.isNotEmpty) {
            List<MosqueModel> mosques = [];

            for (final element in elements) {
              try {
                double elemLat = 0.0;
                double elemLng = 0.0;

                // Get coordinates from different element types
                if (element['lat'] != null && element['lon'] != null) {
                  elemLat = (element['lat'] as num).toDouble();
                  elemLng = (element['lon'] as num).toDouble();
                } else if (element['center'] != null) {
                  elemLat = (element['center']['lat'] as num).toDouble();
                  elemLng = (element['center']['lon'] as num).toDouble();
                } else {
                  continue; // Skip if no coordinates
                }

                final mosque = MosqueModel.fromOverpass(element).copyWith(
                  latitude: elemLat,
                  longitude: elemLng,
                  distanceInKm: _calculateDistance(
                    latitude,
                    longitude,
                    elemLat,
                    elemLng,
                  ),
                );

                mosques.add(mosque);
              } catch (e) {
                // Skip element if parsing fails
                continue;
              }
            }

            // Sort by distance
            mosques.sort(
                (a, b) => (a.distanceInKm ?? 0).compareTo(b.distanceInKm ?? 0));

            // Return results if found
            if (mosques.isNotEmpty) {
              return mosques.take(50).toList();
            }
          }
        } else if (response.statusCode != 429) {
          // Don't retry on rate limit errors
          throw Exception('Overpass API error: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == 1) {
          rethrow; // Throw on last attempt
        }
        // Continue to next attempt
      }
    }

    return []; // Return empty list if no mosques found after retries
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _toRad(double degree) => degree * (3.141592653589793 / 180);

  /// Generate test mosques for UI development
  /// Remove this after API starts returning data properly
  static List<MosqueModel> _generateTestMosques(
    double userLat,
    double userLng,
  ) {
    return [
      MosqueModel(
        id: 'test_1',
        name: 'বায়তুল মোকাররম',
        nameEn: 'Baitul Mukarram',
        latitude: userLat + 0.002,
        longitude: userLng + 0.001,
        address: 'Bangladesh',
        phone: '+880-1700-000000',
        distanceInKm: 0.25,
      ),
      MosqueModel(
        id: 'test_2',
        name: 'নূর মসজিদ',
        nameEn: 'Nur Mosque',
        latitude: userLat - 0.001,
        longitude: userLng + 0.002,
        address: 'Bangladesh',
        phone: '+880-1700-000001',
        distanceInKm: 0.35,
      ),
      MosqueModel(
        id: 'test_3',
        name: 'আহসান মঞ্জিল',
        nameEn: 'Ahsan Manjil',
        latitude: userLat + 0.0015,
        longitude: userLng - 0.0015,
        address: 'Bangladesh',
        phone: '+880-1700-000002',
        distanceInKm: 0.50,
      ),
    ];
  }
}
