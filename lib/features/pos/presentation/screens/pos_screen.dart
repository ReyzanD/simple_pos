import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/pos_controller.dart';
import '../../../inventory/domain/entities/product.dart';
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
import '../../../../core/widgets/brutal_widgets.dart';
import '../../../shared/widgets/empty_state_display.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../../../../core/utils/audio_feedback_helper.dart';
import '../../../../core/utils/responsive_helper.dart';

// Import extracted POS widgets
import '../widgets/pos/pos_search_bar.dart';
import '../widgets/pos/pos_filter_controls.dart';
import '../widgets/pos/pos_category_chips.dart';
import '../widgets/pos/pos_no_results.dart';
import '../widgets/pos/cart_floating_button.dart';
import '../widgets/pos/flying_plus_one_animation.dart';
import '../widgets/pos/pos_kpi_dashboard.dart';
import '../widgets/pos/shift_required_dialog.dart';
import '../widgets/pos/product_grid_widget.dart';
import '../widgets/pos/pos_shimmer_loading_grid.dart';

/// Point of Sale screen with modern design
class POSScreen extends ConsumerStatefulWidget {
  final Future<void> Function()? onCheckoutSuccess;

  const POSScreen({super.key, this.onCheckoutSuccess});

  @override
  ConsumerState<POSScreen> createState() => POSScreenState();
}

class POSScreenState extends ConsumerState<POSScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final GlobalKey<CartFloatingButtonState> _cartIconKey = GlobalKey();
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
        ref.read(posControllerProvider).setViewMode(ViewMode.list);
      }
      ref.read(posControllerProvider).loadProducts();
      ref.read(categoryControllerProvider).loadCategories();
      _hasLoadedInitially = true;
      _lastRefreshTime = DateTime.now();
    });
  }

  /// Check for active shift and prompt to open if none exists
  Future<void> _checkActiveShift() async {
    final shiftController = ref.read(shiftControllerProvider);
    await shiftController.loadCurrentShift();

    if (!shiftController.hasActiveShift) {
      if (mounted) {
        _showShiftRequiredDialog();
      }
    }
  }

  /// Show dialog when shift is required
  void _showShiftRequiredDialog() {
    ShiftRequiredDialog.show(context);
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
      ref.read(posControllerProvider).loadProducts();
      _lastRefreshTime = now;
    }
  }

  /// Public method to refresh products - can be called from MainNavigation
  void refreshProducts() {
    if (_hasLoadedInitially) {
      ref.read(posControllerProvider).loadProducts();
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
    final controller = ref.watch(posControllerProvider);

    // Show scan mode if active
    if (controller.isInScanMode) {
      return const ScanModeScreen();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(NeoBrutalTheme.spaceXS),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(color: Colors.black, width: 2),
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
            margin: EdgeInsets.all(NeoBrutalTheme.spaceXS),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(color: Colors.black, width: 2),
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
        padding: EdgeInsets.only(
          bottom: ResponsiveHelper.getFABBottomOffset(context),
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final controller = ref.watch(posControllerProvider);
            final itemCount = controller.cartItemCount;
            return BrutalFab(
              label: itemCount > 0 ? 'Cart ($itemCount)' : 'Cart',
              icon: Icons.shopping_cart,
              heroTag: 'pos_cart_fab',
              onPressed: () => _openCartModal(context, controller),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Consumer(
        builder: (context, ref, _) {
          final posController = ref.watch(posControllerProvider);
          final categoryController = ref.watch(categoryControllerProvider);
          final salesController = ref.watch(salesHistoryControllerProvider);
          // Show shimmer loading grid
          if (posController.isLoading && posController.products.isEmpty) {
            return const POSShimmerLoadingGrid();
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
                          POSKPIDashboard(
                            todayRevenue: salesController.todayRevenue,
                            todayTransactions:
                                salesController.todayTransactionCount,
                            itemsSold: salesController.todayItemsSold,
                            isLoading:
                                !posController.hasProducts ||
                                salesController.isLoading,
                          ),
                          // Search bar
                          POSSearchBar(
                            controller: posController,
                            searchController: _searchController,
                          ),
                          // Filter controls row
                          POSFilterControls(controller: posController),
                          // Category chips
                          POSCategoryChips(
                            categoryController: categoryController,
                            posController: posController,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    // Product grid or empty state for no results
                    if (filteredProducts.isEmpty)
                      SliverFillRemaining(child: _buildNoResults(posController))
                    else
                      ProductGridWidget(
                        products: filteredProducts,
                        viewMode: posController.viewMode,
                        onTap: (product) => _handleAddToCart(context, product),
                        onAddAnimation: (position) =>
                            _showFlyingPlusOne(position),
                        getQuantity: (product) =>
                            posController.getCartItem(product)?.quantity,
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

  Widget _buildNoResults(POSController controller) {
    return POSNoResults(
      controller: controller,
      onClearFilters: () {
        controller.clearSearch();
        controller.clearCategoryFilter();
        _searchController.clear();
      },
    );
  }

  void _handleAddToCart(BuildContext context, Product product) async {
    final controller = ref.read(posControllerProvider);

    // Check if product has valid ID
    if (product.id == null) {
      _showErrorSnackBar(context, 'Produk tidak valid - ID hilang');
      return;
    }

    if (product.hasVariants) {
      final variantController = ref.read(productVariantControllerProvider);
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

  void _showFlyingPlusOne(Offset position) {
    // Get the screen position
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => FlyingPlusOneAnimation(
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
    // Save ScaffoldMessenger reference before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
    final salesController = ref.read(salesHistoryControllerProvider);
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
      scaffoldMessenger.showSnackBar(
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
    final controller = ref.read(posControllerProvider);
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
