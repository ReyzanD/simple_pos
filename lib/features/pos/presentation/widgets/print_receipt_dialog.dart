import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../sales/domain/entities/transaction.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../shifts/presentation/controllers/shift_controller.dart';
import '../../../shared/presentation/providers.dart';

/// Dialog for offering to print receipt after successful checkout
class PrintReceiptDialog extends ConsumerStatefulWidget {
  final Transaction transaction;
  final double? cashReceived;
  final double? change;

  const PrintReceiptDialog({
    super.key,
    required this.transaction,
    this.cashReceived,
    this.change,
  });

  /// Show the print receipt dialog
  static Future<void> show({
    required BuildContext context,
    required Transaction transaction,
    double? cashReceived,
    double? change,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrintReceiptDialog(
        transaction: transaction,
        cashReceived: cashReceived,
        change: change,
      ),
    );
  }

  @override
  ConsumerState<PrintReceiptDialog> createState() => _PrintReceiptDialogState();
}

class _PrintReceiptDialogState extends ConsumerState<PrintReceiptDialog> {
  bool _isPrinting = false;
  String? _errorMessage;
  final int _paperWidth = 58; // Default to 58mm
  final PrinterService _printerService = PrinterService();

  @override
  Widget build(BuildContext context) {
    final settingsController = ref.watch(settingsControllerProvider);
    final shiftController = ref.watch(shiftControllerProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 48,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Transaksi Berhasil!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'No. Transaksi: #${widget.transaction.id}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Total: ${settingsController.settings.currencySymbol} ${widget.transaction.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            // Printer connection status
            if (!_printerService.isConnected)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.print_disabled,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tidak ada printer terhubung. Hubungkan printer di Pengaturan untuk mencetak struk.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Print button
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Cetak Struk',
                icon: Icons.print,
                onPressed: (_printerService.isConnected && !_isPrinting)
                    ? () => _handlePrint(settingsController, shiftController)
                    : null,
                isFullWidth: true,
              ),
            ),

            const SizedBox(height: 12),

            // Skip button
            TextButton(
              onPressed: _isPrinting
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePrint(
    SettingsController settingsController,
    ShiftController shiftController,
  ) async {
    setState(() {
      _isPrinting = true;
      _errorMessage = null;
    });

    try {
      final result = await _printerService.printReceipt(
        transaction: widget.transaction,
        settings: settingsController.settings,
        shift: shiftController.currentShift,
        cashReceived: widget.cashReceived,
        change: widget.change,
        paperWidth: _paperWidth,
      );

      if (mounted) {
        if (result.success) {
          // Show success and close dialog
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Struk berhasil dicetak'),
                backgroundColor: AppTheme.successColor,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = result.errorMessage ?? 'Gagal mencetak struk';
            _isPrinting = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mencetak struk: $e';
          _isPrinting = false;
        });
      }
    }
  }
}
