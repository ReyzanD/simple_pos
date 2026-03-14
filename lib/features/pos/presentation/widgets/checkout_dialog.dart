import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../sales/domain/entities/payment_method.dart';
import '../../../sales/domain/usecases/validate_payment_usecase.dart';
import '../../../sales/presentation/widgets/payment_method_selector.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../domain/entities/cart_item.dart';
import '../../../sales/presentation/controllers/discount_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

/// Dialog for checkout with payment processing
class CheckoutDialog extends StatefulWidget {
  final List<CartItem> cart;
  final Future<bool> Function({
    required PaymentMethod paymentMethod,
    double? cashReceived,
    String? cardLast4Digits,
  }) onConfirm;

  const CheckoutDialog({
    super.key,
    required this.cart,
    required this.onConfirm,
  });

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  double? _cashReceived;
  String? _cardLast4Digits;
  bool _isProcessing = false;
  String? _errorMessage;
  final ValidatePaymentUseCase _validatePaymentUseCase = ValidatePaymentUseCase();

  double get _subtotal {
    // Calculate subtotal with compound discounts
    final categoryController = context.read<CategoryController>();
    final discountController = context.read<DiscountController>();

    return widget.cart.fold(0, (sum, item) {
      // Get category discount
      double? categoryDiscount;
      if (item.product.categoryId != null) {
        final category = categoryController.categories
            .where((c) => c.id == item.product.categoryId)
            .firstOrNull;
        if (category != null && category.hasDiscount) {
          categoryDiscount = category.discountPercentage;
        }
      }

      // Get active promotion discount
      double? promotionDiscount;
      if (discountController.activePromotions.isNotEmpty) {
        promotionDiscount = discountController.activePromotions.first.discountPercentage;
      }

      return sum + item.getCompoundTotalPrice(
        categoryDiscount: categoryDiscount,
        promotionDiscount: promotionDiscount,
      );
    });
  }

  double get _totalDiscount {
    // Calculate total discount with compound discounts
    final categoryController = context.read<CategoryController>();
    final discountController = context.read<DiscountController>();

    return widget.cart.fold(0, (sum, item) {
      // Get category discount
      double? categoryDiscount;
      if (item.product.categoryId != null) {
        final category = categoryController.categories
            .where((c) => c.id == item.product.categoryId)
            .firstOrNull;
        if (category != null && category.hasDiscount) {
          categoryDiscount = category.discountPercentage;
        }
      }

      // Get active promotion discount
      double? promotionDiscount;
      if (discountController.activePromotions.isNotEmpty) {
        promotionDiscount = discountController.activePromotions.first.discountPercentage;
      }

      final breakdown = item.getCompoundDiscountBreakdown(
        categoryDiscount: categoryDiscount,
        promotionDiscount: promotionDiscount,
      );

      return sum + breakdown.totalDiscount;
    });
  }

  // Tax calculation (11% tax, only if enabled)
  double get _tax {
    final settingsController = context.read<SettingsController>();
    if (!settingsController.taxEnabled) return 0;
    return _subtotal * 0.11;
  }

  // Total amount including tax (only if enabled)
  double get _totalAmount => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konfirmasi Checkout'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Order Summary
            _buildOrderSummary(),
            const Divider(height: UIConstants.spacingLarge),
            const SizedBox(height: UIConstants.spacingSmall),

            // Payment Method Selector
            PaymentMethodSelector(
              initialMethod: _selectedPaymentMethod,
              totalAmount: _totalAmount,
              onPaymentSelected: (method, {cashReceived, cardLast4Digits}) {
                setState(() {
                  _selectedPaymentMethod = method;
                  _cashReceived = cashReceived;
                  _cardLast4Digits = cardLast4Digits;
                  _errorMessage = null;
                });
              },
              // Pass a callback to sync values when confirming
              onValueChange: (cashReceived) {
                setState(() {
                  _cashReceived = cashReceived;
                });
              },
            ),

