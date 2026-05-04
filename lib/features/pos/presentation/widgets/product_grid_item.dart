import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/controllers/category_controller.dart';
import '../../../sales/presentation/controllers/discount_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../shared/presentation/providers.dart';

/// 2-Column Product Card with Image Focus
///
/// Layout:
/// - Top (60%): Image container with pastel placeholder if null
/// - Bottom (40%): White info section with Product Name and Price
/// - Press animation: 4px down/right + shadow removal
/// - Entire card tappable
/// - Supports category + promotion discounts
class ProductGridItem extends ConsumerWidget {
  final Product product;
  final int quantity;
  final VoidCallback onTap;
  final Function(Offset position)? onAddAnimation;
  final int? index;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.quantity,
    required this.onTap,
    this.onAddAnimation,
    this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryController = ref.watch(categoryControllerProvider);
    final discountController = ref.watch(discountControllerProvider);
    return _ProductGridItemContent(
      product: product,
      quantity: quantity,
      onTap: onTap,
      onAddAnimation: onAddAnimation,
      index: index,
      categoryController: categoryController,
      discountController: discountController,
    );
  }
}

class _ProductGridItemContent extends StatefulWidget {
  final Product product;
  final int quantity;
  final VoidCallback onTap;
  final Function(Offset position)? onAddAnimation;
  final int? index;
  final CategoryController categoryController;
  final DiscountController discountController;

  const _ProductGridItemContent({
    required this.product,
    required this.quantity,
    required this.onTap,
    this.onAddAnimation,
    this.index,
    required this.categoryController,
    required this.discountController,
  });

  @override
  State<_ProductGridItemContent> createState() =>
      _ProductGridItemContentState();
}

