import 'package:flutter/material.dart';
import 'package:simple_pos/features/inventory/domain/entities/product.dart';
import 'package:simple_pos/features/pos/presentation/widgets/product_grid_item.dart';
import 'package:simple_pos/core/utils/responsive_helper.dart';
import 'package:simple_pos/features/pos/presentation/controllers/pos_controller.dart';

/// Product grid widget for displaying products in grid or list view
class ProductGridWidget extends StatelessWidget {
  final List<Product> products;
  final ViewMode viewMode;
  final Function(Product) onTap;
  final Function(Offset) onAddAnimation;
  final Function(Product) getQuantity;

  const ProductGridWidget({
    super.key,
    required this.products,
    required this.viewMode,
    required this.onTap,
    required this.onAddAnimation,
    required this.getQuantity,
  });

  @override
  Widget build(BuildContext context) {
    if (viewMode == ViewMode.list) {
      return _buildListView(context);
    } else {
      return _buildGridView(context);
    }
  }

  Widget _buildListView(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.getCardSpacing(context),
        0,
        ResponsiveHelper.getCardSpacing(context),
        ResponsiveHelper.isVerySmallScreen(context) ? 90 : 100,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: ResponsiveHelper.getCardSpacing(context),
              ),
              child: SizedBox(
                height: 240, // Constrain height in list view to prevent layout exception
                child: ProductGridItem(
                  product: product,
                  quantity: getQuantity(product) ?? 0,
                  onTap: () => onTap(product),
                  onAddAnimation: onAddAnimation,
                  index: index,
                ),
              ),
            );
          },
          childCount: products.length,
          addAutomaticKeepAlives: true,
        ),
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.getCardSpacing(context),
        0,
        ResponsiveHelper.getCardSpacing(context),
        ResponsiveHelper.getBottomPadding(context),
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.getGridColumns(context),
          childAspectRatio: ResponsiveHelper.getGridChildAspectRatio(context),
          crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
          mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];

            return ProductGridItem(
              product: product,
              quantity: getQuantity(product) ?? 0,
              onTap: () => onTap(product),
              onAddAnimation: onAddAnimation,
              index: index,
            );
          },
          childCount: products.length,
          addAutomaticKeepAlives: true,
        ),
      ),
    );
  }
}
