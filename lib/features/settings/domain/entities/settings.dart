import '../../../shared/domain/entities/business_info.dart';

/// App settings entity
class Settings {
  final BusinessInfo businessInfo;
  final double taxRate;
  final String currencySymbol;
  final String currencyCode;
  final String receiptFooter;
  final bool enableTax;
  final int lowStockThreshold;

  const Settings({
    required this.businessInfo,
    this.taxRate = 0.11, // 11% default tax (Indonesia)
    this.currencySymbol = 'Rp',
    this.currencyCode = 'IDR',
    this.receiptFooter = 'Terima kasih atas kunjungan Anda!',
    this.enableTax = true,
    this.lowStockThreshold = 10,
  });

  /// Creates a copy with the given fields replaced
  Settings copyWith({
    BusinessInfo? businessInfo,
    double? taxRate,
    String? currencySymbol,
    String? currencyCode,
    String? receiptFooter,
    bool? enableTax,
    int? lowStockThreshold,
  }) {
    return Settings(
      businessInfo: businessInfo ?? this.businessInfo,
      taxRate: taxRate ?? this.taxRate,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      enableTax: enableTax ?? this.enableTax,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }

  /// Calculate tax amount
  double calculateTax(double subtotal) {
    if (!enableTax) return 0;
    return subtotal * taxRate;
  }

  /// Calculate total with tax
  double calculateTotal(double subtotal) {
    return subtotal + calculateTax(subtotal);
  }

  /// Format currency
  String formatCurrency(double amount) {
    return '$currencySymbol $amount.toStringAsFixed(0)';
  }

  /// Converts settings to map for storage
  Map<String, dynamic> toMap() {
    return {
      'businessName': businessInfo.name,
      'businessAddress': businessInfo.address,
      'businessPhone': businessInfo.phone,
      'businessEmail': businessInfo.email,
      'taxRate': taxRate,
      'currencySymbol': currencySymbol,
      'currencyCode': currencyCode,
      'receiptFooter': receiptFooter,
      'enableTax': enableTax,
      'lowStockThreshold': lowStockThreshold,
    };
  }

  /// Creates Settings from a map
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      businessInfo: BusinessInfo(
        name: map['businessName'] as String? ?? '',
        address: map['businessAddress'] as String? ?? '',
        phone: map['businessPhone'] as String? ?? '',
        email: map['businessEmail'] as String? ?? '',
      ),
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0.11,
      currencySymbol: map['currencySymbol'] as String? ?? 'Rp',
      currencyCode: map['currencyCode'] as String? ?? 'IDR',
      receiptFooter: map['receiptFooter'] as String? ?? 'Terima kasih atas kunjungan Anda!',
      enableTax: map['enableTax'] as bool? ?? true,
      lowStockThreshold: map['lowStockThreshold'] as int? ?? 10,
    );
  }

  /// Default settings
  static const Settings defaultSettings = Settings(
    businessInfo: BusinessInfo(
      name: 'Toko Saya',
      address: 'Jl. Contoh No. 123',
      phone: '08123456789',
      email: 'toko@example.com',
    ),
  );

  @override
  String toString() =>
      'Settings(businessInfo: $businessInfo, taxRate: $taxRate, currencySymbol: $currencySymbol)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Settings &&
        other.businessInfo == businessInfo &&
        other.taxRate == taxRate &&
        other.currencySymbol == currencySymbol &&
        other.currencyCode == currencyCode &&
        other.receiptFooter == receiptFooter &&
        other.enableTax == enableTax &&
        other.lowStockThreshold == lowStockThreshold;
  }

  @override
  int get hashCode =>
      businessInfo.hashCode ^
      taxRate.hashCode ^
      currencySymbol.hashCode ^
      currencyCode.hashCode ^
      receiptFooter.hashCode ^
      enableTax.hashCode ^
      lowStockThreshold.hashCode;
}
