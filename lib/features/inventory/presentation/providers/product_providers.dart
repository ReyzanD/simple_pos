import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/datasources/product_local_datasource_impl.dart';
import '../../../shared/presentation/providers.dart';

// Product Local Data Source Provider
final _productLocalDataSourceProvider = Provider(
  (ref) => ProductLocalDataSourceImpl(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);

// Product Repository Provider
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(
    localDataSource: ref.watch(_productLocalDataSourceProvider),
  ),
);
