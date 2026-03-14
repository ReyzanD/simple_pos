import 'package:flutter/material.dart';
import '../animations/animation_constants.dart';
import '../theme/app_theme.dart';

/// Animated number counter that counts up smoothly from 0 to target value
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration? duration;
  final Curve? curve;
  final String? prefix;
  final String? suffix;
  final int? decimalPlaces;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration,
    this.curve,
    this.prefix,
    this.suffix,
    this.decimalPlaces,
    this.style,
    this.textAlign,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AnimationDurations.slow,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AnimationCurves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? AnimationCurves.easeOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = (_previousValue +
            (widget.value - _previousValue) * _animation.value);
        return Text(
          _formatValue(currentValue),
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }

  String _formatValue(double value) {
    String formatted;
    if (widget.decimalPlaces != null && widget.decimalPlaces! > 0) {
      formatted = value.toStringAsFixed(widget.decimalPlaces!);
    } else {
      formatted = value.round().toString();
    }
    return '${widget.prefix ?? ''}$formatted${widget.suffix ?? ''}';
  }
}

/// Animated counter for currency values with proper formatting
class AnimatedCurrencyCounter extends StatefulWidget {
  final double value;
  final Duration? duration;
  final Curve? curve;
  final String? currencySymbol;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool showDecimals;

  const AnimatedCurrencyCounter({
    super.key,
    required this.value,
    this.duration,
    this.curve,
    this.currencySymbol,
    this.style,
    this.textAlign,
    this.showDecimals = true,
  });

  @override
  State<AnimatedCurrencyCounter> createState() => _AnimatedCurrencyCounterState();
}

class _AnimatedCurrencyCounterState extends State<AnimatedCurrencyCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AnimationDurations.slow,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AnimationCurves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCurrencyCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? AnimationCurves.easeOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = (_previousValue +
            (widget.value - _previousValue) * _animation.value);
        return Text(
          _formatCurrency(currentValue),
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }

  String _formatCurrency(double value) {
    final symbol = widget.currencySymbol ?? '\$';
    if (widget.showDecimals) {
      final formatted = value.toStringAsFixed(2);
      // Add thousand separators
      final parts = formatted.split('.');
      final integerPart = _addThousandSeparator(parts[0]);
      return '$symbol$integerPart.${parts[1]}';
    } else {
      final rounded = value.round().toString();
      return '$symbol${_addThousandSeparator(rounded)}';
    }
  }

  String _addThousandSeparator(String value) {
    final buffer = StringBuffer();
    final length = value.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(value[i]);
    }
    return buffer.toString();
  }
}

/// Compact counter badge with animation
class AnimatedCounterBadge extends StatefulWidget {
  final int count;
  final Duration? duration;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;

  const AnimatedCounterBadge({
    super.key,
    required this.count,
    this.duration,
    this.backgroundColor,
    this.textColor,
    this.size,
  });

  @override
  State<AnimatedCounterBadge> createState() => _AnimatedCounterBadgeState();
}

class _AnimatedCounterBadgeState extends State<AnimatedCounterBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AnimationDurations.fast,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.bounceOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounterBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _scaleAnimation = Tween<double>(
        begin: 1.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AnimationCurves.bounceOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count == 0) {
      return const SizedBox.shrink();
    }

    final backgroundColor = widget.backgroundColor ?? AppTheme.errorColor;
    final textColor = widget.textColor ?? Colors.white;
    final size = widget.size ?? 18;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            constraints: BoxConstraints(
              minWidth: size,
              minHeight: size,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Center(
              child: Text(
                _formatCount(),
                style: TextStyle(
                  color: textColor,
                  fontSize: size * 0.7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCount() {
    if (widget.count > 99) {
      return '99+';
    }
    return widget.count.toString();
  }
}

/// Percentage change indicator with animated sign
class AnimatedPercentageChange extends StatefulWidget {
  final double value; // Positive for increase, negative for decrease
  final Duration? duration;
  final TextStyle? style;

  const AnimatedPercentageChange({
    super.key,
    required this.value,
    this.duration,
    this.style,
  });

  @override
  State<AnimatedPercentageChange> createState() => _AnimatedPercentageChangeState();
}

class _AnimatedPercentageChangeState extends State<AnimatedPercentageChange>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? AnimationDurations.normal,
    );

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPercentageChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _slideAnimation = Tween<double>(
        begin: _getDirection() * 0.3,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AnimationCurves.easeOut,
      ));
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AnimationCurves.easeOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getDirection() {
    return widget.value >= _previousValue ? -0.3 : 0.3;
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.value >= 0;
    final color = isPositive ? AppTheme.successColor : AppTheme.errorColor;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.value.abs().toStringAsFixed(1)}%',
                  style: (widget.style ?? const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )).copyWith(color: color),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Quick stat counter that animates from 0 to target
class QuickStatCounter extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color? color;
  final Duration? duration;

  const QuickStatCounter({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? AppTheme.primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: accentColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        AnimatedCounter(
          value: value,
          duration: duration,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
