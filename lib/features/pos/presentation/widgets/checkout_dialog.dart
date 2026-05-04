import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sales/domain/entities/payment_method.dart';
import '../../../sales/domain/usecases/validate_payment_usecase.dart';
import '../../../sales/presentation/widgets/payment_method_selector.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../domain/entities/cart_item.dart';
import '../../../sales/presentation/controllers/discount_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../shared/presentation/providers.dart';
import 'package:simple_pos/l10n/app_localizations.dart';

/// Dialog for checkout with payment processing
class CheckoutDialog extends ConsumerStatefulWidget {
  final List<CartItem> cart;
  final Future<bool> Function({
    required PaymentMethod paymentMethod,
    double? cashReceived,
    String? cardLast4Digits,
    double tax,
    double discount,
    int? cashierId,
    String? cashierName,
  })
  onConfirm;

  const CheckoutDialog({
    super.key,
    required this.cart,
    required this.onConfirm,
  });

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  double? _cashReceived;
  String? _cardLast4Digits;
  bool _isProcessing = false;
  String? _errorMessage;
  final ValidatePaymentUseCase _validatePaymentUseCase =
      ValidatePaymentUseCase();

  double _subtotal(
    List<CartItem> cartItems,
    CategoryController categoryController,
    DiscountController discountController,
  ) {
    return cartItems.fold(0, (sum, item) {
      double? categoryDiscount;
      if (item.product.categoryId != null) {
        final category = categoryController.categories
            .where((c) => c.id == item.product.categoryId)
            .firstOrNull;
        if (category != null && category.hasDiscount) {
          categoryDiscount = category.discountPercentage;
        }
      }

      double? promotionDiscount;
      if (discountController.activePromotions.isNotEmpty) {
        promotionDiscount =
            discountController.activePromotions.first.discountPercentage;
      }

      return sum +
          item.getCompoundTotalPrice(
            categoryDiscount: categoryDiscount,
            promotionDiscount: promotionDiscount,
          );
    });
  }

  double _totalDiscount(
    List<CartItem> cartItems,
    CategoryController categoryController,
    DiscountController discountController,
  ) {
    return cartItems.fold(0, (sum, item) {
      double? categoryDiscount;
      if (item.product.categoryId != null) {
        final category = categoryController.categories
            .where((c) => c.id == item.product.categoryId)
            .firstOrNull;
        if (category != null && category.hasDiscount) {
          categoryDiscount = category.discountPercentage;
        }
      }

      double? promotionDiscount;
      if (discountController.activePromotions.isNotEmpty) {
        promotionDiscount =
            discountController.activePromotions.first.discountPercentage;
      }

      final breakdown = item.getCompoundDiscountBreakdown(
        categoryDiscount: categoryDiscount,
        promotionDiscount: promotionDiscount,
      );

      return sum + breakdown.totalDiscount;
    });
  }

  double _tax(double subtotal, SettingsController settingsController) {
    if (!settingsController.taxEnabled) return 0;
    return subtotal * settingsController.taxRate;
  }

  double _totalAmount(double subtotal, double tax) => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryController = ref.watch(categoryControllerProvider);
    final discountController = ref.watch(discountControllerProvider);
    final settingsController = ref.watch(settingsControllerProvider);

