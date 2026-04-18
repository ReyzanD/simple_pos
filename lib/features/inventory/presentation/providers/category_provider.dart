import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/category_usecases.dart';
import '../../domain/entities/category.dart';

part 'category_provider.g.dart';

/// Category notifier - manages category state
@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  List<Category> build() {
    // For now, return empty list
    // TODO: Wire up with use case after migrating category controller
    return [];
  }

  /// Load all categories
  Future<void> loadCategories() async {
    // TODO: Wire up with use case after migrating category controller
    state = [];
  }
}

/// Public provider for widgets
final categoryProvider = categoryNotifierProvider;
