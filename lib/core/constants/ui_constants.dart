import 'package:flutter/material.dart';

/// UI-related constants
class UIConstants {
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 24.0;

  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;

  // Grid
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 1.2;
  static const double gridCrossAxisSpacing = 10.0;
  static const double gridMainAxisSpacing = 10.0;

  // Card
  static const double cardElevation = 4.0;

  // Font Sizes
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;

  // Button
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 16.0;

  // Animation Duration
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);

  // Colors
  static const Color primaryColor = Colors.indigo;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;

  // Private constructor to prevent instantiation
  UIConstants._();
}
