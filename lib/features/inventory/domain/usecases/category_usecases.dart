import '../entities/category.dart';
import '../repositories/category_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Use case for getting all categories
class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase({required this.repository});

  Future<List<Category>> execute() async {
    try {
      AppLogger.useCase('GetCategories');
      return await repository.getCategories();
    } catch (e, stackTrace) {
      AppLogger.error('GetCategories failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Use case for adding a new category
class AddCategoryUseCase {
  final CategoryRepository repository;

  AddCategoryUseCase({required this.repository});

  Future<Category> execute(Category category) async {
    try {
      AppLogger.useCase('AddCategory', details: category.name);
      category.validate();
      return await repository.addCategory(category);
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('AddCategory failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Use case for updating a category
class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase({required this.repository});

  Future<Category> execute(Category category) async {
    try {
      AppLogger.useCase('UpdateCategory', details: 'ID: ${category.id}');
      if (category.id == null) {
        throw const ValidationException('ID kategori diperlukan', field: 'ID');
      }
      category.validate();
      await repository.updateCategory(category);
      return category;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('UpdateCategory failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Use case for deleting a category
class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase({required this.repository});

  Future<void> execute(int id) async {
    try {
      AppLogger.useCase('DeleteCategory', details: 'ID: $id');
      await repository.deleteCategory(id);
    } catch (e, stackTrace) {
      AppLogger.error('DeleteCategory failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
