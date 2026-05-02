import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'neo_brutal_theme.dart';

/// Overhauled AppTheme utilizing Neo-Brutalist design language
class AppTheme {
  // Core colors mapped to NeoBrutalTheme
  static const Color primaryColor = NeoBrutalTheme.primary;
  static const Color primaryLight = NeoBrutalTheme.primaryLight;
  static const Color primaryDark = NeoBrutalTheme.primaryDark;

  static const Color secondaryColor = NeoBrutalTheme.secondary;
  static const Color successColor = NeoBrutalTheme.success;
  static const Color warningColor = NeoBrutalTheme.warning;
  static const Color errorColor = NeoBrutalTheme.error;
  static const Color infoColor = NeoBrutalTheme.blockBlue;

  static const Color lightBackground = NeoBrutalTheme.background;
  static const Color lightSurface = NeoBrutalTheme.surface;
  static const Color darkBackground = NeoBrutalTheme.darkBackground;
  static const Color darkSurface = NeoBrutalTheme.darkSurface;

  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black87;
  static const Color textTertiary = Colors.black54;

  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white70;

  static const Color borderColor = Colors.black;
  static const Color dividerColor = Colors.black;
  static const Color darkBorderColor = NeoBrutalTheme.darkBorder;
  static const Color darkDividerColor = NeoBrutalTheme.darkBorder;

  static const Color errorContainer = Color(0xFFFFCCCC);
  static const Color errorOnContainer = Color(0xFFCC0000);
  
  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final primary = isDark ? NeoBrutalTheme.primaryDark : NeoBrutalTheme.primary;
    final backgroundColor = isDark ? NeoBrutalTheme.darkBackground : NeoBrutalTheme.background;
    final surfaceColor = isDark ? NeoBrutalTheme.darkSurface : NeoBrutalTheme.surface;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderCol = isDark ? NeoBrutalTheme.darkBorder : Colors.black;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: NeoBrutalTheme.secondary,
        error: NeoBrutalTheme.error,
        surface: surfaceColor,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: NeoBrutalTheme.blockBlue,
        foregroundColor: Colors.white,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 6)),
        titleTextStyle: NeoBrutalTheme.headlineMedium.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
        systemOverlayStyle: isDark 
          ? const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.light)
          : const SystemUiOverlayStyle(statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.dark),
      ),
      cardTheme: CardThemeData(
        elevation: 0, 
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          side: NeoBrutalTheme.mediumBorder.copyWith(color: borderCol),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            side: NeoBrutalTheme.mediumBorder.copyWith(color: borderCol),
          ),
          textStyle: NeoBrutalTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            side: NeoBrutalTheme.mediumBorder.copyWith(color: borderCol),
          ),
          textStyle: NeoBrutalTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: NeoBrutalTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? NeoBrutalTheme.darkSurface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          borderSide: NeoBrutalTheme.mediumBorder.copyWith(color: borderCol),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          borderSide: NeoBrutalTheme.mediumBorder.copyWith(color: borderCol),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          borderSide: BorderSide(color: primary, width: 4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          borderSide: BorderSide(color: NeoBrutalTheme.error, width: 3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          borderSide: BorderSide(color: NeoBrutalTheme.error, width: 4),
        ),
        labelStyle: NeoBrutalTheme.labelMedium.copyWith(color: isDark ? Colors.white70 : Colors.black87),
        hintStyle: NeoBrutalTheme.bodyMedium.copyWith(color: isDark ? Colors.white54 : Colors.black54),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          side: NeoBrutalTheme.mediumBorder.copyWith(color: borderCol),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? NeoBrutalTheme.darkSurface : const Color(0xFFF0F0F0),
        selectedColor: primary.withValues(alpha: 0.2),
        labelStyle: NeoBrutalTheme.labelMedium.copyWith(color: textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          side: NeoBrutalTheme.lightBorder.copyWith(color: borderCol),
        ),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
          side: BorderSide(color: borderCol, width: 4),
        ),
        titleTextStyle: NeoBrutalTheme.headlineLarge.copyWith(color: textColor),
        contentTextStyle: NeoBrutalTheme.bodyLarge.copyWith(color: textColor),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(NeoBrutalTheme.radiusLarge)),
          side: BorderSide(color: borderCol, width: 4),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderCol,
        thickness: 3,
        space: 3,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? NeoBrutalTheme.darkSurface : Colors.white,
        contentTextStyle: NeoBrutalTheme.bodyMedium.copyWith(color: textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          side: NeoBrutalTheme.mediumBorder.copyWith(color: borderCol),
        ),
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textColor,
        textColor: textColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: TextTheme(
        displayLarge: NeoBrutalTheme.displayLarge.copyWith(color: textColor),
        displayMedium: NeoBrutalTheme.displayMedium.copyWith(color: textColor),
        displaySmall: NeoBrutalTheme.displayMedium.copyWith(color: textColor, fontSize: 32),
        headlineLarge: NeoBrutalTheme.headlineLarge.copyWith(color: textColor),
        headlineMedium: NeoBrutalTheme.headlineMedium.copyWith(color: textColor),
        headlineSmall: NeoBrutalTheme.headlineSmall.copyWith(color: textColor),
        titleLarge: NeoBrutalTheme.headlineSmall.copyWith(color: textColor, fontSize: 18),
        titleMedium: NeoBrutalTheme.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.bold),
        titleSmall: NeoBrutalTheme.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold),
        bodyLarge: NeoBrutalTheme.bodyLarge.copyWith(color: textColor),
        bodyMedium: NeoBrutalTheme.bodyMedium.copyWith(color: textColor),
        bodySmall: NeoBrutalTheme.bodySmall.copyWith(color: textColor),
        labelLarge: NeoBrutalTheme.labelLarge.copyWith(color: textColor),
        labelMedium: NeoBrutalTheme.labelMedium.copyWith(color: textColor),
        labelSmall: NeoBrutalTheme.labelSmall.copyWith(color: textColor),
      ),
    );
  }

  // Fallback compatibility methods
  static Color getCardColor(BuildContext context) => Theme.of(context).cardColor;
  static Color getBackgroundColor(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  static Color getSurfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color getTextPrimaryColor(BuildContext context) => Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  static Color getTextSecondaryColor(BuildContext context) => Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87;
  static Color getBorderColor(BuildContext context) => Theme.of(context).dividerColor;
  static Color getErrorContainer(BuildContext context) => errorContainer;
  static Color getErrorOnContainer(BuildContext context) => errorOnContainer;
}

