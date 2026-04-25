import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../animations/animation_constants.dart';
import '../utils/haptic_helper.dart';

/// Modern primary button with consistent styling and animations
class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isSuccess;
  final bool isError;
  final Duration? successDuration;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.isSuccess = false,
    this.isError = false,
    this.successDuration,
  });

  @override
  State<ModernButton> createState() => ModernButtonState();
}

class ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AnimationScales.buttonPress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));
  }

  @override
  void didUpdateWidget(ModernButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSuccess && !oldWidget.isSuccess) {
      _showSuccessState();
    }
    if (widget.isError && !oldWidget.isError) {
      _triggerShake();
    }
  }

  void _showSuccessState() {
    setState(() => _showSuccess = true);
    Future.delayed(
      widget.successDuration ?? const Duration(milliseconds: 1500),
      () {
        if (mounted) {
          setState(() => _showSuccess = false);
        }
      },
    );
  }

  void _triggerShake() {
    _controller.forward().then((_) => _controller.reverse());
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isDisabled) {
      HapticHelper.mediumImpact();
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isDisabled) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!_isDisabled) {
      _controller.reverse();
    }
  }

  bool get _isDisabled => widget.isLoading || widget.onPressed == null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ?? AppTheme.primaryColor;
    final effectiveForegroundColor = widget.foregroundColor ?? Colors.white;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = widget.isError
              ? 1.0 + (_shakeAnimation.value / 100).abs()
              : _scaleAnimation.value;

          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: widget.isFullWidth ? double.infinity : null,
              child: ElevatedButton(
                onPressed: null, // Handled by GestureDetector
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveBackgroundColor,
                  foregroundColor: effectiveForegroundColor,
                  padding:
                      widget.padding ??
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  disabledBackgroundColor: AppTheme.textTertiary,
                ),
                child: _buildContent(effectiveForegroundColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(Color foregroundColor) {
    if (_showSuccess) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: _CheckmarkDraw(),
      );
    }

    if (widget.isLoading) {
      return const _PulsingLoader();
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            widget.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Checkmark draw animation for success state
class _CheckmarkDraw extends StatefulWidget {
  const _CheckmarkDraw();

  @override
  State<_CheckmarkDraw> createState() => _CheckmarkDrawState();
}

class _CheckmarkDrawState extends State<_CheckmarkDraw>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _CheckmarkPainter(_animation.value),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;

  _CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final start = Offset(size.width * 0.25, size.height * 0.5);
    final middle = Offset(size.width * 0.45, size.height * 0.7);
    final end = Offset(size.width * 0.75, size.height * 0.3);

    final totalLength = 60.0;
    final drawLength = totalLength * progress.clamp(0.0, 1.0);

    if (drawLength > 0) {
      final firstSegment = 24.0;
      if (drawLength <= firstSegment) {
        final t = drawLength / firstSegment;
        final current = Offset(
          start.dx + (middle.dx - start.dx) * t,
          start.dy + (middle.dy - start.dy) * t,
        );
        path.moveTo(start.dx, start.dy);
        path.lineTo(current.dx, current.dy);
      } else {
        path.moveTo(start.dx, start.dy);
        path.lineTo(middle.dx, middle.dy);

        final remaining = drawLength - firstSegment;
        final t = (remaining / 36.0).clamp(0.0, 1.0);
        final current = Offset(
          middle.dx + (end.dx - middle.dx) * t,
          middle.dy + (end.dy - middle.dy) * t,
        );
        path.lineTo(current.dx, current.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Pulsing loading indicator
class _PulsingLoader extends StatefulWidget {
  const _PulsingLoader();

  @override
  State<_PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<_PulsingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            value: _animation.value,
          );
        },
      ),
    );
  }
}

/// Modern secondary button
class ModernSecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  const ModernSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  State<ModernSecondaryButton> createState() => _ModernSecondaryButtonState();
}

class _ModernSecondaryButtonState extends State<ModernSecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AnimationScales.buttonPress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _handleTapDown(TapDownDetails details) {
    HapticHelper.lightImpact();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.isFullWidth ? double.infinity : null,
              child: OutlinedButton(
                onPressed: null, // Handled by GestureDetector
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Modern icon button with press animation
class ModernIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  State<ModernIconButton> createState() => _ModernIconButtonState();
}

class _ModernIconButtonState extends State<ModernIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AnimationScales.buttonPress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _handleTapDown(TapDownDetails details) {
    HapticHelper.lightImpact();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size ?? 48,
              height: widget.size ?? 48,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: null, // Handled by GestureDetector
                  borderRadius: BorderRadius.circular(12),
                  child: Tooltip(
                    message: widget.tooltip ?? '',
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor ?? AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Modern action button for FAB-like behavior
class ModernActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Object? heroTag;

  const ModernActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.heroTag,
  });

  @override
  State<ModernActionButton> createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<ModernActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AnimationScales.buttonPress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _handleTapDown(TapDownDetails details) {
    HapticHelper.lightImpact();
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FloatingActionButton.extended(
              heroTag: widget.heroTag, // ✅ Unique hero tag
              onPressed: null, // Handled by GestureDetector
              backgroundColor: widget.backgroundColor ?? AppTheme.primaryColor,
              icon: Icon(widget.icon, color: Colors.white),
              label: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 4,
            ),
          );
        },
      ),
    );
  }
}
