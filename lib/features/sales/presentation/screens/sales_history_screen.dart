import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_status.dart';
import '../controllers/sales_history_controller.dart';
import '../controllers/refund_controller.dart';
import '../widgets/refund_confirmation_dialog.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../shared/presentation/main_navigation.dart';

/// Modern Material 3 screen showing sales history with filters
class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<SalesHistoryController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
                mainNavState?.openDrawer();
              },
            ),
            title: const Text('Riwayat Penjualan'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context, controller),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.refresh,
              ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppTheme.darkSurface,
                          AppTheme.darkSurface.withValues(alpha: 0.95),
                        ]
                      : [
                          AppTheme.primaryColor,
                          AppTheme.primaryLight,
                        ],
                ),
              ),
            ),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Summary Cards
                    _buildSummaryCards(context, controller),
                    const Divider(height: 1),

                    // Search Bar
                    _buildSearchBar(context, controller),
                    const Divider(height: 1),

                    // Transactions List
                    Expanded(
                      child: controller.filteredTransactions.isEmpty
                          ? _buildEmptyState(controller)
                          : _buildTransactionsList(controller),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, SalesHistoryController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.getCardColor(context),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 160,
            child: _buildCompactSummaryCard(
              context,
              title: 'Total Transaksi',
              value: '${controller.transactionCount}',
              icon: Icons.receipt_long,
              color: AppTheme.infoColor,
            ),
          ),
          SizedBox(
            width: 160,
            child: _buildCompactSummaryCard(
              context,
              title: 'Total Pendapatan',
              value: CurrencyFormatter.format(controller.totalRevenue),
              icon: Icons.payments,
              color: AppTheme.successColor,
            ),
          ),
          SizedBox(
            width: 160,
            child: _buildCompactSummaryCard(
              context,
              title: 'Total Profit',
              value: CurrencyFormatter.format(controller.totalProfit),
              icon: Icons.account_balance_wallet,
              color: AppTheme.secondaryColor,
            ),
          ),
          SizedBox(
            width: 160,
            child: _buildCompactSummaryCard(
              context,
              title: 'Total Item Terjual',
              value: '${controller.totalItemsSold}',
              icon: Icons.inventory_2_outlined,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Title row - more compact
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Value - more compact but still prominent
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, SalesHistoryController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari transaksi...',
          hintStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 15,
          ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () {
                    controller.setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // Rounded search bar
            borderSide: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: const Color(0xFFF1F5F9), // Light grey filled background
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        onChanged: (value) {
          controller.setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildEmptyState(SalesHistoryController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.isNotEmpty || controller.selectedPaymentMethod != null
                ? 'Coba ubah filter atau pencarian'
                : 'Mulai transaksi untuk melihat riwayat',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(SalesHistoryController controller) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppTheme.primaryColor,
      displacement: 80,
      strokeWidth: 3,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 140, // Space for floating nav
        ),
        itemCount: controller.filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = controller.filteredTransactions[index];
          return _buildTransactionCard(context, transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    final isRefundable = transaction.isRefundable;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Modern Material 3
        side: BorderSide(
          color: transaction.paymentStatus == PaymentStatus.refunded
              ? AppTheme.textTertiary.withValues(alpha: 0.5)
              : AppTheme.getBorderColor(context),
          width: 0.5,
        ),
      ),
      elevation: 0,
      color: transaction.paymentStatus == PaymentStatus.refunded
          ? AppTheme.textTertiary.withValues(alpha: 0.05)
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPaymentColor(transaction.paymentMethod).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPaymentIcon(transaction.paymentMethod),
              color: _getPaymentColor(transaction.paymentMethod),
              size: 20,
            ),
          ),
          title: Text(
            'Transaksi #${transaction.id}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: transaction.paymentStatus == PaymentStatus.refunded
                  ? AppTheme.textTertiary
                  : null,
              decoration: transaction.paymentStatus == PaymentStatus.refunded
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                _formatDate(transaction.transactionDate),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${transaction.totalItems} item',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(transaction.totalAmount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: transaction.paymentStatus == PaymentStatus.refunded
                      ? AppTheme.textTertiary
                      : AppTheme.primaryColor,
                  decoration: transaction.paymentStatus == PaymentStatus.refunded
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusBadge(transaction.paymentStatus),
            ],
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item Pembelian:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ...transaction.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.productName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: transaction.paymentStatus == PaymentStatus.refunded
                                      ? AppTheme.textTertiary
                                      : null,
                                ),
                              ),
                            ),
                            Text(
                              '${item.quantity}x ${CurrencyFormatter.format(item.unitPrice)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: transaction.paymentStatus == PaymentStatus.refunded
                                    ? AppTheme.textTertiary
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              CurrencyFormatter.format(item.subtotal),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: transaction.paymentStatus == PaymentStatus.refunded
                                    ? AppTheme.textTertiary
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildTotalsRow('Subtotal', transaction.subtotal),
                  if (transaction.tax > 0) _buildTotalsRow('Pajak', transaction.tax),
                  if (transaction.discount > 0) _buildTotalsRow('Diskon', -transaction.discount),
                  _buildTotalsRow(
                    'Total',
                    transaction.totalAmount,
                    isBold: true,
                  ),

                  // Refund button
                  if (isRefundable) ...[
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleRefund(context, transaction),
                        icon: const Icon(Icons.assignment_return, size: 18),
                        label: const Text('Refund Transaksi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.warningColor,
                          side: BorderSide(color: AppTheme.warningColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Refund tersedia dalam 30 hari setelah transaksi',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Refunded indicator
                  if (transaction.paymentStatus == PaymentStatus.refunded) ...[
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.textTertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.textTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Transaksi ini telah di-refund',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case PaymentStatus.completed: // Selesai
        bgColor = AppTheme.successColor.withValues(alpha: 0.15); // Light green
        textColor = AppTheme.successColor; // Dark green
        break;
      case PaymentStatus.pending: // Pending
        bgColor = AppTheme.warningColor.withValues(alpha: 0.15);
        textColor = AppTheme.warningColor;
        break;
      case PaymentStatus.cancelled: // Batal
        bgColor = AppTheme.errorColor.withValues(alpha: 0.15);
        textColor = AppTheme.errorColor;
        break;
      case PaymentStatus.refunded: // Refund
        bgColor = AppTheme.textTertiary.withValues(alpha: 0.15);
        textColor = AppTheme.textTertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12), // Rounded pill shape
      ),
      child: Text(
        status.displayNameId,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTotalsRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppTheme.primaryColor : null,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, SalesHistoryController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
        ),
        title: const Text('Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Metode Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Semua', style: TextStyle(fontSize: 13)),
                  selected: controller.selectedPaymentMethod == null,
                  onSelected: (selected) {
                    controller.setPaymentMethodFilter(null);
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
                  ),
                ),
                ...PaymentMethod.values.map((method) {
                  return FilterChip(
                    label: Text(method.displayNameId, style: const TextStyle(fontSize: 13)),
                    selected: controller.selectedPaymentMethod == method,
                    onSelected: (selected) {
                      controller.setPaymentMethodFilter(selected ? method : null);
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Rentang Tanggal:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, controller, true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(controller.startDate == null
                        ? 'Dari'
                        : '${controller.startDate!.day}/${controller.startDate!.month}/${controller.startDate!.year}'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, controller, false),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(controller.endDate == null
                        ? 'Sampai'
                        : '${controller.endDate!.day}/${controller.endDate!.month}/${controller.endDate!.year}'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (controller.startDate != null || controller.endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: () {
                    controller.setDateRangeFilter(null, null);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Hapus Filter Tanggal'),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, SalesHistoryController controller, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      if (isStartDate) {
        controller.setDateRangeFilter(picked, controller.endDate);
      } else {
        controller.setDateRangeFilter(controller.startDate, picked);
      }
    }
  }

  Color _getPaymentColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return AppTheme.successColor; // Green
      case PaymentMethod.card:
        return AppTheme.infoColor; // Blue
      case PaymentMethod.qr:
        return AppTheme.primaryColor; // Indigo/Purple
      case PaymentMethod.transfer:
        return AppTheme.warningColor; // Orange
    }
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleRefund(BuildContext context, Transaction transaction) async {
    // Show confirmation dialog
    final confirmed = await showRefundConfirmationDialog(
      context: context,
      transaction: transaction,
    );

    if (confirmed != true || !context.mounted) return;

    // Get controllers
    final refundController = context.read<RefundController>();
    final historyController = context.read<SalesHistoryController>();

    // Process refund
    final success = await refundController.refundTransaction(transaction.id!);

    if (!context.mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaksi berhasil di-refund'),
          backgroundColor: AppTheme.successColor,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      // Refresh transactions
      historyController.refresh();
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            refundController.errorMessage ?? 'Gagal melakukan refund',
          ),
          backgroundColor: AppTheme.errorColor,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              refundController.clearError();
            },
          ),
        ),
      );
    }
  }
}
