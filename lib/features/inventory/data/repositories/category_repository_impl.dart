import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource_impl.dart';
import '../models/category_model.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of category repository
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSourceImpl localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Category>> getCategories() async {
    try {
      AppLogger.debug('Fetching all categories', tag: 'CategoryRepository');

      final categoryModels = await localDataSource.getAllCategories();

      AppLogger.info('Categories fetched successfully', tag: 'CategoryRepository');
      return categoryModels.map((model) => model.toEntity()).toList();
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getCategories',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryRepository',
      );
      throw DatabaseException(
        'Gagal mengambil kategori',
        operation: 'getCategories',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Category> getCategoryById(int id) async {
    try {
      AppLogger.debug('Fetching category by ID', tag: 'CategoryRepository');

      final categoryModel = await localDataSource.getCategoryById(id);

      AppLogger.info('Category fetched successfully', tag: 'CategoryRepository');
      return categoryModel.toEntity();
    } on NotFoundException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getCategoryById',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryRepository',
      );
      throw DatabaseException(
        'Gagal mengambil kategori',
        operation: 'getCategoryById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Category> addCategory(Category category) async {
    try {
      AppLogger.debug('Creating category', tag: 'CategoryRepository');

      final categoryModel = CategoryModel.fromEntity(category);
      final createdModel = await localDataSource.createCategory(categoryModel);

      AppLogger.info('Category created successfully', tag: 'CategoryRepository');
      return createdModel.toEntity();
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in addCategory',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryRepository',
      );
      throw DatabaseException(
        'Gagal membuat kategori',
        operation: 'addCategory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      AppLogger.debug('Updating category', tag: 'CategoryRepository');

      if (category.id == null) {
        throw const ValidationException(
          'ID kategori diperlukan',
          field: 'ID',
        );
      }

      final categoryModel = CategoryModel.fromEntity(category);
      await localDataSource.updateCategory(categoryModel);

      AppLogger.info('Category updated successfully', tag: 'CategoryRepository');
    } on ValidationException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateCategory',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryRepository',
      );
      throw DatabaseException(
        'Gagal mengupdate kategori',
        operation: 'updateCategory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      AppLogger.debug('Deleting category', tag: 'CategoryRepository');

      await localDataSource.deleteCategory(id);

      AppLogger.info('Category deleted successfully', tag: 'CategoryRepository');
    } on DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteCategory',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryRepository',
      );
      throw DatabaseException(
        'Gagal menghapus kategori',
        operation: 'deleteCategory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> categoryExists(String name) async {
    try {
      final categories = await localDataSource.getAllCategories();
      return categories.any((cat) => cat.name.toLowerCase() == name.toLowerCase());
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check category existence',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryRepository',
      );
      return false;
    }
  }
}
