import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme.dart';

/// Dialog for confirming transaction refund
class RefundConfirmationDialog extends StatelessWidget {
  final Transaction transaction;

  const RefundConfirmationDialog({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.assignment_return,
              color: AppTheme.warningColor,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Konfirmasi Refund',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning message
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Stok produk akan dikembalikan ke inventory.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Transaction details
            _buildDetailRow(
              'No. Transaksi',
              '#${transaction.id}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Tanggal',
              '${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Metode Pembayaran',
              transaction.paymentMethod.displayNameId,
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // Items to be returned
            const Text(
              'Item yang Dikembalikan:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            ...transaction.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Stok +${item.quantity} unit',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Total refund amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Refund',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(transaction.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.warningColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: const Text('Konfirmasi Refund'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Shows refund confirmation dialog
/// Returns true if user confirms, false otherwise
Future<bool?> showRefundConfirmationDialog({
  required BuildContext context,
  required Transaction transaction,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => RefundConfirmationDialog(
      transaction: transaction,
    ),
  );
}
