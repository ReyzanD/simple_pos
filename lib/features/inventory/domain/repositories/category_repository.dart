import '../entities/category.dart';

/// Interface for category repository operations
abstract class CategoryRepository {
  /// Retrieves all categories
  Future<List<Category>> getCategories();

  /// Retrieves a single category by ID
  Future<Category> getCategoryById(int id);

  /// Adds a new category
  Future<Category> addCategory(Category category);

  /// Updates an existing category
  Future<void> updateCategory(Category category);

  /// Deletes a category
  Future<void> deleteCategory(int id);

  /// Checks if category name exists
  Future<bool> categoryExists(String name);
}
