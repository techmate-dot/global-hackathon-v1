import 'package:flutter/material.dart';

/// Echoes Color Palette
/// Duolingo-inspired friendly colors as specified in PRD
class EchoesColors {
  // Primary Colors
  static const Color primary = Color(0xFF6CC644); // Duolingo-ish friendly green
  static const Color accent = Color(0xFFFFB86B); // Warm orange
  static const Color secondary = Color(0xFF4A90E2); // Calm blue

  // Background & Surface
  static const Color background = Color(0xFFFFFDF7); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF); // Cards

  // Text Colors
  static const Color textPrimary = Color(0xFF0B1F2D); // Very dark
  static const Color textSecondary = Color(0xFF5A6B73); // Medium gray
  static const Color textTertiary = Color(0xFF8A9BA5); // Light gray

  // System Colors
  static const Color error = Color(0xFFE85D75);
  static const Color warning = Color(0xFFFFB86B);
  static const Color success = Color(0xFF6CC644);
  static const Color info = Color(0xFF4A90E2);

  // Gamification Colors
  static const Color streakGold = Color(0xFFFFD700);
  static const Color badgeGreen = Color(0xFF6CC644);
  static const Color progressBlue = Color(0xFF4A90E2);

  // Recording States
  static const Color recordingActive = Color(0xFFE85D75);
  static const Color recordingInactive = Color(0xFF8A9BA5);
  static const Color waveformActive = Color(0xFF6CC644);

  // Story Colors
  static const Color storyBackground = Color(0xFFFFF8E7);
  static const Color storyAccent = Color(0xFFFFB86B);

  // Shadows & Overlays
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
  static const Color overlay = Color(0x80000000);
}

/// Echoes Typography System
/// Merriweather for stories, Inter for UI as specified in PRD
class EchoesTypography {
  // Font Families
  static const String uiFontFamily = 'Inter';
  static const String storyFontFamily = 'Merriweather';

  // UI Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: EchoesColors.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: EchoesColors.textSecondary,
  );

  // Story Text Styles (Merriweather)
  static const TextStyle storyTitle = TextStyle(
    fontFamily: storyFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle storyBody = TextStyle(
    fontFamily: storyFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.6,
    color: EchoesColors.textPrimary,
  );

  static const TextStyle storyCaption = TextStyle(
    fontFamily: storyFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: EchoesColors.textSecondary,
  );

  // Button Text Styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: uiFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}

/// Echoes Spacing System
class EchoesSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Echoes Border Radius System
class EchoesBorderRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 1000.0; // Circular
}

/// Echoes Elevation System
class EchoesElevation {
  static const double none = 0.0;
  static const double low = 2.0;
  static const double medium = 4.0;
  static const double high = 8.0;
  static const double highest = 16.0;
}
