import '../entities/transaction.dart';

/// Store information for receipts
class StoreInfo {
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? taxId;

  const StoreInfo({
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.taxId,
  });

  /// Default store info
  static const StoreInfo defaultStore = StoreInfo(
    name: 'TOKO POS',
    address: 'Jl. Contoh No. 123',
    phone: '0812-3456-7890',
    email: 'info@tokopos.com',
    taxId: 'NPWP: 1234567890',
  );
}

/// Receipt entity containing transaction and store info
class Receipt {
  final Transaction transaction;
  final StoreInfo storeInfo;
  final DateTime printedAt;

  const Receipt({
    required this.transaction,
    required this.storeInfo,
    required this.printedAt,
  });

  /// Creates a receipt from a transaction
  factory Receipt.fromTransaction({
    required Transaction transaction,
    StoreInfo? storeInfo,
  }) {
    return Receipt(
      transaction: transaction,
      storeInfo: storeInfo ?? StoreInfo.defaultStore,
      printedAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'Receipt(transactionId: ${transaction.id}, store: ${storeInfo.name}, printedAt: $printedAt)';
}
