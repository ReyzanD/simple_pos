import 'package:flutter/material.dart';
import 'neo_brutal_theme.dart';

/// EnhancedTheme is now an alias for NeoBrutalTheme
/// This maintains backwards compatibility for older widgets while enforcing
/// the new Neo-Brutalist design language across the app.
class EnhancedTheme {
  EnhancedTheme._();

  // ============================================
  // COLOR PALETTE - Mapped to NeoBrutal
  // ============================================

  static const Color primary = NeoBrutalTheme.primary;
  static const Color primaryLight = NeoBrutalTheme.primaryLight;
  static const Color primaryDark = NeoBrutalTheme.primaryDark;

  static const Color secondary = NeoBrutalTheme.secondary;
  static const Color secondaryLight = NeoBrutalTheme.secondaryLight;
  static const Color secondaryDark = NeoBrutalTheme.secondaryDark;

  static const Color success = NeoBrutalTheme.success;
  static const Color warning = NeoBrutalTheme.warning;
  static const Color error = NeoBrutalTheme.error;
  static const Color info = NeoBrutalTheme.blockBlue;

  static const Color background = NeoBrutalTheme.background;
  static const Color surface = NeoBrutalTheme.surface;
  static const Color surfaceVariant = NeoBrutalTheme.surfaceVariant;

  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black87;
  static const Color textTertiary = Colors.black54;

  static const Color border = Colors.black;
  static const Color divider = Colors.black;

  static const Color darkBackground = NeoBrutalTheme.darkBackground;
  static const Color darkSurface = NeoBrutalTheme.darkSurface;
  static const Color darkBorder = NeoBrutalTheme.darkBorder;

  // ============================================
  // SHADOW SYSTEM - Mapped to NeoBrutal
  // ============================================

  static List<BoxShadow> get subtleShadow => NeoBrutalTheme.softShadow;
  static List<BoxShadow> get mediumShadow => NeoBrutalTheme.chunkyShadow;
  static List<BoxShadow> get strongShadow => NeoBrutalTheme.chunkyShadow;

  static List<BoxShadow> primaryGlow(BuildContext context) => NeoBrutalTheme.primaryGlow;

  // ============================================
  // BORDER RADIUS - Mapped to NeoBrutal
  // ============================================

  static const double radiusSmall = NeoBrutalTheme.radiusSmall;
  static const double radiusMedium = NeoBrutalTheme.radiusMedium;
  static const double radiusLarge = NeoBrutalTheme.radiusLarge;
  static const double radiusXLarge = NeoBrutalTheme.radiusXLarge;
  static const double radiusXXLarge = NeoBrutalTheme.radiusXLarge;

  // ============================================
  // SPACING SYSTEM
  // ============================================

  static const double spacingXXS = NeoBrutalTheme.spaceXXS;
  static const double spacingXS = NeoBrutalTheme.spaceXS;
  static const double spacingSM = NeoBrutalTheme.spaceSM;
  static const double spacingMD = NeoBrutalTheme.spaceMD;
  static const double spacingLG = NeoBrutalTheme.spaceLG;
  static const double spacingXL = NeoBrutalTheme.spaceXL;
  static const double spacingXXL = NeoBrutalTheme.spaceXXL;

  // ============================================
  // TYPOGRAPHY - Mapped to NeoBrutal
  // ============================================

  static const TextStyle displayLarge = NeoBrutalTheme.displayLarge;
  static const TextStyle displayMedium = NeoBrutalTheme.displayMedium;
  static const TextStyle displaySmall = NeoBrutalTheme.displayMedium;

  static const TextStyle headlineLarge = NeoBrutalTheme.headlineLarge;
  static const TextStyle headlineMedium = NeoBrutalTheme.headlineMedium;
  static const TextStyle headlineSmall = NeoBrutalTheme.headlineSmall;

  static const TextStyle titleLarge = NeoBrutalTheme.headlineSmall;
  static const TextStyle titleMedium = NeoBrutalTheme.bodyLarge;
  static const TextStyle titleSmall = NeoBrutalTheme.bodyMedium;

  static const TextStyle bodyLarge = NeoBrutalTheme.bodyLarge;
  static const TextStyle bodyMedium = NeoBrutalTheme.bodyMedium;
  static const TextStyle bodySmall = NeoBrutalTheme.bodySmall;

  static const TextStyle labelLarge = NeoBrutalTheme.labelLarge;
  static const TextStyle labelMedium = NeoBrutalTheme.labelMedium;
  static const TextStyle labelSmall = NeoBrutalTheme.labelSmall;

  // ============================================
  // GRADIENTS - Mapped to NeoBrutal (solid blocks)
  // ============================================

  static const LinearGradient primaryGradient = LinearGradient(colors: [primary, primary]);
  static const LinearGradient secondaryGradient = LinearGradient(colors: [secondary, secondary]);
  static const LinearGradient successGradient = LinearGradient(colors: [success, success]);
  static const LinearGradient oceanGradient = LinearGradient(colors: [primary, success]);

  // ============================================
  // HELPER METHODS
  // ============================================

  static Color getTextColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  static Color getSecondaryTextColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87;
  static Color getCardColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;
  static Color getBackgroundColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkBackground : background;
}
