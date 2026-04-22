import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core dependency
import 'package:simple_pos/core/database/database_helper.dart';
import 'package:simple_pos/core/providers/core_providers.dart';

// Inventory Data Layer
import 'package:simple_pos/features/inventory/data/datasources/product_local_datasource_impl.dart';
import 'package:simple_pos/features/inventory/data/datasources/category_local_datasource_impl.dart';
import 'package:simple_pos/features/inventory/data/datasources/supplier_local_datasource_impl.dart';
import 'package:simple_pos/features/inventory/data/repositories/product_repository_impl.dart';
import 'package:simple_pos/features/inventory/data/repositories/category_repository_impl.dart';
import 'package:simple_pos/features/inventory/data/repositories/supplier_repository_impl.dart';

// Inventory Domain Layer (Use Cases)
import 'package:simple_pos/features/inventory/domain/usecases/get_products_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/update_product_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/delete_product_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/search_products_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/import_products_from_csv_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/category_usecases.dart';
import 'package:simple_pos/features/inventory/domain/usecases/supplier_usecases.dart';

// Inventory Presentation Layer (Controllers)
import 'package:simple_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/category_controller.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/supplier_controller.dart';

// --- DATA LAYER (Product) ---

final productLocalDataSourceProvider = Provider<ProductLocalDataSourceImpl>((
  ref,
) {
  final db = ref.watch(databaseHelperProvider);
  return ProductLocalDataSourceImpl(databaseHelper: db);
});

final productRepositoryProvider = Provider<ProductRepositoryImpl>((ref) {
  return ProductRepositoryImpl(
    localDataSource: ref.watch(productLocalDataSourceProvider),
  );
});

// --- DATA LAYER (Category) ---

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSourceImpl>((
  ref,
) {
  final db = ref.watch(databaseHelperProvider);
  return CategoryLocalDataSourceImpl(databaseHelper: db);
});

final categoryRepositoryProvider = Provider<CategoryRepositoryImpl>((ref) {
  return CategoryRepositoryImpl(
    localDataSource: ref.watch(categoryLocalDataSourceProvider),
  );
});

// --- DATA LAYER (Supplier) ---

final supplierLocalDataSourceProvider = Provider<SupplierLocalDataSourceImpl>((
  ref,
) {
  final db = ref.watch(databaseHelperProvider);
  return SupplierLocalDataSourceImpl(databaseHelper: db);
});

final supplierRepositoryProvider = Provider<SupplierRepositoryImpl>((ref) {
  return SupplierRepositoryImpl(
    localDataSource: ref.watch(supplierLocalDataSourceProvider),
  );
});

// --- DOMAIN LAYER (Product Use Cases) ---

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(repository: ref.watch(productRepositoryProvider));
});

final addProductUseCaseProvider = Provider<AddProductUseCase>((ref) {
  return AddProductUseCase(repository: ref.watch(productRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(repository: ref.watch(productRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(repository: ref.watch(productRepositoryProvider));
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  return SearchProductsUseCase(
    repository: ref.watch(productRepositoryProvider),
  );
});

final importProductsFromCsvUseCaseProvider =
    Provider<ImportProductsFromCsvUseCase>((ref) {
      return ImportProductsFromCsvUseCase(
        productRepository: ref.watch(productRepositoryProvider),
      );
    });

// --- DOMAIN LAYER (Category Use Cases) ---

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(
    repository: ref.watch(categoryRepositoryProvider),
  );
});

final addCategoryUseCaseProvider = Provider<AddCategoryUseCase>((ref) {
  return AddCategoryUseCase(repository: ref.watch(categoryRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider<UpdateCategoryUseCase>((ref) {
  return UpdateCategoryUseCase(
    repository: ref.watch(categoryRepositoryProvider),
  );
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(
    repository: ref.watch(categoryRepositoryProvider),
  );
});

// --- DOMAIN LAYER (Supplier Use Cases) ---

final getSuppliersUseCaseProvider = Provider<GetSuppliersUseCase>((ref) {
  return GetSuppliersUseCase(repository: ref.watch(supplierRepositoryProvider));
});

final addSupplierUseCaseProvider = Provider<AddSupplierUseCase>((ref) {
  return AddSupplierUseCase(repository: ref.watch(supplierRepositoryProvider));
});

final updateSupplierUseCaseProvider = Provider<UpdateSupplierUseCase>((ref) {
  return UpdateSupplierUseCase(
    repository: ref.watch(supplierRepositoryProvider),
  );
});

final deleteSupplierUseCaseProvider = Provider<DeleteSupplierUseCase>((ref) {
  return DeleteSupplierUseCase(
    repository: ref.watch(supplierRepositoryProvider),
  );
});

// --- PRESENTATION LAYER ---

final inventoryControllerProvider = ChangeNotifierProvider<InventoryController>(
  (ref) {
    return InventoryController(
      getProductsUseCase: ref.watch(getProductsUseCaseProvider),
      addProductUseCase: ref.watch(addProductUseCaseProvider),
      updateProductUseCase: ref.watch(updateProductUseCaseProvider),
      deleteProductUseCase: ref.watch(deleteProductUseCaseProvider),
      searchProductsUseCase: ref.watch(searchProductsUseCaseProvider),
      importProductsFromCsvUseCase: ref.watch(
        importProductsFromCsvUseCaseProvider,
      ),
    );
  },
);

final categoryControllerProvider = ChangeNotifierProvider<CategoryController>((
  ref,
) {
  return CategoryController(
    getCategoriesUseCase: ref.watch(getCategoriesUseCaseProvider),
    addCategoryUseCase: ref.watch(addCategoryUseCaseProvider),
    updateCategoryUseCase: ref.watch(updateCategoryUseCaseProvider),
    deleteCategoryUseCase: ref.watch(deleteCategoryUseCaseProvider),
  );
});

final supplierControllerProvider = ChangeNotifierProvider<SupplierController>((
  ref,
) {
  return SupplierController(
    getSuppliersUseCase: ref.watch(getSuppliersUseCaseProvider),
    addSupplierUseCase: ref.watch(addSupplierUseCaseProvider),
    updateSupplierUseCase: ref.watch(updateSupplierUseCaseProvider),
    deleteSupplierUseCase: ref.watch(deleteSupplierUseCaseProvider),
  );
});
