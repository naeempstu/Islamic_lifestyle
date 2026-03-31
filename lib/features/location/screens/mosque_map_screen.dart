import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:http/http.dart' as http;
import '../../../core/models/app_enums.dart';

class MosqueMapScreen extends StatefulWidget {
  final AppLanguage language;

  const MosqueMapScreen({super.key, required this.language});

  @override
  State<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends State<MosqueMapScreen> {
  late final MapController _mapController;
  final List<Marker> _markers = [];
  latlong2.LatLng? _currentLocation;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      _markers.clear();

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

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentLocation = latlong2.LatLng(position.latitude, position.longitude);

      // Current location marker
      _markers.add(
        Marker(
          point: _currentLocation!,
          width: 80,
          height: 80,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.language == AppLanguage.bn ? 'আপনি' : 'You',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const Icon(Icons.location_on, color: Colors.blue),
            ],
          ),
        ),
      );

      // 🔥 Load nearby mosques from API
      await _loadNearbyMosques();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // 🔥 API CALL
  Future<void> _loadNearbyMosques() async {
    if (_currentLocation == null) return;

    final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=[out:json];node["amenity"="place_of_worship"]["religion"="muslim"](around:3000,${_currentLocation!.latitude},${_currentLocation!.longitude});out;',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final elements = data['elements'] as List;

      for (var e in elements) {
        final name = e['tags']?['name'] ?? 'Mosque';

        _markers.add(
          Marker(
            point: latlong2.LatLng(e['lat'], e['lon']),
            width: 80,
            height: 80,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const Icon(Icons.mosque, color: Colors.green),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == AppLanguage.bn ? 'মসজিদ ম্যাপ' : 'Mosque Map',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation!,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'islamic_lifestyle',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 15);
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
