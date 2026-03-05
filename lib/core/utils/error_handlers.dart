import 'package:flutter/material.dart';
import '../exceptions/app_exceptions.dart';

/// Helper utilities for error handling
/// Reduces code duplication across the app
class ErrorHandlers {
  /// Shows error dialog with optional retry action
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String message,
    String title = 'Error',
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Coba Lagi'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String message,
    String title = 'Konfirmasi',
    String confirmText = 'Ya',
    String cancelText = 'Batal',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Shows success dialog
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String message,
    String title = 'Berhasil',
    VoidCallback? onOk,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOk?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Shows loading dialog
  static Future<void> showLoadingDialog({
    required BuildContext context,
    String message = 'Memuat...',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  /// Handles exceptions and shows appropriate error message
  static void handleException({
    required BuildContext context,
    required Object exception,
    StackTrace? stackTrace,
    VoidCallback? onRetry,
  }) {
    String title = 'Error';
    String message = 'Terjadi kesalahan yang tidak terduga';

    if (exception is ValidationException) {
      title = 'Validasi Error';
      message = exception.message;
    } else if (exception is NotFoundException) {
      title = 'Not Found';
      message = exception.message;
    } else if (exception is InsufficientStockException) {
      title = 'Stok Tidak Mencukupi';
      message = exception.message;
    } else if (exception is DatabaseException) {
      title = 'Database Error';
      message = exception.message;
    } else if (exception is EmptyCartException) {
      title = 'Keranjang Kosong';
      message = exception.message;
    }

    showErrorDialog(
      context: context,
      title: title,
      message: message,
      onRetry: onRetry,
    );
  }

  /// Shows snackbar with error message
  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
      ),
    );
  }

  /// Shows snackbar with success message
  static void showSuccessSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        action: action != null
            ? SnackBarAction(
                label: 'UNDO',
                textColor: Colors.white,
                onPressed: action,
              )
            : null,
      ),
    );
  }
}

/// Extension on BuildContext for easier error handling
extension BuildContextErrorExtensions on BuildContext {
  Future<void> showError({
    required String message,
    String title = 'Error',
    VoidCallback? onRetry,
  }) {
    return ErrorHandlers.showErrorDialog(
      context: this,
      message: message,
      title: title,
      onRetry: onRetry,
    );
  }

  Future<bool?> showConfirm({
    required String message,
    String title = 'Konfirmasi',
    String confirmText = 'Ya',
    String cancelText = 'Batal',
  }) {
    return ErrorHandlers.showConfirmationDialog(
      context: this,
      message: message,
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  void showSuccess({
    required String message,
    String title = 'Berhasil',
    VoidCallback? onOk,
  }) {
    ErrorHandlers.showSuccessDialog(
      context: this,
      message: message,
      title: title,
      onOk: onOk,
    );
  }

  void showErrorSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ErrorHandlers.showErrorSnackBar(
      context: this,
      message: message,
      duration: duration,
    );
  }

  void showSuccessSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? action,
  }) {
    ErrorHandlers.showSuccessSnackBar(
      context: this,
      message: message,
      duration: duration,
      action: action,
    );
  }
}
