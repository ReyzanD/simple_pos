import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/supplier.dart';

part 'supplier_provider.g.dart';

/// Supplier notifier - manages supplier state
@riverpod
class SupplierNotifier extends _$SupplierNotifier {
  @override
  List<Supplier> build() {
    // For now, return empty list
    // TODO: Wire up with use case after migrating supplier controller
    return [];
  }

  /// Load all suppliers
  Future<void> loadSuppliers() async {
    // TODO: Wire up with use case after migrating supplier controller
    state = [];
  }
}

/// Public provider for widgets
final supplierProvider = supplierNotifierProvider;
