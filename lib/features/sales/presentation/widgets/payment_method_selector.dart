import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/payment_method.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/ui_constants.dart';

/// Widget for selecting payment method and entering payment details
class PaymentMethodSelector extends StatefulWidget {
  final PaymentMethod initialMethod;
  final double totalAmount;
  final Function(PaymentMethod, {double? cashReceived, String? cardLast4Digits})
  onPaymentSelected;

  const PaymentMethodSelector({
    super.key,
    required this.initialMethod,
    required this.totalAmount,
    required this.onPaymentSelected,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  late PaymentMethod _selectedMethod;
  final TextEditingController _cashReceivedController = TextEditingController();
  final TextEditingController _cardDigitsController = TextEditingController();
  double? _changeAmount;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
    _cashReceivedController.text = widget.totalAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _cardDigitsController.dispose();
    super.dispose();
  }

  void _calculateChange(String value) {
    if (_selectedMethod == PaymentMethod.cash) {
      final cashReceived = double.tryParse(value);
      if (cashReceived != null && cashReceived >= widget.totalAmount) {
        setState(() {
          _changeAmount = cashReceived - widget.totalAmount;
        });
      } else {
        setState(() {
          _changeAmount = null;
        });
      }
    }
  }

  void _notifyPaymentChanged() {
    if (_selectedMethod == PaymentMethod.cash) {
      final cashReceived = double.tryParse(_cashReceivedController.text);
      widget.onPaymentSelected(_selectedMethod, cashReceived: cashReceived);
    } else if (_selectedMethod == PaymentMethod.card) {
      widget.onPaymentSelected(
        _selectedMethod,
        cardLast4Digits: _cardDigitsController.text,
      );
    } else {
      widget.onPaymentSelected(_selectedMethod);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Payment Method Selection
        Text(
          'Metode Pembayaran',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: UIConstants.spacingSmall),

        // Payment Method Radio Buttons
        ...PaymentMethod.values.map((method) {
          return RadioListTile<PaymentMethod>(
            title: Row(
              children: [
                Icon(_getPaymentIcon(method)),
                const SizedBox(width: UIConstants.spacingSmall),
                Text(method.displayNameId),
              ],
            ),
            value: method,
            groupValue: _selectedMethod,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedMethod = value;
                  _changeAmount = null;
                });
                _notifyPaymentChanged();
              }
            },
            activeColor: UIConstants.primaryColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: UIConstants.spacingSmall,
              vertical: 0,
            ),
          );
        }),

        // Payment Details
        const SizedBox(height: UIConstants.spacingMedium),
        _buildPaymentDetails(),

        // Change Display (for cash payments)
        if (_selectedMethod == PaymentMethod.cash && _changeAmount != null)
          Padding(
            padding: const EdgeInsets.only(top: UIConstants.spacingMedium),
            child: Container(
              padding: const EdgeInsets.all(UIConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kembalian:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: UIConstants.fontSizeMedium,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(_changeAmount!),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: UIConstants.fontSizeLarge,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uang Diterima',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UIConstants.spacingSmall),
            TextField(
              controller: _cashReceivedController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah uang',
                prefixText: 'Rp ',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _calculateChange,
              onEditingComplete: _notifyPaymentChanged,
            ),
            if (_changeAmount == null &&
                _cashReceivedController.text.isNotEmpty &&
                (double.tryParse(_cashReceivedController.text) ?? 0) <
                    widget.totalAmount)
              Padding(
                padding: const EdgeInsets.only(top: UIConstants.spacingSmall),
                child: Text(
                  'Jumlah uang kurang dari total',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: UIConstants.fontSizeSmall,
                  ),
                ),
              ),
          ],
        );

      case PaymentMethod.card:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '4 Digit Terakhir Kartu (Opsional)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UIConstants.spacingSmall),
            TextField(
              controller: _cardDigitsController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                hintText: '****',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
              onEditingComplete: _notifyPaymentChanged,
            ),
          ],
        );

      case PaymentMethod.qr:
        return Container(
          padding: const EdgeInsets.all(UIConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
            border: Border.all(color: Colors.blue.shade300),
          ),
          child: Column(
            children: [
              Icon(Icons.qr_code_2, size: 80, color: Colors.blue.shade700),
              const SizedBox(height: UIConstants.spacingMedium),
              Text(
                'Scan QRIS untuk pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.spacingSmall),
              Text(
                'Total: ${CurrencyFormatter.format(widget.totalAmount)}',
                style: TextStyle(
                  fontSize: UIConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        );

      case PaymentMethod.transfer:
        return Container(
          padding: const EdgeInsets.all(UIConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.orange.shade700),
                  const SizedBox(width: UIConstants.spacingSmall),
                  Text(
                    'Informasi Transfer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                      fontSize: UIConstants.fontSizeMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              _buildInfoRow('Bank', 'BCA'),
              _buildInfoRow('Nomor Rekening', '123-456-7890'),
              _buildInfoRow('Atas Nama', 'Toko POS'),
              const Divider(height: UIConstants.spacingLarge),
              _buildInfoRow(
                'Total',
                CurrencyFormatter.format(widget.totalAmount),
                isBold: true,
              ),
            ],
          ),
        );
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.orange.shade900 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.qr:
        return Icons.qr_code_2;
      case PaymentMethod.transfer:
        return Icons.account_balance;
    }
  }
}
