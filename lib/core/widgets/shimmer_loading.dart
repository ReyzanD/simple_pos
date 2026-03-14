import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shimmer loading effect for skeleton screens
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppTheme.borderColor;
    final highlightColor = widget.highlightColor ?? Colors.white.withValues(alpha: 0.8);

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.centerRight,
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: _SlidingGradientTransform(
            slidePercent: _animation.value,
          ),
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Base shimmer container for custom shapes
class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.borderColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Shimmer rectangle (most common)
class ShimmerRectangle extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const ShimmerRectangle({
    super.key,
    this.width,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: width ?? double.infinity,
      height: height ?? 16,
      margin: margin,
      borderRadius: BorderRadius.circular(8),
    );
  }
}

/// Shimmer circle for avatars and icons
class ShimmerCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const ShimmerCircle({
    super.key,
    this.size = 48,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: size,
      height: size,
      margin: margin,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

/// Pre-built shimmer card for loading states
class ShimmerCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final double? width;

  const ShimmerCard({
    super.key,
    this.margin,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.shadowSm,
      ),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerCircle(size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerRectangle(height: 16, width: 120),
                      const SizedBox(height: 8),
                      ShimmerRectangle(height: 14, width: 80),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ShimmerRectangle(height: 12),
            const SizedBox(height: 8),
            ShimmerRectangle(height: 12, width: 200),
          ],
        ),
      ),
    );
  }
}

/// Shimmer list item for list loading states
class ShimmerListItem extends StatelessWidget {
  final bool showLeading;
  final bool showTrailing;
  final EdgeInsetsGeometry? padding;

  const ShimmerListItem({
    super.key,
    this.showLeading = true,
    this.showTrailing = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ShimmerLoading(
        child: Row(
          children: [
            if (showLeading) ...[
              const ShimmerCircle(size: 40),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerRectangle(height: 16, width: double.infinity),
                  const SizedBox(height: 8),
                  ShimmerRectangle(height: 14, width: 150),
                ],
              ),
            ),
            if (showTrailing) ...[
              const SizedBox(width: 12),
              const ShimmerRectangle(width: 24, height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer product grid item for POS/inventory
class ShimmerProductGridItem extends StatelessWidget {
  final double? width;

  const ShimmerProductGridItem({
    super.key,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.shadowSm,
      ),
      child: ShimmerLoading(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Title placeholder
              ShimmerRectangle(height: 14),
              const SizedBox(height: 6),
              // Price placeholder
              ShimmerRectangle(height: 16, width: 60),
              const SizedBox(height: 8),
              // Stock placeholder
              ShimmerRectangle(height: 12, width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer stat card for dashboard/stats screens
class ShimmerStatCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const ShimmerStatCard({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.shadowSm,
      ),
      child: ShimmerLoading(
        child: Row(
          children: [
            const ShimmerCircle(size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerRectangle(height: 12, width: 80),
                  const SizedBox(height: 8),
                  ShimmerRectangle(height: 24, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
