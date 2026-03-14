import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'animation_constants.dart';

/// Shared axis transition - simplified wrapper
/// For hierarchical navigation, use SharedAxisPageRoute
class SharedAxisTransition extends StatelessWidget {
  final Widget child;
  final Duration? duration;
  final bool fill;

  const SharedAxisTransition({
    super.key,
    required this.child,
    this.duration,
    this.fill = true,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  /// Create a wrapped version of the child with transition
  static Widget wrapped({
    required Widget child,
    Duration? duration,
    bool fill = true,
  }) {
    return SharedAxisTransition(
      key: GlobalKey(),
      duration: duration,
      fill: fill,
      child: child,
    );
  }
}

/// Fade through transition - for tab switching and peer-to-peer navigation
/// Creates a smooth cross-fade between unrelated screens
class FadeThroughTransition extends StatefulWidget {
  final Widget child;
  final Duration? duration;

  const FadeThroughTransition({
    super.key,
    required this.child,
    this.duration,
  });

  @override
  State<FadeThroughTransition> createState() => _FadeThroughTransitionState();
}

class _FadeThroughTransitionState extends State<FadeThroughTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
      curve: AnimationCurves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.96,
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Fade scale transition - for dialogs and modals
/// Creates a smooth appear/disappear animation for overlays
class FadeScaleTransition extends StatefulWidget {
  final Widget child;
  final Duration? duration;

  const FadeScaleTransition({
    super.key,
    required this.child,
    this.duration,
  });

  @override
  State<FadeScaleTransition> createState() => _FadeScaleTransitionState();
}

class _FadeScaleTransitionState extends State<FadeScaleTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
      curve: AnimationCurves.decelerate,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.emphasized,
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

/// Slide fade transition - for sliding pages in from edges
enum SlideDirection { fromTop, fromBottom, fromLeft, fromRight }

class SlideFadeTransition extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration? duration;
  final Curve? curve;

  const SlideFadeTransition({
    super.key,
    required this.child,
    this.direction = SlideDirection.fromBottom,
    this.duration,
    this.curve,
  });

  @override
  State<SlideFadeTransition> createState() => _SlideFadeTransitionState();
}

class _SlideFadeTransitionState extends State<SlideFadeTransition>
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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? AnimationCurves.decelerate,
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
      curve: widget.curve ?? AnimationCurves.decelerate,
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Custom page route builder with shared axis transition
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  SharedAxisPageRoute({
    required Widget child,
    Duration? duration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration ?? AnimationDurations.normal,
          reverseTransitionDuration: duration ?? AnimationDurations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = AnimationCurves.fastOutSlowIn;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

/// Fade through page route for tab-like navigation
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  FadeThroughPageRoute({
    required Widget child,
    Duration? duration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration ?? AnimationDurations.normal,
          reverseTransitionDuration: duration ?? AnimationDurations.fast,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: AnimationCurves.easeOut,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}
