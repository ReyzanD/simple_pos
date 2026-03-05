/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'POS & Inventory';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'pos.db';
  static const int databaseVersion = 7;

  // Stock thresholds
  static const int lowStockThreshold = 10;
  static const int outOfStockThreshold = 0;

  // Private constructor to prevent instantiation
  AppConstants._();
}
