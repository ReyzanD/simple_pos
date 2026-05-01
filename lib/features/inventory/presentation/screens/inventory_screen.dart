import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../../../../core/widgets/brutal_widgets.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../shared/presentation/providers.dart';

// Import extracted inventory widgets
import '../controllers/inventory_controller.dart';
import '../widgets/inventory/inventory_app_bar.dart';
import '../widgets/inventory/inventory_empty_state.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/csv_import_dialog.dart';

/// Inventory management screen using Riverpod
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int? selectedCategoryId; // Changed to nullable int to track category ID

  @override
  void initState() {
    super.initState();
    selectedCategoryId = null; // null means "SEMUA" (all products)
  }

  @override
  Widget build(BuildContext context) {
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
    final controller = ref.watch(inventoryControllerProvider);
    final isGridMode = controller.viewMode == ProductViewMode.grid;

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
          // Horizontal Scrollable Categories
          _buildCategoriesScroll(),
          // Products Grid or List
          Expanded(
            child: Padding(
              padding: ResponsiveHelper.getScreenPadding(
                context,
              ).copyWith(top: 0, bottom: 0),
              child: isGridMode
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.getGridColumns(
                          context,
                        ),
                        mainAxisSpacing: ResponsiveHelper.getCardSpacing(
                          context,
                        ),
                        crossAxisSpacing: ResponsiveHelper.getCardSpacing(
                          context,
                        ),
                        mainAxisExtent: ResponsiveHelper.getProductCardHeight(
                          context,
                        ),
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(context, ref, product);
                      },
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: ResponsiveHelper.getCardSpacing(context),
                          ),
                          child: SizedBox(
                            height: ResponsiveHelper.getProductCardHeight(
                              context,
                            ),
                            child: _buildProductCard(context, ref, product),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesScroll() {
    final categoryController = ref.watch(categoryControllerProvider);
    final categories = categoryController.categories;
    final isSemuaSelected = selectedCategoryId == null;

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getScreenPadding(context).left,
          vertical: 8,
        ),
        child: Row(
          children: [
            // Fixed "SEMUA" button
            ResponsiveCategoryChip(
              label: 'Semua',
              icon: Icons.apps_rounded,
              color: AppTheme.primaryColor,
              isSelected: isSemuaSelected,
              onTap: () {
                setState(() => selectedCategoryId = null);
                // Call your filter method here
                // ref.read(inventoryControllerProvider).setCategoryFilter(null);
              },
            ),
            const SizedBox(width: 8),
            // All category chips
            ...categories.map((category) {
              final isSelected = selectedCategoryId == category.id;
              final categoryIcon = CategoryIcons.getIcon(category.name);
              final categoryColor = CategoryColors.getColor(category.name);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ResponsiveCategoryChip(
                  label: category.name,
                  icon: categoryIcon,
                  color: categoryColor,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => selectedCategoryId = category.id);
                    // Call your filter method here
                    // ref.read(inventoryControllerProvider).setCategoryFilter(category.id);
                  },
                ),
              );
            }).toList(),
          ],
        ),
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
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppTheme.textSecondary,
            size: ResponsiveHelper.getIconSize(context) + 4,
          ),
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

    return GestureDetector(
      onTap: () => _showProductDetails(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: isOutOfStock ? const Color(0xFFF3F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(color: Colors.black, width: 2.5),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image - Takes 60% of card height
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFE8EEFF),
                  child:
                      product.imagePath != null && product.imagePath!.isNotEmpty
                      ? Image.network(
                          product.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE8EEFF),
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: NeoBrutalTheme.primary,
                                size: 32,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: const Color(0xFFE8EEFF),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFFE8EEFF),
                          child: Icon(
                            Icons.image_outlined,
                            color: NeoBrutalTheme.primary,
                            size: 40,
                          ),
                        ),
                ),
              ),
              // Stock Status Badge - Mini bar on bottom of image
              if (isOutOfStock || isLowStock)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  color: isOutOfStock
                      ? AppTheme.errorColor
                      : AppTheme.warningColor,
                  child: Row(
                    children: [
                      Icon(
                        isOutOfStock ? Icons.block : Icons.warning,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOutOfStock ? 'HABIS' : 'STOK RENDAH',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              // Product Info - Takes 40% of card height
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product Name
                      Flexible(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isOutOfStock ? Colors.grey : Colors.black,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Price and Stock at bottom
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.format(product.price),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'Stok: ${product.stock}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isOutOfStock
                                  ? Colors.grey
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStockIndicator(
    BuildContext context,
    bool isLowStock,
    bool isOutOfStock,
    int stock,
  ) {
    // Stock indicator is now integrated into the product card
    return const SizedBox.shrink();
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
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: NeoBrutalTheme.spaceMD),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            BrutalSectionHeader(
              title: 'Tambah Produk',
              icon: Icons.add_circle_outline,
            ),
            SizedBox(height: NeoBrutalTheme.spaceSM),
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

    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onAdd:
            ({
              required String name,
              required double price,
              required double costPrice,
              required int stock,
              int? categoryId,
              int? supplierId,
              String? barcode,
              String? imagePath,
              String? unitOfMeasurement,
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
                unitOfMeasurement: unitOfMeasurement,
                hasVariants: hasVariants,
              );
            },
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
