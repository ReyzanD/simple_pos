import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/pos_controller.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../../inventory/presentation/controllers/product_variant_controller.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../sales/presentation/controllers/sales_history_controller.dart';
import '../../../shifts/presentation/controllers/shift_controller.dart';
import '../widgets/product_grid_item.dart';
import '../widgets/checkout_dialog.dart';
import '../widgets/print_receipt_dialog.dart';
import '../widgets/cart_modal.dart';
import '../widgets/hold_order_dialog.dart';
import '../widgets/variant_selector_dialog.dart';
import 'held_orders_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/success_animation.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/kpi_stats_dashboard.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../../../core/presentation/widgets/barcode_scanner_screen.dart';
import '../../../shared/widgets/empty_state_display.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../../../shifts/presentation/screens/shift_open_screen.dart';

/// Point of Sale screen with modern design
class POSScreen extends StatefulWidget {
  final Future<void> Function()? onCheckoutSuccess;

  const POSScreen({super.key, this.onCheckoutSuccess});

  @override
  State<POSScreen> createState() => POSScreenState();
}

class POSScreenState extends State<POSScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final GlobalKey<_CartFloatingButtonState> _cartIconKey = GlobalKey();
  final List<OverlayEntry> _overlayEntries = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _hasLoadedInitially = false;
  DateTime? _lastRefreshTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveShift();
      context.read<POSController>().loadProducts();
      context.read<CategoryController>().loadCategories();
      _hasLoadedInitially = true;
      _lastRefreshTime = DateTime.now();
    });
  }

  /// Check for active shift and prompt to open if none exists
  Future<void> _checkActiveShift() async {
    final shiftController = context.read<ShiftController>();
    await shiftController.loadCurrentShift();

    if (!shiftController.hasActiveShift) {
      if (mounted) {
        _showShiftRequiredDialog();
      }
    }
  }

  /// Show dialog when shift is required
  void _showShiftRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Shift Belum Dibuka'),
            ],
          ),
          content: const Text(
            'Anda perlu membuka shift kerja sebelum dapat melakukan transaksi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to home
              },
              child: const Text('Kembali'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShiftOpenScreen(),
                  ),
                ).then((result) {
                  if (result == true) {
                    // Shift opened successfully, reload current shift
                    _checkActiveShift();
                  } else {
                    // User cancelled, go back to home
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Buka Shift'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload products when returning to the app
    if (state == AppLifecycleState.resumed && _hasLoadedInitially) {
      _refreshIfNeeded();
    }
  }

  @override
  void didUpdateWidget(POSScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshIfNeeded();
  }

  void _refreshIfNeeded() {
    final now = DateTime.now();
    // Refresh if more than 2 seconds have passed since last refresh
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!).inSeconds >= 2) {
      context.read<POSController>().loadProducts();
      _lastRefreshTime = now;
    }
  }

  /// Public method to refresh products - can be called from MainNavigation
  void refreshProducts() {
    if (_hasLoadedInitially) {
      context.read<POSController>().loadProducts();
      _lastRefreshTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Remove any remaining overlay entries and clear the list
    for (final entry in _overlayEntries) {
      try {
        entry.remove();
      } catch (_) {
        // Entry might already be removed
      }
    }
    _overlayEntries.clear();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              final mainNavState = context
                  .findAncestorStateOfType<MainNavigationState>();
              mainNavState?.openDrawer();
            },
          ),
        ),
        title: const Text('Checkout Cart'),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.pause_circle_outline),
              onPressed: () => _openHeldOrders(context),
              tooltip: 'Pesanan Tertahan',
            ),
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
                  : [AppTheme.primaryColor, AppTheme.primaryLight],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 105), // Above floating nav
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 12),
            // Cart FAB
            Consumer<POSController>(
              builder: (context, controller, _) {
                return _CartFloatingButton(
                  itemCount: controller.cartItemCount,
                  total: controller.cartTotal,
                  onTap: () => _openCartModal(context, controller),
                  key: _cartIconKey,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Consumer3<POSController, CategoryController, SalesHistoryController>(
        builder: (context, posController, categoryController, salesController, _) {
          // Show shimmer loading grid
          if (posController.isLoading && posController.products.isEmpty) {
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                childAspectRatio: _getChildAspectRatio(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const ShimmerProductGridItem(),
            );
          }

          // Show error
          if (posController.hasError) {
            return ErrorDisplay.fromException(
              posController.error!,
              onRetry: () => posController.loadProducts(),
            );
          }

          // Show empty state
          if (!posController.hasProducts) {
            return const EmptyStateDisplay(
              message: 'Belum ada Produk. Tambah produk di Inventory yuk!',
              icon: Icons.shopping_cart_outlined,
            );
          }

          final filteredProducts = posController.filteredProducts;

          // Show product grid with pull-to-refresh
          return RefreshIndicator(
            onRefresh: () async {
              await posController.loadProducts();
              // Also refresh sales data (using the already captured controller)
              await salesController.refresh();
            },
            color: AppTheme.primaryColor,
            displacement: 80,
            strokeWidth: 3,
            child:
                CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Fixed header content
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: kToolbarHeight + 20),
                          // KPI Dashboard
                          _buildKPIDashboard(posController, salesController),
                          // Search bar
                          _buildSearchBar(posController),
                          // Filter controls row
                          _buildFilterControls(posController),
                          // Category chips
                          _buildCategoryChips(
                            categoryController,
                            posController,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    // Product grid or empty state for no results
                    if (filteredProducts.isEmpty)
                      SliverFillRemaining(child: _buildNoResults(posController))
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getCrossAxisCount(context),
                                childAspectRatio: _getChildAspectRatio(context),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = filteredProducts[index];
                              final cartItem = posController.getCartItem(
                                product,
                              );

                              return ProductGridItem(
                                product: product,
                                quantity: cartItem?.quantity ?? 0,
                                onTap: () => _handleAddToCart(context, product),
                                onAddAnimation: (position) =>
                                    _showFlyingPlusOne(position),
                                index: index,
                              );
                            },
                            childCount: filteredProducts.length,
                            addAutomaticKeepAlives: true,
                          ),
                        ),
                      ),
                  ],
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
          );
        },
      ),
    );
  }

  Widget _buildKPIDashboard(
    POSController posController,
    SalesHistoryController salesController,
  ) {
    // Use live values from SalesHistoryController (not cached state)
    final todayRevenue = salesController.todayRevenue;
    final todayTransactions = salesController.todayTransactionCount;
    final itemsSold = salesController.todayItemsSold;

    // Calculate if we should show loading shimmer (only on initial load, not after refresh)
    // Show loading if products aren't loaded OR if sales data isn't loaded yet
    final isLoading = !posController.hasProducts || salesController.isLoading;

    return KPIStatsDashboard(
      todayRevenue: todayRevenue,
      todayTransactions: todayTransactions,
      itemsSold: itemsSold,
      isLoading: isLoading,
      onRevenueTap: () {
        // Navigate to sales report
      },
      onTransactionsTap: () {
        // Navigate to sales history
      },
      onItemsSoldTap: () {
        // Navigate to sales report
      },
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSearchBar(POSController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceVariant : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: controller.searchQuery.isNotEmpty
                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari produk...',
            hintStyle: TextStyle(
              color: AppTheme.getTextSecondaryColor(context),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            suffixIcon: controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      controller.clearSearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            // Search-as-you-type
            controller.setSearchQuery(value);
          },
        ),
      ),
    );
  }

  Widget _buildFilterControls(POSController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Stock filter chip
          FilterChip(
            label: Text(
              'Stok Tersedia',
              style: TextStyle(
                fontSize: 13,
                color: controller.inStockOnly
                    ? AppTheme.successColor
                    : AppTheme.getTextSecondaryColor(context),
              ),
            ),
            selected: controller.inStockOnly,
            onSelected: (_) => controller.toggleInStockOnly(),
            selectedColor: AppTheme.successColor.withValues(alpha: 0.2),
            checkmarkColor: AppTheme.successColor,
            side: BorderSide(
              color: controller.inStockOnly
                  ? AppTheme.successColor
                  : AppTheme.getBorderColor(context),
            ),
            avatar: controller.inStockOnly
                ? const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.successColor,
                  )
                : Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          // Sort dropdown
          _SortDropdown(
            selectedOption: controller.sortOption,
            onOptionChanged: (option) => controller.setSortOption(option),
          ),
          const Spacer(),
          // Grid/List view toggle
          _ViewModeToggle(
            viewMode: controller.viewMode,
            onToggle: () => controller.toggleViewMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(
    CategoryController categoryController,
    POSController posController,
  ) {
    final categories = categoryController.categories;
    final selectedCategory = posController.selectedCategory;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          // First item is "All" category
          if (index == 0) {
            final isSelected = selectedCategory == null;
            return _buildCategoryChip(
              label: 'Semua',
              icon: Icons.apps_rounded,
              color: AppTheme.primaryColor,
              isSelected: isSelected,
              onTap: () => posController.setCategoryFilter(null),
            );
          }

          // Rest are actual categories
          final category = categories[index - 1];
          final isSelected = selectedCategory?.id == category.id;
          // Use dynamic icon from CategoryIcons
          final categoryIcon = CategoryIcons.getIcon(category.name);
          final categoryColor = CategoryColors.getColor(category.name);
          return _buildCategoryChip(
            label: category.name,
            icon: categoryIcon,
            color: categoryColor,
            isSelected: isSelected,
            onTap: () => posController.setCategoryFilter(category),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child:
          AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [color, color.withValues(alpha: 0.8)],
                        )
                      : null,
                  color: isSelected ? null : AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : AppShadows.shadowSm,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: isSelected ? Colors.white : color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideX(begin: 0.1, end: 0, duration: 200.ms),
    );
  }

  Widget _buildNoResults(POSController controller) {
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
                onPressed: () {
                  controller.clearSearch();
                  controller.clearCategoryFilter();
                  _searchController.clear();
                },
              ),
            ),
        ],
      ),
    );
  }

  void _handleAddToCart(BuildContext context, Product product) async {
    final controller = context.read<POSController>();

    // Check if product has variants
    if (product.hasVariants) {
      // Show variant selector
      final variantController = context.read<ProductVariantController>();
      await variantController.loadVariants(product.id!);

      if (variantController.hasVariants) {
        if (mounted) {
          final selectedVariant = await VariantSelectorDialog.show(
            context: context,
            product: product,
            variants: variantController.variants,
          );

          if (selectedVariant != null && mounted) {
            final success = await controller.addToCartWithVariant(product, selectedVariant);

            if (success) {
              _cartIconKey.currentState?.bumpAnimation();
            } else if (controller.hasError) {
              _showErrorSnackBar(context, controller.error!.userMessage);
              controller.clearError();
            }
          }
        }
        return;
      }
    }

    // No variants or variant loading failed - add product directly
    final success = await controller.addToCart(product);

    if (success) {
      // Trigger cart icon bump animation
      _cartIconKey.currentState?.bumpAnimation();
    } else if (controller.hasError && context.mounted) {
      _showErrorSnackBar(context, controller.error!.userMessage);
      controller.clearError();
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openCartModal(BuildContext context, POSController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => CartModal(
        onUpdateQuantity: (product, quantity) {
          controller.updateCartQuantity(product, quantity);
        },
        onRemove: (product) {
          controller.removeFromCart(product);
          // Show undo snackbar
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} dihapus dari keranjang'),
                action: SnackBarAction(
                  label: 'Urungkan',
                  textColor: AppTheme.primaryColor,
                  onPressed: () => controller.undoRemoveFromCart(),
                ),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        onCheckout: () => _handleCheckout(context, controller),
        onHoldOrder: () => _handleHoldOrder(context, controller),
        isProcessing: controller.isCheckingOut,
      ),
    );
  }

  /// Get responsive cross axis count based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  /// Get responsive child aspect ratio based on screen width
  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 0.85;
    if (width > 600) return 0.82;
    return 0.78;
  }

  void _showFlyingPlusOne(Offset position) {
    // Get the screen position
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _FlyingPlusOneAnimation(
        startPosition: position,
        onAnimationComplete: () {
          overlayEntry.remove();
          _overlayEntries.remove(overlayEntry);
        },
      ),
    );

    _overlayEntries.add(overlayEntry);
    overlay.insert(overlayEntry);
  }

  void _handleCheckout(BuildContext context, POSController controller) async {
    // Close the cart modal first
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Get controllers BEFORE showing dialog (while context is still valid)
    final salesController = context.read<SalesHistoryController>();

    // Show checkout dialog with payment method selection
    final success = await showCheckoutDialog(
      context: context,
      cart: controller.cart,
      onConfirm:
          ({required paymentMethod, cashReceived, cardLast4Digits}) async {
            return await controller.checkoutWithPayment(
              paymentMethod: paymentMethod,
              cashReceived: cashReceived,
              cardLast4Digits: cardLast4Digits,
            );
          },
    );

    if (success) {
      // Small delay to ensure database transaction is fully committed
      await Future.delayed(const Duration(milliseconds: 300));

      // Directly refresh SalesHistoryController for immediate KPI update
      // This will trigger Consumer3 to rebuild and update KPI
      await salesController.refresh();

      // Notify parent to refresh other controllers
      widget.onCheckoutSuccess?.call();

      // Show success celebration overlay (handle deactivated context gracefully)
      if (mounted) {
        try {
          SuccessAnimationOverlay.show(context, message: 'Checkout Berhasil!');
        } catch (_) {
          // Widget was deactivated, ignore error
        }
      }

      // Show print receipt dialog
      if (mounted && controller.lastTransaction != null) {
        try {
          await PrintReceiptDialog.show(
            context: context,
            transaction: controller.lastTransaction,
            cashReceived: controller.lastCashReceived,
            change: controller.lastChange,
          );
        } catch (_) {
          // Dialog was dismissed or context was deactivated
        }
      }
    } else if (controller.hasError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error!.userMessage),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      controller.clearError();
    }
  }

  void _handleHoldOrder(BuildContext context, POSController controller) async {
    // Show hold order dialog
    final held = await showHoldOrderDialog(context, controller);

    // If order was held successfully, close the cart modal
    if (held == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _openHeldOrders(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HeldOrdersScreen()));
  }

  void _openBarcodeScanner() {
    final controller = context.read<POSController>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          title: 'Scan Produk',
          instruction: 'Arahkan barcode ke dalam bingkai',
          mode: ScannerMode.preview,
          productLookup: (barcode) {
            final product = controller.products.firstWhere(
              (p) => p.barcode == barcode,
              orElse: () => controller.products.firstWhere(
                (p) => p.id.toString() == barcode,
                orElse: () => Product(id: -1, name: '', price: 0, stock: 0),
              ),
            );
            if (product.id == -1) return null;
            return {
              'name': product.name,
              'price': 'Rp ${product.price.toStringAsFixed(0)}',
              'stock': product.stock.toString(),
            };
          },
          onScanned: (barcode) {
            // Handle the scanned barcode
            handleBarcodeScanned(barcode);
          },
        ),
      ),
    );
  }

  void handleBarcodeScanned(String barcode) {
    final controller = context.read<POSController>();

    // Search for product by barcode
    final product = controller.products.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => controller.products.firstWhere(
        (p) => p.id.toString() == barcode,
        orElse: () {
          // Product not found, show error
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Produk dengan barcode "$barcode" tidak ditemukan',
                ),
                backgroundColor: AppTheme.errorColor,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
          // Return a dummy product that won't be added
          return Product(id: -1, name: '', price: 0, stock: 0);
        },
      ),
    );

    // If found (not the dummy product), add to cart
    if (product.id != -1 && context.mounted) {
      _handleAddToCart(context, product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ditambahkan ke keranjang'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

/// Flying +1 animation widget
class _FlyingPlusOneAnimation extends StatefulWidget {
  final Offset startPosition;
  final VoidCallback onAnimationComplete;

  const _FlyingPlusOneAnimation({
    required this.startPosition,
    required this.onAnimationComplete,
  });

  @override
  State<_FlyingPlusOneAnimation> createState() =>
      _FlyingPlusOneAnimationState();
}

class _FlyingPlusOneAnimationState extends State<_FlyingPlusOneAnimation> {
  @override
  void initState() {
    super.initState();
    // Trigger animation complete after animation finishes (150+100+200=450)
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.startPosition.dx,
      top: widget.startPosition.dy,
      child: Material(
        color: Colors.transparent,
        child:
            Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppGradients.success,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.successShadow(0.4),
                  ),
                  child: const Center(
                    child: Text(
                      '+1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1.2, 1.2),
                  duration: 150.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                  duration: 100.ms,
                  curve: Curves.easeOut,
                )
                .then()
                .fadeOut(duration: 200.ms),
      ),
    );
  }
}

/// Floating cart button with badge and modern design
class _CartFloatingButton extends StatefulWidget {
  final int itemCount;
  final double total;
  final VoidCallback onTap;

  const _CartFloatingButton({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  @override
  State<_CartFloatingButton> createState() => _CartFloatingButtonState();
}

class _CartFloatingButtonState extends State<_CartFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _previousCount = widget.itemCount;
  }

  @override
  void didUpdateWidget(_CartFloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount > _previousCount) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
    _previousCount = widget.itemCount;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void bumpAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.itemCount > 0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: hasItems ? AppGradients.primary : null,
            color: hasItems ? null : AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: hasItems
                  ? Colors.transparent
                  : AppTheme.getBorderColor(context),
              width: 1,
            ),
            boxShadow: hasItems
                ? AppShadows.primaryShadow(0.4)
                : AppShadows.shadowMd,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 28,
                  color: hasItems
                      ? Colors.white
                      : AppTheme.getTextPrimaryColor(context),
                ),
              ),
              if (widget.itemCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppGradients.sunset,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.errorColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(minWidth: 22),
                    child: Text(
                      widget.itemCount > 9 ? '9+' : '${widget.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sort dropdown button for selecting product sort option
class _SortDropdown extends StatelessWidget {
  final SortOption selectedOption;
  final ValueChanged<SortOption> onOptionChanged;

  const _SortDropdown({
    required this.selectedOption,
    required this.onOptionChanged,
  });

  String _getOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Nama A-Z';
      case SortOption.nameDesc:
        return 'Nama Z-A';
      case SortOption.priceAsc:
        return 'Harga Terendah';
      case SortOption.priceDesc:
        return 'Harga Tertinggi';
      case SortOption.stockLevel:
        return 'Stok Terbanyak';
    }
  }

  IconData _getOptionIcon(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
      case SortOption.nameDesc:
        return Icons.sort_by_alpha;
      case SortOption.priceAsc:
      case SortOption.priceDesc:
        return Icons.attach_money;
      case SortOption.stockLevel:
        return Icons.inventory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      initialValue: selectedOption,
      onSelected: onOptionChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.getBorderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getOptionIcon(selectedOption),
              size: 16,
              color: AppTheme.getTextSecondaryColor(context),
            ),
            const SizedBox(width: 6),
            Text(
              _getOptionLabel(selectedOption),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          SortOption.nameAsc,
          'Nama A-Z',
          Icons.sort_by_alpha,
        ),
        _buildMenuItem(
          context,
          SortOption.nameDesc,
          'Nama Z-A',
          Icons.sort_by_alpha,
        ),
        _buildMenuItem(
          context,
          SortOption.priceAsc,
          'Harga Terendah',
          Icons.attach_money,
        ),
        _buildMenuItem(
          context,
          SortOption.priceDesc,
          'Harga Tertinggi',
          Icons.attach_money,
        ),
        _buildMenuItem(
          context,
          SortOption.stockLevel,
          'Stok Terbanyak',
          Icons.inventory,
        ),
      ],
    );
  }

  PopupMenuItem<SortOption> _buildMenuItem(
    BuildContext context,
    SortOption option,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedOption == option;
    return PopupMenuItem<SortOption>(
      value: option,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.getTextSecondaryColor(context),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.getTextPrimaryColor(context),
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(Icons.check, size: 18, color: AppTheme.primaryColor),
        ],
      ),
    );
  }
}

/// Grid/List view toggle button
class _ViewModeToggle extends StatelessWidget {
  final ViewMode viewMode;
  final VoidCallback onToggle;

  const _ViewModeToggle({required this.viewMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.getBorderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ViewModeIcon(
              mode: ViewMode.grid,
              isSelected: viewMode == ViewMode.grid,
            ),
            const SizedBox(width: 4),
            _ViewModeIcon(
              mode: ViewMode.list,
              isSelected: viewMode == ViewMode.list,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual view mode icon
class _ViewModeIcon extends StatelessWidget {
  final ViewMode mode;
  final bool isSelected;

  const _ViewModeIcon({required this.mode, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        mode == ViewMode.grid ? Icons.grid_view : Icons.view_list,
        size: 18,
        color: isSelected
            ? AppTheme.primaryColor
            : AppTheme.getTextSecondaryColor(context),
      ),
    );
  }
}
