import 'package:flutter/foundation.dart';
import '../../domain/entities/category.dart' as entities;
import '../../domain/usecases/category_usecases.dart';
import '../../../../core/utils/logger.dart';

/// Controller for managing categories
class CategoryController extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final AddCategoryUseCase _addCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  bool _disposed = false;

  CategoryController({
    required GetCategoriesUseCase getCategoriesUseCase,
    required AddCategoryUseCase addCategoryUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required DeleteCategoryUseCase deleteCategoryUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _addCategoryUseCase = addCategoryUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _deleteCategoryUseCase = deleteCategoryUseCase {
    loadCategories();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // State
  List<entities.Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<entities.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  int get categoryCount => _categories.length;

  /// Load all categories
  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    if (!_disposed) notifyListeners();

    try {
      AppLogger.info('Loading categories');
      _categories = await _getCategoriesUseCase.execute();
      _isLoading = false;
      if (!_disposed) notifyListeners();
      AppLogger.info('Categories loaded: ${_categories.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      if (!_disposed) notifyListeners();
      AppLogger.error(
        'Failed to load categories',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Add a new category
  Future<bool> addCategory(entities.Category category) async {
    _isLoading = true;
    _errorMessage = null;
    if (!_disposed) notifyListeners();

    try {
      AppLogger.info('Adding category: ${category.name}');

      // Validate category before adding
      category.validate();

      final added = await _addCategoryUseCase.execute(category);
      _categories = [..._categories, added];
      _isLoading = false;
      if (!_disposed) notifyListeners();
      AppLogger.info('Category added successfully');
      return true;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      if (!_disposed) notifyListeners();
      AppLogger.error(
        'Failed to add category',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Update a category
  Future<bool> updateCategory(entities.Category category) async {
    _isLoading = true;
    _errorMessage = null;
    if (!_disposed) notifyListeners();

    try {
      AppLogger.info('Updating category: ${category.id}');

      // Validate category before updating
      category.validate();

      final updated = await _updateCategoryUseCase.execute(category);
      _categories = [
        for (final cat in _categories)
          if (cat.id == category.id) updated else cat
      ];
      _isLoading = false;
      if (!_disposed) notifyListeners();
      AppLogger.info('Category updated successfully');
      return true;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      if (!_disposed) notifyListeners();
      AppLogger.error(
        'Failed to update category',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    if (!_disposed) notifyListeners();

    try {
      AppLogger.info('Deleting category: $id');
      await _deleteCategoryUseCase.execute(id);
      _categories = _categories.where((cat) => cat.id != id).toList();
      _isLoading = false;
      if (!_disposed) notifyListeners();
      AppLogger.info('Category deleted successfully');
      return true;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = e.toString();
      if (!_disposed) notifyListeners();
      AppLogger.error(
        'Failed to delete category',
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
