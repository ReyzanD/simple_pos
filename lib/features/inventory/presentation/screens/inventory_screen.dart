import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/supplier_controller.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
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
import '../../../../core/widgets/animated_empty_state.dart';

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
      context.read<InventoryController>().loadProducts();
      context.read<CategoryController>().loadCategories();
      context.read<SupplierController>().loadSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          // View mode toggle
          Consumer<InventoryController>(
            builder: (context, controller, _) {
              return IconButton(
                icon: Icon(
                  controller.viewMode == ProductViewMode.list
                      ? Icons.grid_view
                      : Icons.view_list,
                ),
                onPressed: controller.isLoading
                    ? null
                    : () => controller.toggleViewMode(),
                tooltip: controller.viewMode == ProductViewMode.list
                    ? 'Tampilan Grid'
                    : 'Tampilan List',
              );
            },
          ),
          Consumer<InventoryController>(
            builder: (context, controller, _) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.isLoading
                    ? null
                    : () => controller.loadProducts(),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppTheme.darkSurface,
                      AppTheme.darkSurface.withValues(alpha: 0.95),
                    ]
                  : [
                      AppTheme.primaryColor,
                      AppTheme.primaryLight,
                    ],
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
                return const AnimatedEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory Kosong',
                  subtitle: 'Tap + untuk menambah produk baru',
                  actionText: 'Tambah Produk',
                  iconColor: AppTheme.textTertiary,
                );
              }

              // Show no search results
              if (inventoryController.hasNoResults) {
                return AnimatedEmptyState(
                  icon: Icons.search_off,
                  title: 'Produk Tidak Ditemukan',
                  subtitle: 'Tidak ada produk dengan nama "${inventoryController.searchQuery}"',
                  actionText: 'Hapus Filter',
                  onAction: () => inventoryController.clearFilters(),
                  iconColor: AppTheme.textTertiary,
                );
              }

              // Show product list
              return Column(
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
                    child: RefreshIndicator(
                      onRefresh: () => inventoryController.loadProducts(),
                      color: AppTheme.primaryColor,
                      child: inventoryController.viewMode == ProductViewMode.list
                          ? ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 8,
                                bottom: 140, // Space for floating nav and FAB
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
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                top: 12,
                                bottom: 140, // Space for floating nav and FAB
                              ),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
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
                  ),
                ],
              );
            },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 105), // Above floating nav
        child: FloatingActionButton(
          onPressed: () => _showAddOptions(context),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add),
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
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              ),
              title: const Text('Tambah Produk Manual'),
              subtitle: const Text('Masukkan produk satu per satu'),
              onTap: () {
                Navigator.pop(context);
                _showAddDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.upload_file, color: AppTheme.secondaryColor),
              ),
              title: const Text('Import dari CSV'),
              subtitle: const Text('Import banyak produk sekaligus'),
              onTap: () {
                Navigator.pop(context);
                _showCsvImportDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, {String? initialBarcode}) {
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
              final success = await context
                  .read<InventoryController>()
                  .addProduct(
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppTheme.getCardColor(context),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successColor.withValues(alpha: 0.2),
                    AppTheme.successColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_shopping_cart,
                color: AppTheme.successColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Tambah Stok',
              style: TextStyle(
                color: AppTheme.getTextPrimaryColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk: ${product.name}',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stok saat ini: ${product.stock}',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.getTextSecondaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah yang akan ditambahkan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.add_rounded),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
