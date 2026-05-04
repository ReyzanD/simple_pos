import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/usecases/generate_receipt_usecase.dart';
import '../controllers/sales_history_controller.dart';
import '../widgets/refund_confirmation_dialog.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../../../../core/widgets/brutal_inputs.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Modern Material 3 screen showing sales history with filters
class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.watch(salesHistoryControllerProvider);
        final borderColor = NeoBrutalTheme.getBorderColor(context);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                context
                    .findAncestorStateOfType<MainNavigationState>()
                    ?.openDrawer();
              },
            ),
            title: Text(AppLocalizations.of(context)!.sales_riwayat),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: NeoBrutalTheme.spaceXS),
                child: Container(
                  decoration: BoxDecoration(
                    color: NeoBrutalTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      NeoBrutalTheme.radiusSmall,
                    ),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: NeoBrutalTheme.secondary,
                    ),
                    tooltip: AppLocalizations.of(context)!.common_filter,
                    onPressed: () => _showFilterDialog(context, controller),
                  ),
                ),
              ),
            ],
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
                          ? _buildEmptyState(context, controller)
                          : _buildTransactionsList(ref, controller),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    SalesHistoryController controller,
  ) {
    final cardColor = NeoBrutalTheme.getCardColor(context);
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      color: cardColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCompactStatCard(
              context: context,
              title: AppLocalizations.of(context)!.sales_total_transactions,
              value: '${controller.transactionCount}',
              icon: Icons.receipt_long,
              iconColor: NeoBrutalTheme.primary,
            ),
            SizedBox(width: NeoBrutalTheme.spaceMD),
            _buildCompactStatCard(
              context: context,
              title: AppLocalizations.of(context)!.sales_total_revenue,
              value: CurrencyFormatter.format(controller.totalRevenue),
              icon: Icons.payments,
              iconColor: NeoBrutalTheme.success,
            ),
            SizedBox(width: NeoBrutalTheme.spaceMD),
            _buildCompactStatCard(
              context: context,
              title: AppLocalizations.of(context)!.sales_total_profit,
              value: CurrencyFormatter.format(controller.totalProfit),
              icon: Icons.account_balance_wallet,
              iconColor: NeoBrutalTheme.secondary,
            ),
            SizedBox(width: NeoBrutalTheme.spaceMD),
            _buildCompactStatCard(
              context: context,
              title: AppLocalizations.of(context)!.sales_total_items_sold,
              value: '${controller.totalItemsSold}',
              icon: Icons.inventory_2_outlined,
              iconColor: NeoBrutalTheme.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final textColor = NeoBrutalTheme.getTextColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    return Container(
      width: 140,
      padding: EdgeInsets.all(NeoBrutalTheme.spaceSM),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(
                    NeoBrutalTheme.radiusSmall,
                  ),
                  border: Border.all(color: borderColor, width: 3),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ],
          ),
          SizedBox(height: NeoBrutalTheme.spaceXS),
          Text(
            value,
            style: NeoBrutalTheme.displayLarge.copyWith(
              fontSize: 24,
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: NeoBrutalTheme.spaceXS),
          Text(
            title.toUpperCase(),
            style: NeoBrutalTheme.labelSmall.copyWith(
              color: secondaryTextColor,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    SalesHistoryController controller,
  ) {
    return Padding(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceMD),
      child: BrutalSearchField(
        hint: AppLocalizations.of(context)!.sales_search,
        controller: TextEditingController(text: controller.searchQuery),
        onChanged: (value) => controller.setSearchQuery(value),
        backgroundColor: NeoBrutalTheme.getCardColor(context),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    SalesHistoryController controller,
  ) {
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    final tertiaryTextColor = NeoBrutalTheme.getTertiaryTextColor(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: tertiaryTextColor),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.sales_no_transactions,
            style: TextStyle(
              fontSize: 18,
              color: secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.isNotEmpty ||
                    controller.selectedPaymentMethod != null
                ? AppLocalizations.of(context)!.sales_no_data_found
                : AppLocalizations.of(context)!.empty_state_get_started,
            style: TextStyle(fontSize: 14, color: tertiaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    WidgetRef ref,
    SalesHistoryController controller,
  ) {
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
          return _buildTransactionCard(context, ref, transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) {
    final isRefundable = transaction.isRefundable;
    final textColor = NeoBrutalTheme.getTextColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);
    final tertiaryTextColor = NeoBrutalTheme.getTertiaryTextColor(context);
    final cardColor = NeoBrutalTheme.getCardColor(context);
    final borderColor = NeoBrutalTheme.getBorderColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: transaction.paymentStatus == PaymentStatus.refunded
              ? tertiaryTextColor.withValues(alpha: 0.3)
              : borderColor,
          width: 0.5,
        ),
      ),
      elevation: 0,
      color: transaction.paymentStatus == PaymentStatus.refunded
          ? tertiaryTextColor.withValues(alpha: 0.05)
          : cardColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPaymentColor(
                transaction.paymentMethod,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPaymentIcon(transaction.paymentMethod),
              color: _getPaymentColor(transaction.paymentMethod),
              size: 20,
            ),
          ),
          title: Text(
            '${AppLocalizations.of(context)!.sales_transaction} #${transaction.id}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: transaction.paymentStatus == PaymentStatus.refunded
                  ? tertiaryTextColor
                  : textColor,
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
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              Text(
                '${transaction.totalItems} ${AppLocalizations.of(context)!.sales_items}',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
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
                      ? tertiaryTextColor
                      : NeoBrutalTheme.primary,
                  decoration:
                      transaction.paymentStatus == PaymentStatus.refunded
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusBadge(transaction.paymentStatus, context),
            ],
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (transaction.cashierName != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${AppLocalizations.of(context)!.sales_cashier_colon} ${transaction.cashierName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    AppLocalizations.of(context)!.sales_purchase_items,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...transaction.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    transaction.paymentStatus ==
                                        PaymentStatus.refunded
                                    ? tertiaryTextColor
                                    : textColor,
                              ),
                            ),
                          ),
                          Text(
                            '${item.quantity}x ${CurrencyFormatter.format(item.unitPrice)}',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  transaction.paymentStatus ==
                                      PaymentStatus.refunded
                                  ? tertiaryTextColor
                                  : textColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            CurrencyFormatter.format(item.subtotal),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color:
                                  transaction.paymentStatus ==
                                      PaymentStatus.refunded
                                  ? tertiaryTextColor
                                  : textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildTotalsRow(
                    AppLocalizations.of(context)!.receipt_subtotal,
                    transaction.subtotal,
                    context: context,
                  ),
                  if (transaction.tax > 0)
                    _buildTotalsRow(
                      AppLocalizations.of(context)!.receipt_tax,
                      transaction.tax,
                      context: context,
                    ),
                  if (transaction.discount > 0)
                    _buildTotalsRow(
                      AppLocalizations.of(context)!.receipt_discount,
                      -transaction.discount,
                      context: context,
                    ),
                  _buildTotalsRow(
                    AppLocalizations.of(context)!.receipt_total,
                    transaction.totalAmount,
                    isBold: true,
                    context: context,
                  ),

                  // Action buttons
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _handleReprintReceipt(context, transaction),
                          icon: const Icon(Icons.receipt_long, size: 18),
                          label: Text(
                            AppLocalizations.of(context)!.sales_cetak_struk,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: NeoBrutalTheme.blockBlue,
                            side: BorderSide(color: NeoBrutalTheme.blockBlue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (isRefundable) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _handleRefund(context, ref, transaction),
                            icon: const Icon(Icons.assignment_return, size: 18),
                            label: Text(
                              AppLocalizations.of(context)!.sales_refund,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: NeoBrutalTheme.warning,
                              side: BorderSide(color: NeoBrutalTheme.warning),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isRefundable) ...[
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.sales_refund_available_30_days,
                      style: TextStyle(
                        fontSize: 11,
                        color: tertiaryTextColor,
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
                        color: tertiaryTextColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: tertiaryTextColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.sales_transaction_refunded_badge,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: secondaryTextColor,
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

  Widget _buildStatusBadge(PaymentStatus status, BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case PaymentStatus.completed:
        bgColor = NeoBrutalTheme.success.withValues(alpha: 0.15);
        textColor = NeoBrutalTheme.success;
        break;
      case PaymentStatus.pending:
        bgColor = NeoBrutalTheme.warning.withValues(alpha: 0.15);
        textColor = NeoBrutalTheme.warning;
        break;
      case PaymentStatus.cancelled:
        bgColor = NeoBrutalTheme.error.withValues(alpha: 0.15);
        textColor = NeoBrutalTheme.error;
        break;
      case PaymentStatus.refunded:
        textColor = NeoBrutalTheme.getTertiaryTextColor(context);
        bgColor = textColor.withValues(alpha: 0.15);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildTotalsRow(
    String label,
    double amount, {
    bool isBold = false,
    required BuildContext context,
  }) {
    final textColor = NeoBrutalTheme.getTextColor(context);
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
              color: textColor,
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? NeoBrutalTheme.primary : textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    SalesHistoryController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.getBorderColor(context), width: 0.5),
        ),
        title: Text(AppLocalizations.of(context)!.common_filter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.sales_filter_by_payment,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: NeoBrutalTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(
                    AppLocalizations.of(context)!.category_semua,
                    style: TextStyle(fontSize: 13),
                  ),
                  selected: controller.selectedPaymentMethod == null,
                  onSelected: (selected) {
                    controller.setPaymentMethodFilter(null);
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppTheme.getBorderColor(context),
                      width: 0.5,
                    ),
                  ),
                ),
                ...PaymentMethod.values.map((method) {
                  return FilterChip(
                    label: Text(
                      method.displayNameId,
                      style: const TextStyle(fontSize: 13),
                    ),
                    selected: controller.selectedPaymentMethod == method,
                    onSelected: (selected) {
                      controller.setPaymentMethodFilter(
                        selected ? method : null,
                      );
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppTheme.getBorderColor(context),
                        width: 0.5,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.sales_category_colon,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: NeoBrutalTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            if (controller.categories.isEmpty)
              Text(
                AppLocalizations.of(context)!.sales_loading_categories,
                style: TextStyle(
                  fontSize: 13,
                  color: NeoBrutalTheme.getSecondaryTextColor(context),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(
                      AppLocalizations.of(context)!.category_semua,
                      style: TextStyle(fontSize: 13),
                    ),
                    selected: controller.selectedCategoryId == null,
                    onSelected: (selected) {
                      controller.setCategoryFilter(null);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppTheme.getBorderColor(context),
                        width: 0.5,
                      ),
                    ),
                  ),
                  ...controller.categories.map((category) {
                    return FilterChip(
                      label: Text(
                        category.name,
                        style: const TextStyle(fontSize: 13),
                      ),
                      selected: controller.selectedCategoryId == category.id,
                      onSelected: (selected) {
                        controller.setCategoryFilter(
                          selected ? category.id : null,
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppTheme.getBorderColor(context),
                          width: 0.5,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.sales_cashier_colon,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: NeoBrutalTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            if (controller.cashiers.isEmpty)
              Text(
                AppLocalizations.of(context)!.sales_loading_cashiers,
                style: TextStyle(
                  fontSize: 13,
                  color: NeoBrutalTheme.getSecondaryTextColor(context),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(
                      AppLocalizations.of(context)!.category_semua,
                      style: TextStyle(fontSize: 13),
                    ),
                    selected: controller.selectedCashierId == null,
                    onSelected: (selected) {
                      controller.setCashierFilter(null);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppTheme.getBorderColor(context),
                        width: 0.5,
                      ),
                    ),
                  ),
                  ...controller.cashiers.map((cashier) {
                    return FilterChip(
                      label: Text(
                        cashier.fullName,
                        style: const TextStyle(fontSize: 13),
                      ),
                      selected: controller.selectedCashierId == cashier.id,
                      onSelected: (selected) {
                        controller.setCashierFilter(
                          selected ? cashier.id : null,
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppTheme.getBorderColor(context),
                          width: 0.5,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.sales_filter_by_date,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: NeoBrutalTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, controller, true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      controller.startDate == null
                          ? AppLocalizations.of(context)!.sales_from
                          : '${controller.startDate!.day}/${controller.startDate!.month}/${controller.startDate!.year}',
                    ),
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
                    label: Text(
                      controller.endDate == null
                          ? AppLocalizations.of(context)!.sales_to
                          : '${controller.endDate!.day}/${controller.endDate!.month}/${controller.endDate!.year}',
                    ),
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
                  label: Text(
                    AppLocalizations.of(context)!.sales_clear_date_filter,
                  ),
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
            child: Text(AppLocalizations.of(context)!.sales_tutup),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    SalesHistoryController controller,
    bool isStartDate,
  ) async {
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

  Future<void> _handleRefund(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    // Show confirmation dialog
    final confirmed = await showRefundConfirmationDialog(
      context: context,
      transaction: transaction,
    );

    if (confirmed != true || !context.mounted) return;

    // Get controllers
    final refundController = ref.read(refundControllerProvider);
    final historyController = ref.read(salesHistoryControllerProvider);

    // Process refund
    final success = await refundController.refundTransaction(transaction.id!);

    if (!context.mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.sales_refund_success),
          backgroundColor: AppTheme.successColor,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.common_ok,
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
            refundController.errorMessage ??
                AppLocalizations.of(context)!.sales_refund_failed_msg,
          ),
          backgroundColor: AppTheme.errorColor,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.common_ok,
            textColor: Colors.white,
            onPressed: () {
              refundController.clearError();
            },
          ),
        ),
      );
    }
  }

  Future<void> _handleReprintReceipt(
    BuildContext context,
    Transaction transaction,
  ) async {
    try {
      final receipt = Receipt.fromTransaction(transaction: transaction);
      final usecase = GenerateReceiptUseCase();
      final file = await usecase.execute(receipt);

      if (!context.mounted) return;

      // Show options dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(AppLocalizations.of(context)!.sales_cetak_struk),
          content: Text(
            '${AppLocalizations.of(context)!.receipt_title} ${AppLocalizations.of(context)!.sales_transaction} #${transaction.id} ${AppLocalizations.of(context)!.receipt_print_success}',
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await Printing.layoutPdf(
                  onLayout: (format) async => file.readAsBytes(),
                );
              },
              icon: const Icon(Icons.print),
              label: Text(AppLocalizations.of(context)!.receipt_print),
            ),
            TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    subject:
                        '${AppLocalizations.of(context)!.receipt_title} ${AppLocalizations.of(context)!.sales_transaction} #${transaction.id}',
                  ),
                );
              },
              icon: const Icon(Icons.share),
              label: Text(AppLocalizations.of(context)!.common_share),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.sales_tutup),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.sales_failed_create_receipt}: $e',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
