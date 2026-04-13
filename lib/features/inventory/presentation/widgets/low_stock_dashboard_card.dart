import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
/// Stock status enum
enum StockStatus {
  outOfStock,
  lowStock,
}

/// Card widget displaying a product with stock issues
class LowStockDashboardCard extends StatelessWidget {
  final Product product;
  final StockStatus stockStatus;
  final VoidCallback? onEditPressed;
  final VoidCallback? onQuickAddPressed;

  const LowStockDashboardCard({
    super.key,
    required this.product,
    required this.stockStatus,
    this.onEditPressed,
    this.onQuickAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = stockStatus == StockStatus.outOfStock;
    final statusColor = isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor;

    return Container(
      margin: EdgeInsets.only(bottom: NeoBrutalTheme.spaceSM),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
        border: Border.all(
          color: statusColor, // ✅ Bold colored border
          width: 4, // ✅ Bold 4px border
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow, // ✅ Chunky brutal shadow
      ),
      child: InkWell(
        onTap: onEditPressed,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Status icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: statusColor, // ✅ Solid bold color
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
                      border: Border.all(
                        color: Colors.black, // ✅ Bold black border
                        width: 3, // ✅ Bold 3px border
                      ),
                      boxShadow: NeoBrutalTheme.chunkyShadow,
                    ),
                    child: Icon(
                      isOutOfStock ? Icons.block : Icons.inventory_2_outlined,
                      color: Colors.white, // ✅ White icon for contrast
                      size: 28,
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceMD),

                  // Product info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code_2,
                              size: 14,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.barcode ?? 'No Barcode',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textTertiary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: NeoBrutalTheme.spaceSM,
                      vertical: NeoBrutalTheme.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor, // ✅ Solid bold color
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall), // ✅ Brutal radius
                      border: Border.all(
                        color: Colors.black, // ✅ Bold black border
                        width: 2, // ✅ Bold 2px border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      isOutOfStock ? 'Habis' : 'Rendah',
                      style: NeoBrutalTheme.labelSmall.copyWith(
                        color: Colors.white, // ✅ White text for contrast
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stock level indicator
              _buildStockIndicator(context, statusColor),

              const SizedBox(height: 16),

              // Details row
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.inventory,
                      'Stok Saat Ini',
                      '${product.stock} unit',
                      statusColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.sell_outlined,
                      'Harga Jual',
                      CurrencyFormatter.format(product.price),
                      AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      Icons.shopping_cart_outlined,
                      'Harga Modal',
                      CurrencyFormatter.format(product.costPrice),
                      AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),

              // Restock suggestion
              if (!isOutOfStock && product.stock < 10) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.infoColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Saran: Tambah ${10 - product.stock} unit untuk mencapai stok aman',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.infoColor,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEditPressed,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Produk'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (onQuickAddPressed != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onQuickAddPressed,
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Tambah Stok'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockIndicator(BuildContext context, Color statusColor) {
    final threshold = 10;
    final stockPercent = (product.stock / threshold).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tingkat Stok',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            Text(
              '${(stockPercent * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: stockPercent,
            backgroundColor: AppTheme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
