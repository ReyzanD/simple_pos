import '../../domain/entities/shift.dart';

/// ShiftModel for data transfer between database and domain layer
class ShiftModel {
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

  const ShiftModel({
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

  /// Creates ShiftModel from domain entity
  factory ShiftModel.fromEntity(Shift shift) {
    return ShiftModel(
      id: shift.id,
      userName: shift.userName,
      openingBalance: shift.openingBalance,
      closingBalance: shift.closingBalance,
      cashSales: shift.cashSales,
      cardSales: shift.cardSales,
      qrSales: shift.qrSales,
      transferSales: shift.transferSales,
      totalTransactions: shift.totalTransactions,
      openedAt: shift.openedAt,
      closedAt: shift.closedAt,
    );
  }

  /// Converts to domain entity
  Shift toEntity() {
    return Shift(
      id: id,
      userName: userName,
      openingBalance: openingBalance,
      closingBalance: closingBalance,
      cashSales: cashSales,
      cardSales: cardSales,
      qrSales: qrSales,
      transferSales: transferSales,
      totalTransactions: totalTransactions,
      openedAt: openedAt,
      closedAt: closedAt,
    );
  }

  /// Creates ShiftModel from database map
  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
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

  /// Converts to map for database storage
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_name': userName,
      'opening_balance': openingBalance,
      'closing_balance': closingBalance ?? 0.0, // Use 0.0 as default for new shifts
      'cash_sales': cashSales,
      'card_sales': cardSales,
      'qr_sales': qrSales,
      'transfer_sales': transferSales,
      'total_transactions': totalTransactions,
      'opened_at': openedAt.millisecondsSinceEpoch,
      'closed_at': closedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a copy with the given fields replaced
  ShiftModel copyWith({
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
    return ShiftModel(
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

  @override
  String toString() =>
      'ShiftModel(id: $id, userName: $userName, openedAt: $openedAt, isActive: ${closedAt == null})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShiftModel &&
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
