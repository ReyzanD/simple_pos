import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/theme/app_theme.dart';

/// Empty state widget for inventory screen
class InventoryEmptyState extends StatelessWidget {
  const InventoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: NeoBrutalTheme.blockBlue,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.black,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),
          Text(
            'INVENTORY KOSONG',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.black,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          Text(
            'Tap + untuk menambah produk baru',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
