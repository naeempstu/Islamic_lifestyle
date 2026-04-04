import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/app_enums.dart';
import '../../../core/services/location_service.dart';
import '../data/mosque_repository.dart';
import '../models/mosque_model.dart';

class MosqueMapScreen extends StatefulWidget {
  final AppLanguage language;
  final LocationService locationService;
  final String? googleApiKey;

  const MosqueMapScreen({
    super.key,
    required this.language,
    required this.locationService,
    this.googleApiKey,
  });

  @override
  State<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends State<MosqueMapScreen> {
  late GoogleMapController _mapController;

  LatLng? _currentLocation;
  List<MosqueModel> _mosques = [];

  bool _isLoading = true;
  String? _errorMessage;

  final MosqueRepository _repository = MosqueRepository();
  bool _showSearchRadius = false;
  int _searchRadiusMeters = 5000;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      // Request location permission
      final status = await perm.Permission.location.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        setState(() {
          _errorMessage = widget.language == AppLanguage.bn
              ? 'অবস্থান অনুমতি প্রয়োজন'
              : 'Location permission is required';
          _isLoading = false;
        });
        return;
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final userLocation = LatLng(position.latitude, position.longitude);

      // Load nearby mosques
      final mosques = await _repository.search(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        radiusInMeters: _searchRadiusMeters,
        googleApiKey: widget.googleApiKey,
      );

      setState(() {
        _currentLocation = userLocation;
        _mosques = mosques;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = widget.language == AppLanguage.bn
            ? 'ত্রুটি: ${e.toString()}'
            : 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyMosques() async {
    if (_currentLocation == null) return;

    try {
      setState(() => _isLoading = true);

      final mosques = await _repository.search(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        radiusInMeters: _searchRadiusMeters,
        googleApiKey: widget.googleApiKey,
      );

      setState(() {
        _mosques = mosques;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = widget.language == AppLanguage.bn
            ? 'মসজিদ লোড করতে ব্যর্থ: $e'
            : 'Failed to load mosques: $e';
        _isLoading = false;
      });
    }
  }

  void _showMosqueDetails(MosqueModel mosque) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _MosqueDetailsSheet(
        language: widget.language,
        mosque: mosque,
        onDirections: _launchDirections,
        onCall: _launchPhone,
        onWebsite: _launchWebsite,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Future<void> _launchDirections(MosqueModel mosque) async {
    final mapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}&travelmode=driving',
    );

    try {
      await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.language == AppLanguage.bn
                ? 'মানচিত্র খুলতে পারা যায়নি'
                : 'Could not open maps',
          ),
        ),
      );
    }
  }

  Future<void> _launchPhone(String phone) async {
    final phoneUrl = Uri.parse('tel:$phone');

    try {
      await launchUrl(phoneUrl);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.language == AppLanguage.bn
                ? 'কল করতে পারা যায়নি'
                : 'Could not make call',
          ),
        ),
      );
    }
  }

  Future<void> _launchWebsite(String url) async {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.language == AppLanguage.bn
                ? 'ওয়েবসাইট খুলতে পারা যায়নি'
                : 'Could not open website',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == AppLanguage.bn ? 'মসজিদ খুঁজুন' : 'Find Mosques',
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyMosques,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _currentLocation!,
                      zoom: 14,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading && _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _isLoading = true;
                          });
                          _initializeMap();
                        },
                        child: Text(
                          widget.language == AppLanguage.bn
                              ? 'পুনরায় চেষ্টা করুন'
                              : 'Retry',
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target:
                            _currentLocation ?? const LatLng(23.8103, 90.4441),
                        zoom: 14,
                      ),
                      markers: _buildMarkers(),
                      circles: _buildCircles(),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.language == AppLanguage.bn
                                        ? 'খুঁজে পাওয়া: ${_mosques.length}'
                                        : 'Found: ${_mosques.length}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.expand_more),
                                    onPressed: () {
                                      setState(() => _showSearchRadius =
                                          !_showSearchRadius);
                                    },
                                  ),
                                ],
                              ),
                              if (_showSearchRadius) ...[
                                const SizedBox(height: 12),
                                Text(
                                  widget.language == AppLanguage.bn
                                      ? 'পরিসীমা: ${(_searchRadiusMeters / 1000).toStringAsFixed(1)} কি.মি.'
                                      : 'Radius: ${(_searchRadiusMeters / 1000).toStringAsFixed(1)} km',
                                ),
                                Slider(
                                  value: _searchRadiusMeters.toDouble(),
                                  min: 1000,
                                  max: 10000,
                                  divisions: 9,
                                  label:
                                      '${(_searchRadiusMeters / 1000).toStringAsFixed(1)} km',
                                  onChanged: (value) {
                                    setState(() {
                                      _searchRadiusMeters = value.toInt();
                                    });
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: _loadNearbyMosques,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  child: Text(
                                    widget.language == AppLanguage.bn
                                        ? 'অনুসন্ধান'
                                        : 'Search',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Current location
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: InfoWindow(
            title: widget.language == AppLanguage.bn
                ? 'আমার অবস্থান'
                : 'My Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Mosque locations
    for (final mosque in _mosques) {
      markers.add(
        Marker(
          markerId: MarkerId(mosque.id),
          position: LatLng(mosque.latitude, mosque.longitude),
          infoWindow: InfoWindow(
            title: mosque.name,
            snippet: mosque.address,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () => _showMosqueDetails(mosque),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles() {
    if (_currentLocation == null) return {};

    return {
      Circle(
        circleId: const CircleId('search_radius'),
        center: _currentLocation!,
        radius: _searchRadiusMeters.toDouble(),
        fillColor: Colors.blue.withValues(alpha: 0.1),
        strokeColor: Colors.blue.withValues(alpha: 0.3),
        strokeWidth: 2,
      ),
    };
  }
}

class _MosqueDetailsSheet extends StatelessWidget {
  final AppLanguage language;
  final MosqueModel mosque;
  final Function(MosqueModel) onDirections;
  final Function(String) onCall;
  final Function(String) onWebsite;

  const _MosqueDetailsSheet({
    required this.language,
    required this.mosque,
    required this.onDirections,
    required this.onCall,
    required this.onWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                mosque.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (mosque.address != null) ...[
                const SizedBox(height: 8),
                Text(
                  mosque.address!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
              if (mosque.distanceInKm != null) ...[
                const SizedBox(height: 8),
                Text(
                  language == AppLanguage.bn
                      ? 'দূরত্ব: ${mosque.distanceInKm!.toStringAsFixed(1)} কি.মি.'
                      : 'Distance: ${mosque.distanceInKm!.toStringAsFixed(1)} km',
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      onDirections(mosque);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.directions),
                    label:
                        Text(language == AppLanguage.bn ? 'দিক' : 'Directions'),
                  ),
                  if (mosque.phone != null)
                    ElevatedButton.icon(
                      onPressed: () => onCall(mosque.phone!),
                      icon: const Icon(Icons.phone),
                      label: Text(language == AppLanguage.bn ? 'কল' : 'Call'),
                    ),
                  if (mosque.website != null)
                    ElevatedButton.icon(
                      onPressed: () => onWebsite(mosque.website!),
                      icon: const Icon(Icons.language),
                      label: Text(language == AppLanguage.bn ? 'ওয়েব' : 'Web'),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
