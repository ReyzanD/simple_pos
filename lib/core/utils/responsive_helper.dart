import 'package:flutter/widgets.dart';

/// Responsive helper utility for adaptive UI layouts
///
/// Provides screen size-based calculations for responsive design.
/// Breakpoints:
/// - Mobile: < 600px
/// - Tablet: 600px - 900px
/// - Desktop: > 900px
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Get responsive value based on screen width
  ///
  /// [mobile] - value for mobile screens (< 600px)
  /// [tablet] - value for tablet screens (600px - 900px)
  /// [desktop] - value for desktop screens (> 900px)
  static T getValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;

    if (width > 900 && desktop != null) {
      return desktop;
    } else if (width > 600 && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive column count for grid layouts
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  /// Get responsive column count for wide grids (e.g., KPI cards)
  static int getWideGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  /// Get responsive child aspect ratio for grid items
  static double getGridChildAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 0.85;
    if (width > 600) return 0.82;
    if (width > 360) return 0.80; // Medium phones
    return 0.70; // Very small phones - gives more height
  }

  /// Check if screen is very small (should use list view instead of grid)
  static bool isVerySmallScreen(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    // Very small screen: either narrow width OR small height
    // This covers both narrow phones and phones in landscape with limited height
    return width < 400 || height < 600;
  }

  /// Get responsive padding for screens
  static EdgeInsets getScreenPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) {
      return const EdgeInsets.all(24);
    } else if (width > 600) {
      return const EdgeInsets.all(20);
    }
    return const EdgeInsets.all(16);
  }

  /// Get responsive spacing between cards
  static double getCardSpacing(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 16;
    if (width > 600) return 14;
    return 12;
  }

  /// Get responsive chart height
  static double getChartHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 300;
    if (width > 600) return 250;
    return 200;
  }

  /// Get responsive font size
  static double getFontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getValue<double>(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 600;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width <= 900;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width > 900;
  }

  /// Get responsive border radius
  static double getBorderRadius(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 16;
    if (width > 600) return 14;
    return 12;
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 24;
    if (width > 600) return 22;
    return 20;
  }

  /// Get responsive container padding
  static double getContainerPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 900) return 20;
    if (width > 600) return 18;
    return 16;
  }
}
