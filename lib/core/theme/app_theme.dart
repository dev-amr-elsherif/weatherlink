import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00ADB5),
        brightness: Brightness.light,
        primary: const Color(0xFF00ADB5),
        secondary: const Color(0xFF393E46),
        surface: const Color(0xFFF9F7F7),
      ),
      scaffoldBackgroundColor: const Color(0xFFF9F7F7),
      textTheme: GoogleFonts.poppinsTextTheme(),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get darkTheme {
    // Premium futuristic Neon Glassmorphism aesthetic restored
    const neonCyan = Color(0xFF00E5FF);
    const neonPurple = Color(0xFF9D00FF);
    const deepDarkBg = Color(0xFF050505);
    const cardSurface = Color(0xFF121212);

    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepDarkBg,
      textTheme: GoogleFonts.rajdhaniTextTheme(baseTextTheme).apply(
        bodyColor: const Color(0xFFFFFFFF),
        displayColor: const Color(0xFFFFFFFF),
      ),
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: neonCyan,
        onPrimary: Color(0xFF000000),
        secondary: neonPurple,
        onSecondary: Color(0xFFFFFFFF),
        surface: cardSurface,
        onSurface: Color(0xFFFFFFFF),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 8.0, // Premium thick responsive track restored
        activeTrackColor: neonCyan,
        inactiveTrackColor: Color(0x14FFFFFF), // Strictly Hex with Alpha channel
        thumbColor: neonCyan,
        overlayColor: Color(0x4000E5FF), // Strictly Hex with Alpha channel
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 13.0),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 26.0),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: neonCyan),
        titleTextStyle: GoogleFonts.rajdhani(
          color: neonCyan,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
