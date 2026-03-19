import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/settings.dart';
import '../../../shared/domain/entities/business_info.dart';
import '../../../../core/utils/logger.dart';

/// Local data source for settings using SharedPreferences
class SettingsLocalDataSource {
  static const String _keyBusinessName = 'business_name';
  static const String _keyBusinessAddress = 'business_address';
  static const String _keyBusinessPhone = 'business_phone';
  static const String _keyBusinessEmail = 'business_email';
  static const String _keyTaxRate = 'tax_rate';
  static const String _keyCurrencySymbol = 'currency_symbol';
  static const String _keyCurrencyCode = 'currency_code';
  static const String _keyReceiptFooter = 'receipt_footer';
  static const String _keyEnableTax = 'enable_tax';
  static const String _keyLowStockThreshold = 'low_stock_threshold';

  /// Get settings from SharedPreferences
  Future<Settings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return Settings(
        businessInfo: _getBusinessInfo(prefs),
        taxRate: prefs.getDouble(_keyTaxRate) ?? 0.11,
        currencySymbol: prefs.getString(_keyCurrencySymbol) ?? 'Rp',
        currencyCode: prefs.getString(_keyCurrencyCode) ?? 'IDR',
        receiptFooter: prefs.getString(_keyReceiptFooter) ?? 'Terima kasih atas kunjungan Anda!',
        enableTax: prefs.getBool(_keyEnableTax) ?? true,
        lowStockThreshold: prefs.getInt(_keyLowStockThreshold) ?? 10,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load settings', error: e, stackTrace: stackTrace);
      return Settings.defaultSettings;
    }
  }

  /// Save settings to SharedPreferences
  Future<void> saveSettings(Settings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save business info
      await prefs.setString(_keyBusinessName, settings.businessInfo.name);
      await prefs.setString(_keyBusinessAddress, settings.businessInfo.address);
      await prefs.setString(_keyBusinessPhone, settings.businessInfo.phone);
      await prefs.setString(_keyBusinessEmail, settings.businessInfo.email);

      // Save other settings
      await prefs.setDouble(_keyTaxRate, settings.taxRate);
      await prefs.setString(_keyCurrencySymbol, settings.currencySymbol);
      await prefs.setString(_keyCurrencyCode, settings.currencyCode);
      await prefs.setString(_keyReceiptFooter, settings.receiptFooter);
      await prefs.setBool(_keyEnableTax, settings.enableTax);
      await prefs.setInt(_keyLowStockThreshold, settings.lowStockThreshold);

      AppLogger.info('Settings saved successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save settings', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyBusinessName);
      await prefs.remove(_keyBusinessAddress);
      await prefs.remove(_keyBusinessPhone);
      await prefs.remove(_keyBusinessEmail);
      await prefs.remove(_keyTaxRate);
      await prefs.remove(_keyCurrencySymbol);
      await prefs.remove(_keyCurrencyCode);
      await prefs.remove(_keyReceiptFooter);
      await prefs.remove(_keyEnableTax);
      await prefs.remove(_keyLowStockThreshold);

      AppLogger.info('Settings cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear settings', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get business info from prefs
  BusinessInfo _getBusinessInfo(SharedPreferences prefs) {
    return BusinessInfo(
      name: prefs.getString(_keyBusinessName) ?? 'Toko Saya',
      address: prefs.getString(_keyBusinessAddress) ?? '',
      phone: prefs.getString(_keyBusinessPhone) ?? '',
      email: prefs.getString(_keyBusinessEmail) ?? '',
    );
  }

  /// Export settings to JSON string
  Future<String> exportSettings() async {
    try {
      final settings = await getSettings();
      final map = settings.toMap();
      return map.toString();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to export settings', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Import settings from JSON string
  Future<void> importSettings(String jsonString) async {
    try {
      AppLogger.info('Settings import requested');

      // Parse JSON string
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      // Create Settings from map
      final settings = Settings.fromMap(jsonMap);

      // Save settings
      await saveSettings(settings);

      AppLogger.info('Settings imported successfully');
    } on FormatException catch (e) {
      AppLogger.error('Invalid JSON format', error: e);
      throw const FormatException('Format JSON tidak valid. Pastikan file yang diimpor benar.');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to import settings', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
