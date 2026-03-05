import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/pos_controller.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../../inventory/domain/entities/product.dart';
import '../widgets/product_grid_item.dart';
import '../widgets/checkout_dialog.dart';
import '../widgets/cart_modal.dart';
import '../widgets/hold_order_dialog.dart';
import 'held_orders_screen.dart';
import '../../../../core/theme.dart';
import '../../../shared/widgets/empty_state_display.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/presentation/main_navigation.dart';

/// Point of Sale screen
class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => POSScreenState();
}

class POSScreenState extends State<POSScreen> {
  final GlobalKey<_CartFloatingButtonState> _cartIconKey = GlobalKey();
  final List<OverlayEntry> _overlayEntries = [];

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<POSController>().loadProducts();
      context.read<CategoryController>().loadCategories();
    });
  }

  @override
  void dispose() {
    // Remove any remaining overlay entries
    for (final entry in _overlayEntries) {
      entry.remove();
    }
    super.dispose();
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
        title: const Text('Checkout Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause_circle_outline),
            onPressed: () => _openHeldOrders(context),
            tooltip: 'Pesanan Tertahan',
          ),
        ],
      ),
      floatingActionButton: Consumer<POSController>(
        builder: (context, controller, _) {
          return _CartFloatingButton(
            itemCount: controller.cartItemCount,
            total: controller.cartTotal,
            onTap: () => _openCartModal(context, controller),
            key: _cartIconKey,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Consumer2<POSController, CategoryController>(
        builder: (context, posController, categoryController, _) {
          // Show loading indicator
          if (posController.isLoading && posController.products.isEmpty) {
            return const LoadingIndicator(message: 'Memuat produk...');
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

          // Show product grid
          return Column(
            children: [
              // Search bar
              _buildSearchBar(posController),

              // Category chips
              _buildCategoryChips(categoryController, posController),

              // Product grid or empty state for no results
              Expanded(
                child: filteredProducts.isEmpty
                    ? _buildNoResults(posController)
                    : RefreshIndicator(
                        onRefresh: () => posController.loadProducts(),
                        color: AppTheme.primaryColor,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.78,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final cartItem = posController.getCartItem(product);

                            return ProductGridItem(
                              product: product,
                              quantity: cartItem?.quantity ?? 0,
                              onTap: () => _handleAddToCart(context, product),
                              onAddAnimation: (position) => _showFlyingPlusOne(position),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(POSController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 15,
          ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () => controller.clearSearch(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppTheme.cardBorder, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppTheme.cardBorder, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        onChanged: (value) {
          // Search-as-you-type
          controller.setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildCategoryChips(CategoryController categoryController, POSController posController) {
    final categories = categoryController.categories;
    final selectedCategory = posController.selectedCategory;

    return Container(
      height: 50,
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
              isSelected: isSelected,
              onTap: () => posController.setCategoryFilter(null),
            );
          }

          // Rest are actual categories
          final category = categories[index - 1];
          final isSelected = selectedCategory?.id == category.id;
          return _buildCategoryChip(
            label: category.name,
            isSelected: isSelected,
            onTap: () => posController.setCategoryFilter(category),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : AppTheme.cardBorder,
            width: 0.5,
          ),
        ),
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
        backgroundColor: AppTheme.cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
    );
  }

  Widget _buildNoResults(POSController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.isNotEmpty || controller.selectedCategory != null
                ? 'Tidak ditemukan produk yang cocok'
                : 'Belum ada produk',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (controller.searchQuery.isNotEmpty || controller.selectedCategory != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: () {
                  controller.clearSearch();
                  controller.clearCategoryFilter();
                },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Hapus Filter'),
              ),
            ),
        ],
      ),
    );
  }

  void _handleAddToCart(BuildContext context, Product product) async {
    final controller = context.read<POSController>();
    final success = await controller.addToCart(product);

    if (success) {
      // Trigger cart icon bump animation
      _cartIconKey.currentState?.bumpAnimation();
    } else if (controller.hasError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error!.userMessage),
          backgroundColor: Colors.red,
        ),
      );
      controller.clearError();
    }
  }

  void _openCartModal(BuildContext context, POSController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => CartModal(
        cartItems: controller.cart,
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

    // Show checkout dialog with payment method selection
    final success = await showCheckoutDialog(
      context: context,
      cart: controller.cart,
      onConfirm: ({required paymentMethod, cashReceived, cardLast4Digits}) async {
        return await controller.checkoutWithPayment(
          paymentMethod: paymentMethod,
          cashReceived: cashReceived,
          cardLast4Digits: cardLast4Digits,
        );
      },
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (controller.hasError && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error!.userMessage),
          backgroundColor: Colors.red,
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

  void _openSettings(BuildContext context) {
    // Navigate to settings tab (index 4)
    final mainNavigationState = context.findAncestorStateOfType<MainNavigationState>();
    mainNavigationState?.navigateToSettings();
  }

  void _openHeldOrders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HeldOrdersScreen(),
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
                content: Text('Produk dengan barcode "$barcode" tidak ditemukan'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          // Return a dummy product that won't be added
          return Product(
            id: -1,
            name: '',
            price: 0,
            stock: 0,
          );
        },
      ),
    );

    // If found (not the dummy product), add to cart
    if (product.id != -1 && context.mounted) {
      _handleAddToCart(context, product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ditambahkan ke keranjang'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
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
  State<_FlyingPlusOneAnimation> createState() => _FlyingPlusOneAnimationState();
}

class _FlyingPlusOneAnimationState extends State<_FlyingPlusOneAnimation> {
  @override
  void initState() {
    super.initState();
    // Trigger animation complete after animation finishes
    Future.delayed(const Duration(milliseconds: 800), () {
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
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.successColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.successColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
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
        .fadeIn(duration: 200.ms)
        .then()
        .slideY(begin: 0, end: -100, duration: 600.ms, curve: Curves.easeOut)
        .then()
        .fadeOut(duration: 200.ms),
      ),
    );
  }
}

/// Floating cart button with badge
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
      child: Material(
        elevation: hasItems ? 4 : 2,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: hasItems ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasItems
                    ? AppTheme.primaryColor
                    : AppTheme.cardBorder,
                width: 0.5,
              ),
              boxShadow: hasItems
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 28,
                    color: hasItems ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
                if (widget.itemCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 20),
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
      ),
    );
  }
}
