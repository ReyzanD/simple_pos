import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_card.dart';
import 'package:intl/intl.dart';
import 'cash_count_screen.dart';

/// Screen for closing an active cashier shift
class ShiftCloseScreen extends ConsumerStatefulWidget {
  const ShiftCloseScreen({super.key});

  @override
  ConsumerState<ShiftCloseScreen> createState() => _ShiftCloseScreenState();
}

class _ShiftCloseScreenState extends ConsumerState<ShiftCloseScreen> {
  final _closingBalanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _closingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _handleCloseShift() async {
    final controller = ref.read(shiftControllerProvider);
    final shift = controller.currentShift;

    if (shift == null) {
      return;
    }

    // Navigate to cash count screen first
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CashCountScreen(
          shiftId: shift.id!,
          expectedAmount: shift.expectedClosingBalance,
        ),
      ),
    );

    // Only close shift if cash count was saved
    if (result == true && mounted) {
      // Proceed with shift close
      final closingBalance = _closingBalanceController.text.isEmpty
          ? 0.0
          : double.parse(_closingBalanceController.text);

      final success = await controller.closeShift(
        closingBalance: closingBalance,
      );

      if (mounted && success) {
        Navigator.pop(context, true);
      }
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(shiftControllerProvider);
    final shift = controller.currentShift;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Tutup Shift'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: () {

            if (shift == null) {
              return const Center(
                child: Text('Tidak ada shift aktif'),
              );
            }

            if (controller.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.error?.userMessage ?? 'Terjadi kesalahan'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                controller.clearError();
              });
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            size: 40,
                            color: AppTheme.warningColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Tutup Shift Kerja',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Kasir: ${shift.userName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Dibuka: ${_formatDate(shift.openedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Summary cards
                        Row(
                          children: [
                            Expanded(
                              child: ModernStatCard(
                                title: 'Modal Awal',
                                value: _formatCurrency(shift.openingBalance),
                                icon: Icons.money_off,
                                iconColor: AppTheme.infoColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ModernStatCard(
                                title: 'Penjualan',
                                value: _formatCurrency(shift.totalSales),
                                icon: Icons.shopping_cart,
                                iconColor: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: ModernStatCard(
                                title: 'Transaksi',
                                value: '${shift.totalTransactions}',
                                icon: Icons.receipt,
                                iconColor: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ModernStatCard(
                                title: 'Tunai',
                                value: _formatCurrency(shift.cashSales),
                                icon: Icons.payments_outlined,
                                iconColor: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Payment method breakdown
                        ModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Metode Pembayaran',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildPaymentRow('Tunai', shift.cashSales, AppTheme.successColor),
                              _buildPaymentRow('Kartu', shift.cardSales, AppTheme.infoColor),
                              _buildPaymentRow('QRIS', shift.qrSales, AppTheme.primaryColor),
                              _buildPaymentRow('Transfer', shift.transferSales, AppTheme.warningColor),
                              const Divider(height: 24),
                              _buildPaymentRow('Total', shift.totalSales, AppTheme.textPrimary, isBold: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Expected closing balance
                        ModernCard(
                          backgroundColor: AppTheme.infoColor.withValues(alpha: 0.05),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppTheme.infoColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saldo Akhir Diharapkan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(shift.expectedClosingBalance),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.infoColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Closing balance input
                        ModernCard(
                          child: TextFormField(
                            controller: _closingBalanceController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Hitung Uang di Laci',
                              hintText: 'Masukkan jumlah uang tunai',
                              prefixIcon: Icon(Icons.calculate),
                              border: InputBorder.none,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleCloseShift(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Jumlah uang wajib diisi';
                              }
                              final balance = double.tryParse(value);
                              if (balance == null || balance < 0) {
                                return 'Masukkan angka yang valid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Close button
                        ModernButton(
                          text: 'Tutup Shift',
                          icon: Icons.check,
                          onPressed: controller.isLoading ? null : _handleCloseShift,
                          isLoading: controller.isLoading,
                          backgroundColor: AppTheme.primaryColor,
                        ),

                        const SizedBox(height: 16),

                        // Cancel button
                        ModernSecondaryButton(
                          text: 'Batal',
                          icon: Icons.close,
                          onPressed: controller.isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
        }(),
      ),
    );
  }

  Widget _buildPaymentRow(String label, double value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
