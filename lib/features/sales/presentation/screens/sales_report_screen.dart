import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../shared/presentation/providers.dart';
import '../../../shared/presentation/main_navigation.dart';

import '../widgets/report_summary_section.dart';
import '../widgets/report_charts_section.dart';
import '../widgets/report_analysis_tables.dart';

class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(salesReportControllerProvider);

    return Scaffold(
      backgroundColor: NeoBrutalTheme.background,
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: NeoBrutalTheme.blockYellow,
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
          ? const Center(child: Text('Data tidak ditemukan'))
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getScreenPadding(context).copyWith(
                  bottom: ResponsiveHelper.getBottomPadding(context),
                ),
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
                    SizedBox(height: ResponsiveHelper.getBottomPadding(context)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateHeader(BuildContext context, dynamic controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockBlue,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Periode Laporan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeoBrutalTheme.primary,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 3),
          ),
        ),
        onPressed: controller.isExporting
            ? null
            : () async {
                final file = await controller.exportSalesReport();
                if (file != null) {
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    subject: 'Laporan Penjualan',
                    text: 'Laporan penjualan dari aplikasi POS',
                  );
                }
              },
        child: Text(
          controller.isExporting ? 'Mengekspor...' : 'Ekspor Laporan',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
