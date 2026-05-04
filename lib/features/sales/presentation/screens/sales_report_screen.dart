import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../shared/presentation/providers.dart';
import '../../../shared/presentation/main_navigation.dart';
import '../../../../l10n/app_localizations.dart';

import '../widgets/report_summary_section.dart';
import '../widgets/report_charts_section.dart';
import '../widgets/report_analysis_tables.dart';

class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(salesReportControllerProvider);

    return Scaffold(
      backgroundColor: NeoBrutalTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sales_laporan),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => context
              .findAncestorStateOfType<MainNavigationState>()
              ?.openDrawer(),
        ),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.report == null
          ? Center(
              child: Text(AppLocalizations.of(context)!.sales_no_data_found),
            )
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getScreenPadding(
                  context,
                ).copyWith(bottom: ResponsiveHelper.getBottomPadding(context)),
                child: Column(
                  children: [
                    _buildDateHeader(context, controller),
                    const SizedBox(height: 24),
                    ReportSummarySection(report: controller.report!),
                    const SizedBox(height: 24),
                    ReportChartsSection(report: controller.report!),
                    const SizedBox(height: 24),
                    ReportAnalysisTables(report: controller.report!),
                    const SizedBox(height: 24),
                    _buildExportButton(context, controller),
                    SizedBox(
                      height: ResponsiveHelper.getBottomPadding(context),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateHeader(BuildContext context, dynamic controller) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockBlue,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.report_period,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, dynamic controller) {
    final borderColor = NeoBrutalTheme.getBorderColor(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeoBrutalTheme.primary,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: borderColor, width: 3),
                  ),
                ),
                onPressed: controller.isExporting
                    ? null
                    : () async {
                        final file = await controller.exportSalesReport();
                        if (file != null) {
                          await SharePlus.instance.share(
                            ShareParams(
                              files: [XFile(file.path)],
                              subject: 'Laporan Penjualan (CSV)',
                              text: 'Laporan penjualan dari aplikasi POS',
                            ),
                          );
                        }
                      },
                child: Text(
                  controller.isExporting
                      ? AppLocalizations.of(context)!.common_loading
                      : AppLocalizations.of(context)!.sales_export,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeoBrutalTheme.blockBlue,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: borderColor, width: 3),
                  ),
                ),
                onPressed: controller.isExporting
                    ? null
                    : () async {
                        final file = await controller.exportSalesReportPdf();
                        if (file != null) {
                          await SharePlus.instance.share(
                            ShareParams(
                              files: [XFile(file.path)],
                              subject: AppLocalizations.of(
                                context,
                              )!.sales_laporan,
                              text: AppLocalizations.of(
                                context,
                              )!.report_generate,
                            ),
                          );
                        }
                      },
                child: Text(
                  controller.isExporting
                      ? AppLocalizations.of(context)!.common_loading
                      : 'Ekspor PDF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
