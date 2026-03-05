import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_local_datasource_impl.dart';
import '../models/supplier_model.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of supplier repository
class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierLocalDataSourceImpl localDataSource;

  SupplierRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Supplier>> getSuppliers() async {
    try {
      AppLogger.debug('Fetching all suppliers', tag: 'SupplierRepository');

      final supplierModels = await localDataSource.getAllSuppliers();

      AppLogger.info('Suppliers fetched successfully', tag: 'SupplierRepository');
      return supplierModels.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getSuppliers',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierRepository',
      );
      throw DatabaseException(
        'Gagal mengambil pemasok',
        operation: 'getSuppliers',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Supplier> getSupplierById(int id) async {
    try {
      AppLogger.debug('Fetching supplier by ID', tag: 'SupplierRepository');

      final supplierModel = await localDataSource.getSupplierById(id);

      AppLogger.info('Supplier fetched successfully', tag: 'SupplierRepository');
      return supplierModel.toEntity();
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getSupplierById',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierRepository',
      );
      throw DatabaseException(
        'Gagal mengambil pemasok',
        operation: 'getSupplierById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Supplier> addSupplier(Supplier supplier) async {
    try {
      AppLogger.debug('Creating supplier', tag: 'SupplierRepository');

      final supplierModel = SupplierModel.fromEntity(supplier);
      final createdModel = await localDataSource.createSupplier(supplierModel);

      AppLogger.info('Supplier created successfully', tag: 'SupplierRepository');
      return createdModel.toEntity();
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in addSupplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierRepository',
      );
      throw DatabaseException(
        'Gagal membuat pemasok',
        operation: 'addSupplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    try {
      AppLogger.debug('Updating supplier', tag: 'SupplierRepository');

      if (supplier.id == null) {
        throw const ValidationException(
          'ID pemasok diperlukan',
          field: 'ID',
        );
      }

      final supplierModel = SupplierModel.fromEntity(supplier);
      await localDataSource.updateSupplier(supplierModel);

      AppLogger.info('Supplier updated successfully', tag: 'SupplierRepository');
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateSupplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierRepository',
      );
      throw DatabaseException(
        'Gagal mengupdate pemasok',
        operation: 'updateSupplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteSupplier(int id) async {
    try {
      AppLogger.debug('Deleting supplier', tag: 'SupplierRepository');

      await localDataSource.deleteSupplier(id);

      AppLogger.info('Supplier deleted successfully', tag: 'SupplierRepository');
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteSupplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierRepository',
      );
      throw DatabaseException(
        'Gagal menghapus pemasok',
        operation: 'deleteSupplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Supplier>> searchSuppliers(String query) async {
    try {
      final suppliers = await localDataSource.getAllSuppliers();
      return suppliers
          .where((model) =>
              model.name.toLowerCase().contains(query.toLowerCase()))
          .map((model) => model.toEntity())
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to search suppliers',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierRepository',
      );
      return [];
    }
  }

  @override
  Future<bool> supplierExists(String name) async {
    try {
      final suppliers = await localDataSource.getAllSuppliers();
      return suppliers.any((sup) => sup.name.toLowerCase() == name.toLowerCase());
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check supplier existence',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierRepository',
      );
      return false;
    }
  }
}
