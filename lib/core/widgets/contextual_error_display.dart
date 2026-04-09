import 'package:flutter/material.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart';
import '../theme/app_theme.dart';
import 'modern_button.dart';

/// Error types for contextual error display
enum ErrorType { validation, notFound, database, unknown }

/// Contextual error display widget with auto-detection for AppException types
/// Shows appropriate icon, color, and actions based on error type
class ContextualErrorDisplay extends StatelessWidget {
  final Object error;
  final ErrorType type;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final String? customMessage;

  const ContextualErrorDisplay({
    required this.error,
    required this.type,
    this.onRetry,
    this.onBack,
    this.customMessage,
    super.key,
  });

  /// Auto-detect error type from AppException subtypes
  factory ContextualErrorDisplay.auto({
    required Object error,
    VoidCallback? onRetry,
    VoidCallback? onBack,
    String? customMessage,
  }) {
    ErrorType detectedType = ErrorType.unknown;

    if (error is ValidationException) {
      detectedType = ErrorType.validation;
    } else if (error is NotFoundException) {
      detectedType = ErrorType.notFound;
    } else if (error is DatabaseException) {
      detectedType = ErrorType.database;
    } else if (error is ConflictException) {
      detectedType = ErrorType.validation;
    } else if (error is InsufficientStockException) {
      detectedType = ErrorType.validation;
    } else if (error is EmptyCartException) {
      detectedType = ErrorType.validation;
    }

    return ContextualErrorDisplay(
      error: error,
      type: detectedType,
      onRetry: onRetry,
      onBack: onBack,
      customMessage: customMessage,
    );
  }

  IconData get _icon {
    switch (type) {
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.database:
        return Icons.storage;
      case ErrorType.unknown:
        return Icons.error;
    }
  }

  Color get _color {
    switch (type) {
      case ErrorType.validation:
        return AppTheme.errorColor;
      case ErrorType.notFound:
        return AppTheme.infoColor;
      case ErrorType.database:
        return AppTheme.errorColor;
      case ErrorType.unknown:
        return AppTheme.errorColor;
    }
  }

  String get _message {
    if (customMessage != null) return customMessage!;
    if (error is AppException) return (error as AppException).userMessage;

    switch (type) {
      case ErrorType.validation:
        return 'Periksa input Anda';
      case ErrorType.notFound:
        return 'Data tidak ditemukan';
      case ErrorType.database:
        return 'Terjadi kesalahan database';
      case ErrorType.unknown:
        return 'Terjadi kesalahan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 64, color: _color),
            const SizedBox(height: 16),
            Text(
              _message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (error is AppException && error is! ValidationException) ...[
              const SizedBox(height: 8),
              Text(
                (error as AppException).message,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onBack != null)
                  OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                  ),
                if (onBack != null && onRetry != null)
                  const SizedBox(width: 12),
                if (onRetry != null)
                  ModernButton(
                    text: 'Coba Lagi',
                    icon: Icons.refresh,
                    onPressed: onRetry,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
