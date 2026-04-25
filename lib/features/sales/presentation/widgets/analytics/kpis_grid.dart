import 'package:flutter/material.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/utils/currency_formatter.dart';
import 'package:simple_pos/core/utils/responsive_helper.dart';
import 'package:simple_pos/features/sales/presentation/widgets/analytics/kpi_card.dart';
import 'package:simple_pos/features/sales/domain/entities/sales_analytics.dart';

/// KPIs grid widget for analytics
class KPIsGrid extends StatelessWidget {
  final AnalyticsKPIs kpis;

  const KPIsGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveHelper.getWideGridColumns(context),
      mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
      crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
      childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.4 : 1.6,
      children: [
        KPICard(
          icon: Icons.trending_up,
          title: 'Pertumbuhan',
          value: '${kpis.revenueGrowthRate.toStringAsFixed(1)}%',
          color: kpis.revenueGrowthRate >= 0
              ? AppTheme.successColor
              : AppTheme.errorColor,
          subtitle: 'Pendapatan',
        ),
        KPICard(
          icon: Icons.account_balance_wallet,
          title: 'Margin',
          value: '${kpis.profitMargin.toStringAsFixed(1)}%',
          color: kpis.profitMargin >= 20
              ? AppTheme.successColor
              : kpis.profitMargin >= 15
              ? AppTheme.warningColor
              : AppTheme.errorColor,
          subtitle: 'Keuntungan',
        ),
        KPICard(
          icon: Icons.receipt_long,
          title: 'Rata-rata',
          value: CurrencyFormatter.format(kpis.averageTransactionValue),
          color: AppTheme.infoColor,
          subtitle: 'Per Transaksi',
        ),
        KPICard(
          icon: Icons.shopping_cart,
          title: 'Item',
          value: kpis.itemsPerTransaction.toStringAsFixed(1),
          color: AppTheme.secondaryColor,
          subtitle: 'Per Transaksi',
        ),
      ],
    );
  }
}
