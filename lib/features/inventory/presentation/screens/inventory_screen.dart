import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../../../../core/widgets/brutal_widgets.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/inventory_providers.dart';

// Import extracted inventory widgets
import '../widgets/inventory/inventory_app_bar.dart';
import '../widgets/inventory/inventory_empty_state.dart';

/// Inventory management screen using Riverpod
class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(inventoryProvider);
    final isLoading = ref.read(inventoryProvider.notifier).isLoading;

    return Scaffold(
      backgroundColor: NeoBrutalTheme.background,
      appBar: InventoryAppBar(
        onMenuTap: () {
          final mainNavState = context
              .findAncestorStateOfType<MainNavigationState>();
          mainNavState?.openDrawer();
        },
        isLoading: isLoading,
      ),
      body: products.isEmpty && !isLoading
          ? const InventoryEmptyState()
          : _buildInventoryContent(context, ref, products),
      floatingActionButton: ModernButton(
        text: 'Tambah Produk',
        icon: Icons.add,
        onPressed: () => _showAddProductOptions(context),
      ),
    );
  }

  Widget _buildInventoryContent(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(inventoryProvider.notifier).loadProducts(),
      color: NeoBrutalTheme.primary,
      backgroundColor: NeoBrutalTheme.blockYellow.withValues(alpha: 0.3),
      strokeWidth: 4,
      child: Column(
        children: [
          // Simple search bar
          Padding(
            padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
            child: _buildSimpleSearchBar(context, ref),
          ),

          // Products Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 4
                      : 2,
                  mainAxisSpacing: NeoBrutalTheme.spaceMD,
                  crossAxisSpacing: NeoBrutalTheme.spaceMD,
                  mainAxisExtent: 280,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductCard(context, ref, product);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSearchBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceSM,
      ),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.background,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.textSecondary, size: 24),
          SizedBox(width: NeoBrutalTheme.spaceSM),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
              onChanged: (query) {
                ref.read(inventoryProvider.notifier).searchProducts(query);
              },
            ),
          ),
          if (ref.read(inventoryProvider.notifier).searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                ref.read(inventoryProvider.notifier).clearSearch();
              },
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image or placeholder
          if (product.imagePath != null) ...[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                product.imagePath!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: NeoBrutalTheme.blockYellow,
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Container(
              height: 150,
              color: NeoBrutalTheme.blockYellow,
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.black,
              ),
            ),
          ],

          // Product info
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceSM),
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: NeoBrutalTheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stock indicator
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: NeoBrutalTheme.spaceSM,
                          vertical: NeoBrutalTheme.spaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: product.isLowStock
                              ? AppTheme.warningColor
                              : product.isOutOfStock
                              ? AppTheme.errorColor
                              : AppTheme.successColor,
                          borderRadius: BorderRadius.circular(
                            NeoBrutalTheme.radiusSmall,
                          ),
                        ),
                        child: Text(
                          '${product.stock} stok',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      // View details button
                      ModernButton(
                        text: 'Detail',
                        icon: Icons.visibility,
                        onPressed: () => _showProductDetails(context, product),
                        isFullWidth: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  void _showAddProductOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(NeoBrutalTheme.radiusLarge),
          ),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: NeoBrutalTheme.spaceMD),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Section header
            BrutalSectionHeader(
              title: 'Tambah Produk',
              icon: Icons.add_circle_outline,
            ),
            SizedBox(height: NeoBrutalTheme.spaceSM),
            // Manual add option
            _buildBottomSheetOption(
              icon: Icons.edit_note,
              title: 'Tambah Produk Manual',
              subtitle: 'Masukkan produk satu per satu',
              color: NeoBrutalTheme.primary,
              onTap: () {
                Navigator.pop(context);
                // TODO: Show add product dialog when implemented
              },
            ),
            SizedBox(height: NeoBrutalTheme.spaceSM),
            // CSV import option
            _buildBottomSheetOption(
              icon: Icons.upload_file,
              title: 'Import dari CSV',
              subtitle: 'Import banyak produk sekaligus',
              color: NeoBrutalTheme.secondary,
              onTap: () {
                Navigator.pop(context);
                // TODO: Show CSV import dialog when implemented
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: NeoBrutalTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: NeoBrutalTheme.headlineSmall),
                  Text(subtitle, style: NeoBrutalTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProductDetailScreen(product: product),
      ),
    );
  }
}

/// Product detail screen
class _ProductDetailScreen extends StatelessWidget {
  final Product product;

  const _ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(product.name),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: NeoBrutalTheme.blockYellow,
            border: Border(bottom: BorderSide(color: Colors.black, width: 6)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (product.imagePath != null) ...[
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      NeoBrutalTheme.radiusLarge,
                    ),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: NeoBrutalTheme.chunkyShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      NeoBrutalTheme.radiusLarge,
                    ),
                    child: Image.network(
                      product.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: NeoBrutalTheme.background,
                          child: const Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: NeoBrutalTheme.spaceLG),
            ],

            // Product Info
            BrutalSectionHeader(
              title: 'Informasi Produk',
              icon: Icons.info_outline,
            ),
            SizedBox(height: NeoBrutalTheme.spaceMD),

            _buildInfoRow('Nama', product.name),
            _buildInfoRow('Harga', CurrencyFormatter.format(product.price)),
            _buildInfoRow(
              'Harga Pokok',
              CurrencyFormatter.format(product.costPrice),
            ),
            _buildInfoRow(
              'Stok',
              product.stock.toString(),
              valueColor: product.isLowStock
                  ? AppTheme.warningColor
                  : product.isOutOfStock
                  ? AppTheme.errorColor
                  : AppTheme.successColor,
            ),
            if (product.barcode != null)
              _buildInfoRow('Barcode', product.barcode!),
            SizedBox(height: NeoBrutalTheme.spaceLG),

            // Status Badges
            Row(
              children: [
                if (product.isLowStock) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: NeoBrutalTheme.spaceMD,
                      vertical: NeoBrutalTheme.spaceSM,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor,
                      borderRadius: BorderRadius.circular(
                        NeoBrutalTheme.radiusSmall,
                      ),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 16),
                        SizedBox(width: NeoBrutalTheme.spaceXS),
                        Text(
                          'Stok Rendah',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceSM),
                ],
                if (product.isOutOfStock)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: NeoBrutalTheme.spaceMD,
                      vertical: NeoBrutalTheme.spaceSM,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(
                        NeoBrutalTheme.radiusSmall,
                      ),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.block, color: Colors.white, size: 16),
                        SizedBox(width: NeoBrutalTheme.spaceXS),
                        Text(
                          'Habis',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: NeoBrutalTheme.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
