import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../../sales/presentation/controllers/discount_controller.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../shared/presentation/providers.dart';

/// Modern grid item widget for displaying a product in POS screen
///
/// Material 3 Features:
/// - 24px border radius (matches Design System)
/// - Subtle 0.5px border instead of shadows
/// - Reduced padding for better information density
/// - Larger, semi-bold product name
/// - Ghosted button when out of stock
/// - Staggered entrance animation
class ProductGridItem extends ConsumerWidget {
  final Product product;
  final int quantity;
  final VoidCallback onTap;
  final Function(Offset position)? onAddAnimation;
  final int? index;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.quantity,
    required this.onTap,
    this.onAddAnimation,
    this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryController = ref.watch(categoryControllerProvider);
    final discountController = ref.watch(discountControllerProvider);

    return _ProductGridItemContent(
      product: product,
      quantity: quantity,
      onTap: onTap,
      onAddAnimation: onAddAnimation,
      index: index,
      categoryController: categoryController,
      discountController: discountController,
    );
  }
}

class _ProductGridItemContent extends StatefulWidget {
  final Product product;
  final int quantity;
  final VoidCallback onTap;
  final Function(Offset position)? onAddAnimation;
  final int? index;
  final CategoryController categoryController;
  final DiscountController discountController;

  const _ProductGridItemContent({
    required this.product,
    required this.quantity,
    required this.onTap,
    this.onAddAnimation,
    this.index,
    required this.categoryController,
    required this.discountController,
  });

  @override
  State<_ProductGridItemContent> createState() => _ProductGridItemContentState();
}

class _ProductGridItemContentState extends State<_ProductGridItemContent> {
  bool _isPressed = false;
  final GlobalKey _widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.product.isOutOfStock;
    final canAddMore = !isOutOfStock && (widget.quantity < widget.product.stock);
    final hasQuantity = widget.quantity > 0;

    double? categoryDiscount;
    if (widget.product.categoryId != null) {
      final category = widget.categoryController.categories
          .where((c) => c.id == widget.product.categoryId)
          .firstOrNull;
      if (category != null && category.hasDiscount) {
        categoryDiscount = category.discountPercentage;
      }
    }

    // Get active promotion discount (use the first active promotion if multiple)
    double? promotionDiscount;
    if (widget.discountController.activePromotions.isNotEmpty) {
      promotionDiscount = widget.discountController.activePromotions.first.discountPercentage;
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
                final size = renderBox.size;
                // Calculate center position, accounting for the 40px animation container
                final centerPosition = Offset(
                  position.dx + size.width / 2 - 20, // 20 = half of container width (40px)
                  position.dy + size.height / 2 - 20, // 20 = half of container height (40px)
                );
                widget.onAddAnimation!(centerPosition);
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
        ).animate(
          delay: (widget.index != null ? Duration(milliseconds: widget.index! * 50) : Duration.zero),
        ).fadeIn(
          duration: 300.ms,
          curve: Curves.easeOut,
        ).slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        ).then().scale(
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
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      height: ResponsiveHelper.getValue(
        context: context,
        mobile: 80.0,
        tablet: 85.0,
        desktop: 90.0,
      ),
      decoration: BoxDecoration(
        color: isOutOfStock ? const Color(0xFFF3F4F6) : Colors.white,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: hasQuantity ? NeoBrutalTheme.primary : Colors.black,
          width: 3, // Bold Neo-Brutalist border
        ),
        boxShadow: hasQuantity ? NeoBrutalTheme.chunkyShadow : NeoBrutalTheme.softShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveHelper.getValue(
            context: context,
            mobile: 10.0,
            tablet: 12.0,
            desktop: 14.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Compact product image (left side)
            SizedBox(
              width: ResponsiveHelper.getValue(
                context: context,
                mobile: 50.0,
                tablet: 55.0,
                desktop: 60.0,
              ),
              height: ResponsiveHelper.getValue(
                context: context,
                mobile: 50.0,
                tablet: 55.0,
                desktop: 60.0,
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: NeoBrutalTheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: widget.product.imagePath != null && widget.product.imagePath!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              File(widget.product.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.inventory_2_outlined,
                            size: ResponsiveHelper.getIconSize(context),
                            color: NeoBrutalTheme.primary,
                          ),
                  ),
                  // Quantity badge
                  if (hasQuantity)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: NeoBrutalTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          '${widget.quantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(
              width: ResponsiveHelper.getValue(
                context: context,
                mobile: 10.0,
                tablet: 12.0,
                desktop: 14.0,
              ),
            ),

            // Product info (center - more space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Product name
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(
                        context,
                        mobile: 15.0,
                        tablet: 16.0,
                        desktop: 17.0,
                      ),
                      fontWeight: FontWeight.w700,
                      color: isOutOfStock
                          ? AppTheme.textTertiary
                          : Colors.black,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getValue(
                      context: context,
                      mobile: 4.0,
                      tablet: 5.0,
                      desktop: 6.0,
                    ),
                  ),
                  // Price with discount support
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasCompoundDiscount)
                        Text(
                          CurrencyFormatter.format(widget.product.price),
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(
                              context,
                              mobile: 12.0,
                              tablet: 13.0,
                              desktop: 14.0,
                            ),
                            color: AppTheme.textTertiary,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppTheme.textTertiary,
                            height: 1.0,
                          ),
                          maxLines: 1,
                        ),
                      Text(
                        hasCompoundDiscount
                            ? CurrencyFormatter.format(compoundPrice)
                            : CurrencyFormatter.format(widget.product.price),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            mobile: 17.0,
                            tablet: 18.0,
                            desktop: 19.0,
                          ),
                          fontWeight: FontWeight.w900,
                          color: hasCompoundDiscount
                              ? AppTheme.successColor
                              : NeoBrutalTheme.primary,
                          height: 1.1,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              width: ResponsiveHelper.getValue(
                context: context,
                mobile: 8.0,
                tablet: 10.0,
                desktop: 12.0,
              ),
            ),

            // Action button (right side)
            _buildCompactActionButton(canAddMore, isOutOfStock, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionButton(bool canAddMore, bool isOutOfStock, bool isMobile) {
    final buttonSize = ResponsiveHelper.getValue(
      context: context,
      mobile: 36.0,
      tablet: 40.0,
      desktop: 44.0,
    );
    final iconSize = ResponsiveHelper.getValue(
      context: context,
      mobile: 18.0,
      tablet: 20.0,
      desktop: 22.0,
    );

    // Green "Tambah" button (default)
    if (canAddMore) {
      return Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: AppTheme.successColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          size: iconSize,
          color: Colors.white,
        ),
      );
    }

    // Amber "Max" button (when quantity equals stock)
    if (!isOutOfStock && widget.quantity >= widget.product.stock) {
      return Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: AppTheme.warningColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.check_circle,
          size: iconSize,
          color: Colors.white,
        ),
      );
    }

    // Ghosted "Habis" button
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Icon(
        Icons.block,
        size: iconSize,
        color: Colors.grey.shade600,
      ),
    );
  }
}
