import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import '../../providers.dart';

/// Store Stats Card - Today's sales, transaction count, low stock
class DrawerStoreStats extends ConsumerWidget {
  const DrawerStoreStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryControllerProvider);

    final lowStockCount = inventory.allProducts
        .where((p) => p.isLowStock || p.isOutOfStock)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
            padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
            decoration: BoxDecoration(
              color: NeoBrutalTheme.blockCoral, // ✅ Bold coral background
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium), // ✅ Brutal 8px
              border: Border.all(
                color: Colors.black, // ✅ Bold black border
                width: 4, // ✅ Bold 4px border
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow, // ✅ Chunky brutal shadow
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.storefront,
                        size: 16,
                        color: NeoBrutalTheme.primary,
                      ),
                    ),
                    SizedBox(width: NeoBrutalTheme.spaceXS),
                    Text(
                      'Store Stats',
                      style: NeoBrutalTheme.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: NeoBrutalTheme.spaceSM),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.payments_rounded,
                        label: 'Today\'s Sales',
                        value: 'Rp 0',
                        color: AppTheme.successColor,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.getBorderColor(context),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.receipt_long,
                        label: 'Transactions',
                        value: '0',
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: AppTheme.getBorderColor(context),
                ),
                const SizedBox(height: 8),
                _LowStockAlert(count: lowStockCount),
              ],
            ),
        ),
      );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.getTextSecondaryColor(context),
          ),
        ),
      ],
    );
  }
}

class _LowStockAlert extends StatelessWidget {
  final int count;

  const _LowStockAlert({required this.count});

  @override
  Widget build(BuildContext context) {
    final hasLowStock = count > 0;

    return Row(
      children: [
        Icon(
          hasLowStock ? Icons.warning_amber : Icons.check_circle,
          size: 16,
          color: hasLowStock ? AppTheme.warningColor : AppTheme.successColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hasLowStock
                ? '$count items with low stock'
                : 'All stock levels healthy',
            style: TextStyle(
              fontSize: 12,
              color: hasLowStock
                  ? AppTheme.warningColor
                  : AppTheme.getTextSecondaryColor(context),
              fontWeight: hasLowStock ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
