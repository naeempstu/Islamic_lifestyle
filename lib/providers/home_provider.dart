import 'package:flutter/foundation.dart';
import 'dart:async';
import '../features/prayer/services/prayer_times.dart';
import '../features/prayer/services/prayer_times_service.dart';
import '../core/models/app_enums.dart';
import '../core/services/location_service.dart';

class HomeProvider extends ChangeNotifier {
  final PrayerTimesService prayerTimesService;
  final LocationService locationService;

  // State variables
  PrayerTimesModel? _prayerTimes;
  String? _locationName;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  String? _error;
  late Timer _midnightRefreshTimer;
  late Timer _secondTickTimer;

  // Prayer completion tracking
  final Map<String, bool> _prayerCompleted = {
    'fajr': false,
    'zuhr': false,
    'asr': false,
    'maghrib': false,
    'isha': false,
  };

  // Getters
  PrayerTimesModel? get prayerTimes => _prayerTimes;
  String? get locationName => _locationName;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, bool> get prayerCompleted => _prayerCompleted;
  int get completedPrayerCount =>
      _prayerCompleted.values.where((v) => v).length;

  HomeProvider({
    required this.prayerTimesService,
    required this.locationService,
  });

  Future<void> initialize(
    PrayerCalculationMethod method,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load location
      final (lat, lng) = await locationService.getLatLngOrFallback();
      _latitude = lat;
      _longitude = lng;

      // Get location name
      _locationName = await locationService.getLiveLocationName();

      // Calculate prayer times
      _prayerTimes = prayerTimesService.calculateFor(
        latitude: lat,
        longitude: lng,
        method: method,
      );

      _isLoading = false;
      _setupTimers();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  void _setupTimers() {
    // Setup midnight refresh timer
    _setupMidnightRefresh();

    // Setup second tick timer for real-time updates
    _secondTickTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
  }

  void _setupMidnightRefresh() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _midnightRefreshTimer = Timer(durationUntilMidnight, () {
      // Reset checklist
      _prayerCompleted.updateAll((key, value) => false);
      // Reschedule
      _setupMidnightRefresh();
      notifyListeners();
    });
  }

  void togglePrayerCompletion(String prayerKey) {
    if (_prayerCompleted.containsKey(prayerKey)) {
      _prayerCompleted[prayerKey] = !_prayerCompleted[prayerKey]!;
      notifyListeners();
    }
  }

  Future<void> refreshData(PrayerCalculationMethod method) async {
    await initialize(method);
  }

  @override
  void dispose() {
    _midnightRefreshTimer.cancel();
    _secondTickTimer.cancel();
    super.dispose();
  }
}
