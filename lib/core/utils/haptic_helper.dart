import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Helper class for haptic feedback throughout the app
///
/// Usage:
/// ```dart
/// HapticHelper.lightImpact();  // For light taps
/// HapticHelper.mediumImpact(); // For button presses
/// HapticHelper.heavyImpact();  // For confirmations
/// HapticHelper.success();       // For successful actions
/// HapticHelper.warning();       // For warnings
/// HapticHelper.error();         // For errors
/// HapticHelper.selection();     // For selection changes
/// ```
class HapticHelper {
  // Private constructor to prevent instantiation
  HapticHelper._();

  /// Light haptic feedback for subtle interactions
  /// Use for: tap feedback, scroll edges
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for standard interactions
  /// Use for: button presses, card taps
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for important interactions
  /// Use for: confirmations, destructive actions
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Haptic feedback for successful actions
  /// Use for: successful checkout, data saved
  static void success() {
    HapticFeedback.heavyImpact();
  }

  /// Haptic feedback for warnings
  /// Use for: low stock alerts, validation errors
  static void warning() {
    HapticFeedback.mediumImpact();
  }

  /// Haptic feedback for errors
  /// Use for: failed operations, network errors
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Haptic feedback for selection changes
  /// Use for: tab switching, toggle changes, picker rolls
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate with custom pattern (Android only)
  /// Use for: custom notifications
  ///
  /// [pattern] Array of durations: [vibrate, sleep, vibrate, sleep, ...]
  /// Example: [0, 100, 50, 100] = wait 0ms, vibrate 100ms, sleep 50ms, vibrate 100ms
  static void vibratePattern(List<int> pattern) {
    // Note: This requires the vibration permission on Android
    // For now, we'll use haptic feedback as a cross-platform alternative
    if (pattern.isNotEmpty && pattern[0] == 0) {
      // Initial wait, then vibrate
      Future.delayed(Duration(milliseconds: pattern[0]), () {
        if (pattern.length > 1) {
          HapticFeedback.mediumImpact();
        }
      });
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  /// Notification haptic - sequence of vibrations
  /// Use for: important alerts, completed downloads
  static void notification() {
    // Pattern: medium-heavy
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
  }

  /// Double tap haptic feedback
  /// Use for: double tap to like, double click to edit
  static void doubleTap() {
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
    });
  }
}

/// Extension to provide haptic feedback on any widget
extension HapticWidgetExtension on Widget {
  /// Wrap widget to add haptic feedback on tap
  Widget withHapticFeedback({
    required VoidCallback? onTap,
    HapticType type = HapticType.light,
  }) {
    return GestureDetector(
      onTap: () {
        switch (type) {
          case HapticType.light:
            HapticHelper.lightImpact();
            break;
          case HapticType.medium:
            HapticHelper.mediumImpact();
            break;
          case HapticType.heavy:
            HapticHelper.heavyImpact();
            break;
          case HapticType.success:
            HapticHelper.success();
            break;
          case HapticType.warning:
            HapticHelper.warning();
            break;
          case HapticType.error:
            HapticHelper.error();
            break;
          case HapticType.selection:
            HapticHelper.selection();
            break;
        }
        onTap?.call();
      },
      child: this,
    );
  }
}

/// Types of haptic feedback
enum HapticType {
  light,
  medium,
  heavy,
  success,
  warning,
  error,
  selection,
}
