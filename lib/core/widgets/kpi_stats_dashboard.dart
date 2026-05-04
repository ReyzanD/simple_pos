import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/neo_brutal_theme.dart';
import '../utils/haptic_helper.dart';
import '../utils/responsive_helper.dart';
import 'animated_counter.dart';
import 'shimmer_loading.dart';
import 'package:simple_pos/l10n/app_localizations.dart';

/// Improved KPI Stats Dashboard with Neo-Brutalism styling
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
  int _pressedCard = -1;

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
      return _buildShimmerLoading(context);
    }

    final textColor = NeoBrutalTheme.getTextColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getContainerPadding(context),
            vertical: NeoBrutalTheme.spaceMD,
          ),
          child: GestureDetector(
            onTap: () {
              HapticHelper.lightImpact();
              _toggleExpanded();
            },
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.kpi_today_summary,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isExpanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: secondaryTextColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0,
          child: ClipRect(
            child: Padding(
              padding: ResponsiveHelper.getScreenPadding(
                context,
              ).copyWith(top: 0, bottom: 0),
              child: Column(
                children: [
                  _buildKPIStatCard(
                    title: AppLocalizations.of(context)!.kpi_revenue,
                    value: widget.todayRevenue,
                    icon: Icons.payments_outlined,
                    color: AppTheme.successColor,
                    isCurrency: true,
                    cardIndex: 0,
                    onTap: widget.onRevenueTap,
                  ),
                  const SizedBox(height: 12),
                  _buildKPIStatCard(
                    title: AppLocalizations.of(context)!.kpi_transactions,
                    value: widget.todayTransactions.toDouble(),
                    icon: Icons.receipt_long_rounded,
                    color: NeoBrutalTheme.primary,
                    isCurrency: false,
                    cardIndex: 1,
                    onTap: widget.onTransactionsTap,
                  ),
                  const SizedBox(height: 12),
                  _buildKPIStatCard(
                    title: AppLocalizations.of(context)!.kpi_items_sold,
                    value: widget.itemsSold.toDouble(),
                    icon: Icons.shopping_bag_outlined,
                    color: NeoBrutalTheme.blockCoral,
                    isCurrency: false,
                    cardIndex: 2,
                    onTap: widget.onItemsSoldTap,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIStatCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    required bool isCurrency,
    required int cardIndex,
    VoidCallback? onTap,
  }) {
    final isPressed = _pressedCard == cardIndex;
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final cardColor = NeoBrutalTheme.getCardColor(context);
    final secondaryTextColor = NeoBrutalTheme.getSecondaryTextColor(context);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressedCard = cardIndex);
      },
      onTapUp: (_) {
        setState(() => _pressedCard = -1);
        if (onTap != null) {
          HapticHelper.lightImpact();
          onTap();
        }
      },
      onTapCancel: () {
        setState(() => _pressedCard = -1);
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([]),
        builder: (context, _) {
          final offset = isPressed ? const Offset(4.0, 4.0) : Offset.zero;
          final shadowAlpha = isPressed ? 0.1 : 0.2;

          return Transform.translate(
            offset: offset,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(
                  NeoBrutalTheme.radiusMedium,
                ),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowAlpha),
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        isCurrency
                            ? AnimatedCurrencyCounter(
                                value: value,
                                currencySymbol: 'Rp',
                                showDecimals: false,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                  height: 1.0,
                                ),
                              )
                            : AnimatedCounter(
                                value: value.toInt(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: color,
                                  height: 1.0,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(
        context,
      ).copyWith(top: 0, bottom: 0),
      child: Column(
        children: const [
          _KPIStatShimmerCard(),
          SizedBox(height: 12),
          _KPIStatShimmerCard(),
          SizedBox(height: 12),
          _KPIStatShimmerCard(),
        ],
      ),
    );
  }
}

class _KPIStatShimmerCard extends StatelessWidget {
  const _KPIStatShimmerCard();

  @override
  Widget build(BuildContext context) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    final cardColor = NeoBrutalTheme.getCardColor(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: const ShimmerLoading(
        child: Row(
          children: [
            SizedBox(width: 44, height: 44),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerRectangle(width: 60, height: 12),
                SizedBox(height: 6),
                ShimmerRectangle(width: 120, height: 20),
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
          border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
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
              child: Icon(icon, size: 16, color: effectiveIconColor),
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
  const MiniKPIRow({super.key, required this.items});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map((item) => Expanded(child: _MiniKPIItemWidget(item: item)))
          .toList(),
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
  const _MiniKPIItemWidget({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.color.withValues(alpha: 0.3), width: 1),
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