/// Fallbacks for older widgets relying on AppShadows
class AppShadows {
  static List<BoxShadow> get shadowSm => NeoBrutalTheme.softShadow;
  static List<BoxShadow> get shadowMd => NeoBrutalTheme.chunkyShadow;
  static List<BoxShadow> get shadowLg => NeoBrutalTheme.chunkyShadow;
  static List<BoxShadow> primaryShadow(double opacity) => NeoBrutalTheme.primaryGlow;
  static List<BoxShadow> successShadow(double opacity) => [BoxShadow(color: NeoBrutalTheme.success, blurRadius: 10)];
  static List<BoxShadow> errorShadow(double opacity) => [BoxShadow(color: NeoBrutalTheme.error, blurRadius: 10)];
}

/// Fallbacks for older widgets relying on AppGradients
class AppGradients {
  static const primary = LinearGradient(colors: [NeoBrutalTheme.primary, NeoBrutalTheme.primaryLight]);
  static const primarySubtle = LinearGradient(colors: [Color(0x330066FF), Color(0x110066FF)]);
  static const secondary = LinearGradient(colors: [NeoBrutalTheme.secondary, NeoBrutalTheme.secondaryLight]);
  static const success = LinearGradient(colors: [NeoBrutalTheme.success, NeoBrutalTheme.successLight]);
  static const cardShimmer = LinearGradient(colors: [Colors.black12, Colors.black26, Colors.black12]);
  static const darkCardShimmer = LinearGradient(colors: [Colors.white10, Colors.white24, Colors.white10]);
  static const sunset = LinearGradient(colors: [NeoBrutalTheme.primary, NeoBrutalTheme.secondary]);
  static const ocean = LinearGradient(colors: [NeoBrutalTheme.primary, NeoBrutalTheme.blockPurple]);
  static const glassOverlay = LinearGradient(colors: [Colors.white24, Colors.transparent]);
}
