import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/entities/product_variant.dart';

/// Dialog for selecting a product variant at POS
/// Shows available variants with their prices and stock
class VariantSelectorDialog extends StatelessWidget {
  final Product product;
  final List<ProductVariant> variants;

  const VariantSelectorDialog({
    super.key,
    required this.product,
    required this.variants,
  });

  /// Show dialog and return selected variant, or null if cancelled
  static Future<ProductVariant?> show({
    required BuildContext context,
    required Product product,
    required List<ProductVariant> variants,
  }) {
    return showModalBottomSheet<ProductVariant>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VariantSelectorDialog(
        product: product,
        variants: variants,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableVariants = variants.where((v) => v.isActive).toList();

    if (availableVariants.isEmpty) {
      return _EmptyVariantsSheet(product: product);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (product.imagePath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imagePath!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: AppTheme.getCardColor(context),
                          child: const Icon(Icons.image_not_supported, size: 24),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${availableVariants.length} varian tersedia',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Variant list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              itemCount: availableVariants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final variant = availableVariants[index];
                return _VariantTile(
                  variant: variant,
                  onTap: () => Navigator.of(context).pop(variant),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVariantsSheet extends StatelessWidget {
  final Product product;

  const _EmptyVariantsSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Varian',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${product.name} tidak memiliki varian yang tersedia',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ModernButton(
            text: 'Tutup',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  final ProductVariant variant;
  final VoidCallback onTap;

  const _VariantTile({
    required this.variant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = variant.isOutOfStock;
    final isLowStock = variant.isLowStock;

    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isOutOfStock
              ? AppTheme.getCardColor(context)
              : AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOutOfStock
                ? AppTheme.borderColor
                : AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Variant info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOutOfStock ? AppTheme.textTertiary : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(variant.price),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // Stock indicator
            _StockIndicator(
              stock: variant.stock,
              isOutOfStock: isOutOfStock,
              isLowStock: isLowStock,
            ),

            const SizedBox(width: 12),

            // Selection indicator
            if (!isOutOfStock)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.primaryColor,
              )
            else
              Icon(
                Icons.block,
                size: 20,
                color: AppTheme.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0)}';
  }
}

class _StockIndicator extends StatelessWidget {
  final int stock;
  final bool isOutOfStock;
  final bool isLowStock;

  const _StockIndicator({
    required this.stock,
    required this.isOutOfStock,
    required this.isLowStock,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    if (isOutOfStock) {
      color = AppTheme.errorColor;
      text = 'Habis';
      icon = Icons.block;
    } else if (isLowStock) {
      color = AppTheme.warningColor;
      text = '$stock';
      icon = Icons.warning_amber;
    } else {
      color = AppTheme.successColor;
      text = '$stock';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
