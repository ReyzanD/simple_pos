import 'package:flutter/material.dart';
import '../theme/enhanced_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Enhanced card system for professional yet friendly UI
///
/// Features:
/// - Sophisticated shadow system
/// - Consistent border radius
/// - Subtle animations
/// - Clear visual hierarchy
/// - Generous spacing

/// Premium card with subtle shadow and smooth animations
class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool bordered;
  final double? width;
  final double? height;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.bordered = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = backgroundColor ?? EnhancedTheme.getCardColor(context);

    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(vertical: EnhancedTheme.spacingSM),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(EnhancedTheme.radiusLarge),
        border: bordered
            ? Border.all(
                color: EnhancedTheme.border.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
        boxShadow: onTap != null ? EnhancedTheme.mediumShadow : EnhancedTheme.subtleShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(EnhancedTheme.radiusLarge),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(EnhancedTheme.spacingMD),
            child: child,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.03, end: 0);
  }
}

/// Stat card for KPIs and metrics with professional styling
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = iconColor ?? EnhancedTheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? EnhancedTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(EnhancedTheme.radiusLarge),
        boxShadow: EnhancedTheme.subtleShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(EnhancedTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(EnhancedTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: defaultIconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(EnhancedTheme.radiusSmall),
                      ),
                      child: Icon(
                        icon,
                        color: defaultIconColor,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.chevron_right,
                        color: EnhancedTheme.getSecondaryTextColor(context),
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: EnhancedTheme.spacingSM),
                Text(
                  value,
                  style: EnhancedTheme.displaySmall.copyWith(
                    color: EnhancedTheme.getTextColor(context),
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: EnhancedTheme.spacingXXS),
                Text(
                  title,
                  style: EnhancedTheme.labelMedium.copyWith(
                    color: EnhancedTheme.getSecondaryTextColor(context),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: EnhancedTheme.spacingXXS),
                  Text(
                    subtitle!,
                    style: EnhancedTheme.bodySmall.copyWith(
                      color: defaultIconColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}

/// Section header with title and optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: EnhancedTheme.spacingMD,
        right: EnhancedTheme.spacingMD,
        bottom: EnhancedTheme.spacingSM,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: EnhancedTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(EnhancedTheme.radiusSmall),
              ),
              child: Icon(
                icon,
                color: EnhancedTheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: EnhancedTheme.spacingSM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: EnhancedTheme.headlineMedium.copyWith(
                    color: EnhancedTheme.getTextColor(context),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: EnhancedTheme.bodySmall.copyWith(
                      color: EnhancedTheme.getSecondaryTextColor(context),
                    ),
                  ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Grouped list tile with professional styling
class GroupedListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showDivider;

  const GroupedListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: leadingIcon != null
              ? Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconColor ?? EnhancedTheme.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(EnhancedTheme.radiusSmall),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: iconColor ?? EnhancedTheme.primary,
                    size: 18,
                  ),
                )
              : null,
          title: Text(
            title,
            style: EnhancedTheme.titleMedium.copyWith(
              color: EnhancedTheme.getTextColor(context),
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: EnhancedTheme.bodySmall.copyWith(
                    color: EnhancedTheme.getSecondaryTextColor(context),
                  ),
                )
              : null,
          trailing: trailing,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: EnhancedTheme.spacingMD,
            vertical: EnhancedTheme.spacingXS,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: EnhancedTheme.divider,
            indent: leadingIcon != null ? 68 : 16,
            endIndent: 16,
          ),
      ],
    );
  }
}

/// Info banner with icon and message
class InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onDismiss;

  const InfoBanner({
    super.key,
    required this.message,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? EnhancedTheme.info.withValues(alpha: 0.1);
    final icColor = iconColor ?? EnhancedTheme.info;
    final txtColor = textColor ?? EnhancedTheme.info;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: EnhancedTheme.spacingMD,
        vertical: EnhancedTheme.spacingXS,
      ),
      padding: const EdgeInsets.all(EnhancedTheme.spacingSM),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(EnhancedTheme.radiusMedium),
        border: Border.all(
          color: icColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: icColor, size: 20),
          const SizedBox(width: EnhancedTheme.spacingSM),
          Expanded(
            child: Text(
              message,
              style: EnhancedTheme.bodyMedium.copyWith(
                color: txtColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: txtColor.withValues(alpha: 0.6),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
