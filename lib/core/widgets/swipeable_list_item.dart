import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_helper.dart';
import 'package:simple_pos/l10n/app_localizations.dart';

/// Swipeable list item with configurable left and right actions
///
/// Features:
/// - Left swipe action (e.g., edit, quick add)
/// - Right swipe actions (e.g., delete, archive)
/// - Haptic feedback on swipe
/// - Smooth animations
/// - Undo support
class SwipeableListItem extends StatelessWidget {
  final Widget child;
  final List<SwipeAction>? leftActions;
  final List<SwipeAction>? rightActions;
  final VoidCallback? onSwipe;
  final bool enabled;

  const SwipeableListItem({
    super.key,
    required this.child,
    this.leftActions,
    this.rightActions,
    this.onSwipe,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || (rightActions == null && leftActions == null)) {
      return child;
    }

    return SwipeableWidget(
      leftActions: leftActions,
      rightActions: rightActions,
      onSwipe: onSwipe,
      child: child,
    );
  }
}

/// Swipe action configuration
class SwipeAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const SwipeAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.backgroundColor,
  });
}

/// Internal swipeable widget
class SwipeableWidget extends StatefulWidget {
  final Widget child;
  final List<SwipeAction>? leftActions;
  final List<SwipeAction>? rightActions;
  final VoidCallback? onSwipe;

  const SwipeableWidget({
    super.key,
    required this.child,
    this.leftActions,
    this.rightActions,
    this.onSwipe,
  });

  @override
  State<SwipeableWidget> createState() => _SwipeableWidgetState();
}

