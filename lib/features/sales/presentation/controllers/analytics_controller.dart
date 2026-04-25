import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_sales_analytics_usecase.dart';
import '../../domain/entities/sales_analytics.dart';
import '../../domain/entities/chart_enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Controller for Sales Analytics Screen
/// Manages state and business logic for advanced analytics
class AnalyticsController extends ChangeNotifier {
  final GetSalesAnalyticsUseCase getSalesAnalyticsUseCase;

  bool _disposed = false;

  AnalyticsController({
    required this.getSalesAnalyticsUseCase,
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // State
  SalesAnalyticsReport? _report;
  bool _isLoading = false;
  AppException? _error;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  int _forecastDays = 7;

  // Getters
  SalesAnalyticsReport? get report => _report;
  bool get isLoading => _isLoading;
  AppException? get error => _error;
  bool get hasError => _error != null;
  bool get hasReport => _report != null;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  int get forecastDays => _forecastDays;

  /// Load analytics report
  Future<void> loadAnalytics() async {
    try {
      AppLogger.ui('Loading sales analytics', details: 'AnalyticsController');
      _setLoading(true);
      _clearError();

      _report = await getSalesAnalyticsUseCase.execute(
        startDate: _startDate,
        endDate: _endDate,
        forecastDays: _forecastDays,
      );

      AppLogger.info('Sales analytics loaded successfully - AnalyticsController');
    } on AppException catch (e) {
      _setError(e);
      AppLogger.error('Failed to load sales analytics - AnalyticsController', error: e);
    } catch (e, stackTrace) {
      _setError(DatabaseException(
        'Gagal memuat analitik penjualan',
        operation: 'loadAnalytics',
        originalError: e,
        stackTrace: stackTrace,
      ));
      AppLogger.error(
        'Unexpected error loading sales analytics - AnalyticsController',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Set date range for analytics
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    loadAnalytics();
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
        return;
    }

    setDateRange(start, end);
  }

  /// Set forecast days
  void setForecastDays(int days) {
    if (days >= 1 && days <= 30) {
      _forecastDays = days;
      loadAnalytics();
    }
  }

  /// Refresh analytics
  Future<void> refresh() async {
    await loadAnalytics();
  }

  /// Clear error
  void clearError() {
    _clearError();
  }

  // Private methods

  void _setLoading(bool value) {
    _isLoading = value;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setError(AppException error) {
    _error = error;
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _clearError() {
    _error = null;
    if (!_disposed) {
      notifyListeners();
    }
  }
}

extension DateRangePresetExtension on DateRangePreset {
  String get displayName {
    switch (this) {
      case DateRangePreset.today:
        return 'Hari Ini';
      case DateRangePreset.thisWeek:
        return 'Minggu Ini';
      case DateRangePreset.last7Days:
        return '7 Hari Terakhir';
      case DateRangePreset.last30Days:
        return '30 Hari Terakhir';
      case DateRangePreset.last90Days:
        return '90 Hari Terakhir';
      case DateRangePreset.thisMonth:
        return 'Bulan Ini';
      case DateRangePreset.lastMonth:
        return 'Bulan Lalu';
      case DateRangePreset.last3Months:
        return '3 Bulan Terakhir';
      case DateRangePreset.thisQuarter:
        return 'Kuartal Ini';
      case DateRangePreset.thisYear:
        return 'Tahun Ini';
      case DateRangePreset.custom:
        return 'Kustom';
    }
  }
}
