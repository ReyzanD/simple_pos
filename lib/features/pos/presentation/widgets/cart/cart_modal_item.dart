import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/category_controller.dart';
import 'package:simple_pos/features/pos/presentation/controllers/pos_controller.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart' as domain;
import 'package:simple_pos/features/sales/presentation/controllers/discount_controller.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/utils/currency_formatter.dart';
import 'package:simple_pos/core/utils/discount_calculator.dart';
import 'package:simple_pos/features/shared/presentation/providers.dart';

/// Individual cart item widget with brutal styling
class CartModalItem extends ConsumerWidget {
  final domain.CartItem item;
  final POSController controller;
  final Function(int quantity) onUpdateQuantity;
  final VoidCallback onRemove;

  const CartModalItem({
    super.key,
    required this.item,
    required this.controller,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryController = ref.watch(categoryControllerProvider);
    final discountController = ref.watch(discountControllerProvider);

    return _CartModalItemContent(
      item: item,
      controller: controller,
      onUpdateQuantity: onUpdateQuantity,
      onRemove: onRemove,
      categoryController: categoryController,
      discountController: discountController,
    );
  }
}

class _CartModalItemContent extends StatefulWidget {
  final domain.CartItem item;
  final POSController controller;
  final Function(int quantity) onUpdateQuantity;
  final VoidCallback onRemove;
  final CategoryController categoryController;
  final DiscountController discountController;

  const _CartModalItemContent({
    required this.item,
    required this.controller,
    required this.onUpdateQuantity,
    required this.onRemove,
    required this.categoryController,
    required this.discountController,
  });

  @override
  State<_CartModalItemContent> createState() => _CartModalItemContentState();
}

class _CartModalItemContentState extends State<_CartModalItemContent> {
  bool _isRemoving = false;

  void _handleRemove() {
    setState(() {
      _isRemoving = true;
    });
    Future.delayed(200.ms, () {
      if (mounted) {
        widget.onRemove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRemoving) {
      return const SizedBox.shrink()
          .animate()
          .fadeOut(duration: 200.ms)
          .slideX(begin: 0, end: 1, duration: 200.ms);
    }

    final currentItem = widget.controller.getCartItem(widget.item.product);
    final currentQuantity = currentItem?.quantity ?? widget.item.quantity;

    final product = widget.item.product;
    final canAddMore = currentItem?.canAddMore ?? widget.item.canAddMore;
    final isLowStock = product.isLowStock && !canAddMore;
    final isOutOfStock = product.isOutOfStock;

    double? categoryDiscount;
    if (product.categoryId != null) {
      final category = widget.categoryController.categories
          .where((c) => c.id == product.categoryId)
          .firstOrNull;
      if (category != null && category.hasDiscount) {
        categoryDiscount = category.discountPercentage;
      }
    }

    double? promotionDiscount;
    if (widget.discountController.activePromotions.isNotEmpty) {
      promotionDiscount = widget.discountController.activePromotions.first.discountPercentage;
    }

    final hasCompoundDiscount = product.hasAnyDiscount(
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );

    final compoundPrice = hasCompoundDiscount
        ? product.calculateCompoundPrice(
            categoryDiscount: categoryDiscount,
            promotionDiscount: promotionDiscount,
          )
        : product.price;

    final effectiveDiscount = hasCompoundDiscount
        ? DiscountCalculator.calculateEffectiveDiscountPercentage(
            basePrice: product.price,
            productDiscount: product.discountPercentage,
            categoryDiscount: categoryDiscount,
            promotionDiscount: promotionDiscount,
          )
        : null;

    final totalDiscount = hasCompoundDiscount
        ? widget.item.getCompoundDiscountBreakdown(
            categoryDiscount: categoryDiscount,
            promotionDiscount: promotionDiscount,
          ).totalDiscount
        : 0.0;

    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: isOutOfStock
              ? NeoBrutalTheme.error
              : Colors.black,
          width: isOutOfStock ? 5 : 4,
        ),
        boxShadow: isOutOfStock
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
      ),
      child: Row(
        children: [
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: NeoBrutalTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: NeoBrutalTheme.spaceSM),

                // Price display
                if (hasCompoundDiscount) ...[
                  // Original price (strikethrough)
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: NeoBrutalTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textTertiary,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppTheme.textTertiary,
                    ),
                  ),
                  SizedBox(height: 2),

                  // Compound price with discount badge
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(compoundPrice),
                        style: NeoBrutalTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.successColor,
                        ),
                      ),
                      SizedBox(width: NeoBrutalTheme.spaceSM),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: NeoBrutalTheme.spaceSM,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                          border: Border.all(
                            color: AppTheme.warningColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '-${effectiveDiscount!.toStringAsFixed(0)}%',
                          style: NeoBrutalTheme.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.warningColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Savings info
                  if (totalDiscount > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Hemat ${CurrencyFormatter.format(totalDiscount)}',
                        style: NeoBrutalTheme.bodySmall.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ] else ...[
                  // Regular price
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: NeoBrutalTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: NeoBrutalTheme.primary,
                    ),
                  ),
                ],

                // Stock status
                if (isOutOfStock)
                  Padding(
                    padding: EdgeInsets.only(top: NeoBrutalTheme.spaceSM),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: NeoBrutalTheme.spaceSM,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                        border: Border.all(
                          color: AppTheme.errorColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block_rounded,
                            size: 14,
                            color: AppTheme.errorColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'STOK HABIS',
                            style: NeoBrutalTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.errorColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isLowStock)
                  Padding(
                    padding: EdgeInsets.only(top: NeoBrutalTheme.spaceSM),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: NeoBrutalTheme.spaceSM,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                        border: Border.all(
                          color: AppTheme.warningColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: AppTheme.warningColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'STOK: ${product.stock}',
                            style: NeoBrutalTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Quantity controls with brutal styling
          SizedBox(width: NeoBrutalTheme.spaceMD),

          // Remove button
          GestureDetector(
            onTap: _handleRemove,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.errorColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
          ),

          SizedBox(width: NeoBrutalTheme.spaceSM),

          // Brutal quantity controls
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Minus button
                GestureDetector(
                  onTap: () => widget.onUpdateQuantity(currentQuantity - 1),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(NeoBrutalTheme.radiusSmall - 1),
                        bottomLeft: Radius.circular(NeoBrutalTheme.radiusSmall - 1),
                      ),
                      border: Border(
                        right: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.remove_rounded,
                        size: 20,
                        color: NeoBrutalTheme.primary,
                      ),
                    ),
                  ),
                ),

                // Quantity
                Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: Text(
                    '$currentQuantity',
                    style: NeoBrutalTheme.displayLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),

                // Plus button
                GestureDetector(
                  onTap: canAddMore
                      ? () => widget.onUpdateQuantity(currentQuantity + 1)
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: canAddMore
                          ? NeoBrutalTheme.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(NeoBrutalTheme.radiusSmall - 1),
                        bottomRight: Radius.circular(NeoBrutalTheme.radiusSmall - 1),
                      ),
                      border: Border(
                        left: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: canAddMore
                            ? NeoBrutalTheme.primary
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0, duration: 300.ms);
  }
}
