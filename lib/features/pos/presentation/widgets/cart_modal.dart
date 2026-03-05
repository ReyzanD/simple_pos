import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../domain/entities/cart_item.dart' as domain;
import '../../../sales/presentation/controllers/discount_controller.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/discount_calculator.dart';

/// Modal bottom sheet for cart management
///
/// Features:
/// - Header with "Keranjang" title and close button
/// - Scrollable item list with quantity controls and remove button
/// - Footer with subtotal, tax, total, hold button, and checkout button
/// - Animations for modal entry and item removal
class CartModal extends StatefulWidget {
  final List<domain.CartItem> cartItems;
  final Function(Product product, int quantity) onUpdateQuantity;
  final Function(Product product) onRemove;
  final VoidCallback onCheckout;
  final VoidCallback onHoldOrder;
  final bool isProcessing;

  const CartModal({
    super.key,
    required this.cartItems,
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
  final List<GlobalKey<_CartModalItemState>> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    // Initialize keys for all items
    _itemKeys.addAll(List.generate(
      widget.cartItems.length,
      (_) => GlobalKey<_CartModalItemState>(),
    ));
  }

  @override
  void didUpdateWidget(CartModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update keys if cart length changes
    if (widget.cartItems.length != oldWidget.cartItems.length) {
      _itemKeys.clear();
      _itemKeys.addAll(List.generate(
        widget.cartItems.length,
        (_) => GlobalKey<_CartModalItemState>(),
      ));
    }
  }

  double get _subtotal {
    // Calculate subtotal with compound discounts
    final categoryController = context.read<CategoryController>();
    final discountController = context.read<DiscountController>();

    return widget.cartItems.fold(0, (sum, item) {
      // Get category discount
      double? categoryDiscount;
      if (item.product.categoryId != null) {
        final category = categoryController.categories
            .where((c) => c.id == item.product.categoryId)
            .firstOrNull;
        if (category != null && category.hasDiscount) {
          categoryDiscount = category.discountPercentage;
        }
      }

      // Get active promotion discount
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

  double get _totalDiscount {
    // Calculate total discount with compound discounts
    final categoryController = context.read<CategoryController>();
    final discountController = context.read<DiscountController>();

    return widget.cartItems.fold(0, (sum, item) {
      // Get category discount
      double? categoryDiscount;
      if (item.product.categoryId != null) {
        final category = categoryController.categories
            .where((c) => c.id == item.product.categoryId)
            .firstOrNull;
        if (category != null && category.hasDiscount) {
          categoryDiscount = category.discountPercentage;
        }
      }

      // Get active promotion discount
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

  double get _tax => _subtotal * 0.11; // 11% tax on discounted subtotal
  double get _total => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Cart items list
          Expanded(
            child: widget.cartItems.isEmpty
                ? _buildEmptyState()
                : _buildCartItems(),
          ),

          // Footer with totals and checkout
          _buildFooter(),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Keranjang',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          // Item count badge
          if (widget.cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.cartItems.length} item${widget.cartItems.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Tutup',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang kosong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.cartItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = widget.cartItems[index];
        final key = index < _itemKeys.length ? _itemKeys[index] : null;
        return CartModalItem(
          key: key,
          item: item,
          onUpdateQuantity: (quantity) => widget.onUpdateQuantity(item.product, quantity),
          onRemove: () => widget.onRemove(item.product),
          index: index,
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: const Border(
          top: BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Totals
            _buildTotalRow('Subtotal', _subtotal),
            const SizedBox(height: 8),
            // Discount row (only if there's a discount)
            if (_totalDiscount > 0) ...[
              _buildTotalRow(
                'Diskon Item',
                -_totalDiscount,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 8),
            ],
            _buildTotalRow('Pajak (11%)', _tax),
            const SizedBox(height: 12),
            _buildTotalRow(
              'Total',
              _total,
              isBold: true,
              fontSize: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),

            // Hold Order & Checkout buttons
            Row(
              children: [
                // Hold Order button
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.cartItems.isEmpty || widget.isProcessing
                        ? null
                        : widget.onHoldOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.cartItems.isEmpty
                          ? Colors.grey.shade300
                          : AppTheme.infoColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pause, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Checkout button
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.cartItems.isEmpty || widget.isProcessing
                        ? null
                        : widget.onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.cartItems.isEmpty
                          ? Colors.grey.shade300
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: widget.isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, size: 20),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Bayar ${CurrencyFormatter.format(_total)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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

  Widget _buildTotalRow(
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
            fontSize: fontSize ?? 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppTheme.textSecondary,
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: fontSize ?? 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Individual cart item widget with quantity controls
class CartModalItem extends StatefulWidget {
  final domain.CartItem item;
  final Function(int quantity) onUpdateQuantity;
  final VoidCallback onRemove;
  final int index;

  const CartModalItem({
    super.key,
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemove,
    required this.index,
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
    // Wait for animation to complete before calling onRemove
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

    final product = widget.item.product;
    final canAddMore = widget.item.canAddMore;
    final isLowStock = product.isLowStock && !canAddMore;
    final isOutOfStock = product.isOutOfStock;

    // Get category discount
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

    // Get active promotion discount
    double? promotionDiscount;
    if (discountController.activePromotions.isNotEmpty) {
      promotionDiscount = discountController.activePromotions.first.discountPercentage;
    }

    // Check if has compound discount
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOutOfStock
              ? AppTheme.errorColor.withValues(alpha: 0.3)
              : AppTheme.cardBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Price display (with compound discount if applicable)
                if (hasCompoundDiscount) ...[
                  // Original price (strikethrough)
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: AppTheme.textTertiary,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Row with compound price and discount badge
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(compoundPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.warningColor.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '-${effectiveDiscount!.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Show total discount for this line item
                  if (totalDiscount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Hemat ${CurrencyFormatter.format(totalDiscount)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                ] else ...[
                  // Regular price
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
                if (isOutOfStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.block,
                          size: 12,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stok habis',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isLowStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 12,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stok menipis (${product.stock})',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            children: [
              // Remove button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _handleRemove,
                tooltip: 'Hapus',
                color: AppTheme.errorColor,
                constraints: const BoxConstraints(minWidth: 40),
                padding: EdgeInsets.zero,
              ),

              // Quantity controls
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.cardBorder,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Minus button
                    InkWell(
                      onTap: () => widget.onUpdateQuantity(widget.item.quantity - 1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.remove,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),

                    // Quantity
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.item.quantity}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),

                    // Plus button
                    InkWell(
                      onTap: canAddMore
                          ? () => widget.onUpdateQuantity(widget.item.quantity + 1)
                          : null,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: canAddMore
                              ? AppTheme.primaryColor
                              : AppTheme.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0, duration: 300.ms);
  }
}
