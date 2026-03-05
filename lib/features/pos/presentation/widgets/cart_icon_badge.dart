import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Cart icon with badge showing item count in AppBar
///
/// Features:
/// - Badge shows item count (red circle with white text)
/// - Bump animation when count changes (scale 1.0 -> 1.3 -> 1.0)
/// - Tap callback to open cart modal
class CartIconBadge extends StatefulWidget {
  final int itemCount;
  final VoidCallback onTap;

  const CartIconBadge({
    super.key,
    required this.itemCount,
    required this.onTap,
  });

  @override
  State<CartIconBadge> createState() => CartIconBadgeState();
}

class CartIconBadgeState extends State<CartIconBadge>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _previousCount = widget.itemCount;
  }

  @override
  void didUpdateWidget(CartIconBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger bump animation when count increases
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

  /// Programmatically trigger the bump animation
  void bumpAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cart icon
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: widget.onTap,
          tooltip: 'Keranjang',
        ),

        // Badge
        if (widget.itemCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                elevation: 2,
                shape: const CircleBorder(),
                child: Container(
                  width: widget.itemCount > 9 ? 22 : 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.itemCount > 9 ? '9+' : '${widget.itemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
