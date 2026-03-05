import 'dart:convert';
import '../../../features/pos/domain/entities/cart_item.dart';

/// Model for serializing cart to/from JSON for database storage
class CartModel {
  final String customerName;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.customerName,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert CartModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert CartModel to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create CartModel from JSON
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      customerName: json['customerName'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create CartModel from JSON string
  factory CartModel.fromJsonString(String jsonString) {
    return CartModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Create CartModel from a list of CartItems
  factory CartModel.fromCartItems({
    required String customerName,
    required List<CartItem> items,
  }) {
    final now = DateTime.now();
    return CartModel(
      customerName: customerName,
      items: items,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get total amount
  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Copy with
  CartModel copyWith({
    String? customerName,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
