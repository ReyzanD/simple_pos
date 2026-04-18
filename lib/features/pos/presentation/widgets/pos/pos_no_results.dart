import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/widgets/modern_button.dart';
import '../../controllers/pos_controller.dart';

/// POS No Results - Empty state when no products match filters
class POSNoResults extends StatelessWidget {
  final POSController controller;
  final VoidCallback onClearFilters;

  const POSNoResults({
    super.key,
    required this.controller,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppGradients.primarySubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            controller.searchQuery.isNotEmpty ||
                    controller.selectedCategory != null
                ? 'Tidak ditemukan produk yang cocok'
                : 'Belum ada produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
          if (controller.searchQuery.isNotEmpty ||
              controller.selectedCategory != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ModernSecondaryButton(
                text: 'Hapus Filter',
                icon: Icons.clear_rounded,
                onPressed: onClearFilters,
              ),
            ),
        ],
      ),
    );
  }
}
