import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../animations/animation_constants.dart';
import '../animations/page_transitions.dart';
import 'shimmer_loading.dart';

/// Modern card widget with consistent styling and optional entrance animation
class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final Border? border;
  final bool isLoading;
  final bool animateEntrance;
  final Duration? entranceDuration;
  final SlideDirection entranceDirection;
  final bool enableHover;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.border,
    this.isLoading = false,
    this.animateEntrance = false,
    this.entranceDuration,
    this.entranceDirection = SlideDirection.fromBottom,
    this.enableHover = false,
  });

  @override
  State<ModernCard> createState() => ModernCardState();
}

class ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    if (widget.enableHover) {
      _hoverController = AnimationController(
        vsync: this,
        duration: AnimationDurations.fast,
      );

      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: AnimationScales.cardHover,
      ).animate(CurvedAnimation(
        parent: _hoverController,
        curve: AnimationCurves.easeOut,
      ));
    } else {
      _hoverController = AnimationController.unbounded(vsync: this);
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
    }
  }

  void _handleHover(bool isHovered) {
    if (widget.enableHover) {
      setState(() => _isHovered = isHovered);
      if (isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = _AnimatedCardWrapper(
      animate: widget.animateEntrance,
      duration: widget.entranceDuration,
      direction: widget.entranceDirection,
      child: _buildCardContent(),
    );

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: widget.onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                child: cardContent,
              ),
            )
          : cardContent,
    );
  }

  Widget _buildCardContent() {
    final effectiveElevation = widget.elevation ??
        (widget.enableHover && _isHovered ? 4 : 2);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enableHover ? _scaleAnimation.value : 1.0,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: widget.border ??
                  Border.all(
                    color: isDark
                        ? AppTheme.darkBorderColor.withValues(alpha: 0.3)
                        : AppTheme.borderColor,
                    width: 0.5,
                  ),
              boxShadow: effectiveElevation == 0
                  ? []
                  : effectiveElevation == 4
                      ? AppShadows.shadowMd
                      : AppShadows.shadowSm,
              gradient: widget.backgroundColor == null && !isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF8FAFC),
                      ],
                    )
                  : null,
            ),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.isLoading
                  ? _buildLoadingState()
                  : widget.child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Internal wrapper for card entrance animation
class _AnimatedCardWrapper extends StatefulWidget {
  final bool animate;
  final Duration? duration;
  final SlideDirection direction;
  final Widget child;

  const _AnimatedCardWrapper({
    required this.animate,
    this.duration,
    this.direction = SlideDirection.fromBottom,
    required this.child,
  });

  @override
  State<_AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<_AnimatedCardWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.animate) {
      final duration = widget.duration ?? AnimationDurations.normal;
      _controller = AnimationController(
        vsync: this,
        duration: duration,
      );

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AnimationCurves.decelerate,
      ));

      Offset beginOffset;
      switch (widget.direction) {
        case SlideDirection.fromTop:
          beginOffset = AnimationOffsets.fromTop;
          break;
        case SlideDirection.fromBottom:
          beginOffset = AnimationOffsets.fromBottom;
          break;
        case SlideDirection.fromLeft:
          beginOffset = AnimationOffsets.fromLeft;
          break;
        case SlideDirection.fromRight:
          beginOffset = AnimationOffsets.fromRight;
          break;
      }

      _slideAnimation = Tween<Offset>(
        begin: beginOffset,
        end: AnimationOffsets.none,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AnimationCurves.decelerate,
      ));

      _controller.forward();
    } else {
      _controller = AnimationController.unbounded(vsync: this);
      _fadeAnimation = const AlwaysStoppedAnimation(1.0);
      _slideAnimation = const AlwaysStoppedAnimation(AnimationOffsets.none);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.child;
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Stat card for displaying metrics with optional animation
class ModernStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;
  final bool animateValue;
  final bool animateEntrance;

  const ModernStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.subtitle,
    this.trailing,
    this.animateValue = false,
    this.animateEntrance = false,
  });

  @override
  State<ModernStatCard> createState() => _ModernStatCardState();
}

class _ModernStatCardState extends State<ModernStatCard>
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
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = widget.iconColor ?? AppTheme.primaryColor;
    final defaultBgColor = widget.backgroundColor ?? defaultIconColor.withValues(alpha: 0.1);

    final content = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ModernCard(
              onTap: widget.onTap,
              padding: const EdgeInsets.all(16),
              animateEntrance: widget.animateEntrance,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: defaultBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.icon,
                      color: defaultIconColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.value,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: defaultIconColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.trailing != null) widget.trailing!,
                ],
              ),
            ),
          );
        },
      ),
    );

    return content;
  }
}

/// Shimmer wrapper for card loading states
class ShimmerCardWrapper extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerCardWrapper({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ShimmerLoading(child: child);
    }
    return child;
  }
}
