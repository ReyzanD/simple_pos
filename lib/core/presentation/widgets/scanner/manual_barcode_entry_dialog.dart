import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';

/// Manual barcode entry dialog
class ManualBarcodeEntryDialog extends StatelessWidget {
  const ManualBarcodeEntryDialog({super.key});

  static Future<String?> show(BuildContext context) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enter Barcode Manually'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Barcode',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.barcode_reader),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final barcode = controller.text.trim();
              if (barcode.isNotEmpty) {
                Navigator.pop(dialogContext, barcode);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError('Use ManualBarcodeEntryDialog.show() instead');
  }
}
