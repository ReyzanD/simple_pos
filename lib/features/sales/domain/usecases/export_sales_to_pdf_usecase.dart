import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../entities/sales_report.dart';
import '../../../../core/utils/logger.dart';

/// Use case for exporting sales report to PDF
class ExportSalesToPdfUseCase {
  /// Executes the use case to export sales report to PDF file
  Future<File> execute(SalesReport report) async {
    try {
      AppLogger.useCase(
        'ExportSalesToPdf',
        details: 'Report: ${report.startDate} to ${report.endDate}',
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(report),
            pw.SizedBox(height: 16),
            _buildSummaryTable(report),
            pw.SizedBox(height: 24),
            _buildDailyBreakdown(report),
            pw.SizedBox(height: 24),
            _buildTopProducts(report),
            pw.SizedBox(height: 24),
            _buildPaymentBreakdown(report),
            if (report.cashierBreakdown.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              _buildCashierBreakdown(report),
            ],
            if (report.discountSummary != null) ...[
              pw.SizedBox(height: 24),
              _buildDiscountSummary(report),
            ],
            if (report.monthOverMonth != null || report.yearOverYear != null)
              pw.SizedBox(height: 24),
            if (report.monthOverMonth != null || report.yearOverYear != null)
              _buildComparisonSection(report),
          ],
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Halaman ${context.pageNumber} dari ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ),
        ),
      );

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final reportsDir = Directory('${directory.path}/reports');

      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final file = File('${reportsDir.path}/sales_report_$timestamp.pdf');

      await file.writeAsBytes(await pdf.save());

      AppLogger.info('Sales report exported to PDF: ${file.path}');

      return file;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to export sales report to PDF',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  pw.Widget _buildHeader(SalesReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'LAPORAN PENJUALAN',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#4F46E5'),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Periode: ${_formatDate(report.startDate)} - ${_formatDate(report.endDate)}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(color: PdfColor.fromHex('#4F46E5'), thickness: 2),
      ],
    );
  }

  pw.Widget _buildSummaryTable(SalesReport report) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        _tableRow(['Ringkasan', ''], isHeader: true),
        _tableRow(['Total Transaksi', '${report.totalTransactions}']),
        _tableRow(['Total Pendapatan', _formatCurrency(report.totalRevenue)]),
        _tableRow(['Total Pajak', _formatCurrency(report.totalTax)]),
        _tableRow(['Total Laba', _formatCurrency(report.totalProfit)]),
        _tableRow([
          'Rata-rata Transaksi',
          _formatCurrency(report.averageTransactionValue),
        ]),
        _tableRow([
          'Margin Laba',
          '${report.profitMargin.toStringAsFixed(1)}%',
        ]),
        if (report.profitReport != null)
          _tableRow([
            'Total Pengeluaran',
            _formatCurrency(report.totalExpenses),
          ]),
        if (report.profitReport != null)
          _tableRow(['Laba Bersih', _formatCurrency(report.netProfit)]),
      ],
    );
  }

  pw.Widget _buildDailyBreakdown(SalesReport report) {
    if (report.dailyBreakdown.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Breakdown Harian',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#4F46E5'),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1.5),
            3: pw.FlexColumnWidth(1.5),
            4: pw.FlexColumnWidth(1.5),
          },
          children: [
            _tableRow([
              'Tanggal',
              'Transaksi',
              'Pendapatan',
              'Pajak',
              'Laba',
            ], isHeader: true),
            ...report.dailyBreakdown.map(
              (daily) => _tableRow([
                _formatDate(daily.date),
                daily.transactionCount.toString(),
                _formatCurrency(daily.revenue),
                _formatCurrency(daily.tax),
                _formatCurrency(daily.profit),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTopProducts(SalesReport report) {
    if (report.topProducts.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Produk Terlaris',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#4F46E5'),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1.5),
          },
          children: [
            _tableRow([
              'Produk',
              'Qty',
              'Margin',
              'Pendapatan',
            ], isHeader: true),
            ...report.topProducts.map(
              (product) => _tableRow([
                product.productName,
                product.quantitySold.toString(),
                '${product.profitMargin.toStringAsFixed(1)}%',
                _formatCurrency(product.revenue),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPaymentBreakdown(SalesReport report) {
    if (report.paymentBreakdown.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Metode Pembayaran',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#4F46E5'),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1.5),
            3: pw.FlexColumnWidth(1),
          },
          children: [
            _tableRow([
              'Metode',
              'Transaksi',
              'Total',
              'Persentase',
            ], isHeader: true),
            ...report.paymentBreakdown.map(
              (payment) => _tableRow([
                payment.paymentMethod.displayNameId.toUpperCase(),
                payment.transactionCount.toString(),
                _formatCurrency(payment.totalAmount),
                '${payment.percentage.toStringAsFixed(1)}%',
              ]),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCashierBreakdown(SalesReport report) {
    if (report.cashierBreakdown.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Performa Kasir',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#4F46E5'),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1.5),
            3: pw.FlexColumnWidth(1.5),
          },
          children: [
            _tableRow([
              'Kasir',
              'Transaksi',
              'Pendapatan',
              'Margin',
            ], isHeader: true),
            ...report.cashierBreakdown.map(
              (cashier) => _tableRow([
                cashier.cashierName,
                cashier.transactionCount.toString(),
                _formatCurrency(cashier.revenue),
                '${cashier.profitMargin.toStringAsFixed(1)}%',
              ]),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildDiscountSummary(SalesReport report) {
    final summary = report.discountSummary;
    if (summary == null) return pw.SizedBox.shrink();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Ringkasan Diskon',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#4F46E5'),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            _tableRow(['Ringkasan Diskon', ''], isHeader: true),
            _tableRow(['Total Diskon', _formatCurrency(summary.totalDiscount)]),
            _tableRow([
              'Transaksi Berdiskon',
              '${summary.discountedTransactionCount}/${summary.totalTransactionCount}',
            ]),
            _tableRow([
              'Rata-rata Diskon',
              _formatCurrency(summary.averageDiscountPerTransaction),
            ]),
            _tableRow([
              'Tingkat Diskon',
              '${summary.discountRate.toStringAsFixed(1)}%',
            ]),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildComparisonSection(SalesReport report) {
    final widgets = <pw.Widget>[];

    widgets.add(
      pw.Text(
        'Perbandingan Periode',
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#4F46E5'),
        ),
      ),
    );
    widgets.add(pw.SizedBox(height: 8));

    if (report.monthOverMonth != null) {
      final mom = report.monthOverMonth!;
      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.5),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1),
          },
          children: [
            _tableRow([
              'Bulan Sebelumnya',
              'Pendapatan',
              'Keuntungan',
              'Transaksi',
            ], isHeader: true),
            _tableRow([
              'Perubahan',
              '${mom.isRevenueGrowth ? '+' : ''}${mom.revenueChange.toStringAsFixed(1)}%',
              '${mom.isProfitGrowth ? '+' : ''}${mom.profitChange.toStringAsFixed(1)}%',
              '${mom.isTransactionGrowth ? '+' : ''}${mom.transactionChange.toStringAsFixed(1)}%',
            ]),
          ],
        ),
      );
    }

    if (report.monthOverMonth != null && report.yearOverYear != null) {
      widgets.add(pw.SizedBox(height: 12));
    }

    if (report.yearOverYear != null) {
      final yoy = report.yearOverYear!;
      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.5),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1),
          },
          children: [
            _tableRow([
              'Tahun Sebelumnya',
              'Pendapatan',
              'Keuntungan',
              'Transaksi',
            ], isHeader: true),
            _tableRow([
              'Perubahan',
              '${yoy.isRevenueGrowth ? '+' : ''}${yoy.revenueChange.toStringAsFixed(1)}%',
              '${yoy.isProfitGrowth ? '+' : ''}${yoy.profitChange.toStringAsFixed(1)}%',
              '${yoy.isTransactionGrowth ? '+' : ''}${yoy.transactionChange.toStringAsFixed(1)}%',
            ]),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: widgets,
    );
  }

  pw.TableRow _tableRow(List<String> cells, {bool isHeader = false}) {
    return pw.TableRow(
      decoration: isHeader ? pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: cells.map((cell) {
        return pw.Padding(
          padding: pw.EdgeInsets.all(6),
          child: pw.Text(
            cell,
            style: pw.TextStyle(
              fontSize: isHeader ? 10 : 9,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
