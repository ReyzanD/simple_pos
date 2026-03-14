import 'package:flutter/material.dart';
import '../animations/animation_constants.dart';
import '../animations/page_transitions.dart';

/// Wraps page content with consistent entrance animation
/// Provides fadeIn + slideY animation for smooth page transitions
class AnimatedPageWrapper extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration? duration;
  final Curve? curve;
  final bool enableSlide;

  const AnimatedPageWrapper({
    super.key,
    required this.child,
    this.direction = SlideDirection.fromBottom,
    this.duration,
    this.curve,
    this.enableSlide = true,
  });

  @override
  State<AnimatedPageWrapper> createState() => _AnimatedPageWrapperState();
}

class _AnimatedPageWrapperState extends State<AnimatedPageWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final duration = widget.duration ?? AnimationDurations.normal;

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    final curve = widget.curve ?? AnimationCurves.decelerate;

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: curve,
    ));

    if (widget.enableSlide) {
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
        curve: curve,
      ));
    } else {
      _slideAnimation = const AlwaysStoppedAnimation(AnimationOffsets.none);
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Wraps a list of children with staggered entrance animation
/// Useful for animating list items or card children one after another
class StaggeredAnimationList extends StatelessWidget {
  final List<Widget> children;
  final Duration? duration;
  final Duration? staggerDelay;
  final SlideDirection direction;
  final bool enableSlide;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.duration,
    this.staggerDelay,
    this.direction = SlideDirection.fromBottom,
    this.enableSlide = true,
  });

  @override
  Widget build(BuildContext context) {
    final itemDuration = duration ?? AnimationDurations.normal;
    final delay = staggerDelay ?? const Duration(milliseconds: 50);

    return Column(
      children: [
        for (int i = 0; i < children.length; i++)
          _StaggeredItem(
            key: ValueKey(i),
            index: i,
            duration: itemDuration,
            delay: delay,
            direction: direction,
            enableSlide: enableSlide,
            child: children[i],
          ),
      ],
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  final int index;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final bool enableSlide;
  final Widget child;

  const _StaggeredItem({
    super.key,
    required this.index,
    required this.duration,
    required this.delay,
    required this.direction,
    required this.enableSlide,
    required this.child,
  });

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curve = AnimationCurves.decelerate;

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: curve,
    ));

    if (widget.enableSlide) {
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
        curve: curve,
      ));
    } else {
      _slideAnimation = const AlwaysStoppedAnimation(AnimationOffsets.none);
    }

    // Start animation after stagger delay
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Wraps a grid of children with staggered entrance animation
/// Perfect for product grids or dashboard widgets
class StaggeredAnimationGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Duration? duration;
  final Duration? staggerDelay;
  final SlideDirection direction;
  final bool enableSlide;

  const StaggeredAnimationGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.duration,
    this.staggerDelay,
    this.direction = SlideDirection.fromBottom,
    this.enableSlide = true,
  });

  @override
  Widget build(BuildContext context) {
    final itemDuration = duration ?? AnimationDurations.normal;
    final delay = staggerDelay ?? const Duration(milliseconds: 80);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return _StaggeredItem(
          key: ValueKey('grid_$index'),
          index: index,
          duration: itemDuration,
          delay: delay,
          direction: direction,
          enableSlide: enableSlide,
          child: children[index],
        );
      },
    );
  }
}

/// Simple fade-only wrapper for subtle entrance
class FadeInWrapper extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Curve? curve;

  const FadeInWrapper({
    super.key,
    required this.child,
    this.duration,
    this.curve,
  });

  @override
  State<FadeInWrapper> createState() => _FadeInWrapperState();
}

class _FadeInWrapperState extends State<FadeInWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
      curve: widget.curve ?? AnimationCurves.easeOut,
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

/// Scale wrapper for pop-in entrance effect
class ScaleInWrapper extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final Curve? curve;
  final double beginScale;

  const ScaleInWrapper({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.beginScale = 0.8,
  });

  @override
  State<ScaleInWrapper> createState() => _ScaleInWrapperState();
}

class _ScaleInWrapperState extends State<ScaleInWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    final duration = widget.duration ?? AnimationDurations.normal;

    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AnimationCurves.emphasized,
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
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: widget.child,
    );
  }
}
