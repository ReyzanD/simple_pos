import '../../../../core/exceptions/app_exceptions.dart';

/// Shift entity representing a cashier's work shift
/// Tracks opening/closing balance, sales by payment method, and transaction counts
class Shift {
  final int? id;
  final String userName;
  final double openingBalance;
  final double? closingBalance;
  final double cashSales;
  final double cardSales;
  final double qrSales;
  final double transferSales;
  final int totalTransactions;
  final DateTime openedAt;
  final DateTime? closedAt;

  const Shift({
    this.id,
    required this.userName,
    required this.openingBalance,
    this.closingBalance,
    this.cashSales = 0,
    this.cardSales = 0,
    this.qrSales = 0,
    this.transferSales = 0,
    this.totalTransactions = 0,
    required this.openedAt,
    this.closedAt,
  });

  /// Checks if this shift is currently active (not closed)
  bool get isActive => closedAt == null;

  /// Calculates total sales across all payment methods
  double get totalSales => cashSales + cardSales + qrSales + transferSales;

  /// Calculates expected closing balance (opening + cash sales)
  double get expectedClosingBalance => openingBalance + cashSales;

  /// Calculates the discrepancy between expected and actual closing balance
  /// Returns positive if there's more cash than expected, negative if less
  double? get discrepancy {
    if (closingBalance == null) return null;
    return closingBalance! - expectedClosingBalance;
  }

  /// Checks if there's a cash discrepancy (after shift is closed)
  bool get hasDiscrepancy {
    final disc = discrepancy;
    return disc != null && disc.abs() > 0.01; // Allow for small rounding errors
  }

  /// Creates a copy of this shift with the given fields replaced
  Shift copyWith({
    int? id,
    String? userName,
    double? openingBalance,
    double? closingBalance,
    double? cashSales,
    double? cardSales,
    double? qrSales,
    double? transferSales,
    int? totalTransactions,
    DateTime? openedAt,
    DateTime? closedAt,
  }) {
    return Shift(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      openingBalance: openingBalance ?? this.openingBalance,
      closingBalance: closingBalance ?? this.closingBalance,
      cashSales: cashSales ?? this.cashSales,
      cardSales: cardSales ?? this.cardSales,
      qrSales: qrSales ?? this.qrSales,
      transferSales: transferSales ?? this.transferSales,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  /// Validates the shift data
  /// Throws [ValidationException] if validation fails
  void validate() {
    if (userName.trim().isEmpty) {
      throw const ValidationException(
        'Nama kasir wajib diisi',
        field: 'Nama Kasir',
      );
    }

    if (openingBalance < 0) {
      throw const ValidationException(
        'Saldo awal tidak boleh negatif',
        field: 'Saldo Awal',
      );
    }

    if (closingBalance != null && closingBalance! < 0) {
      throw const ValidationException(
        'Saldo akhir tidak boleh negatif',
        field: 'Saldo Akhir',
      );
    }

    if (cashSales < 0 || cardSales < 0 || qrSales < 0 || transferSales < 0) {
      throw const ValidationException(
        'Penjualan tidak boleh negatif',
        field: 'Penjualan',
      );
    }

    if (totalTransactions < 0) {
      throw const ValidationException(
        'Jumlah transaksi tidak boleh negatif',
        field: 'Jumlah Transaksi',
      );
    }
  }

  /// Converts shift to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_name': userName,
      'opening_balance': openingBalance,
      'closing_balance': closingBalance,
      'cash_sales': cashSales,
      'card_sales': cardSales,
      'qr_sales': qrSales,
      'transfer_sales': transferSales,
      'total_transactions': totalTransactions,
      'opened_at': openedAt.millisecondsSinceEpoch,
      'closed_at': closedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a Shift from a database map
  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] as int?,
      userName: map['user_name'] as String,
      openingBalance: (map['opening_balance'] as num).toDouble(),
      closingBalance: map['closing_balance'] != null
          ? (map['closing_balance'] as num).toDouble()
          : null,
      cashSales: (map['cash_sales'] as num?)?.toDouble() ?? 0,
      cardSales: (map['card_sales'] as num?)?.toDouble() ?? 0,
      qrSales: (map['qr_sales'] as num?)?.toDouble() ?? 0,
      transferSales: (map['transfer_sales'] as num?)?.toDouble() ?? 0,
      totalTransactions: (map['total_transactions'] as int?) ?? 0,
      openedAt: DateTime.fromMillisecondsSinceEpoch(map['opened_at'] as int),
      closedAt: map['closed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['closed_at'] as int)
          : null,
    );
  }

  @override
  String toString() =>
      'Shift(id: $id, userName: $userName, openedAt: $openedAt, '
      'isActive: $isActive, totalSales: $totalSales)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Shift &&
        other.id == id &&
        other.userName == userName &&
        other.openingBalance == openingBalance &&
        other.closingBalance == closingBalance &&
        other.cashSales == cashSales &&
        other.cardSales == cardSales &&
        other.qrSales == qrSales &&
        other.transferSales == transferSales &&
        other.totalTransactions == totalTransactions &&
        other.openedAt == openedAt &&
        other.closedAt == closedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userName.hashCode ^
      openingBalance.hashCode ^
      closingBalance.hashCode ^
      cashSales.hashCode ^
      cardSales.hashCode ^
      qrSales.hashCode ^
      transferSales.hashCode ^
      totalTransactions.hashCode ^
      openedAt.hashCode ^
      closedAt.hashCode;
}
