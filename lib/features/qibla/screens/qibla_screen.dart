import 'package:flutter/material.dart';

import '../../../core/models/app_enums.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/qibla_service.dart';

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
  late Future<(double, double)> _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = widget.locationService.getLatLngOrFallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == AppLanguage.bn ? 'কিবলা দিক' : 'Qibla Direction',
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<(double, double)>(
          future: _locationFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final (lat, lng) = snapshot.data!;
            final bearing = QiblaService.qiblaBearingDegrees(lat, lng);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.language == AppLanguage.bn
                          ? 'ফোন ঘুরিয়ে কম্পাস মিলিয়ে নিন'
                          : 'Rotate your phone to align the compass',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 22),
                    _QiblaCompass(
                      language: widget.language,
                      latitude: lat,
                      longitude: lng,
                      qiblaBearing: bearing,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${bearing.toStringAsFixed(1)}°',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QiblaCompass extends StatelessWidget {
  final AppLanguage language;
  final double latitude;
  final double longitude;
  final double qiblaBearing;

  const _QiblaCompass({
    required this.language,
    required this.latitude,
    required this.longitude,
    required this.qiblaBearing,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: QiblaService.qiblaRotationStream(
        latitude: latitude,
        longitude: longitude,
      ),
      builder: (context, snapshot) {
        final rotationDeg = snapshot.data ?? qiblaBearing;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF4EE), Color(0xFFCFE7DA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
            border: Border.all(color: const Color(0xFF1E8C58), width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const _CompassTicks(),
              Text(
                language == AppLanguage.bn ? 'উত্তর' : 'N',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: rotationDeg / 360,
                child: const Icon(
                  Icons.navigation_rounded,
                  size: 130,
                  color: Color(0xFF1E8C58),
                ),
              ),
              Positioned(
                bottom: 22,
                child: Text(
                  language == AppLanguage.bn ? 'কাবা' : 'Kaaba',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E8C58),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompassTicks extends StatelessWidget {
  const _CompassTicks();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < 12; i++)
            Transform.rotate(
              angle: i * 0.523599,
              child: const Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 3,
                  height: 18,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x88304E42),
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
