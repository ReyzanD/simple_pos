import '../../domain/entities/shift.dart';
import '../../domain/entities/cash_count.dart';
import '../../domain/repositories/shift_repository.dart';
import '../datasources/shift_local_datasource_impl.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Repository implementation for Shift operations
class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftLocalDataSourceImpl localDataSource;

  ShiftRepositoryImpl({required this.localDataSource});

  @override
  Future<Shift> openShift({
    required String userName,
    required double openingBalance,
  }) async {
    try {
      AppLogger.database('openShift', details: 'ShiftRepository');

      final model = await localDataSource.openShift(
        userName: userName,
        openingBalance: openingBalance,
      );

      return model.toEntity();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in ShiftRepository.openShift',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal membuka shift',
        operation: 'openShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Shift> closeShift({
    required int shiftId,
    required double closingBalance,
  }) async {
    try {
      AppLogger.database('closeShift', details: 'ShiftRepository');

      final model = await localDataSource.closeShift(
        shiftId: shiftId,
        closingBalance: closingBalance,
      );

      return model.toEntity();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in ShiftRepository.closeShift',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menutup shift',
        operation: 'closeShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Shift?> getCurrentShift() async {
    try {
      AppLogger.database('getCurrentShift', details: 'ShiftRepository');

      final model = await localDataSource.getCurrentShift();

      return model?.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in ShiftRepository.getCurrentShift',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil shift aktif',
        operation: 'getCurrentShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Shift>> getShifts({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      AppLogger.database('getShifts', details: 'ShiftRepository');

      final models = await localDataSource.getShifts(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );

      return models.map((model) => model.toEntity()).toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in ShiftRepository.getShifts',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil riwayat shift',
        operation: 'getShifts',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Shift?> getShiftById(int id) async {
    try {
      AppLogger.database('getShiftById', details: 'ShiftRepository');

      final model = await localDataSource.getShiftById(id);

      return model.toEntity();
    } on NotFoundException {
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in ShiftRepository.getShiftById',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengambil data shift',
        operation: 'getShiftById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Shift> updateShiftTotals({
    required int shiftId,
    required double cashSales,
    required double cardSales,
    required double qrSales,
    required double transferSales,
    required int transactionCount,
  }) async {
    try {
      AppLogger.database('updateShiftTotals', details: 'ShiftRepository');

      final model = await localDataSource.updateShiftTotals(
        shiftId: shiftId,
        cashSales: cashSales,
        cardSales: cardSales,
        qrSales: qrSales,
        transferSales: transferSales,
        transactionCount: transactionCount,
      );

      return model.toEntity();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in ShiftRepository.updateShiftTotals',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal mengupdate total shift',
        operation: 'updateShiftTotals',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> deleteShift(int shiftId) async {
    try {
      AppLogger.database('deleteShift', details: 'ShiftRepository');

      return await localDataSource.deleteShift(shiftId);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in ShiftRepository.deleteShift',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseException(
        'Gagal menghapus shift',
        operation: 'deleteShift',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> saveCashCount(CashCount cashCount) async {
    // Cash count is saved via CashCountRepository
    // This is a no-op here as it's handled separately
    // The ShiftController coordinates both repositories
  }
}
