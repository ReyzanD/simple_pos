import 'package:flutter/material.dart';
import 'dart:io';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/supplier.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/category_icons.dart';

/// Grid item widget for displaying a product in inventory
///
/// Material 3 Features:
/// - 16px border radius with subtle border
/// - Product thumbnail or icon with category color
/// - Stock status indicators
/// - Quick action buttons for edit/add stock/delete
class ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddStock;
  final List<entities.Category> categories;
  final List<Supplier> suppliers;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    this.onAddStock,
    this.categories = const [],
    this.suppliers = const [],
  });

  entities.Category? get _category {
    if (product.categoryId == null) return null;
    try {
      return categories.firstWhere((c) => c.id == product.categoryId);
    } catch (_) {
      return null;
    }
  }

  Supplier? get _supplier {
    if (product.supplierId == null) return null;
    try {
      return suppliers.firstWhere((s) => s.id == product.supplierId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.isOutOfStock;
    final categoryColor = _category != null
        ? CategoryColors.getColor(_category!.name)
        : AppTheme.primaryColor;
    final categoryIcon = _category != null
        ? CategoryIcons.getIcon(_category!.name)
        : Icons.category;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        decoration: BoxDecoration(
          color: isOutOfStock
              ? Colors.grey.shade100
              : AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOutOfStock
                ? Colors.grey.shade300
                : AppTheme.getBorderColor(context),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image/icon section
            Expanded(
              flex: 3,
              child: _buildImageSection(categoryColor, categoryIcon),
            ),

            // Product info section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOutOfStock
                            ? AppTheme.textTertiary
                            : AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Price
                    Text(
                      product.hasDiscount
                          ? CurrencyFormatter.format(product.effectivePrice)
                          : CurrencyFormatter.format(product.price),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: product.hasDiscount
                            ? AppTheme.successColor
                            : (isOutOfStock
                                ? Colors.grey.shade600
                                : AppTheme.primaryColor),
                      ),
                    ),

                    if (product.hasDiscount) ...[
                      Text(
                        CurrencyFormatter.format(product.price),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Stock status
                    _buildStockStatus(),

                    const SizedBox(height: 8),

                    // Action buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Color categoryColor, IconData categoryIcon) {
    final isOutOfStock = product.isOutOfStock;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: product.imagePath != null && product.imagePath!.isNotEmpty
              ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.file(
                    File(product.imagePath!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Icon(
                    categoryIcon,
                    size: 48,
                    color: isOutOfStock
                        ? Colors.grey.shade400
                        : categoryColor.withValues(alpha: 0.7),
                  ),
                ),
        ),

        // Stock badge
        if (isOutOfStock)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Habis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Discount badge
        if (product.hasDiscount)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.warningColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '-${product.discountPercentage!.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Variant badge
        if (product.hasVariants)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 10,
                    color: Colors.white,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Varian',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStockStatus() {
    Color textColor;
    String text;
    IconData icon;

    if (product.isOutOfStock) {
      textColor = AppTheme.errorColor;
      text = 'Stok Habis';
      icon = Icons.block;
    } else if (product.isLowStock) {
      textColor = AppTheme.warningColor;
      text = 'Stok: ${product.stock}';
      icon = Icons.warning_amber;
    } else {
      textColor = AppTheme.successColor;
      text = 'Stok: ${product.stock}';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Add stock button
        if (onAddStock != null && !product.isOutOfStock)
          Expanded(
            child: _buildActionButton(
              icon: Icons.add_shopping_cart_outlined,
              color: AppTheme.successColor,
              onPressed: onAddStock!,
            ),
          ),
        if (onAddStock != null && !product.isOutOfStock)
          const SizedBox(width: 4),
        // Edit button
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit_outlined,
            color: AppTheme.infoColor,
            onPressed: onEdit,
          ),
        ),
        const SizedBox(width: 4),
        // Delete button
        Expanded(
          child: _buildActionButton(
            icon: Icons.delete_outline,
            color: AppTheme.errorColor,
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
