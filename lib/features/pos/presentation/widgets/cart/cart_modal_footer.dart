import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/l10n/app_localizations.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/currency_formatter.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart'
    as domain;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final cardColor = NeoBrutalTheme.getCardColor(context);
    final disabledColor = isDark
        ? const Color(0xFF333333)
        : Colors.grey.shade300;

    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            NeoBrutalTheme.getBackgroundColor(context),
            NeoBrutalTheme.getBackgroundColor(context).withValues(alpha: 0.95),
          ],
        ),
        border: Border(top: BorderSide(color: borderColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: NeoBrutalTheme.getShadowColor(context),
            offset: Offset(0, -6),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(
                  NeoBrutalTheme.radiusMedium,
                ),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: NeoBrutalTheme.getShadowColor(context),
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CartModalTotalRow(
                    label: AppLocalizations.of(context)!.cart_subtotal,
                    amount: subtotal,
                    context: context,
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceSM),
                  if (totalDiscount > 0) ...[
                    CartModalTotalRow(
                      label: AppLocalizations.of(context)!.cart_total_discount,
                      amount: -totalDiscount,
                      color: AppTheme.successColor,
                      context: context,
                    ),
                    SizedBox(height: NeoBrutalTheme.spaceSM),
                  ],
                  if (tax > 0) ...[
                    CartModalTotalRow(
                      label: AppLocalizations.of(context)!.tax_label,
                      amount: tax,
                      context: context,
                    ),
                    SizedBox(height: NeoBrutalTheme.spaceSM),
                  ],
                  Container(
                    height: 3,
                    color: NeoBrutalTheme.getTertiaryTextColor(
                      context,
                    ).withValues(alpha: 0.2),
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceSM),
                  CartModalTotalRow(
                    label: AppLocalizations.of(context)!.cart_total,
                    amount: total,
                    isBold: true,
                    fontSize: 24,
                    color: NeoBrutalTheme.primary,
                    context: context,
                  ),
                ],
              ),
            ),
            SizedBox(height: NeoBrutalTheme.spaceLG),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: cartItems.isEmpty || isProcessing
                          ? disabledColor
                          : AppTheme.infoColor,
                      borderRadius: BorderRadius.circular(
                        NeoBrutalTheme.radiusMedium,
                      ),
                      border: Border.all(color: borderColor, width: 4),
                      boxShadow: cartItems.isEmpty && !isProcessing
                          ? []
                          : [
                              BoxShadow(
                                color: NeoBrutalTheme.getShadowColor(context),
                                offset: Offset(6, 6),
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: AppTheme.infoColor.withValues(
                                  alpha: 0.5,
                                ),
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
                        borderRadius: BorderRadius.circular(
                          NeoBrutalTheme.radiusMedium,
                        ),
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
                                AppLocalizations.of(context)!.held_order_hold,
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
                          ? disabledColor
                          : null,
                      borderRadius: BorderRadius.circular(
                        NeoBrutalTheme.radiusMedium,
                      ),
                      border: Border.all(color: borderColor, width: 4),
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
                        borderRadius: BorderRadius.circular(
                          NeoBrutalTheme.radiusMedium,
                        ),
                        child: Center(
                          child: isProcessing
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
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
                                        style: NeoBrutalTheme.labelLarge
                                            .copyWith(
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
  final BuildContext context;

  const CartModalTotalRow({
    super.key,
    required this.label,
    required this.amount,
    this.isBold = false,
    this.fontSize,
    this.color,
    required this.context,
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
            color: color ?? NeoBrutalTheme.getSecondaryTextColor(this.context),
            letterSpacing: isBold ? 2 : 1,
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ?? NeoBrutalTheme.getTextColor(this.context),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
