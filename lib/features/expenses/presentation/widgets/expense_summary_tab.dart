import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/animated_empty_state.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/sales/presentation/widgets/summary_stat_card.dart';
import '../controllers/expense_controller.dart';

class ExpenseSummaryTab extends StatefulWidget {
  final ExpenseController controller;

  const ExpenseSummaryTab({required this.controller, super.key});

  @override
  State<ExpenseSummaryTab> createState() => _ExpenseSummaryTabState();
}

class _ExpenseSummaryTabState extends State<ExpenseSummaryTab> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectPeriod(DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PeriodSelector(
          selected: _selectedRange,
          onPeriodSelected: (range) {
            setState(() => _selectedRange = range);
            widget.controller.loadSummary(
              startDate: range.start,
              endDate: range.end,
            );
          },
        ),
        Expanded(
          child: Consumer<ExpenseController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                );
              }

              if (controller.totalExpenses == 0) {
                return AnimatedEmptyState(
                  icon: Icons.bar_chart,
                  title: 'Belum Ada Data',
                  subtitle: 'Pilih periode untuk melihat ringkasan pengeluaran',
                );
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // KPI Cards
                  Row(
                    children: [
                      Expanded(
                        child: SummaryStatCard(
                          title: 'Total Pengeluaran',
                          value: CurrencyFormatter.format(controller.totalExpenses),
                          icon: Icons.payments,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryStatCard(
                          title: 'Periode Lalu',
                          value: controller.periodComparison != null
                              ? '${controller.periodComparison!.toStringAsFixed(0)}%'
                              : '-',
                          icon: controller.periodComparison != null &&
                                  controller.periodComparison! >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: controller.periodComparison != null &&
                                  controller.periodComparison! >= 0
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Category breakdown
                  _CategoryBreakdownChart(
                    categorySummary: controller.categorySummary,
                  ),
                  const SizedBox(height: 24),
                  // Payment method breakdown
                  _PaymentMethodChart(
                    expenses: controller.expenses,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _selectPeriod(DateTimeRange range) {
    setState(() => _selectedRange = range);
    widget.controller.loadSummary(
      startDate: range.start,
      endDate: range.end,
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final DateTimeRange? selected;
  final ValueChanged<DateTimeRange> onPeriodSelected;

  const _PeriodSelector({
    required this.selected,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayRange = DateTimeRange(
        start: DateTime(now.year, now.month, now.day), end: now);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          _PeriodChip(
            label: 'Hari Ini',
            isSelected: selected != null &&
                _isSameDay(selected!.start, DateTime.now()),
            onTap: () => onPeriodSelected(todayRange),
          ),
          _PeriodChip(
            label: 'Bulan Ini',
            isSelected: selected != null &&
                selected!.start.month == DateTime.now().month &&
                selected!.start.year == DateTime.now().year,
            onTap: () => onPeriodSelected(DateTimeRange(
                  start: DateTime(DateTime.now().year, DateTime.now().month, 1),
                  end: DateTime.now(),
                )),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.withValues(alpha: 0.1),
      selectedColor: AppTheme.primaryColor,
    );
  }
}

class _CategoryBreakdownChart extends StatelessWidget {
  final Map<String, double> categorySummary;

  const _CategoryBreakdownChart({required this.categorySummary});

  @override
  Widget build(BuildContext context) {
    if (categorySummary.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categorySummary.values.fold<double>(0, (sum, v) => sum + v);
    final categories = categorySummary.entries.toList();

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Per Kategori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ...categories.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key,
                          style: const TextStyle(fontSize: 14)),
                      Text('${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PaymentMethodChart extends StatelessWidget {
  final List<dynamic> expenses;

  const _PaymentMethodChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group by payment method
    final Map<String, double> methodTotals = {};
    for (final expense in expenses) {
      final method = expense.paymentMethod.toString();
      methodTotals[method] = (methodTotals[method] ?? 0) + expense.amount;
    }

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ...methodTotals.entries.map((entry) {
            final total = methodTotals.values.fold<double>(0, (sum, v) => sum + v);
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getMethodColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_getMethodLabel(entry.key))),
                  Text('${percentage.toStringAsFixed(1)}%'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    return switch (method) {
      'ExpensePaymentMethod.cash' => AppTheme.successColor,
      'ExpensePaymentMethod.transfer' => AppTheme.primaryColor,
      'ExpensePaymentMethod.card' => AppTheme.infoColor,
      _ => AppTheme.warningColor,
    };
  }

  String _getMethodLabel(String method) {
    return switch (method) {
      'ExpensePaymentMethod.cash' => 'Tunai',
      'ExpensePaymentMethod.transfer' => 'Transfer',
      'ExpensePaymentMethod.card' => 'Kartu',
      _ => 'Lainnya',
    };
  }
}
