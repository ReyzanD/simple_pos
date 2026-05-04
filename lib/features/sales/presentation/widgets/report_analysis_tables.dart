import 'package:flutter/material.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sales_report.dart';

class ReportAnalysisTables extends StatelessWidget {
  final SalesReport report;
  const ReportAnalysisTables({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductTable(context),
        const SizedBox(height: 32),
        if (report.categoryBreakdown.isNotEmpty) ...[
          _buildCategoryTable(context),
          const SizedBox(height: 32),
        ],
        _buildPeakHours(context),
      ],
    );
  }

  Widget _buildProductTable(BuildContext context) {
    final textColor = NeoBrutalTheme.getTextColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.sales_top_products,
          style: NeoBrutalTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: _brutalDecoration(context),
          child: Column(
            children: [
              const _Header(
                titles: ['Produk', 'Qty', 'Margin', 'Total'],
                flex: [3, 1, 2, 3],
                color: NeoBrutalTheme.blockCoral,
              ),
              ...report.topProducts.asMap().entries.map(
                (e) => _Row(
                  index: e.key,
                  flex: const [3, 1, 2, 3],
                  cells: [
                    Text(
                      e.value.productName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${e.value.quantitySold}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      '${e.value.profitMargin.toStringAsFixed(1)}%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _marginColor(e.value.profitMargin),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(e.value.revenue),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _marginColor(double margin) {
    if (margin >= 40) return NeoBrutalTheme.success;
    if (margin >= 25) return NeoBrutalTheme.secondary;
    if (margin >= 15) return NeoBrutalTheme.warning;
    return NeoBrutalTheme.error;
  }

  Widget _buildCategoryTable(BuildContext context) {
    final textColor = NeoBrutalTheme.getTextColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.category_title,
          style: NeoBrutalTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: _brutalDecoration(context),
          child: Column(
            children: [
              const _Header(
                titles: ['Nama', 'Qty', 'Margin'],
                flex: [4, 2, 3],
                color: NeoBrutalTheme.blockBlue,
              ),
              ...report.categoryBreakdown.asMap().entries.map(
                (e) => _Row(
                  index: e.key,
                  flex: const [4, 2, 3],
                  cells: [
                    Text(
                      e.value.categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${e.value.quantitySold}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      '${e.value.profitMargin.toStringAsFixed(1)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeakHours(BuildContext context) {
    final textColor = NeoBrutalTheme.getTextColor(context);
    final peak = report.peakHours;
    if (peak.isEmpty) return const SizedBox.shrink();
    final max = peak.first.transactionCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.sales_peak_hours,
          style: NeoBrutalTheme.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _brutalDecoration(context),
          child: Column(
            children: peak
                .take(5)
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              h.formattedHour,
                              style: TextStyle(color: textColor),
                            ),
                            Text(
                              '${h.transactionCount} Trx',
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: h.transactionCount / max,
                          color: NeoBrutalTheme.primary,
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  BoxDecoration _brutalDecoration(BuildContext context) => BoxDecoration(
    color: NeoBrutalTheme.getCardColor(context),
    borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
    border: Border.all(color: NeoBrutalTheme.getBorderColor(context), width: 4),
    boxShadow: NeoBrutalTheme.chunkyShadow,
  );
}

class _Header extends StatelessWidget {
  final List<String> titles;
  final List<int> flex;
  final Color color;
  const _Header({
    required this.titles,
    required this.flex,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        border: Border(bottom: BorderSide(color: borderColor, width: 4)),
      ),
      child: Row(
        children: List.generate(
          titles.length,
          (i) => Expanded(
            flex: flex[i],
            child: Text(
              titles[i],
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final int index;
  final List<Widget> cells;
  final List<int> flex;
  const _Row({required this.index, required this.cells, required this.flex});

  @override
  Widget build(BuildContext context) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: index.isOdd
            ? borderColor.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: Row(
        children: List.generate(
          cells.length,
          (i) => Expanded(flex: flex[i], child: cells[i]),
        ),
      ),
    );
  }
}
