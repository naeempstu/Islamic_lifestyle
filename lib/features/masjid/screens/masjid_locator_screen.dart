import 'package:flutter/material.dart';
import '../../../core/models/app_enums.dart';
import '../../../core/services/location_service.dart';
import '../../location/screens/mosque_map_screen.dart';

class MasjidLocatorScreen extends StatefulWidget {
  final AppLanguage language;
  final LocationService locationService;

  const MasjidLocatorScreen({
    super.key,
    required this.language,
    required this.locationService,
  });

  @override
  State<MasjidLocatorScreen> createState() => _MasjidLocatorScreenState();
}

class _MasjidLocatorScreenState extends State<MasjidLocatorScreen> {
  @override
  Widget build(BuildContext context) {
    return MosqueMapScreen(language: widget.language);
  }
}
