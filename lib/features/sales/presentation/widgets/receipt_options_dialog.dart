import 'package:flutter/material.dart';
import '../../domain/entities/receipt.dart';
import '../../../../core/services/receipt_service.dart';
import '../../../../core/constants/ui_constants.dart';

/// Dialog showing receipt options after successful checkout
class ReceiptOptionsDialog extends StatefulWidget {
  final Receipt receipt;
  final VoidCallback? onNewSale;

  const ReceiptOptionsDialog({
    super.key,
    required this.receipt,
    this.onNewSale,
  });

  @override
  State<ReceiptOptionsDialog> createState() => _ReceiptOptionsDialogState();
}

class _ReceiptOptionsDialogState extends State<ReceiptOptionsDialog> {
  final ReceiptService _receiptService = ReceiptService();
  bool _isLoading = false;
  String? _successMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: UIConstants.spacingMedium),

            // Success Message
            Text(
              'Checkout Berhasil!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingSmall),

            Text(
              'Transaksi #${widget.receipt.transaction.id}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingMedium),

            // Total Amount
            Container(
              padding: const EdgeInsets.all(UIConstants.paddingMedium),
              decoration: BoxDecoration(
                color: UIConstants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: UIConstants.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingSmall),
                  Text(
                    _formatCurrency(widget.receipt.transaction.totalAmount),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: UIConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Success Message (if any)
            if (_successMessage != null) ...[
              const SizedBox(height: UIConstants.spacingMedium),
              Container(
                padding: const EdgeInsets.all(UIConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: UIConstants.spacingSmall),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(
                          color: Colors.green.shade900,
                          fontSize: UIConstants.fontSizeSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: UIConstants.spacingLarge),

            // Receipt Options
            Text(
              'Pilih Aksi Struk:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingMedium),

            // Print Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handlePrint,
                icon: const Icon(Icons.print),
                label: const Text('Cetak Struk'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                  backgroundColor: UIConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingSmall),

            // Share Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleShare,
                icon: const Icon(Icons.share),
                label: const Text('Bagikan Struk'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingSmall),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleClose,
                icon: const Icon(Icons.close),
                label: Text(widget.onNewSale != null ? 'Transaksi Baru' : 'Tutup'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Simple currency formatter
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  Future<void> _handlePrint() async {
    setState(() => _isLoading = true);

    try {
      await _receiptService.printReceipt(widget.receipt);
      if (mounted) {
        setState(() {
          _successMessage = 'Struk berhasil dicetak';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Gagal mencetak struk: $e');
      }
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isLoading = true);

    try {
      await _receiptService.shareReceipt(widget.receipt);
      if (mounted) {
        setState(() {
          _successMessage = 'Struk berhasil dibagikan';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Gagal membagikan struk: $e');
      }
    }
  }

  void _handleClose() {
    Navigator.of(context).pop();
    widget.onNewSale?.call();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Shows the receipt options dialog
Future<void> showReceiptOptionsDialog({
  required BuildContext context,
  required Receipt receipt,
  VoidCallback? onNewSale,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ReceiptOptionsDialog(
      receipt: receipt,
      onNewSale: onNewSale,
    ),
  );
}
