import 'package:flutter/material.dart';

/// Central theme configuration following the Design System
///
/// Uses Material 3 with Indigo (#4F46E5) primary and Teal (#14B8A6) secondary colors.
/// All spacing, border radius, and colors follow the Design System standards.
///
/// Usage in MaterialApp:
/// ```dart
/// theme: AppTheme.lightTheme,
/// ```
///
/// Access colors directly:
/// ```dart
/// AppTheme.primaryColor    // #4F46E5 Indigo
/// AppTheme.secondaryColor  // #14B8A6 Teal
/// AppTheme.successColor    // #10B981 Green
/// AppTheme.warningColor    // #F59E0B Amber
/// AppTheme.errorColor      // #EF4444 Red
/// ```
class AppTheme {
  // ============================================
  // COLOR PALETTE - Design System Colors
  // ============================================

  // Primary Colors - Indigo based
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // Secondary Colors - Teal accent
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color secondaryLight = Color(0xFF2DD4BF);
  static const Color secondaryDark = Color(0xFF0F766E);

  // Semantic Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Error/Warning Container Colors (Material 3)
  static const Color errorContainer = Color(0xFFFEE2E2); // Soft Red
  static const Color errorOnContainer = Color(0xFF991B1B); // Dark Red

  // Background Colors
  static const Color backgroundColor = Color(0xFFF8FAFC); // Very light grey for scaffold
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Card Border - Subtle light grey border
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Border & Divider Colors
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFF3F4F6);

  // ============================================
  // THEME DATA - Material 3 Configuration
  // ============================================

  /// Get the light theme with Material 3 and Design System colors
  static ThemeData get lightTheme {
    return ThemeData(
      // Material 3 flag
      useMaterial3: true,

      // Color scheme from seed
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
        brightness: Brightness.light,
      ),

      // Scaffold background - very light grey to make white cards pop
      scaffoldBackgroundColor: backgroundColor,

      // Typography - Design System scale
      textTheme: _buildTextTheme(),

      // App Bar - Primary color with white text
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),

      // Card - Modern Material 3 style with 24px radius and subtle border
      cardTheme: CardThemeData(
        elevation: 0, // Remove shadow in favor of border
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Modern Material 3 radius
          side: const BorderSide(
            color: cardBorder,
            width: 0.5, // Subtle border
          ),
        ),
        color: cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button - Modern Material 3 with reduced elevation
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1, // Reduced elevation
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Increased from 12
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5, // Better readability
          ),
        ),
      ),

      // Outlined Button - Modern with thicker border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: primaryColor, width: 1.5), // Thicker border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Increased from 12
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button - Modern Material 3
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Slightly rounded
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Fields - Modern Material 3 with subtle borders
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC), // Light grey fill matches scaffold
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5), // Thicker on focus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: textTertiary,
          fontSize: 15,
        ),
      ),

      // Floating Action Button - Modern Material 3 with extended shape
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2, // Reduced elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // More rounded
        ),
        extendedTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Chip - Modern Material 3 with subtle border
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9), // Light indigo tint
        selectedColor: primaryColor.withValues(alpha: 0.15),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // More rounded
          side: const BorderSide(color: cardBorder, width: 0.5),
        ),
        side: const BorderSide(color: cardBorder, width: 0.5),
      ),

      // Dialog - Modern Material 3 with 24px radius
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Increased from 20
          side: const BorderSide(color: cardBorder, width: 0.5),
        ),
        elevation: 2, // Reduced elevation
        backgroundColor: surfaceColor,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),

      // Bottom Navigation Bar - White background with Indigo active
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white, // White background
        selectedItemColor: primaryColor, // Indigo for active
        unselectedItemColor: Colors.grey, // Grey for unselected
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Snack Bar - Modern Material 3 with better spacing
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Increased from 12
          side: const BorderSide(color: cardBorder, width: 0.5),
        ),
        elevation: 2, // Reduced elevation
      ),

      // List Tile - Modern Material 3 with better spacing
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Increased from 8
        ),
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),

      // NavigationBar (Material 3) - Modern bottom navigation
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        height: 65, // Slightly taller for better touch targets
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        indicatorColor: primaryColor.withValues(alpha: 0.12), // Subtle indicator
      ),
    );
  }

  // ============================================
  // TYPOGRAPHY - Design System Scale
  // ============================================

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display (hero text)
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),

      // Headlines
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      // Titles
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),

      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),

      // Labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textTertiary,
      ),
    );
  }
}

// ============================================
// CUSTOM SHADOWS - Modern Material 3 Elevation
// ============================================

/// Custom shadows following modern Material 3 elevation standards
/// Much more subtle - emphasizes borders over shadows
class AppShadows {
  /// Small elevation (cards, buttons) - Almost no shadow
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02), // Very subtle
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Medium elevation (floating elements) - Minimal shadow
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04), // Reduced
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Large elevation (dialogs, drawers) - Subtle shadow
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06), // Much reduced
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
