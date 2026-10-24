import 'package:flutter/material.dart';

class KivoraColors {
  // Brand Teal Palette
  static const Color primary = Color(0xFF0D9488); // Teal 600
  static const Color primaryDark = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight = Color(0xFFCCFBF1); // Teal 100
  static const Color primarySubtle = Color(0xFFF0FDFA); // Teal 50

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Semantic Feedback
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successSurface = Color(0xFFECFDF5); // Emerald 50
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningSurface = Color(0xFFFFFBEB); // Amber 50
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorSurface = Color(0xFFFEF2F2); // Red 50
  static const Color info = Color(0xFF0284C7); // Sky 600
  static const Color infoSurface = Color(0xFFF0F9FF); // Sky 50
}

class KivoraTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: KivoraColors.primary,
        primary: KivoraColors.primary,
        onPrimary: Colors.white,
        surface: KivoraColors.surface,
        background: KivoraColors.background,
        error: KivoraColors.error,
      ),
      scaffoldBackgroundColor: KivoraColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: KivoraColors.background,
        foregroundColor: KivoraColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: KivoraColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KivoraColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26), // Pill style from design
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KivoraColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KivoraColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KivoraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KivoraColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(
          color: KivoraColors.textMuted,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: KivoraColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: KivoraColors.border),
        ),
      ),
    );
  }
}
