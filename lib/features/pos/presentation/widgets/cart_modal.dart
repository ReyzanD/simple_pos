import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../domain/entities/cart_item.dart' as domain;
import '../controllers/pos_controller.dart';
import '../../../sales/presentation/controllers/discount_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

import '../../../../core/theme/neo_brutal_theme.dart';

// Import extracted cart components
import 'cart/cart_modal_header.dart';
import 'cart/cart_modal_empty_state.dart';
import 'cart/cart_modal_footer.dart';
import 'cart/cart_modal_item.dart';

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
    return CartModalHeader(cartItems: cartItems);
  }

  /// Brutal empty state
  Widget _buildBrutalEmptyState() {
    return const CartModalEmptyState();
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

    return CartModalFooter(
      cartItems: cartItems,
      subtotal: subtotal,
      totalDiscount: totalDiscount,
      tax: tax,
      total: total,
      isProcessing: widget.isProcessing,
      onCheckout: widget.onCheckout,
      onHoldOrder: widget.onHoldOrder,
    );
  }
}
