// lib/core/widgets/quick_actions_menu.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../animations/animation_constants.dart';

/// Quick Actions Menu - expands on long press of FAB
/// Shows 6 quick actions for common POS operations
class QuickActionsMenu extends StatefulWidget {
  final VoidCallback onFavorites;
  final VoidCallback onHeldOrders;
  final VoidCallback onQuickAdd;
  final VoidCallback onQuickQuantity;
  final VoidCallback onTodaySummary;
  final VoidCallback onRefresh;

  const QuickActionsMenu({
    super.key,
    required this.onFavorites,
    required this.onHeldOrders,
    required this.onQuickAdd,
    required this.onQuickQuantity,
    required this.onTodaySummary,
    required this.onRefresh,
  });

  @override
  State<QuickActionsMenu> createState() => _QuickActionsMenuState();
}

class _QuickActionsMenuState extends State<QuickActionsMenu>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  static const List<_QuickAction> _actions = [
    _QuickAction(Icons.star, 'Favorites', 'favorites'),
    _QuickAction(Icons.receipt_long, 'Held Orders', 'held_orders'),
    _QuickAction(Icons.add_circle, 'Quick Add', 'quick_add'),
    _QuickAction(Icons.pin, 'Quick Quantity', 'quick_quantity'),
    _QuickAction(Icons.bar_chart, 'Today\'s Summary', 'today_summary'),
    _QuickAction(Icons.refresh, 'Refresh', 'refresh'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationDurations.normal,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AnimationCurves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  VoidCallback _getHandler(String action) {
    switch (action) {
      case 'favorites':
        return widget.onFavorites;
      case 'held_orders':
        return widget.onHeldOrders;
      case 'quick_add':
        return widget.onQuickAdd;
      case 'quick_quantity':
        return widget.onQuickQuantity;
      case 'today_summary':
        return widget.onTodaySummary;
      case 'refresh':
        return widget.onRefresh;
      default:
        return () {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Action buttons (arranged in arc around FAB)
          if (_isExpanded)
            ...List.generate(_actions.length, (index) {
              final action = _actions[index];
              final angle = 90.0 + (index * 45.0); // Arc from bottom
              return _buildActionButton(action, angle);
            }),

          // Main FAB
          GestureDetector(
            onLongPress: _toggle,
            onTap: _isExpanded ? _toggle : null,
            child: FloatingActionButton(
              heroTag: 'quick_actions_fab',
              backgroundColor: AppTheme.primaryColor,
              onPressed: _isExpanded ? _toggle : null,
              child: AnimatedIcon(
                icon: _isExpanded
                    ? AnimatedIcons.close_menu
                    : AnimatedIcons.menu_close,
                progress: _expandAnimation,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(_QuickAction action, double angle) {
    final radians = angle * pi / 180;
    final distance = 70.0;
    final x = distance * cos(radians);
    final y = distance * sin(radians);

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(x, y) * _expandAnimation.value,
          child: Opacity(
            opacity: _expandAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {
              _toggle();
              _getHandler(action.key)();
            },
            customBorder: const CircleBorder(),
            borderRadius: BorderRadius.circular(24),
            child: Tooltip(
              message: action.label,
              child: Center(
                child: Semantics(
                  label: action.label,
                  button: true,
                  child: Icon(
                    action.icon,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String key;

  const _QuickAction(this.icon, this.label, this.key);
}
