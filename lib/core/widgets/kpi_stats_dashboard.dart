import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_helper.dart';
import '../utils/responsive_helper.dart';
import 'animated_counter.dart';
import 'shimmer_loading.dart';

/// KPI Stats Dashboard showing key performance indicators
///
/// Displays quick stats for:
/// - Today's sales/revenue
/// - Transaction count
/// - Items sold
class KPIStatsDashboard extends StatefulWidget {
  final double todayRevenue;
  final int todayTransactions;
  final int itemsSold;
  final bool isLoading;
  final VoidCallback? onRevenueTap;
  final VoidCallback? onTransactionsTap;
  final VoidCallback? onItemsSoldTap;

  const KPIStatsDashboard({
    super.key,
    required this.todayRevenue,
    required this.todayTransactions,
    required this.itemsSold,
    this.isLoading = false,
    this.onRevenueTap,
    this.onTransactionsTap,
    this.onItemsSoldTap,
  });

  @override
  State<KPIStatsDashboard> createState() => _KPIStatsDashboardState();
}

class _KPIStatsDashboardState extends State<KPIStatsDashboard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildShimmerLoading();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with toggle button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: GestureDetector(
            onTap: () {
              HapticHelper.lightImpact();
              _toggleExpanded();
            },
            child: Row(
              children: [
                Text(
                  'Ringkasan Hari Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isExpanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Collapsible content
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0,
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _KPIStatCard(
                    title: 'Pendapatan',
                    value: widget.todayRevenue,
                    icon: Icons.payments_outlined,
                    color: AppTheme.successColor,
                    isCurrency: true,
                    onTap: widget.onRevenueTap,
                  ),
                  const SizedBox(height: 8),
                  _KPIStatCard(
                    title: 'Transaksi',
                    value: widget.todayTransactions.toDouble(),
                    icon: Icons.receipt_long_rounded,
                    color: AppTheme.infoColor,
                    isCurrency: false,
                    onTap: widget.onTransactionsTap,
                  ),
                  const SizedBox(height: 8),
                  _KPIStatCard(
                    title: 'Terjual',
                    value: widget.itemsSold.toDouble(),
                    icon: Icons.shopping_bag_outlined,
                    color: AppTheme.primaryColor,
                    isCurrency: false,
                    onTap: widget.onItemsSoldTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: const [
          _KPIStatShimmerCard(),
          SizedBox(height: 8),
          _KPIStatShimmerCard(),
          SizedBox(height: 8),
          _KPIStatShimmerCard(),
        ],
      ),
    );
  }
}

class _KPIStatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final bool isCurrency;
  final VoidCallback? onTap;

  const _KPIStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isCurrency = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticHelper.lightImpact();
          onTap!();
        }
      },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 10 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: isMobile ? 18 : 20,
              ),
            ),
            SizedBox(width: isMobile ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                  SizedBox(height: isMobile ? 3 : 4),
                  isCurrency
                      ? AnimatedCurrencyCounter(
                          value: value,
                          currencySymbol: 'Rp',
                          showDecimals: false,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        )
                      : AnimatedCounter(
                          value: value.toInt(),
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KPIStatShimmerCard extends StatelessWidget {
  const _KPIStatShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
          width: 1,
        ),
      ),
      child: const ShimmerLoading(
        child: Row(
          children: [
            SizedBox(width: 40, height: 40),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerRectangle(width: 60, height: 12),
                SizedBox(height: 4),
                ShimmerRectangle(width: 80, height: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact KPI widget for use in tight spaces
class CompactKPIStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const CompactKPIStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticHelper.lightImpact();
          onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: effectiveIconColor,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.getTextSecondaryColor(context),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini KPI row widget for horizontal display
class MiniKPIRow extends StatelessWidget {
  final List<MiniKPIItem> items;

  const MiniKPIRow({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) => Expanded(
        child: _MiniKPIItemWidget(item: item),
      )).toList(),
    );
  }
}

class MiniKPIItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const MiniKPIItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _MiniKPIItemWidget extends StatelessWidget {
  final MiniKPIItem item;

  const _MiniKPIItemWidget({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 16, color: item.color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.getTextSecondaryColor(context),
                ),
              ),
              Text(
                item.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
