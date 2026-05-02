import 'package:flutter/material.dart';
import 'package:simple_pos/features/sales/domain/entities/transaction.dart';
import 'package:simple_pos/features/sales/domain/entities/transaction_item.dart';
import 'package:simple_pos/features/sales/domain/entities/payment_method.dart';
import 'package:simple_pos/features/sales/domain/entities/payment_status.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/sales/domain/repositories/transaction_repository.dart';
import 'package:simple_pos/features/inventory/domain/entities/product_variant.dart';

class CartController extends ChangeNotifier {
  final TransactionRepository transactionRepository;

  CartController({required this.transactionRepository});

  // State
  final List<TransactionItem> _items = [];
  double _discount = 0.0;
  final double _taxRate = 0.0; // e.g., 0.11 for 11%
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  // Getters
  List<TransactionItem> get items => List.unmodifiable(_items);
  double get discount => _discount;
  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;

  // --- Calculations ---

  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  double get taxAmount => subtotal * _taxRate;

  double get totalAmount => (subtotal + taxAmount) - _discount;

  // --- Actions ---

  void addProduct(Product product, {ProductVariant? variant}) {
    // Use a unique key: ProductID + VariantID (if it exists)
    final String uniqueKey = variant != null
        ? '${product.id}_${variant.id}'
        : '${product.id}';

    final existingIndex = _items.indexWhere(
      (item) =>
          (variant != null
              ? '${item.productId}_${item.variantId}'
              : '${item.productId}') ==
          uniqueKey,
    );

    if (existingIndex >= 0) {
      // ... existing increment logic ...
    } else {
      _items.add(
        TransactionItem(
          transactionId: 0, // Placeholder
          productId: product
              .id!, // The Fix: Add the '!' to tell Dart this won't be null
          variantId: variant?.id! ?? 0,
          productName: variant != null
              ? '${product.name} (${variant.name})'
              : product.name,
          quantity: 1,
          unitPrice: variant?.price ?? product.price,
          subtotal: variant?.price ?? product.price,
          costPrice: variant?.costPrice ?? product.costPrice,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int delta) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final newQty = _items[index].quantity + delta;
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(
          quantity: newQty,
          subtotal: newQty * _items[index].unitPrice,
        );
      }
      notifyListeners();
    }
  }

  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _discount = 0.0;
    notifyListeners();
  }

  // --- Checkout ---

  Future<void> checkout() async {
    if (_items.isEmpty) return;

    try {
      final transaction = Transaction(
        transactionDate: DateTime.now(),
        subtotal: subtotal,
        tax: taxAmount,
        discount: _discount,
        totalAmount: totalAmount,
        paymentMethod: _selectedPaymentMethod,
        paymentStatus: PaymentStatus.completed,
        items: _items,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await transactionRepository.createTransaction(transaction);
      clearCart();
    } catch (e) {
      rethrow; // Handle this in the UI (e.g., show a SnackBar)
    }
  }
}
