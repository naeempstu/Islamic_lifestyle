import 'package:flutter/material.dart';
import '../../../core/models/app_enums.dart';
import 'hadith_books_screen.dart';

class HadithReaderScreen extends StatefulWidget {
  final AppLanguage language;

  const HadithReaderScreen({
    super.key,
    required this.language,
  });

  @override
  State<HadithReaderScreen> createState() => _HadithReaderScreenState();
}

class _HadithReaderScreenState extends State<HadithReaderScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HadithBooksScreen(language: widget.language);
  }
}
