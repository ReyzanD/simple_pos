import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_pos/core/theme/neo_brutal_theme.dart';
import 'package:simple_pos/core/widgets/kpi_stats_dashboard.dart';
import 'package:simple_pos/core/widgets/brutal_widgets.dart';

/// Improved POS KPI Dashboard wrapper
///
/// Changes:
/// - Reduced spacing to save vertical space
/// - More products visible on screen
/// - Better visual hierarchy
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
    return Container(
          padding: EdgeInsets.only(
            left: NeoBrutalTheme.spaceMD,
            right: NeoBrutalTheme.spaceMD,
            top: NeoBrutalTheme.spaceSM,
            bottom: 0, // Reduced to save space
          ),
          child: BrutalCard(
            padding: EdgeInsets.zero,
            child: KPIStatsDashboard(
              todayRevenue: todayRevenue,
              todayTransactions: todayTransactions,
              itemsSold: itemsSold,
              isLoading: isLoading,
              onRevenueTap: onRevenueTap,
              onTransactionsTap: onTransactionsTap,
              onItemsSoldTap: onItemsSoldTap,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut)
        .then()
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.elasticOut,
        );
  }
}
