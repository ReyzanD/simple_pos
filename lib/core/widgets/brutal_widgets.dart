import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/neo_brutal_theme.dart';
import '../utils/responsive_helper.dart';

/// Neo-Brutalist Card System
///
/// Bold, confident cards with chunky borders and dramatic shadows
/// These make a statement and are instantly memorable
class BrutalCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool isPressed;

  const BrutalCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? NeoBrutalTheme.surface;
    final bColor = borderColor ?? Colors.black;

    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(NeoBrutalTheme.spaceSM),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: bColor,
          width: 4,
        ),
        boxShadow: isPressed
            ? NeoBrutalTheme.insetShadow
            : NeoBrutalTheme.chunkyShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(NeoBrutalTheme.spaceMD),
            child: child,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

/// Neo-Brutalist Button - Chunky and satisfying
class BrutalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const BrutalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? NeoBrutalTheme.primary;
    final txtColor = textColor ?? Colors.white;
    final bColor = borderColor ?? Colors.black;
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: ResponsiveHelper.getValue(
        context: context,
        mobile: 56,
        tablet: 60,
        desktop: 64,
      ), // Responsive height for chunky feel
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          disabledBackgroundColor: Colors.grey.shade400,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getValue(
              context: context,
              mobile: 20,
              tablet: 24,
              desktop: 32,
            ),
            vertical: ResponsiveHelper.getValue(
              context: context,
              mobile: 10,
              tablet: 11,
              desktop: 12,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
            side: BorderSide(
              color: bColor,
              width: 4,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: ResponsiveHelper.getValue(
                  context: context,
                  mobile: 24,
                  tablet: 26,
                  desktop: 28,
                ),
                height: ResponsiveHelper.getValue(
                  context: context,
                  mobile: 24,
                  tablet: 26,
                  desktop: 28,
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 24),
                    const SizedBox(width: NeoBrutalTheme.spaceSM),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    ).animate(target: isLoading ? 1 : 0).shake(
      curve: Curves.easeInOut,
      duration: 300.ms,
      hz: isLoading ? 10 : 0,
    );
  }
}

/// Neo-Brutalist Stat Card - Massive numbers, bold colors
class BrutalStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const BrutalStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = iconColor ?? NeoBrutalTheme.primary;
    final bgColor = backgroundColor ?? NeoBrutalTheme.surface;

    return BrutalCard(
      onTap: onTap,
      backgroundColor: bgColor,
      padding: const EdgeInsets.all(NeoBrutalTheme.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: defaultIconColor,
                  borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              if (onTap != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: NeoBrutalTheme.blockYellow,
                    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                    border: Border.all(
                      color: Colors.black,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: NeoBrutalTheme.spaceSM),
          Text(
            value,
            style: NeoBrutalTheme.displayLarge.copyWith(
              fontSize: 42,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: NeoBrutalTheme.spaceXS),
          Text(
            title.toUpperCase(),
            style: NeoBrutalTheme.labelMedium.copyWith(
              color: Colors.black87,
              letterSpacing: 2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: NeoBrutalTheme.spaceXS),
            Text(
              subtitle!,
              style: NeoBrutalTheme.bodySmall.copyWith(
                color: defaultIconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}

/// Neo-Brutalist Section Header - Bold and oversized
class BrutalSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final IconData? icon;
  final Color? backgroundColor;

  const BrutalSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? NeoBrutalTheme.blockYellow;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: NeoBrutalTheme.spaceMD,
        vertical: NeoBrutalTheme.spaceSM,
      ),
      padding: const EdgeInsets.all(NeoBrutalTheme.spaceMD),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: Colors.black,
          width: 4,
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: NeoBrutalTheme.spaceSM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: NeoBrutalTheme.headlineMedium.copyWith(
                    fontSize: 32,
                    letterSpacing: 2,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: NeoBrutalTheme.bodyMedium.copyWith(
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// Neo-Brutalist Action Chip - Bold and blocky
class BrutalActionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;

  const BrutalActionChip({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? (isSelected ? NeoBrutalTheme.primary : NeoBrutalTheme.surface);
    final txtColor = textColor ?? (isSelected ? Colors.white : Colors.black);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NeoBrutalTheme.spaceMD,
          vertical: NeoBrutalTheme.spaceSM,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          border: Border.all(
            color: Colors.black,
            width: isSelected ? 4 : 3,
          ),
          boxShadow: isSelected
              ? NeoBrutalTheme.chunkyShadow
              : NeoBrutalTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: txtColor),
              const SizedBox(width: NeoBrutalTheme.spaceXS),
            ],
            Text(
              label.toUpperCase(),
              style: NeoBrutalTheme.labelMedium.copyWith(
                color: txtColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      duration: 150.ms,
      curve: Curves.easeOut,
      begin: const Offset(1, 1),
      end: const Offset(0.95, 0.95),
    );
  }
}

/// Neo-Brutalist FAB - Floating Action Block
class BrutalFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Object? heroTag;

  const BrutalFab({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? NeoBrutalTheme.secondary;
    final txtColor = textColor ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
        border: Border.all(
          color: Colors.black,
          width: 4,
        ),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: FloatingActionButton.extended(
        heroTag: heroTag, // ✅ Unique hero tag
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Icon(icon, color: txtColor, size: 24),
        label: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: txtColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    ).animate().scale(
      duration: 200.ms,
      curve: Curves.elasticOut,
      begin: const Offset(0, 0),
      end: const Offset(1, 1),
    );
  }
}
