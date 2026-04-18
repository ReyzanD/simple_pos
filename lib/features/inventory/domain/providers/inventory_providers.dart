import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Core dependency
import 'package:simple_pos/core/database/database_helper.dart';

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

/// Inventory feature providers
///
/// Manages all dependencies for inventory management:
/// - Products (CRUD, search, import)
/// - Categories (CRUD)
/// - Suppliers (CRUD)
List<SingleChildWidget> createInventoryProviders() {
  return [
    // Product data sources
    ProxyProvider<DatabaseHelper, ProductLocalDataSourceImpl>(
      update: (_, db, _) => ProductLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<ProductLocalDataSourceImpl, ProductRepositoryImpl>(
      update: (_, dataSource, _) =>
          ProductRepositoryImpl(localDataSource: dataSource),
    ),

    // Product use cases
    ProxyProvider<ProductRepositoryImpl, GetProductsUseCase>(
      update: (_, repo, _) => GetProductsUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, AddProductUseCase>(
      update: (_, repo, _) => AddProductUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, UpdateProductUseCase>(
      update: (_, repo, _) => UpdateProductUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, DeleteProductUseCase>(
      update: (_, repo, _) => DeleteProductUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, SearchProductsUseCase>(
      update: (_, repo, _) => SearchProductsUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, ImportProductsFromCsvUseCase>(
      update: (_, repo, _) => ImportProductsFromCsvUseCase(productRepository: repo),
    ),

    // Category data sources
    ProxyProvider<DatabaseHelper, CategoryLocalDataSourceImpl>(
      update: (_, db, _) => CategoryLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<CategoryLocalDataSourceImpl, CategoryRepositoryImpl>(
      update: (_, dataSource, _) =>
          CategoryRepositoryImpl(localDataSource: dataSource),
    ),

    // Category use cases (from category_usecases.dart)
    ProxyProvider<CategoryRepositoryImpl, GetCategoriesUseCase>(
      update: (_, repo, _) => GetCategoriesUseCase(repository: repo),
    ),
    ProxyProvider<CategoryRepositoryImpl, AddCategoryUseCase>(
      update: (_, repo, _) => AddCategoryUseCase(repository: repo),
    ),
    ProxyProvider<CategoryRepositoryImpl, UpdateCategoryUseCase>(
      update: (_, repo, _) => UpdateCategoryUseCase(repository: repo),
    ),
    ProxyProvider<CategoryRepositoryImpl, DeleteCategoryUseCase>(
      update: (_, repo, _) => DeleteCategoryUseCase(repository: repo),
    ),

    // Supplier data sources
    ProxyProvider<DatabaseHelper, SupplierLocalDataSourceImpl>(
      update: (_, db, _) => SupplierLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<SupplierLocalDataSourceImpl, SupplierRepositoryImpl>(
      update: (_, dataSource, _) =>
          SupplierRepositoryImpl(localDataSource: dataSource),
    ),

    // Supplier use cases (from supplier_usecases.dart)
    ProxyProvider<SupplierRepositoryImpl, GetSuppliersUseCase>(
      update: (_, repo, _) => GetSuppliersUseCase(repository: repo),
    ),
    ProxyProvider<SupplierRepositoryImpl, AddSupplierUseCase>(
      update: (_, repo, _) => AddSupplierUseCase(repository: repo),
    ),
    ProxyProvider<SupplierRepositoryImpl, UpdateSupplierUseCase>(
      update: (_, repo, _) => UpdateSupplierUseCase(repository: repo),
    ),
    ProxyProvider<SupplierRepositoryImpl, DeleteSupplierUseCase>(
      update: (_, repo, _) => DeleteSupplierUseCase(repository: repo),
    ),

    // Controllers
    ChangeNotifierProxyProvider6<
      GetProductsUseCase,
      AddProductUseCase,
      UpdateProductUseCase,
      DeleteProductUseCase,
      SearchProductsUseCase,
      ImportProductsFromCsvUseCase,
      InventoryController
    >(
      create: (context) => InventoryController(
        getProductsUseCase: context.read(),
        addProductUseCase: context.read(),
        updateProductUseCase: context.read(),
        deleteProductUseCase: context.read(),
        searchProductsUseCase: context.read(),
        importProductsFromCsvUseCase: context.read(),
      ),
      update: (_, getProducts, add, update, delete, search, import, _) =>
          InventoryController(
        getProductsUseCase: getProducts,
        addProductUseCase: add,
        updateProductUseCase: update,
        deleteProductUseCase: delete,
        searchProductsUseCase: search,
        importProductsFromCsvUseCase: import,
      ),
    ),

    ChangeNotifierProxyProvider4<
      GetCategoriesUseCase,
      AddCategoryUseCase,
      UpdateCategoryUseCase,
      DeleteCategoryUseCase,
      CategoryController
    >(
      create: (context) => CategoryController(
        getCategoriesUseCase: context.read(),
        addCategoryUseCase: context.read(),
        updateCategoryUseCase: context.read(),
        deleteCategoryUseCase: context.read(),
      ),
      update: (_, get, add, update, delete, _) => CategoryController(
        getCategoriesUseCase: get,
        addCategoryUseCase: add,
        updateCategoryUseCase: update,
        deleteCategoryUseCase: delete,
      ),
    ),

    ChangeNotifierProxyProvider4<
      GetSuppliersUseCase,
      AddSupplierUseCase,
      UpdateSupplierUseCase,
      DeleteSupplierUseCase,
      SupplierController
    >(
      create: (context) => SupplierController(
        getSuppliersUseCase: context.read(),
        addSupplierUseCase: context.read(),
        updateSupplierUseCase: context.read(),
        deleteSupplierUseCase: context.read(),
      ),
      update: (_, get, add, update, delete, _) => SupplierController(
        getSuppliersUseCase: get,
        addSupplierUseCase: add,
        updateSupplierUseCase: update,
        deleteSupplierUseCase: delete,
      ),
    ),
  ];
}
