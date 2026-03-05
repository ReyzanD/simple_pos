import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/entities/category.dart' as entities;
import '../../../inventory/domain/entities/supplier.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Modern horizontal list item widget for displaying a product in inventory
///
/// Material 3 Features:
/// - 24px border radius with subtle 0.5px border
/// - Product thumbnail or soft ID circle with Indigo tint
/// - Action buttons at far right (Edit, Add Stock, Delete)
/// - Stock status indicators with chip-style badges
/// - Cost price badge
/// - Barcode display
/// - Category and supplier tags
class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddStock;
  final List<entities.Category> categories;
  final List<Supplier> suppliers;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    this.onAddStock,
    this.categories = const [],
    this.suppliers = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.isOutOfStock;

    return Slidable(
      // Specify the key to avoid issues with rebuilding
      key: ValueKey(product.id),

      // The start action pane is on the left (swipe right)
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          // Edit action (blue)
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: AppTheme.infoColor,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            spacing: 8,
          ),
        ],
      ),

      // The end action pane is on the right (swipe left)
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          // Delete action (red)
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            spacing: 8,
          ),
        ],
      ),

      // The child widget
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isOutOfStock
              ? Colors.grey.shade100
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24), // Material 3: 24px radius
          border: Border.all(
            color: isOutOfStock
                ? Colors.grey.shade300
                : AppTheme.cardBorder,
            width: 0.5, // Subtle 0.5px border
          ),
          boxShadow: const [], // No shadow - Material 3 border-focused
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 56px ID circle with 10% indigo opacity
              _buildIDCircle(),

              const SizedBox(width: 16),

              // Product info
              Expanded(
                child: _buildProductInfo(context),
              ),

              const SizedBox(width: 12),

              // Action buttons (visible when not swiped)
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildIDCircle() {
    // Show product image if available, otherwise show ID circle
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image.file(
            File(product.imagePath!),
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Fallback to ID circle
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1), // 10% indigo opacity
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          product.id?.toString() ?? '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    final isOutOfStock = product.isOutOfStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name with optional discount badge
        Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOutOfStock ? AppTheme.textTertiary : AppTheme.textPrimary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (product.hasVariants) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.infoColor.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 11,
                      color: AppTheme.infoColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Varian',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (product.hasDiscount) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '-${product.discountPercentage!.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningColor,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 6),

        // Price and barcode
        Row(
          children: [
            // Discounted price display or regular price
            if (product.hasDiscount) ...[
              // Original price (strikethrough)
              Text(
                CurrencyFormatter.format(product.price),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: AppTheme.textTertiary,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppTheme.textTertiary,
                ),
              ),
              const SizedBox(width: 6),
              // Effective price (highlighted)
              Text(
                CurrencyFormatter.format(product.effectivePrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ] else ...[
              // Regular price
              Text(
                CurrencyFormatter.format(product.price),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOutOfStock ? Colors.grey.shade600 : AppTheme.primaryColor,
                ),
              ),
            ],
            if (product.barcode != null && product.barcode!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 12,
                      color: AppTheme.infoColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.barcode!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        // Category and supplier tags
        if (_category != null || _supplier != null)
          Wrap(
            spacing: 8,
            children: [
              if (_category != null)
                _buildInfoChip(
                  icon: Icons.category,
                  label: _category!.name,
                  color: AppTheme.primaryColor,
                ),
              if (_supplier != null)
                _buildInfoChip(
                  icon: Icons.local_shipping,
                  label: _supplier!.name,
                  color: AppTheme.secondaryColor,
                ),
            ],
          ),

        if (_category != null || _supplier != null)
          const SizedBox(height: 8),

        // Stock status
        _buildStockStatus(),
      ],
    );
  }

  Widget _buildStockStatus() {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    if (product.isOutOfStock) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      text = 'Stok Habis';
      icon = Icons.block;
    } else if (product.isLowStock) {
      bgColor = AppTheme.warningColor.withValues(alpha: 0.1);
      textColor = AppTheme.warningColor;
      text = 'Stok Rendah: ${product.stock}';
      icon = Icons.warning_amber;
    } else {
      bgColor = AppTheme.successColor.withValues(alpha: 0.1);
      textColor = AppTheme.successColor;
      text = 'Stok: ${product.stock}';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Cost price badge (if available)
        if (product.costPrice > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Modal: ${CurrencyFormatter.format(product.costPrice)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add Stock button (if callback provided)
            if (onAddStock != null) ...[
              _buildActionButton(
                icon: Icons.add_shopping_cart_outlined,
                color: AppTheme.successColor,
                tooltip: 'Add Stock',
                onPressed: onAddStock!,
              ),
              const SizedBox(width: 4),
            ],
            _buildActionButton(
              icon: Icons.edit_outlined,
              color: AppTheme.infoColor,
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            const SizedBox(width: 4),
            _buildActionButton(
              icon: Icons.delete_outline,
              color: AppTheme.errorColor,
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
