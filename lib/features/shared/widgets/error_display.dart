import 'package:flutter/material.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Reusable widget for displaying error messages
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// Creates an error display from an AppException
  factory ErrorDisplay.fromException(
    AppException exception, {
    VoidCallback? onRetry,
    IconData icon = Icons.error_outline,
  }) {
    return ErrorDisplay(
      message: exception.userMessage,
      onRetry: onRetry,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: UIConstants.errorColor,
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: UIConstants.fontSizeMedium,
                color: Colors.grey,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: UIConstants.spacingLarge),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
