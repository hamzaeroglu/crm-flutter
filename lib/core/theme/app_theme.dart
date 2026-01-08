import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Modern Premium Color Palette ---
  static const Color primaryColor = Color(0xFF2D31FA); // Modern Indigo
  static const Color secondaryColor = Color(0xFF00D2FF); // Electric Blue
  static const Color accentColor = Color(0xFF6C63FF); // Soft Purple
  static const Color backgroundColor = Color(0xFFF8FAFF); // Very Light Blue/Grey
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFFF4D4D); // Soft Coral Red
  static const Color textPrimary = Color(0xFF1E293B); // Slate Blue/Dark
  static const Color textSecondary = Color(0xFF64748B); // Cool Grey

  // --- Glassmorphism & Effects ---
  static Color glassColor = Colors.white.withOpacity(0.7);
  static Color glassBorder = Colors.white.withOpacity(0.4);
  
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primaryColor.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontSize: 32,
        ),
        titleLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontSize: 22,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 15,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        color: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
      ),
    );
  }
}