            // Error Message
            if (_errorMessage != null) ...[
              const SizedBox(height: UIConstants.spacingMedium),
              Container(
                padding: const EdgeInsets.all(UIConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: UIConstants.spacingSmall),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900, fontSize: UIConstants.fontSizeSmall),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: UIConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Konfirmasi'),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Pesanan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: UIConstants.spacingMedium),

        // Items List
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.cart.length,
            itemBuilder: (context, index) {
              final item = widget.cart[index];

              // Get category discount
              final categoryController = context.watch<CategoryController>();
              final discountController = context.watch<DiscountController>();

              double? categoryDiscount;
              if (item.product.categoryId != null) {
                final category = categoryController.categories
                    .where((c) => c.id == item.product.categoryId)
                    .firstOrNull;
                if (category != null && category.hasDiscount) {
                  categoryDiscount = category.discountPercentage;
                }
              }

              // Get active promotion discount
              double? promotionDiscount;
              if (discountController.activePromotions.isNotEmpty) {
                promotionDiscount = discountController.activePromotions.first.discountPercentage;
              }

              // Check if has compound discount
              final hasCompoundDiscount = item.product.hasAnyDiscount(
                categoryDiscount: categoryDiscount,
                promotionDiscount: promotionDiscount,
              );

              final compoundPrice = hasCompoundDiscount
                  ? item.product.calculateCompoundPrice(
                      categoryDiscount: categoryDiscount,
                      promotionDiscount: promotionDiscount,
                    )
                  : item.product.price;

              final totalDiscount = hasCompoundDiscount
                  ? item.getCompoundDiscountBreakdown(
                      categoryDiscount: categoryDiscount,
                      promotionDiscount: promotionDiscount,
                    ).totalDiscount
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (hasCompoundDiscount) ...[
                            Text(
                              '${item.quantity} x ${CurrencyFormatter.format(item.product.price)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: UIConstants.fontSizeSmall,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              '${item.quantity} x ${CurrencyFormatter.format(compoundPrice)}',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: UIConstants.fontSizeSmall,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '${item.quantity} x ${CurrencyFormatter.format(item.product.price)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: UIConstants.fontSizeSmall,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasCompoundDiscount) ...[
                          Text(
                            CurrencyFormatter.format(item.subtotalBeforeDiscount),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: UIConstants.fontSizeSmall,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(compoundPrice * item.quantity),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          // Show discount amount
                          if (totalDiscount > 0)
                            Text(
                              '-${CurrencyFormatter.format(totalDiscount)}',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: UIConstants.fontSizeSmall,
                              ),
                            ),
                        ] else ...[
                          Text(
                            CurrencyFormatter.format(item.totalPrice),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const Divider(height: UIConstants.spacingLarge),

        // Totals
        _buildTotalRow('Subtotal', _subtotal),
        if (_totalDiscount > 0) ...[
          const SizedBox(height: UIConstants.spacingSmall),
          _buildTotalRow(
            'Diskon',
            -_totalDiscount,
            color: Colors.green,
          ),
        ],
        const SizedBox(height: UIConstants.spacingSmall),
        if (_tax > 0) _buildTotalRow('Pajak (11%)', _tax),
        const SizedBox(height: UIConstants.spacingSmall),
        _buildTotalRow(
          'Total',
          _totalAmount,
          isBold: true,
          fontSize: UIConstants.fontSizeLarge,
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false, double? fontSize, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: color,
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: color ?? (isBold ? UIConstants.primaryColor : null),
          ),
        ),
      ],
    );
  }

  Future<void> _handleConfirm() async {
    // Validate payment
    final validationResult = _validatePaymentUseCase.execute(
      paymentMethod: _selectedPaymentMethod,
      totalAmount: _totalAmount,
      cashReceived: _cashReceived,
      cardLast4Digits: _cardLast4Digits,
    );

    if (!validationResult.isValid) {
      setState(() {
        _errorMessage = validationResult.errorMessage;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onConfirm(
        paymentMethod: _selectedPaymentMethod,
        cashReceived: _cashReceived,
        cardLast4Digits: _cardLast4Digits,
      );

      if (mounted) {
        Navigator.of(context).pop(success);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memproses checkout: $e';
        _isProcessing = false;
      });
    }
  }
}

/// Shows the checkout dialog and returns true if checkout was successful
Future<bool> showCheckoutDialog({
  required BuildContext context,
  required List<CartItem> cart,
  required Future<bool> Function({
    required PaymentMethod paymentMethod,
    double? cashReceived,
    String? cardLast4Digits,
  }) onConfirm,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => CheckoutDialog(
      cart: cart,
      onConfirm: onConfirm,
    ),
  );

  return result ?? false;
}
