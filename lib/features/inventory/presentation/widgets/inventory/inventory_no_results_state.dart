import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/widgets/modern_button.dart';

/// No search results state widget for inventory
class InventoryNoResultsState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClearFilters;

  const InventoryNoResultsState({
    super.key,
    required this.searchQuery,
    required this.onClearFilters,
  });

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
              color: NeoBrutalTheme.blockCoral.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.search_off,
              size: 60,
              color: NeoBrutalTheme.blockCoral,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),
          Text(
            'PRODUK TIDAK DITEMUKAN',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.black,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Tidak ada produk dengan nama "$searchQuery"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),
          ModernButton(
            text: 'Hapus Filter',
            icon: Icons.clear_rounded,
            onPressed: onClearFilters,
          ),
        ],
      ),
    );
  }
}
