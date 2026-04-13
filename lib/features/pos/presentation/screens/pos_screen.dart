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
import 'scan_mode_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/widgets/success_animation.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/kpi_stats_dashboard.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../../../core/widgets/brutal_widgets.dart';
import '../../../../core/widgets/brutal_inputs.dart';
import '../../../shared/widgets/empty_state_display.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../../../shifts/presentation/screens/shift_open_screen.dart';
import '../../../../core/utils/audio_feedback_helper.dart';
import '../../../../core/utils/responsive_helper.dart';

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
    AudioFeedbackHelper.instance.init();
    WidgetsBinding.instance.addObserver(this);
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveShift();
      // Auto-switch to list view on very small screens
      if (mounted && ResponsiveHelper.isVerySmallScreen(context)) {
        context.read<POSController>().setViewMode(ViewMode.list);
      }
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
      builder: (context) => PopScope(
        // ── Modern replacement for onWillPop ──
        canPop: false, // Prevents back button / swipe from closing the dialog
        onPopInvokedWithResult: (didPop, result) {
          // Optional: you can add extra logic here if needed
          // For now we just block the pop (canPop: false already does this)
          if (!didPop) {
            return;
          }
        },
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
                  MaterialPageRoute(builder: (_) => const ShiftOpenScreen()),
                ).then((result) {
                  if (result == true) {
                    // Shift opened successfully, reload current shift
                    _checkActiveShift();
                  } else {
                    // User cancelled, go back to home
                    if (!mounted) return;
                    Navigator.pop(context);
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
    final controller = context.watch<POSController>();

    // Show scan mode if active
    if (controller.isInScanMode) {
      return const ScanModeScreen();
    }

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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: ResponsiveHelper.isVerySmallScreen(context) ? 80 : 90), // ✅ Updated for new navbar height
        child: Consumer<POSController>(
          builder: (context, controller, _) {
            final itemCount = controller.cartItemCount;
            return BrutalFab(
              label: itemCount > 0 ? 'Cart ($itemCount)' : 'Cart',
              icon: Icons.shopping_cart,
              heroTag: 'pos_cart_fab', // ✅ Unique hero tag
              onPressed: () => _openCartModal(context, controller),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Consumer3<POSController, CategoryController, SalesHistoryController>(
        builder: (context, posController, categoryController, salesController, _) {
          // Show shimmer loading grid
          if (posController.isLoading && posController.products.isEmpty) {
            return GridView.builder(
              padding: EdgeInsets.fromLTRB(
                ResponsiveHelper.getCardSpacing(context),
                0,
                ResponsiveHelper.getCardSpacing(context),
                ResponsiveHelper.isVerySmallScreen(context) ? 80 : 100,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                childAspectRatio: _getChildAspectRatio(context),
                crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
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
                    else if (posController.viewMode == ViewMode.list)
                      // List view for better mobile experience
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          ResponsiveHelper.getCardSpacing(context),
                          0,
                          ResponsiveHelper.getCardSpacing(context),
                          ResponsiveHelper.isVerySmallScreen(context) ? 90 : 100,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = filteredProducts[index];
                              final cartItem = posController.getCartItem(
                                product,
                              );

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: ResponsiveHelper.getCardSpacing(context),
                                ),
                                child: ProductGridItem(
                                  product: product,
                                  quantity: cartItem?.quantity ?? 0,
                                  onTap: () => _handleAddToCart(context, product),
                                  onAddAnimation: (position) =>
                                      _showFlyingPlusOne(position),
                                  index: index,
                                ),
                              );
                            },
                            childCount: filteredProducts.length,
                            addAutomaticKeepAlives: true,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          ResponsiveHelper.getCardSpacing(context),
                          0,
                          ResponsiveHelper.getCardSpacing(context),
                          ResponsiveHelper.isVerySmallScreen(context) ? 90 : 100,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _getCrossAxisCount(context),
                                childAspectRatio: _getChildAspectRatio(context),
                                crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                                mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(NeoBrutalTheme.spaceMD, NeoBrutalTheme.spaceSM, NeoBrutalTheme.spaceMD, NeoBrutalTheme.spaceSM),
      child: BrutalSearchField(
        hint: 'Cari produk...',
        controller: _searchController,
        onChanged: (value) {
          controller.setSearchQuery(value);
        },
        backgroundColor: NeoBrutalTheme.surface,
      ),
    );
  }

  Widget _buildFilterControls(POSController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(NeoBrutalTheme.spaceMD, NeoBrutalTheme.spaceSM, NeoBrutalTheme.spaceMD, NeoBrutalTheme.spaceSM),
      child: Row(
        children: [
          // Stock filter chip
          BrutalActionChip(
            label: 'Stok Tersedia',
            icon: controller.inStockOnly ? Icons.check_circle : Icons.inventory_2_outlined,
            onTap: () => controller.toggleInStockOnly(),
            isSelected: controller.inStockOnly,
            backgroundColor: controller.inStockOnly
                ? NeoBrutalTheme.success
                : NeoBrutalTheme.surface,
          ),
          SizedBox(width: NeoBrutalTheme.spaceSM),
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
      child: BrutalActionChip(
        label: label,
        icon: icon,
        onTap: onTap,
        isSelected: isSelected,
        backgroundColor: isSelected ? color : NeoBrutalTheme.surface,
      ),
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

    if (product.hasVariants) {
      final variantController = context.read<ProductVariantController>();
      await variantController.loadVariants(product.id!);

      if (!mounted) return; // ✅

      if (variantController.hasVariants) {
        final selectedVariant = await VariantSelectorDialog.show(
          context: context,
          product: product,
          variants: variantController.variants,
        );

        if (!mounted) return; // ✅

        if (selectedVariant != null) {
          final success = await controller.addToCartWithVariant(
            product,
            selectedVariant,
          );

          if (!mounted) return; // ✅

          if (success) {
            _cartIconKey.currentState?.bumpAnimation();
          } else if (controller.hasError) {
            _showErrorSnackBar(context, controller.error!.userMessage);
            controller.clearError();
          }
        }
        return;
      }
    }

    final success = await controller.addToCart(product);

    if (!mounted) return; // ✅

    if (success) {
      _cartIconKey.currentState?.bumpAnimation();
    } else if (controller.hasError) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return ResponsiveHelper.getGridColumns(context);
  }

  /// Get responsive child aspect ratio based on screen width
  double _getChildAspectRatio(BuildContext context) {
    return ResponsiveHelper.getGridChildAspectRatio(context);
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
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    final salesController = context.read<SalesHistoryController>();
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
      await Future.delayed(const Duration(milliseconds: 300));
      await salesController.refresh();
      widget.onCheckoutSuccess?.call();
      if (!mounted) return; // ✅ single clean guard after all awaits
      try {
        SuccessAnimationOverlay.show(
          context,
          message: 'Checkout Berhasil!',
        ); // ✅
      } catch (_) {}
      if (controller.lastTransaction != null) {
        if (!mounted) return; // ✅ second guard before the next async call
        try {
          await PrintReceiptDialog.show(
            context: context, // ✅ safe
            transaction: controller.lastTransaction,
            cashReceived: controller.lastCashReceived,
            change: controller.lastChange,
          );
        } catch (_) {}
      }
    } else if (controller.hasError) {
      if (!mounted) return; // ✅ State.mounted guard
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
    final held = await showHoldOrderDialog(context, controller);
    if (!mounted) return; // ✅ clean standalone guard after await
    if (held == true) {
      // ✅ separate condition with curly braces
      Navigator.of(context).pop();
    }
  }

  void _openHeldOrders(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HeldOrdersScreen()));
  }

  void handleBarcodeScanned(String barcode) {
    if (!mounted) {
      return; // ✅ top-level State.mounted guard covers everything below
    }
    final controller = context.read<POSController>();
    final product = controller.products.firstWhere(
      (p) => p.barcode == barcode,
      orElse: () => controller.products.firstWhere(
        (p) => p.id.toString() == barcode,
        orElse: () {
          // ✅ No mounted check needed — guarded at top of method
          // Play error sound for product not found
          AudioFeedbackHelper.instance.playError();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produk dengan barcode "$barcode" tidak ditemukan'),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          return Product(id: -1, name: '', price: 0, stock: 0);
        },
      ),
    );
    // ✅ Remove context.mounted — already guarded at top
    if (product.id != -1) {
      // Play success sound for product found
      AudioFeedbackHelper.instance.playBeep();
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
        return 'A-Z';
      case SortOption.nameDesc:
        return 'Z-A';
      case SortOption.priceAsc:
        return 'Termurah';
      case SortOption.priceDesc:
        return 'Termahal';
      case SortOption.stockLevel:
        return 'Stok';
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        side: BorderSide(
          color: Colors.black,
          width: 3, // ✅ Bold border
        ),
      ),
      color: Colors.white,
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(
            color: Colors.black,
            width: 2, // ✅ Bold border
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getOptionIcon(selectedOption),
              size: 14,
              color: Colors.black,
            ),
            const SizedBox(width: 4),
            Text(
              _getOptionLabel(selectedOption),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.black,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          SortOption.nameAsc,
          'A-Z',
          Icons.sort_by_alpha,
        ),
        _buildMenuItem(
          context,
          SortOption.nameDesc,
          'Z-A',
          Icons.sort_by_alpha,
        ),
        _buildMenuItem(
          context,
          SortOption.priceAsc,
          'Termurah',
          Icons.attach_money,
        ),
        _buildMenuItem(
          context,
          SortOption.priceDesc,
          'Termahal',
          Icons.attach_money,
        ),
        _buildMenuItem(
          context,
          SortOption.stockLevel,
          'Stok',
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: NeoBrutalTheme.primary,
                  width: 2,
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? NeoBrutalTheme.primary
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? NeoBrutalTheme.primary : Colors.black.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isSelected ? NeoBrutalTheme.primary : Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NeoBrutalTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          border: Border.all(
            color: Colors.black,
            width: 2, // ✅ Bold border
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
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
            ? NeoBrutalTheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? NeoBrutalTheme.primary : Colors.black.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        mode == ViewMode.grid ? Icons.grid_view : Icons.view_list,
        size: 16,
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}
