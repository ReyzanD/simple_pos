import 'package:flutter/material.dart';

/// Animation constants for consistent timing and curves throughout the app
class AnimationDurations {
  const AnimationDurations._();

  /// Fast animations (150ms) - micro-interactions, button presses
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animations (300ms) - standard transitions, UI changes
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow animations (500ms) - elaborate animations, page transitions
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow animations (800ms) - special celebrations
  static const Duration extraSlow = Duration(milliseconds: 800);
}

/// Animation curves for different motion types
class AnimationCurves {
  const AnimationCurves._();

  /// Quick deceleration - for entrances appearing
  static const Curve easeOut = Curves.easeOut;

  /// Smooth in and out - for standard transitions
  static const Curve easeInOut = Curves.easeInOut;

  /// Bouncy finish - for delightful feedback
  static const Curve bounceOut = Curves.bounceOut;

  /// Elastic finish - for playful elements
  static const Curve elasticOut = Curves.elasticOut;

  /// Fast start, gradual stop - for sliding elements
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// Emphasized motion - for important actions
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Decelerated motion - for entering elements
  static const Curve decelerate = Cubic(0.0, 0.0, 0.2, 1.0);

  /// Accelerated motion - for exiting elements
  static const Curve accelerate = Cubic(0.4, 0.0, 1.0, 1.0);
}

/// Stagger delay utilities for list/grid animations
class StaggerDelay {
  const StaggerDelay._();

  /// Calculate delay for list items
  /// [index] - item position in list
  /// [delay] - delay between each item (default 50ms)
  static Duration forListItem(int index, [Duration delay = const Duration(milliseconds: 50)]) {
    return delay * index;
  }

  /// Calculate delay for grid items (slower than list)
  /// [index] - item position in grid
  /// [delay] - delay between each item (default 80ms)
  static Duration forGridItem(int index, [Duration delay = const Duration(milliseconds: 80)]) {
    return delay * index;
  }

  /// Calculate delay for card children
  /// [index] - child position
  /// [delay] - delay between each child (default 60ms)
  static Duration forCardChild(int index, [Duration delay = const Duration(milliseconds: 60)]) {
    return delay * index;
  }
}

/// Common animation presets combining duration and curve
class AnimationPresets {
  const AnimationPresets._();

  /// Quick, subtle animation for micro-interactions
  static const Animatable fast = Animatable(
    duration: AnimationDurations.fast,
    curve: AnimationCurves.easeOut,
  );

  /// Standard animation for UI transitions
  static const Animatable normal = Animatable(
    duration: AnimationDurations.normal,
    curve: AnimationCurves.easeInOut,
  );

  /// Smooth entrance animation
  static const Animatable entrance = Animatable(
    duration: AnimationDurations.normal,
    curve: AnimationCurves.decelerate,
  );

  /// Smooth exit animation
  static const Animatable exit = Animatable(
    duration: AnimationDurations.fast,
    curve: AnimationCurves.accelerate,
  );

  /// Bouncy animation for playful feedback
  static const Animatable bouncy = Animatable(
    duration: AnimationDurations.slow,
    curve: AnimationCurves.bounceOut,
  );

  /// Emphasized animation for important actions
  static const Animatable emphasized = Animatable(
    duration: AnimationDurations.normal,
    curve: AnimationCurves.emphasized,
  );
}

/// Simple animatable configuration
class Animatable {
  final Duration duration;
  final Curve curve;

  const Animatable({
    required this.duration,
    required this.curve,
  });
}

/// Helper for checking if animations should be reduced
class AnimationHelper {
  const AnimationHelper._();

  /// Check if animations should be reduced based on accessibility settings
  static bool shouldReduceAnimations(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.disableAnimations ||
        mediaQuery.accessibleNavigation;
  }

  /// Get appropriate duration based on accessibility settings
  static Duration getDuration(BuildContext context, Duration duration) {
    return shouldReduceAnimations(context)
        ? Duration.zero
        : duration;
  }

  /// Get appropriate curve based on accessibility settings
  static Curve getCurve(BuildContext context, Curve curve) {
    return shouldReduceAnimations(context)
        ? Curves.linear
        : curve;
  }
}

/// Scale values for common animations
class AnimationScales {
  const AnimationScales._();

  /// Button press scale
  static const double buttonPress = 0.95;

  /// Card hover scale
  static const double cardHover = 1.02;

  /// Icon pulse scale
  static const double iconPulse = 1.1;

  /// Badge pop scale
  static const double badgePop = 1.3;

  /// Empty default scale
  static const double none = 1.0;
}

/// Offset values for slide animations
class AnimationOffsets {
  const AnimationOffsets._();

  /// Slide from slightly below (for card entrances)
  static const Offset fromBottom = Offset(0, 0.1);

  /// Slide from above
  static const Offset fromTop = Offset(0, -0.1);

  /// Slide from left
  static const Offset fromLeft = Offset(-0.1, 0);

  /// Slide from right
  static const Offset fromRight = Offset(0.1, 0);

  /// No offset (fade only)
  static const Offset none = Offset.zero;
}
