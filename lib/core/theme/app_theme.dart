import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color green = Color(0xFF218B56);
  static const Color beige = Color(0xFFF7F7F5);
  static const Color nightBlue = Color(0xFF071A2B);

  // Dark mode text colors for better visibility
  static const Color darkModePrimaryText = Colors.white;
  static const Color darkModeSecondaryText = Color(0xFFDDE0E5); // ~87% white
  static const Color darkModeTertiaryText = Color(0xFFB3B8BF); // ~70% white
  static const Color darkModeHintText = Color(0xFF99A0A9); // ~60% white
  static const Color darkModeDisabledText = Color(0xFF616A73); // ~38% white

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: green),
          textStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 18),
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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
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
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: GoogleFonts.nunito(
          color: darkModeSecondaryText,
        ),
        titleMedium: GoogleFonts.nunito(
          color: darkModePrimaryText,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.nunito(
          color: darkModePrimaryText,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // Helper methods for dynamic color selection in dark mode
  static Color getTextColor(BuildContext context, {required bool isDark}) {
    return isDark ? darkModePrimaryText : Colors.black87;
  }

  static Color getSecondaryTextColor(BuildContext context,
      {required bool isDark}) {
    return isDark ? darkModeTertiaryText : Colors.grey[600]!;
  }

  static Color getBackgroundColor(BuildContext context,
      {required bool isDark}) {
    return isDark ? const Color(0xFF1f2937) : Colors.white;
  }

  static Color getBorderColor(BuildContext context, {required bool isDark}) {
    return isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!;
  }
}
