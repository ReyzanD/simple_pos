import 'package:flutter/material.dart';
import '../theme/enhanced_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Enhanced button system for professional yet friendly interactions
///
/// Features:
/// - Generous touch targets (min 44x44 for accessibility)
/// - Satisfying micro-animations
/// - Clear visual hierarchy
/// - Sophisticated shadows and gradients
/// - Professional color usage

/// Primary button with gradient and subtle shadow
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? EnhancedTheme.primary;
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 52, // Generous touch target
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: EnhancedTheme.spacingLG,
            vertical: EnhancedTheme.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EnhancedTheme.radiusMedium),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: EnhancedTheme.spacingXS),
                  ],
                  Text(
                    text,
                    style: EnhancedTheme.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

/// Secondary button with subtle border
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bColor = borderColor ?? EnhancedTheme.primary;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: bColor,
          side: BorderSide(
            color: bColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: EnhancedTheme.spacingLG,
            vertical: EnhancedTheme.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EnhancedTheme.radiusMedium),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: EnhancedTheme.spacingXS),
            ],
            Text(
              text,
              style: EnhancedTheme.labelLarge.copyWith(
                color: bColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

/// Icon button with generous touch target and subtle animation
class EnhancedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const EnhancedIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? EnhancedTheme.primary.withValues(alpha: 0.1);
    final icColor = iconColor ?? EnhancedTheme.primary;
    final btnSize = size ?? 44.0; // Minimum touch target

    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: btnSize,
        height: btnSize,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(EnhancedTheme.radiusSmall),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(EnhancedTheme.radiusSmall),
            child: Icon(
              icon,
              color: icColor,
              size: 20,
            ),
          ),
        ),
      ),
    ).animate(target: onTap != null ? 1 : 0).scale(
      duration: 150.ms,
      curve: Curves.easeOut,
      begin: const Offset(1, 1),
      end: const Offset(0.95, 0.95),
    );
  }
}

/// Action chip for quick actions
class EnhancedActionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const EnhancedActionChip({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? EnhancedTheme.surfaceVariant;
    final txtColor = textColor ?? EnhancedTheme.getTextColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EnhancedTheme.spacingSM,
          vertical: EnhancedTheme.spacingXS,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(EnhancedTheme.radiusSmall),
          border: Border.all(
            color: EnhancedTheme.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: txtColor),
              const SizedBox(width: EnhancedTheme.spacingXXS),
            ],
            Text(
              label,
              style: EnhancedTheme.labelMedium.copyWith(
                color: txtColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

/// Floating action button with enhanced styling
class EnhancedFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Object? heroTag;

  const EnhancedFab({
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
    final txtColor = textColor ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor != null
            ? LinearGradient(colors: [backgroundColor!, backgroundColor!])
            : EnhancedTheme.primaryGradient,
        borderRadius: BorderRadius.circular(EnhancedTheme.radiusXLarge),
        boxShadow: EnhancedTheme.primaryGlow(context),
      ),
      child: FloatingActionButton.extended(
        heroTag: heroTag, // ✅ Unique hero tag
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Icon(icon, color: txtColor),
        label: Text(
          label,
          style: EnhancedTheme.labelLarge.copyWith(
            color: txtColor,
            fontWeight: FontWeight.w600,
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

/// Danger button for destructive actions
class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: EnhancedTheme.error.withValues(alpha: 0.1),
          foregroundColor: EnhancedTheme.error,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: EnhancedTheme.spacingLG,
            vertical: EnhancedTheme.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EnhancedTheme.radiusMedium),
            side: BorderSide(
              color: EnhancedTheme.error.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: EnhancedTheme.spacingXS),
            ],
            Text(
              text,
              style: EnhancedTheme.labelLarge.copyWith(
                color: EnhancedTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success button for confirmation actions
class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  const SuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: EnhancedTheme.success,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: EnhancedTheme.spacingLG,
            vertical: EnhancedTheme.spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EnhancedTheme.radiusMedium),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(Icons.check_rounded, size: 18),
              const SizedBox(width: EnhancedTheme.spacingXS),
            ],
            Text(
              text,
              style: EnhancedTheme.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
      duration: 200.ms,
      curve: Curves.elasticOut,
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
    );
  }
}
