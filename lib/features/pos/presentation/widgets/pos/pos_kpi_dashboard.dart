import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_pos/core/theme/app_theme.dart';
import 'package:simple_pos/core/widgets/kpi_stats_dashboard.dart';

/// KPI Dashboard widget for POS screen showing sales statistics
class POSKPIDashboard extends StatelessWidget {
  final double todayRevenue;
  final int todayTransactions;
  final int itemsSold;
  final bool isLoading;
  final VoidCallback? onRevenueTap;
  final VoidCallback? onTransactionsTap;
  final VoidCallback? onItemsSoldTap;

  const POSKPIDashboard({
    super.key,
    required this.todayRevenue,
    required this.todayTransactions,
    required this.itemsSold,
    required this.isLoading,
    this.onRevenueTap,
    this.onTransactionsTap,
    this.onItemsSoldTap,
  });

  @override
  Widget build(BuildContext context) {
    return KPIStatsDashboard(
      todayRevenue: todayRevenue,
      todayTransactions: todayTransactions,
      itemsSold: itemsSold,
      isLoading: isLoading,
      onRevenueTap: onRevenueTap,
      onTransactionsTap: onTransactionsTap,
      onItemsSoldTap: onItemsSoldTap,
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
