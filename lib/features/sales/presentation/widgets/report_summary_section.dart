import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/sales_report.dart';
import '../../../../l10n/app_localizations.dart';
import 'summary_stat_card.dart';

class ReportSummarySection extends StatelessWidget {
  final SalesReport report;

  const ReportSummarySection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final textColor = NeoBrutalTheme.getTextColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppLocalizations.of(context)!.report_generate,
            style: NeoBrutalTheme.headlineLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildRow([
          _animate(
            SummaryStatCard(
              title: AppLocalizations.of(context)!.sales_total_transactions,
              value: '${report.totalTransactions}',
              icon: Icons.receipt_long,
              color: NeoBrutalTheme.blockBlue,
            ),
            0,
          ),
          _animate(
            SummaryStatCard(
              title: AppLocalizations.of(context)!.sales_total_revenue,
              value: CurrencyFormatter.format(report.totalRevenue),
              icon: Icons.payments,
              color: NeoBrutalTheme.success,
            ),
            100,
          ),
        ]),
        const SizedBox(height: 16),
        _buildRow([
          _animate(
            SummaryStatCard(
              title: AppLocalizations.of(context)!.sales_total_profit,
              value: CurrencyFormatter.format(report.totalProfit),
              icon: Icons.trending_up,
              color: NeoBrutalTheme.blockPurple,
            ),
            200,
          ),
          _animate(
            SummaryStatCard(
              title: AppLocalizations.of(context)!.expenses_title,
              value: CurrencyFormatter.format(report.totalExpenses),
              icon: Icons.shopping_cart,
              color: NeoBrutalTheme.error,
            ),
            300,
          ),
        ]),
        const SizedBox(height: 16),
        _animate(
          SummaryStatCard(
            title: AppLocalizations.of(context)!.receipt_tax,
            value: CurrencyFormatter.format(report.totalTax),
            icon: Icons.receipt_long_outlined,
            color: NeoBrutalTheme.warning,
          ),
          400,
        ),
      ],
    );
  }

  Widget _buildRow(List<Widget> cards) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
        ],
      ),
    );
  }

  Widget _animate(Widget child, int delayMs) {
    return child.animate(delay: delayMs.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
}
