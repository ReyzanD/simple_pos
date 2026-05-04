import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/sales_report.dart';
import '../../domain/entities/chart_enums.dart';
import '../../domain/usecases/get_sales_report_usecase.dart'
    show GetSalesReportUseCase, ReportPeriod;
import '../../domain/usecases/export_sales_to_csv_usecase.dart';
import '../../domain/usecases/export_sales_to_pdf_usecase.dart';
import '../../../expenses/domain/usecases/get_profit_report_usecase.dart';
import '../../../expenses/domain/entities/profit_report.dart';
import '../../../../core/utils/logger.dart';

/// Date range for reports
class ReportDateRange {
  final DateTime start;
  final DateTime end;

  ReportDateRange({required this.start, required this.end});
}

/// Controller for Sales Report Screen
/// Manages state and business logic for sales reports
class SalesReportController extends ChangeNotifier {
  final GetSalesReportUseCase _getSalesReportUseCase;
  final ExportSalesToCsvUseCase _exportSalesToCsvUseCase;
  final ExportSalesToPdfUseCase _exportSalesToPdfUseCase;
  final GetProfitReportUseCase? _getProfitReportUseCase;

  SalesReportController({
    required GetSalesReportUseCase getSalesReportUseCase,
    required ExportSalesToCsvUseCase exportSalesToCsvUseCase,
    required ExportSalesToPdfUseCase exportSalesToPdfUseCase,
    GetProfitReportUseCase? getProfitReportUseCase,
  }) : _getSalesReportUseCase = getSalesReportUseCase,
       _exportSalesToCsvUseCase = exportSalesToCsvUseCase,
       _exportSalesToPdfUseCase = exportSalesToPdfUseCase,
       _getProfitReportUseCase = getProfitReportUseCase {
    loadReport();
  }

  // State
  SalesReport? _report;
  bool _isLoading = true;
  String? _errorMessage;
  ReportDateRange _dateRange = ReportDateRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  ReportPeriod _period = ReportPeriod.monthly;

  // Chart display options
  ChartType _chartType = ChartType.line;
  ChartMetric _chartMetric = ChartMetric.revenue;
  ChartPeriod _chartPeriod = ChartPeriod.daily;

  // Export state
  bool _isExporting = false;
  String? _exportErrorMessage;

  // Getters
  SalesReport? get report => _report;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReportDateRange get dateRange => _dateRange;
  ReportPeriod get period => _period;
  ChartType get chartType => _chartType;
  ChartMetric get chartMetric => _chartMetric;
  ChartPeriod get chartPeriod => _chartPeriod;
  bool get isExporting => _isExporting;
  String? get exportErrorMessage => _exportErrorMessage;

  /// Load sales report based on current date range and period
  Future<void> loadReport() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Loading sales report');

      final result = await _getSalesReportUseCase.execute(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
        period: _period,
      );

      // Load profit report if use case is available
      ProfitReport? profitReport;
      if (_getProfitReportUseCase != null) {
        try {
          profitReport = await _getProfitReportUseCase.execute(
            startDate: _dateRange.start,
            endDate: _dateRange.end,
          );
          AppLogger.info('Profit report loaded successfully');
        } catch (e) {
          AppLogger.warning(
            'Failed to load profit report, continuing without it: $e',
          );
          // Continue without profit data - not a critical failure
        }
      }

      // Create updated report with profit data
      _report = SalesReport(
        startDate: result.startDate,
        endDate: result.endDate,
        totalTransactions: result.totalTransactions,
        totalRevenue: result.totalRevenue,
        totalProfit: result.totalProfit,
        averageTransactionValue: result.averageTransactionValue,
        totalItemsSold: result.totalItemsSold,
        dailyBreakdown: result.dailyBreakdown,
        topProducts: result.topProducts,
        paymentBreakdown: result.paymentBreakdown,
        categoryBreakdown: result.categoryBreakdown,
        monthOverMonth: result.monthOverMonth,
        yearOverYear: result.yearOverYear,
        peakHours: result.peakHours,
        profitReport: profitReport,
      );

      _isLoading = false;
      notifyListeners();
      AppLogger.info('Sales report loaded successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      AppLogger.error(
        'Failed to load sales report',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set date range for report
  void setDateRange(DateTime start, DateTime end) {
    _dateRange = ReportDateRange(start: start, end: end);
    loadReport();
  }

  /// Set report period
  void setPeriod(ReportPeriod period) {
    _period = period;
    loadReport();
  }

  /// Set predefined date range
  void setPredefinedRange(DateRangePreset preset) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (preset) {
      case DateRangePreset.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case DateRangePreset.thisWeek:
        final weekday = now.weekday;
        start = now.subtract(Duration(days: weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case DateRangePreset.last7Days:
        start = now.subtract(const Duration(days: 7));
        break;
      case DateRangePreset.last30Days:
        start = now.subtract(const Duration(days: 30));
        break;
      case DateRangePreset.last90Days:
        start = now.subtract(const Duration(days: 90));
        break;
      case DateRangePreset.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case DateRangePreset.lastMonth:
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      case DateRangePreset.last3Months:
        start = DateTime(now.year, now.month - 3, 1);
        break;
      case DateRangePreset.thisQuarter:
        final quarter = (now.month - 1) ~/ 3 + 1;
        start = DateTime(now.year, (quarter - 1) * 3 + 1, 1);
        break;
      case DateRangePreset.thisYear:
        start = DateTime(now.year, 1, 1);
        break;
      case DateRangePreset.custom:
        // Don't change, let user pick custom dates
        return;
    }

    setDateRange(start, end);
  }

  /// Refresh report
  Future<void> refresh() async {
    await loadReport();
  }

  /// Export sales report to CSV
  Future<File?> exportSalesReport() async {
    if (_report == null) {
      _exportErrorMessage = 'Tidak ada laporan untuk diekspor';
      notifyListeners();
      return null;
    }

    _isExporting = true;
    _exportErrorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Exporting sales report to CSV');

      final file = await _exportSalesToCsvUseCase.execute(_report!);

      _isExporting = false;
      notifyListeners();

      AppLogger.info('Sales report exported successfully');
      return file;
    } catch (e, stackTrace) {
      _isExporting = false;
      _exportErrorMessage = e.toString();
      notifyListeners();
      AppLogger.error(
        'Failed to export sales report',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Export sales report to PDF
  Future<File?> exportSalesReportPdf() async {
    if (_report == null) {
      _exportErrorMessage = 'Tidak ada laporan untuk diekspor';
      notifyListeners();
      return null;
    }

    _isExporting = true;
    _exportErrorMessage = null;
    notifyListeners();

    try {
      AppLogger.info('Exporting sales report to PDF');

      final file = await _exportSalesToPdfUseCase.execute(_report!);

      _isExporting = false;
      notifyListeners();

      AppLogger.info('Sales report exported to PDF successfully');
      return file;
    } catch (e, stackTrace) {
      _isExporting = false;
      _exportErrorMessage = e.toString();
      notifyListeners();
      AppLogger.error(
        'Failed to export sales report to PDF',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Clear export error message
  void clearExportError() {
    _exportErrorMessage = null;
    notifyListeners();
  }

  /// Set chart type
  void setChartType(ChartType type) {
    _chartType = type;
    notifyListeners();
  }

  /// Set chart metric
  void setChartMetric(ChartMetric metric) {
    _chartMetric = metric;
    notifyListeners();
  }

  /// Set chart period
  void setChartPeriod(ChartPeriod period) {
    _chartPeriod = period;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    AppLogger.info('Disposing SalesReportController');
  }
}
