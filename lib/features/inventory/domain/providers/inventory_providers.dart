import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Package imports for Infrastructure
import 'package:simple_pos/core/database/database_helper.dart';

// Data Sources
import 'package:simple_pos/features/inventory/data/datasources/product_local_datasource_impl.dart';
import 'package:simple_pos/features/inventory/data/datasources/category_local_datasource_impl.dart';
import 'package:simple_pos/features/inventory/data/datasources/supplier_local_datasource_impl.dart';
import 'package:simple_pos/features/inventory/data/datasources/product_variant_local_datasource.dart';

// Repositories
import 'package:simple_pos/features/inventory/data/repositories/product_repository_impl.dart';
import 'package:simple_pos/features/inventory/data/repositories/category_repository_impl.dart';
import 'package:simple_pos/features/inventory/data/repositories/supplier_repository_impl.dart';
import 'package:simple_pos/features/inventory/data/repositories/product_variant_repository_impl.dart';

// Use Cases
import 'package:simple_pos/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/delete_product_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/get_products_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/search_products_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/update_product_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/import_products_from_csv_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/category_usecases.dart';
import 'package:simple_pos/features/inventory/domain/usecases/supplier_usecases.dart';
import 'package:simple_pos/features/inventory/domain/usecases/get_product_variants_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/add_product_variant_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/update_product_variant_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/delete_product_variant_usecase.dart';
import 'package:simple_pos/features/inventory/domain/usecases/variant_attribute_usecases.dart';

// Controllers
import 'package:simple_pos/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/category_controller.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/supplier_controller.dart';
import 'package:simple_pos/features/inventory/presentation/controllers/product_variant_controller.dart';

List<SingleChildWidget> createInventoryProviders() {
  return [
    // --- DATA LAYER ---
    ProxyProvider<DatabaseHelper, ProductLocalDataSourceImpl>(
      update: (_, db, __) => ProductLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<DatabaseHelper, CategoryLocalDataSourceImpl>(
      update: (_, db, __) => CategoryLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<DatabaseHelper, SupplierLocalDataSourceImpl>(
      update: (_, db, __) => SupplierLocalDataSourceImpl(databaseHelper: db),
    ),
    ProxyProvider<DatabaseHelper, ProductVariantLocalDataSourceImpl>(
      update: (_, db, __) =>
          ProductVariantLocalDataSourceImpl(databaseHelper: db),
    ),

    // --- REPOSITORY LAYER ---
    ProxyProvider<ProductLocalDataSourceImpl, ProductRepositoryImpl>(
      update: (_, ds, __) => ProductRepositoryImpl(localDataSource: ds),
    ),
    ProxyProvider<CategoryLocalDataSourceImpl, CategoryRepositoryImpl>(
      update: (_, ds, __) => CategoryRepositoryImpl(localDataSource: ds),
    ),
    ProxyProvider<SupplierLocalDataSourceImpl, SupplierRepositoryImpl>(
      update: (_, ds, __) => SupplierRepositoryImpl(localDataSource: ds),
    ),
    ProxyProvider<
      ProductVariantLocalDataSourceImpl,
      ProductVariantRepositoryImpl
    >(update: (_, ds, __) => ProductVariantRepositoryImpl(dataSource: ds)),

    // --- DOMAIN LAYER (Use Cases) ---
    ProxyProvider<ProductRepositoryImpl, GetProductsUseCase>(
      update: (_, repo, __) => GetProductsUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, AddProductUseCase>(
      update: (_, repo, __) => AddProductUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, UpdateProductUseCase>(
      update: (_, repo, __) => UpdateProductUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, DeleteProductUseCase>(
      update: (_, repo, __) => DeleteProductUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, SearchProductsUseCase>(
      update: (_, repo, __) => SearchProductsUseCase(repository: repo),
    ),
    ProxyProvider<ProductRepositoryImpl, ImportProductsFromCsvUseCase>(
      update: (_, repo, __) =>
          ImportProductsFromCsvUseCase(productRepository: repo),
    ),

    // --- PRESENTATION LAYER (Controllers) ---
    ChangeNotifierProvider<InventoryController>(
      create: (context) => InventoryController(
        getProductsUseCase: context.read<GetProductsUseCase>(),
        addProductUseCase: context.read<AddProductUseCase>(),
        updateProductUseCase: context.read<UpdateProductUseCase>(),
        deleteProductUseCase: context.read<DeleteProductUseCase>(),
        searchProductsUseCase: context.read<SearchProductsUseCase>(),
        importProductsFromCsvUseCase: context
            .read<ImportProductsFromCsvUseCase>(),
      ),
    ),

    // Example for Category Controller if needed:
    // ProxyProvider...
  ];
}
