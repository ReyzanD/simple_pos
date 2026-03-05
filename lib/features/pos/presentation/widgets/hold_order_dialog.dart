import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../controllers/pos_controller.dart';
import '../../../../core/widgets/modern_button.dart';

/// Dialog for holding an order with customer name input
class HoldOrderDialog extends StatefulWidget {
  final POSController controller;

  const HoldOrderDialog({
    super.key,
    required this.controller,
  });

  @override
  State<HoldOrderDialog> createState() => _HoldOrderDialogState();
}

class _HoldOrderDialogState extends State<HoldOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _handleHoldOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customerName = _customerNameController.text.trim();
    final success = await widget.controller.holdCart(customerName);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan untuk $customerName berhasil ditahan'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (widget.controller.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.controller.error!.userMessage),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.pause_circle_outline,
            color: AppTheme.infoColor,
          ),
          const SizedBox(width: 12),
          const Text('Tahan Pesanan'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan nama pelanggan untuk pesanan ini:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan',
                hintText: 'Contoh: Budi Santoso',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama pelanggan wajib diisi';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (_formKey.currentState!.validate()) {
                  _handleHoldOrder();
                }
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.infoColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keranjang saat ini akan disimpan dan dapat dilanjutkan nanti',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        ModernButton(
          text: 'Tahan Pesanan',
          icon: Icons.pause,
          onPressed: _handleHoldOrder,
          backgroundColor: AppTheme.infoColor,
        ),
      ],
    );
  }
}

/// Show dialog to hold current order
Future<bool?> showHoldOrderDialog(
  BuildContext context,
  POSController controller,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => HoldOrderDialog(controller: controller),
  );
}

