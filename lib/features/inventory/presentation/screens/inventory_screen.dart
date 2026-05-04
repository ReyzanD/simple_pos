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
import '../../../../l10n/app_localizations.dart';

// Import extracted inventory widgets
import '../controllers/inventory_controller.dart';
import '../providers/inventory_providers.dart';
import '../widgets/inventory/inventory_app_bar.dart';
import '../widgets/inventory/inventory_empty_state.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/csv_import_dialog.dart';
import '../widgets/stock_adjustment_section.dart';
import '../../domain/entities/stock_adjustment.dart';

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
      backgroundColor: NeoBrutalTheme.getBackgroundColor(context),
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
          label: AppLocalizations.of(context)!.product_tambah_produk,
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
      backgroundColor: NeoBrutalTheme.blockBlue.withValues(alpha: 0.3),
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
              label: AppLocalizations.of(context)!.category_semua,
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
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleSearchBar(BuildContext context, WidgetRef ref) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getContainerPadding(context),
        vertical: ResponsiveHelper.getContainerPadding(context) * 0.75,
      ),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: secondaryTextColor,
            size: ResponsiveHelper.getIconSize(context) + 4,
          ),
          SizedBox(width: ResponsiveHelper.getCardSpacing(context) * 0.5),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.product_search,
                border: InputBorder.none,
                hintStyle: TextStyle(color: secondaryTextColor, fontSize: 16),
              ),
              style: TextStyle(color: textColor, fontSize: 16),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock;
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    final imageBgColor = isDark
        ? const Color(0xFF2A2A3A)
        : const Color(0xFFE8EEFF);
    final outOfStockBg = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFF3F4F6);

    return GestureDetector(
      onTap: () => _showProductDetails(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: isOutOfStock
              ? outOfStockBg
              : NeoBrutalTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(color: borderColor, width: 2.5),
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
                  color: imageBgColor,
                  child:
                      product.imagePath != null && product.imagePath!.isNotEmpty
                      ? Image.network(
                          product.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: imageBgColor,
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
                              color: imageBgColor,
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
                          color: imageBgColor,
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
                        isOutOfStock
                            ? AppLocalizations.of(
                                context,
                              )!.product_out_of_stock_badge
                            : AppLocalizations.of(
                                context,
                              )!.product_stock_low_badge(product.stock),
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
                            color: isOutOfStock
                                ? secondaryTextColor.withValues(alpha: 0.5)
                                : textColor,
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
                            '${AppLocalizations.of(context)!.product_stok}: ${product.stock}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isOutOfStock
                                  ? secondaryTextColor.withValues(alpha: 0.5)
                                  : secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Stock Adjustment Button
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: Text(
                      AppLocalizations.of(context)!.product_adjust_stock,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () =>
                        _openStockAdjustmentDialog(context, ref, product),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  void _showAddProductOptions(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.getCardColor(context),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(NeoBrutalTheme.radiusLarge),
          ),
          border: Border.all(color: borderColor, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: NeoBrutalTheme.spaceMD),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            BrutalSectionHeader(
              title: AppLocalizations.of(context)!.product_tambah_produk,
              icon: Icons.add_circle_outline,
            ),
            SizedBox(height: NeoBrutalTheme.spaceSM),
            _buildBottomSheetOption(
              context: context,
              icon: Icons.edit_note,
              title: AppLocalizations.of(context)!.product_tambah_manual,
              subtitle: AppLocalizations.of(context)!.product_manual_hint,
              color: NeoBrutalTheme.primary,
              onTap: () {
                Navigator.pop(context);
                _showAddProductDialog(context, ref);
              },
            ),
            SizedBox(height: NeoBrutalTheme.spaceSM),
            _buildBottomSheetOption(
              context: context,
              icon: Icons.upload_file,
              title: AppLocalizations.of(context)!.product_import_csv,
              subtitle: AppLocalizations.of(context)!.product_import_hint,
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

  void _openStockAdjustmentDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    // Guard: ensure product has an id before proceeding
    if (product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.product_stock_missing),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final controller = ref.read(inventoryControllerProvider);
    StockAdjustmentType selectedType = StockAdjustmentType.purchase;
    int? adjustmentQuantity;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: AppTheme.successColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${AppLocalizations.of(context)!.product_adjust_stock}: ${product.name}',
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StockAdjustmentSection(
                  selectedType: selectedType,
                  adjustmentQuantity: adjustmentQuantity,
                  onTypeChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                  onQuantityChanged: (value) {
                    setDialogState(() => adjustmentQuantity = value);
                  },
                  onAdd: adjustmentQuantity != null && adjustmentQuantity! > 0
                      ? () async {
                          // product.id is non-null due to guard
                          final success = await controller.adjustStock(
                            productId: product.id!,
                            adjustmentType: selectedType,
                            quantity: adjustmentQuantity!,
                            reason: AppLocalizations.of(
                              context,
                            )!.product_manual_adjustment,
                            username: 'admin',
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, success);
                            if (success) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.product_stock_adjusted,
                                  ),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(context)!.common_cancel),
          ),
        ],
      ),
    ).then((result) {
      if (result == true) {
        controller.loadProducts();
      }
    });
  }

  Widget _buildBottomSheetOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
        decoration: BoxDecoration(
          color: NeoBrutalTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(color: borderColor, width: 3),
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
                border: Border.all(color: borderColor, width: 3),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: NeoBrutalTheme.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: NeoBrutalTheme.headlineSmall.copyWith(
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: NeoBrutalTheme.bodySmall.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
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
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}

class ProductDetailScreen extends ConsumerWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    return Scaffold(
      backgroundColor: NeoBrutalTheme.getBackgroundColor(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(product.name),
        actions: [
          // EDIT BUTTON
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, ref),
            tooltip: AppLocalizations.of(context)!.product_edit_produk,
          ),
        ],
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
                    color: NeoBrutalTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(
                      NeoBrutalTheme.radiusLarge,
                    ),
                    border: Border.all(color: borderColor, width: 3),
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
                          color: NeoBrutalTheme.getBackgroundColor(context),
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                            color: secondaryTextColor,
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
              title: AppLocalizations.of(context)!.product_information,
              icon: Icons.info_outline,
            ),
            SizedBox(height: NeoBrutalTheme.spaceMD),
            _buildInfoRow(
              context,
              AppLocalizations.of(context)!.product_nama,
              product.name,
            ),
            _buildInfoRow(
              context,
              AppLocalizations.of(context)!.product_harga,
              CurrencyFormatter.format(product.price),
            ),
            _buildInfoRow(
              context,
              AppLocalizations.of(context)!.product_harga_pokok,
              CurrencyFormatter.format(product.costPrice),
            ),
            _buildInfoRow(
              context,
              AppLocalizations.of(context)!.product_stok,
              product.stock.toString(),
              valueColor: product.isLowStock
                  ? AppTheme.warningColor
                  : product.isOutOfStock
                  ? AppTheme.errorColor
                  : AppTheme.successColor,
            ),
            if (product.barcode != null)
              _buildInfoRow(
                context,
                AppLocalizations.of(context)!.product_barcode_label,
                product.barcode!,
              ),
            _buildInfoRow(
              context,
              AppLocalizations.of(context)!.product_satuan,
              product.unitOfMeasurement,
            ),
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
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 16),
                        const SizedBox(width: NeoBrutalTheme.spaceXS),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.product_stock_low_badge(product.stock),
                          style: const TextStyle(
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
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.white, size: 16),
                        const SizedBox(width: NeoBrutalTheme.spaceXS),
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.product_out_of_stock_badge,
                          style: const TextStyle(
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
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);
    return Padding(
      padding: EdgeInsets.only(bottom: NeoBrutalTheme.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
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
                color: valueColor ?? textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AddProductDialog(
        productToEdit: product,
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
              try {
                // Create updated product
                final updatedProduct = product.copyWith(
                  name: name,
                  price: price,
                  costPrice: costPrice,
                  stock: stock,
                  categoryId: categoryId,
                  supplierId: supplierId,
                  barcode: barcode,
                  imagePath: imagePath,
                  unitOfMeasurement: unitOfMeasurement,
                );
                // Call the inventory notifier to update
                final success = await ref
                    .read(inventoryNotifierProvider.notifier)
                    .updateProduct(updatedProduct);
                if (success && dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.product_update_success_id,
                      ),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  // Pop the detail screen to go back to list
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          )!.product_update_success_id,
                        ),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                    // Pop the detail screen to go back to list
                    if (context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  }
                }
                return success;
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${AppLocalizations.of(context)!.common_error}: $e',
                      ),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
                return false;
              }
            },
      ),
    );
  }
}

// Widget for section header
class BrutalSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const BrutalSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final textColor = NeoBrutalTheme.getTextColor(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: textColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