class _SwipeableWidgetState extends State<SwipeableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragOffset = 0;
  final double _actionWidth = 80.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Background actions
          Positioned.fill(child: _buildActionsBackground()),
          // Foreground content
          SlideTransition(
            position:
                Tween<Offset>(
                  begin: Offset.zero,
                  end: Offset(
                    _dragOffset / MediaQuery.sizeOf(context).width,
                    0,
                  ),
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOut,
                  ),
                ),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsBackground() {
    if (_dragOffset > 0 && widget.leftActions != null) {
      // Swiping right, show left actions
      return Row(
        children: widget.leftActions!.map((action) {
          return _ActionBackground(action: action, width: _actionWidth);
        }).toList(),
      );
    } else if (_dragOffset < 0 && widget.rightActions != null) {
      // Swiping left, show right actions
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: widget.rightActions!.map((action) {
          return _ActionBackground(action: action, width: _actionWidth);
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;

      // Limit the swipe distance
      final maxOffset =
          _actionWidth *
          (widget.rightActions?.length ?? widget.leftActions?.length ?? 1);

      if (_dragOffset > maxOffset) {
        _dragOffset = maxOffset;
      } else if (_dragOffset < -maxOffset) {
        _dragOffset = -maxOffset;
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final maxOffset =
        _actionWidth *
        (widget.rightActions?.length ?? widget.leftActions?.length ?? 1);
    final threshold = maxOffset * 0.3;

    if (_dragOffset > threshold || _dragOffset < -threshold) {
      // Swipe complete, trigger action
      _triggerAction();
    } else {
      // Snap back
      _snapBack();
    }
  }

  void _triggerAction() {
    // Determine which action was triggered based on swipe direction and distance
    if (_dragOffset > 0 && widget.leftActions != null) {
      final actionIndex = (_dragOffset / _actionWidth).floor().clamp(
        0,
        widget.leftActions!.length - 1,
      );
      final action = widget.leftActions![actionIndex];
      _snapBack().then((_) {
        HapticHelper.lightImpact();
        action.onTap();
      });
    } else if (_dragOffset < 0 && widget.rightActions != null) {
      final actionIndex = (-_dragOffset / _actionWidth).floor().clamp(
        0,
        widget.rightActions!.length - 1,
      );
      final action = widget.rightActions![actionIndex];
      _snapBack().then((_) {
        HapticHelper.lightImpact();
        action.onTap();
      });
    }
  }

  Future<void> _snapBack() async {
    await _animationController.forward();
    setState(() => _dragOffset = 0);
    await _animationController.reverse();
  }
}

class _ActionBackground extends StatelessWidget {
  final SwipeAction action;
  final double width;

  const _ActionBackground({required this.action, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: action.backgroundColor ?? action.color.withValues(alpha: 0.15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(action.icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            action.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pre-configured swipe actions for common use cases
class SwipeActions {
  // Private constructor
  SwipeActions._();

  /// Edit action
  static SwipeAction edit({
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return SwipeAction(
      icon: Icons.edit_outlined,
      label: l10n.common_edit,
      color: AppTheme.infoColor,
      backgroundColor: AppTheme.infoColor,
      onTap: onTap,
    );
  }

  /// Delete action
  static SwipeAction delete({
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return SwipeAction(
      icon: Icons.delete_outline,
      label: l10n.common_delete,
      color: AppTheme.errorColor,
      backgroundColor: AppTheme.errorColor,
      onTap: onTap,
    );
  }

  /// Archive action
  static SwipeAction archive({
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return SwipeAction(
      icon: Icons.archive_outlined,
      label: l10n.common_archive,
      color: AppTheme.warningColor,
      backgroundColor: AppTheme.warningColor,
      onTap: onTap,
    );
  }

  /// Quick add action
  static SwipeAction quickAdd({
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return SwipeAction(
      icon: Icons.add_shopping_cart,
      label: l10n.common_add,
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.primaryColor,
      onTap: onTap,
    );
  }

  /// Favorite action
  static SwipeAction favorite({
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return SwipeAction(
      icon: Icons.favorite_border,
      label: l10n.common_favorite,
      color: Colors.pink,
      backgroundColor: Colors.pink,
      onTap: onTap,
    );
  }

  /// Share action
  static SwipeAction share({
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return SwipeAction(
      icon: Icons.share,
      label: l10n.common_share,
      color: AppTheme.successColor,
      backgroundColor: AppTheme.successColor,
      onTap: onTap,
    );
  }

  /// Standard edit and delete actions for right swipe
  static List<SwipeAction> editAndDelete({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required BuildContext context,
  }) {
    return [
      delete(onTap: onDelete, context: context),
      edit(onTap: onEdit, context: context),
    ];
  }

  /// Standard quick add and edit actions for left swipe
  static List<SwipeAction> quickAddAndEdit({
    required VoidCallback onQuickAdd,
    required VoidCallback onEdit,
    required BuildContext context,
  }) {
    return [
      quickAdd(onTap: onQuickAdd, context: context),
      edit(onTap: onEdit, context: context),
    ];
  }
}

/// Simpler swipeable container for basic swipe-to-delete functionality
class SwipeToDeleteContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final Color? deleteColor;

  const SwipeToDeleteContainer({
    super.key,
    required this.child,
    required this.onDelete,
    this.deleteColor,
  });

  @override
  State<SwipeToDeleteContainer> createState() => _SwipeToDeleteContainerState();
}

class _SwipeToDeleteContainerState extends State<SwipeToDeleteContainer>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _controller;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deleteColor = widget.deleteColor ?? AppTheme.errorColor;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (_isDeleting) return;
        setState(() {
          _dragOffset += details.delta.dx;
          if (_dragOffset > 0) _dragOffset = 0; // Only allow left swipe
          if (_dragOffset < -200) _dragOffset = -200;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_isDeleting) return;

        if (_dragOffset < -100) {
          // Swiped far enough, confirm delete
          _confirmDelete();
        } else {
          // Snap back
          _controller.forward().then((_) {
            setState(() => _dragOffset = 0);
            _controller.reverse();
          });
        }
      },
      child: Stack(
        children: [
          Container(
            color: deleteColor,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: _dragOffset < -80
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Release to Delete',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  )
                : const Icon(Icons.delete, color: Colors.white),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    HapticHelper.mediumImpact();
    setState(() => _isDeleting = true);

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isDeleting = false;
                _dragOffset = 0;
              });
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
