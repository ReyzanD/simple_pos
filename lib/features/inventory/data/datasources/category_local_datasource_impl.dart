import '../models/category_model.dart';
import 'package:simple_pos/core/database/database_helper.dart'; // Use package import
import 'package:simple_pos/core/exceptions/app_exceptions.dart'
    as app_exceptions;
import 'package:simple_pos/core/utils/logger.dart';

/// Implementation of category local data source
class CategoryLocalDataSourceImpl {
  final DatabaseHelper databaseHelper;

  CategoryLocalDataSourceImpl({required this.databaseHelper});

  /// Creates a new category
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      AppLogger.debug(
        'Creating category in local data source',
        tag: 'CategoryDataSource',
      );

      // CHANGED: Use the categories DAO
      final result = await databaseHelper.categories.insert(category.toMap());

      AppLogger.info(
        'Category created successfully',
        tag: 'CategoryDataSource',
      );
      return CategoryModel.fromMap(result);
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in createCategory',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal membuat kategori',
        operation: 'createCategory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      AppLogger.debug(
        'Fetching all categories from local data source',
        tag: 'CategoryDataSource',
      );

      // CHANGED: Use the categories DAO
      final data = await databaseHelper.categories.getAll();

      AppLogger.info(
        'Categories fetched successfully',
        tag: 'CategoryDataSource',
      );
      return data.map((map) => CategoryModel.fromMap(map)).toList();
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getAllCategories',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil semua kategori',
        operation: 'getAllCategories',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets a category by ID
  Future<CategoryModel> getCategoryById(int id) async {
    try {
      AppLogger.debug('Fetching category by ID', tag: 'CategoryDataSource');

      // CHANGED: Use the categories DAO
      final data = await databaseHelper.categories.getById(id);

      if (data == null) {
        throw app_exceptions.NotFoundException(
          'Kategori tidak ditemukan',
          resourceType: 'Kategori',
          resourceId: id.toString(),
        );
      }

      AppLogger.info(
        'Category fetched successfully',
        tag: 'CategoryDataSource',
      );
      return CategoryModel.fromMap(data);
    } on app_exceptions.NotFoundException {
      rethrow;
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getCategoryById',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengambil kategori',
        operation: 'getCategoryById',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates a category
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    if (category.id == null) {
      throw const app_exceptions.ValidationException(
        'ID kategori diperlukan untuk update',
        field: 'ID',
      );
    }

    try {
      AppLogger.debug('Updating category', tag: 'CategoryDataSource');

      // CHANGED: Use the categories DAO
      await databaseHelper.categories.update(category.id!, category.toMap());

      AppLogger.info(
        'Category updated successfully',
        tag: 'CategoryDataSource',
      );
      return category;
    } on app_exceptions.ValidationException {
      rethrow;
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in updateCategory',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal mengupdate kategori',
        operation: 'updateCategory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a category
  Future<void> deleteCategory(int id) async {
    try {
      AppLogger.debug('Deleting category', tag: 'CategoryDataSource');

      // CHANGED: Use the categories DAO
      await databaseHelper.categories.delete(id);

      AppLogger.info(
        'Category deleted successfully',
        tag: 'CategoryDataSource',
      );
    } on app_exceptions.DatabaseException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in deleteCategory',
        error: e,
        stackTrace: stackTrace,
        tag: 'CategoryDataSource',
      );
      throw app_exceptions.DatabaseException(
        'Gagal menghapus kategori',
        operation: 'deleteCategory',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
