import '../entities/supplier.dart';

/// Interface for supplier repository operations
abstract class SupplierRepository {
  /// Retrieves all suppliers
  Future<List<Supplier>> getSuppliers();

  /// Retrieves a single supplier by ID
  Future<Supplier> getSupplierById(int id);

  /// Adds a new supplier
  Future<Supplier> addSupplier(Supplier supplier);

  /// Updates an existing supplier
  Future<void> updateSupplier(Supplier supplier);

  /// Deletes a supplier
  Future<void> deleteSupplier(int id);

  /// Searches suppliers by name
  Future<List<Supplier>> searchSuppliers(String query);

  /// Checks if supplier name exists
  Future<bool> supplierExists(String name);
}
