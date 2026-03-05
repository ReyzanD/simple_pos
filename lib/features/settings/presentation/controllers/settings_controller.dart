import 'package:flutter/foundation.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../shared/domain/entities/business_info.dart';
import '../../../../core/utils/logger.dart';

/// Controller for managing app settings
class SettingsController extends ChangeNotifier {
  final SettingsRepository _repository;

  SettingsController({required SettingsRepository repository})
      : _repository = repository {
    loadSettings();
  }

  // State
  Settings _settings = Settings.defaultSettings;
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  Settings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BusinessInfo get businessInfo => _settings.businessInfo;
  double get taxRate => _settings.taxRate;
  String get currencySymbol => _settings.currencySymbol;
  String get currencyCode => _settings.currencyCode;
  String get receiptFooter => _settings.receiptFooter;
  bool get taxEnabled => _settings.enableTax;
  int get lowStockThreshold => _settings.lowStockThreshold;

  /// Load settings
  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Loading settings');
      _settings = await _repository.getSettings();
      _isLoading = false;
      notifyListeners();
      AppLogger.info('Settings loaded successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      _settings = Settings.defaultSettings;
      notifyListeners();
      AppLogger.error('Failed to load settings', error: e, stackTrace: stackTrace);
    }
  }

  /// Save all settings
  Future<bool> saveSettings(Settings settings) async {
    try {
      AppLogger.info('Saving settings');
      await _repository.saveSettings(settings);
      _settings = settings;
      notifyListeners();
      AppLogger.info('Settings saved successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save settings', error: e, stackTrace: stackTrace);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update business info
  Future<bool> updateBusinessInfo(BusinessInfo businessInfo) async {
    try {
      final updated = _settings.copyWith(businessInfo: businessInfo);
      return await saveSettings(updated);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update business info', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Update tax rate
  Future<bool> updateTaxRate(double taxRate) async {
    try {
      final updated = _settings.copyWith(taxRate: taxRate);
      return await saveSettings(updated);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update tax rate', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Update currency settings
  Future<bool> updateCurrency({
    required String symbol,
    required String code,
  }) async {
    try {
      final updated = _settings.copyWith(
        currencySymbol: symbol,
        currencyCode: code,
      );
      return await saveSettings(updated);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update currency', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Update receipt footer
  Future<bool> updateReceiptFooter(String footer) async {
    try {
      final updated = _settings.copyWith(receiptFooter: footer);
      return await saveSettings(updated);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update receipt footer', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Toggle tax
  Future<bool> toggleTax(bool enabled) async {
    try {
      final updated = _settings.copyWith(enableTax: enabled);
      return await saveSettings(updated);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle tax', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Update low stock threshold
  Future<bool> updateLowStockThreshold(int threshold) async {
    try {
      final updated = _settings.copyWith(lowStockThreshold: threshold);
      return await saveSettings(updated);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update low stock threshold', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Reset settings to default
  Future<bool> resetSettings() async {
    try {
      AppLogger.info('Resetting settings to default');
      await _repository.resetSettings();
      _settings = Settings.defaultSettings;
      notifyListeners();
      AppLogger.info('Settings reset successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to reset settings', error: e, stackTrace: stackTrace);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Export settings
  Future<String?> exportSettings() async {
    try {
      return await _repository.exportSettings();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to export settings', error: e, stackTrace: stackTrace);
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Clear all data
  Future<bool> clearAllData() async {
    try {
      AppLogger.info('Clearing all data');
      await _repository.clearAllData();
      await _repository.resetSettings(); // Also reset settings to default
      _settings = Settings.defaultSettings;
      notifyListeners();
      AppLogger.info('All data cleared successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear all data', error: e, stackTrace: stackTrace);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
