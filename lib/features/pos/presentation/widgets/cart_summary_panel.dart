import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Elevated floating panel at bottom of POS screen showing cart summary
///
/// Material 3 Features:
/// - Floating container with 16px margin and 20px border radius
/// - Subtle 0.5px border instead of heavy shadows
/// - Large bold font for total price
/// - Left: Cart icon badge, green items count, total price
/// - Right: Checkout button with check icon
class CartSummaryPanel extends StatefulWidget {
  final int itemCount;
  final double total;
  final bool isProcessing;
  final VoidCallback onCheckout;

  const CartSummaryPanel({
    super.key,
    required this.itemCount,
    required this.total,
    this.isProcessing = false,
    required this.onCheckout,
  });

  @override
  State<CartSummaryPanel> createState() => CartSummaryPanelState();
}

class CartSummaryPanelState extends State<CartSummaryPanel> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16), // 16px margin - makes it floating
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20), // 20px border radius
        // Subtle 0.5px border instead of heavy shadow
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 0.5,
        ),
        // Minimal shadow for elevation
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Much reduced
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side: Cart info
          Expanded(
            child: _buildCartInfo(),
          ),

          const SizedBox(width: 16),

          // Right side: Checkout button
          _buildCheckoutButton(),
        ],
      ),
    );
  }

  bool get isCartEmpty => widget.itemCount == 0;

  void bumpAnimation() {
    setState(() {
      _scale = 1.3;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
        });
      }
    });
  }

  Widget _buildCartInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with badges
        Row(
          children: [
            // Cart icon badge
            Transform.scale(
              scale: _scale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCartEmpty
                      ? Colors.grey.shade100
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 16,
                      color: isCartEmpty
                          ? Colors.grey.shade600
                          : AppTheme.primaryColor,
                    ),
                    if (widget.itemCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${widget.itemCount}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCartEmpty
                              ? Colors.grey.shade600
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.itemCount > 0) ...[
              const SizedBox(width: 12),
              // Green items badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.itemCount == 1 ? '1 item' : '${widget.itemCount} items',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Total price - LARGE BOLD font (32px instead of 28px)
        Text(
          CurrencyFormatter.format(widget.total),
          style: const TextStyle(
            fontSize: 32, // Increased from 28px for more prominence
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            letterSpacing: -0.5, // Better readability for large numbers
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isCartEmpty ? 'Keranjang kosong' : 'Subtotal',
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return ElevatedButton(
      onPressed: isCartEmpty || widget.isProcessing ? null : widget.onCheckout,
      style: ElevatedButton.styleFrom(
        backgroundColor: isCartEmpty
            ? Colors.grey.shade300
            : AppTheme.primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 20px radius to match panel
        ),
        elevation: isCartEmpty ? 0 : 1, // Reduced elevation (Material 3)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isProcessing)
            // Show spinner when processing
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else ...[
            // Check icon when not processing
            const Icon(Icons.check, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Checkout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5, // Better readability
              ),
            ),
          ],
        ],
      ),
    );
  }
}
