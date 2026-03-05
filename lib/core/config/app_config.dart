import '../constants/currency_constants.dart';
import '../constants/app_constants.dart';

/// Application configuration
/// Centralized configuration for all app settings
class AppConfig {
  // Singleton pattern
  AppConfig._internal();
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;

  // Store Information (Configurable)
  String storeName = AppConstants.appName;
  String storeAddress = 'Jl. Contoh No. 123';
  String storePhone = '0812-3456-7890';
  String storeEmail = 'info@tokopos.com';
  String? storeTaxId;

  // Business Rules
  int lowStockThreshold = AppConstants.lowStockThreshold;
  int outOfStockThreshold = AppConstants.outOfStockThreshold;
  double taxRate = 0.0; // 10% for example
  double defaultDiscount = 0.0;

  // Currency Settings
  String currencySymbol = CurrencyConstants.currencySymbol;
  String currencyDecimalSeparator = CurrencyConstants.decimalSeparator;
  String currencyThousandSeparator = CurrencyConstants.thousandSeparator;
  int currencyDecimalDigits = CurrencyConstants.decimalDigits;

  // Receipt Settings
  String receiptFooter = 'Terima kasih atas kunjungan Anda!';
  String receiptNoReturnPolicy = 'Barang yang sudah dibeli tidak dapat ditukar/dikembalikan';
  int receiptWidth = 80; // 80mm thermal printer

  // UI Settings
  double dialogMaxWidth = 500.0;
  int gridCrossAxisCount = 4;

  // Payment Settings
  bool allowCashPayment = true;
  bool allowCardPayment = true;
  bool allowQRPayment = true;
  bool allowTransferPayment = true;

  // Report Settings
  int topProductsLimit = 10;
  int defaultReportDays = 30;

  /// Update configuration from map
  void updateFromMap(Map<String, dynamic> config) {
    if (config.containsKey('storeName')) storeName = config['storeName'] as String;
    if (config.containsKey('storeAddress')) storeAddress = config['storeAddress'] as String;
    if (config.containsKey('storePhone')) storePhone = config['storePhone'] as String;
    if (config.containsKey('storeEmail')) storeEmail = config['storeEmail'] as String;
    if (config.containsKey('storeTaxId')) storeTaxId = config['storeTaxId'] as String?;
    if (config.containsKey('lowStockThreshold')) {
      lowStockThreshold = config['lowStockThreshold'] as int;
    }
    if (config.containsKey('taxRate')) taxRate = config['taxRate'] as double;
  }

  /// Convert configuration to map for storage
  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'storeAddress': storeAddress,
      'storePhone': storePhone,
      'storeEmail': storeEmail,
      'storeTaxId': storeTaxId,
      'lowStockThreshold': lowStockThreshold,
      'outOfStockThreshold': outOfStockThreshold,
      'taxRate': taxRate,
      'defaultDiscount': defaultDiscount,
      'currencySymbol': currencySymbol,
      'receiptFooter': receiptFooter,
      'receiptWidth': receiptWidth,
    };
  }

  /// Reset to defaults
  void reset() {
    storeName = AppConstants.appName;
    lowStockThreshold = AppConstants.lowStockThreshold;
    outOfStockThreshold = AppConstants.outOfStockThreshold;
    taxRate = 0.0;
    defaultDiscount = 0.0;
    receiptWidth = 80;
  }

  /// Validates configuration
  void validate() {
    if (storeName.trim().isEmpty) {
      throw Exception('Store name cannot be empty');
    }
    if (lowStockThreshold < 0) {
      throw Exception('Low stock threshold must be >= 0');
    }
    if (outOfStockThreshold < 0) {
      throw Exception('Out of stock threshold must be >= 0');
    }
    if (taxRate < 0 || taxRate > 1) {
      throw Exception('Tax rate must be between 0 and 1');
    }
    if (receiptWidth < 58 || receiptWidth > 80) {
      throw Exception('Receipt width must be between 58 and 80');
    }
  }
}
