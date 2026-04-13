import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../domain/entities/cart_item.dart' as domain;
import '../controllers/pos_controller.dart';
import '../../../sales/presentation/controllers/discount_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/discount_calculator.dart';

/// Brutalist Cart Modal - Bold, Industrial, Unforgettable
///
/// Design Philosophy:
/// - Heavy visual weight with 4-5px black borders
/// - Chunky shadows (6px offset, no blur)
/// - Dramatic header with blockYellow gradient
/// - Bold typography (w700-w900) with letter spacing
/// - Industrial color palette (primary, secondary, blockYellow)
/// - Brutal quantity controls with thick borders
class CartModal extends StatefulWidget {
  final Function(Product product, int quantity) onUpdateQuantity;
  final Function(Product product) onRemove;
  final VoidCallback onCheckout;
  final VoidCallback onHoldOrder;
  final bool isProcessing;

  const CartModal({
    super.key,
    required this.onUpdateQuantity,
    required this.onRemove,
    required this.onCheckout,
    required this.onHoldOrder,
    this.isProcessing = false,
  });

  @override
  State<CartModal> createState() => CartModalState();
}

class CartModalState extends State<CartModal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(CartModal oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  double _subtotal(List<domain.CartItem> cartItems) {
    final categoryController = context.read<CategoryController>();
    final discountController = context.read<DiscountController>();

    return cartItems.fold(0, (sum, item) {
      double? categoryDiscount;
      if (item.product.categoryId != null) {
        final category = categoryController.categories
            .where((c) => c.id == item.product.categoryId)
            .firstOrNull;
        if (category != null && category.hasDiscount) {
          categoryDiscount = category.discountPercentage;
        }
      }

      double? promotionDiscount;
      if (discountController.activePromotions.isNotEmpty) {
        promotionDiscount = discountController.activePromotions.first.discountPercentage;
      }

      return sum + item.getCompoundTotalPrice(
        categoryDiscount: categoryDiscount,
        promotionDiscount: promotionDiscount,
      );
    });
  }

  double _totalDiscount(List<domain.CartItem> cartItems) {
    final categoryController = context.read<CategoryController>();
    final discountController = context.read<DiscountController>();

    return cartItems.fold(0, (sum, item) {
      double? categoryDiscount;
      if (item.product.categoryId != null) {
        final category = categoryController.categories
            .where((c) => c.id == item.product.categoryId)
            .firstOrNull;
        if (category != null && category.hasDiscount) {
          categoryDiscount = category.discountPercentage;
        }
      }

      double? promotionDiscount;
      if (discountController.activePromotions.isNotEmpty) {
        promotionDiscount = discountController.activePromotions.first.discountPercentage;
      }

      final breakdown = item.getCompoundDiscountBreakdown(
        categoryDiscount: categoryDiscount,
        promotionDiscount: promotionDiscount,
      );

      return sum + breakdown.totalDiscount;
    });
  }

  double _tax(double subtotal) {
    final settingsController = context.read<SettingsController>();
    if (!settingsController.taxEnabled) return 0;
    return subtotal * 0.11;
  }

  double _total(double subtotal) => subtotal + _tax(subtotal);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;

    return Consumer<POSController>(
      builder: (context, controller, _) {
        final cartItems = controller.cart;

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: Colors.black,
              width: 5, // ✅ Extra bold border
            ),
            boxShadow: NeoBrutalTheme.chunkyShadow,
          ),
          child: Column(
            children: [
              // Header
              _buildBrutalHeader(cartItems),

              // Cart items list
              Expanded(
                child: cartItems.isEmpty
                    ? _buildBrutalEmptyState()
                    : _buildCartItems(cartItems, controller),
              ),

              // Footer with totals and checkout
              _buildBrutalFooter(cartItems),
            ],
          ),
        ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  /// Dramatic header with brutal styling
  Widget _buildBrutalHeader(List<domain.CartItem> cartItems) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeoBrutalTheme.blockYellow,
            NeoBrutalTheme.blockYellow.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(19), // Account for 5px border
          topRight: Radius.circular(19),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 5, // ✅ Bold bottom border
          ),
        ),
      ),
      child: Row(
        children: [
          // Dramatic cart icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: NeoBrutalTheme.primary,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
              border: Border.all(
                color: Colors.black,
                width: 4,
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 28,
              color: Colors.white,
            ),
          ),
          SizedBox(width: NeoBrutalTheme.spaceMD),

          // Bold title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KERANJANG',
                  style: NeoBrutalTheme.headlineLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 3,
                    fontSize: 22,
                  ),
                ),
                if (cartItems.isNotEmpty)
                  Text(
                    '${cartItems.length} PRODUK',
                    style: NeoBrutalTheme.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),
              ],
            ),
          ),

          // Close button with brutal styling
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Brutal empty state
  Widget _buildBrutalEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: NeoBrutalTheme.blockCoral.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
              border: Border.all(
                color: Colors.black,
                width: 4,
              ),
              boxShadow: NeoBrutalTheme.chunkyShadow,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: NeoBrutalTheme.blockCoral,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),
          Text(
            'KERANJANG KOSONG',
            style: NeoBrutalTheme.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceSM),
          Text(
            'Tambahkan produk untuk memulai',
            style: NeoBrutalTheme.bodyMedium.copyWith(
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Cart items list with brutal styling
  Widget _buildCartItems(List<domain.CartItem> cartItems, POSController controller) {
    return ListView.separated(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => SizedBox(height: NeoBrutalTheme.spaceMD),
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return CartModalItem(
          key: ValueKey(item.product.id),
          item: item,
          controller: controller,
          onUpdateQuantity: (quantity) => widget.onUpdateQuantity(item.product, quantity),
          onRemove: () => widget.onRemove(item.product),
        );
      },
    );
  }

  /// Brutal footer with totals and action buttons
  Widget _buildBrutalFooter(List<domain.CartItem> cartItems) {
    final subtotal = _subtotal(cartItems);
    final totalDiscount = _totalDiscount(cartItems);
    final tax = _tax(subtotal);
    final total = _total(subtotal);

    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            NeoBrutalTheme.background,
            NeoBrutalTheme.background.withValues(alpha: 0.95),
          ],
        ),
        border: Border(
          top: BorderSide(color: Colors.black, width: 5), // ✅ Bold 5px border
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: Offset(0, -6),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Totals section
            Container(
              padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildBrutalTotalRow('Subtotal', subtotal),
                  SizedBox(height: NeoBrutalTheme.spaceSM),

                  // Discount row
                  if (totalDiscount > 0) ...[
                    _buildBrutalTotalRow(
                      'Diskon',
                      -totalDiscount,
                      color: AppTheme.successColor,
                    ),
                    SizedBox(height: NeoBrutalTheme.spaceSM),
                  ],

                  // Tax row
                  if (tax > 0) ...[
                    _buildBrutalTotalRow('Pajak (11%)', tax),
                    SizedBox(height: NeoBrutalTheme.spaceSM),
                  ],

                  // Divider
                  Container(
                    height: 3,
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceSM),

                  // Total - Dramatic
                  _buildBrutalTotalRow(
                    'TOTAL',
                    total,
                    isBold: true,
                    fontSize: 24,
                    color: NeoBrutalTheme.primary,
                  ),
                ],
              ),
            ),
            SizedBox(height: NeoBrutalTheme.spaceLG),

            // Action buttons
            Row(
              children: [
                // Hold Order button
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: cartItems.isEmpty || widget.isProcessing
                          ? Colors.grey.shade300
                          : AppTheme.infoColor,
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                      border: Border.all(
                        color: Colors.black,
                        width: 4,
                      ),
                      boxShadow: cartItems.isEmpty && !widget.isProcessing
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: Offset(6, 6),
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: AppTheme.infoColor.withValues(alpha: 0.5),
                                offset: Offset(3, 3),
                                blurRadius: 8,
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: cartItems.isEmpty || widget.isProcessing
                            ? null
                            : widget.onHoldOrder,
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pause_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                              SizedBox(width: NeoBrutalTheme.spaceSM),
                              Text(
                                'TAHAN',
                                style: NeoBrutalTheme.labelLarge.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: NeoBrutalTheme.spaceMD),

                // Checkout button
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: cartItems.isEmpty || widget.isProcessing
                          ? null
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                NeoBrutalTheme.primary,
                                NeoBrutalTheme.primary.withValues(alpha: 0.8),
                              ],
                            ),
                      color: cartItems.isEmpty || widget.isProcessing
                          ? Colors.grey.shade300
                          : null,
                      borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                      border: Border.all(
                        color: Colors.black,
                        width: 4,
                      ),
                      boxShadow: cartItems.isEmpty && !widget.isProcessing
                          ? []
                          : NeoBrutalTheme.chunkyShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: cartItems.isEmpty || widget.isProcessing
                            ? null
                            : widget.onCheckout,
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
                        child: Center(
                          child: widget.isProcessing
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_rounded,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: NeoBrutalTheme.spaceSM),
                                    Flexible(
                                      child: Text(
                                        'BAYAR ${CurrencyFormatter.format(total)}',
                                        style: NeoBrutalTheme.labelLarge.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Brutal total row with dramatic styling
  Widget _buildBrutalTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double? fontSize,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ?? Colors.black.withValues(alpha: 0.7),
            letterSpacing: isBold ? 2 : 1,
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ?? Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Individual cart item widget with brutal styling
class CartModalItem extends StatefulWidget {
  final domain.CartItem item;
  final POSController controller;
  final Function(int quantity) onUpdateQuantity;
  final VoidCallback onRemove;

  const CartModalItem({
    super.key,
    required this.item,
    required this.controller,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  @override
  State<CartModalItem> createState() => _CartModalItemState();
}

class _CartModalItemState extends State<CartModalItem> {
  bool _isRemoving = false;

  void _handleRemove() {
    setState(() {
      _isRemoving = true;
    });
    Future.delayed(200.ms, () {
      if (mounted) {
        widget.onRemove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRemoving) {
      return const SizedBox.shrink()
          .animate()
          .fadeOut(duration: 200.ms)
          .slideX(begin: 0, end: 1, duration: 200.ms);
    }

    final currentItem = widget.controller.getCartItem(widget.item.product);
    final currentQuantity = currentItem?.quantity ?? widget.item.quantity;

    final product = widget.item.product;
    final canAddMore = currentItem?.canAddMore ?? widget.item.canAddMore;
    final isLowStock = product.isLowStock && !canAddMore;
    final isOutOfStock = product.isOutOfStock;

    // Get discounts
    final categoryController = context.watch<CategoryController>();
    final discountController = context.watch<DiscountController>();

    double? categoryDiscount;
    if (product.categoryId != null) {
      final category = categoryController.categories
          .where((c) => c.id == product.categoryId)
          .firstOrNull;
      if (category != null && category.hasDiscount) {
        categoryDiscount = category.discountPercentage;
      }
    }

    double? promotionDiscount;
    if (discountController.activePromotions.isNotEmpty) {
      promotionDiscount = discountController.activePromotions.first.discountPercentage;
    }

    final hasCompoundDiscount = product.hasAnyDiscount(
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );

    final compoundPrice = hasCompoundDiscount
        ? product.calculateCompoundPrice(
            categoryDiscount: categoryDiscount,
            promotionDiscount: promotionDiscount,
          )
        : product.price;

    final effectiveDiscount = hasCompoundDiscount
        ? DiscountCalculator.calculateEffectiveDiscountPercentage(
            basePrice: product.price,
            productDiscount: product.discountPercentage,
            categoryDiscount: categoryDiscount,
            promotionDiscount: promotionDiscount,
          )
        : null;

    final totalDiscount = hasCompoundDiscount
        ? widget.item.getCompoundDiscountBreakdown(
            categoryDiscount: categoryDiscount,
            promotionDiscount: promotionDiscount,
          ).totalDiscount
        : 0.0;

    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: isOutOfStock
              ? NeoBrutalTheme.error
              : Colors.black,
          width: isOutOfStock ? 5 : 4, // ✅ Bold borders
        ),
        boxShadow: isOutOfStock
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
      ),
      child: Row(
        children: [
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: NeoBrutalTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: NeoBrutalTheme.spaceSM),

                // Price display
                if (hasCompoundDiscount) ...[
                  // Original price (strikethrough)
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: NeoBrutalTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textTertiary,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppTheme.textTertiary,
                    ),
                  ),
                  SizedBox(height: 2),

                  // Compound price with discount badge
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(compoundPrice),
                        style: NeoBrutalTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.successColor,
                        ),
                      ),
                      SizedBox(width: NeoBrutalTheme.spaceSM),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: NeoBrutalTheme.spaceSM,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                          border: Border.all(
                            color: AppTheme.warningColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '-${effectiveDiscount!.toStringAsFixed(0)}%',
                          style: NeoBrutalTheme.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.warningColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Savings info
                  if (totalDiscount > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Hemat ${CurrencyFormatter.format(totalDiscount)}',
                        style: NeoBrutalTheme.bodySmall.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ] else ...[
                  // Regular price
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: NeoBrutalTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: NeoBrutalTheme.primary,
                    ),
                  ),
                ],

                // Stock status
                if (isOutOfStock)
                  Padding(
                    padding: EdgeInsets.only(top: NeoBrutalTheme.spaceSM),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: NeoBrutalTheme.spaceSM,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                        border: Border.all(
                          color: AppTheme.errorColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block_rounded,
                            size: 14,
                            color: AppTheme.errorColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'STOK HABIS',
                            style: NeoBrutalTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.errorColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isLowStock)
                  Padding(
                    padding: EdgeInsets.only(top: NeoBrutalTheme.spaceSM),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: NeoBrutalTheme.spaceSM,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                        border: Border.all(
                          color: AppTheme.warningColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: AppTheme.warningColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'STOK: ${product.stock}',
                            style: NeoBrutalTheme.labelSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Quantity controls with brutal styling
          SizedBox(width: NeoBrutalTheme.spaceMD),

          // Remove button
          GestureDetector(
            onTap: _handleRemove,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.errorColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
            ),
          ),

          SizedBox(width: NeoBrutalTheme.spaceSM),

          // Brutal quantity controls
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Minus button
                GestureDetector(
                  onTap: () => widget.onUpdateQuantity(currentQuantity - 1),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(NeoBrutalTheme.radiusSmall - 1),
                        bottomLeft: Radius.circular(NeoBrutalTheme.radiusSmall - 1),
                      ),
                      border: Border(
                        right: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.remove_rounded,
                        size: 20,
                        color: NeoBrutalTheme.primary,
                      ),
                    ),
                  ),
                ),

                // Quantity
                Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: Text(
                    '$currentQuantity',
                    style: NeoBrutalTheme.displayLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),

                // Plus button
                GestureDetector(
                  onTap: canAddMore
                      ? () => widget.onUpdateQuantity(currentQuantity + 1)
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: canAddMore
                          ? NeoBrutalTheme.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(NeoBrutalTheme.radiusSmall - 1),
                        bottomRight: Radius.circular(NeoBrutalTheme.radiusSmall - 1),
                      ),
                      border: Border(
                        left: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: canAddMore
                            ? NeoBrutalTheme.primary
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0, duration: 300.ms);
  }
}
