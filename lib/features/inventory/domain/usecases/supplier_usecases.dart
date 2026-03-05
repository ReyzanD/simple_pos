import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for getting all suppliers
class GetSuppliersUseCase {
  final SupplierRepository repository;

  GetSuppliersUseCase({required this.repository});

  Future<List<Supplier>> execute() async {
    try {
      AppLogger.useCase('GetSuppliers');
      return await repository.getSuppliers();
    } catch (e, stackTrace) {
      AppLogger.error('GetSuppliers failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Use case for adding a new supplier
class AddSupplierUseCase {
  final SupplierRepository repository;

  AddSupplierUseCase({required this.repository});

  Future<Supplier> execute(Supplier supplier) async {
    try {
      AppLogger.useCase('AddSupplier', details: supplier.name);
      supplier.validate();
      return await repository.addSupplier(supplier);
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('AddSupplier failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Use case for updating a supplier
class UpdateSupplierUseCase {
  final SupplierRepository repository;

  UpdateSupplierUseCase({required this.repository});

  Future<Supplier> execute(Supplier supplier) async {
    try {
      AppLogger.useCase('UpdateSupplier', details: 'ID: ${supplier.id}');
      if (supplier.id == null) {
        throw const ValidationException('ID pemasok diperlukan', field: 'ID');
      }
      supplier.validate();
      await repository.updateSupplier(supplier);
      return supplier;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('UpdateSupplier failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Use case for deleting a supplier
class DeleteSupplierUseCase {
  final SupplierRepository repository;

  DeleteSupplierUseCase({required this.repository});

  Future<void> execute(int id) async {
    try {
      AppLogger.useCase('DeleteSupplier', details: 'ID: $id');
      await repository.deleteSupplier(id);
    } catch (e, stackTrace) {
      AppLogger.error('DeleteSupplier failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
