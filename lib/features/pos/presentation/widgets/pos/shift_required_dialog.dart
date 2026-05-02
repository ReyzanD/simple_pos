import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/features/shifts/presentation/screens/shift_open_screen.dart';

/// Dialog shown when a shift is required but none is active
class ShiftRequiredDialog extends StatelessWidget {
  const ShiftRequiredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ShiftRequiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return;
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.storefront,
                color: AppTheme.warningColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Shift Belum Dibuka')),
          ],
        ),
        content: const Text(
          'Anda perlu membuka shift kerja sebelum dapat melakukan transaksi.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShiftOpenScreen()),
              ).then((result) {
                if (result == true && context.mounted) {
                  Navigator.pop(context);
                } else if (context.mounted) {
                  Navigator.pop(context);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Buka Shift'),
          ),
        ],
      ),
    );
  }
}
