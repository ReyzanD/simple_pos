import 'package:flutter/foundation.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/usecases/supplier_usecases.dart';
import '../../../../core/utils/logger.dart';

/// Controller for managing suppliers
class SupplierController extends ChangeNotifier {
  final GetSuppliersUseCase _getSuppliersUseCase;
  final AddSupplierUseCase _addSupplierUseCase;
  final UpdateSupplierUseCase _updateSupplierUseCase;
  final DeleteSupplierUseCase _deleteSupplierUseCase;

  bool _disposed = false;

  SupplierController({
    required GetSuppliersUseCase getSuppliersUseCase,
    required AddSupplierUseCase addSupplierUseCase,
    required UpdateSupplierUseCase updateSupplierUseCase,
    required DeleteSupplierUseCase deleteSupplierUseCase,
  })  : _getSuppliersUseCase = getSuppliersUseCase,
        _addSupplierUseCase = addSupplierUseCase,
        _updateSupplierUseCase = updateSupplierUseCase,
        _deleteSupplierUseCase = deleteSupplierUseCase {
    loadSuppliers();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // State
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get supplierCount => _suppliers.length;

  /// Load all suppliers
  Future<void> loadSuppliers() async {
    _isLoading = true;
    _errorMessage = null;
    if (!_disposed) notifyListeners();

    try {
      AppLogger.info('Loading suppliers');
      _suppliers = await _getSuppliersUseCase.execute();
      _isLoading = false;
      if (!_disposed) notifyListeners();
      AppLogger.info('Suppliers loaded: ${_suppliers.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      if (!_disposed) notifyListeners();
      AppLogger.error(
        'Failed to load suppliers',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Add a new supplier
  Future<bool> addSupplier(Supplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    if (!_disposed) notifyListeners();

    try {
      AppLogger.info('Adding supplier: ${supplier.name}');
      final added = await _addSupplierUseCase.execute(supplier);
      _suppliers = [..._suppliers, added];
      _isLoading = false;
      if (!_disposed) notifyListeners();
      AppLogger.info('Supplier added successfully');
      return true;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      if (!_disposed) notifyListeners();
      AppLogger.error(
        'Failed to add supplier',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Update a supplier
  Future<bool> updateSupplier(Supplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    if (!_disposed) notifyListeners();

    try {
      AppLogger.info('Updating supplier: ${supplier.id}');
      final updated = await _updateSupplierUseCase.execute(supplier);
      _suppliers = [
        for (final sup in _suppliers)
          if (sup.id == supplier.id) updated else sup
      ];
      _isLoading = false;
      if (!_disposed) notifyListeners();
      AppLogger.info('Supplier updated successfully');
      return true;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      if (!_disposed) notifyListeners();
      AppLogger.error(
        'Failed to update supplier',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Delete a supplier
  Future<bool> deleteSupplier(int id) async {
    _isLoading = true;
    _errorMessage = null;
    if (!_disposed) notifyListeners();

    try {
      AppLogger.info('Deleting supplier: $id');
      await _deleteSupplierUseCase.execute(id);
      _suppliers = _suppliers.where((sup) => sup.id != id).toList();
      _isLoading = false;
      if (!_disposed) notifyListeners();
      AppLogger.info('Supplier deleted successfully');
      return true;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      if (!_disposed) notifyListeners();
      AppLogger.error(
        'Failed to delete supplier',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (!_disposed) notifyListeners();
  }
}
