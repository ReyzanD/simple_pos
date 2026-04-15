import '../models/supplier_model.dart';
import 'package:simple_pos/core/database/database_helper.dart';
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;
import 'package:simple_pos/core/utils/logger.dart';

/// Implementation of supplier local data source
class SupplierLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  SupplierLocalDataSourceImpl({required this.databaseHelper});

  /// Creates a new supplier
  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    try {
      AppLogger.debug(
        'Creating supplier in local data source',
        tag: 'SupplierDataSource',
      );

      // CHANGED: Call the DAO insert method
      final result = await databaseHelper.suppliers.insert(supplier.toMap());

      AppLogger.info(
        'Supplier created successfully',
        tag: 'SupplierDataSource',
      );
      return SupplierModel.fromMap(result);
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in createSupplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal membuat pemasok',
        operation: 'createSupplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets all suppliers
  Future<List<SupplierModel>> getAllSuppliers() async {
    try {
      AppLogger.debug(
        'Fetching all suppliers from local data source',
        tag: 'SupplierDataSource',
      );

      // CHANGED: Call the DAO getAll method
      final data = await databaseHelper.suppliers.getAll();

      AppLogger.info(
        'Suppliers fetched successfully',
        tag: 'SupplierDataSource',
      );
      return data.map((map) => SupplierModel.fromMap(map)).toList();
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getAllSuppliers',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua pemasok',
        operation: 'getAllSuppliers',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets a supplier by ID
  Future<SupplierModel> getSupplierById(int id) async {
    try {
      AppLogger.debug('Fetching supplier by ID', tag: 'SupplierDataSource');

      // CHANGED: Call the DAO getById method
      final data = await databaseHelper.suppliers.getById(id);

      if (data == null) {
        throw app_exceptions.NotFoundException(
          'Pemasok tidak ditemukan',
          resourceType: 'Pemasok',
          resourceId: id.toString(),
        );
      }

      AppLogger.info(
        'Supplier fetched successfully',
        tag: 'SupplierDataSource',
      );
      return SupplierModel.fromMap(data);
    } on app_exceptions.NotFoundException {
      rethrow;
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getSupplierById',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil pemasok',
        operation: 'getSupplierById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates a supplier
  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    if (supplier.id == null) {
      throw const app_exceptions.ValidationException(
        'ID pemasok diperlukan untuk update',
        field: 'ID',
      );
    }

    try {
      AppLogger.debug('Updating supplier', tag: 'SupplierDataSource');

      // CHANGED: Call the DAO update method
      await databaseHelper.suppliers.update(supplier.id!, supplier.toMap());

      AppLogger.info(
        'Supplier updated successfully',
        tag: 'SupplierDataSource',
      );
      return supplier;
    } on app_exceptions.ValidationException {
      rethrow;
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateSupplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate pemasok',
        operation: 'updateSupplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a supplier
  Future<void> deleteSupplier(int id) async {
    try {
      AppLogger.debug('Deleting supplier', tag: 'SupplierDataSource');

      // CHANGED: Call the DAO delete method
      await databaseHelper.suppliers.delete(id);

      AppLogger.info(
        'Supplier deleted successfully',
        tag: 'SupplierDataSource',
      );
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteSupplier',
        error: e,
        stackTrace: stackTrace,
        tag: 'SupplierDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menghapus pemasok',
        operation: 'deleteSupplier',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
