import 'package:flutter/material.dart';
import '../../../../core/constants/ui_constants.dart';

/// Dialog for confirming product deletion
class DeleteConfirmationDialog extends StatelessWidget {
  final String productName;
  final VoidCallback onDelete;

  const DeleteConfirmationDialog({
    super.key,
    required this.productName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Produk'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            size: 48,
            color: Colors.orange.shade700,
          ),
          const SizedBox(height: UIConstants.spacingMedium),
          Text(
            'Apakah Anda yakin ingin menghapus produk ini?',
            style: const TextStyle(fontSize: UIConstants.fontSizeMedium),
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            productName,
            style: const TextStyle(
              fontSize: UIConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.spacingSmall),
          Text(
            'Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              fontSize: UIConstants.fontSizeSmall,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Hapus'),
        ),
      ],
    );
  }
}
