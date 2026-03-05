import '../entities/settings.dart';

/// Repository interface for settings
abstract class SettingsRepository {
  /// Get current settings
  Future<Settings> getSettings();

  /// Save settings
  Future<void> saveSettings(Settings settings);

  /// Reset settings to default
  Future<void> resetSettings();

  /// Export settings to JSON
  Future<String> exportSettings();

  /// Import settings from JSON
  Future<void> importSettings(String json);

  /// Clear all data (products, transactions, categories, suppliers, settings)
  Future<void> clearAllData();
}
