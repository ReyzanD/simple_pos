import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/currency_formatter.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart' as domain;

/// Cart Modal Footer - Shows totals and action buttons
class CartModalFooter extends StatelessWidget {
  final List<domain.CartItem> cartItems;
  final double subtotal;
  final double totalDiscount;
  final double tax;
  final double total;
  final bool isProcessing;
  final VoidCallback onCheckout;
  final VoidCallback onHoldOrder;

  const CartModalFooter({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.totalDiscount,
    required this.tax,
    required this.total,
    required this.isProcessing,
    required this.onCheckout,
    required this.onHoldOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            NeoBrutalTheme.background,
            NeoBrutalTheme.background.withValues(alpha: 0.95),
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.black, width: 5), // ✅ Bold 5px border
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: Offset(0, -6),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Totals section
            Container(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CartModalTotalRow(label: 'Subtotal', amount: subtotal),
                  SizedBox(height: NeoBrutalTheme.spaceSM),

                  // Discount row
                  if (totalDiscount > 0) ...[
                    CartModalTotalRow(
                      label: 'Diskon',
                      amount: -totalDiscount,
                      color: AppTheme.successColor,
                    ),
                    SizedBox(height: NeoBrutalTheme.spaceSM),
                  ],

                  // Tax row
                  if (tax > 0) ...[
                    CartModalTotalRow(label: 'Pajak (11%)', amount: tax),
                    SizedBox(height: NeoBrutalTheme.spaceSM),
                  ],

                  // Divider
                  Container(
                    height: 3,
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceSM),

                  // Total - Dramatic
                  CartModalTotalRow(
                    label: 'TOTAL',
                    amount: total,
                    isBold: true,
                    fontSize: 24,
                    color: NeoBrutalTheme.primary,
                  ),
                ],
              ),
            ),
            SizedBox(height: NeoBrutalTheme.spaceLG),

            // Action buttons
            Row(
              children: [
                // Hold Order button
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: cartItems.isEmpty || isProcessing
                          ? Colors.grey.shade300
                          : AppTheme.infoColor,
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                      border: Border.all(
                        color: Colors.black,
                        width: 4,
                      ),
                      boxShadow: cartItems.isEmpty && !isProcessing
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: Offset(6, 6),
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: AppTheme.infoColor.withValues(alpha: 0.5),
                                offset: Offset(3, 3),
                                blurRadius: 8,
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: cartItems.isEmpty || isProcessing
                            ? null
                            : onHoldOrder,
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pause_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                              SizedBox(width: NeoBrutalTheme.spaceSM),
                              Text(
                                'TAHAN',
                                style: NeoBrutalTheme.labelLarge.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: NeoBrutalTheme.spaceMD),

                // Checkout button
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: cartItems.isEmpty || isProcessing
                          ? null
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                NeoBrutalTheme.primary,
                                NeoBrutalTheme.primary.withValues(alpha: 0.8),
                              ],
                            ),
                      color: cartItems.isEmpty || isProcessing
                          ? Colors.grey.shade300
                          : null,
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                      border: Border.all(
                        color: Colors.black,
                        width: 4,
                      ),
                      boxShadow: cartItems.isEmpty && !isProcessing
                          ? []
                          : NeoBrutalTheme.chunkyShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: cartItems.isEmpty || isProcessing
                            ? null
                            : onCheckout,
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                        child: Center(
                          child: isProcessing
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_rounded,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: NeoBrutalTheme.spaceSM),
                                    Flexible(
                                      child: Text(
                                        'BAYAR ${CurrencyFormatter.format(total)}',
                                        style: NeoBrutalTheme.labelLarge.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Brutal total row with dramatic styling
class CartModalTotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isBold;
  final double? fontSize;
  final Color? color;

  const CartModalTotalRow({
    super.key,
    required this.label,
    required this.amount,
    this.isBold = false,
    this.fontSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ?? Colors.black.withValues(alpha: 0.7),
            letterSpacing: isBold ? 2 : 1,
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ?? Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
