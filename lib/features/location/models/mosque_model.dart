/// Mosque model to represent a mosque location with details
class MosqueModel {
  final String id;
  final String name;
  final String? nameEn;
  final double latitude;
  final double longitude;
  final String? address;
  final String? phone;
  final String? website;
  final double? rating;
  final int? reviewCount;
  final String? openingHours;
  final double? distanceInKm;

  const MosqueModel({
    required this.id,
    required this.name,
    this.nameEn,
    required this.latitude,
    required this.longitude,
    this.address,
    this.phone,
    this.website,
    this.rating,
    this.reviewCount,
    this.openingHours,
    this.distanceInKm,
  });

  /// Create MosqueModel from Google Places API response
  factory MosqueModel.fromGooglePlaces(Map<String, dynamic> json) {
    return MosqueModel(
      id: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown Mosque',
      nameEn: json['name'],
      latitude: (json['geometry']?['location']?['lat'] ?? 0.0).toDouble(),
      longitude: (json['geometry']?['location']?['lng'] ?? 0.0).toDouble(),
      address: json['vicinity'] ?? json['formatted_address'],
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['user_ratings_total'],
      openingHours: json['opening_hours']?['weekday_text'] != null
          ? (json['opening_hours']['weekday_text'] as List).join('\n')
          : null,
    );
  }

  /// Create MosqueModel from Overpass API response
  factory MosqueModel.fromOverpass(Map<String, dynamic> json) {
    return MosqueModel(
      id: json['id'].toString(),
      name: json['tags']?['name'] ?? 'Mosque',
      nameEn: json['tags']?['name:en'],
      latitude: (json['lat'] ?? 0.0).toDouble(),
      longitude: (json['lon'] ?? 0.0).toDouble(),
      address: json['tags']?['addr:full'] ?? json['tags']?['address'],
      phone: json['tags']?['contact:phone'] ?? json['tags']?['phone'],
      website: json['tags']?['website'] ?? json['tags']?['contact:website'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameEn': nameEn,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'phone': phone,
        'website': website,
        'rating': rating,
        'reviewCount': reviewCount,
        'openingHours': openingHours,
        'distanceInKm': distanceInKm,
      };

  /// Copy with updates
  MosqueModel copyWith({
    String? id,
    String? name,
    String? nameEn,
    double? latitude,
    double? longitude,
    String? address,
    String? phone,
    String? website,
    double? rating,
    int? reviewCount,
    String? openingHours,
    double? distanceInKm,
  }) {
    return MosqueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openingHours: openingHours ?? this.openingHours,
      distanceInKm: distanceInKm ?? this.distanceInKm,
    );
  }
}
