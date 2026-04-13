import 'package:flutter/material.dart';

/// Enhanced theme system for professional yet friendly POS experience
///
/// Design Philosophy: Modern Professional with Warmth
/// - Clean efficiency like enterprise software
/// - Approachable touches that reduce stress
/// - Subtle animations and sophisticated shadows
/// - Clear visual hierarchy and generous touch targets
class EnhancedTheme {
  EnhancedTheme._();

  // ============================================
  // COLOR PALETTE - Professional with Warmth
  // ============================================

  /// Primary Colors - Sophisticated Indigo
  static const Color primary = Color(0xFF4F46E5);      // Rich indigo
  static const Color primaryLight = Color(0xFF818CF8); // Soft indigo
  static const Color primaryDark = Color(0xFF3730A3);  // Deep indigo

  /// Secondary Colors - Warm Teal
  static const Color secondary = Color(0xFF14B8A6);    // Warm teal
  static const Color secondaryLight = Color(0xFF2DD4BF); // Light teal
  static const Color secondaryDark = Color(0xFF0F766E);  // Deep teal

  /// Semantic Colors - Refined & Clear
  static const Color success = Color(0xFF10B981);      // Clear green
  static const Color warning = Color(0xFFF59E0B);      // Warm amber
  static const Color error = Color(0xFFEF4444);        // Clear red
  static const Color info = Color(0xFF3B82F6);         // Trustworthy blue

  /// Neutral Colors - Sophisticated Grays
  static const Color background = Color(0xFFFAFAFA);   // Warm white
  static const Color surface = Color(0xFFFFFFFF);      // Pure white
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Soft gray

  static const Color textPrimary = Color(0xFF111827);  // Rich black
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray
  static const Color textTertiary = Color(0xFF9CA3AF);  // Light gray

  static const Color border = Color(0xFFE5E7EB);       // Subtle border
  static const Color divider = Color(0xFFF3F4F6);      // Soft divider

  /// Dark Mode Colors - Sophisticated Dark
  static const Color darkBackground = Color(0xFF111827); // Rich dark
  static const Color darkSurface = Color(0xFF1F2937);    // Soft dark
  static const Color darkBorder = Color(0xFF374151);     // Subtle dark border

  // ============================================
  // SHADOW SYSTEM - Sophisticated Depth
  // ============================================

  /// Subtle shadow for cards and elevated elements
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow for floating elements
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Strong shadow for dialogs and overlays
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Colored shadow for primary actions (warm glow effect)
  static List<BoxShadow> primaryGlow(BuildContext context) => [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // BORDER RADIUS - Consistent & Friendly
  // ============================================

  static const double radiusSmall = 8.0;   // Chips, badges
  static const double radiusMedium = 12.0; // Buttons, cards
  static const double radiusLarge = 16.0;  // Large cards
  static const double radiusXLarge = 20.0; // Dialogs
  static const double radiusXXLarge = 24.0; // Hero containers

  // ============================================
  // SPACING SYSTEM - Consistent & Generous
  // ============================================

  static const double spacingXXS = 4.0;
  static const double spacingXS = 8.0;
  static const double spacingSM = 12.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 20.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;

  // ============================================
  // TYPOGRAPHY - Clear Hierarchy
  // ============================================

  /// Display text - Hero sections
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// Headlines - Section titles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Titles - Card titles, list items
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  /// Body - Main content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Labels - Buttons, tags
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ============================================
  // GRADIENTS - Sophisticated Transitions
  // ============================================

  /// Primary gradient - Sophisticated indigo
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    colors: [primary, primaryLight],
  );

  /// Secondary gradient - Warm teal
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    colors: [secondary, secondaryLight],
  );

  /// Success gradient - Reassuring green
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
    colors: [success, Color(0xFF34D399)],
  );

  /// Ocean gradient - For scanner button
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
  );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get appropriate text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.9)
        : textPrimary;
  }

  /// Get secondary text color based on theme
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.6)
        : textSecondary;
  }

  /// Get card color based on theme
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surface;
  }

  /// Get background color based on theme
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : background;
  }
}
