import '../../domain/entities/cash_count.dart';
import '../../domain/repositories/cash_count_repository.dart';
import '../datasources/cash_count_local_datasource_impl.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of CashCountRepository
class CashCountRepositoryImpl implements CashCountRepository {
  final CashCountLocalDataSourceImpl localDataSource;

  CashCountRepositoryImpl({required this.localDataSource});

  @override
  Future<CashCount> saveCashCount(CashCount cashCount) async {
    try {
      AppLogger.database('saveCashCount', details: 'CashCountRepository');

      return await localDataSource.saveCashCount(cashCount);
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in CashCountRepository.saveCashCount',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menyimpan hitungan uang',
        operation: 'saveCashCount',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<CashCount?> getCashCountByShift(int shiftId) async {
    try {
      AppLogger.database('getCashCountByShift', details: 'CashCountRepository');

      return await localDataSource.getCashCountByShift(shiftId);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in CashCountRepository.getCashCountByShift',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<List<CashCount>> getCashCountHistory(int shiftId) async {
    try {
      AppLogger.database('getCashCountHistory', details: 'CashCountRepository');

      final results = await localDataSource.getCashCountHistory(shiftId);

      // Convert to entities
      return results.map((row) {
        // Simple conversion for history display
        return CashCount(
          shiftId: shiftId,
          billCounts: {},
          totalCounted: row['count'] as int,
          expectedAmount: 0,
          discrepancy: 0,
          countedAt: DateTime.fromMillisecondsSinceEpoch(
            (row['counted_at'] as int) * 1000,
          ),
          countedBy: row['counted_by'] as String,
        );
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in CashCountRepository.getCashCountHistory',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<bool> deleteCashCount(int id) async {
    try {
      AppLogger.database('deleteCashCount', details: 'CashCountRepository');

      return await localDataSource.deleteCashCount(id);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in CashCountRepository.deleteCashCount',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
