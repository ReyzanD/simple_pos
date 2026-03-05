import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/sales_report.dart';
import '../../../../core/utils/logger.dart';

/// Use case for exporting sales report to CSV
class ExportSalesToCsvUseCase {
  /// Executes the use case to export sales report to CSV file
  Future<File> execute(SalesReport report) async {
    try {
      AppLogger.useCase('ExportSalesToCsv', details: 'Report: ${report.startDate} to ${report.endDate}');

      // Create CSV data
      final rows = <List<String>>[];

      // Summary section
      rows.add(['LAPORAN PENJUALAN']);
      rows.add(['Periode', '${report.startDate.day}/${report.startDate.month}/${report.startDate.year} - ${report.endDate.day}/${report.endDate.month}/${report.endDate.year}']);
      rows.add(['Total Transaksi', report.totalTransactions.toString()]);
      rows.add(['Total Pendapatan', _formatCurrency(report.totalRevenue)]);
      rows.add(['Total Laba', _formatCurrency(report.totalProfit)]);
      rows.add(['Rata-rata Transaksi', _formatCurrency(report.averageTransactionValue)]);
      rows.add(['Margin Laba', '${report.profitMargin.toStringAsFixed(2)}%']);
      rows.add([]);

      // Daily breakdown
      rows.add(['BREAKDOWN HARIAN']);
      rows.add(['Tanggal', 'Jumlah Transaksi', 'Pendapatan', 'Laba']);
      for (final daily in report.dailyBreakdown) {
        rows.add([
          '${daily.date.day}/${daily.date.month}/${daily.date.year}',
          daily.transactionCount.toString(),
          _formatCurrency(daily.revenue),
          _formatCurrency(daily.profit),
        ]);
      }
      rows.add([]);

      // Top products
      rows.add(['PRODUK TERLARIS']);
      rows.add(['Produk', 'Qty Terjual', 'Pendapatan', 'Laba']);
      for (final product in report.topProducts) {
        rows.add([
          product.productName,
          product.quantitySold.toString(),
          _formatCurrency(product.revenue),
          _formatCurrency(product.profit),
        ]);
      }
      rows.add([]);

      // Payment methods
      rows.add(['METODE PEMBAYARAN']);
      rows.add(['Metode', 'Jumlah', 'Total', 'Persentase']);
      for (final payment in report.paymentBreakdown) {
        rows.add([
          payment.paymentMethod.displayNameId,
          payment.transactionCount.toString(),
          _formatCurrency(payment.totalAmount),
          '${payment.percentage.toStringAsFixed(1)}%',
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(rows);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final reportsDir = Directory('${directory.path}/reports');

      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final file = File('${reportsDir.path}/sales_report_$timestamp.csv');

      await file.writeAsString(csvString);

      AppLogger.info('Sales report exported to CSV: ${file.path}');

      return file;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to export sales report to CSV',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}
