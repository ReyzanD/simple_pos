import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/product_image_picker.dart';
import '../../domain/entities/product.dart';
import '../../../../core/utils/haptic_helper.dart';

/// Enhanced product card with visual stock bar, profit margin, and quick actions
///
/// Features:
/// - Product image thumbnail with fallback
/// - Visual stock level bar (gradient green → red)
/// - Profit margin badge
/// - Quick action buttons
/// - Low stock warning indicator
class EnhancedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onQuickAdd;
  final String? categoryName;
  final double? profitMargin;

  const EnhancedProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onQuickAdd,
    this.categoryName,
    this.profitMargin,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;
    final stockPercentage = product.stock > 0
        ? (product.stock / (product.stock + 50)).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOutOfStock
                ? AppTheme.errorColor.withValues(alpha: 0.3)
                : isLowStock
                    ? AppTheme.warningColor.withValues(alpha: 0.3)
                    : AppTheme.getBorderColor(context),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product image
                ProductImageDisplay(
                  imagePath: product.imagePath,
                  size: 70,
                  onTap: onTap,
                ),
                const SizedBox(width: 12),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Category badge
                      if (categoryName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            categoryName!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Stock bar
                      _StockBar(
                        stock: product.stock,
                        percentage: stockPercentage,
                        isLowStock: isLowStock,
                        isOutOfStock: isOutOfStock,
                      ),

                      const SizedBox(height: 8),

                      // Price row
                      Row(
                        children: [
                          Text(
                            _formatCurrency(product.price),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (profitMargin != null && profitMargin! > 0)
                            _ProfitMarginBadge(margin: profitMargin!),
                          const Spacer(),
                          // Stock count
                          _StockBadge(
                            stock: product.stock,
                            isLowStock: isLowStock,
                            isOutOfStock: isOutOfStock,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quick actions
                _QuickActions(
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onQuickAdd: onQuickAdd,
                  isOutOfStock: isOutOfStock,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'Rp${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}

/// Visual stock level bar with gradient
class _StockBar extends StatelessWidget {
  final int stock;
  final double percentage;
  final bool isLowStock;
  final bool isOutOfStock;

  const _StockBar({
    required this.stock,
    required this.percentage,
    required this.isLowStock,
    required this.isOutOfStock,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = isOutOfStock
        ? AppTheme.errorColor
        : isLowStock
            ? AppTheme.warningColor
            : AppTheme.successColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Stok',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const Spacer(),
            Text(
              isOutOfStock ? 'Habis' : '$stock unit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: isOutOfStock ? 0 : percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      barColor.withValues(alpha: 0.8),
                      barColor.withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Stock badge showing current stock level
class _StockBadge extends StatelessWidget {
  final int stock;
  final bool isLowStock;
  final bool isOutOfStock;

  const _StockBadge({
    required this.stock,
    required this.isLowStock,
    required this.isOutOfStock,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOutOfStock
        ? AppTheme.errorColor
        : isLowStock
            ? AppTheme.warningColor
            : AppTheme.successColor;

    final icon = isOutOfStock
        ? Icons.block
        : isLowStock
            ? Icons.warning_amber_rounded
            : Icons.check_circle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$stock',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Profit margin badge
class _ProfitMarginBadge extends StatelessWidget {
  final double margin;

  const _ProfitMarginBadge({required this.margin});

  @override
  Widget build(BuildContext context) {
    final displayMargin = margin.toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.secondaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            size: 10,
            color: AppTheme.secondaryColor,
          ),
          const SizedBox(width: 2),
          Text(
            '$displayMargin%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick action buttons for edit, delete, and quick add
class _QuickActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onQuickAdd;
  final bool isOutOfStock;

  const _QuickActions({
    required this.onEdit,
    required this.onDelete,
    required this.onQuickAdd,
    required this.isOutOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onQuickAdd != null)
          _ActionButton(
            icon: Icons.add_shopping_cart,
            color: AppTheme.primaryColor,
            onTap: () {
              HapticHelper.lightImpact();
              onQuickAdd!();
            },
          ),
        if (onEdit != null && onQuickAdd != null) const SizedBox(height: 8),
        if (onEdit != null)
          _ActionButton(
            icon: Icons.edit_outlined,
            color: AppTheme.infoColor,
            onTap: () {
              HapticHelper.lightImpact();
              onEdit!();
            },
          ),
        const SizedBox(height: 8),
        if (onDelete != null)
          _ActionButton(
            icon: Icons.delete_outline,
            color: AppTheme.errorColor,
            onTap: () {
              HapticHelper.mediumImpact();
              onDelete!();
            },
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}

/// Compact version for use in grids
class CompactProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  const CompactProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.quantity = 0,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;

    return GestureDetector(
      onTap: () {
        HapticHelper.lightImpact();
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOutOfStock
                ? AppTheme.errorColor.withValues(alpha: 0.3)
                : isLowStock
                    ? AppTheme.warningColor.withValues(alpha: 0.3)
                    : AppTheme.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: ProductImageDisplay(
                      imagePath: product.imagePath,
                      size: 100,
                    ),
                  ),
                  // Stock badge overlay
                  if (isOutOfStock || isLowStock)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _StockBadge(
                        stock: product.stock,
                        isLowStock: isLowStock,
                        isOutOfStock: isOutOfStock,
                      ),
                    ),
                ],
              ),
            ),

            // Details section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(product.price),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  // Stock bar
                  const SizedBox(height: 8),
                  _StockBar(
                    stock: product.stock,
                    percentage: (product.stock / (product.stock + 20)).clamp(0.0, 1.0),
                    isLowStock: isLowStock,
                    isOutOfStock: isOutOfStock,
                  ),

                  // Quantity controls
                  if (quantity > 0 || onAdd != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (quantity > 0 && onRemove != null)
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: () {
                              HapticHelper.lightImpact();
                              onRemove!();
                            },
                          )
                        else
                          const SizedBox(width: 36),

                        Text(
                          quantity.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextPrimaryColor(context),
                          ),
                        ),

                        if (!isOutOfStock && onAdd != null)
                          _QuantityButton(
                            icon: Icons.add,
                            onTap: () {
                              HapticHelper.lightImpact();
                              onAdd!();
                            },
                          )
                        else
                          const SizedBox(width: 36),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'Rp${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
