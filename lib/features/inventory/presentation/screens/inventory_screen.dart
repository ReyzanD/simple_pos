import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../../../../core/widgets/brutal_widgets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../shared/presentation/providers.dart';

// Import extracted inventory widgets
import '../widgets/inventory/inventory_app_bar.dart';
import '../widgets/inventory/inventory_empty_state.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/csv_import_dialog.dart';

/// Inventory management screen using Riverpod
class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(inventoryControllerProvider);
    final products = controller.products;
    final isLoading = controller.isLoading;

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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: ResponsiveHelper.getFABBottomOffset(context),
        ),
        child: BrutalFab(
          label: 'Tambah Produk',
          icon: Icons.add,
          onPressed: () => _showAddProductOptions(context, ref),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildInventoryContent(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
  ) {
    return RefreshIndicator(
      onRefresh: () => ref.read(inventoryControllerProvider).loadProducts(),
      color: NeoBrutalTheme.primary,
      backgroundColor: NeoBrutalTheme.blockYellow.withValues(alpha: 0.3),
      strokeWidth: 4,
      child: Column(
        children: [
          // Simple search bar
          Padding(
            padding: ResponsiveHelper.getScreenPadding(context),
            child: _buildSimpleSearchBar(context, ref),
          ),

          // Products Grid
          Expanded(
            child: Padding(
              padding: ResponsiveHelper.getScreenPadding(context).copyWith(
                top: 0,
                bottom: 0,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.getGridColumns(context),
                  mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                  crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                  mainAxisExtent: ResponsiveHelper.getProductCardHeight(context),
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
        horizontal: ResponsiveHelper.getContainerPadding(context),
        vertical: ResponsiveHelper.getContainerPadding(context) * 0.75,
      ),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.background,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppTheme.textSecondary, size: ResponsiveHelper.getIconSize(context) + 4),
          SizedBox(width: ResponsiveHelper.getCardSpacing(context) * 0.5),
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
                ref.read(inventoryControllerProvider).searchProducts(query);
              },
            ),
          ),
          if (ref.read(inventoryControllerProvider).searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                ref.read(inventoryControllerProvider).clearSearch();
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
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;

    return Container(
      height: ResponsiveHelper.getValue(
        context: context,
        mobile: 80.0,
        tablet: 85.0,
        desktop: 90.0,
      ),
      decoration: BoxDecoration(
        color: isOutOfStock ? const Color(0xFFF3F4F6) : Colors.white,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: Colors.black,
          width: 3,
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showProductDetails(context, product),
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(
              ResponsiveHelper.getValue(
                context: context,
                mobile: 10.0,
                tablet: 12.0,
                desktop: 14.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Compact product image (left side)
                SizedBox(
                  width: ResponsiveHelper.getValue(
                    context: context,
                    mobile: 50.0,
                    tablet: 55.0,
                    desktop: 60.0,
                  ),
                  height: ResponsiveHelper.getValue(
                    context: context,
                    mobile: 50.0,
                    tablet: 55.0,
                    desktop: 60.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: NeoBrutalTheme.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: product.imagePath != null && product.imagePath!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              product.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.inventory_2_outlined,
                                  size: ResponsiveHelper.getIconSize(context),
                                  color: NeoBrutalTheme.primary,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.inventory_2_outlined,
                            size: ResponsiveHelper.getIconSize(context),
                            color: NeoBrutalTheme.primary,
                          ),
                  ),
                ),

                SizedBox(
                  width: ResponsiveHelper.getValue(
                    context: context,
                    mobile: 10.0,
                    tablet: 12.0,
                    desktop: 14.0,
                  ),
                ),

                // Product info (center - more space)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            mobile: 15.0,
                            tablet: 16.0,
                            desktop: 17.0,
                          ),
                          fontWeight: FontWeight.w700,
                          color: isOutOfStock
                              ? AppTheme.textTertiary
                              : Colors.black,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getValue(
                          context: context,
                          mobile: 4.0,
                          tablet: 5.0,
                          desktop: 6.0,
                        ),
                      ),
                      // Price
                      Text(
                        CurrencyFormatter.format(product.price),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            mobile: 17.0,
                            tablet: 18.0,
                            desktop: 19.0,
                          ),
                          fontWeight: FontWeight.w900,
                          color: NeoBrutalTheme.primary,
                          height: 1.1,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: ResponsiveHelper.getValue(
                    context: context,
                    mobile: 8.0,
                    tablet: 10.0,
                    desktop: 12.0,
                  ),
                ),

                // Stock indicator (right side)
                _buildStockIndicator(context, isLowStock, isOutOfStock, product.stock),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStockIndicator(BuildContext context, bool isLowStock, bool isOutOfStock, int stock) {
    final buttonSize = ResponsiveHelper.getValue(
      context: context,
      mobile: 36.0,
      tablet: 40.0,
      desktop: 44.0,
    );
    final iconSize = ResponsiveHelper.getValue(
      context: context,
      mobile: 18.0,
      tablet: 20.0,
      desktop: 22.0,
    );

    Color bgColor;
    IconData iconData;

    if (isOutOfStock) {
      bgColor = AppTheme.errorColor;
      iconData = Icons.block;
    } else if (isLowStock) {
      bgColor = AppTheme.warningColor;
      iconData = Icons.warning;
    } else {
      bgColor = AppTheme.successColor;
      iconData = Icons.check_circle;
    }

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Icon(
        iconData,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }

  void _showAddProductOptions(BuildContext context, WidgetRef ref) {
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
                _showAddProductDialog(context, ref);
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
                _showCsvImportDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final controller = ref.read(inventoryControllerProvider);
    final categoryController = ref.read(categoryControllerProvider);
    final supplierController = ref.read(supplierControllerProvider);

    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onAdd: ({
          required String name,
          required double price,
          required double costPrice,
          required int stock,
          int? categoryId,
          int? supplierId,
          String? barcode,
          String? imagePath,
          bool hasVariants = false,
        }) async {
          return await controller.addProduct(
            name: name,
            price: price,
            costPrice: costPrice,
            stock: stock,
            categoryId: categoryId,
            supplierId: supplierId,
            barcode: barcode,
            imagePath: imagePath,
            hasVariants: hasVariants,
          );
        },
        categories: categoryController.categories,
        suppliers: supplierController.suppliers,
      ),
    ).then((result) {
      if (result == true) {
        controller.loadProducts();
      }
    });
  }

  void _showCsvImportDialog(BuildContext context, WidgetRef ref) {
    final controller = ref.read(inventoryControllerProvider);

    showDialog(
      context: context,
      builder: (context) => CsvImportDialog(
        onImportConfirmed: (products) async {
          return await controller.importProductsFromCsv(
            products: products,
            username: 'admin',
          );
        },
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

  const _ProductDetailScreen({required this.product});

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
