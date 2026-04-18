import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';

/// Cart Floating Button - Animated cart button with item count badge
class CartFloatingButton extends StatefulWidget {
  final int itemCount;
  final double total;
  final VoidCallback onTap;

  const CartFloatingButton({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  @override
  State<CartFloatingButton> createState() => CartFloatingButtonState();
}

class CartFloatingButtonState extends State<CartFloatingButton>
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
  void didUpdateWidget(CartFloatingButton oldWidget) {
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
