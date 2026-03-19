import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Success toast notification service with preset methods
/// Provides branded toast notifications using AppTheme.successColor
class SuccessToastService {
  SuccessToastService._internal();

  static final SuccessToastService _instance = SuccessToastService._internal();
  static SuccessToastService get instance => _instance;

  /// Show a success toast notification
  ///
  /// [context] - BuildContext for showing SnackBar
  /// [message] - Message to display
  /// [icon] - Optional icon (defaults to check_circle)
  /// [duration] - How long to show the toast
  /// [actionLabel] - Optional action button text
  /// [onAction] - Callback for action button
  void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  /// Preset: Data saved successfully
  /// [itemName] - Optional name of the item that was saved
  void saved(BuildContext context, [String? itemName]) => show(
        context,
        itemName != null ? '$itemName berhasil disimpan' : 'Data berhasil disimpan',
      );

  /// Preset: Data deleted successfully
  /// [itemName] - Optional name of the item that was deleted
  void deleted(BuildContext context, [String? itemName]) => show(
        context,
        itemName != null ? '$itemName berhasil dihapus' : 'Data berhasil dihapus',
      );

  /// Preset: Data added successfully
  /// [itemName] - Optional name of the item that was added
  void added(BuildContext context, [String? itemName]) => show(
        context,
        itemName != null
            ? '$itemName berhasil ditambahkan'
            : 'Data berhasil ditambahkan',
      );

  /// Preset: Data updated successfully
  /// [itemName] - Optional name of the item that was updated
  void updated(BuildContext context, [String? itemName]) => show(
        context,
        itemName != null
            ? '$itemName berhasil diperbarui'
            : 'Data berhasil diperbarui',
      );
}
