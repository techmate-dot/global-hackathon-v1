import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class EchoesTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: EchoesColors.primary,
        secondary: EchoesColors.accent,
        surface: EchoesColors.surface,
        error: EchoesColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: EchoesColors.textPrimary,
        onError: Colors.white,
      ),

      // Typography
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
          color: EchoesColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.2,
          color: EchoesColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: EchoesColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: EchoesColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: EchoesColors.textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: EchoesColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: EchoesColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: EchoesColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: EchoesColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: EchoesColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: EchoesColors.textPrimary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: EchoesColors.textSecondary,
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EchoesColors.primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: EchoesSpacing.lg,
            vertical: EchoesSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EchoesBorderRadius.md),
          ),
          elevation: EchoesElevation.low,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: EchoesColors.surface,
        elevation: EchoesElevation.low,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EchoesBorderRadius.lg),
        ),
        margin: const EdgeInsets.all(EchoesSpacing.sm),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: EchoesColors.surface,
        foregroundColor: EchoesColors.textPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: EchoesColors.textPrimary,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EchoesColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EchoesBorderRadius.md),
          borderSide: const BorderSide(color: EchoesColors.textTertiary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EchoesBorderRadius.md),
          borderSide: const BorderSide(color: EchoesColors.textTertiary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EchoesBorderRadius.md),
          borderSide: const BorderSide(color: EchoesColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EchoesBorderRadius.md),
          borderSide: const BorderSide(color: EchoesColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: EchoesSpacing.md,
          vertical: EchoesSpacing.md,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: EchoesColors.background,
    );
  }

  // Story Theme for Merriweather font in story reader
  static TextTheme get storyTextTheme {
    return TextTheme(
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
        color: EchoesColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        height: 1.6,
        color: EchoesColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.merriweather(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.6,
        color: EchoesColors.textPrimary,
      ),
      labelMedium: GoogleFonts.merriweather(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
        color: EchoesColors.textSecondary,
      ),
    );
  }
}
