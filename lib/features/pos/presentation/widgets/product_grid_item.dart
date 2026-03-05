import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../../sales/presentation/controllers/discount_controller.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/discount_calculator.dart';

/// Modern grid item widget for displaying a product in POS screen
///
/// Material 3 Features:
/// - 24px border radius (matches Design System)
/// - Subtle 0.5px border instead of shadows
/// - Reduced padding for better information density
/// - Larger, semi-bold product name
/// - Ghosted button when out of stock
class ProductGridItem extends StatefulWidget {
  final Product product;
  final int quantity;
  final VoidCallback onTap;
  final Function(Offset position)? onAddAnimation;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.quantity,
    required this.onTap,
    this.onAddAnimation,
  });

  @override
  State<ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<ProductGridItem> {
  bool _isPressed = false;
  final GlobalKey _widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.product.isOutOfStock;
    final canAddMore = !isOutOfStock && (widget.quantity < widget.product.stock);
    final hasQuantity = widget.quantity > 0;

    // Get category discount if product has a category
    final categoryController = context.watch<CategoryController>();
    final discountController = context.watch<DiscountController>();

    double? categoryDiscount;
    if (widget.product.categoryId != null) {
      final category = categoryController.categories
          .where((c) => c.id == widget.product.categoryId)
          .firstOrNull;
      if (category != null && category.hasDiscount) {
        categoryDiscount = category.discountPercentage;
      }
    }

    // Get active promotion discount (use the first active promotion if multiple)
    double? promotionDiscount;
    if (discountController.activePromotions.isNotEmpty) {
      promotionDiscount = discountController.activePromotions.first.discountPercentage;
    }

    // Calculate compound price
    final hasCompoundDiscount = widget.product.hasAnyDiscount(
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );

    final compoundPrice = hasCompoundDiscount
        ? widget.product.calculateCompoundPrice(
            categoryDiscount: categoryDiscount,
            promotionDiscount: promotionDiscount,
          )
        : widget.product.price;

    return Container(
      key: _widgetKey,
      child: GestureDetector(
        onTapDown: (_) {
          if (!isOutOfStock) {
            setState(() => _isPressed = true);
            // Haptic feedback
            HapticFeedback.lightImpact();
          }
        },
        onTapUp: (_) {
          if (!isOutOfStock) {
            setState(() => _isPressed = false);
          }
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
        },
        onTap: isOutOfStock ? null : () {
          // Trigger animation callback before calling onTap
          if (widget.onAddAnimation != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final RenderBox? renderBox = _widgetKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null) {
              final position = renderBox.localToGlobal(Offset.zero);
                widget.onAddAnimation!(position);
              }
            });
          }
          widget.onTap();
        },
        child: _buildCard(
          context,
          isOutOfStock,
          canAddMore,
          hasQuantity,
          hasCompoundDiscount,
          categoryDiscount,
          promotionDiscount,
          compoundPrice,
        ).animate()
            .scale(
              begin: const Offset(1.0, 1.0),
              end: _isPressed ? const Offset(0.95, 0.95) : const Offset(1.0, 1.0),
              duration: 100.ms,
              curve: Curves.easeInOut,
            ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    bool isOutOfStock,
    bool canAddMore,
    bool hasQuantity,
    bool hasCompoundDiscount,
    double? categoryDiscount,
    double? promotionDiscount,
    double compoundPrice,
  ) {
    return Container(
      decoration: BoxDecoration(
        // Light grey background when out of stock
        color: isOutOfStock ? const Color(0xFFF3F4F6) : AppTheme.cardColor,
        // Modern Material 3: 24px border radius
        borderRadius: BorderRadius.circular(24),
        // Subtle 0.5px border (Material 3 style)
        border: Border.all(
          color: hasQuantity ? AppTheme.primaryColor : AppTheme.cardBorder,
          width: hasQuantity ? 2 : 0.5,
        ),
        // No shadow - Material 3 emphasizes borders
        boxShadow: const [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quantity badge at top-right
            if (hasQuantity)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

            const Spacer(),

            // Product image or icon placeholder
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.product.imagePath != null && widget.product.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.product.imagePath!),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      _getProductIcon(),
                      size: 28,
                      color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    ),
            ),

            const SizedBox(height: 6),

            // Product name - LARGER and SEMI-BOLD with optional discount badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500, // Semi-bold (was w600)
                          color: isOutOfStock ? AppTheme.textTertiary : AppTheme.textPrimary,
                          fontSize: 15, // Increased from 13
                          letterSpacing: 0.2, // Better readability
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasCompoundDiscount) ...[
                  const SizedBox(width: 4),
                  // Calculate effective discount percentage
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppTheme.warningColor.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '-${DiscountCalculator.calculateEffectiveDiscountPercentage(
                        basePrice: widget.product.price,
                        productDiscount: widget.product.discountPercentage,
                        categoryDiscount: categoryDiscount,
                        promotionDiscount: promotionDiscount,
                      ).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 4),

            // Price (with discount display if applicable)
            if (hasCompoundDiscount) ...[
              // Original price (strikethrough)
              Text(
                CurrencyFormatter.format(widget.product.price),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textTertiary,
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppTheme.textTertiary,
                    ),
              ),
              const SizedBox(height: 2),
              // Compound price (green)
              Text(
                CurrencyFormatter.format(compoundPrice),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
              ),
            ] else ...[
              // Regular price
              Text(
                CurrencyFormatter.format(widget.product.price),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isOutOfStock ? AppTheme.textTertiary : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // Increased from 12
                    ),
              ),
            ],

            const SizedBox(height: 6),

            // Stock status
            _buildStockStatus(context, isOutOfStock),

            const SizedBox(height: 6),

            // Dynamic action button at bottom
            _buildActionButton(canAddMore, isOutOfStock),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(BuildContext context, bool isOutOfStock) {
    Color bgColor;
    Color textColor;
    String text;

    if (isOutOfStock) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      text = 'Stok Habis';
    } else if (widget.product.isLowStock) {
      bgColor = AppTheme.warningColor.withValues(alpha: 0.1);
      textColor = AppTheme.warningColor;
      text = 'Stok Rendah: ${widget.product.stock}';
    } else {
      bgColor = AppTheme.successColor.withValues(alpha: 0.1);
      textColor = AppTheme.successColor;
      text = 'Stok: ${widget.product.stock}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(bool canAddMore, bool isOutOfStock) {
    // Green "Tambah" button (default)
    if (canAddMore) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8), // Modern Material 3
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 13, // Slightly larger
              color: AppTheme.successColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Tambah',
              style: TextStyle(
                fontSize: 12, // Slightly larger
                fontWeight: FontWeight.w600,
                color: AppTheme.successColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    // Amber "Max" button (when quantity equals stock)
    if (!isOutOfStock && widget.quantity >= widget.product.stock) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8), // Modern Material 3
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 13,
              color: AppTheme.warningColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Max',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.warningColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    // Ghosted "Stok Habis" button
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer, // Soft Red background
        borderRadius: BorderRadius.circular(8), // Modern Material 3
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 13,
            color: AppTheme.errorOnContainer, // Dark Red
          ),
          const SizedBox(width: 4),
          Text(
            'Stok Habis',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.errorOnContainer, // Dark Red
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon() {
    // You can return different icons based on category
    // For now, using a general shopping icon
    return Icons.inventory_2_outlined;
  }
}