    final subtotal = _subtotal(
      widget.cart,
      categoryController,
      discountController,
    );
    final totalDiscount = _totalDiscount(
      widget.cart,
      categoryController,
      discountController,
    );
    final tax = _tax(subtotal, settingsController);
    final totalAmount = _totalAmount(subtotal, tax);

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.checkout_confirm),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(
                categoryController,
                discountController,
                subtotal,
                totalDiscount,
                tax,
                totalAmount,
              ),
              const Divider(height: UIConstants.spacingLarge),
              const SizedBox(height: UIConstants.spacingSmall),
              PaymentMethodSelector(
                initialMethod: _selectedPaymentMethod,
                totalAmount: totalAmount,
                onPaymentSelected: (method, {cashReceived, cardLast4Digits}) {
                  setState(() {
                    _selectedPaymentMethod = method;
                    _cashReceived = cashReceived;
                    _cardLast4Digits = cardLast4Digits;
                    _errorMessage = null;
                  });
                },
                onValueChange: (cashReceived) {
                  setState(() {
                    _cashReceived = cashReceived;
                  });
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: UIConstants.spacingMedium),
                Container(
                  padding: const EdgeInsets.all(UIConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.errorColor.withValues(alpha: 0.15)
                        : AppTheme.errorColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      UIConstants.radiusSmall,
                    ),
                    border: Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: UIConstants.spacingSmall),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: UIConstants.fontSizeSmall,
                          ),
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
          onPressed: _isProcessing
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)!.common_cancel),
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
              : Text(AppLocalizations.of(context)!.checkout_confirm),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(
    CategoryController categoryController,
    DiscountController discountController,
    double subtotal,
    double totalDiscount,
    double tax,
    double totalAmount,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.grey.shade600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.checkout_confirm,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        Container(
          constraints: const BoxConstraints(maxHeight: 150),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.cart.length,
            itemBuilder: (context, index) {
              final item = widget.cart[index];

              double? categoryDiscount;
              if (item.product.categoryId != null) {
                final category = categoryController.categories
                    .where((c) => c.id == item.product.categoryId)
                    .firstOrNull;
                if (category != null && category.hasDiscount) {
                  categoryDiscount = category.discountPercentage;
                }
              }

              double? promotionDiscount;
              if (discountController.activePromotions.isNotEmpty) {
                promotionDiscount = discountController
                    .activePromotions
                    .first
                    .discountPercentage;
              }

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

              final itemTotalDiscount = hasCompoundDiscount
                  ? item
                        .getCompoundDiscountBreakdown(
                          categoryDiscount: categoryDiscount,
                          promotionDiscount: promotionDiscount,
                        )
                        .totalDiscount
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: UIConstants.spacingSmall,
                ),
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
                                color: secondaryTextColor,
                                fontSize: UIConstants.fontSizeSmall,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              '${item.quantity} x ${CurrencyFormatter.format(compoundPrice)}',
                              style: TextStyle(
                                color: AppTheme.successColor,
                                fontSize: UIConstants.fontSizeSmall,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            Text(
                              '${item.quantity} x ${CurrencyFormatter.format(item.product.price)}',
                              style: TextStyle(
                                color: secondaryTextColor,
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
                            CurrencyFormatter.format(
                              item.subtotalBeforeDiscount,
                            ),
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: UIConstants.fontSizeSmall,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(
                              compoundPrice * item.quantity,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                          if (itemTotalDiscount > 0)
                            Text(
                              '-${CurrencyFormatter.format(itemTotalDiscount)}',
                              style: TextStyle(
                                color: AppTheme.successColor,
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
        _buildTotalRow(AppLocalizations.of(context)!.cart_subtotal, subtotal),
        if (totalDiscount > 0) ...[
          const SizedBox(height: UIConstants.spacingSmall),
          _buildTotalRow(
            AppLocalizations.of(context)!.cart_total_discount,
            -totalDiscount,
            color: AppTheme.successColor,
          ),
        ],
        const SizedBox(height: UIConstants.spacingSmall),
        if (tax > 0)
          _buildTotalRow(AppLocalizations.of(context)!.tax_label, tax),
        const SizedBox(height: UIConstants.spacingSmall),
        _buildTotalRow(
          AppLocalizations.of(context)!.cart_total,
          totalAmount,
          isBold: true,
          fontSize: UIConstants.fontSizeLarge,
        ),
      ],
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double? fontSize,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, // This is a dynamic label passed from _buildOrderSummary
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
    final categoryController = ref.read(categoryControllerProvider);
    final discountController = ref.read(discountControllerProvider);
    final settingsController = ref.read(settingsControllerProvider);
    final authController = ref.read(authControllerProvider);

    final subtotal = _subtotal(
      widget.cart,
      categoryController,
      discountController,
    );
    final totalDiscount = _totalDiscount(
      widget.cart,
      categoryController,
      discountController,
    );
    final tax = _tax(subtotal, settingsController);
    final totalAmount = _totalAmount(subtotal, tax);

    final cashierId = authController.currentUser?.id;
    final cashierName = authController.currentUser?.fullName;

    // Validate payment
    final validationResult = _validatePaymentUseCase.execute(
      paymentMethod: _selectedPaymentMethod,
      totalAmount: totalAmount,
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
        tax: tax,
        discount: totalDiscount,
        cashierId: cashierId,
        cashierName: cashierName,
      );

      if (mounted) {
        Navigator.of(context).pop(success);
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.checkout_error_discount;
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
    double tax,
    double discount,
    int? cashierId,
    String? cashierName,
  })
  onConfirm,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => CheckoutDialog(cart: cart, onConfirm: onConfirm),
  );

  return result ?? false;
}
