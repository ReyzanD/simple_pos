import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../../sales/presentation/controllers/discount_controller.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive_helper.dart';

/// Modern grid item widget for displaying a product in POS screen
///
/// Material 3 Features:
/// - 24px border radius (matches Design System)
/// - Subtle 0.5px border instead of shadows
/// - Reduced padding for better information density
/// - Larger, semi-bold product name
/// - Ghosted button when out of stock
/// - Staggered entrance animation
class ProductGridItem extends StatefulWidget {
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
      decoration: BoxDecoration(
        // Light grey background when out of stock
        color: isOutOfStock ? const Color(0xFFF3F4F6) : NeoBrutalTheme.surface,
        // Neo-Brutalist: Bold borders and chunky shadows
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: hasQuantity ? NeoBrutalTheme.primary : Colors.black,
          width: 4, // ✅ Bold 4px border
        ),
        // Chunky shadow for brutal aesthetic
        boxShadow: hasQuantity ? NeoBrutalTheme.chunkyShadow : NeoBrutalTheme.softShadow,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 4 : 12,
          vertical: isMobile ? 2 : 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product image with overlay quantity badge
            SizedBox(
              height: isMobile ? 26 : 50,
              child: Stack(
                children: [
                  // Product image or icon
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                    ),
                    child: widget.product.imagePath != null && widget.product.imagePath!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                            child: Image.file(
                              File(widget.product.imagePath!),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            _getProductIcon(),
                            size: isMobile ? 18 : 28,
                            color: AppTheme.primaryColor.withValues(alpha: 0.6),
                          ),
                  ),
                  // Quantity badge overlay
                  if (hasQuantity)
                    Positioned(
                      top: isMobile ? 0 : 2,
                      right: isMobile ? 0 : 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 2 : 4,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          '${widget.quantity}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 7 : 10,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 1 : 6),

            // Product name (truncated on mobile)
            Text(
              widget.product.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isOutOfStock ? AppTheme.textTertiary : AppTheme.textPrimary,
                    fontSize: isMobile ? 10 : 15,
                    letterSpacing: 0.0,
                    height: 1.0,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Price only (hide discount badge on mobile)
            if (hasCompoundDiscount && !isMobile) ...[
              Text(
                CurrencyFormatter.format(widget.product.price),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textTertiary,
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppTheme.textTertiary,
                      height: 1.0,
                    ),
                maxLines: 1,
              ),
            ],
            Text(
              hasCompoundDiscount
                  ? CurrencyFormatter.format(compoundPrice)
                  : CurrencyFormatter.format(widget.product.price),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: hasCompoundDiscount
                        ? AppTheme.successColor
                        : (isOutOfStock ? AppTheme.textTertiary : AppTheme.primaryColor),
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 9 : 13,
                    height: 1.0,
                  ),
              maxLines: 1,
            ),

            SizedBox(height: isMobile ? 1 : 6),

            // Action button only (hide stock status on mobile)
            if (!isMobile)
              _buildStockStatus(context, isOutOfStock, isMobile),

            SizedBox(height: isMobile ? 0 : 2),

            // Action button
            _buildActionButton(canAddMore, isOutOfStock, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(BuildContext context, bool isOutOfStock, bool isMobile) {
    Color bgColor;
    Color textColor;
    String text;

    if (isOutOfStock) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      text = 'Habis';
    } else if (widget.product.isLowStock) {
      bgColor = AppTheme.warningColor.withValues(alpha: 0.1);
      textColor = AppTheme.warningColor;
      text = isMobile ? '${widget.product.stock}' : 'Stok: ${widget.product.stock}';
    } else {
      bgColor = AppTheme.successColor.withValues(alpha: 0.1);
      textColor = AppTheme.successColor;
      text = isMobile ? '${widget.product.stock}' : 'Stok: ${widget.product.stock}';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 3 : 6,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 7 : 10,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.0,
        ),
        maxLines: 1,
      ),
    );
  }

  Widget _buildActionButton(bool canAddMore, bool isOutOfStock, bool isMobile) {
    // Green "Tambah" button (default)
    if (canAddMore) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : 8,
          vertical: isMobile ? 1 : 5,
        ),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isMobile ? 4 : 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMobile)
              Icon(
                Icons.add,
                size: 13,
                color: AppTheme.successColor,
              ),
            if (!isMobile) SizedBox(width: 4),
            Text(
              isMobile ? '+' : 'Tambah',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.successColor,
                height: 1.0,
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
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : 8,
          vertical: isMobile ? 1 : 5,
        ),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isMobile ? 4 : 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMobile)
              Icon(
                Icons.check_circle,
                size: 13,
                color: AppTheme.warningColor,
              ),
            if (!isMobile) SizedBox(width: 4),
            Text(
              isMobile ? 'Max' : 'Max',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.warningColor,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    // Ghosted "Habis" button
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : 8,
        vertical: isMobile ? 1 : 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getErrorContainer(context),
        borderRadius: BorderRadius.circular(isMobile ? 4 : 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMobile)
            Icon(
              Icons.block,
              size: 13,
              color: AppTheme.getErrorOnContainer(context),
            ),
          if (!isMobile) SizedBox(width: 4),
          Text(
            isMobile ? '✕' : 'Habis',
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.getErrorOnContainer(context),
              height: 1.0,
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
