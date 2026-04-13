import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/supplier_controller.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/edit_product_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/inventory_search_bar.dart';
import '../widgets/product_list_item.dart';
import '../widgets/product_grid_item.dart';
import '../widgets/csv_import_dialog.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/brutal_widgets.dart';
import '../../../../core/widgets/modern_button.dart';

/// Inventory management screen
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Auto-switch to list view on very small screens
      if (mounted && ResponsiveHelper.isVerySmallScreen(context)) {
        final controller = context.read<InventoryController>();
        if (controller.viewMode != ProductViewMode.list) {
          controller.toggleViewMode();
        }
      }
      context.read<InventoryController>().loadProducts();
      context.read<CategoryController>().loadCategories();
      context.read<SupplierController>().loadSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            final mainNavState = context
                .findAncestorStateOfType<MainNavigationState>();
            mainNavState?.openDrawer();
          },
        ),
        title: const Text('Manage Inventory'),
        actions: [
          // View mode toggle with brutal styling
          Consumer<InventoryController>(
            builder: (context, controller, _) {
              return Padding(
                padding: EdgeInsets.only(right: NeoBrutalTheme.spaceXS),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                    border: Border.all(
                      color: Colors.black,
                      width: 3, // ✅ Bold 3px border
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      controller.viewMode == ProductViewMode.list
                          ? Icons.grid_view
                          : Icons.view_list,
                      color: NeoBrutalTheme.primary,
                      size: 22,
                    ),
                    tooltip: controller.viewMode == ProductViewMode.list
                        ? 'Tampilan Grid'
                        : 'Tampilan List',
                    onPressed: controller.isLoading
                        ? null
                        : () => controller.toggleViewMode(),
                  ),
                ),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: NeoBrutalTheme.blockYellow, // ✅ Bold yellow background
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 6, // ✅ Extra thick bottom border
              ),
            ),
          ),
        ),
      ),
      body: Consumer3<InventoryController, CategoryController, SupplierController>(
        builder:
            (
              context,
              inventoryController,
              categoryController,
              supplierController,
              _,
            ) {
              // Show loading indicator
              if (inventoryController.isLoading &&
                  inventoryController.allProducts.isEmpty) {
                return const LoadingIndicator(message: 'Memuat produk...');
              }

              // Show error
              if (inventoryController.hasError) {
                return ErrorDisplay.fromException(
                  inventoryController.error!,
                  onRetry: () => inventoryController.loadProducts(),
                );
              }

              // Show empty state
              if (inventoryController.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: NeoBrutalTheme.blockYellow,
                          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
                          border: Border.all(
                            color: Colors.black,
                            width: 4, // ✅ Bold border
                          ),
                          boxShadow: NeoBrutalTheme.chunkyShadow,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: NeoBrutalTheme.spaceLG),
                      Text(
                        'INVENTORY KOSONG',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: NeoBrutalTheme.spaceSM),
                      Text(
                        'Tap + untuk menambah produk baru',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show no search results
              if (inventoryController.hasNoResults) {
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
                          border: Border.all(
                            color: Colors.black,
                            width: 4, // ✅ Bold border
                          ),
                          boxShadow: NeoBrutalTheme.chunkyShadow,
                        ),
                        child: Icon(
                          Icons.search_off,
                          size: 60,
                          color: NeoBrutalTheme.blockCoral,
                        ),
                      ),
                      const SizedBox(height: NeoBrutalTheme.spaceLG),
                      Text(
                        'PRODUK TIDAK DITEMUKAN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: NeoBrutalTheme.spaceSM),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Tidak ada produk dengan nama "${inventoryController.searchQuery}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: NeoBrutalTheme.spaceLG),
                      ModernButton(
                        text: 'Hapus Filter',
                        icon: Icons.clear_rounded,
                        onPressed: () => inventoryController.clearFilters(),
                      ),
                    ],
                  ),
                );
              }

              // Show product list with pull-to-refresh
              return RefreshIndicator(
                onRefresh: () => inventoryController.loadProducts(),
                color: NeoBrutalTheme.primary, // ✅ Brutal primary color
                backgroundColor: NeoBrutalTheme.blockYellow.withValues(alpha: 0.3),
                displacement: 80,
                strokeWidth: 4, // ✅ Thicker indicator
                child: Column(
                  children: [
                    // Search bar with filters
                    InventorySearchBar(
                      searchQuery: inventoryController.searchQuery,
                      onChanged: inventoryController.searchProducts,
                      onClear: inventoryController.clearSearch,
                      categories: categoryController.categories,
                      suppliers: supplierController.suppliers,
                      selectedCategoryId: inventoryController.filterCategoryId,
                      selectedSupplierId: inventoryController.filterSupplierId,
                      onCategoryChanged: inventoryController.filterByCategory,
                      onSupplierChanged: inventoryController.filterBySupplier,
                      onClearFilters: inventoryController.clearFilters,
                      inStockOnly: inventoryController.inStockOnly,
                      onToggleInStockOnly: inventoryController.toggleInStockOnly,
                      sortOption: inventoryController.sortOption,
                      onSortChanged: inventoryController.setSortOption,
                    ),
                    // Product list/grid
                    Expanded(
                      child: inventoryController.viewMode == ProductViewMode.list
                          ? ListView.builder(
                              padding: EdgeInsets.only(
                                left: ResponsiveHelper.getCardSpacing(context) / 1.5,
                                right: ResponsiveHelper.getCardSpacing(context) / 1.5,
                                top: ResponsiveHelper.getCardSpacing(context) / 1.5,
                                bottom: ResponsiveHelper.isVerySmallScreen(context) ? 120 : 140, // Space for floating nav and FAB
                              ),
                              itemCount: inventoryController.products.length,
                              itemBuilder: (context, index) {
                                final product = inventoryController.products[index];
                                return ProductListItem(
                                      product: product,
                                      categories: categoryController.categories,
                                      suppliers: supplierController.suppliers,
                                      onEdit: () => _showEditDialog(context, product),
                                      onDelete: () =>
                                          _showDeleteDialog(context, product),
                                      onAddStock: () =>
                                          _showAddStockDialog(context, product),
                                      index: index,
                                    )
                                    .animate(delay: Duration(milliseconds: index * 50))
                                    .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                                    .slideX(
                                      begin: 0.1,
                                      end: 0,
                                      duration: 300.ms,
                                      curve: Curves.easeOut,
                                    );
                              },
                            )
                          : GridView.builder(
                              padding: EdgeInsets.only(
                                left: ResponsiveHelper.getCardSpacing(context),
                                right: ResponsiveHelper.getCardSpacing(context),
                                top: ResponsiveHelper.getCardSpacing(context),
                                bottom: ResponsiveHelper.isVerySmallScreen(context) ? 120 : 140, // Space for floating nav and FAB
                              ),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveHelper.getGridColumns(context),
                                childAspectRatio: ResponsiveHelper.getGridChildAspectRatio(context),
                                crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                                mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                              ),
                              itemCount: inventoryController.products.length,
                              itemBuilder: (context, index) {
                                final product = inventoryController.products[index];
                                return ProductGridItem(
                                      product: product,
                                      categories: categoryController.categories,
                                      suppliers: supplierController.suppliers,
                                      onEdit: () => _showEditDialog(context, product),
                                      onDelete: () =>
                                          _showDeleteDialog(context, product),
                                      onAddStock: () =>
                                          _showAddStockDialog(context, product),
                                    )
                                    .animate(delay: Duration(milliseconds: index * 50))
                                    .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                                    .scale(
                                      begin: const Offset(0.9, 0.9),
                                      end: const Offset(1, 1),
                                      duration: 300.ms,
                                      curve: Curves.easeOut,
                                    );
                              },
                            ),
                  ),
                ],
              ),
            );
            },
          ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: ResponsiveHelper.isVerySmallScreen(context) ? 80 : 90), // ✅ Updated for new navbar height
          child: BrutalFab(
            label: 'Produk',
            icon: Icons.add,
            heroTag: 'inventory_product_fab', // ✅ Unique hero tag
            onPressed: () => _showAddOptions(context),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
  }

  /// Show add options menu (manual add or CSV import)
  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BrutalCard(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
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
            BrutalCard(
              onTap: () {
                Navigator.pop(context);
                _showAddDialog(context);
              },
              padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.primary,
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.edit_note,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambah Produk Manual',
                          style: NeoBrutalTheme.headlineSmall,
                        ),
                        Text(
                          'Masukkan produk satu per satu',
                          style: NeoBrutalTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: NeoBrutalTheme.spaceSM),
            // CSV import option
            BrutalCard(
              onTap: () {
                Navigator.pop(context);
                _showCsvImportDialog(context);
              },
              padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.secondary,
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.upload_file,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: NeoBrutalTheme.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import dari CSV',
                          style: NeoBrutalTheme.headlineSmall,
                        ),
                        Text(
                          'Import banyak produk sekaligus',
                          style: NeoBrutalTheme.bodySmall,
                        ),
                      ],
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

  void _showAddDialog(BuildContext context, {String? initialBarcode}) {
    // Get controller reference BEFORE showing dialog
    final inventoryController = context.read<InventoryController>();
    final categoryController = context.read<CategoryController>();
    final supplierController = context.read<SupplierController>();

    showDialog(
      context: context,
      builder: (dialogContext) => AddProductDialog(
        categories: categoryController.categories,
        suppliers: supplierController.suppliers,
        initialBarcode: initialBarcode,
        onAdd:
            ({
              required name,
              required price,
              required costPrice,
              required stock,
              categoryId,
              supplierId,
              barcode,
              imagePath,
              hasVariants = false,
            }) async {
              // Use the controller reference instead of context.read
              final success = await inventoryController.addProduct(
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
              if (success && dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produk berhasil ditambahkan')),
                );
              }
              return success;
            },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Product product) {
    final categoryController = context.read<CategoryController>();
    final supplierController = context.read<SupplierController>();

    showDialog<bool>(
      context: context,
      builder: (dialogContext) => EditProductDialog(
        product: product,
        categories: categoryController.categories,
        suppliers: supplierController.suppliers,
        onEdit:
            ({
              required name,
              required price,
              required costPrice,
              required stock,
              categoryId,
              supplierId,
              barcode,
            }) async {
              final success = await context
                  .read<InventoryController>()
                  .updateProductFields(
                    productId: product.id!,
                    name: name,
                    price: price,
                    costPrice: costPrice,
                    stock: stock,
                    categoryId: categoryId,
                    supplierId: supplierId,
                    barcode: barcode,
                  );
              return success;
            },
      ),
    ).then((success) {
      if (success == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diupdate')),
        );
      }
    });
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteConfirmationDialog(
        productName: product.name,
        onDelete: () async {
          final success = await context
              .read<InventoryController>()
              .deleteProduct(product.id!);
          if (success && dialogContext.mounted) {
            Navigator.pop(dialogContext);
            // Show SnackBar with Undo button
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Produk berhasil dihapus'),
                  backgroundColor: AppTheme.successColor,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Batal',
                    textColor: Colors.white,
                    onPressed: () async {
                      final controller = context.read<InventoryController>();
                      final undoSuccess = await controller.undoDeleteProduct();
                      if (undoSuccess && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Produk dipulihkan'),
                            backgroundColor: AppTheme.infoColor,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppTheme.getBorderColor(context),
                      width: 0.5,
                    ),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showCsvImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CsvImportDialog(
        onImportConfirmed: (products) async {
          final controller = context.read<InventoryController>();
          final username = 'Admin'; // TODO: Get from auth controller

          try {
            await controller.importProductsFromCsv(
              products: products,
              username: username,
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Berhasil mengimport ${products.length} produk'),
                  backgroundColor: AppTheme.successColor,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              final message = e is AppException ? e.userMessage : 'Gagal mengimpor produk';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: AppTheme.errorColor,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Tutup',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showAddStockDialog(BuildContext context, Product product) {
    final controller = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
            border: Border.all(
              color: Colors.black,
              width: 5, // ✅ Bold border
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brutal header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TAMBAH STOK',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stok saat ini: ${product.stock}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'JUMLAH',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppTheme.successColor,
                        ),
                        hintText: '1',
                        prefixIcon: Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppTheme.successColor,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.getBorderColor(context),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.successColor,
                            width: 3,
                          ),
                        ),
                      ),
                      autofocus: true,
                    ),
                  ],
                ),
              ),
              // Brutal actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Colors.black,
                            width: 3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'BATAL',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.successColor,
                              AppTheme.successColor.withValues(alpha: 0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final quantity = int.tryParse(controller.text);
                              if (quantity == null || quantity <= 0) {
                                return;
                              }

                              final success = await context
                                  .read<InventoryController>()
                                  .addStock(productId: product.id!, quantity: quantity);

                              if (success && dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Stok ${product.name} bertambah $quantity'),
                                      backgroundColor: AppTheme.successColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'TAMBAH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
