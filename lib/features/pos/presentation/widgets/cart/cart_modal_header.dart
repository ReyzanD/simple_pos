import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/features/pos/domain/entities/cart_item.dart' as domain;

/// Cart Modal Header - Dramatic header with cart icon and title
class CartModalHeader extends StatelessWidget {
  final List<domain.CartItem> cartItems;

  const CartModalHeader({
    super.key,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeoBrutalTheme.blockBlue,
            NeoBrutalTheme.blockBlue.withValues(alpha: 0.85),
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
                    color: Colors.white,
                    letterSpacing: 3,
                    fontSize: 22,
                  ),
                ),
                if (cartItems.isNotEmpty)
                  Text(
                    '${cartItems.length} PRODUK',
                    style: NeoBrutalTheme.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.8),
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
}
