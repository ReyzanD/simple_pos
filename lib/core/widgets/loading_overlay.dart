import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Full-screen or contained loading overlay with optional message
/// Theme-aware (works with light/dark mode)
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const LoadingOverlay({
    this.message,
    this.isFullScreen = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isFullScreen
          ? AppTheme.getBackgroundColor(context).withValues(alpha: 0.8)
          : Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 3,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  color: AppTheme.getTextPrimaryColor(context),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
