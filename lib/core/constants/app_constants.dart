/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'POS & Inventory';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'pos.db';
  static const int databaseVersion = 14;

  // Stock thresholds
  static const int lowStockThreshold = 10;
  static const int outOfStockThreshold = 0;

  // Private constructor to prevent instantiation
  AppConstants._();
}

/// Material 3 Spacing System (multiples of 4)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Private constructor to prevent instantiation
  AppSpacing._();
}

/// Border Radius values (Material 3 Style)
class AppBorderRadius {
  static const double xs = 8.0;   // Small elements (chips, badges, input fields)
  static const double sm = 10.0;  // Icon buttons, small buttons
  static const double md = 12.0;  // Standard buttons, dialogs
  static const double lg = 14.0;  // Medium containers
  static const double xl = 16.0;  // Large cards, important containers
  static const double xxl = 20.0; // Dialogs, bottom sheets
  static const double xxxl = 24.0; // Hero containers

  // Private constructor to prevent instantiation
  AppBorderRadius._();
}
