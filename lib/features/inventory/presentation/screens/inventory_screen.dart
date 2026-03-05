import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/supplier_controller.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/edit_product_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/inventory_search_bar.dart';
import '../widgets/product_list_item.dart';
import '../../../shared/widgets/empty_state_display.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/presentation/main_navigation.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
            mainNavState?.openDrawer();
          },
        ),
        title: const Text('Manage Inventory'),
        actions: [
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
      ),
      body: Consumer3<InventoryController, CategoryController, SupplierController>(
        builder: (context, inventoryController, categoryController, supplierController, _) {
          // Show loading indicator
          if (inventoryController.isLoading && inventoryController.allProducts.isEmpty) {
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
            return const EmptyStateDisplay(
              message: 'Inventory kosong. Tap + untuk menambah produk.',
              icon: Icons.inventory_2_outlined,
            );
          }

          // Show no search results
          if (inventoryController.hasNoResults) {
            return EmptyStateDisplay(
              message:
                  'Tidak ditemukan produk dengan "${inventoryController.searchQuery}"',
              icon: Icons.search_off,
              action: TextButton(
                onPressed: () => inventoryController.clearFilters(),
                child: const Text('Hapus Filter'),
              ),
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
              ),
              // Product list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: inventoryController.products.length,
                  itemBuilder: (context, index) {
                    final product = inventoryController.products[index];
                    return ProductListItem(
                      product: product,
                      categories: categoryController.categories,
                      suppliers: supplierController.suppliers,
                      onEdit: () => _showEditDialog(context, product),
                      onDelete: () => _showDeleteDialog(context, product),
                      onAddStock: () => _showAddStockDialog(context, product),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: ModernActionButton(
        label: 'Add Product',
        icon: Icons.add,
        onPressed: () => _showAddDialog(context),
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
                    side: BorderSide(color: AppTheme.cardBorder, width: 0.5),
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
              child: const Icon(
                Icons.add_shopping_cart,
                color: AppTheme.successColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Tambah Stok'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produk: ${product.name}',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Stok saat ini: ${product.stock}',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah yang akan ditambahkan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stok ${product.name} bertambah $quantity'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    // Navigate to settings tab (index 4)
    final mainNavigationState = context
        .findAncestorStateOfType<MainNavigationState>();
    mainNavigationState?.navigateToSettings();
  }
}
