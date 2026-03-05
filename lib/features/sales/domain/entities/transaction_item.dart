import '../../../inventory/domain/entities/product.dart';

/// Transaction item entity representing a product in a transaction
class TransactionItem {
  final int? id;
  final int transactionId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  /// Creates a copy of this transaction item with the given fields replaced
  TransactionItem copyWith({
    int? id,
    int? transactionId,
    int? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  /// Creates a TransactionItem from a cart item
  factory TransactionItem.fromCartItem({
    required int transactionId,
    required Product product,
    required int quantity,
  }) {
    return TransactionItem(
      transactionId: transactionId,
      productId: product.id!,
      productName: product.name,
      quantity: quantity,
      unitPrice: product.price,
      subtotal: product.price * quantity,
    );
  }

  /// Converts transaction item to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  /// Creates a TransactionItem from a database map
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  @override
  String toString() =>
      'TransactionItem(id: $id, productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, subtotal: $subtotal)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionItem &&
        other.id == id &&
        other.transactionId == transactionId &&
        other.productId == productId &&
        other.productName == productName &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice &&
        other.subtotal == subtotal;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      transactionId.hashCode ^
      productId.hashCode ^
      productName.hashCode ^
      quantity.hashCode ^
      unitPrice.hashCode ^
      subtotal.hashCode;
}