class _ProductGridItemContentState extends State<_ProductGridItemContent>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  final GlobalKey _widgetKey = GlobalKey();
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.product.isOutOfStock;
    final hasQuantity = widget.quantity > 0;

    // Calculate discount
    double? categoryDiscount;
    if (widget.product.categoryId != null) {
      final category = widget.categoryController.categories
          .where((c) => c.id == widget.product.categoryId)
          .firstOrNull;
      if (category != null && category.hasDiscount) {
        categoryDiscount = category.discountPercentage;
      }
    }

    double? promotionDiscount;
    if (widget.discountController.activePromotions.isNotEmpty) {
      promotionDiscount =
          widget.discountController.activePromotions.first.discountPercentage;
    }

    final hasCompoundDiscount = widget.product.hasAnyDiscount(
      categoryDiscount: categoryDiscount,
      promotionDiscount: promotionDiscount,
    );

    final compoundPrice = hasCompoundDiscount
        ? widget.product.calculateCompoundPrice(
            categoryDiscount: categoryDiscount,
            promotionDiscount: promotionDiscount,
          )
        : widget.product.price;

    return Container(
      key: _widgetKey,
      child: GestureDetector(
        onTapDown: (_) {
          if (!isOutOfStock) {
            setState(() => _isPressed = true);
            _pressController.forward();
            HapticFeedback.lightImpact();
          }
        },
        onTapUp: (_) {
          if (!isOutOfStock) {
            setState(() => _isPressed = false);
            _pressController.reverse();
          }
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _pressController.reverse();
        },
        onTap: isOutOfStock
            ? null
            : () {
                if (widget.onAddAnimation != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final RenderBox? renderBox =
                        _widgetKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    if (renderBox != null) {
                      final position = renderBox.localToGlobal(Offset.zero);
                      final size = renderBox.size;
                      final centerPosition = Offset(
                        position.dx + size.width / 2 - 20,
                        position.dy + size.height / 2 - 20,
                      );
                      widget.onAddAnimation!(centerPosition);
                    }
                  });
                }
                widget.onTap();
              },
        child:
            _buildCard(
                  context,
                  isOutOfStock,
                  hasQuantity,
                  hasCompoundDiscount,
                  compoundPrice,
                )
                .animate(
                  delay: (widget.index != null
                      ? Duration(milliseconds: widget.index! * 50)
                      : Duration.zero),
                )
                .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    bool isOutOfStock,
    bool hasQuantity,
    bool hasCompoundDiscount,
    double compoundPrice,
  ) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final cardColor = NeoBrutalTheme.getCardColor(context);

    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final offset = _isPressed ? const Offset(4.0, 4.0) : Offset.zero;
        final shadowAlpha = _isPressed ? 0.05 : 0.2;

        return Transform.translate(
          offset: offset,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
              border: Border.all(
                color: hasQuantity ? NeoBrutalTheme.primary : borderColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowAlpha),
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 60,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(NeoBrutalTheme.radiusMedium),
                        topRight: Radius.circular(NeoBrutalTheme.radiusMedium),
                      ),
                      color: _getPlaceholderColor(widget.product.id ?? 0),
                    ),
                    child: _buildImageContent(isOutOfStock, hasQuantity),
                  ),
                ),
                Expanded(
                  flex: 40,
                  child: _buildInfoSection(
                    isOutOfStock,
                    hasQuantity,
                    hasCompoundDiscount,
                    compoundPrice,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build image or placeholder
  Widget _buildImageContent(bool isOutOfStock, bool hasQuantity) {
    final imagePath = widget.product.imagePath;
    final borderColor = NeoBrutalTheme.getBorderColor(context);

    return Stack(
      children: [
        if (imagePath != null && imagePath.isNotEmpty)
          _buildImage(imagePath)
        else
          _buildPlaceholder(),
        if (hasQuantity)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: NeoBrutalTheme.primary,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Text(
                '${widget.quantity}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  height: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build actual image with error handling and object-fit: cover
  Widget _buildImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(NeoBrutalTheme.radiusMedium),
        topRight: Radius.circular(NeoBrutalTheme.radiusMedium),
      ),
      child: Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      ),
    );
  }

  /// Build pastel placeholder when image_path is null or image fails
  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _getPlaceholderColor(widget.product.id ?? 0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(NeoBrutalTheme.radiusMedium),
          topRight: Radius.circular(NeoBrutalTheme.radiusMedium),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  /// Get pastel placeholder color based on product ID
  Color _getPlaceholderColor(int productId) {
    final colors = [
      const Color(0xFFFFB6C1), // Pastel pink
      const Color(0xFFFFD1DC), // Pastel light pink
      const Color(0xFFFFC0CB), // Pastel peach
      const Color(0xFFFFDAB9), // Pastel peach puff
      const Color(0xFFFFE4B5), // Pastel moccasin
      const Color(0xFFFFEDD5), // Pastel floral white
      const Color(0xFFF0E68C), // Pastel khaki
      const Color(0xFFEEE8AA), // Pastel pale goldenrod
      const Color(0xFFE0FFFF), // Pastel cyan
      const Color(0xFFB0E0E6), // Pastel powder blue
      const Color(0xFFADD8E6), // Pastel light blue
      const Color(0xFFC8A2C8), // Pastel lilac
    ];
    return colors[productId % colors.length];
  }

  /// Build info section (Product Name + Price)
  Widget _buildInfoSection(
    bool isOutOfStock,
    bool hasQuantity,
    bool hasCompoundDiscount,
    double compoundPrice,
  ) {
    final textColor = NeoBrutalTheme.getTextColor(context);
    final tertiaryColor = isOutOfStock
        ? AppTheme.textTertiary
        : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white38
              : AppTheme.textTertiary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.product.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isOutOfStock ? tertiaryColor : textColor,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasCompoundDiscount)
            Text(
              CurrencyFormatter.format(widget.product.price),
              style: TextStyle(
                fontSize: 10,
                color: tertiaryColor,
                decoration: TextDecoration.lineThrough,
                decorationColor: tertiaryColor,
                height: 1.0,
              ),
            ),
          Row(
            children: [
              Text(
                'Rp',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isOutOfStock
                      ? tertiaryColor
                      : (hasCompoundDiscount
                            ? AppTheme.successColor
                            : NeoBrutalTheme.primary),
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  hasCompoundDiscount
                      ? CurrencyFormatter.formatWithoutDecimals(
                          compoundPrice,
                        ).replaceAll('Rp ', '')
                      : CurrencyFormatter.formatWithoutDecimals(
                          widget.product.price,
                        ).replaceAll('Rp ', ''),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isOutOfStock
                        ? tertiaryColor
                        : (hasCompoundDiscount
                              ? AppTheme.successColor
                              : NeoBrutalTheme.primary),
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
