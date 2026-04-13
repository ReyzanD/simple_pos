import 'package:flutter/material.dart';

/// Neo-Brutalist Design System for POS
///
/// A bold, memorable alternative to generic enterprise software
/// Think: confident borders, chunky shadows, asymmetric layouts
class NeoBrutalTheme {
  NeoBrutalTheme._();

  // ============================================
  // BOLD COLORS - High Contrast, Memorable
  // ============================================

  /// Primary - Electric Blue
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryLight = Color(0xFF3399FF);
  static const Color primaryDark = Color(0xFF0044CC);

  /// Secondary - Vibrant Coral
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryLight = Color(0xFFFF8B5B);
  static const Color secondaryDark = Color(0xFFE04A10);

  /// Accent - Bright Yellow
  static const Color accent = Color(0xFFFFD700);
  static const Color accentLight = Color(0xFFFFE066);
  static const Color accentDark = Color(0xFFE5C100);

  /// Success - Bold Green
  static const Color success = Color(0xFF00CC44);
  static const Color successLight = Color(0xFF33FF77);
  static const Color successDark = Color(0xFF009933);

  /// Warning - Orange
  static const Color warning = Color(0xFFFF9500);
  static const Color warningLight = Color(0xFFFFAA33);
  static const Color warningDark = Color(0xFFCC7700);

  /// Error - Bright Red
  static const Color error = Color(0xFFFF3366);
  static const Color errorLight = Color(0xFFFF6699);
  static const Color errorDark = Color(0xFFCC0044);

  /// Background Colors - Bold, not subtle
  static const Color background = Color(0xFFFFFFFF); // ✅ Pure white - let borders and shadows create contrast
  static const Color surface = Color(0xFFFFFFFF); // ✅ White for cards
  static const Color surfaceVariant = Color(0xFFF5F5F5); // ✅ Very light gray for subtle variation

  /// Dark Mode
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkBorder = Color(0xFF333333);

  // ============================================
  // NEO-BRUTALIST BORDERS - The Hallmark
  // ============================================

  /// Aggressive 4px black border
  static const BorderSide brutalBorder = BorderSide(
    color: Colors.black,
    width: 4,
  );

  /// Medium 3px border
  static const BorderSide mediumBorder = BorderSide(
    color: Colors.black,
    width: 3,
  );

  /// Light 2px border
  static const BorderSide lightBorder = BorderSide(
    color: Colors.black,
    width: 2,
  );

  // ============================================
  // CHUNKY SHADOWS - 3D Effect
  // ============================================

  /// Dramatic shadow that makes elements pop
  static List<BoxShadow> get chunkyShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 0,
      offset: const Offset(6, 6),
      spreadRadius: 0,
    ),
  ];

  /// Softer shadow for depth
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 0,
      offset: const Offset(4, 4),
      spreadRadius: 0,
    ),
  ];

  /// Inset shadow for pressed state
  static List<BoxShadow> get insetShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 0,
      offset: const Offset(2, 2),
      spreadRadius: 0,
    ),
  ];

  /// Colored shadow for primary elements
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 0),
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // BOLD TYPOGRAPHY - Oversized & Confident
  // ============================================

  /// Display - Massive and bold
  static const TextStyle displayMassive = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    letterSpacing: -2,
    height: 0.9,
    color: Colors.black,
  );

  static const TextStyle displayHuge = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.5,
    height: 1.0,
    color: Colors.black,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.0,
    color: Colors.black,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
    color: Colors.black,
  );

  /// Headlines - Bold and impactful
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: Colors.black,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: Colors.black,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: Colors.black,
  );

  /// Body - Clear and readable
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Colors.black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: Colors.black,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Colors.black87,
  );

  /// Labels - Bold and uppercase
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    height: 1.2,
    color: Colors.black,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.3,
    color: Colors.black,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.3,
    color: Colors.black87,
  );

  // ============================================
  // BOLD BORDER RADIUS
  // ============================================

  static const double radiusNone = 0;      // Sharp corners (very brutal)
  static const double radiusSmall = 4;      // Slightly rounded
  static const double radiusMedium = 8;     // Moderately rounded
  static const double radiusLarge = 12;     // Well rounded
  static const double radiusXLarge = 16;    // Very rounded

  // ============================================
  // GENEROUS SPACING
  // ============================================

  static const double spaceXXS = 4;
  static const double spaceXS = 8;
  static const double spaceSM = 12;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;

  // ============================================
  // COLOR BLOCKS - For backgrounds and sections
  // ============================================

  static const Color blockBlue = Color(0xFF0066FF);
  static const Color blockCoral = Color(0xFFFF6B35);
  static const Color blockYellow = Color(0xFFFFD700);
  static const Color blockGreen = Color(0xFF00CC44);
  static const Color blockPink = Color(0xFFFF6699);
  static const Color blockPurple = Color(0xFF9933FF);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get appropriate text color
  static Color getTextColor(BuildContext context) {
    return Colors.black;
  }

  /// Get secondary text color
  static Color getSecondaryTextColor(BuildContext context) {
    return Colors.black87;
  }

  /// Get card color
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surface;
  }

  /// Get background color
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : background;
  }
}
