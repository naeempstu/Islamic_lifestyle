import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color green = Color(0xFF218B56);
  static const Color beige = Color(0xFFF7F7F5);
  static const Color nightBlue = Color(0xFF071A2B);

  static ThemeData light({required bool darkMode}) {
    if (darkMode) return dark();

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: green,
      brightness: Brightness.light,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: beige,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: green),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F8F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E0DB)),
        ),
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.nunito(
          color: Colors.black87,
        ),
        titleMedium: GoogleFonts.nunito(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.nunito(
          color: Colors.black87,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: green,
      brightness: Brightness.dark,
      surface: const Color(0xFF0F2438),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: nightBlue,
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.nunito(
          color: Colors.white70,
        ),
        titleMedium: GoogleFonts.nunito(
          color: Colors.white70,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.nunito(
          color: Colors.white70,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

